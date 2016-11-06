//
//  UniReusingContainer.swift
//  UniLayout Pod
//
//  Library container: a container with reusable views
//  Overrides UITableView to support layout properties
//

import UIKit

open class UniReusingContainer: UITableView, UniLayoutView {

    // ---
    // MARK: Members
    // ---
    
    public var layoutProperties = UniLayoutProperties()


    // ---
    // MARK: Custom layout
    // ---
    
    open func measuredSize(sizeSpec: CGSize, widthSpec: UniMeasureSpec, heightSpec: UniMeasureSpec) -> CGSize {
        var result = systemLayoutSizeFitting(sizeSpec, withHorizontalFittingPriority: widthSpec == .unspecified ? UILayoutPriorityFittingSizeLevel : UILayoutPriorityRequired, verticalFittingPriority: heightSpec == .unspecified ? UILayoutPriorityFittingSizeLevel : UILayoutPriorityRequired)
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

}
