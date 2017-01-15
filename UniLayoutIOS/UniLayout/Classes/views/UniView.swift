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
    // MARK: Utilities
    // ---
    
    public static func uniMeasure(view: UIView, sizeSpec: CGSize, parentWidthSpec: UniMeasureSpec, parentHeightSpec: UniMeasureSpec, forceViewWidthSpec: UniMeasureSpec, forceViewHeightSpec: UniMeasureSpec) -> CGSize {
        // Derive view spec from parent
        var viewWidthSpec = forceViewWidthSpec
        var viewHeightSpec = forceViewHeightSpec
        if viewWidthSpec == .unspecified {
            viewWidthSpec = parentWidthSpec == .unspecified ? .unspecified : .limitSize
        }
        if viewHeightSpec == .unspecified {
            viewHeightSpec = parentHeightSpec == .unspecified ? .unspecified : .limitSize
        }
        if let viewLayoutProperties = (view as? UniLayoutView)?.layoutProperties {
            if parentWidthSpec == .exactSize && viewLayoutProperties.width == UniLayoutProperties.stretchToParent {
                viewWidthSpec = .exactSize
            }
            if parentHeightSpec == .exactSize && viewLayoutProperties.height == UniLayoutProperties.stretchToParent {
                viewHeightSpec = .exactSize
            }
        }
        
        // Determine sizing limits
        let viewMinWidth = max(0, (view as? UniLayoutView)?.layoutProperties.minWidth ?? 0)
        let viewMaxWidth = (view as? UniLayoutView)?.layoutProperties.maxWidth ?? 0xFFFFFF
        let viewMinHeight = max(0, (view as? UniLayoutView)?.layoutProperties.minHeight ?? 0)
        let viewMaxHeight = (view as? UniLayoutView)?.layoutProperties.maxHeight ?? 0xFFFFFF

        // Adjust size to measure on based on view limits or forced values
        var viewSize = sizeSpec
        if viewWidthSpec == .exactSize {
            viewSize.width = min(viewSize.width, max(viewMinWidth, viewMaxWidth))
        } else if ((view as? UniLayoutView)?.layoutProperties.width ?? -1) >= 0 {
            viewSize.width = min(viewSize.width, max(viewMinWidth, min((view as? UniLayoutView)?.layoutProperties.width ?? 0, viewMaxWidth)))
            viewWidthSpec = .exactSize
        } else {
            viewSize.width = min(viewSize.width, max(viewMinWidth, viewMaxWidth))
        }
        if viewHeightSpec == .exactSize {
            viewSize.height = min(viewSize.height, max(viewMinHeight, viewMaxHeight))
        } else if ((view as? UniLayoutView)?.layoutProperties.height ?? -1) >= 0 {
            viewSize.height = min(viewSize.height, max(viewMinHeight, min((view as? UniLayoutView)?.layoutProperties.height ?? 0, viewMaxHeight)))
            viewHeightSpec = .exactSize
        } else {
            viewSize.height = min(viewSize.height, max(viewMinHeight, viewMaxHeight))
        }

        // Perform measure and apply size restrictions if they are in place
        var result = obtainMeasuredSize(ofView: view, sizeSpec: viewSize, widthSpec: viewWidthSpec, heightSpec: viewHeightSpec)
        result.width = min(viewSize.width, max(viewMinWidth, result.width))
        result.height = min(viewSize.height, max(viewMinHeight, result.height))
        return result
    }

    static func obtainMeasuredSize(ofView: UIView, sizeSpec: CGSize, widthSpec: UniMeasureSpec, heightSpec: UniMeasureSpec) -> CGSize {
        if let layoutView = ofView as? UniLayoutView {
            return layoutView.measuredSize(sizeSpec: sizeSpec, widthSpec: widthSpec, heightSpec: heightSpec)
        }
        var result = ofView.systemLayoutSizeFitting(sizeSpec, withHorizontalFittingPriority: widthSpec == .unspecified ? UILayoutPriorityFittingSizeLevel : UILayoutPriorityRequired, verticalFittingPriority: heightSpec == .unspecified ? UILayoutPriorityFittingSizeLevel : UILayoutPriorityRequired)
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
