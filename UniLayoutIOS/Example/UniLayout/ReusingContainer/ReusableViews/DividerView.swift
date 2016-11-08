//
//  DividerView.swift
//  UniLayout Example
//
//  A reusable divider view for dividing sections
//

import UIKit
import UniLayout

class DividerView: UniFrameContainer {
    
    // --
    // MARK: Members
    // --

    private var lineView = UniView()
    
    
    // --
    // MARK: Initialization
    // --

    override init(frame : CGRect) {
        super.init(frame: frame)
        initialize(bottom: false)
    }
    
    init(bottom: Bool) {
        super.init(frame: CGRect.zero)
        initialize(bottom: bottom)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize(bottom: false)
    }
    
    func initialize(bottom: Bool) {
        // Set height
        layoutProperties.minHeight = 6
        
        // Add and configure thick line view
        lineView.layoutProperties.width = UniLayoutProperties.stretchToParent
        lineView.layoutProperties.height = 1
        lineView.backgroundColor = UIColor(white: 0.75, alpha: 1)
        lineView.layoutProperties.verticalGravity = bottom ? 0 : 1
        addSubview(lineView)
    }
    
}
