//
//  AppDelegate.swift
//  APSlidableTabPageControllerDemo_tvOS
//
//  Created by Magnus Eriksson on 2017-03-15.
//  Copyright © 2017 Magnus Eriksson. All rights reserved.
//

import UIKit
import APSlidableTabPageController_tvOS

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        let tabPageCtrl = APSlidableTabPageControllerFactory.make(childViewControllers: createViewControllers(count: 7))
        
        tabPageCtrl.maxNumberOfIndexBarElementsPerScreen = 4.5
        tabPageCtrl.indexBarHeightConstraint.constant = 49
        tabPageCtrl.indexBarElementColor = UIColor.black
        tabPageCtrl.indexBarElementHighlightedColor = tabPageCtrl.indexIndicatorView.backgroundColor!
        
        window = UIWindow()
        window?.rootViewController = tabPageCtrl
        window?.makeKeyAndVisible()
        return true
    }
    
    private func createViewControllers(count: Int) -> [UIViewController] {
        return (0..<count).map { i -> UIViewController in
            let vc = UIViewController()
            vc.title = "\(i)"
            vc.view.backgroundColor = randomColor()
            
            if i == 0 {
                vc.tabBarItem.image = UIImage(named: "icon-star")?.withRenderingMode(.alwaysTemplate)
                vc.tabBarItem.selectedImage = UIImage(named: "icon-plane")?.withRenderingMode(.alwaysTemplate)
            } else if i == 1 {
                vc.title = "hello there"
            } else if i == 2 {
                vc.tabBarItem.image = UIImage(named: "icon-star")
            } else if i == 4 {
                vc.title = "a veeeery long (truncated) title"
            }
            return vc
        }
    }
    
    private func randomColor() -> UIColor {
        return UIColor(red: CGFloat(drand48()), green: CGFloat(drand48()), blue: CGFloat(drand48()), alpha: 1)
    }

}

