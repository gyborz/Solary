//
//  TipJarView.swift
//  Solary
//
//  Created by Gyorgy Borz on 2022. 12. 03..
//  Copyright © 2022. Gyorgy Borz. All rights reserved.
//

import SnapKit
import UIKit

class TipJarView: UIView {
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.layer.cornerRadius = 12
        view.clipsToBounds = true
        return view
    }()

    private let blurView = CustomIntensityVisualEffectView(effect: UIBlurEffect(style: .light), intensity: 0.3)

    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        titleLabel.text = "If you like this app and would like to show your appreciation you can send some love with this tip jar."
        return titleLabel
    }()

    lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.spacing = 20
        stackView.alignment = .center
        return stackView
    }()

    lazy var noThanksButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = .systemFont(ofSize: 17)
        button.setTitle("No thanks", for: .normal)
        button.setTitleColor(UIColor.white.withAlphaComponent(0.5), for: .normal)
        return button
    }()

    init() {
        super.init(frame: .zero)
        setupLayout()
    }

    private func setupLayout() {
        backgroundColor = .clear
        addSubview(containerView)
        containerView.addSubview(blurView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(stackView)
        containerView.addSubview(noThanksButton)

        blurView.layer.cornerRadius = 12
        blurView.clipsToBounds = true

        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(300)
            make.height.greaterThanOrEqualTo(250)
        }

        blurView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(24)
            make.leading.trailing.equalToSuperview().inset(24)
        }

        stackView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview()
        }

        noThanksButton.snp.makeConstraints { make in
            make.top.equalTo(stackView.snp.bottom).offset(24)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(20)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

