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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.reactor?.action.onNext(.fetchData)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.hideTooltip(after: 5)
    }
    
    // MARK: - Public helpers
    
    // MARK: - Private helpers
    private func presentQRLoginView() {
        guard let profile: Member = reactor?.currentState.userProfile else {
            return
        }
        let vc: QRCheckInViewController = .init(profile: profile)
        vc.delegate = self
        self.present(vc, animated: true)
    }
    
    private func showAlert(title: String, message: String) {
        let alert: UIAlertController = .init(title: title, message: message, preferredStyle: .alert)
        alert.addAction(.init(title: "확인", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    private func hideTooltip(after: Int) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(after)) { [weak self] in
            self?.mainView.hideToolTip()
        }
    }
}

extension MemberMainViewController: View {
    func bind(reactor: Reactor) {
        bindState(reactor)
        bindAction(reactor)
    }
    
    private func bindState(_ reactor: Reactor) {
        reactor.state.map { $0.userAttendanceHistory }
            .distinctUntilChanged()
            .compactMap { $0 }
            .observe(on: MainScheduler.asyncInstance)
            .bind { [weak self] attendances in
                self?.mainView.bindAttendances(attendances)
            }.disposed(by: disposeBag)
        
        reactor.state.map { ($0.todayEvent, $0.isAttendanceNeeded) }
            .observe(on: MainScheduler.asyncInstance)
            .bind { [weak self] event, isAttendanceNeeded in
                guard let event,
                      let isAttendanceNeeded else {
                    return
                }
                self?.mainView.bindEvent(event, isAttendanceNeeded)
            }.disposed(by: disposeBag)
        
        reactor.state.map { $0.userProfile }
            .distinctUntilChanged()
            .compactMap { $0 }
            .observe(on: MainScheduler.asyncInstance)
            .bind { [weak self] profile in
                self?.mainView.bindProfile(profile)
            }.disposed(by: disposeBag)
    }
    
    private func bindAction(_ reactor: Reactor) {
        mainView.qrCheckInButton.rx.throttleTap.bind { [weak self] in
            self?.presentQRLoginView()
        }.disposed(by: disposeBag)
        
        mainView.checkInHistoryButton.rx.throttleTap.bind { [weak self] in
            let vc: MemberAttendanceHistoryViewController = .init()
            self?.navigationController?.pushViewController(vc, animated: true)
        }.disposed(by: disposeBag)
        
        mainView.profileButton.rx.throttleTap.bind { [weak self] in
            let vc: MemberProfileDetailViewController = .init()
            self?.navigationController?.pushViewController(vc, animated: true)
        }.disposed(by: disposeBag)
    }
}

extension MemberMainViewController: QRCheckInViewControllerDelegate {
    func qrCheckInViewDismissed() {
        self.reactor?.action.onNext(.fetchData)
    }
}
