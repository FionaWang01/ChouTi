//
//  Button.swift
//  Pods
//
//  Created by Honghao Zhang on 2016-05-06.
//
//

import UIKit

/// Button With Extra Presentation Styles
/// You can set borderColor, borderWidth, cornerRadius and backgroundColor for different states
public class Button: UIButton {
    
    /**
     Corner radius attribute, used in CornerRadius .Relative case
     
     - Width:  Width
     - Height: Height
     */
    public enum Attribute {
        case Width
        case Height
    }
    
    /**
     Corner radius option
     
     - Absolute:   absolute corner radius
     - Relative:   relative corner radius, calculated by percetage multiply by width or height
     - HalfCircle: half-circle, capsule like
     */
    public enum CornerRadius {
        case Absolute(CGFloat)
        case Relative(percent: CGFloat, attribute: Attribute)
        case HalfCircle
        
        public func cornerRadiusValue(forView view: UIView) -> CGFloat {
            switch self {
            case .Absolute(let cornerRadius):
                return cornerRadius
                
            case .Relative(percent: let percent, attribute: let attribute):
                switch attribute {
                case .Width:
                    return percent * view.bounds.width
                case .Height:
                    return percent * view.bounds.height
                }
                
            case .HalfCircle:
                return 0.5 * min(view.bounds.width, view.bounds.height)
            }
        }
    }
    
    // MARK: - Storing Extra Presentation Styles
    private var borderColorForState = [UInt : UIColor]()
    private var borderWidthForState = [UInt : CGFloat]()
    private var cornerRadiusForState = [UInt : CornerRadius]()
    private var backgroundImageColorForState = [UInt : UIColor]()
    
    // MARK: - Overriden
    public override var highlighted: Bool { didSet { refreshBorderStyles() } }
    public override var enabled: Bool { didSet { refreshBorderStyles() } }
    public override var selected: Bool { didSet { refreshBorderStyles() } }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        refreshBorderStyles()
    }
}

// MARK: - Configuring Button Presentation
extension Button {
    // MARK: - Setting Extra Presentation Styles
    
    /**
     Set the border color to use for the specified state.
     
     - parameter color: The border color to use for the specified state.
     - parameter state: The state that uses the specified border color. The possible values are described in UIControlState.
     */
    public func setBorderColor(color: UIColor?, forState state: UIControlState) {
        if borderColorForState[state.rawValue] <-? color { refreshBorderStyles() }
    }
    
    /**
     Set the border width to use for the specified state.
     
     - parameter width: The border width to use for the specified state.
     - parameter state: The state that uses the specified border width. The possible values are described in UIControlState.
     */
    public func setBorderWidth(width: CGFloat?, forState state: UIControlState) {
        if borderWidthForState[state.rawValue] <-? width { refreshBorderStyles() }
    }
    
    /**
     Set the corner radius to use for the specified state. `clipsToBounds` is set to true.
     
     - parameter cornerRadius: The corner radius to use for the specified state.
     - parameter state:        The state that uses the specified corner radius. The possible values are described in UIControlState.
     */
    public func setCornerRadius(cornerRadius: CornerRadius?, forState state: UIControlState) {
        clipsToBounds = true
        if cornerRadiusForState[state.rawValue] <-? cornerRadius { refreshBorderStyles() }
    }
    
    /**
     Set the background image with color to use for the specified state.
     
     - parameter color: The color for background image to use for the specified state.
     - parameter state: The state that uses the specified background image color. The possible values are described in UIControlState.
     */
    public override func setBackgroundImageWithColor(color: UIColor?, forState state: UIControlState) {
        if backgroundImageColorForState[state.rawValue] <-? color {
            if let color = color {
                setBackgroundImage(UIImage.imageWithColor(color), forState: state)
            } else {
                setBackgroundImage(nil, forState: state)
            }
        }
    }
    
    // MARK: - Getting Extra Presentation Styles
    
