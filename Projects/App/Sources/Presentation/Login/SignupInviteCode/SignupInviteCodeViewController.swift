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
    private var mainView: SignupInviteCodeView { self.view as! SignupInviteCodeView }
    
    // MARK: - Properties
    var disposeBag: DisposeBag = .init()
    
    // MARK: - Lifecycles
    init(uid: String) {
        super.init(nibName: nil, bundle: nil)
        self.reactor = SignupInviteCodeReactor(uid: uid)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        self.view = SignupInviteCodeView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setDelegate()
        self.registerForKeyboardNotifications()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    deinit {
        self.unregisterForKeyboardNotifications()
    }
    // MARK: - Public helpers
    
    // MARK: - Private helpers
    private func setDelegate() {
        self.mainView.codeTextField.delegate = self
    }
    
    private func routeToNextStep(_ memberType: MemberType) {
        guard let uid: String = self.reactor?.currentState.uid else { return }
        self.reactor?.action.onNext(.reset)
        let vc: SignupNameViewController = .init(uid: uid, memberType: memberType)
        self.view.endEditing(true)
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension SignupInviteCodeViewController: ReactorKit.View {
    func bind(reactor: Reactor) {
        self.mainView.backButton.rx.throttleTap.bind { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }.disposed(by: self.disposeBag)
        
        self.mainView.textFieldClearButton.rx.throttleTap.bind { [weak self] in
            self?.mainView.codeTextField.text = ""
        }.disposed(by: self.disposeBag)
        
        mainView.codeTextField.rx.text
            .orEmpty
            .map { Reactor.Action.updateInviteCode($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        mainView.nextButton.rx.throttleTap
            .map { Reactor.Action.checkCode }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.inviteCode }
            .distinctUntilChanged()
            .map { !$0.isEmpty }
            .observe(on: MainScheduler.asyncInstance)
            .bind(to: mainView.nextButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.inviteCode }
            .distinctUntilChanged()
            .map { $0.isEmpty }
            .observe(on: MainScheduler.asyncInstance)
            .bind(to: mainView.textFieldClearButton.rx.isHidden)
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.errorMessage }
            .distinctUntilChanged()
            .observe(on: MainScheduler.asyncInstance)
            .bind { [weak self] errorMessage in
                self?.mainView.codeErrorLabel.text = errorMessage
                self?.mainView.codeErrorLabel.isHidden = errorMessage == nil
            }.disposed(by: disposeBag)
        
        reactor.state.map { $0.memberType }
            .distinctUntilChanged()
            .observe(on: MainScheduler.asyncInstance)
            .bind { [weak self] memberType in
                guard let memberType else { return }
                self?.routeToNextStep(memberType)
            }.disposed(by: disposeBag)
    }
}

extension SignupInviteCodeViewController: UITextFieldDelegate {
    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        let allowedCharacters: CharacterSet = CharacterSet.decimalDigits
        let characterSet: CharacterSet = CharacterSet(charactersIn: string)
        return allowedCharacters.isSuperset(of: characterSet)
    }
}
