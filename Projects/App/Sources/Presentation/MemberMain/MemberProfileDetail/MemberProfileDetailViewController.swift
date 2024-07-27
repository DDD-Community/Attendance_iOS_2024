//
//  MemberProfileDetailViewController.swift
//  DDDAttendance
//
//  Created by 고병학 on 7/27/24.
//

import ReactorKit

import UIKit

final class MemberProfileDetailViewController: UIViewController {
    
    typealias Reactor = MemberProfileDetailReactor
    
    // MARK: - UI properties
    private var mainView: MemberProfileDetailView { view as! MemberProfileDetailView }
    
    // MARK: - Properties
    var disposeBag: DisposeBag = .init()
    
    // MARK: - Lifecycles
    override func loadView() {
        view = MemberProfileDetailView()
        reactor = Reactor()
    }
    
    // MARK: - Public helpers
    
    // MARK: - Private helpers
    private func switchToLoginView() {
        guard let sceneDelegate = self.view.window?.windowScene?.delegate as? SceneDelegate,
              let window = sceneDelegate.window else {
            return
        }
        UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve) {
            let viewController: SNSLoginViewController = .init()
            let navigationController: UINavigationController = .init(rootViewController: viewController)
            window.rootViewController = navigationController
        }
    }
}

extension MemberProfileDetailViewController: View {
    func bind(reactor: MemberProfileDetailReactor) {
        bindState(reactor)
        bindAction(reactor)
    }
    
    private func bindState(_ reactor: Reactor) {
        reactor.state.map { $0.profile }
            .distinctUntilChanged()
            .compactMap { $0 }
            .observe(on: MainScheduler.asyncInstance)
            .bind { [weak self] profile in
                self?.mainView.bind(profile: profile)
            }.disposed(by: disposeBag)
        
        reactor.state.map { $0.isUserLoggedOut }
            .distinctUntilChanged()
            .compactMap { $0 }
            .observe(on: MainScheduler.asyncInstance)
            .bind { [weak self] isLoggedOut in
                guard isLoggedOut else { return }
                self?.switchToLoginView()
            }.disposed(by: disposeBag)
    }
    
    private func bindAction(_ reactor: Reactor) {
        mainView.backButton.rx.throttleTap.bind { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }.disposed(by: disposeBag)
        
        mainView.logoutButton.rx.throttleTap
            .map { Reactor.Action.didTapLogout }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
}
