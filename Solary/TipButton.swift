//
//  TipButton.swift
//  Solary
//
//  Created by Gyorgy Borz on 2022. 12. 03..
//  Copyright © 2022. Gyorgy Borz. All rights reserved.
//

import SnapKit
import UIKit

class TipButtonView: TouchView {
    var isAnimating: Bool = false {
        didSet {
            if isAnimating {
                activityIndicator.startAnimating()
                isUserInteractionEnabled = false
            } else {
                activityIndicator.stopAnimating()
                isUserInteractionEnabled = true
            }
        }
    }

    private let activityIndicator = UIActivityIndicatorView(style: .medium)
    private let label = UILabel()
    init(title: String, color: UIColor) {
        super.init(frame: .zero)
        layer.borderWidth = 1
        layer.borderColor = color.cgColor

        label.font = .systemFont(ofSize: 16)
        label.text = title
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        label.textColor = color
        label.textAlignment = .center
        activityIndicator.color = .cyan
        addSubview(label)
        addSubview(activityIndicator)
        label.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(12)
            make.top.bottom.equalToSuperview().inset(8)
        }
        activityIndicator.snp.makeConstraints { make in
            make.height.equalToSuperview()
            make.trailing.equalTo(label.snp.leading).offset(-16)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.height / 2
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

