//
//  UniButtonView.swift
//  UniLayout Pod
//
//  Library view: a simple button
//  Extends UIButton to support properties for UniLayout containers and more control over padding
//

import UIKit

open class UniButtonView: UIButton, UniLayoutView, UniLayoutPaddedView {

    // ---
    // MARK: Members
    // ---

    public var layoutProperties = UniLayoutProperties()
    private var backgroundColorNormalState: UIColor?
    private var backgroundColorHighlightedState: UIColor?
    private var backgroundColorDisabledState: UIColor?
    private var borderColorNormalState: UIColor?
    private var borderColorHighlightedState: UIColor?
    private var borderColorDisabledState: UIColor?

    
    // ---
    // MARK: Change padding
    // ---
    
    public var padding: UIEdgeInsets {
        get { return contentEdgeInsets }
        set {
            contentEdgeInsets = newValue
            if contentEdgeInsets.top == 0 {
                contentEdgeInsets.top = 0.01
            }
            if contentEdgeInsets.bottom == 0 {
                contentEdgeInsets.bottom = 0.01
            }
        }
    }

    
    // ---
    // MARK: Initialization
    // ---

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        padding = UIEdgeInsetsMake(0, 0, 0, 0)
    }
    
    
    // ---
    // MARK: Add more state support
    // ---
    
    open override var isHighlighted: Bool {
        didSet {
            refreshStateBackground()
            refreshStateBorder()
        }
    }
    
    open override var isEnabled: Bool {
        didSet {
            refreshStateBackground()
            refreshStateBorder()
        }
    }
    
    open override var backgroundColor: UIColor? {
        get { return backgroundColorNormalState }
        set { setBackgroundColor(newValue, for: .normal) }
    }

    public func setBackgroundColor(_ color: UIColor?, for state: UIControlState) {
        let currentState = !isEnabled ? UIControlState.disabled : (isHighlighted ? UIControlState.highlighted : UIControlState.normal)
        if state == .normal {
            backgroundColorNormalState = color
        } else if state == .highlighted {
            backgroundColorHighlightedState = color
        } else if state == .disabled {
            backgroundColorDisabledState = color
        }
        if state == .normal || state == currentState {
            refreshStateBackground()
        }
    }
    
    public func setBorderColor(_ color: UIColor?, for state: UIControlState) {
        let currentState = !isEnabled ? UIControlState.disabled : (isHighlighted ? UIControlState.highlighted : UIControlState.normal)
        if state == .normal {
            borderColorNormalState = color
        } else if state == .highlighted {
            borderColorHighlightedState = color
        } else if state == .disabled {
            borderColorDisabledState = color
        }
        if state == .normal || state == currentState {
            refreshStateBorder()
        }
    }

    private func refreshStateBackground() {
        var backgroundWasSet = false
        if !isEnabled && backgroundColorDisabledState != nil {
            super.backgroundColor = backgroundColorDisabledState
            backgroundWasSet = true
        }
        if isEnabled && isHighlighted && backgroundColorHighlightedState != nil {
            super.backgroundColor = backgroundColorHighlightedState
            backgroundWasSet = true
        }
        if !backgroundWasSet {
            super.backgroundColor = backgroundColorNormalState
        }
    }

    private func refreshStateBorder() {
        var borderWasSet = false
        if !isEnabled && borderColorDisabledState != nil {
            layer.borderColor = borderColorDisabledState?.cgColor
            borderWasSet = true
        }
        if isEnabled && isHighlighted && borderColorHighlightedState != nil {
            layer.borderColor = borderColorHighlightedState?.cgColor
            borderWasSet = true
        }
        if !borderWasSet {
            layer.borderColor = borderColorNormalState?.cgColor
        }
    }

    
    // ---
    // MARK: Custom layout
    // ---

    open func measuredSize(sizeSpec: CGSize, widthSpec: UniMeasureSpec, heightSpec: UniMeasureSpec) -> CGSize {
        let limitedSize = CGSize(width: max(0, sizeSpec.width), height: max(0, sizeSpec.height))
        var result = super.systemLayoutSizeFitting(limitedSize, withHorizontalFittingPriority: widthSpec == .unspecified ? UILayoutPriorityFittingSizeLevel : UILayoutPriorityRequired, verticalFittingPriority: heightSpec == .unspecified ? UILayoutPriorityFittingSizeLevel : UILayoutPriorityRequired)
        if widthSpec == .exactSize {
            result.width = sizeSpec.width
        } else if widthSpec == .limitSize {
            result.width = min(result.width, sizeSpec.width)
        }
        if heightSpec == .exactSize {
            result.height = sizeSpec.height
        } else if heightSpec == .limitSize {
            result.height = min(result.height, sizeSpec.height)
        }
        return result
    }

    open override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
        return measuredSize(sizeSpec: targetSize, widthSpec: horizontalFittingPriority == UILayoutPriorityRequired ? UniMeasureSpec.limitSize : UniMeasureSpec.unspecified, heightSpec: verticalFittingPriority == UILayoutPriorityRequired ? UniMeasureSpec.limitSize : UniMeasureSpec.unspecified)
    }
    
    open override func setNeedsLayout() {
        super.setNeedsLayout()
        if superview is UniLayoutView {
            superview?.setNeedsLayout()
        }
    }

}
