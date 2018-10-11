//
//  ReusingContainerView.swift
//  UniLayout Example
//
//  Contains the reusing container and data to supply to the reusable views inside (based on UITableView)
//

import UIKit
import UniLayout

enum ReusableItemType: String {
    
    case unknown = ""
    case section = "section"
    case item = "item"
    case topDivider = "topDivider"
    case bottomDivider = "bottomDivider"
    
}

class ReusableItem {
    
    let type: ReusableItemType
    let title: String
    let additional: String
    let value: String
    
    init(type: ReusableItemType, title: String = "", additional: String = "", value: String = "") {
        self.type = type
        self.title = title
        self.additional = additional
        self.value = value
    }
    
}

class ReusingContainerView: UniFrameContainer, UITableViewDataSource, UITableViewDelegate {
    
    // --
    // MARK: Members
    // --
    
    var items: [ReusableItem] = []
    let container = UniReusingContainer()
    
    
    // --
    // MARK: Initialize
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
    
    func initialize () {
        // Set up the reusing container
        container.layoutProperties.width = UniLayoutProperties.stretchToParent
        container.layoutProperties.height = UniLayoutProperties.stretchToParent
        container.backgroundColor = UIColor(white: 0.95, alpha: 1)
        addSubview(container)
        
        // Add empty footer
        let tableFooter = UIView()
        tableFooter.frame = CGRect(x: 0, y: 0, width: 0, height: 0.01)
        container.tableFooterView = tableFooter
        
        // Set the container properties
        container.rowHeight = UITableView.automaticDimension
        container.estimatedRowHeight = 40
        container.dataSource = self
        container.delegate = self
        container.separatorStyle = .none
    }
    
    
    // --
    // MARK: Modify items
    // --
    
    func removeItems() {
        items.removeAll()
    }
    
    func addItem(_ item: ReusableItem) {
        items.append(item)
    }
    
    
    // --
    // MARK: UITableViewDataSource
    // --
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Create cell (if needed)
        let item = items[(indexPath as NSIndexPath).row]
        let nextType = (indexPath as NSIndexPath).row + 1 < items.count ? items[(indexPath as NSIndexPath).row + 1].type : ReusableItemType.unknown
        let cell = tableView.dequeueReusableCell(withIdentifier: item.type.rawValue) as? UniReusableView ?? UniReusableView()
        cell.isSimulatingSpacing = false
        
        // Set up an item cell
        if item.type == .item {
            // Create view
            if !(cell.view is ItemView) {
                cell.view = ItemView()
            }
            let cellView = cell.view as? ItemView
            
            // Supply data
            cell.selectionStyle = .none
            cell.dividerLine.isHidden = nextType != .item
            cell.contentView.backgroundColor = UIColor.white
            cellView?.title = item.title
            cellView?.additional = item.additional
            cellView?.value = item.value
        }
        
        // Set up a section cell
        if item.type == .section {
            // Create view
            if !(cell.view is SectionView) {
                cell.view = SectionView()
            }
            let cellView = cell.view as? SectionView
            
            // Supply data
            cell.selectionStyle = .none
            cell.dividerLine.isHidden = true
            cell.contentView.backgroundColor = tableView.backgroundColor
            cellView?.text = item.title
        }
        
        // Set up a divider cell
        if item.type == .topDivider || item.type == .bottomDivider {
            // Create view
            if !(cell.view is DividerView) {
                cell.view = DividerView(bottom: item.type != .topDivider)
            }
            
            // Supply data
            cell.selectionStyle = .none
            cell.dividerLine.isHidden = true
            cell.contentView.backgroundColor = tableView.backgroundColor
        }
        
        // Return result
        return cell
    }
    
}
