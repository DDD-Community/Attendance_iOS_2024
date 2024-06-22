//
//  SignupInviteCodeViewController.swift
//  DDDAttendance
//
//  Created by 고병학 on 6/8/24.
//

import ReactorKit
import ComposableArchitecture

import UIKit
import SwiftUI

final class SignupInviteCodeViewController: UIViewController {
    
    typealias Reactor = SignupInviteCodeReactor
    
    // MARK: - UI properties
    private var mainView: SignupInviteCodeView { view as! SignupInviteCodeView }
    
    // MARK: - Properties
    var disposeBag: DisposeBag = .init()
    
    
    // MARK: - Lifecycles
    init(
        uid: String,
        name: String,
        part: SelectPart,
        isManager: Bool
    ) {
        super.init(nibName: nil, bundle: nil)
        self.reactor = SignupInviteCodeReactor(
            uid: uid,
            name: name,
            isManager: isManager,
            part: part
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = SignupInviteCodeView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerForKeyboardNotifications()
    }
    
    deinit {
        self.unregisterForKeyboardNotifications()
    }
    // MARK: - Public helpers
    
    // MARK: - Private helpers
    private func getViewController() -> UIViewController? {
        guard let isManager: Bool = self.reactor?.currentState.isManager else {
            return nil
        }
        if isManager {
            let rootCoreMemberView = RootCoreMemberView(store: Store(
                initialState: RootCoreMember.State(),
                reducer: {
                RootCoreMember()
                        ._printChanges()
            }))
            let coreMemberHostingViewController = UIHostingController(rootView: rootCoreMemberView)
            return coreMemberHostingViewController
        } else {
//            let rootCoreMemberView = RootCoreMemberView(store: Store(
//                initialState: RootCoreMember.State(),
//                reducer: {
//                RootCoreMember()
//                        ._printChanges()
//            }))
//            let coreMemberHostingViewController = UIHostingController(rootView: rootCoreMemberView)
//            return coreMemberHostingViewController
            return MemberMainViewController()
        }
    }
    
    private func switchView() {
        guard let sceneDelegate = self.view.window?.windowScene?.delegate as? SceneDelegate,
              let window = sceneDelegate.window else {
            return
        }
        UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve) { [weak self] in
            guard let viewController = self?.getViewController() else { return }
            let navigationController: UINavigationController = .init(rootViewController: viewController)
            navigationController.navigationBar.isHidden = true
            window.rootViewController = navigationController
        }
    }
}

extension SignupInviteCodeViewController: ReactorKit.View {
    func bind(reactor: Reactor) {
        mainView.codeTextField.rx.text
            .orEmpty
            .map { Reactor.Action.updateInviteCode($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        mainView.nextButton.rx.throttleTap
            .map { Reactor.Action.signup }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.inviteCode }
            .distinctUntilChanged()
            .map { !$0.isEmpty }
            .observe(on: MainScheduler.asyncInstance)
            .bind(to: mainView.nextButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.errorMessage }
            .distinctUntilChanged()
            .observe(on: MainScheduler.asyncInstance)
            .bind { [weak self] errorMessage in
                self?.mainView.codeErrorLabel.text = errorMessage
                self?.mainView.codeErrorLabel.isHidden = errorMessage == nil
            }.disposed(by: disposeBag)
        
        reactor.state.map { $0.isSignupSuccess }
            .distinctUntilChanged()
            .observe(on: MainScheduler.asyncInstance)
            .bind { [weak self] isSignupSuccess in
                guard let isSignupSuccess, isSignupSuccess else { return }
                self?.switchView()
            }.disposed(by: disposeBag)
    }
}
