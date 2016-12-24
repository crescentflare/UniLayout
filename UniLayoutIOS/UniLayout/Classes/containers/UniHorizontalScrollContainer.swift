//
//  UniHorizontalScrollContainer.swift
//  UniLayout Pod
//
//  Library container: a view container providing horizontal scrolling
//  Contains a single element which can be horizontally scrolled within the container
//

import UIKit

open class UniHorizontalScrollContainer: UIScrollView, UniLayoutView, UniLayoutPaddedView {
    
    // ---
    // MARK: Members
    // ---

    public var layoutProperties = UniLayoutProperties()
    public var fillContent: Bool = false
    public var padding = UIEdgeInsets.zero
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
        var measuredContentSize = CGSize.zero
        if let view = _contentView {
            if !view.isHidden || ((view as? UniLayoutView)?.layoutProperties.hiddenTakesSpace ?? false) {
                var filledWidth = paddedSize.width
                var limitHeight = paddedSize.height
                if let viewLayoutProperties = (view as? UniLayoutView)?.layoutProperties {
                    filledWidth -= viewLayoutProperties.margin.left + viewLayoutProperties.margin.right
                    limitHeight -= viewLayoutProperties.margin.top + viewLayoutProperties.margin.bottom
                }
                measuredContentSize = UniView.uniMeasure(view: view, sizeSpec: CGSize(width: 0xFFFFFF, height: limitHeight), parentWidthSpec: .unspecified, parentHeightSpec: heightSpec, forceViewWidthSpec: .unspecified, forceViewHeightSpec: .unspecified)
                if fillContent && heightSpec == .exactSize && measuredContentSize.width < filledWidth {
                    measuredContentSize.width = filledWidth
                }
            }
        }
        
        // Start doing layout
        if let view = _contentView {
            if !view.isHidden || ((view as? UniLayoutView)?.layoutProperties.hiddenTakesSpace ?? false) {
                var x = padding.left
                var y = padding.top
                if let viewLayoutProperties = (view as? UniLayoutView)?.layoutProperties {
                    x += viewLayoutProperties.margin.left
                    y += viewLayoutProperties.margin.top
                    if adjustFrames {
                        x += (paddedSize.width - viewLayoutProperties.margin.left - viewLayoutProperties.margin.right - measuredContentSize.width) * viewLayoutProperties.horizontalGravity
                        y += (paddedSize.height - viewLayoutProperties.margin.top - viewLayoutProperties.margin.bottom - measuredContentSize.height) * viewLayoutProperties.verticalGravity
                    }
                    measuredSize.width = max(measuredSize.width, x + measuredContentSize.width + viewLayoutProperties.margin.right)
                    measuredSize.height = max(measuredSize.height, y + measuredContentSize.height + viewLayoutProperties.margin.bottom)
                } else {
                    measuredSize.width = max(measuredSize.width, x + measuredContentSize.width)
                    measuredSize.height = max(measuredSize.height, y + measuredContentSize.height)
                }
                if adjustFrames {
                    view.frame = CGRect(x: x, y: y, width: measuredContentSize.width, height: measuredContentSize.height)
                }
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
