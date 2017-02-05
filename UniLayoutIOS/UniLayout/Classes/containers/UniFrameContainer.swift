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
        
        // Iterate over subviews and measure each one
        var subviewSizes: [CGSize] = []
        for view in subviews {
            // Skip hidden views if they are not part of the layout
            if view.isHidden && !((view as? UniLayoutView)?.layoutProperties.hiddenTakesSpace ?? false) {
                subviewSizes.append(CGSize.zero)
                continue
            }
            
            // Perform measure
            var limitWidth = paddedSize.width
            var limitHeight = paddedSize.height
            if let viewLayoutProperties = (view as? UniLayoutView)?.layoutProperties {
                limitWidth -= viewLayoutProperties.margin.left + viewLayoutProperties.margin.right
                limitHeight -= viewLayoutProperties.margin.top + viewLayoutProperties.margin.bottom
            }
            let result = UniView.uniMeasure(view: view, sizeSpec: CGSize(width: limitWidth, height: limitHeight), parentWidthSpec: widthSpec, parentHeightSpec: heightSpec, forceViewWidthSpec: .unspecified, forceViewHeightSpec: .unspecified)
            subviewSizes.append(result)
        }
        
        // Start doing layout
        for i in 0..<min(subviews.count, subviewSizes.count) {
            // Skip hidden views if they are not part of the layout
            let view = subviews[i]
            if view.isHidden && !((view as? UniLayoutView)?.layoutProperties.hiddenTakesSpace ?? false) {
                continue
            }
            
            // Continue with the others
            let size = subviewSizes[i]
            var x = padding.left
            var y = padding.top
            if let viewLayoutProperties = (view as? UniLayoutView)?.layoutProperties {
                x += viewLayoutProperties.margin.left
                y += viewLayoutProperties.margin.top
                if adjustFrames {
                    x += (paddedSize.width - viewLayoutProperties.margin.left - viewLayoutProperties.margin.right - size.width) * viewLayoutProperties.horizontalGravity
                    y += (paddedSize.height - viewLayoutProperties.margin.top - viewLayoutProperties.margin.bottom - size.height) * viewLayoutProperties.verticalGravity
                }
                measuredSize.width = max(measuredSize.width, x + size.width + viewLayoutProperties.margin.right)
                measuredSize.height = max(measuredSize.height, y + size.height + viewLayoutProperties.margin.bottom)
            } else {
                measuredSize.width = max(measuredSize.width, x + size.width)
                measuredSize.height = max(measuredSize.height, y + size.height)
            }
            if adjustFrames {
                UniView.uniSetFrame(view: view, frame: CGRect(x: x, y: y, width: size.width, height: size.height))
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
        performLayout(sizeSpec: bounds.size, widthSpec: .exactSize, heightSpec: .exactSize, adjustFrames: true)
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
