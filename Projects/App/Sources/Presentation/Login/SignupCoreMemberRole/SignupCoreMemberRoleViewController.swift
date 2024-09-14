//
//  SignupCoreMemberRoleViewController.swift
//  DDDAttendance
//
//  Created by 고병학 on 9/14/24.
//

import ComposableArchitecture
import ReactorKit

import SwiftUI
import UIKit

final class SignupCoreMemberRoleViewController: UIViewController {
    
    typealias Reactor = SignupCoreMemberRoleReactor
    
    // MARK: - UI properties
    private var mainView: SignupCoreMemberRoleView { view as! SignupCoreMemberRoleView }
    
    // MARK: - Properties
    var disposeBag: DisposeBag = .init()
    private lazy var feedbackGenerator: UIImpactFeedbackGenerator = .init()
    
    // MARK: - Lifecycles
    init(_ member: MemberRequestModel) {
        super.init(nibName: nil, bundle: nil)
        self.reactor = Reactor(member: member)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = SignupCoreMemberRoleView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    // MARK: - Public helpers
    
    // MARK: - Private helpers
    private func getViewController() -> UIViewController? {
        let rootCoreMemberView = RootCoreMemberView(store: Store(
            initialState: RootCoreMember.State(),
            reducer: {
                RootCoreMember()
                    ._printChanges()
            }))
        let coreMemberHostingViewController = UIHostingController(rootView: rootCoreMemberView)
        return coreMemberHostingViewController
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

extension SignupCoreMemberRoleViewController: ReactorKit.View {
    func bind(reactor: SignupCoreMemberRoleReactor) {
        // Action
        mainView.teamManagingButton.rx.tap
            .map { Reactor.Action.selectRole(.projectTeamManging) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        mainView.calendarButton.rx.tap
            .map { Reactor.Action.selectRole(.scheduleManagement) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        mainView.photoButton.rx.tap
            .map { Reactor.Action.selectRole(.photographer) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        mainView.rentPlaceButton.rx.tap
            .map { Reactor.Action.selectRole(.accountiConsulting) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        mainView.snsManageButton.rx.tap
            .map { Reactor.Action.selectRole(.instagramManagement) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        mainView.attendanceCheckButton.rx.tap
            .map { Reactor.Action.selectRole(.attendanceCheck) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        mainView.nextButton.rx.throttleTap.bind { [weak self] in
            self?.reactor?.action.onNext(.didTapNextButton)
        }.disposed(by: disposeBag)
        
        self.mainView.backButton.rx.throttleTap.bind { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }.disposed(by: self.disposeBag)
        
        reactor.state.map { $0.member.coreMemberRole }
            .distinctUntilChanged()
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] role in
                self?.mainView.teamManagingButton.isSelected = role == .projectTeamManging
                self?.mainView.calendarButton.isSelected = role == .scheduleManagement
                self?.mainView.photoButton.isSelected = role == .photographer
                self?.mainView.rentPlaceButton.isSelected = role == .accountiConsulting
                self?.mainView.snsManageButton.isSelected = role == .instagramManagement
                self?.mainView.attendanceCheckButton.isSelected = role == .attendanceCheck
                self?.mainView.nextButton.isEnabled = role != nil
                
                if role != nil {
                    self?.feedbackGenerator.impactOccurred()
                }
            })
            .disposed(by: self.disposeBag)
        
        reactor.state.map { $0.isSignupSuccess }
            .distinctUntilChanged()
            .compactMap { $0 }
            .bind { [weak self] isSuccess in
                guard isSuccess else { return }
                self?.switchView()
            }.disposed(by: self.disposeBag)
    }
    
}
