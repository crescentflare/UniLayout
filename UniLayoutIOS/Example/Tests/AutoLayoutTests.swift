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
    
}
