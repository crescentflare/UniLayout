//
//  UniImageView.swift
//  UniLayout Pod
//
//  Library view: a view containing an image
//  Extends UIView containing a UIImageView to support properties for UniLayout containers and padding
//

import UIKit

/// A UniLayout enabled UIImageView, adding padding and layout properties
open class UniImageView: UIView, UniLayoutView, UniLayoutPaddedView {

    // ---
    // MARK: Layout integration
    // ---
    
    public var layoutProperties = UniLayoutProperties()
    public var padding = UIEdgeInsets.zero
    
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

    private var imageView = UniNotifyingImageView()
    

    // ---
    // MARK: UIImageView properties
    // ---
    
    public var image: UIImage? {
        get {
            return imageView.image
        }
        set {
            imageView.image = newValue
        }
    }
    
    public var highlightedImage: UIImage? {
        get {
            return imageView.highlightedImage
        }
        set {
            imageView.highlightedImage = newValue
        }
    }
    
    public var animationDuration: TimeInterval {
        get {
            return imageView.animationDuration
        }
        set {
            imageView.animationDuration = newValue
        }
    }
    
    public var animationImages: [UIImage]? {
        get {
            return imageView.animationImages
        }
        set {
            imageView.animationImages = newValue
        }
    }
    
    public var highlightedAnimationImages: [UIImage]? {
        get {
            return imageView.highlightedAnimationImages
        }
        set {
            imageView.highlightedAnimationImages = newValue
        }
    }
    
    public var animationRepeatCount: Int {
        get {
            return imageView.animationRepeatCount
        }
        set {
            imageView.animationRepeatCount = newValue
        }
    }
    
    public var isAnimating: Bool {
        get {
            return imageView.isAnimating
        }
    }
    
    public var internalImageView: UIImageView {
        get {
            return imageView
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
        addSubview(imageView)
    }
    
    
    // ---
    // MARK: Override variables to update the layout
    // ---
    
    open override var isHidden: Bool {
        didSet {
            UniLayout.setNeedsLayout(view: self)
        }
    }

    
    // ---
    // MARK: Custom layout
    // ---

    open func measuredSize(sizeSpec: CGSize, widthSpec: UniMeasureSpec, heightSpec: UniMeasureSpec) -> CGSize {
        var result = CGSize(width: padding.left + padding.right, height: padding.top + padding.bottom)
        if let image = imageView.image {
            result.width += image.size.width
            result.height += image.size.height
        }
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
        UniLayout.setFrame(view: imageView, frame: CGRect(x: padding.left, y: padding.top, width: max(0, bounds.width - padding.left - padding.right), height: max(0, bounds.height - padding.top - padding.bottom)))
    }
    
    open override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
        return measuredSize(sizeSpec: targetSize, widthSpec: horizontalFittingPriority == UILayoutPriorityRequired ? UniMeasureSpec.limitSize : UniMeasureSpec.unspecified, heightSpec: verticalFittingPriority == UILayoutPriorityRequired ? UniMeasureSpec.limitSize : UniMeasureSpec.unspecified)
    }
    
    open override var intrinsicContentSize : CGSize {
        return imageView.intrinsicContentSize
    }

}

class UniNotifyingImageView: UIImageView {

    // ---
    // MARK: Hook layout into image changes
    // ---
    
    override var image: UIImage? {
        didSet {
            UniLayout.setNeedsLayout(view: self)
        }
    }

    override var highlightedImage: UIImage? {
        didSet {
            UniLayout.setNeedsLayout(view: self)
        }
    }

    override var animationImages: [UIImage]? {
        didSet {
            UniLayout.setNeedsLayout(view: self)
        }
    }

    override var highlightedAnimationImages: [UIImage]? {
        didSet {
            UniLayout.setNeedsLayout(view: self)
        }
    }

}
