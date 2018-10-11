//
//  NestedLayoutsViewController.swift
//  UniLayout Example
//
//  A viewcontroller containing nested layout containers
//

import UIKit
import UniLayout

class NestedLayoutsViewController: UIViewController {

    // --
    // MARK: Access typed view instance
    // --

    var containerView: UniVerticalScrollContainer! { return self.view as? UniVerticalScrollContainer }

    
    // --
    // MARK: Lifecycle
    // --

    override func loadView() {
        view = UniVerticalScrollContainer()
        view.backgroundColor = UIColor(white: 1, alpha: 1)
        edgesForExtendedLayout = UIRectEdge()
    }

    override func viewDidLoad() {
        // Initialize navigation bar
        super.viewDidLoad()
        navigationItem.title = "Nested layouts"
        
        // Set a vertical layout to the scroll container
        let verticalLayout = UniLinearContainer()
        verticalLayout.orientation = .vertical
        verticalLayout.layoutProperties.width = UniLayoutProperties.stretchToParent
        containerView.contentView = verticalLayout
        
        // Add the layout sets and divider lines
        verticalLayout.addSubview(generateLayoutView(imageName: "linearcontainer", title: "Linear Container", text: "These containers are made to arrange views horizontally or vertically depending on their orientation. The size depends on its content. Nest them to create structured layouts."))
        verticalLayout.addSubview(generateDividerLine())
        verticalLayout.addSubview(generateLayoutView(imageName: "framecontainer", title: "Frame Container", text: "These containers are used as the most simple container but can also be used to stack views on top of each other for complex layouts."))
    }
    
    private func generateLayoutView(imageName: String, title: String, text: String) -> UniLinearContainer {
        // Prepare the horizontal layout
        let horizontalLayout = UniLinearContainer()
        horizontalLayout.orientation = .horizontal
        horizontalLayout.layoutProperties.width = UniLayoutProperties.stretchToParent
        horizontalLayout.padding = UIEdgeInsets.init(top: 16, left: 8, bottom: 16, right: 8)
        
        // Add the image
        let imageView = UniImageView()
        imageView.layoutProperties.margin.right = 8
        imageView.image = UIImage(named: imageName)
        horizontalLayout.addSubview(imageView)
        
        // Add a vertical layout
        let verticalLayout = UniLinearContainer()
        verticalLayout.orientation = .vertical
        verticalLayout.layoutProperties.width = 0
        verticalLayout.layoutProperties.weight = 1
        horizontalLayout.addSubview(verticalLayout)
        
        // Add the title
        let titleView = UniTextView()
        titleView.font = UIFont.boldSystemFont(ofSize: 17)
        titleView.text = title
        verticalLayout.addSubview(titleView)
        
        // Add the text
        let textView = UniTextView()
        textView.layoutProperties.margin.top = 4
        textView.font = UIFont.systemFont(ofSize: 15)
        textView.text = text
        verticalLayout.addSubview(textView)
        
        // Return result
        return horizontalLayout
    }
    
    private func generateDividerLine() -> UniView {
        let divider = UniView()
        divider.layoutProperties.width = UniLayoutProperties.stretchToParent
        divider.layoutProperties.height = 1
        divider.backgroundColor = UIColor(white: 0.90, alpha: 1)
        return divider
    }
    
}
