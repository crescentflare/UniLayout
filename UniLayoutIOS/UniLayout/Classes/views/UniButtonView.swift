//
//  UniButtonView.swift
//  UniLayout Pod
//
//  Library view: a simple button
//  Extends UIButton to support properties for UniLayout containers and more control over padding
//

import UIKit

/// A UniLayout enabled UIButton, adding padding and layout properties
open class UniButtonView: UIButton, UniLayoutView, UniLayoutPaddedView {

    // ---
    // MARK: Layout integration
    // ---
    
    public var layoutProperties = UniLayoutProperties()
    
    public var visibility: UniVisibility {
        set {
            isHidden = newValue != .visible
            layoutProperties.hiddenTakesSpace = newValue == .invisible
        }
        get {
            if isHidden {
                return layoutProperties.hiddenTakesSpace ? .invisible : .hidden
            }
            return .visible
        }
    }

    
    // ---
    // MARK: Members
    // ---
    
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
                contentEdgeInsets.top = 0.01 // Prevents UIKIT to apply automatic sizing when using a zero value
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
        padding = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    
    // ---
    // MARK: Override variables to update the layout
    // ---
    
    open override var contentEdgeInsets: UIEdgeInsets {
        didSet {
            UniLayout.setNeedsLayout(view: self)
        }
    }

    open override var titleEdgeInsets: UIEdgeInsets {
        didSet {
            UniLayout.setNeedsLayout(view: self)
        }
    }
    
    open override var imageEdgeInsets: UIEdgeInsets {
        didSet {
            UniLayout.setNeedsLayout(view: self)
        }
    }
    
    open override var isHidden: Bool {
        didSet {
            UniLayout.setNeedsLayout(view: self)
        }
    }
    
    
    // ---
    // MARK: Override functions to update the layout
    // ---

    open override func setTitle(_ title: String?, for state: UIControl.State) {
        super.setTitle(title, for: state)
        UniLayout.setNeedsLayout(view: self)
        if adjustsTintColorToMatchTitle {
            refreshTintColor()
        }
    }

    open override func setImage(_ image: UIImage?, for state: UIControl.State) {
        super.setImage(image, for: state)
        UniLayout.setNeedsLayout(view: self)
    }

    open override func setBackgroundImage(_ image: UIImage?, for state: UIControl.State) {
        super.setBackgroundImage(image, for: state)
        UniLayout.setNeedsLayout(view: self)
    }

    open override func setAttributedTitle(_ title: NSAttributedString?, for state: UIControl.State) {
        super.setAttributedTitle(title, for: state)
        UniLayout.setNeedsLayout(view: self)
    }
    

    // ---
    // MARK: Add more state support
    // ---
    
    open override var isHighlighted: Bool {
        didSet {
            refreshStateBackground()
            if borderColorNormalState != nil || borderColorHighlightedState != nil || borderColorDisabledState != nil {
                refreshStateBorder()
            }
            if adjustsTintColorToMatchTitle {
                refreshTintColor()
            }
        }
    }
    
    open override var isEnabled: Bool {
        didSet {
            refreshStateBackground()
            if borderColorNormalState != nil || borderColorHighlightedState != nil || borderColorDisabledState != nil {
                refreshStateBorder()
            }
            if adjustsTintColorToMatchTitle {
                refreshTintColor()
            }
        }
    }
    
    open var adjustsTintColorToMatchTitle: Bool = false {
        didSet {
            refreshTintColor()
        }
    }
    
    open override var backgroundColor: UIColor? {
        get { return backgroundColorNormalState }
        set { setBackgroundColor(newValue, for: .normal) }
    }

    public func setBackgroundColor(_ color: UIColor?, for state: UIControl.State) {
        let currentState = !isEnabled ? UIControl.State.disabled : (isHighlighted ? UIControl.State.highlighted : UIControl.State.normal)
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
    
    public func setBorderColor(_ color: UIColor?, for state: UIControl.State) {
        let currentState = !isEnabled ? UIControl.State.disabled : (isHighlighted ? UIControl.State.highlighted : UIControl.State.normal)
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
    
    private func refreshTintColor() {
        if adjustsTintColorToMatchTitle {
            tintColor = titleColor(for: isEnabled ? (isHighlighted ? .highlighted : .normal) : .disabled)
        } else {
            tintColor = nil
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
        var result = super.systemLayoutSizeFitting(limitedSize, withHorizontalFittingPriority: widthSpec == .unspecified ? UILayoutPriority.fittingSizeLevel : UILayoutPriority.required, verticalFittingPriority: heightSpec == .unspecified ? UILayoutPriority.fittingSizeLevel : UILayoutPriority.required)
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
        return measuredSize(sizeSpec: targetSize, widthSpec: horizontalFittingPriority == UILayoutPriority.required ? UniMeasureSpec.limitSize : UniMeasureSpec.unspecified, heightSpec: verticalFittingPriority == UILayoutPriority.required ? UniMeasureSpec.limitSize : UniMeasureSpec.unspecified)
    }

}
