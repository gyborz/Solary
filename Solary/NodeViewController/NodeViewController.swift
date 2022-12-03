//
//  NodeViewController.swift
//  Solary
//
//  Created by Gyorgy Borz on 2020. 06. 07..
//  Copyright © 2020. Gyorgy Borz. All rights reserved.
//

import Combine
import SnapKit
import SwiftTipJar
import UIKit

class NodeViewController: UIViewController {
    // MARK: - Properties

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    /// hard coded data for the tableView and ARViewController
    private let nodeData: [NodeData] = [
        NodeData(sceneType: .solarSystem, nodeName: "solarSystem", title: "Solar system"),
        NodeData(sceneType: .planet, nodeName: "sun", title: "Sun"),
        NodeData(sceneType: .planet, nodeName: "mercury", title: "Mercury"),
        NodeData(sceneType: .planet, nodeName: "venus", title: "Venus"),
        NodeData(sceneType: .planet, nodeName: "earthDay", title: "Earth (day)"),
        NodeData(sceneType: .planet, nodeName: "earthNight", title: "Earth (night)"),
        NodeData(sceneType: .planet, nodeName: "moon", title: "Moon"),
        NodeData(sceneType: .planet, nodeName: "mars", title: "Mars"),
        NodeData(sceneType: .planet, nodeName: "jupiter", title: "Jupiter"),
        NodeData(sceneType: .planet, nodeName: "saturn", title: "Saturn"),
        NodeData(sceneType: .planet, nodeName: "uranus", title: "Uranus"),
        NodeData(sceneType: .planet, nodeName: "neptune", title: "Neptune"),
    ]

    // MARK: - IBOutlets, Views, properties

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var headerView: UIView!
    @IBOutlet var sceneTableView: UITableView!

    private let fadeView = UIView()
    private let tipJarView = TipJarView()
    private let tipjarButton = UIButton()
    private var tipJarButtonEnabled: Bool = false {
        didSet {
            tipjarButton.isEnabled = tipJarButtonEnabled
        }
    }

    private var isShowingTipJar: Bool = false {
        didSet {
            animateTipJar(isShowingTipJar: isShowingTipJar)
        }
    }

    private let tipJar = SwiftTipJar(tipsIdentifiers: Set([
        "com.solary.tip",
        "com.solary.bigtip",
        "com.solary.gianttip",
    ]))

    private var disposeBag = Set<AnyCancellable>()

    // MARK: - View Controller Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tipJar.startObservingPaymentQueue()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tipJar.stopObservingPaymentQueue()
    }

    // MARK: - UI Setup

    private func configure() {
        view.backgroundColor = .black

        sceneTableView.delegate = self
        sceneTableView.dataSource = self
        sceneTableView.register(UINib(nibName: "NodeTableViewCell", bundle: nil), forCellReuseIdentifier: "NodeCell")
        sceneTableView.separatorStyle = .none
        sceneTableView.rowHeight = 150
        sceneTableView.backgroundColor = .clear

        tipJar.productsReceivedBlock = fillStackViewWithButtons
        tipJar.transactionFailedBlock = transactionEnded

        tipJar.productsRequest?.start()

        NotificationCenter.default.publisher(for: UIApplication.willTerminateNotification)
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.tipJar.stopObservingPaymentQueue()
            }.store(in: &disposeBag)

        headerView.addSubview(tipjarButton)
        tipjarButton.setImage(UIImage(systemName: "dollarsign.circle")?.withConfiguration(UIImage.SymbolConfiguration(pointSize: 27)), for: .normal)
        tipjarButton.tintColor = .white
        tipjarButton.snp.makeConstraints { make in
            make.size.equalTo(50)
            make.trailing.equalToSuperview().inset(24)
            make.centerY.equalTo(titleLabel.snp.centerY)
        }
        tipjarButton.addTarget(self, action: #selector(tipJarButtonTapped), for: .touchUpInside)

        view.addSubview(fadeView)
        fadeView.backgroundColor = .black
        fadeView.alpha = 0
        fadeView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        let fadeTapGesture = UITapGestureRecognizer(target: self, action: #selector(fadeViewTapped))
        fadeView.addGestureRecognizer(fadeTapGesture)

        view.addSubview(tipJarView)
        tipJarView.transform = CGAffineTransform(translationX: 0, y: UIScreen.main.bounds.height / 2 + 250)
        tipJarView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        tipJarView.noThanksButton.addTarget(self, action: #selector(noThanksButtonTapped), for: .touchUpInside)
    }

    @objc private func tipJarButtonTapped() {
        isShowingTipJar = true
    }

    @objc func tipButtonTapped(_ gesture: UITapGestureRecognizer) {
        guard let tipButton = gesture.view as? TipButtonView, let identifier = tipButton.accessibilityIdentifier else { return }
        tipButton.isAnimating = true
        view.isUserInteractionEnabled = false
        fadeView.isUserInteractionEnabled = false
        tipJarView.isUserInteractionEnabled = false
        tipJarView.noThanksButton.isUserInteractionEnabled = false
        tipJar.initiatePurchase(productIdentifier: identifier)
    }

    @objc private func noThanksButtonTapped() {
        isShowingTipJar = false
    }

    @objc private func fadeViewTapped() {
        isShowingTipJar = false
    }

    private func fillStackViewWithButtons() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.tipJar.tips.enumerated().forEach { idx, tip in
                var color: UIColor = .clear
                if idx == 0 {
                    color = UIColor.white
                } else if idx == 1 {
                    color = UIColor.systemYellow
                } else {
                    color = UIColor.systemOrange
                }
                let button = TipButtonView(title: tip.displayName + " - " + tip.displayPrice, color: color)
                button.accessibilityIdentifier = tip.identifier
                let buttonTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tipButtonTapped(_:)))
                button.addGestureRecognizer(buttonTapGesture)
                self.tipJarView.stackView.addArrangedSubview(button)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.tipJarButtonEnabled = true
            }
        }
    }

    private func animateTipJar(isShowingTipJar: Bool) {
        if isShowingTipJar {
            UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.8, options: [.layoutSubviews]) {
                self.fadeView.alpha = 0.6
                self.tipJarView.transform = .identity
            }
        } else {
            UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.8, options: [.layoutSubviews]) {
                self.fadeView.alpha = 0
                self.tipJarView.transform = CGAffineTransform(translationX: 0, y: UIScreen.main.bounds.height / 2 + 250)
            }
        }
    }

    private func transactionEnded() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.view.isUserInteractionEnabled = true
            self.fadeView.isUserInteractionEnabled = true
            self.tipJarView.isUserInteractionEnabled = true
            self.tipJarView.noThanksButton.isUserInteractionEnabled = true
            self.tipJarView.stackView.arrangedSubviews.forEach { subView in
                if let tipButton = subView as? TipButtonView {
                    tipButton.isAnimating = false
                }
            }
        }
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension NodeViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        nodeData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = sceneTableView.dequeueReusableCell(withIdentifier: "NodeCell", for: indexPath) as! NodeTableViewCell

        cell.nodeLabel.text = nodeData[indexPath.row].title
        cell.nodeImageView.image = UIImage(named: nodeData[indexPath.row].nodeName)

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let chosenNode = nodeData[indexPath.row]
        let destVC = storyboard?.instantiateViewController(withIdentifier: "ARViewController") as! ARViewController
        destVC.nodeData = chosenNode
        destVC.modalPresentationStyle = .fullScreen
        present(destVC, animated: true) { [weak self] in
            self?.sceneTableView.deselectRow(at: indexPath, animated: false)
        }
    }
}
