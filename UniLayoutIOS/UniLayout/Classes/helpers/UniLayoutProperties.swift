//
//  UniLayoutProperties.swift
//  UniLayout Pod
//
//  Library helper: layout properties
//  Used in combination with each UniLayout view, container or component to customize layout behavior
//

import UIKit

/// An enum used to indicate how measure a view, sent by a layout container
public enum UniMeasureSpec {
    
    case unspecified
    case limitSize
    case exactSize
    
}

/// An enum used to set the visibility type of a view, wraps the isHidden and hiddentakesSpace properties
public enum UniVisibility {
    
    case visible
    case invisible
    case hidden
    
}

/// A protocol to add padding support to a view
public protocol UniLayoutPaddedView {
    
    var padding: UIEdgeInsets { get set }
    
}

/// A protocol to change a view into a UniLayout enabled view
/// Adds layout properties and more control over measuring its size
public protocol UniLayoutView {
    
    var layoutProperties: UniLayoutProperties { get set }
    var visibility: UniVisibility { get set }
    func measuredSize(sizeSpec: CGSize, widthSpec: UniMeasureSpec, heightSpec: UniMeasureSpec) -> CGSize
    
}

/// The properties available to every UniLayout enabled view
/// Allows more control on how a subview is placed within a container
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
    public var spacingMargin: CGFloat = 0
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


    // ---
    // MARK: Public initializer
    // ---
    
    public init() {
        // Required to be able to create UniLayoutView implementations outside of the library
    }

}
