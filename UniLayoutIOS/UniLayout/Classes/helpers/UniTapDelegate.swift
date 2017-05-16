//
//  UniTapDelegate.swift
//  UniLayout Pod
//
//  Library helper: tap delegate
//  A delegate which captures the touch up inside event of frame or linear containers
//

import UIKit

/// A protocol to define the delegate method of touch up inside
public protocol UniTapDelegate: class {
    
    func containerTapped(_ sender: UIView)
    
}
