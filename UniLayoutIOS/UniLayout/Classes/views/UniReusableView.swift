//
//  UniReusableView.swift
//  UniLayout Pod
//
//  Library view: a reusable view container
//  Extends UITableViewCell to support automatic height calculation and layout based on a UniLayoutView class
//

import UIKit

open class UniReusableView : UITableViewCell {
    
    // --
    // MARK: Members
    // --
    
    private var dividerLine = UniView()
    private var _view: UIView? = nil
    
    
    // --
    // MARK: Setting values
    // --
    
    public var view: UniLayoutView? {
        set {
            _view?.removeFromSuperview()
            _view = newValue as? UIView
            if _view != nil {
                contentView.addSubview(_view!)
            }
        }
        get { return _view as? UniLayoutView }
    }
    
    public var dividerIsHidden: Bool? {
        set {
            dividerLine.isHidden = newValue ?? false
        }
        get { return dividerLine.isHidden }
    }
    
    
    // --
    // MARK: Initialize
    // --
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    func setupView() {
        // Add a default empty view which will be overwritten later
        let emptyView = UniView()
        emptyView.layoutProperties.width = UniLayoutProperties.stretchToParent
        emptyView.layoutProperties.height = 40
        view = emptyView
        
        // Add the divider line to the container
        dividerLine = UniView()
        dividerLine.layoutProperties.width = UniLayoutProperties.stretchToParent
        dividerLine.layoutProperties.height = 1 / UIScreen.main.scale
        dividerLine.layoutProperties.margin.left = 16
        dividerLine.backgroundColor = UIColor(white: 0.8, alpha: 1)
        addSubview(dividerLine)
    }
    
    
    // --
    // MARK: Layout
    // --
    
    open override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
        var result = CGSize.zero
        if let uniCellView = _view as? UniLayoutView {
            result = uniCellView.measuredSize(sizeSpec: targetSize, widthSpec: .exactSize, heightSpec: .unspecified)
            result.height = max(result.height, uniCellView.layoutProperties.minHeight)
        }
        if !dividerLine.isHidden {
            result.height += dividerLine.layoutProperties.height
        }
        return result
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        if !dividerLine.isHidden {
            _view?.frame = CGRect(x: 0, y: 0, width: contentView.frame.size.width, height: contentView.frame.size.height - dividerLine.layoutProperties.height)
            dividerLine.frame = CGRect(x: dividerLine.layoutProperties.margin.left, y: frame.height - dividerLine.layoutProperties.height, width: frame.width * 2 - dividerLine.layoutProperties.margin.left, height: dividerLine.layoutProperties.height)
        } else {
            _view?.frame = CGRect(x: 0, y: 0, width: contentView.frame.size.width, height: contentView.frame.size.height)
        }
    }
    
}

