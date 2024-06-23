//
//  MemberMainView.swift
//  DDDAttendance
//
//  Created by 고병학 on 6/8/24.
//

import FlexLayout
import PinLayout
import Then

import UIKit

final class MemberMainView: BaseView {
    // MARK: - UI properties
    private let rootView: UIView = .init()
    
    private let scrollView: UIScrollView = .init()
    
    private let scrollContentView: UIView = .init()
    
    let checkInStatusTitleLabel: UILabel = .init().then {
        $0.text = "🙋 출석 현황"
        $0.font = .systemFont(ofSize: 20)
    }
    
    let checkInStatusLabel: UILabel = .init().then {
        $0.text = "출석 1회 | 지각 1회 | 결석 1회"
        $0.textColor = .black
        $0.font = .systemFont(ofSize: 20, weight: .semibold)
    }
    
    let qrCheckInButton: UIButton = .init().then {
        $0.setTitle("QR 출석", for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 24, weight: .semibold)
        $0.backgroundColor = .black
    }
    
    let checkInHistoryButton: UIButton = .init().then {
        $0.setTitle("출석 기록", for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 20, weight: .semibold)
        $0.backgroundColor = .black
    }
    
    let profileButton: UIButton = .init().then {
        $0.setTitle("프로필", for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 20, weight: .semibold)
        $0.backgroundColor = .black
    }
    
    let logoutButton: UIButton = .init().then {
        $0.setTitle("로그아웃", for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 20, weight: .semibold)
        $0.backgroundColor = .black
    }
    
    // MARK: - Properties
    
    // MARK: - Lifecycles
    override func layoutSubviews() {
        super.layoutSubviews()
        layout()
    }
    
    override func configureViews() {
        backgroundColor = .white
        addSubview(rootView)
        scrollView.addSubview(scrollContentView)
        
        rootView.flex.define { flex in
            flex.addItem(scrollView)
                .grow(1)
        }
        
        scrollContentView.flex.define { flex in
            
            flex.addItem(checkInStatusTitleLabel)
                .marginTop(16)
                .marginHorizontal(16)
                .marginBottom(12)
                .height(20)
            flex.addItem(checkInStatusLabel)
                .marginHorizontal(16)
                .marginBottom(16)
                .height(20)
            
            flex.addItem()
                .direction(.row)
                .justifyContent(.center)
                .columnGap(4)
                .marginBottom(4)
                .height(150)
                .define { flex in
                    flex.addItem(qrCheckInButton)
                        .maxWidth(65%)
                        .grow(1)
                        .cornerRadius(12)
                        .marginLeft(16)
                    
                    flex.addItem()
                        .maxWidth(35%)
                        .grow(1)
                        .rowGap(4)
                        .marginRight(16)
                        .define { flex in
                            flex.addItem(profileButton)
                                .cornerRadius(12)
                                .grow(1)
                            flex.addItem(checkInHistoryButton)
                                .cornerRadius(12)
                                .grow(1)
                        }
                }
            
            flex.addItem(logoutButton)
                .marginHorizontal(16)
                .height(80)
                .cornerRadius(12)
        }
    }
    
    // MARK: - Public helpers
    func bindAttendances(_ attendances: [Attendance]) {
        let attendances = attendances.reduce(into: (attendance: 0, late: 0, absent: 0)) { result, attendance in
            switch attendance.attendanceType {
            case .present:
                result.attendance += 1
            case .late:
                result.late += 1
            case .absent:
                result.absent += 1
            default: return
            }
        }
        checkInStatusLabel.text = "출석 \(attendances.attendance)회 | 지각 \(attendances.late)회 | 결석 \(attendances.absent)회"
    }
    
    func bindEvent(_ event: DDDEvent, _ isAttendanceNeeded: Bool) {
        qrCheckInButton.isEnabled = isAttendanceNeeded
        if isAttendanceNeeded {
            qrCheckInButton.setTitle("QR 출석 👉", for: .normal)
            qrCheckInButton.backgroundColor = .black
        } else {
            qrCheckInButton.setTitle("출석 불필요", for: .normal)
            qrCheckInButton.backgroundColor = .gray
        }
    }
    
    // MARK: - Private helpers
    private func layout() {
        rootView.pin.top(pin.safeArea.top)
            .left(pin.safeArea.left)
            .right(pin.safeArea.right)
            .bottom()
        rootView.flex.layout()
        scrollView.contentSize = scrollContentView.frame.size
    }
}
