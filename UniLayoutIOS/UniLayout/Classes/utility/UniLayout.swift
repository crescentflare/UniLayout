//
//  UniLayout.swift
//  UniLayout Pod
//
//  Library utility: layout related helpers
//  Provides shared helper functions for measurement and layout
//

import UIKit

/// Provides utilities to help measure and layout views
public class UniLayout {

    // ---
    // MARK: Initialization
    // ---
    
    private init() {
    }

    
    // ---
    // MARK: Utilities
    // ---
    
    public static func measure(view: UIView, sizeSpec: CGSize, parentWidthSpec: UniMeasureSpec, parentHeightSpec: UniMeasureSpec, forceViewWidthSpec: UniMeasureSpec, forceViewHeightSpec: UniMeasureSpec) -> CGSize {
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
    
    public static func setFrame(view: UIView, frame: CGRect) {
        if view.bounds.width == frame.width && view.bounds.height == frame.height {
            if view.center.x == frame.origin.x + frame.width / 2 && view.center.y == frame.origin.y + frame.height / 2 {
                return // No change
            }
            view.center = CGPoint(x: frame.origin.x + frame.width / 2, y: frame.origin.y + frame.height / 2)
        } else if view.center.x == frame.origin.x + frame.width / 2 && view.center.y == frame.origin.y + frame.height / 2 {
            view.bounds.size = frame.size
        } else {
            view.bounds.size = frame.size
            view.center = CGPoint(x: frame.origin.x + frame.width / 2, y: frame.origin.y + frame.height / 2)
        }
    }
    
    public static func setNeedsLayout(view: UIView) {
        if let superview = view.superview {
            if superview is UniLayoutView {
                setNeedsLayout(view: superview)
            }
        }
        view.setNeedsLayout()
    }
    
    
    // ---
    // MARK: Internal helpers
    // ---

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
