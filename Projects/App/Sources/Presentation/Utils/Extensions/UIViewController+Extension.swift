//
//  UIViewController+Extension.swift
//  DDDAttendance
//
//  Created by 고병학 on 6/6/24.
//

import UIKit

extension UIViewController {
    func topMostViewController() -> UIViewController? {
        if let presentedViewController = self.presentedViewController {
            return presentedViewController.topMostViewController()
        }
        
        if let navigationController = self as? UINavigationController {
            return navigationController.visibleViewController?.topMostViewController()
        }
        
        if let tabBarController = self as? UITabBarController {
            if let selectedViewController = tabBarController.selectedViewController {
                return selectedViewController.topMostViewController()
            }
        }
        
        for childViewController in children {
            if let topViewController = childViewController.topMostViewController() {
                return topViewController
            }
        }
        
        return self
    }
}
