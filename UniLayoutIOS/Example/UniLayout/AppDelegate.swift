//
//  AppDelegate.swift
//  UniLayout Example
//
//  The application delegate, handling global events while the app is running
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    // --
    // MARK: Window member (used to contain the navigation controller)
    // --

    var window: UIWindow?


    // --
    // MARK: Lifecycle callbacks
    // --

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = UIColor.white
        window?.rootViewController = UINavigationController(rootViewController: MainViewController())
        window?.makeKeyAndVisible()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // No implementation
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // No implementation
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // No implementation
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // No implementation
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // No implementation
    }

}
