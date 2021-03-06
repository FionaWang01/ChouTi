//
//  UIButton+Extensions.swift
//  Pods
//
//  Created by Honghao Zhang on 2015-11-12.
//
//

import UIKit

public extension UIButton {
    
    /**
     Sets the background image color to use for the specified state.
     
     - parameter color: The background image color to use for the specified state.
     - parameter state: The state that uses the specified background image color. The possible values are described in UIControlState.
     */
    public func setBackgroundImageWithColor(color: UIColor, forState state: UIControlState) {
        self.setBackgroundImage(UIImage.imageWithColor(color), forState: state)
    }
}
