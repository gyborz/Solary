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
    private let data: [Node] = [
        Node(sceneType: .solarSystem, fileName: "solarSystem", name: "Solar system", rotation: nil),
        Node(sceneType: .planet, fileName: "sun", name: "Sun", rotation: nil),
        Node(sceneType: .planet, fileName: "mercury", name: "Mercury", rotation: nil),
        Node(sceneType: .planet, fileName: "venus", name: "Venus", rotation: nil),
        Node(sceneType: .planet, fileName: "earthDay", name: "Earth (day)", rotation: nil),
        Node(sceneType: .planet, fileName: "earthNight", name: "Earth (night)", rotation: nil),
        Node(sceneType: .planet, fileName: "moon", name: "Moon", rotation: nil),
        Node(sceneType: .planet, fileName: "mars", name: "Mars", rotation: nil),
        Node(sceneType: .planet, fileName: "jupiter", name: "Jupiter", rotation: nil),
        Node(sceneType: .planet, fileName: "saturn", name: "Saturn", rotation: nil),
        Node(sceneType: .planet, fileName: "uranus", name: "Uranus", rotation: nil),
        Node(sceneType: .planet, fileName: "neptune", name: "Neptune", rotation: nil)
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
        data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = sceneTableView.dequeueReusableCell(withIdentifier: "NodeCell", for: indexPath) as! NodeTableViewCell
        
        cell.nodeLabel.text = data[indexPath.row].name
        cell.nodeImageView.image = UIImage(named: data[indexPath.row].fileName)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let chosenNode = data[indexPath.row]
        let destVC = self.storyboard?.instantiateViewController(withIdentifier: "ARViewController") as! ARViewController
        destVC.nodeData = chosenNode
        destVC.modalPresentationStyle = .fullScreen
        present(destVC, animated: true, completion: {
            tableView.deselectRow(at: indexPath, animated: true)
        })
    }
    
}
