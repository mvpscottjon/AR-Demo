//
//  ViewController.swift
//  ar-test
//
//  Created by Seven Tsai on 2023/7/29.
//

import UIKit
import RealityKit
import ARKit
import SnapKit
import CombineCocoa
import Combine

final class ViewController: UIViewController {
    
    enum Constants {
        static let selectedNodeColor = UIColor.yellow
        static let unselectedNodeColor = UIColor.white
    }
    
    struct Vector {
        let x: Float
        let y: Float
        let z: Float
        
        func mapToVector() -> SCNVector3 {
            SCNVector3(x: x, y: y, z: z)
        }
    }
    
//    /// x, y, z
//    typealias Plane = (CGFloat, CGFloat, CGFloat)
    
    // MARK: Property
    
    @Published private var selectedObject: ARObject? = .box
    @Published private var selectedNodes: [SCNNode] = []
//    private var selectedNodes: [SCNNode] = []
    
    private var cancelBags = Set<AnyCancellable>()
    
    // MARK: View
    
    private let sceneView: ARSCNView = {
        ARSCNView()
    }()
    
    private let button: UIButton = {
        let button = UIButton()
        button.setTitle("3D OBJs", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .yellow
        return button
    }()
    
    private let toolButton: UIButton = {
        let button = UIButton()
        button.setTitle("Tool", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .blue
        return button
    }()
    
    private let objectsVC = ObjectsViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindUI()
        
        addGestures()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let configuration = ARWorldTrackingConfiguration()
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {

        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
}

private extension ViewController {
    
    func configureLighting() {
        sceneView.autoenablesDefaultLighting = true
        sceneView.automaticallyUpdatesLighting = true
    }
    
    func setupUI() {
        setupARSceneView()

        sceneView.addSubview(button)
        button.snp.makeConstraints {
            $0.bottom.trailing.equalToSuperview().inset(20.0)
        }
        
        sceneView.addSubview(toolButton)
        toolButton.snp.makeConstraints {
            $0.bottom.leading.equalToSuperview().inset(20.0)
        }
    }
    
    func bindUI() {
        button.tapPublisher
            .sink(receiveValue: { [weak self] _ in
                guard let self = self else { return }
                self.present(self.objectsVC, animated: true)
            })
            .store(in: &cancelBags)
        
        toolButton.tapPublisher
            .sink(receiveValue: { [weak self] _ in
                self?.removeAllARObject()
            })
            .store(in: &cancelBags)
        
        objectsVC.$selectedObj
            .assign(to: &$selectedObject)
                    
        $selectedObject
            .sink(receiveValue: { selectedObj in
                print("### selctedObj:", selectedObj)
            })
            .store(in: &cancelBags)

//        $selectedNodes
//            .compactMap { $0 }
//            .sink(receiveValue: { [weak self] node in
//                guard let self = self else { return }
//
//
////                node.geometry?.firstMaterial?.diffuse.contents = UIColor.yellow
//
//            })
//            .store(in: &cancelBags)
        
    }
}

private extension ViewController {
    func setupARSceneView() {
        configureLighting()
        view.addSubview(sceneView)
        sceneView.backgroundColor = .orange
        sceneView.snp.makeConstraints { $0.edges.equalToSuperview() }
    }
}

// MARK: - Gesture

extension ViewController {
    
    func addGestures() {
        addTapGestureToSceneView()
        addPinchGestureToScenceView()
    }
    
    func addTapGestureToSceneView() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTap(with:)))
        sceneView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    func addPinchGestureToScenceView() {
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(didPinch))
        sceneView.addGestureRecognizer(pinch)
    }
}

// MARK: - Helper

extension ViewController {
    @objc func didTap(with recognizer: UIGestureRecognizer) {
        let tapLocation = recognizer.location(in: sceneView)
        let hitTestResults = sceneView.hitTest(tapLocation)
        guard let node = hitTestResults.first?.node else {
            
            // 不存在 node 則 add
            let hitTestResultsWithFeaturePoints = sceneView.hitTest(tapLocation, types: .featurePoint)
            
            if let hitTestResultWithFeaturePoints = hitTestResultsWithFeaturePoints.first,
               let arObj = selectedObject
            {
                let translation = hitTestResultWithFeaturePoints.worldTransform.translation
                let plane = Vector(x: translation.x, y: translation.y, z: translation.z)
                addARObject(object: arObj, to: plane)
            }
            return
        }
        
        selectedNodes.forEach { removeSelectedNodeColor(from: $0)}
        setSelectedNodeColor(to: node)
        selectedNodes.append(node)
//        // 已存在則 remove
//        node.removeFromParentNode()
    }
    
    @objc func didPinch(with recognizer: UIPinchGestureRecognizer) {
        guard let node = selectedNodes.last else { return }
        var pinchScale = recognizer.scale
        pinchScale = round(pinchScale * 1000) / 1000.0
        
        node.scale = SCNVector3(x: Float(pinchScale), y: Float(pinchScale), z: Float(pinchScale))
    }
    
    func addARObject(object: ARObject, to plane: Vector) {
        guard let node = object.node else { return }
        node.position = plane.mapToVector()
        node.scale = SCNVector3(0.5, 0.5, 0.5)
        sceneView.scene.rootNode.addChildNode(node)
    }
    
    func removeAllARObject() {
        sceneView.scene.rootNode.childNodes.forEach { $0.removeFromParentNode() }
    }
    
    func removeSelectedNodeColor(from node: SCNNode) {
        node.geometry?.firstMaterial?.diffuse.contents = Constants.unselectedNodeColor
    }
    
    func setSelectedNodeColor(to node: SCNNode, color: UIColor = Constants.selectedNodeColor) {
        node.geometry?.firstMaterial?.diffuse.contents = color
    }
}


