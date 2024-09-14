//
//  SignupMemberTeamViewController.swift
//  DDDAttendance
//
//  Created by 고병학 on 9/14/24.
//

import ReactorKit

import UIKit

final class SignupMemberTeamViewController: UIViewController {
    
    typealias Reactor = SignupMemberTeamReactor
    
    // MARK: - UI properties
    private var mainView: SignupMemberTeamView { view as! SignupMemberTeamView }
    
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
        view = SignupMemberTeamView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    // MARK: - Public helpers
    
    // MARK: - Private helpers
    private func switchView() {
        guard let sceneDelegate = self.view.window?.windowScene?.delegate as? SceneDelegate,
              let window = sceneDelegate.window else {
            return
        }
        UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve) {
            let viewController: MemberMainViewController = .init()
            let navigationController: UINavigationController = .init(rootViewController: viewController)
            navigationController.navigationBar.isHidden = true
            window.rootViewController = navigationController
        }
    }
}

extension SignupMemberTeamViewController: View {
    func bind(reactor: Reactor) {
        // Action
        mainView.and1TeamButton.rx.tap
            .map { Reactor.Action.selectTeam(.and1) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        mainView.and2TeamButton.rx.tap
            .map { Reactor.Action.selectTeam(.and2) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        mainView.iOS1Button.rx.tap
            .map { Reactor.Action.selectTeam(.ios1) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        mainView.iOS2Button.rx.tap
            .map { Reactor.Action.selectTeam(.ios2) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        mainView.web1Button.rx.tap
            .map { Reactor.Action.selectTeam(.web1) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        mainView.web2Button.rx.tap
            .map { Reactor.Action.selectTeam(.web2) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        self.mainView.nextButton.rx.throttleTap.bind { [weak self] in
            self?.reactor?.action.onNext(.didTapNextButton)
        }.disposed(by: self.disposeBag)
        
        self.mainView.backButton.rx.throttleTap.bind { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }.disposed(by: self.disposeBag)
        
        reactor.state.map { $0.member.memberTeam }
            .distinctUntilChanged()
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] team in
                self?.mainView.and1TeamButton.isSelected = team == .and1
                self?.mainView.and2TeamButton.isSelected = team == .and2
                self?.mainView.iOS1Button.isSelected = team == .ios1
                self?.mainView.iOS2Button.isSelected = team == .ios2
                self?.mainView.web1Button.isSelected = team == .web1
                self?.mainView.web2Button.isSelected = team == .web2
                self?.mainView.nextButton.isEnabled = team != nil
                
                if team != nil {
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

