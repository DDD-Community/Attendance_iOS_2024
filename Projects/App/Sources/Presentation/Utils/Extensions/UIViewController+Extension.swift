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

extension UIViewController {

    func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func unregisterForKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        if let userInfo = notification.userInfo,
           let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
           let animationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double {

            let keyboardHeight = keyboardFrame.height
            adjustViewForKeyboard(height: keyboardHeight, animationDuration: animationDuration)
        }
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        if let userInfo = notification.userInfo,
           let animationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double {
            
            adjustViewForKeyboard(height: 0, animationDuration: animationDuration)
        }
    }
    
    private func adjustViewForKeyboard(height: CGFloat, animationDuration: Double) {
        UIView.animate(withDuration: animationDuration) {
            self.view.frame.size.height = UIScreen.main.bounds.height - height
        }
    }
}
