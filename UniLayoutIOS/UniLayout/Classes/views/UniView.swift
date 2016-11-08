//
//  UniView.swift
//  UniLayout Pod
//
//  Library view: a simple view
//  Extends UIView to support properties for UniLayout containers and padding
//

import UIKit

open class UniView: UIView, UniLayoutView, UniLayoutPaddedView {

    // ---
    // MARK: Members
    // ---

    public var layoutProperties = UniLayoutProperties()
    public var padding = UIEdgeInsets.zero
    

    // ---
    // MARK: Custom layout
    // ---
    
    open func measuredSize(sizeSpec: CGSize, widthSpec: UniMeasureSpec, heightSpec: UniMeasureSpec) -> CGSize {
        var result = CGSize(width: padding.left + padding.right, height: padding.top + padding.bottom)
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
    
    
    // ---
    // MARK: Helper for measuring UniLayout or normal views
    // ---

    static func obtainMeasuredSize(ofView: UIView, sizeSpec: CGSize, widthSpec: UniMeasureSpec, heightSpec: UniMeasureSpec) -> CGSize {
        if let layoutView = ofView as? UniLayoutView {
            return layoutView.measuredSize(sizeSpec: sizeSpec, widthSpec: widthSpec, heightSpec: heightSpec)
        }
        return ofView.systemLayoutSizeFitting(sizeSpec, withHorizontalFittingPriority: widthSpec == .unspecified ? UILayoutPriorityFittingSizeLevel : UILayoutPriorityRequired, verticalFittingPriority: heightSpec == .unspecified ? UILayoutPriorityFittingSizeLevel : UILayoutPriorityRequired)
    }
    
}
