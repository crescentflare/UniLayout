//
//  UniVerticalScrollContainer.swift
//  UniLayout Pod
//
//  Library container: a view container providing vertical scrolling
//  Contains a single element which can be vertically scrolled within the container
//

import UIKit

/// A layout container view used for vertically scrolling the content view
open class UniVerticalScrollContainer: UIScrollView, UniLayoutView, UniLayoutPaddedView {
    
    // ---
    // MARK: Members
    // ---

    public var layoutProperties = UniLayoutProperties()
    public var padding = UIEdgeInsets.zero
    public var fillContent: Bool = false
    private var _backgroundView: UIView?
    private var _contentView: UIView?


    // ---
    // MARK: Set content view
    // ---

    public var contentView: UIView? {
        get {
            return _contentView
        }
        set {
            if _contentView != nil {
                _contentView!.removeFromSuperview()
            }
            _contentView = newValue
            if _contentView != nil {
                addSubview(_contentView!)
            }
        }
    }

    public var backgroundView: UIView? {
        get {
            return _backgroundView
        }
        set {
            if _backgroundView != nil {
                _backgroundView!.removeFromSuperview()
            }
            _backgroundView = newValue
            if _backgroundView != nil {
                insertSubview(_backgroundView!, at: 0)
            }
        }
    }


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
        var checkViews: [UIView] = []
        if _backgroundView != nil {
            checkViews.append(_backgroundView!)
        }
        if _contentView != nil {
            checkViews.append(_contentView!)
        }
        for view in checkViews {
            // Skip hidden views if they are not part of the layout
            if view.isHidden && !((view as? UniLayoutView)?.layoutProperties.hiddenTakesSpace ?? false) && !(view is UIRefreshControl) {
                subviewSizes.append(CGSize.zero)
                continue
            }
            
            // Perform measure
            var limitWidth = paddedSize.width
            var filledHeight = paddedSize.height
            if let viewLayoutProperties = (view as? UniLayoutView)?.layoutProperties {
                limitWidth -= viewLayoutProperties.margin.left + viewLayoutProperties.margin.right
                filledHeight -= viewLayoutProperties.margin.top + viewLayoutProperties.margin.bottom
            }
            var result = UniLayout.measure(view: view, sizeSpec: CGSize(width: limitWidth, height: 0xFFFFFF), parentWidthSpec: widthSpec, parentHeightSpec: .unspecified, forceViewWidthSpec: .unspecified, forceViewHeightSpec: .unspecified)
            if view is UIRefreshControl {
                if widthSpec == .exactSize {
                    result.width = limitWidth
                } else {
                    result.width = 0
                }
            }
            if fillContent && view == _contentView && heightSpec == .exactSize && result.height < filledHeight {
                result.height = filledHeight
            }
            subviewSizes.append(result)
        }
        
        // Start doing layout
        for i in 0..<min(checkViews.count, subviewSizes.count) {
            // Skip hidden views if they are not part of the layout
            let view = checkViews[i]
            if view.isHidden && !((view as? UniLayoutView)?.layoutProperties.hiddenTakesSpace ?? false) && !(view is UIRefreshControl) {
                continue
            }
            
            // Continue with the others
            let size = subviewSizes[i]
            var x = padding.left
            var y = padding.top
            if view is UIRefreshControl {
                y += contentOffset.y
            }
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
                UniLayout.setFrame(view: view, frame: CGRect(x: x, y: y, width: size.width, height: size.height))
            }
        }

        // Adjust final measure with padding and limitations
        measuredSize.width += padding.right
        measuredSize.height += padding.bottom
        if adjustFrames {
            contentSize = CGSize(width: measuredSize.width, height: measuredSize.height)
        }
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
        UniLayout.setNeedsLayout(view: self)
    }
    
    open override func didAddSubview(_ subview: UIView) {
        UniLayout.setNeedsLayout(view: self)
    }

}