    /**
     Returns the border color associated with the specified state.
     
     - parameter state: The state that uses the border color. The possible values are described in UIControlState.
     
     - returns: The border color for the specified state. If no border color has been set for the specific state, this method returns the border color associated with the UIControlStateNormal state. If no border color has been set for the UIControlStateNormal state, nil is returned.
     */
    public func borderColorForState(state: UIControlState) -> UIColor? {
        return borderColorForState[state.rawValue] ?? borderColorForState[UIControlState.Normal.rawValue]
    }
    
    /**
     Returns the border width used for a state.
     
     - parameter state: The state that uses the border width. The possible values are described in UIControlState.
     
     - returns: The border width for the specified state. If there's no border width is set for the state, border width for normal state is returned, otherwise, nil is returned.
     */
    public func borderWidthForState(state: UIControlState) -> CGFloat? {
        return borderWidthForState[state.rawValue] ?? borderWidthForState[UIControlState.Normal.rawValue]
    }
    
    /**
     Returns the corner radius used for a state.
     
     - parameter state: The state that uses the corner radius. The possible values are described in UIControlState.
     
     - returns: The corner radius for the specified state. If there's no corner radius is set for the state, corner radius for normal state is returned, otherwise, nil is returned.
     */
    public func cornerRadiusForState(state: UIControlState) -> CornerRadius? {
        return cornerRadiusForState[state.rawValue] ?? cornerRadiusForState[UIControlState.Normal.rawValue]
    }
    
    /**
     Returns the background image color associated with the specified state.
     
     - parameter state: The state that uses the background image color. The possible values are described in UIControlState.
     
     - returns: The background image color for the specified state. If no background image color has been set for the specific state, this method returns the background image color associated with the UIControlStateNormal state. If no background image color has been set for the UIControlStateNormal state, nil is returned.
     */
    public func backgroundImageColorForState(state: UIControlState) -> UIColor? {
        return backgroundImageColorForState[state.rawValue] ?? backgroundImageColorForState[UIControlState.Normal.rawValue]
    }
}

// MARK: - Getting the Current State
extension Button {
    /// The current border color that is displayed on the button. (read-only)
    public var currentBorderColor: UIColor? { return (layer.borderColor != nil) ? UIColor(CGColor: layer.borderColor!) : nil }
    
    /// The current border width that is displayed on the button. (read-only)
    public var currentBorderWidth: CGFloat { return layer.borderWidth }
    
    /// The current corner radius that is displayed on the button. (read-only)
    public var currentCornerRadius: CornerRadius {
        return cornerRadiusForState[state.rawValue] ?? cornerRadiusForState[UIControlState.Normal.rawValue] ?? .Absolute(layer.cornerRadius)
    }
    
    /// The current background image color that is displayed on the button. (read-only)
    public var currentBackgroundImageColor: UIColor? {
        return backgroundImageColorForState[state.rawValue] ?? backgroundImageColorForState[UIControlState.Normal.rawValue]
    }
}

// MARK: - Private Helpers
extension Button {
    
    // MARK: - Convenient Values
    private var normalBorderColor: UIColor? { return borderColorForState[UIControlState.Normal.rawValue] }
    private var highlightedBorderColor: UIColor? { return borderColorForState[UIControlState.Highlighted.rawValue] }
    private var disabledBorderColor: UIColor? { return borderColorForState[UIControlState.Disabled.rawValue] }
    private var selectedBorderColor: UIColor? { return borderColorForState[UIControlState.Selected.rawValue] }
    
    private var normalBorderWidth: CGFloat? { return borderWidthForState[UIControlState.Normal.rawValue] }
    private var highlightedBorderWidth: CGFloat? { return borderWidthForState[UIControlState.Highlighted.rawValue] }
    private var disabledBorderWidth: CGFloat? { return borderWidthForState[UIControlState.Disabled.rawValue] }
    private var selectedBorderWidth: CGFloat? { return borderWidthForState[UIControlState.Selected.rawValue] }
    
