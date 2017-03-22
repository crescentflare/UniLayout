//
//  UniReusableView.swift
//  UniLayout Pod
//
//  Library view: a reusable view container
//  Extends UITableViewCell to support automatic height calculation and layout based on a UniLayoutView class
//

import UIKit

/// A UniLayout enabled UITableViewCell, used in combination with a UniLayout container as the custom view
open class UniReusableView : UITableViewCell {
    
    // --
    // MARK: Members
    // --
    
    let mainContainer = UniLinearContainer()
    let contentContainer = UniFrameContainer()
    let accessoryContainer = UniFrameContainer()
    public let dividerLine = UniReusableDividerView()
    private let coreContainer = UniLinearContainer()
    private var _view: UIView? = nil
    private var _accessoryView: UIView? = nil
    private var _simulatedAccessoryType = UITableViewCellAccessoryType.none
    private var _simulatingSpacing = true
    
    
    // --
    // MARK: Set custom view
    // --
    
    public var view: UniLayoutView? {
        set {
            _view?.removeFromSuperview()
            _view = newValue as? UIView
            if _view != nil {
                view?.layoutProperties.width = UniLayoutProperties.stretchToParent
                contentContainer.addSubview(_view!)
            }
        }
        get { return _view as? UniLayoutView }
    }
    
    
    // --
    // MARK: Remove simulation of padding and height
    // --
    
    open var isSimulatingSpacing: Bool {
        set {
            _simulatingSpacing = newValue
            if _simulatingSpacing {
                mainContainer.padding = UIEdgeInsetsMake(4, 8, 4, 8)
                mainContainer.layoutProperties.minHeight = 44
            } else {
                mainContainer.padding = UIEdgeInsetsMake(0, 0, 0, 0)
                mainContainer.layoutProperties.minHeight = 0
            }
        }
        get { return _simulatingSpacing }
    }
    

    // --
    // MARK: Set custom accessory view
    // --
    
    open override var accessoryView: UIView? {
        set {
            _accessoryView?.removeFromSuperview()
            _accessoryView = newValue
            if _accessoryView != nil {
                accessoryContainer.addSubview(_accessoryView!)
            }
            accessoryContainer.isHidden = _accessoryView == nil
        }
        get { return _accessoryView }
    }

    // --
    // MARK: Override and simulate disclosure indicator
    // --
    
    open override var accessoryType: UITableViewCellAccessoryType {
        set {
            _simulatedAccessoryType = newValue
            if _simulatedAccessoryType == .disclosureIndicator {
                let imageView = UniImageView()
                imageView.image = UniAssets.chevron
                accessoryView = imageView
            }
        }
        get { return _simulatedAccessoryType }
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
        // Set up core container
        coreContainer.orientation = .vertical
        contentView.addSubview(coreContainer)
        
        // Set up and add the main container view
        mainContainer.layoutProperties.width = UniLayoutProperties.stretchToParent
        mainContainer.orientation = .horizontal
        mainContainer.padding = UIEdgeInsetsMake(4, 8, 4, 8)
        mainContainer.layoutProperties.minHeight = 44
        coreContainer.addSubview(mainContainer)
        
        // Set up and add the divider line view
        dividerLine.layoutProperties.width = UniLayoutProperties.stretchToParent
        dividerLine.layoutProperties.height = 1 / UIScreen.main.scale
        dividerLine.layoutProperties.margin.left = 16
        dividerLine.color = UIColor(white: 0.8, alpha: 1)
        coreContainer.addSubview(dividerLine)
        
        // Set up and add the content container view
        contentContainer.layoutProperties.width = 0
        contentContainer.layoutProperties.weight = 1
        contentContainer.layoutProperties.verticalGravity = 0.5
        mainContainer.addSubview(contentContainer)
        
        // Set up and add the accessory container view
        accessoryContainer.layoutProperties.margin.left = 6
        accessoryContainer.layoutProperties.margin.right = 8
        accessoryContainer.layoutProperties.minWidth = 12
        accessoryContainer.layoutProperties.horizontalGravity = 1
        accessoryContainer.layoutProperties.verticalGravity = 0.5
        accessoryContainer.isHidden = true
        mainContainer.addSubview(accessoryContainer)
    }
    
    
    // --
    // MARK: Layout
    // --
    
    open override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
        var result = coreContainer.measuredSize(sizeSpec: targetSize, widthSpec: .exactSize, heightSpec: .unspecified)
        result.height = max(coreContainer.layoutProperties.minHeight, min(result.height, coreContainer.layoutProperties.maxHeight))
        return result
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        UniLayout.setFrame(view: coreContainer, frame: CGRect(x: 0, y: 0, width: contentView.bounds.width, height: contentView.bounds.height))
        if selectedBackgroundView != nil {
            UniLayout.setFrame(view: selectedBackgroundView!, frame: CGRect(x: 0, y: 0, width: contentView.bounds.width, height: contentView.bounds.height))
        }
    }
    
}

/// A helper view for the UniReusableView to show as a divider which keeps its background color, even when selected
public class UniReusableDividerView : UniView {
    
    private var fillColor: UIColor?
    
    public var color: UIColor? {
        set {
            fillColor = newValue
        }
        get {
            return fillColor
        }
    }
    
    public override func draw(_ rect: CGRect) {
        if let fillColor = fillColor {
            if let context = UIGraphicsGetCurrentContext() {
                context.setFillColor(fillColor.cgColor)
                context.fill(self.bounds)
            }
        }
    }
    
}
