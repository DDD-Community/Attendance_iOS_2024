//
//  SplashViewController.swift
//  DDDAttendance
//
//  Created by 고병학 on 6/6/24.
//

import UIKit

final class SplashViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .green
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.switchView(1)
    }
    
    private func switchView(_ after: Int) {
        DispatchQueue.main.asyncAfter(
            deadline: .now() + .seconds(after)
        ) { [weak self] in
            self?.switchView()
        }
    }
    
    private func switchView() {
        guard let sceneDelegate = self.view.window?.windowScene?.delegate as? SceneDelegate,
              let window = sceneDelegate.window else {
            return
        }
        UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve) {
            let viewController: SNSLoginViewController = .init()
            window.rootViewController = viewController
        }
    }
}
