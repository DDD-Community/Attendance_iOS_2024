//
//  MemberAttendanceHistoryViewController.swift
//  DDDAttendance
//
//  Created by 고병학 on 6/27/24.
//

import ReactorKit

import UIKit

final class MemberAttendanceHistoryViewController: UIViewController {
    
    typealias Reactor = MemberAttendanceHistoryReactor
    
    // MARK: - UI properties
    private var mainView: MemberAttendanceHistoryView { view as! MemberAttendanceHistoryView }
    
    // MARK: - Properties
    var disposeBag: DisposeBag = .init()
    
    // MARK: - Lifecycles
    override func loadView() {
        view = MemberAttendanceHistoryView()
        reactor = Reactor()
    }
    
    // MARK: - Public helpers
    
    // MARK: - Private helpers
}

extension MemberAttendanceHistoryViewController: View {
    func bind(reactor: Reactor) {
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
        
        reactor.state.map { $0.attendanceList }
            .distinctUntilChanged()
            .observe(on: MainScheduler.asyncInstance)
            .bind { [weak self] attendances in
                self?.mainView.bind(attendances: attendances)
            }.disposed(by: disposeBag)
    }
    
    private func bindAction(_ reactor: Reactor) {
        mainView.backButton.rx.throttleTap.bind{ [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }.disposed(by: disposeBag)
    }
}
