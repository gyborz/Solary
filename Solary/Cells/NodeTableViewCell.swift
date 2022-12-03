//
//  NodeTableViewCell.swift
//  Solary
//
//  Created by Gyorgy Borz on 2020. 06. 07..
//  Copyright © 2020. Gyorgy Borz. All rights reserved.
//

import UIKit

class NodeTableViewCell: UITableViewCell {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var containerView: TouchView!
    @IBOutlet weak var nodeLabel: UILabel!
    @IBOutlet weak var nodeImageView: UIImageView!
    
    // MARK: - View Handling

    override func awakeFromNib() {
        super.awakeFromNib()
        containerView.layer.cornerRadius = 20
        containerView.layer.masksToBounds = true
        selectionStyle = .default
        selectedBackgroundView = UIView()
        selectedBackgroundView?.backgroundColor = .clear
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        setGradientBackground()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if isSelected {
            containerView.alpha = 0.8
        } else {
            containerView.alpha = 1
        }
    }
    
    // MARK: - Gradient Method
    
    private func setGradientBackground() {
        let colorTop = #colorLiteral(red: 0.04841813788, green: 0.04889752538, blue: 0.04889752538, alpha: 1).cgColor
        let colorBottom = #colorLiteral(red: 0.1127911037, green: 0.317065338, blue: 0.4521781481, alpha: 1).cgColor

        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [colorTop, colorBottom]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.frame = self.containerView.bounds

        self.containerView.layer.insertSublayer(gradientLayer, at: 0)
    }
    
}
