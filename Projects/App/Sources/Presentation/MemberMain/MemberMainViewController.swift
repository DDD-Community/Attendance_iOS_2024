//
//  MemberMainViewController.swift
//  DDDAttendance
//
//  Created by 고병학 on 6/6/24.
//

import ReactorKit

import UIKit

final class MemberMainViewController: UIViewController {
    typealias Reactor = MemberMainReactor
    
    // MARK: - UI properties
    private var mainView: MemberMainView { view as! MemberMainView }
    
    // MARK: - Properties
    var disposeBag: DisposeBag = .init()
    
    // MARK: - Lifecycles
    override func loadView() {
        view = MemberMainView()
        reactor = Reactor()
    }
    
    // MARK: - Public helpers
    
    // MARK: - Private helpers
    private func presentQRLoginView() {
        guard let profile: Member = reactor?.currentState.userProfile else {
            return
        }
        let vc: QRCheckInViewController = .init(profile: profile)
        self.present(vc, animated: true)
    }
    
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
    
    private func showAlert(title: String, message: String) {
        let alert: UIAlertController = .init(title: title, message: message, preferredStyle: .alert)
        alert.addAction(.init(title: "확인", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

extension MemberMainViewController: View {
    func bind(reactor: Reactor) {
        mainView.logoutButton.rx.throttleTap
            .map { Reactor.Action.didTapLogout }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        mainView.qrCheckInButton.rx.throttleTap
            .bind { [weak self] in
                self?.presentQRLoginView()
            }.disposed(by: disposeBag)
        
        reactor.state.map { $0.userAttendanceHistory }
            .distinctUntilChanged()
            .compactMap { $0 }
            .observe(on: MainScheduler.asyncInstance)
            .bind { [weak self] attendances in
                self?.mainView.bindAttendances(attendances)
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
}
