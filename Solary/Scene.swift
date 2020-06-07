//
//  Scene.swift
//  Solary
//
//  Created by Gyorgy Borz on 2020. 06. 07..
//  Copyright © 2020. Gyorgy Borz. All rights reserved.
//

import UIKit

struct Scene {
    
    var sceneType: SceneType
    var name: String
    var rotation: CGFloat?
    
    init(sceneType: SceneType, name: String, rotation: CGFloat?) {
        self.sceneType = sceneType
        self.name = name
        self.rotation = rotation
    }
    
}
