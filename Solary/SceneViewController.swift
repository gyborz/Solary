//
//  SceneViewController.swift
//  Solary
//
//  Created by Gyorgy Borz on 2020. 06. 07..
//  Copyright © 2020. Gyorgy Borz. All rights reserved.
//

import UIKit

class SceneViewController: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    private let data: [Scene] = [
        Scene(sceneType: .solarSystem, fileName: "solarSystem", name: "Solar system", rotation: nil),
        Scene(sceneType: .planet, fileName: "sun", name: "Sun", rotation: nil),
        Scene(sceneType: .planet, fileName: "mercury", name: "Mercury", rotation: nil),
        Scene(sceneType: .planet, fileName: "venus", name: "Venus", rotation: nil),
        Scene(sceneType: .planet, fileName: "earthDay", name: "Earth (day)", rotation: nil),
        Scene(sceneType: .planet, fileName: "earthNight", name: "Earth (night)", rotation: nil),
        Scene(sceneType: .planet, fileName: "moon", name: "Moon", rotation: nil),
        Scene(sceneType: .planet, fileName: "mars", name: "Mars", rotation: nil),
        Scene(sceneType: .planet, fileName: "jupiter", name: "Jupiter", rotation: nil),
        Scene(sceneType: .planet, fileName: "saturn", name: "Saturn", rotation: nil),
        Scene(sceneType: .planet, fileName: "uranus", name: "Uranus", rotation: nil),
        Scene(sceneType: .planet, fileName: "neptune", name: "Neptune", rotation: nil)
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
        sceneTableView.register(UINib(nibName: "SceneTableViewCell", bundle: nil), forCellReuseIdentifier: "SceneCell")
        sceneTableView.separatorStyle = .none
        sceneTableView.rowHeight = 150
        sceneTableView.backgroundColor = .clear
    }

}

extension SceneViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = sceneTableView.dequeueReusableCell(withIdentifier: "SceneCell", for: indexPath) as! SceneTableViewCell
        
        cell.sceneLabel.text = data[indexPath.row].name
        cell.sceneImageView.image = UIImage(named: data[indexPath.row].fileName)
        
        return cell
    }
    
}
