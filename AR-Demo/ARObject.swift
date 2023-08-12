//
//  ARObject.swift
//  AR-Demo
//
//  Created by Seven Tsai on 2023/8/12.
//

import Foundation
import SceneKit

enum ARObject {
    case box
    case plane
    case car
    
    var title: String {
        switch self {
        case .box:
            return "箱子"
        case .plane:
            return "飛機"
        case .car:
            return "車子"
        }
    }
    
    var node: SCNNode? {
        switch self {
        case .box:
            return makeBox()
        case .plane:
            return makePaperPlane()
        case .car:
            return makeCar()
        }
    }
}

extension ARObject {
    func makeBox() -> SCNNode {
        let box = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0)
        let boxNode = SCNNode()
        boxNode.geometry = box
        return boxNode
    }
    
    func makePaperPlane() -> SCNNode? {
        guard let paperPlaneScene = SCNScene(named: "paperPlane.scn"),
              let paperPlaneNode = paperPlaneScene.rootNode.childNode(withName: "paperPlane", recursively: true)
        else { return nil }
        return paperPlaneNode
    }
    
    func makeCar()  -> SCNNode? {
        guard let carScene = SCNScene(named: "car.dae") else { return nil }
        let carNode = SCNNode()
        let carSceneChildNodes = carScene.rootNode.childNodes
            
        for childNode in carSceneChildNodes {
            carNode.addChildNode(childNode)
        }
            
        return carNode
    }
}
