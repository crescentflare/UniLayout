//
//  CustomViews.swift
//  A custom view structure that traces events to the layout analyzer
//

import UIKit
@testable import UniLayout

// --
// MARK: The view controller and root view
// --

class TestViewController: UIViewController {
    
    override func loadView() {
        view = TestRootView()
        view.accessibilityIdentifier = "Root view"
    }
    
}

class TestRootView: UIView {
    
    override var bounds: CGRect {
        didSet {
            LayoutAnalyzer.shared.add(LayoutAnalyzerItem(view: self, type: .changeBounds, value: bounds))
        }
    }
    
    override func layoutSubviews() {
        LayoutAnalyzer.shared.add(LayoutAnalyzerItem(view: self, type: .layoutSubviews))
        super.layoutSubviews()
    }
    
}


// --
// MARK: Custom view components
// --

class TestContainerView: UIView {
    
    override var bounds: CGRect {
        didSet {
            LayoutAnalyzer.shared.add(LayoutAnalyzerItem(view: self, type: .changeBounds, value: bounds))
        }
    }

    override func layoutSubviews() {
        LayoutAnalyzer.shared.add(LayoutAnalyzerItem(view: self, type: .layoutSubviews))
        super.layoutSubviews()
    }
    
}

class TestLabelView: UILabel {
    
    override var text: String? {
        didSet {
            LayoutAnalyzer.shared.add(LayoutAnalyzerItem(view: self, type: .changeText, value: text))
        }
    }
    
    override var bounds: CGRect {
        didSet {
            LayoutAnalyzer.shared.add(LayoutAnalyzerItem(view: self, type: .changeBounds, value: bounds))
        }
    }

    override func layoutSubviews() {
        LayoutAnalyzer.shared.add(LayoutAnalyzerItem(view: self, type: .layoutSubviews))
        super.layoutSubviews()
    }
    
}
