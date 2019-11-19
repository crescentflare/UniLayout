//
//  AutoLayoutTests.swift
//  UniLayout Tests
//
//  Used for analyzing and testing autolayout behavior
//

import UIKit
import XCTest
@testable import UniLayout

@available(iOS 9.0, *)
class AutoLayoutTests: XCTestCase {
    
    // --
    // MARK: Members
    // --
    
    var viewController: TestViewController!


    // --
    // MARK: Lifecycle
    // --
    
    override func setUp() {
        LayoutAnalyzer.shared.clear()
        viewController = TestViewController()
        UIApplication.shared.keyWindow?.rootViewController = viewController
    }


    // --
    // MARK: View controller tests
    // --

    // Testing a plain view controller
    // Not contained in, for example, a navigation controller
    // By default the view is sized to the screen bounds by the key window
    // The size is set when it's added and made visible
    // The status bar is always translucent
    // The view goes also below the status bar and takes up the entire screen
    func testBasicViewControllerView() {
        // Assert the default root view
        XCTAssertEqual(viewController.view.frame, CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        print("Screen bounds are: ", UIScreen.main.bounds)

        // Wait for the layout pass to complete and print out information of layout events
        simpleWait(time: 1)
        LayoutAnalyzer.shared.printEvents()
    }


    // --
    // MARK: Constraint tests
    // --

    // Testing constraints in nested views
    // A container with 2 containers inside, each containing a couple of text views
    // Containers should be sized to fit their content
    // Uses a layout builder class to have a readable test case
    func testConstraints() {
        // Build a layout
        LayoutBuilder.start(forViewController: viewController, { builder in
            builder.addContainer(color: .blue, name: "Main container", { builder in
                builder.addContainer(color: .red, name: "Top container", { builder in
                    builder.addLabel(text: "Text topleft")
                    builder.addLabel(text: "Text topright")
                })
                builder.addContainer(color: .green, name: "Bottom container", { builder in
                    builder.addLabel(text: "Text bottomleft")
                    builder.addLabel(text: "Text bottomright")
                })
            })
        })

        // Wait for the layout pass to complete and print out information of layout events
        simpleWait(time: 0.1)
        LayoutAnalyzer.shared.printEvents()
    }

    
    // --
    // MARK: Helpers
    // --
    
    func simpleWait(time: TimeInterval) {
        let expectation = XCTestExpectation(description: "Wait time is over")
        DispatchQueue.main.asyncAfter(deadline: .now() + time, execute: {
            expectation.fulfill()
        })
        wait(for: [expectation], timeout: 60)
    }
    

    // --
    // MARK: Layout builder
    // --

    class LayoutBuilder {
        
        private var view: UIView
        
        private init(view: UIView) {
            self.view = view
        }
        
        class func start(forViewController: TestViewController, _ build: (_ builder: LayoutBuilder) -> Void) {
            let builder = LayoutBuilder(view: forViewController.view)
            build(builder)
        }

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

    
    // --
    // MARK: Layout analyzer
    // --
    
    class LayoutAnalyzer {
        
        static var shared = LayoutAnalyzer()
        var items = [LayoutAnalyzerItem]()
        
        func clear() {
            items = []
        }
        
        func add(_ item: LayoutAnalyzerItem) {
            items.append(item)
        }
        
        func printEvents() {
            var previousItem: LayoutAnalyzerItem?
            for item in items {
                item.printInfo(previousItem: previousItem)
                previousItem = item
            }
        }
        
    }
    
    class LayoutAnalyzerItem {
        
        let view: UIView
        let type: LayoutAnalyzerType
        let value: Any?
        
        init(view: UIView, type: LayoutAnalyzerType, value: Any? = nil) {
            self.view = view
            self.type = type
            self.value = value
        }
        
        func printInfo(previousItem: LayoutAnalyzerItem?) {
            let viewLabel = view.accessibilityIdentifier ?? "unknown"
            var operationInfo = ""
            switch type {
            case .changeText:
                let stringValue = value as? String ?? ""
                operationInfo = type.rawValue + " to '\(stringValue)'"
            case .changeBounds:
                let rectValue = value as? CGRect ?? CGRect.zero
                operationInfo = type.rawValue + " to \(rectValue)"
            default:
                operationInfo = type.rawValue
            }
            print("View '\(viewLabel)' had operation: \(operationInfo)")
        }
        
    }
    
    enum LayoutAnalyzerType: String {
        
        case layoutSubviews = "layout subviews"
        case changeBounds = "change bounds"
        case changeText = "change text"
        
    }


    // --
    // MARK: Testing view controller and views
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

}
