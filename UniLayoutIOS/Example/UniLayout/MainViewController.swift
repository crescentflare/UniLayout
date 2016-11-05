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
        view.backgroundColor = UIColor(white: 0.95, alpha: 1)
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
        let firstButton = UniButtonView()
        firstButton.layoutProperties.margin.top = 16
        firstButton.layoutProperties.width = UniLayoutProperties.stretchToParent
        firstButton.padding = UIEdgeInsetsMake(4, 8, 4, 8)
        firstButton.setTitle("First example", for: .normal)
        firstButton.setTitleColor(self.view.tintColor, for: .normal)
        firstButton.layer.cornerRadius = 8
        firstButton.layer.borderWidth = 1
        firstButton.layer.borderColor = self.view.tintColor.cgColor
        buttonContainer.addSubview(firstButton)
        firstButton.addTarget(self, action: #selector(showFirstExample), for: .touchUpInside)

        // Add a button with the second example
        let secondButton = UniButtonView()
        secondButton.layoutProperties.margin.top = 6
        secondButton.layoutProperties.width = UniLayoutProperties.stretchToParent
        secondButton.padding = UIEdgeInsetsMake(4, 8, 4, 8)
        secondButton.setTitle("Second example", for: .normal)
        secondButton.setTitleColor(self.view.tintColor, for: .normal)
        secondButton.layer.cornerRadius = 8
        secondButton.layer.borderWidth = 1
        secondButton.layer.borderColor = self.view.tintColor.cgColor
        buttonContainer.addSubview(secondButton)
        secondButton.addTarget(self, action: #selector(showSecondExample), for: .touchUpInside)
    }
    
    func showFirstExample() {
        let alert = UIAlertController(title: "Not implemented", message: "This example is not implemented yet", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    func showSecondExample() {
        let alert = UIAlertController(title: "Not implemented", message: "This example is not implemented yet", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

}
