//
//  SplashViewController.swift
//  DDDAttendance
//
//  Created by 고병학 on 6/6/24.
//

import ComposableArchitecture
import ReactorKit

import UIKit
import SwiftUI

final class SplashViewController: UIViewController {
    
    typealias Reactor = SplashReactor
    
    private var mainView: SplashView {
        return view as! SplashView
    }
    
    var disposeBag: DisposeBag = .init()
    
    override func loadView() {
        view = SplashView()
        reactor = SplashReactor()
        reactor?.action.onNext(.fetchSignedUser)
    }
    
    private func switchView(_ memberType: MemberType) {
        DispatchQueue.main.asyncAfter(
            deadline: .now() + .milliseconds(Int(3.8 * 1000))
        ) { [weak self] in
            switch memberType {
            case .master, .coreMember:
                self?.switchToCoreMemberView()
            case .member:
                self?.switchToMemberView()
            case .notYet, .run:
                self?.switchToLoginView()
            }
        }
    }
    
    private func switchToLoginView() {
        let viewController: SNSLoginViewController = .init()
        switchView(viewController)
    }
    
    private func switchToMemberView() {
        let viewController = MemberMainViewController()
        switchView(viewController)
    }
    
    private func switchToCoreMemberView() {
        let rootCoreMemberView = RootCoreMemberView(store: Store(
            initialState: RootCoreMember.State(),
            reducer: {
                RootCoreMember()
                    ._printChanges()
            }))
        let coreMemberHostingViewController = UIHostingController(rootView: rootCoreMemberView)
        switchView(coreMemberHostingViewController)
    }
    
    private func switchView(_ viewController: UIViewController) {
        guard let sceneDelegate = self.view.window?.windowScene?.delegate as? SceneDelegate,
              let window = sceneDelegate.window else {
            return
        }
        UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve) {
            let navigationController: UINavigationController = .init(rootViewController: viewController)
            navigationController.isNavigationBarHidden = true
            window.rootViewController = navigationController
        }
    }
}

extension SplashViewController: ReactorKit.View {
    func bind(reactor: SplashReactor) {
        reactor.state.map { $0.memberType }
            .distinctUntilChanged()
            .compactMap { $0 }
            .observe(on: MainScheduler.asyncInstance)
            .bind { [weak self] memberType in
                self?.switchView(memberType)
            }.disposed(by: self.disposeBag)
    }
}
