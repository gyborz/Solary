//
//  Node.swift
//  Solary
//
//  Created by Gyorgy Borz on 2020. 06. 07..
//  Copyright © 2020. Gyorgy Borz. All rights reserved.
//

import UIKit

struct Node {
    
    var sceneType: SceneType
    var fileName: String
    var name: String
    var rotation: CGFloat?
    
    init(sceneType: SceneType, fileName: String, name: String, rotation: CGFloat?) {
        self.sceneType = sceneType
        self.fileName = fileName
        self.name = name
        self.rotation = rotation
    }
    
}
