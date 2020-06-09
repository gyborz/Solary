//
//  ARViewController.swift
//  Solary
//
//  Created by Gyorgy Borz on 2020. 06. 07..
//  Copyright © 2020. Gyorgy Borz. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ARViewController: UIViewController, ARSCNViewDelegate {
    
    var node: Node!
    private var center: CGPoint!
    private var positions = [SCNVector3]()
    private let pointer = SCNScene(named: "art.scnassets/pointer.scn")!.rootNode
    private var rootNode: SCNNode {
        return sceneView.scene.rootNode
    }
    
    private enum SceneState {
        case pointer
        case planet
    }
    private var currentSceneState: SceneState = .pointer
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet var blurViews: [UIView]!
    private let coachingOverlay = ARCoachingOverlayView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.delegate = self
        center = view.center
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupARSession()
        setOverlay(automatically: true, forDetectionType: .tracking)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    private func setupUI() {
        for blurView in blurViews {
            let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.systemUltraThinMaterialDark)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            blurEffectView.frame = blurView.bounds
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            blurView.addSubview(blurEffectView)
            blurView.sendSubviewToBack(blurEffectView)
            blurView.layer.masksToBounds = true
            if blurView.tag == 1 {
                blurView.layer.cornerRadius = blurView.frame.height / 2
            } else {
                blurView.layer.cornerRadius = 10
            }
        }
    }
    
    private func setupARSession() {
        let configuration = ARWorldTrackingConfiguration()
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        rootNode.addChildNode(pointer)
    }
    
    private func setOverlay(automatically: Bool, forDetectionType goal: ARCoachingOverlayView.Goal) {
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
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        center = view.center
    }
    
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

    // MARK: - ARSCNViewDelegate
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    func sessionShouldAttemptRelocalization(_ session: ARSession) -> Bool {
        true
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        let hitTest = sceneView.hitTest(center, types: .featurePoint)
        let result = hitTest.last
        guard let transform = result?.worldTransform else { return }
        let thirdColumn = transform.columns.3
        let position = SCNVector3Make(thirdColumn.x, thirdColumn.y, thirdColumn.z)
        positions.append(position)
        let lastTenPositions = positions.suffix(10)
        pointer.position = getAveragePosition(from: lastTenPositions)
    }
    
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        switch camera.trackingState {
        case .notAvailable, .limited:
            // MARK: - TODO
            print("not normal")
            if currentSceneState == .pointer {
                pointer.removeFromParentNode()
            }
        case .normal:
            // MARK: - TODO
            print("normal")
            if currentSceneState == .pointer {
                rootNode.addChildNode(pointer)
            }
        }
    }
    
    @IBAction func exitButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
}

extension ARViewController: ARCoachingOverlayViewDelegate {
    
    func coachingOverlayViewWillActivate(_ coachingOverlayView: ARCoachingOverlayView) {
        blurViews.forEach { $0.isHidden = $0.tag != 1 ? true : false }
    }
    
    func coachingOverlayViewDidDeactivate(_ coachingOverlayView: ARCoachingOverlayView) {
        blurViews.forEach { $0.isHidden = false }
    }
    
    func coachingOverlayViewDidRequestSessionReset(_ coachingOverlayView: ARCoachingOverlayView) {
        setupARSession()
    }
    
}
