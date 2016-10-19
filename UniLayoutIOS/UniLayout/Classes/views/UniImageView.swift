//
//  UniImageView.swift
//  UniLayout Pod
//
//  Library view: a view containing an image
//  Extends UIView containing a UIImageView to support properties for UniLayout containers and padding
//

import UIKit

class UniImageView: UIView, UniLayoutView {

    // ---
    // MARK: Members
    // ---

    var layoutProperties = UniLayoutProperties()
    private var imageView = UIImageView()
    

    // ---
    // MARK: UIImageView properties
    // ---
    
    var image: UIImage? {
        get {
            return imageView.image
        }
        set {
            imageView.image = newValue
        }
    }
    
    var highlightedImage: UIImage? {
        get {
            return imageView.highlightedImage
        }
        set {
            imageView.highlightedImage = newValue
        }
    }
    
    var animationDuration: TimeInterval {
        get {
            return imageView.animationDuration
        }
        set {
            imageView.animationDuration = newValue
        }
    }
    
    var animationImages: [UIImage]? {
        get {
            return imageView.animationImages
        }
        set {
            imageView.animationImages = newValue
        }
    }
    
    var highlightedAnimationImages: [UIImage]? {
        get {
            return imageView.highlightedAnimationImages
        }
        set {
            imageView.highlightedAnimationImages = newValue
        }
    }
    
    var animationRepeatCount: Int {
        get {
            return imageView.animationRepeatCount
        }
        set {
            imageView.animationRepeatCount = newValue
        }
    }
    
    var isAnimating: Bool {
        get {
            return imageView.isAnimating
        }
    }
    
    var internalImageView: UIImageView {
        get {
            return imageView
        }
    }


    // ---
    // MARK: Initialization
    // ---

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        addSubview(imageView)
    }
    
    
    // ---
    // MARK: Custom layout
    // ---

    internal func measuredSize(sizeSpec: CGSize, widthSpec: UniMeasureSpec, heightSpec: UniMeasureSpec) -> CGSize {
        var result = CGSize(width: layoutProperties.padding.left + layoutProperties.padding.right, height: layoutProperties.padding.top + layoutProperties.padding.bottom)
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
    
    internal override func layoutSubviews() {
        let padding = layoutProperties.padding
        imageView.frame = CGRect(x: padding.left, y: padding.top, width: max(0, frame.width - padding.left - padding.right), height: max(0, frame.height - padding.top - padding.bottom))
    }
    
    internal override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
        return measuredSize(sizeSpec: targetSize, widthSpec: horizontalFittingPriority == UILayoutPriorityRequired ? UniMeasureSpec.limitSize : UniMeasureSpec.unspecified, heightSpec: verticalFittingPriority == UILayoutPriorityRequired ? UniMeasureSpec.limitSize : UniMeasureSpec.unspecified)
    }
    
    internal override var intrinsicContentSize : CGSize {
        return imageView.intrinsicContentSize
    }

}
