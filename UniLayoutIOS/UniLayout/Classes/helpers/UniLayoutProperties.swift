//
//  UniLayoutProperties.swift
//  UniLayout Pod
//
//  Library helper: layout properties
//  Used in combination with each UniLayout view, container or component to customize layout behavior
//

import UIKit

public enum UniMeasureSpec {
    
    case unspecified
    case limitSize
    case exactSize
    
}

public protocol UniLayoutPaddedView {
    
    var padding: UIEdgeInsets { get set }
    
}

public protocol UniLayoutView {
    
    var layoutProperties: UniLayoutProperties { get set }
    func measuredSize(sizeSpec: CGSize, widthSpec: UniMeasureSpec, heightSpec: UniMeasureSpec) -> CGSize
    
}

public class UniLayoutProperties {
    
    // ---
    // MARK: Constants for measuring
    // ---

    public static let unspecified: Int = 0
    public static let limitSize: Int = 1
    public static let exactSize: Int = 2


    // ---
    // MARK: Constants for automatic sizing
    // ---

    public static let stretchToParent: CGFloat = -1
    public static let fitContent: CGFloat = -2
    

    // ---
    // MARK: Properties for layout
    // ---

    public var margin = UIEdgeInsetsMake(0, 0, 0, 0)
    public var minWidth: CGFloat = 0
    public var maxWidth: CGFloat = 0xFFFFFF
    public var minHeight: CGFloat = 0
    public var maxHeight: CGFloat = 0xFFFFFF
    public var width: CGFloat = UniLayoutProperties.fitContent
    public var height: CGFloat = UniLayoutProperties.fitContent
    public var horizontalGravity: CGFloat = 0
    public var verticalGravity: CGFloat = 0
    public var weight: CGFloat = 0
    public var hiddenTakesSpace = false

}
