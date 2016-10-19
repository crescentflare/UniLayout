//
//  UniLinearContainer.swift
//  UniLayout Pod
//
//  Library container: a vertically or horizontally aligned view container
//  Stacks views below or to the right of each other
//

import UIKit

enum UniLinearContainerOrientation: String {
    
    case vertical = "vertical"
    case horizontal = "horizontal"
    
}

class UniLinearContainer: UIView, UniLayoutView {

    // ---
    // MARK: Members
    // ---
    
    var layoutProperties = UniLayoutProperties()
    var orientation = UniLinearContainerOrientation.vertical

    
    // ---
    // MARK: Custom layout
    // ---

    @discardableResult internal func performVerticalLayout(sizeSpec: CGSize, widthSpec: UniMeasureSpec, heightSpec: UniMeasureSpec, adjustFrames: Bool) -> CGSize {
        // Determine available size without padding
        var paddedSize = CGSize(width: max(0, sizeSpec.width - layoutProperties.padding.left - layoutProperties.padding.right), height: max(0, sizeSpec.height - layoutProperties.padding.top - layoutProperties.padding.bottom))
        var measuredSize = CGSize(width: layoutProperties.padding.left, height: layoutProperties.padding.top)
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
            
            // Adjust size limitations based on layout property restrictions
            var viewWidthSpec = widthSpec == .unspecified ? UniMeasureSpec.unspecified : UniMeasureSpec.limitSize
            var viewHeightSpec = heightSpec == .unspecified ? UniMeasureSpec.unspecified : UniMeasureSpec.limitSize
            var viewSizeSpec = CGSize(width: paddedSize.width, height: remainingHeight)
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
                if viewLayoutProperties.height >= 0 {
                    viewSizeSpec.height = min(viewSizeSpec.height, max(viewLayoutProperties.minHeight, min(viewLayoutProperties.height, viewLayoutProperties.maxHeight)))
                    viewHeightSpec = .exactSize
                } else {
                    viewSizeSpec.height = min(viewSizeSpec.height, max(viewLayoutProperties.minHeight, viewLayoutProperties.maxHeight))
                }
            }
            
            // Obtain final size and make final adjustments per view
            var result = UniView.obtainMeasuredSize(ofView: view, sizeSpec: viewSizeSpec, widthSpec: viewWidthSpec, heightSpec: viewHeightSpec)
            if let viewLayoutProperties = (view as? UniLayoutView)?.layoutProperties {
                result.width = min(viewSizeSpec.width, max(viewLayoutProperties.minWidth, result.width))
                result.height = min(viewSizeSpec.height, max(viewLayoutProperties.minHeight, result.height))
                remainingHeight -= viewLayoutProperties.margin.top + viewLayoutProperties.margin.bottom
            } else {
                result.width = min(viewSizeSpec.width, result.width)
                result.height = min(viewSizeSpec.height, result.height)
            }
            subviewSizes.append(result)
            remainingHeight -= result.height
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
                    // Adjust size limitations based on layout property restrictions
                    let wantHeight = remainingHeight * viewLayoutProperties.weight / totalWeight
                    var viewWidthSpec = widthSpec == .unspecified ? UniMeasureSpec.unspecified : UniMeasureSpec.limitSize
                    var viewHeightSpec = heightSpec == .unspecified ? UniMeasureSpec.unspecified : UniMeasureSpec.limitSize
                    var viewSizeSpec = CGSize(width: paddedSize.width, height: remainingHeight)
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
                    viewSizeSpec.height = min(viewSizeSpec.height, max(viewLayoutProperties.minHeight, min(wantHeight, viewLayoutProperties.maxHeight)))
                    viewHeightSpec = .exactSize

