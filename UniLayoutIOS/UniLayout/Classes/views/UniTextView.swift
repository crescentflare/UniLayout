//
//  UniTextView.swift
//  UniLayout Pod
//
//  Library view: a view with simple text
//  Extends UILabel to support properties for UniLayout containers, padding and defaults to multiple lines
//

import UIKit

class UniTextView: UILabel, UniLayoutView {

    // ---
    // MARK: Members
    // ---

    var layoutProperties = UniLayoutProperties()
    

    // ---
    // MARK: Initialization
    // ---

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        numberOfLines = 0
    }
    
    
    // ---
    // MARK: Custom layout
    // ---

    internal func measuredSize(sizeSpec: CGSize, widthSpec: UniMeasureSpec, heightSpec: UniMeasureSpec) -> CGSize {
        let paddedSize = CGSize(width: max(0, sizeSpec.width - layoutProperties.padding.left - layoutProperties.padding.right), height: max(0, sizeSpec.height - layoutProperties.padding.top - layoutProperties.padding.bottom))
        var result = super.systemLayoutSizeFitting(paddedSize, withHorizontalFittingPriority: widthSpec == .unspecified ? UILayoutPriorityFittingSizeLevel : UILayoutPriorityRequired, verticalFittingPriority: heightSpec == .unspecified ? UILayoutPriorityFittingSizeLevel : UILayoutPriorityRequired)
        result.width += layoutProperties.padding.left + layoutProperties.padding.right
        result.height += layoutProperties.padding.top + layoutProperties.padding.bottom
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

    internal override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
        return measuredSize(sizeSpec: targetSize, widthSpec: horizontalFittingPriority == UILayoutPriorityRequired ? UniMeasureSpec.limitSize : UniMeasureSpec.unspecified, heightSpec: verticalFittingPriority == UILayoutPriorityRequired ? UniMeasureSpec.limitSize : UniMeasureSpec.unspecified)
    }
    
    internal override func drawText(in rect: CGRect) {
        super.drawText(in: UIEdgeInsetsInsetRect(rect, layoutProperties.padding))
    }

}
