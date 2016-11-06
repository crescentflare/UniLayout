//
//  MainViewController.swift
//  UniLayout Example
//
//  A simple layout with buttons to show other layout examples
//

import UIKit
import UniLayout

class MainViewController: UIViewController {

    // --
    // MARK: Access typed view instance
    // --

    var containerView: UniVerticalScrollContainer! { return self.view as! UniVerticalScrollContainer }

    
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
        navigationItem.title = "UniLayout example"
        
        // Set a vertical layout to the scroll container
        let verticalLayout = UniLinearContainer()
        verticalLayout.orientation = .vertical
        verticalLayout.layoutProperties.width = UniLayoutProperties.stretchToParent
        verticalLayout.padding = UIEdgeInsetsMake(16, 16, 16, 16)
        containerView.contentView = verticalLayout
        
        // Add a text explaining the example
        let explainingText = UniTextView()
        explainingText.text = "Press on the buttons below to view several examples of layouts built with UniLayout"
        verticalLayout.addSubview(explainingText)
        
        // Add a button container, the buttons inside will all have the same width
        let buttonContainer = UniLinearContainer()
        buttonContainer.orientation = .vertical
        verticalLayout.addSubview(buttonContainer)
        
        // Add a button with the first example
        let nestedLayoutButton = UniButtonView()
        nestedLayoutButton.layoutProperties.margin.top = 16
        nestedLayoutButton.layoutProperties.width = UniLayoutProperties.stretchToParent
        nestedLayoutButton.padding = UIEdgeInsetsMake(4, 8, 4, 8)
        nestedLayoutButton.setTitle("Nested layouts", for: .normal)
        nestedLayoutButton.setTitleColor(self.view.tintColor, for: .normal)
        nestedLayoutButton.layer.cornerRadius = 8
        nestedLayoutButton.layer.borderWidth = 1
        nestedLayoutButton.layer.borderColor = self.view.tintColor.cgColor
        buttonContainer.addSubview(nestedLayoutButton)
        nestedLayoutButton.addTarget(self, action: #selector(showNestedLayouts), for: .touchUpInside)

        // Add a button with the second example
        let reusingContainerButton = UniButtonView()
        reusingContainerButton.layoutProperties.margin.top = 8
        reusingContainerButton.layoutProperties.width = UniLayoutProperties.stretchToParent
        reusingContainerButton.padding = UIEdgeInsetsMake(4, 8, 4, 8)
        reusingContainerButton.setTitle("Reusing container", for: .normal)
        reusingContainerButton.setTitleColor(self.view.tintColor, for: .normal)
        reusingContainerButton.layer.cornerRadius = 8
        reusingContainerButton.layer.borderWidth = 1
        reusingContainerButton.layer.borderColor = self.view.tintColor.cgColor
        buttonContainer.addSubview(reusingContainerButton)
        reusingContainerButton.addTarget(self, action: #selector(showReusingContainer), for: .touchUpInside)
    }
    
    func showNestedLayouts() {
        navigationController?.pushViewController(NestedLayoutsViewController(), animated: true)
    }

    func showReusingContainer() {
        navigationController?.pushViewController(ReusingContainerViewController(), animated: true)
    }

}
