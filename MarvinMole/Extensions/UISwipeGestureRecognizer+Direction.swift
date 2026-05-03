//
//  UISwipeGestureRecognizer+Direction.swift
//  MarvinMole
//
//  (c) Morten Perriard 2026
//

import UIKit

extension UISwipeGestureRecognizer {

    convenience init(target: Any?,
                     action: Selector?,
                     direction: UISwipeGestureRecognizer.Direction) {
        self.init(target: target, action: action)
        self.direction = direction
    }
}
