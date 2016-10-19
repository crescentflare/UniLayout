//
//  UniHorizontalScrollContainer.swift
//  UniLayout Pod
//
//  Library container: a view container providing horizontal scrolling
//  Contains a single element which can be horizontally scrolled within the container
//

import UIKit

class UniHorizontalScrollContainer: UIScrollView, UniLayoutView {
    
    // ---
    // MARK: Members
    // ---

    var layoutProperties = UniLayoutProperties()
    private var _contentView: UIView?
    var fillContent: Bool = false


    // ---
    // MARK: Set content view
    // ---

    var contentView: UIView? {
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
        var paddedSize = CGSize(width: max(0, sizeSpec.width - layoutProperties.padding.left - layoutProperties.padding.right), height: max(0, sizeSpec.height - layoutProperties.padding.top - layoutProperties.padding.bottom))
        var measuredSize = CGSize(width: layoutProperties.padding.left, height: layoutProperties.padding.top)
        if widthSpec == .unspecified {
            paddedSize.width = 0xFFFFFF
        }
        if heightSpec == .unspecified {
            paddedSize.height = 0xFFFFFF
        }
        
        // Iterate over subviews and layout each one
        if let view = _contentView {
            if !view.isHidden || ((view as? UniLayoutView)?.layoutProperties.hiddenTakesSpace ?? false) {
                // Adjust size limitations based on layout property restrictions
                var viewWidthSpec = UniMeasureSpec.unspecified
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
                var x = layoutProperties.padding.left
                var y = layoutProperties.padding.top
                if let viewLayoutProperties = (view as? UniLayoutView)?.layoutProperties {
                    result.width = max(viewLayoutProperties.minWidth, result.width)
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
                    result.height = min(viewSizeSpec.height, result.height)
                    measuredSize.width = max(measuredSize.width, x + result.width)
                    measuredSize.height = max(measuredSize.height, y + result.height)
                }
                if adjustFrames {
                    view.frame = CGRect(x: x, y: y, width: result.width, height: result.height)
                }
            }
        }
        
        // Adjust final measure with padding and limitations
        measuredSize.width += layoutProperties.padding.right
        measuredSize.height += layoutProperties.padding.bottom
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
    
    internal func measuredSize(sizeSpec: CGSize, widthSpec: UniMeasureSpec, heightSpec: UniMeasureSpec) -> CGSize {
        return performLayout(sizeSpec: sizeSpec, widthSpec: widthSpec, heightSpec: heightSpec, adjustFrames: false)
    }
    
    internal override func layoutSubviews() {
        performLayout(sizeSpec: frame.size, widthSpec: .exactSize, heightSpec: .exactSize, adjustFrames: true)
    }
    
    internal override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
        return measuredSize(sizeSpec: targetSize, widthSpec: horizontalFittingPriority == UILayoutPriorityRequired ? UniMeasureSpec.limitSize : UniMeasureSpec.unspecified, heightSpec: verticalFittingPriority == UILayoutPriorityRequired ? UniMeasureSpec.limitSize : UniMeasureSpec.unspecified)
    }
   
}
