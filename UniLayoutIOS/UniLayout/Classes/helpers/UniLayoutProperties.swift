//
//  UniLayoutProperties.swift
//  UniLayout Pod
//
//  Library helper: layout properties
//  Used in combination with each UniLayout component to customize layout behavior
//

import UIKit

enum UniMeasureSpec {
    
    case unspecified
    case limitSize
    case exactSize
    
}

protocol UniLayoutView {
    
    var layoutProperties: UniLayoutProperties { get set }
    func measuredSize(sizeSpec: CGSize, widthSpec: UniMeasureSpec, heightSpec: UniMeasureSpec) -> CGSize
    
}

class UniLayoutProperties {
    
    // ---
    // MARK: Constants for measuring
    // ---

    static let unspecified: Int = 0
    static let limitSize: Int = 1
    static let exactSize: Int = 2


    // ---
    // MARK: Constants for automatic sizing
    // ---

    static let stretchToParent: CGFloat = -1
    static let fitContent: CGFloat = -2
    

    // ---
    // MARK: Properties for layout
    // ---

    var padding = UIEdgeInsetsMake(0, 0, 0, 0)
    var margin = UIEdgeInsetsMake(0, 0, 0, 0)
    var minWidth: CGFloat = 0
    var maxWidth: CGFloat = 0xFFFFFF
    var minHeight: CGFloat = 0
    var maxHeight: CGFloat = 0xFFFFFF
    var width: CGFloat = UniLayoutProperties.fitContent
    var height: CGFloat = UniLayoutProperties.fitContent
    var horizontalGravity: CGFloat = 0
    var verticalGravity: CGFloat = 0
    var weight: CGFloat = 0
    var hiddenTakesSpace = false

}
