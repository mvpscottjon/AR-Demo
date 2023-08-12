//
//  ObjectsViewController.swift
//  ar-test
//
//  Created by Seven Tsai on 2023/8/12.
//

import UIKit


final class ObjectsViewController: UITableViewController {
    
    @Published var selectedObj: ARObject?
    
    private var data: [ARObject] = [.box, .car, .plane]
    
    override func viewDidLoad() {
        super.viewDidLoad()        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
}

extension ObjectsViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        data.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let arObject = data[indexPath.row]
        cell.textLabel?.text = arObject.title
        return cell
    }
}

extension ObjectsViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedObj = data[indexPath.row]
        dismiss(animated: true)
    }
}
