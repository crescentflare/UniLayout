//
//  UniButtonView.swift
//  UniLayout Pod
//
//  Library view: a simple button
//  Extends UIButton to support properties for UniLayout containers and more control over padding
//

import UIKit

public class UniButtonView: UIButton, UniLayoutView {

    // ---
    // MARK: Members
    // ---

    public var layoutProperties = UniLayoutProperties()

    
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
    // MARK: Custom layout
    // ---

    public func measuredSize(sizeSpec: CGSize, widthSpec: UniMeasureSpec, heightSpec: UniMeasureSpec) -> CGSize {
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

    public override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
        return measuredSize(sizeSpec: targetSize, widthSpec: horizontalFittingPriority == UILayoutPriorityRequired ? UniMeasureSpec.limitSize : UniMeasureSpec.unspecified, heightSpec: verticalFittingPriority == UILayoutPriorityRequired ? UniMeasureSpec.limitSize : UniMeasureSpec.unspecified)
    }
    
    public override func setNeedsLayout() {
        super.setNeedsLayout()
        if superview is UniLayoutView {
            superview?.setNeedsLayout()
        }
    }

}
