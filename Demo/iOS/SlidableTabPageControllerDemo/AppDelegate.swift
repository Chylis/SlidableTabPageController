//
//  AppDelegate.swift
//  SlidableTabPageControllerDemo_tvOS
//
//  Created by Magnus Eriksson on 2017-03-15.
//  Copyright © 2017 Magnus Eriksson. All rights reserved.
//

import UIKit
import SlidableTabPageController

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let tabPageCtrl = SlidableTabPageControllerFactory.make(pages: createPages(count: 7))
        tabPageCtrl.maxNumberOfIndexBarElementsPerScreen = 4.5
        tabPageCtrl.indexBarHeightConstraint?.constant = 49
        tabPageCtrl.indexBarElementColor = .black
        tabPageCtrl.indexIndicatorView.backgroundColor = .red
        tabPageCtrl.indexBarElementHighlightedColor = tabPageCtrl.indexIndicatorView.backgroundColor!
        tabPageCtrl.delegate = self
        
        window = UIWindow()
        window?.rootViewController = tabPageCtrl
        window?.makeKeyAndVisible()
        return true
    }
    
    private func createPages(count: Int) -> [SlidableTabPageControllerPage] {
        return (0..<count).map { i -> SlidableTabPageControllerPage in
            let vc = UIViewController()
            vc.view.backgroundColor = randomColor()
            
            vc.title = "\(i)"
            let page: SlidableTabPageControllerPage

            if i == 0 {
                let indexBarElement = IndexBarElement.image(
                    UIImage(named: "icon-star")!.withRenderingMode(.alwaysTemplate),
                    UIImage(named: "icon-plane")!.withRenderingMode(.alwaysTemplate))
                page = SlidableTabPageControllerPage(indexBarElement: indexBarElement,
                                                       contentViewController: vc)
            } else if i == 1 {
                page = SlidableTabPageControllerPage(indexBarElement: IndexBarElement.title("hello there"),
                                                       contentViewController :vc)
            } else if i == 2 {
                let indexBarElement = IndexBarElement.image(
                    UIImage(named: "icon-star")!.withRenderingMode(.alwaysOriginal),
                    UIImage(named: "icon-star")!.withRenderingMode(.alwaysOriginal))
                page = SlidableTabPageControllerPage(indexBarElement: indexBarElement,
                                                       contentViewController: vc)
            } else if i == 4 {
                vc.title = "a veeeery long (truncated) title"
                page = SlidableTabPageControllerPage(contentViewController: vc)
            } else {
                page = SlidableTabPageControllerPage(contentViewController: vc)
            }
            
            return page
        }
    }
    
    private func randomColor() -> UIColor {
        return UIColor(red: CGFloat(drand48()), green: CGFloat(drand48()), blue: CGFloat(drand48()), alpha: 1)
    }
}

extension AppDelegate: SlidableTabPageControllerDelegate {
    func slidableTabPageController(_ slidableTabPageController: SlidableTabPageController, didNavigateFrom oldPage: Int, to newPage: Int) {
        print("Page changed from '\(oldPage)' to  \(newPage)")
    }
}
