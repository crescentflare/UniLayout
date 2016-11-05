//
//  UniFrameContainer.swift
//  UniLayout Pod
//
//  Library container: an overlapping view container
//  Overlaps and aligns views within the container
//

import UIKit

open class UniFrameContainer: UIView, UniLayoutView, UniLayoutPaddedView {

    // ---
    // MARK: Members
    // ---
    
    public var layoutProperties = UniLayoutProperties()
    public var padding = UIEdgeInsets.zero

    
    // ---
    // MARK: Custom layout
    // ---

    @discardableResult internal func performLayout(sizeSpec: CGSize, widthSpec: UniMeasureSpec, heightSpec: UniMeasureSpec, adjustFrames: Bool) -> CGSize {
        // Determine available size without padding
        var paddedSize = CGSize(width: max(0, sizeSpec.width - padding.left - padding.right), height: max(0, sizeSpec.height - padding.top - padding.bottom))
        var measuredSize = CGSize(width: padding.left, height: padding.top)
        if widthSpec == .unspecified {
            paddedSize.width = 0xFFFFFF
        }
        if heightSpec == .unspecified {
            paddedSize.height = 0xFFFFFF
        }
        
        // Iterate over subviews and layout each one
        for view in subviews {
            // Skip hidden views if they are not part of the layout
            if view.isHidden && !((view as? UniLayoutView)?.layoutProperties.hiddenTakesSpace ?? false) {
                continue
            }
            
            // Adjust size limitations based on layout property restrictions
            var viewWidthSpec = widthSpec == .unspecified ? UniMeasureSpec.unspecified : UniMeasureSpec.limitSize
            var viewHeightSpec = heightSpec == .unspecified ? UniMeasureSpec.unspecified : UniMeasureSpec.limitSize
            var viewSizeSpec = paddedSize
            if let viewLayoutProperties = (view as? UniLayoutView)?.layoutProperties {
                viewSizeSpec.width = max(0, viewSizeSpec.width - viewLayoutProperties.margin.left - viewLayoutProperties.margin.right)
                viewSizeSpec.height = max(0, viewSizeSpec.height - viewLayoutProperties.margin.top - viewLayoutProperties.margin.bottom)
                if widthSpec == .exactSize && viewLayoutProperties.width == UniLayoutProperties.stretchToParent {
                    viewSizeSpec.width = min(viewSizeSpec.width, max(viewLayoutProperties.minWidth, viewLayoutProperties.maxWidth))
                    viewWidthSpec = .exactSize
                } else if viewLayoutProperties.width >= 0 {
                    viewSizeSpec.width = min(viewSizeSpec.width, max(viewLayoutProperties.minWidth, min(viewLayoutProperties.width, viewLayoutProperties.maxWidth)))
                    viewWidthSpec = .exactSize
                } else {
                    viewSizeSpec.width = min(viewSizeSpec.width, max(viewLayoutProperties.minWidth, viewLayoutProperties.maxWidth))
                }
                if heightSpec == .exactSize && viewLayoutProperties.height == UniLayoutProperties.stretchToParent {
                    viewSizeSpec.height = min(viewSizeSpec.height, max(viewLayoutProperties.minHeight, viewLayoutProperties.maxHeight))
                    viewHeightSpec = .exactSize
                } else if viewLayoutProperties.height >= 0 {
                    viewSizeSpec.height = min(viewSizeSpec.height, max(viewLayoutProperties.minHeight, min(viewLayoutProperties.height, viewLayoutProperties.maxHeight)))
                    viewHeightSpec = .exactSize
                } else {
                    viewSizeSpec.height = min(viewSizeSpec.height, max(viewLayoutProperties.minHeight, viewLayoutProperties.maxHeight))
                }
            }
            
            // Obtain final size and make final adjustments per view
            var result = UniView.obtainMeasuredSize(ofView: view, sizeSpec: viewSizeSpec, widthSpec: viewWidthSpec, heightSpec: viewHeightSpec)
            var x = padding.left
            var y = padding.top
            if let viewLayoutProperties = (view as? UniLayoutView)?.layoutProperties {
                result.width = min(viewSizeSpec.width, max(viewLayoutProperties.minWidth, result.width))
                result.height = min(viewSizeSpec.height, max(viewLayoutProperties.minHeight, result.height))
                x += viewLayoutProperties.margin.left
                y += viewLayoutProperties.margin.top
                if adjustFrames {
                    x += (paddedSize.width - viewLayoutProperties.margin.left - viewLayoutProperties.margin.right - result.width) * viewLayoutProperties.horizontalGravity
                    y += (paddedSize.height - viewLayoutProperties.margin.top - viewLayoutProperties.margin.bottom - result.height) * viewLayoutProperties.verticalGravity
                }
                measuredSize.width = max(measuredSize.width, x + result.width + viewLayoutProperties.margin.right)
                measuredSize.height = max(measuredSize.height, y + result.height + viewLayoutProperties.margin.bottom)
            } else {
                result.width = min(viewSizeSpec.width, result.width)
                result.height = min(viewSizeSpec.height, result.height)
                measuredSize.width = max(measuredSize.width, x + result.width)
                measuredSize.height = max(measuredSize.height, y + result.height)
            }
            if adjustFrames {
                view.frame = CGRect(x: x, y: y, width: result.width, height: result.height)
            }
        }
        
        // Adjust final measure with padding and limitations
        measuredSize.width += padding.right
        measuredSize.height += padding.bottom
        if widthSpec == .exactSize {
            measuredSize.width = sizeSpec.width
        } else if widthSpec == .limitSize {
            measuredSize.width = min(measuredSize.width, sizeSpec.width)
        }
        if heightSpec == .exactSize {
            measuredSize.height = sizeSpec.height
        } else if heightSpec == .limitSize {
            measuredSize.height = min(measuredSize.height, sizeSpec.height)
        }
        return measuredSize
    }

    open func measuredSize(sizeSpec: CGSize, widthSpec: UniMeasureSpec, heightSpec: UniMeasureSpec) -> CGSize {
        return performLayout(sizeSpec: sizeSpec, widthSpec: widthSpec, heightSpec: heightSpec, adjustFrames: false)
    }
    
    open override func layoutSubviews() {
        performLayout(sizeSpec: frame.size, widthSpec: .exactSize, heightSpec: .exactSize, adjustFrames: true)
    }
    
    open override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
        return measuredSize(sizeSpec: targetSize, widthSpec: horizontalFittingPriority == UILayoutPriorityRequired ? UniMeasureSpec.limitSize : UniMeasureSpec.unspecified, heightSpec: verticalFittingPriority == UILayoutPriorityRequired ? UniMeasureSpec.limitSize : UniMeasureSpec.unspecified)
    }
    
    
    // ---
    // MARK: Improve layout needed behavior
    // ---

    open override func willRemoveSubview(_ subview: UIView) {
        setNeedsLayout()
    }
    
    open override func didAddSubview(_ subview: UIView) {
        setNeedsLayout()
    }
 
    open override func setNeedsLayout() {
        super.setNeedsLayout()
        if superview is UniLayoutView {
            superview?.setNeedsLayout()
        }
    }

}
