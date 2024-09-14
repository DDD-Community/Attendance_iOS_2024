//
//  SignupNameViewController.swift
//  DDDAttendance
//
//  Created by 고병학 on 6/6/24.
//

import ReactorKit

import UIKit

final class SignupNameViewController: UIViewController {
    typealias Reactor = SignupNameReactor
    
    // MARK: - UI properties
    private var mainView: SignupNamView { view as! SignupNamView }
    
    // MARK: - Properties
    var disposeBag: DisposeBag = .init()
    
    // MARK: - Lifecycles
    init(uid: String, memberType: MemberType) {
        super.init(nibName: nil, bundle: nil)
        self.reactor = Reactor(
            uid: uid,
            memberType: memberType
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = SignupNamView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
    private func pushSignupPartViewController() {
        guard let member: MemberRequestModel = self.reactor?.currentState.member else { return }
        let vc: SignupPartViewController = .init(member)
        self.view.endEditing(true)
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension SignupNameViewController: View {
    func bind(reactor: SignupNameReactor) {
        self.mainView.backButton.rx.throttleTap.bind { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }.disposed(by: self.disposeBag)
        
        self.mainView.nameTextField.rx.text
            .orEmpty
            .map { SignupNameReactor.Action.setName($0) }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        self.mainView.textFieldClearButton.rx.throttleTap.bind { [weak self] in
            self?.mainView.nameTextField.text = ""
        }.disposed(by: self.disposeBag)
        
        self.mainView.nextButton.rx.throttleTap
            .bind { [weak self] in
                self?.pushSignupPartViewController()
            }.disposed(by: self.disposeBag)
        
        reactor.state.map { $0.member.name }
            .distinctUntilChanged()
            .compactMap { $0 }
            .observe(on: MainScheduler.asyncInstance)
            .map { !$0.isEmpty }
            .bind(to: mainView.nextButton.rx.isEnabled)
            .disposed(by: self.disposeBag)
    }
}
