//
//  NodeViewController.swift
//  Solary
//
//  Created by Gyorgy Borz on 2020. 06. 07..
//  Copyright © 2020. Gyorgy Borz. All rights reserved.
//

import UIKit

class NodeViewController: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    private let nodeData: [NodeData] = [
        NodeData(sceneType: .solarSystem, fileName: "solarSystem", name: "Solar system"),
        NodeData(sceneType: .planet, fileName: "sun", name: "Sun"),
        NodeData(sceneType: .planet, fileName: "mercury", name: "Mercury"),
        NodeData(sceneType: .planet, fileName: "venus", name: "Venus"),
        NodeData(sceneType: .planet, fileName: "earthDay", name: "Earth (day)"),
        NodeData(sceneType: .planet, fileName: "earthNight", name: "Earth (night)"),
        NodeData(sceneType: .planet, fileName: "moon", name: "Moon"),
        NodeData(sceneType: .planet, fileName: "mars", name: "Mars"),
        NodeData(sceneType: .planet, fileName: "jupiter", name: "Jupiter"),
        NodeData(sceneType: .planet, fileName: "saturn", name: "Saturn"),
        NodeData(sceneType: .planet, fileName: "uranus", name: "Uranus"),
        NodeData(sceneType: .planet, fileName: "neptune", name: "Neptune")
    ]
    
    @IBOutlet weak var sceneTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    private func configure() {
        view.backgroundColor = .black
        
        sceneTableView.delegate = self
        sceneTableView.dataSource = self
        sceneTableView.register(UINib(nibName: "NodeTableViewCell", bundle: nil), forCellReuseIdentifier: "NodeCell")
        sceneTableView.separatorStyle = .none
        sceneTableView.rowHeight = 150
        sceneTableView.backgroundColor = .clear
    }

}

extension NodeViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        nodeData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = sceneTableView.dequeueReusableCell(withIdentifier: "NodeCell", for: indexPath) as! NodeTableViewCell
        
        cell.nodeLabel.text = nodeData[indexPath.row].name
        cell.nodeImageView.image = UIImage(named: nodeData[indexPath.row].fileName)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let chosenNode = nodeData[indexPath.row]
        let destVC = self.storyboard?.instantiateViewController(withIdentifier: "ARViewController") as! ARViewController
        destVC.nodeData = chosenNode
        destVC.modalPresentationStyle = .fullScreen
        present(destVC, animated: true) { [weak self] in
            self?.sceneTableView.deselectRow(at: indexPath, animated: false)
        }
    }
    
}
