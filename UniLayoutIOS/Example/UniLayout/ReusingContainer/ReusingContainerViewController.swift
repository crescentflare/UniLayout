//
//  ReusingContainerViewController.swift
//  UniLayout Example
//
//  A viewcontroller containing a container reusing views (based on UITableView)
//

import UIKit
import UniLayout

class ReusingContainerViewController: UIViewController {

    // --
    // MARK: Access typed view instance
    // --

    var reusingContainer: ReusingContainerView! { return self.view as! ReusingContainerView }
    let editButton = UIButton()

    
    // --
    // MARK: Lifecycle
    // --

    override func loadView() {
        view = ReusingContainerView()
        edgesForExtendedLayout = UIRectEdge()
    }

    override func viewDidLoad() {
        // Initialize navigation bar
        super.viewDidLoad()
        navigationItem.title = "Reusing container"
        
        // Add items to the container
        reusingContainer.addItem(ReusableItem(type: .section, title: "Supported containers"))
        reusingContainer.addItem(ReusableItem(type: .topDivider))
        reusingContainer.addItem(ReusableItem(type: .item, title: "Horizontal scroll container", additional: "Contains a single content view which can scroll horizontally, use linear container as a content view for scrollable layouts", value: "Scroll"))
        reusingContainer.addItem(ReusableItem(type: .item, title: "Vertical scroll container", additional: "Contains a single content view which can scroll vertically, use linear container as a content view for scrollable layouts", value: "Scroll"))
        reusingContainer.addItem(ReusableItem(type: .item, title: "Linear container", additional: "Aligns items horizontally or vertically, depending on its orientation", value: "Layout"))
        reusingContainer.addItem(ReusableItem(type: .item, title: "Frame container", additional: "A simple container to contain one view, or add multiple overlapping views", value: "Layout"))
        reusingContainer.addItem(ReusableItem(type: .item, title: "Reusing container", additional: "A vertical layout container with scrolling with reusable views", value: "Layout\nScroll"))
        reusingContainer.addItem(ReusableItem(type: .bottomDivider))
        reusingContainer.addItem(ReusableItem(type: .section, title: "Supported views"))
        reusingContainer.addItem(ReusableItem(type: .topDivider))
        reusingContainer.addItem(ReusableItem(type: .item, title: "Button view", additional: "Extends UIButton to work with layout properties and provides more control over its padding", value: "Button"))
        reusingContainer.addItem(ReusableItem(type: .item, title: "Image view", additional: "Contains UIImageView to add padding and work with layout properties", value: "Image"))
        reusingContainer.addItem(ReusableItem(type: .item, title: "Text view", additional: "Extends UILabel to add padding and work with other layout properties", value: "Text"))
        reusingContainer.addItem(ReusableItem(type: .item, title: "Spinner view", additional: "Extends UIActivityIndicatorView to add padding and work with other layout properties", value: "Indicator"))
        reusingContainer.addItem(ReusableItem(type: .item, title: "Web view", additional: "Extends UIWebView to work with layout properties and provides more control over its padding", value: "Web content"))
        reusingContainer.addItem(ReusableItem(type: .item, title: "View", additional: "Extends UIView to add layout properties and padding, can be used as a base for custom layouts", value: "Container"))
        reusingContainer.addItem(ReusableItem(type: .item, title: "Reusable view", additional: "Extends UITableViewCell to contain a layout container and support automatic height calculation and custom dividers", value: "Container"))
        reusingContainer.addItem(ReusableItem(type: .bottomDivider))
        reusingContainer.container.reloadData()
    }

}
