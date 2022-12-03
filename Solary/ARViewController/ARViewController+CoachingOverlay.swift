//
//  ARViewController+CoachingOverlay.swift
//  Solary
//
//  Created by Gyorgy Borz on 2020. 06. 14..
//  Copyright © 2020. Gyorgy Borz. All rights reserved.
//

import UIKit
import ARKit

extension ARViewController: ARCoachingOverlayViewDelegate {
    
    func coachingOverlayViewWillActivate(_ coachingOverlayView: ARCoachingOverlayView) {
        hideControls(true)
    }
    
    func coachingOverlayViewDidDeactivate(_ coachingOverlayView: ARCoachingOverlayView) {
        hideControls(false)
    }
    
    func coachingOverlayViewDidRequestSessionReset(_ coachingOverlayView: ARCoachingOverlayView) {
        rootNode.childNodes.forEach {
            if $0.name == nodeData.nodeName || $0.name == galaxy.name || $0.name == pointer.name {
                $0.removeFromParentNode()
            }
        }
        galaxyButton.setImage(UIImage(named: "galaxy"), for: .normal)
        actionButton.setImage(UIImage(systemName: "play"), for: .normal)
        setupARSession()
    }
    
    func setOverlay(automatically: Bool, forDetectionType goal: ARCoachingOverlayView.Goal) {
        // set up coaching view
        coachingOverlay.session = self.sceneView.session
        coachingOverlay.delegate = self
        sceneView.addSubview(self.coachingOverlay)
        
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item:  coachingOverlay, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item:  coachingOverlay, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1, constant: 0),
            NSLayoutConstraint(item:  coachingOverlay, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item:  coachingOverlay, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1, constant: 0)
        ])
        
        coachingOverlay.translatesAutoresizingMaskIntoConstraints = false
        
        self.coachingOverlay.activatesAutomatically = automatically
        
        self.coachingOverlay.goal = goal
    }
    
}
