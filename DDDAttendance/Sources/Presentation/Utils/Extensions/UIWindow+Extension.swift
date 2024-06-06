//
//  UIWindow+Extension.swift
//  DDDAttendance
//
//  Created by 고병학 on 6/6/24.
//

import UIKit

extension UIWindow {
    var topViewController: UIViewController? {
        return self.rootViewController?.topMostViewController()
    }
}
