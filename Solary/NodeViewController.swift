//
//  NodeViewController.swift
//  Solary
//
//  Created by Gyorgy Borz on 2020. 06. 07..
//  Copyright © 2020. Gyorgy Borz. All rights reserved.
//

import UIKit

class NodeViewController: UIViewController {
    
    // MARK: - Properties
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    /// hard coded data for the tableView and ARViewController
    private let nodeData: [NodeData] = [
        NodeData(sceneType: .solarSystem, nodeName: "solarSystem", title: "Solar system"),
        NodeData(sceneType: .planet, nodeName: "sun", title: "Sun"),
        NodeData(sceneType: .planet, nodeName: "mercury", title: "Mercury"),
        NodeData(sceneType: .planet, nodeName: "venus", title: "Venus"),
        NodeData(sceneType: .planet, nodeName: "earthDay", title: "Earth (day)"),
        NodeData(sceneType: .planet, nodeName: "earthNight", title: "Earth (night)"),
        NodeData(sceneType: .planet, nodeName: "moon", title: "Moon"),
        NodeData(sceneType: .planet, nodeName: "mars", title: "Mars"),
        NodeData(sceneType: .planet, nodeName: "jupiter", title: "Jupiter"),
        NodeData(sceneType: .planet, nodeName: "saturn", title: "Saturn"),
        NodeData(sceneType: .planet, nodeName: "uranus", title: "Uranus"),
        NodeData(sceneType: .planet, nodeName: "neptune", title: "Neptune")
    ]
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var sceneTableView: UITableView!
    
    // MARK: - View Controller Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    // MARK: - UI Setup
    
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

// MARK: - UITableViewDataSource, UITableViewDelegate

extension NodeViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        nodeData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = sceneTableView.dequeueReusableCell(withIdentifier: "NodeCell", for: indexPath) as! NodeTableViewCell
        
        cell.nodeLabel.text = nodeData[indexPath.row].title
        cell.nodeImageView.image = UIImage(named: nodeData[indexPath.row].nodeName)
        
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
