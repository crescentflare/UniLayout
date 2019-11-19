//
//  LayoutBuilder.swift
//  Provides an easy structure for manually creating layouts
//

import UIKit
@testable import UniLayout

class LayoutBuilder {
    
    // --
    // MARK: Members
    // --

    private var view: UIView
    

    // --
    // MARK: Initialization
    // --

    private init(view: UIView) {
        self.view = view
    }
    
    class func start(forViewController: TestViewController, _ build: (_ builder: LayoutBuilder) -> Void) {
        let builder = LayoutBuilder(view: forViewController.view)
        build(builder)
    }


    // --
    // MARK: Add view components
    // --

    func addLabel(text: String) {
        // Create label
        let previousView = view.subviews.last
        let label = TestLabelView()
        label.text = text
        label.accessibilityIdentifier = text
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        
        // Add constraints
        var allConstraints = [NSLayoutConstraint]()
        if let leftView = previousView {
            let views = ["leftView": leftView, "label": label]
            allConstraints += NSLayoutConstraint.constraints(withVisualFormat: "H:[leftView]-[label]", options: [], metrics: nil, views: views)
            allConstraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|-[label]", options: [], metrics: nil, views: views)
        } else {
            let views = ["label": label]
            allConstraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-[label]", options: [], metrics: nil, views: views)
            allConstraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|-[label]", options: [], metrics: nil, views: views)
        }
        NSLayoutConstraint.activate(allConstraints)
    }
    
    func addContainer(color: UIColor = .clear, name: String? = nil, _ build: (_ builder: LayoutBuilder) -> Void) {
        // Create container
        let previousView = view.subviews.last
        let container = TestContainerView()
        container.backgroundColor = color
        container.accessibilityIdentifier = name
        container.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(container)

        // Add constraints
        var allConstraints = [NSLayoutConstraint]()
        if let aboveView = previousView {
            let views = ["aboveView": aboveView, "container": container]
            allConstraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-[container]", options: [], metrics: nil, views: views)
            allConstraints += NSLayoutConstraint.constraints(withVisualFormat: "V:[aboveView]-[container]", options: [], metrics: nil, views: views)
        } else {
            let views = ["container": container]
            allConstraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-[container]", options: [], metrics: nil, views: views)
            allConstraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|-[container]", options: [], metrics: nil, views: views)
        }
        NSLayoutConstraint.activate(allConstraints)
        
        // Build layout inside container
        build(LayoutBuilder(view: container))
        
        // Add constraints for adjusting size to contain children
        if let lastView = container.subviews.last {
            let views = ["lastView": lastView]
            var closingConstraints = [NSLayoutConstraint]()
            closingConstraints += NSLayoutConstraint.constraints(withVisualFormat: "H:[lastView]-|", options: [], metrics: nil, views: views)
            closingConstraints += NSLayoutConstraint.constraints(withVisualFormat: "V:[lastView]-|", options: [], metrics: nil, views: views)
            NSLayoutConstraint.activate(closingConstraints)
        }
    }
    
}