    private var normalCornerRadius: CGFloat? { return cornerRadiusForState[UIControlState.Normal.rawValue]?.cornerRadiusValue(forView: self) }
    private var highlightedCornerRadius: CGFloat? { return cornerRadiusForState[UIControlState.Highlighted.rawValue]?.cornerRadiusValue(forView: self) }
    private var disabledCornerRadius: CGFloat? { return cornerRadiusForState[UIControlState.Disabled.rawValue]?.cornerRadiusValue(forView: self) }
    private var selectedCornerRadius: CGFloat? { return cornerRadiusForState[UIControlState.Selected.rawValue]?.cornerRadiusValue(forView: self) }
    
    /**
     Refresh customized styles
     */
    private func refreshBorderStyles() {
        // add a fade transition.
        let transition = CATransition()
        transition.type = kCATransitionFade
        transition.duration = 0.075
        
        defer {
            layer.addAnimation(transition, forKey: kCATransition)
        }
        
        if state == .Highlighted {
            layer.borderColor =? highlightedBorderColor?.CGColor ?? normalBorderColor?.CGColor
            layer.borderWidth =? highlightedBorderWidth ?? normalBorderWidth
            layer.cornerRadius =? highlightedCornerRadius ?? normalCornerRadius
        } else if state == .Disabled {
            layer.borderColor =? disabledBorderColor?.CGColor ?? normalBorderColor?.CGColor
            layer.borderWidth =? disabledBorderWidth ?? normalBorderWidth
            layer.cornerRadius =? disabledCornerRadius ?? normalCornerRadius
        } else if state == .Selected {
            layer.borderColor =? selectedBorderColor?.CGColor ?? normalBorderColor?.CGColor
            layer.borderWidth =? selectedBorderWidth ?? normalBorderWidth
            layer.cornerRadius =? selectedCornerRadius ?? normalCornerRadius
        } else {
            // prolong the fade transition, this mimics UIButtonType.System behaviors
            transition.duration = 0.25
            
            // Defaults to .Normal state
            layer.borderColor =? normalBorderColor?.CGColor
            layer.borderWidth =? normalBorderWidth
            layer.cornerRadius =? normalCornerRadius
        }
    }
	
	// TODO: Transparent title color
	// Reference: https://github.com/purrrminator/AKStencilButton/blob/master/AKStencilButton.m
	// http://stackoverflow.com/questions/27458101/transparent-uibutton-title
	// http://stackoverflow.com/questions/23515100/ios-uibutton-with-transparent-title-on-white-background
//    private func refreshClearTitleMask() {
////        titleLabel?.backgroundColor = UIColor.clearColor()
//        let text = titleLabel?.text
//        let font = titleLabel?.font
//        
//        let attributes = [NSFontAttributeName : titleLabel?.font]
//        let textSize = text.
//    }
}

// MARK: - Button.CornerRadius : Equatable
extension Button.CornerRadius : Equatable {}
public func == (lhs: Button.CornerRadius, rhs: Button.CornerRadius) -> Bool {
    switch (lhs, rhs) {
    case (.Absolute(let lValue), .Absolute(let rValue)):
        return lValue == rValue
    case (.Relative(let lPercent, let lAttribute), .Relative(let rPercent, let rAttribute)):
        return (lPercent == rPercent) && (lAttribute == rAttribute)
    case (.HalfCircle, .HalfCircle):
        return true
    default:
        return false
    }
}

// MARK: <-? Non-equal Assignment Operator
infix operator <-? { associativity right precedence 90 }

/**
 Nonequal Assignment Operator
 If lhs and rhs are equal, no assignment
 
 - parameter lhs: a variable of type T: Equatable
 - parameter rhs: a variable of type T: Equatable
 
 - returns: ture if lhs is assigned, false otherwise
 */
private func <-? <T: Equatable>(inout lhs: T?, rhs: T?) -> Bool {
    if lhs == rhs { return false }
    lhs = rhs
    return true
}
