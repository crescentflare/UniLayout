//
//  UniSwitchView.swift
//  UniLayout Pod
//
//  Library view: a switch with text
//  Extends UIView containing a UISwitch to support properties for UniLayout containers and padding
//  Also adds a text label as part of the component
//

import UIKit

/// A UniLayout enabled UISwitch, adding text, padding and layout properties
open class UniSwitchView: UIView, UniLayoutView, UniLayoutPaddedView {

    // ---
    // MARK: Constants
    // ---

    private static var textPadding: CGFloat = 8
    
    
    // ---
    // MARK: Members
    // ---
    
    public var layoutProperties = UniLayoutProperties()
    public var padding = UIEdgeInsets.zero
    private var switchView = UniNotifyingSwitchView()
    private var textView = UniNotifyingLabelView()

    
    // ---
    // MARK: UISwitch properties
    // ---
    
    public var onTintColor: UIColor? {
        get {
            return switchView.onTintColor
        }
        set {
            switchView.onTintColor = newValue
        }
    }
    
    public var thumbTintColor: UIColor? {
        set {
            switchView.thumbTintColor = newValue
        }
        get { return switchView.thumbTintColor }
    }
    
    public var onImage: UIImage? {
        set {
            switchView.onImage = newValue
        }
        get { return switchView.onImage }
    }
    
    public var offImage: UIImage? {
        set {
            switchView.offImage = newValue
        }
        get { return switchView.offImage }
    }

    public var isOn: Bool {
        set {
            switchView.isOn = newValue
        }
        get { return switchView.isOn }
    }
    
    public var internalSwitchView: UISwitch {
        get {
            return switchView
        }
    }
    
    
    // ---
    // MARK: Text properties
    // ---
    
    public var text: String? {
        set {
            textView.text = newValue
        }
        get { return textView.text }
    }

    public var attributedText: NSAttributedString? {
        set {
            textView.attributedText = newValue
        }
        get { return textView.attributedText }
    }

    public var font: UIFont! {
        set {
            textView.font = newValue
        }
        get { return textView.font }
    }

    public var textColor: UIColor! {
        set {
            textView.textColor = newValue
        }
        get { return textView.textColor }
    }

    public var highlightedTextColor: UIColor! {
        set {
            textView.highlightedTextColor = newValue
        }
        get { return textView.highlightedTextColor }
    }

    public var textShadowColor: UIColor? {
        set {
            textView.shadowColor = newValue
        }
        get { return textView.shadowColor }
    }

    public var textShadowOffset: CGSize {
        set {
            textView.shadowOffset = newValue
        }
        get { return textView.shadowOffset }
    }

    public var textAlignment: NSTextAlignment {
        set {
            textView.textAlignment = newValue
        }
        get { return textView.textAlignment }
    }

    public var textLineBreakMode: NSLineBreakMode {
        set {
            textView.lineBreakMode = newValue
        }
        get { return textView.lineBreakMode }
    }

    public var numberOfLines: Int {
        set {
            textView.numberOfLines = newValue
        }
        get { return textView.numberOfLines }
    }

    public var adjustsFontSizeToFitWidth: Bool {
        set {
            textView.adjustsFontSizeToFitWidth = newValue
        }
        get { return textView.adjustsFontSizeToFitWidth }
    }

    public var baselineAdjustment: UIBaselineAdjustment {
        set {
            textView.baselineAdjustment = newValue
        }
        get { return textView.baselineAdjustment }
    }

    public var minimumScaleFactor: CGFloat {
        set {
            textView.minimumScaleFactor = newValue
        }
        get { return textView.minimumScaleFactor }
    }

    public var internalTextView: UILabel {
        get {
            return textView
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
        // Add views
        textView.numberOfLines = 0
        addSubview(textView)
        addSubview(switchView)
        
        // Add recognizer to tap on the text to enable the switch
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(onTap(_:)))
        addGestureRecognizer(tapRecognizer)
    }
    
    
    // ---
    // MARK: UISwitch methods
    // ---
    
    public func setOn(_ on: Bool, animated: Bool) {
        switchView.setOn(on, animated: animated)
    }
    

    // ---
    // MARK: Interaction
    // ---

    public func onTap(_ sender: Any) {
        switchView.setOn(!switchView.isOn, animated: true)
    }

    
    // ---
    // MARK: Custom layout
    // ---

    open func measuredSize(sizeSpec: CGSize, widthSpec: UniMeasureSpec, heightSpec: UniMeasureSpec) -> CGSize {
        var result = CGSize(width: padding.left + padding.right, height: padding.top + padding.bottom)
        var measuredTextSize = CGSize.zero
        if textView.text?.characters.count ?? 0 > 0 {
            measuredTextSize = UniLayout.measure(view: textView, sizeSpec: CGSize(width: sizeSpec.width - padding.left - padding.right - switchView.intrinsicContentSize.width - UniSwitchView.textPadding, height: sizeSpec.height - padding.top - padding.bottom), parentWidthSpec: widthSpec, parentHeightSpec: heightSpec, forceViewWidthSpec: .unspecified, forceViewHeightSpec: .unspecified)
            result.width += measuredTextSize.width + UniSwitchView.textPadding
        }
        result.width += switchView.intrinsicContentSize.width
        result.height += max(switchView.intrinsicContentSize.height, measuredTextSize.height)
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

    open override func layoutSubviews() {
        let centerY = padding.top + (bounds.height - padding.top - padding.bottom) / 2
        UniLayout.setFrame(view: textView, frame: CGRect(x: padding.left, y: padding.top, width: bounds.width - padding.left - padding.right - switchView.intrinsicContentSize.width - UniSwitchView.textPadding, height: bounds.height - padding.top - padding.bottom))
        UniLayout.setFrame(view: switchView, frame: CGRect(x: bounds.width - padding.right - switchView.intrinsicContentSize.width, y: centerY - switchView.intrinsicContentSize.height / 2, width: switchView.intrinsicContentSize.width, height: switchView.intrinsicContentSize.height))
    }
    
    open override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
        return measuredSize(sizeSpec: targetSize, widthSpec: horizontalFittingPriority == UILayoutPriorityRequired ? UniMeasureSpec.limitSize : UniMeasureSpec.unspecified, heightSpec: verticalFittingPriority == UILayoutPriorityRequired ? UniMeasureSpec.limitSize : UniMeasureSpec.unspecified)
    }
    
    open override var intrinsicContentSize : CGSize {
        return switchView.intrinsicContentSize
    }

}

class UniNotifyingSwitchView: UISwitch {
    
    // ---
    // MARK: Hook layout into style changes
    // ---
    
    override var onImage: UIImage? {
        didSet {
            UniLayout.setNeedsLayout(view: self)
        }
    }

    override var offImage: UIImage? {
        didSet {
            UniLayout.setNeedsLayout(view: self)
        }
    }

}
