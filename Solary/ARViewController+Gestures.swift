//
//  ARViewController+Gestures.swift
//  Solary
//
//  Created by Gyorgy Borz on 2020. 06. 13..
//  Copyright © 2020. Gyorgy Borz. All rights reserved.
//

import UIKit
import ARKit

extension ARViewController: UIGestureRecognizerDelegate {
    
    @objc
    func didRotate(_ gesture: UIRotationGestureRecognizer) {
        guard let currentNode = rootNode.childNode(withName: nodeData.nodeName, recursively: true) else { return }
        guard gesture.state == .changed else { return }
        
        if currentNode.name == "uranus" {
            currentNode.eulerAngles.z -= Float(gesture.rotation)
        } else {
            currentNode.eulerAngles.y -= Float(gesture.rotation)
        }
        
        gesture.rotation = 0
    }
    
    @objc
    func didPinch(_ gesture: UIPinchGestureRecognizer)
    {
        guard let currentNode = rootNode.childNode(withName: nodeData.nodeName, recursively: true) else { return }
        guard gesture.state == .changed else { return }
        
        let touch = gesture.location(in: sceneView)
        let hitTestResults = self.sceneView.hitTest(touch, options: nil)
        
        if let hitTest = hitTestResults.first, hitTest.node.name == currentNode.name {
            let pinchScaleX = Float(gesture.scale) * currentNode.scale.x
            let pinchScaleY = Float(gesture.scale) * currentNode.scale.y
            let pinchScaleZ = Float(gesture.scale) * currentNode.scale.z
            
            currentNode.scale = SCNVector3(pinchScaleX, pinchScaleY, pinchScaleZ)
            
            gesture.scale = 1
        }
    }
    
    @objc
    func didPan(_ gesture: UIPanGestureRecognizer)
    {
        guard let currentNode = rootNode.childNode(withName: nodeData.nodeName, recursively: true) else { return }
        guard gesture.state == .changed else { return }
        
        let touch = gesture.location(in: sceneView)
        let translation = gesture.translation(in: sceneView)
        let hitTestResults = self.sceneView.hitTest(touch, options: nil)
        
        if let hitTest = hitTestResults.first, hitTest.node.name == currentNode.name {
            currentNode.position.y -= Float(translation.y / 350)
            gesture.setTranslation(.zero, in: sceneView)
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }
    
}

