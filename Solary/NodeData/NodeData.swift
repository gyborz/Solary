//
//  NodeData.swift
//  Solary
//
//  Created by Gyorgy Borz on 2020. 06. 07..
//  Copyright © 2020. Gyorgy Borz. All rights reserved.
//

import UIKit

struct NodeData {
    
    /// which scene contains the node
    var sceneType: SceneType
    
    /// node's name
    var nodeName: String
    
    /// title
    var title: String
    
    init(sceneType: SceneType, nodeName: String, title: String) {
        self.sceneType = sceneType
        self.nodeName = nodeName
        self.title = title
    }
    
}
