//
//  SectionView.swift
//  UniLayout Example
//
//  A reusable section view
//

import UIKit
import UniLayout

class SectionView: UniFrameContainer {
    
    // --
    // MARK: Members
    // --

    private var textView = UniTextView()
    

    // --
    // MARK: Change values
    // --

    var text: String? {
        didSet {
            textView.text = text
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
        // Set padding
        padding = UIEdgeInsets.init(top: 4, left: 8, bottom: 0, right: 8)
        
        // Add and configure text view
        textView.font = UIFont.boldSystemFont(ofSize: 17)
        addSubview(textView)
    }
    
}
