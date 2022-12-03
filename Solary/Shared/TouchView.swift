//
//  TouchView.swift
//  Solary
//
//  Created by Gyorgy Borz on 2022. 12. 03..
//  Copyright © 2022. Gyorgy Borz. All rights reserved.
//

import UIKit

open class TouchView: UIView {
    var touchAnimEnabled: Bool = true
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        if touchAnimEnabled {
            let transform: CGAffineTransform = .init(scaleX: 0.95, y: 0.95)
            animate(transform)
        }
    }

    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        if touchAnimEnabled {
            let transform: CGAffineTransform = .identity
            animate(transform)
        }
    }

    open override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        if touchAnimEnabled {
            let transform: CGAffineTransform = .identity
            animate(transform)
        }
    }

    private func animate(_ transform: CGAffineTransform) {
        UIView.animate(
            withDuration: 0.4,
            delay: 0,
            usingSpringWithDamping: 0.5,
            initialSpringVelocity: 3,
            options: [.curveEaseInOut],
            animations: {
                self.transform = transform
            }
        )
    }
}
