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
    init(uid: String) {
        super.init(nibName: nil, bundle: nil)
        self.reactor = Reactor(uid: uid)
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
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.tintColor = .white
    }
    
    deinit {
        self.unregisterForKeyboardNotifications()
    }
    
    // MARK: - Public helpers
    
    // MARK: - Private helpers
    private func pushSignupPartViewController() {
        guard let state = self.reactor?.currentState else { return }
        let signupPartViewController = SignupPartViewController(
            uid: state.uid,
            name: state.name
        )
        self.view.endEditing(true)
        self.navigationController?.pushViewController(
            signupPartViewController,
            animated: true
        )
    }
}

extension SignupNameViewController: View {
    func bind(reactor: SignupNameReactor) {
        mainView.nameTextField.rx.text
            .orEmpty
            .map { SignupNameReactor.Action.setName($0) }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        mainView.nextButton.rx.throttleTap
            .bind { [weak self] in
                self?.pushSignupPartViewController()
            }.disposed(by: self.disposeBag)
        
        reactor.state.map { $0.name }
            .distinctUntilChanged()
            .observe(on: MainScheduler.asyncInstance)
            .map { !$0.isEmpty }
            .bind(to: mainView.nextButton.rx.isEnabled)
            .disposed(by: self.disposeBag)
    }
}
