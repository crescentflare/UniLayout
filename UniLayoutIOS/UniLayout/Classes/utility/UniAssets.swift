//
//  UniAssets.swift
//  UniLayout Pod
//
//  Library utility: obtaining assets
//  Obtain assets from the library, mostly used to simulate internal iOS assets
//

import UIKit

public class UniAssets {

    // ---
    // MARK: Members
    // ---
    
    private static var loadedAssets: [String: UIImage] = [:]
    

    // ---
    // MARK: Initialization
    // ---
    
    private init() {
    }

    
    // ---
    // MARK: Direct asset access
    // ---
    
    public static var chevron: UIImage? {
        get { return UniAssets.obtainAsset(name: "chevron") }
    }

    
    // ---
    // MARK: Generic asset loading
    // ---
    
    public static func obtainAsset(name: String) -> UIImage? {
        if let loadedAsset = loadedAssets[name] {
            return loadedAsset
        }
        if let bundleUrl = Bundle(for: UniAssets.self).url(forResource: "UniLayout", withExtension: "bundle") {
            let bundle = Bundle(url: bundleUrl)
            if let image = UIImage(named: "unilayout-" + name, in: bundle, compatibleWith: nil) {
                loadedAssets[name] = image
                return image
            }
        }
        return nil
    }

}
