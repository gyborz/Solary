//
//  SceneViewController.swift
//  Solary
//
//  Created by Gyorgy Borz on 2020. 06. 07..
//  Copyright © 2020. Gyorgy Borz. All rights reserved.
//

import UIKit

class SceneViewController: UIViewController {
    
    private let data: [Scene] = [
            Scene(sceneType: .solarSystem, name: "solarSystem", rotation: nil),
            Scene(sceneType: .planet, name: "sun", rotation: nil),
            Scene(sceneType: .planet, name: "mercury", rotation: nil),
            Scene(sceneType: .planet, name: "venus", rotation: nil),
            Scene(sceneType: .planet, name: "earth day", rotation: nil),
            Scene(sceneType: .planet, name: "earth night", rotation: nil),
            Scene(sceneType: .planet, name: "moon", rotation: nil),
            Scene(sceneType: .planet, name: "mars", rotation: nil),
            Scene(sceneType: .planet, name: "jupiter", rotation: nil),
            Scene(sceneType: .planet, name: "saturnus", rotation: nil),
            Scene(sceneType: .planet, name: "uranus", rotation: nil),
            Scene(sceneType: .planet, name: "neptunus", rotation: nil)
        ]
    
    @IBOutlet weak var sceneTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
    }
    
    private func configure() {
        sceneTableView.delegate = self
        sceneTableView.dataSource = self
        sceneTableView.register(UINib(nibName: "SceneTableViewCell", bundle: nil), forCellReuseIdentifier: "SceneCell")
        sceneTableView.separatorStyle = .none
    }

}

extension SceneViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = sceneTableView.dequeueReusableCell(withIdentifier: "SceneCell", for: indexPath) as! SceneTableViewCell
        
        cell.sceneLabel.text = data[indexPath.row].name
        
        return cell
    }
    
}
