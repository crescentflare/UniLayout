//
//  UniLinearContainer.swift
//  UniLayout Pod
//
//  Library container: a vertically or horizontally aligned view container
//  Stacks views below or to the right of each other
//

import UIKit

/// Specifies the layout direction of the subviews of the linear container
public enum UniLinearContainerOrientation: String {
    
    case vertical = "vertical"
    case horizontal = "horizontal"
    
}

/// A layout container view used to align subviews horizontally or vertically
open class UniLinearContainer: UIView, UniLayoutView, UniLayoutPaddedView {

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
    
    public var orientation = UniLinearContainerOrientation.vertical

    
    // ---
    // MARK: Custom layout
    // ---

    @discardableResult internal func performVerticalLayout(sizeSpec: CGSize, widthSpec: UniMeasureSpec, heightSpec: UniMeasureSpec, adjustFrames: Bool) -> CGSize {
        // Determine available size without padding
        var paddedSize = CGSize(width: max(0, sizeSpec.width - padding.left - padding.right), height: max(0, sizeSpec.height - padding.top - padding.bottom))
        var measuredSize = CGSize(width: padding.left, height: padding.top)
        if widthSpec == .unspecified {
            paddedSize.width = 0xFFFFFF
        }
        if heightSpec == .unspecified {
            paddedSize.height = 0xFFFFFF
        }

        // Measure the views without any weight
        var subviewSizes: [CGSize] = []
        var totalWeight: CGFloat = 0
        var remainingHeight = paddedSize.height
        var totalMinHeightForWeight: CGFloat = 0
        for view in subviews {
            // Skip hidden views if they are not part of the layout
            if view.isHidden && !((view as? UniLayoutView)?.layoutProperties.hiddenTakesSpace ?? false) {
                subviewSizes.append(CGSize.zero)
                continue
            }

            // Skip views with weight, they will go in the second phase
            if let viewLayoutProperties = (view as? UniLayoutView)?.layoutProperties {
                if viewLayoutProperties.weight > 0 {
                    totalWeight += viewLayoutProperties.weight
                    remainingHeight -= viewLayoutProperties.margin.top + viewLayoutProperties.margin.bottom + viewLayoutProperties.minHeight
                    totalMinHeightForWeight += viewLayoutProperties.minHeight
                    subviewSizes.append(CGSize.zero)
                    continue
                }
            }
            
            // Perform measure and update remaining height
            var limitWidth = paddedSize.width
            if let viewLayoutProperties = (view as? UniLayoutView)?.layoutProperties {
                limitWidth -= viewLayoutProperties.margin.left + viewLayoutProperties.margin.right
                remainingHeight -= viewLayoutProperties.margin.top + viewLayoutProperties.margin.bottom
            }
            let result = UniLayout.measure(view: view, sizeSpec: CGSize(width: limitWidth, height: remainingHeight), parentWidthSpec: widthSpec, parentHeightSpec: heightSpec, forceViewWidthSpec: .unspecified, forceViewHeightSpec: .unspecified)
            remainingHeight = max(0, remainingHeight - result.height)
            subviewSizes.append(result)
        }
        
        // Measure the remaining views with weight
        remainingHeight += totalMinHeightForWeight
        for i in 0..<min(subviews.count, subviewSizes.count) {
            // Skip hidden views if they are not part of the layout
            let view = subviews[i]
            if view.isHidden && !((view as? UniLayoutView)?.layoutProperties.hiddenTakesSpace ?? false) {
                continue
            }
            
            // Continue with views with weight
            if let viewLayoutProperties = (view as? UniLayoutView)?.layoutProperties {
                if viewLayoutProperties.weight > 0 {
                    let forceViewHeightSpec: UniMeasureSpec = heightSpec == .exactSize ? .exactSize : .unspecified
                    let result = UniLayout.measure(view: view, sizeSpec: CGSize(width: paddedSize.width - viewLayoutProperties.margin.left - viewLayoutProperties.margin.right, height: remainingHeight * viewLayoutProperties.weight / totalWeight), parentWidthSpec: widthSpec, parentHeightSpec: heightSpec, forceViewWidthSpec: .unspecified, forceViewHeightSpec: forceViewHeightSpec)
                    remainingHeight = max(0, remainingHeight - result.height)
                    totalWeight -= viewLayoutProperties.weight
                    subviewSizes[i] = result
                }
            }
        }
        
        // Start doing layout
        var y = padding.top
        for i in 0..<min(subviews.count, subviewSizes.count) {
            // Skip hidden views if they are not part of the layout
            let view = subviews[i]
            if view.isHidden && !((view as? UniLayoutView)?.layoutProperties.hiddenTakesSpace ?? false) {
                continue
            }
            
            // Continue with the others
            let size = subviewSizes[i]
            var x = padding.left
            var nextY = y
            if let viewLayoutProperties = (view as? UniLayoutView)?.layoutProperties {
                x += viewLayoutProperties.margin.left
                y += viewLayoutProperties.margin.top
                if adjustFrames {
                    x += (paddedSize.width - viewLayoutProperties.margin.left - viewLayoutProperties.margin.right - size.width) * viewLayoutProperties.horizontalGravity
                }
                measuredSize.width = max(measuredSize.width, x + size.width + viewLayoutProperties.margin.right)
                nextY = y + size.height + viewLayoutProperties.margin.bottom
            } else {
                measuredSize.width = max(measuredSize.width, x + size.width)
                nextY = y + size.height
            }
            if adjustFrames {
                UniLayout.setFrame(view: view, frame: CGRect(x: x, y: y, width: size.width, height: size.height))
            }
            measuredSize.height = max(measuredSize.height, nextY)
            y = nextY
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

    @discardableResult internal func performHorizontalLayout(sizeSpec: CGSize, widthSpec: UniMeasureSpec, heightSpec: UniMeasureSpec, adjustFrames: Bool) -> CGSize {
        // Determine available size without padding
        var paddedSize = CGSize(width: max(0, sizeSpec.width - padding.left - padding.right), height: max(0, sizeSpec.height - padding.top - padding.bottom))
        var measuredSize = CGSize(width: padding.left, height: padding.top)
        if widthSpec == .unspecified {
            paddedSize.width = 0xFFFFFF
        }
        if heightSpec == .unspecified {
            paddedSize.height = 0xFFFFFF
        }
        
        // Measure the views without any weight
        var subviewSizes: [CGSize] = []
        var totalWeight: CGFloat = 0
        var remainingWidth = paddedSize.width
        var totalMinWidthForWeight: CGFloat = 0
        for view in subviews {
            // Skip hidden views if they are not part of the layout
            if view.isHidden && !((view as? UniLayoutView)?.layoutProperties.hiddenTakesSpace ?? false) {
                subviewSizes.append(CGSize.zero)
                continue
            }
            
            // Skip views with weight, they will go in the second phase
            if let viewLayoutProperties = (view as? UniLayoutView)?.layoutProperties {
                if viewLayoutProperties.weight > 0 {
                    totalWeight += viewLayoutProperties.weight
                    remainingWidth -= viewLayoutProperties.margin.left + viewLayoutProperties.margin.right + viewLayoutProperties.minWidth
                    totalMinWidthForWeight += viewLayoutProperties.minWidth
                    subviewSizes.append(CGSize.zero)
                    continue
                }
            }
            
            // Perform measure and update remaining width
            var limitHeight = paddedSize.height
            if let viewLayoutProperties = (view as? UniLayoutView)?.layoutProperties {
                remainingWidth -= viewLayoutProperties.margin.left + viewLayoutProperties.margin.right
                limitHeight -= viewLayoutProperties.margin.top + viewLayoutProperties.margin.bottom
            }
            let result = UniLayout.measure(view: view, sizeSpec: CGSize(width: remainingWidth, height: limitHeight), parentWidthSpec: widthSpec, parentHeightSpec: heightSpec, forceViewWidthSpec: .unspecified, forceViewHeightSpec: .unspecified)
            remainingWidth = max(0, remainingWidth - result.width)
            subviewSizes.append(result)
        }
        
        // Measure the remaining views with weight
        remainingWidth += totalMinWidthForWeight
        for i in 0..<min(subviews.count, subviewSizes.count) {
            // Skip hidden views if they are not part of the layout
            let view = subviews[i]
            if view.isHidden && !((view as? UniLayoutView)?.layoutProperties.hiddenTakesSpace ?? false) {
                continue
            }
            
            // Continue with views with weight
            if let viewLayoutProperties = (view as? UniLayoutView)?.layoutProperties {
                if viewLayoutProperties.weight > 0 {
                    let forceViewWidthSpec: UniMeasureSpec = widthSpec == .exactSize ? .exactSize : .unspecified
                    let result = UniLayout.measure(view: view, sizeSpec: CGSize(width: remainingWidth * viewLayoutProperties.weight / totalWeight, height: paddedSize.height - viewLayoutProperties.margin.top - viewLayoutProperties.margin.bottom), parentWidthSpec: widthSpec, parentHeightSpec: heightSpec, forceViewWidthSpec: forceViewWidthSpec, forceViewHeightSpec: .unspecified)
                    remainingWidth = max(0, remainingWidth - result.width)
                    totalWeight -= viewLayoutProperties.weight
                    subviewSizes[i] = result
                }
            }
        }
        
        // Start doing layout
        var x = padding.left
        for i in 0..<min(subviews.count, subviewSizes.count) {
            // Skip hidden views if they are not part of the layout
            let view = subviews[i]
            if view.isHidden && !((view as? UniLayoutView)?.layoutProperties.hiddenTakesSpace ?? false) {
                continue
            }
            
            // Continue with the others
            let size = subviewSizes[i]
            var y = padding.top
            var nextX = x
            if let viewLayoutProperties = (view as? UniLayoutView)?.layoutProperties {
                x += viewLayoutProperties.margin.left
                y += viewLayoutProperties.margin.top
                if adjustFrames {
                    y += (paddedSize.height - viewLayoutProperties.margin.top - viewLayoutProperties.margin.bottom - size.height) * viewLayoutProperties.verticalGravity
                }
                measuredSize.height = max(measuredSize.height, y + size.height + viewLayoutProperties.margin.bottom)
                nextX = x + size.width + viewLayoutProperties.margin.right
            } else {
                measuredSize.height = max(measuredSize.height, y + size.height)
                nextX = x + size.width
            }
            if adjustFrames {
                UniLayout.setFrame(view: view, frame: CGRect(x: x, y: y, width: size.width, height: size.height))
            }
            measuredSize.width = max(measuredSize.width, nextX)
            x = nextX
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
        if orientation == .vertical {
            return performVerticalLayout(sizeSpec: sizeSpec, widthSpec: widthSpec, heightSpec: heightSpec, adjustFrames: false)
        }
        return performHorizontalLayout(sizeSpec: sizeSpec, widthSpec: widthSpec, heightSpec: heightSpec, adjustFrames: false)
    }
    
    open override func layoutSubviews() {
        if orientation == .vertical {
            performVerticalLayout(sizeSpec: bounds.size, widthSpec: .exactSize, heightSpec: .exactSize, adjustFrames: true)
        } else {
            performHorizontalLayout(sizeSpec: bounds.size, widthSpec: .exactSize, heightSpec: .exactSize, adjustFrames: true)
        }
    }
    
    open override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
        return measuredSize(sizeSpec: targetSize, widthSpec: horizontalFittingPriority == UILayoutPriorityRequired ? UniMeasureSpec.limitSize : UniMeasureSpec.unspecified, heightSpec: verticalFittingPriority == UILayoutPriorityRequired ? UniMeasureSpec.limitSize : UniMeasureSpec.unspecified)
    }
 
    
    // ---
    // MARK: Improve layout needed behavior
    // ---

    open override func willRemoveSubview(_ subview: UIView) {
        UniLayout.setNeedsLayout(view: self)
    }
    
    open override func didAddSubview(_ subview: UIView) {
        UniLayout.setNeedsLayout(view: self)
    }

}
