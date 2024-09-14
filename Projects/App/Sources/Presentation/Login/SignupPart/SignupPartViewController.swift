//
//  SignupPartViewController.swift
//  DDDAttendance
//
//  Created by 고병학 on 6/6/24.
//

import ReactorKit

import UIKit

final class SignupPartViewController: UIViewController {
    
    typealias Reactor = SignupPartReactor
    
    // MARK: - UI properties
    private var mainView: SignupPartView { view as! SignupPartView }
    
    // MARK: - Properties
    var disposeBag: DisposeBag = .init()
    
    // MARK: - Lifecycles
    init(
        uid: String,
        name: String
    ) {
        super.init(nibName: nil, bundle: nil)
        self.reactor = Reactor(uid: uid, name: name)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = SignupPartView()
    }
    
    // MARK: - Public helpers
    
    // MARK: - Private helpers
    private func pushSignupInviteCodeViewController() {
        guard let state = self.reactor?.currentState,
              let part = state.selectedPart else {
            return
        }
        let inviteCodeVC = SignupInviteCodeViewController(uid: state.uid)
        self.navigationController?.pushViewController(
            inviteCodeVC,
            animated: true
        )
    }
}

extension SignupPartViewController: View {
    func bind(reactor: SignupPartReactor) {
        // Action
        mainView.iOSButton.rx.tap
            .map { Reactor.Action.selectPart(.iOS) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        mainView.webButton.rx.tap
            .map { Reactor.Action.selectPart(.web) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        mainView.serverButton.rx.tap
            .map { Reactor.Action.selectPart(.server) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        mainView.androidButton.rx.tap
            .map { Reactor.Action.selectPart(.android) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        mainView.designerButton.rx.tap
            .map { Reactor.Action.selectPart(.design) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        mainView.pmButton.rx.tap
            .map { Reactor.Action.selectPart(.pm) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        mainView.nextButton.rx.tap
            .bind { [weak self] in
                self?.pushSignupInviteCodeViewController()
            }.disposed(by: disposeBag)
        
        reactor.state.map { $0.selectedPart }
            .distinctUntilChanged()
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] part in
                self?.mainView.iOSButton.isSelected = part == .iOS
                self?.mainView.webButton.isSelected = part == .web
                self?.mainView.serverButton.isSelected = part == .server
                self?.mainView.androidButton.isSelected = part == .android
                self?.mainView.designerButton.isSelected = part == .design
                self?.mainView.pmButton.isSelected = part == .pm
                
                self?.mainView.nextButton.isEnabled = part != nil
            })
            .disposed(by: self.disposeBag)
    }
}
