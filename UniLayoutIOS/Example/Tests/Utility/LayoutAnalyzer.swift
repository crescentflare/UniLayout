//
//  LayoutAnalyzer.swift
//  Contains a trace of layout events for analysis
//

import UIKit
@testable import UniLayout

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


// --
// MARK: Layout analyzer item
// --

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


// --
// MARK: Layout analyzer event type enum
// --

enum LayoutAnalyzerType: String {
    
    case layoutSubviews = "layout subviews"
    case changeBounds = "change bounds"
    case changeText = "change text"
    
}
