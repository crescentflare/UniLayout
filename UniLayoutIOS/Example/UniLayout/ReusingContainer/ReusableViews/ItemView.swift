//
//  ItemView.swift
//  UniLayout Example
//
//  A reusable item view in the list
//

import UIKit
import UniLayout

class ItemView: UniLinearContainer {
    
    // --
    // MARK: Members
    // --

    private var container = UniLinearContainer()
    private var titleView = UniTextView()
    private var additionalView = UniTextView()
    private var valueView = UniTextView()
    
    
    // --
    // MARK: Change values
    // --

    var title: String? {
        didSet {
            titleView.text = title
            titleView.isHidden = title?.count == 0
        }
    }
    
    var additional: String? {
        didSet {
            additionalView.text = additional
            additionalView.isHidden = additional?.count == 0
        }
    }
    
    var value: String? {
        didSet {
            valueView.text = value
            valueView.isHidden = value?.count == 0
        }
    }
    
    
    // --
    // MARK: Initialization
    // --

    override init(frame : CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    func initialize() {
        // Set orientation and padding
        orientation = .horizontal
        padding = UIEdgeInsetsMake(4, 8, 4, 8)
        layoutProperties.minHeight = 50
        
        // Add and configure nested container
        container.orientation = .vertical
        container.layoutProperties.width = 0
        container.layoutProperties.weight = 1
        addSubview(container)
        
        // Add and configure title and additional views, vertically aligned within the secondary container
        titleView.font = UIFont.boldSystemFont(ofSize: 17)
        container.addSubview(titleView)
        additionalView.font = UIFont.systemFont(ofSize: 15)
        container.addSubview(additionalView)
        
        // Add and configure the value view
        valueView.layoutProperties.margin.left = 4
        valueView.layoutProperties.verticalGravity = 0.5
        valueView.font = UIFont.boldSystemFont(ofSize: 17)
        addSubview(valueView)
    }
    
}
