//
//  UniTextView.swift
//  UniLayout Pod
//
//  Library view: a view with simple text
//  Extends UILabel to support properties for UniLayout containers, padding and defaults to multiple lines
//

import UIKit

public class UniTextView: UILabel, UniLayoutView, UniLayoutPaddedView {

    // ---
    // MARK: Members
    // ---

    public var layoutProperties = UniLayoutProperties()
    public var padding = UIEdgeInsets.zero

    
    // ---
    // MARK: Hook layout into text changes
    // ---
    
    public override var text: String? {
        set {
            super.text = newValue
            setNeedsLayout()
        }
        get { return super.text }
    }
    

    // ---
    // MARK: Initialization
    // ---

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        numberOfLines = 0
    }
    
    
    // ---
    // MARK: Custom layout
    // ---

    public func measuredSize(sizeSpec: CGSize, widthSpec: UniMeasureSpec, heightSpec: UniMeasureSpec) -> CGSize {
        let paddedSize = CGSize(width: max(0, sizeSpec.width - padding.left - padding.right), height: max(0, sizeSpec.height - padding.top - padding.bottom))
        var result = super.systemLayoutSizeFitting(paddedSize, withHorizontalFittingPriority: widthSpec == .unspecified ? UILayoutPriorityFittingSizeLevel : UILayoutPriorityRequired, verticalFittingPriority: heightSpec == .unspecified ? UILayoutPriorityFittingSizeLevel : UILayoutPriorityRequired)
        result.width += padding.left + padding.right
        result.height += padding.top + padding.bottom
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

    public override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
        return measuredSize(sizeSpec: targetSize, widthSpec: horizontalFittingPriority == UILayoutPriorityRequired ? UniMeasureSpec.limitSize : UniMeasureSpec.unspecified, heightSpec: verticalFittingPriority == UILayoutPriorityRequired ? UniMeasureSpec.limitSize : UniMeasureSpec.unspecified)
    }
    
    public override func drawText(in rect: CGRect) {
        super.drawText(in: UIEdgeInsetsInsetRect(rect, padding))
    }
    
    public override func setNeedsLayout() {
        super.setNeedsLayout()
        if superview is UniLayoutView {
            superview?.setNeedsLayout()
        }
    }

}
