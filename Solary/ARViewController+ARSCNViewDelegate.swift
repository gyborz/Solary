//
//  ARViewController+ARSCNViewDelegate.swift
//  Solary
//
//  Created by Gyorgy Borz on 2020. 06. 14..
//  Copyright © 2020. Gyorgy Borz. All rights reserved.
//

import UIKit
import ARKit

extension ARViewController: ARSCNViewDelegate {
    
    // MARK: - ARSCNViewDelegate
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        guard error is ARError else { return }
        
        let errorWithInfo = error as NSError
        let messages = [
            errorWithInfo.localizedDescription,
            errorWithInfo.localizedFailureReason,
            errorWithInfo.localizedRecoverySuggestion
        ]
        
        let errorMessage = messages.compactMap({ $0 }).joined(separator: "\n")
        
        DispatchQueue.main.async {
            self.displayErrorMessage(title: "The AR session failed.", message: errorMessage)
        }
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Hide control buttons
        hideControls(true)
    }
    
    func sessionShouldAttemptRelocalization(_ session: ARSession) -> Bool {
        true
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        // Position the pointer
        if currentSceneState == .pointer {
            let hitTest = sceneView.hitTest(center, types: .featurePoint)
            let result = hitTest.last
            guard let transform = result?.worldTransform else { return }
            let thirdColumn = transform.columns.3
            let position = SCNVector3Make(thirdColumn.x, thirdColumn.y, thirdColumn.z)
            positions.append(position)
            let lastTenPositions = positions.suffix(10)
            pointer.position = getAveragePosition(from: lastTenPositions)
        }
    }
    
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        switch camera.trackingState {
        case .notAvailable, .limited:
            rootNode.childNodes.forEach { $0.isHidden = true }
        case .normal:
            rootNode.childNodes.forEach { $0.isHidden = false }
        }
    }
    
    // MARK: - Supporting Methods
    
    private func getAveragePosition(from positions: Array<SCNVector3>.SubSequence) -> SCNVector3 {
        var averageX: Float = 0
        var averageY: Float = 0
        var averageZ: Float = 0
        for position in positions {
            averageX += position.x
            averageY += position.y
            averageZ += position.z
        }
        let count = Float(positions.count)
        return SCNVector3Make(averageX / count, averageY / count, averageZ / count)
    }
    
}
