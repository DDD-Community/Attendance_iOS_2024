//
//  SNSLoginViewController.swift
//  DDDAttendance
//
//  Created by 고병학 on 6/6/24.
//

import ReactorKit

import UIKit

final class SNSLoginViewController: UIViewController {
    typealias Reactor = SNSLoginReactor
    
    // MARK: - UI properties
    private var mainView: SNSLoginView { view as! SNSLoginView }
    
    // MARK: - Properties
    var disposeBag: DisposeBag = .init()
    
    // MARK: - Lifecycles
    override func loadView() {
        view = SNSLoginView()
        reactor = SNSLoginReactor()
    }
    
    // MARK: - Public helpers
    
    // MARK: - Private helpers
}

extension SNSLoginViewController: View {
    func bind(reactor: Reactor) {
        mainView.coreMemberCheckSwitch.rx
            .controlEvent(.valueChanged)
            .map { [unowned self] in self.mainView.coreMemberCheckSwitch.isOn }
            .map(Reactor.Action.toggleIsCoreMember)
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        mainView.appleLoginButton.rx.throttleTap
            .map { Reactor.Action.didTapAppleLogin }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        mainView.googleLoginButton.rx.throttleTap
            .map { Reactor.Action.didTapGoogleLogin }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
}
