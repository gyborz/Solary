//
//  ARViewController.swift
//  Solary
//
//  Created by Gyorgy Borz on 2020. 06. 07..
//  Copyright © 2020. Gyorgy Borz. All rights reserved.
//

import ARKit
import SceneKit
import UIKit

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
    var actions = [String: [String: SCNAction]]()

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

    /// showing / hiding tip
    private var isTipVisible: Bool = false {
        didSet {
            infoImageView.image = UIImage(systemName: isTipVisible ? "info.circle.fill" : "info.circle")
            animateTipView(isVisible: isTipVisible)
        }
    }

    // MARK: - IBOutlets

    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet var blurViews: [UIView]!
    @IBOutlet var galaxyButton: UIButton!
    @IBOutlet var actionButton: UIButton!
    @IBOutlet var guideLabel: UILabel!
    @IBOutlet var infoView: TouchView!
    @IBOutlet var infoImageView: UIImageView!
    @IBOutlet var tipView: UIView!
    @IBOutlet var tipPointerView: UIView!

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

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            if self.currentSceneState == .pointer {
                self.animateGuideLabel(isVisible: true)
            }
        }
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

        tipPointerView.transform = CGAffineTransform(rotationAngle: .pi / 4)
        tipView.layer.cornerRadius = 8
        tipView.layer.masksToBounds = true
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        center = view.center
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let location = touches.first?.location(in: self.view) {
            if infoView.frame.contains(location) {
                isTipVisible.toggle()
            } else if tipView.frame.contains(location), isTipVisible {
                isTipVisible = false
            } else {
                if currentSceneState == .pointer {
                    guard let camera = sceneView.session.currentFrame?.camera else { return }
                    let node = getNode(with: nodeData)
                    node.position = pointer.position
                    node.position.y = camera.transform.columns.3.y
                    currentSceneState = .planet
                    rootNode.addChildNode(node)
                    pointer.removeFromParentNode()

                    animateGuideLabel(isVisible: false)
                }
            }
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
        actions = [String: [String: SCNAction]]()

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
        node.enumerateHierarchy { nodeMember, _ in
            guard let nodeName = nodeMember.name else { return }
            if !nodeMember.actionKeys.isEmpty {
                var actionsForThisNode = [String: SCNAction]()
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

        isTipVisible = false
    }

    @IBAction func actionButtonTapped(_ sender: UIButton) {
        guard let currentNode = rootNode.childNode(withName: nodeData.nodeName, recursively: true) else { return }
        var anyNodeHasActions = false

        // check if any node has any kind of action
        currentNode.enumerateHierarchy { nodeMember, stop in
            if !nodeMember.actionKeys.isEmpty {
                anyNodeHasActions = true
                stop.initialize(to: true)
            }
        }

        // run or remove actions
        if !anyNodeHasActions {
            currentNode.enumerateHierarchy { nodeMember, _ in
                guard let nodeName = nodeMember.name else { return }
                if let actionsForThisNode = actions[nodeName] {
                    for (key, action) in actionsForThisNode {
                        nodeMember.runAction(action, forKey: key)
                    }
                }
            }
            actionButton.setImage(UIImage(systemName: "pause"), for: .normal)
        } else {
            currentNode.enumerateHierarchy { nodeMember, _ in
                nodeMember.removeAllActions()
            }
            actionButton.setImage(UIImage(systemName: "play"), for: .normal)
        }

        isTipVisible = false
    }

    @IBAction func exitButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

    @objc func didTap(_ gesture: UITapGestureRecognizer) {
        isTipVisible.toggle()
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

    // MARK: - Guidance

    func animateGuideLabel(isVisible: Bool) {
        UIView.animate(withDuration: 0.2) {
            self.guideLabel.alpha = isVisible ? 1 : 0
        }
    }

    // MARK: - Tip

    func animateTipView(isVisible: Bool) {
        UIView.animate(withDuration: 0.2) {
            if isVisible {
                self.tipView.alpha = 1
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.tipPointerView.alpha = 1
                }
            } else {
                self.tipPointerView.alpha = 0
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.tipView.alpha = 0
                }
            }
            
        }
    }
}
