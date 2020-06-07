//
//  SceneTableViewCell.swift
//  Solary
//
//  Created by Gyorgy Borz on 2020. 06. 07..
//  Copyright © 2020. Gyorgy Borz. All rights reserved.
//

import UIKit

class SceneTableViewCell: UITableViewCell {
    
    @IBOutlet weak var sceneLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}