                    // Obtain final size and make final adjustments per view
                    var result = UniView.obtainMeasuredSize(ofView: view, sizeSpec: viewSizeSpec, widthSpec: viewWidthSpec, heightSpec: viewHeightSpec)
                    if !adjustFrames {
                        result.height = 0
                    }
                    if let viewLayoutProperties = (view as? UniLayoutView)?.layoutProperties {
                        result.width = min(viewSizeSpec.width, max(viewLayoutProperties.minWidth, result.width))
                        result.height = min(viewSizeSpec.height, max(viewLayoutProperties.minHeight, result.height))
                        remainingHeight -= viewLayoutProperties.margin.top + viewLayoutProperties.margin.bottom
                    } else {
                        result.width = min(viewSizeSpec.width, result.width)
                        result.height = min(viewSizeSpec.height, result.height)
                    }
                    subviewSizes[i] = result
                    remainingHeight -= result.height
                    totalWeight -= viewLayoutProperties.weight
                }
            }
        }
        
        // Start doing layout
        var y = layoutProperties.padding.top
        for i in 0..<min(subviews.count, subviewSizes.count) {
            // Skip hidden views if they are not part of the layout
            let view = subviews[i]
            if view.isHidden && !((view as? UniLayoutView)?.layoutProperties.hiddenTakesSpace ?? false) {
                continue
            }
            
            // Continue with the others
            let size = subviewSizes[i]
            var x = layoutProperties.padding.left
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
                view.frame = CGRect(x: x, y: y, width: size.width, height: size.height)
            }
            measuredSize.height = max(measuredSize.height, nextY)
            y = nextY
        }

        // Adjust final measure with padding and limitations
        measuredSize.width += layoutProperties.padding.right
        measuredSize.height += layoutProperties.padding.bottom
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
        var paddedSize = CGSize(width: max(0, sizeSpec.width - layoutProperties.padding.left - layoutProperties.padding.right), height: max(0, sizeSpec.height - layoutProperties.padding.top - layoutProperties.padding.bottom))
        var measuredSize = CGSize(width: layoutProperties.padding.left, height: layoutProperties.padding.top)
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
            
            // Adjust size limitations based on layout property restrictions
            var viewWidthSpec = widthSpec == .unspecified ? UniMeasureSpec.unspecified : UniMeasureSpec.limitSize
            var viewHeightSpec = heightSpec == .unspecified ? UniMeasureSpec.unspecified : UniMeasureSpec.limitSize
            var viewSizeSpec = CGSize(width: remainingWidth, height: paddedSize.height)
            if let viewLayoutProperties = (view as? UniLayoutView)?.layoutProperties {
                viewSizeSpec.width = max(0, viewSizeSpec.width - viewLayoutProperties.margin.left - viewLayoutProperties.margin.right)
                viewSizeSpec.height = max(0, viewSizeSpec.height - viewLayoutProperties.margin.top - viewLayoutProperties.margin.bottom)
                if viewLayoutProperties.width >= 0 {
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
            if let viewLayoutProperties = (view as? UniLayoutView)?.layoutProperties {
                result.width = min(viewSizeSpec.width, max(viewLayoutProperties.minWidth, result.width))
                result.height = min(viewSizeSpec.height, max(viewLayoutProperties.minHeight, result.height))
                remainingWidth -= viewLayoutProperties.margin.left + viewLayoutProperties.margin.right
            } else {
                result.width = min(viewSizeSpec.width, result.width)
                result.height = min(viewSizeSpec.height, result.height)
            }
            subviewSizes.append(result)
            remainingWidth -= result.width
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
                    // Adjust size limitations based on layout property restrictions
                    let wantWidth = remainingWidth * viewLayoutProperties.weight / totalWeight
                    var viewWidthSpec = widthSpec == .unspecified ? UniMeasureSpec.unspecified : UniMeasureSpec.limitSize
                    var viewHeightSpec = heightSpec == .unspecified ? UniMeasureSpec.unspecified : UniMeasureSpec.limitSize
                    var viewSizeSpec = CGSize(width: remainingWidth, height: paddedSize.height)
                    viewSizeSpec.width = max(0, viewSizeSpec.width - viewLayoutProperties.margin.left - viewLayoutProperties.margin.right)
                    viewSizeSpec.height = max(0, viewSizeSpec.height - viewLayoutProperties.margin.top - viewLayoutProperties.margin.bottom)
                    viewSizeSpec.width = min(viewSizeSpec.width, max(viewLayoutProperties.minWidth, min(wantWidth, viewLayoutProperties.maxWidth)))
                    viewWidthSpec = .exactSize
                    if heightSpec == .exactSize && viewLayoutProperties.height == UniLayoutProperties.stretchToParent {
                        viewSizeSpec.height = min(viewSizeSpec.height, max(viewLayoutProperties.minHeight, viewLayoutProperties.maxHeight))
                        viewHeightSpec = .exactSize
                    } else if viewLayoutProperties.height >= 0 {
                        viewSizeSpec.height = min(viewSizeSpec.height, max(viewLayoutProperties.minHeight, min(viewLayoutProperties.height, viewLayoutProperties.maxHeight)))
                        viewHeightSpec = .exactSize
                    } else {
                        viewSizeSpec.height = min(viewSizeSpec.height, max(viewLayoutProperties.minHeight, viewLayoutProperties.maxHeight))
                    }
                    
                    // Obtain final size and make final adjustments per view
                    var result = UniView.obtainMeasuredSize(ofView: view, sizeSpec: viewSizeSpec, widthSpec: viewWidthSpec, heightSpec: viewHeightSpec)
                    if !adjustFrames {
                        result.width = 0
                    }
                    if let viewLayoutProperties = (view as? UniLayoutView)?.layoutProperties {
                        result.width = min(viewSizeSpec.width, max(viewLayoutProperties.minWidth, result.width))
                        result.height = min(viewSizeSpec.height, max(viewLayoutProperties.minHeight, result.height))
                        remainingWidth -= viewLayoutProperties.margin.left + viewLayoutProperties.margin.right
                    } else {
                        result.width = min(viewSizeSpec.width, result.width)
                        result.height = min(viewSizeSpec.height, result.height)
                    }
                    subviewSizes[i] = result
                    remainingWidth -= result.width
                    totalWeight -= viewLayoutProperties.weight
                }
            }
        }
        
        // Start doing layout
        var x = layoutProperties.padding.left
        for i in 0..<min(subviews.count, subviewSizes.count) {
            // Skip hidden views if they are not part of the layout
            let view = subviews[i]
            if view.isHidden && !((view as? UniLayoutView)?.layoutProperties.hiddenTakesSpace ?? false) {
                continue
            }
            
            // Continue with the others
            let size = subviewSizes[i]
            var y = layoutProperties.padding.top
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
                view.frame = CGRect(x: x, y: y, width: size.width, height: size.height)
            }
            measuredSize.width = max(measuredSize.width, nextX)
            x = nextX
        }
        
        // Adjust final measure with padding and limitations
        measuredSize.width += layoutProperties.padding.right
        measuredSize.height += layoutProperties.padding.bottom
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
        if orientation == .vertical {
            return performVerticalLayout(sizeSpec: sizeSpec, widthSpec: widthSpec, heightSpec: heightSpec, adjustFrames: false)
        }
        return performHorizontalLayout(sizeSpec: sizeSpec, widthSpec: widthSpec, heightSpec: heightSpec, adjustFrames: false)
    }
    
    internal override func layoutSubviews() {
        if orientation == .vertical {
            performVerticalLayout(sizeSpec: frame.size, widthSpec: .exactSize, heightSpec: .exactSize, adjustFrames: true)
        } else {
            performHorizontalLayout(sizeSpec: frame.size, widthSpec: .exactSize, heightSpec: .exactSize, adjustFrames: true)
        }
    }
    
    internal override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
        return measuredSize(sizeSpec: targetSize, widthSpec: horizontalFittingPriority == UILayoutPriorityRequired ? UniMeasureSpec.limitSize : UniMeasureSpec.unspecified, heightSpec: verticalFittingPriority == UILayoutPriorityRequired ? UniMeasureSpec.limitSize : UniMeasureSpec.unspecified)
    }
    
}
