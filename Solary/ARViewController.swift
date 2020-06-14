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

class ARViewController: UIViewController {
    
    // MARK: - Properties
    
    /// chosen nodeData
    var nodeData: NodeData!
    
    /// center of the view
    var center: CGPoint!
    
    /// array for calculating pointer's position
    var positions = [SCNVector3]()
    
    /// pointer node for positioning the chosen node
    var pointer: SCNNode!
    
    /// galaxy node
    var galaxy: SCNNode!
    
    /// dictionary for containing all the visible node's actions
    var actions = [String:[String:SCNAction]]()
    
    /// root node of the sceneView's scene
    var rootNode: SCNNode {
        return sceneView.scene.rootNode
    }
    
    /// state to tell if the scene shows the pointer or a planet (or solar system), always starts with pointer
    enum SceneState {
        case pointer
        case planet
    }
    var currentSceneState: SceneState = .pointer
    
    /// hide status bar
    override var prefersStatusBarHidden: Bool {
        return true
    }

    // MARK: - IBOutlets
    
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet var blurViews: [UIView]!
    @IBOutlet weak var galaxyButton: UIButton!
    @IBOutlet weak var actionButton: UIButton!
    
    // MARK: - UI Elements
    
    let coachingOverlay = ARCoachingOverlayView()
    
    // MARK: - View Controller Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.delegate = self
        center = view.center
        
        // set up the UI for interaction
        setupUI()
        
        // add gesture recognizers to the view
        createGestureRecognizers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // set up the session
        setupARSession()
        
        // set up coaching overlay
        setOverlay(automatically: true, forDetectionType: .tracking)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
        
        // enable idle timer
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    // MARK: - UI Handling
    
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
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        center = view.center
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if currentSceneState == .pointer {
            guard let camera = sceneView.session.currentFrame?.camera else { return }
            let node = getNode(with: nodeData)
            node.position = pointer.position
            node.position.y = camera.transform.columns.3.y
            currentSceneState = .planet
            rootNode.addChildNode(node)
            pointer.removeFromParentNode()
        }
    }
    
    func hideControls(_ hide: Bool) {
        // hide every button except the exit button
        if hide {
            for blurView in blurViews {
                if blurView.tag != 1 {
                    UIView.animate(withDuration: 0.3) {
                        blurView.alpha = 0
                    }
                }
            }
        } else {
            for blurView in blurViews {
                UIView.animate(withDuration: 0.3) {
                    blurView.alpha = 1.0
                }
            }
        }
    }
    
    // MARK: - Session management
    
    func setupARSession() {
        // disable idle timer
        UIApplication.shared.isIdleTimerDisabled = true
        
        // set up and run configuration
        let configuration = ARWorldTrackingConfiguration()
        if ARWorldTrackingConfiguration.supportsFrameSemantics(.personSegmentationWithDepth) {
            configuration.frameSemantics.insert(.personSegmentationWithDepth)
        }
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        
        // set pointer, galaxy and actions
        pointer = SCNScene(named: "art.scnassets/pointer.scn")!.rootNode.childNode(withName: "pointer", recursively: true)
        galaxy = SCNScene(named: "art.scnassets/galaxy.scn")!.rootNode.childNode(withName: "galaxy", recursively: true)
        actions = [String:[String:SCNAction]]()
        
        // add pointer to root node, set scene state
        rootNode.addChildNode(pointer)
        currentSceneState = .pointer
    }
    
    // MARK: - Gesture Setup
    
    private func createGestureRecognizers() {
        // rotation gesture
        let rotationGesture = UIRotationGestureRecognizer(target: self, action: #selector(didRotate(_:)))
        rotationGesture.delegate = self
        sceneView.addGestureRecognizer(rotationGesture)
        
        // pinch gesture
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(didPinch(_:)))
        pinchGesture.delegate = self
        sceneView.addGestureRecognizer(pinchGesture)
        
        // pan gesture
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(didPan(_:)))
        panGesture.delegate = self
        sceneView.addGestureRecognizer(panGesture)
    }
    
    // MARK: - Supporting Methods
    
    private func getNode(with nodeData: NodeData) -> SCNNode {
        guard let node = SCNScene(named: "art.scnassets/\(nodeData.sceneType.rawValue).scn")!.rootNode.childNode(withName: nodeData.nodeName, recursively: true) else { fatalError("Missing node") }
        
        // save all the node's and it's childnodes' actions
        node.enumerateHierarchy { (nodeMember, _) in
            guard let nodeName = nodeMember.name else { return }
            if !nodeMember.actionKeys.isEmpty {
                var actionsForThisNode = [String:SCNAction]()
                nodeMember.actionKeys.forEach {
                    actionsForThisNode[$0] = nodeMember.action(forKey: $0)
                }
                actions[nodeName] = actionsForThisNode
                nodeMember.removeAllActions()
            }
        }
        return node
    }
    
    // MARK: - Interface Actions
    
    @IBAction func galaxyButtonTapped(_ sender: UIButton) {
        if rootNode.childNodes.contains(galaxy) {
            galaxy.removeFromParentNode()
            galaxyButton.setImage(UIImage(named: "galaxy"), for: .normal)
        } else {
            rootNode.addChildNode(galaxy)
            galaxyButton.setImage(UIImage(named: "galaxy.fill"), for: .normal)
        }
    }
    
    @IBAction func actionButtonTapped(_ sender: UIButton) {
        guard let currentNode = rootNode.childNode(withName: nodeData.nodeName, recursively: true) else { return }
        var anyNodeHasActions = false
        
        // check if any node has any kind of action
        currentNode.enumerateHierarchy { (nodeMember, stop) in
            if !nodeMember.actionKeys.isEmpty {
                anyNodeHasActions = true
                stop.initialize(to: true)
            }
        }
        
        // run or remove actions
        if !anyNodeHasActions {
            currentNode.enumerateHierarchy { (nodeMember, _) in
                guard let nodeName = nodeMember.name else { return }
                if let actionsForThisNode = actions[nodeName] {
                    for (key, action) in actionsForThisNode {
                        nodeMember.runAction(action, forKey: key)
                    }
                }
            }
            actionButton.setImage(UIImage(systemName: "pause"), for: .normal)
        } else {
            currentNode.enumerateHierarchy { (nodeMember, _) in
                nodeMember.removeAllActions()
            }
            actionButton.setImage(UIImage(systemName: "play"), for: .normal)
        }
    }
    
    @IBAction func exitButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Error handling
    
    func displayErrorMessage(title: String, message: String) {
        // Present an alert informing about the error that has occurred.
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "OK", style: .default) { _ in
            alertController.dismiss(animated: true) { [weak self] in
                self?.dismiss(animated: true, completion: nil)
            }
        }
        alertController.addAction(dismissAction)
        present(alertController, animated: true, completion: nil)
    }
    
}
