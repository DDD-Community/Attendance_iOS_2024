//
//  SplashViewController.swift
//  DDDAttendance
//
//  Created by 고병학 on 6/6/24.
//

import FirebaseAuth

import UIKit

final class SplashViewController: UIViewController {
    
    private var mainView: SplashView {
        return view as! SplashView
    }
    
    override func loadView() {
        view = SplashView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.switchView(1)
    }
    
    private func switchView(_ after: Int) {
        DispatchQueue.main.asyncAfter(
            deadline: .now() + .seconds(after)
        ) { [weak self] in
            self?.checkIsSigned { [weak self] isSigned in
                let viewController = if isSigned {
                    MemberMainViewController()
                } else {
                    SNSLoginViewController()
                }
                self?.switchView(viewController)
            }
        }
    }
    
    private func switchView(_ viewController: UIViewController) {
        guard let sceneDelegate = self.view.window?.windowScene?.delegate as? SceneDelegate,
              let window = sceneDelegate.window else {
            return
        }
        UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve) {
            let navigationController: UINavigationController = .init(rootViewController: viewController)
            window.rootViewController = navigationController
        }
    }
    
    private func checkIsSigned(_ completion: @escaping (Bool) -> Void) {
        if Auth.auth().currentUser != nil {
            completion(true)
        } else {
            completion(false)
        }
    }
}
