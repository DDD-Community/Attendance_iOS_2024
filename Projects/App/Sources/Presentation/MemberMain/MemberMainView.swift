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

import Model

final class MemberMainView: BaseView {
    // MARK: - UI properties
    private let rootView: UIView = .init()
    
    private let greetingLabel: UILabel = .init().then {
        $0.text = "김디디님 반갑습니다 👋"
        $0.textColor = .basicWhite
        $0.font = .pretendardFontFamily(family: .SemiBold, size: 24)
    }
    
    private let attendanceView: AttendanceStatusView = .init()
    
    let checkInHistoryButton: UIButton = .init().then {
        $0.backgroundColor = .gray800
    }
    
    private let checkInHistoryImageView: UIImageView = .init().then {
        $0.image = .init(named: "icon_history")
        $0.contentMode = .scaleAspectFit
    }
    
    private let checkInHistoryLabel: UILabel = .init().then {
        $0.text = "출석 기록"
        $0.textColor = .gray200
        $0.font = .pretendardFontFamily(family: .Regular, size: 14)
    }
    
    let profileButton: UIButton = .init().then {
        $0.backgroundColor = .gray800
    }
    
    private let profileImageView: UIImageView = .init().then {
        $0.image = .init(named: "icon_person")
        $0.contentMode = .scaleAspectFit
    }
    
    private let profileLabel: UILabel = .init().then {
        $0.text = "프로필"
        $0.textColor = .gray200
        $0.font = .pretendardFontFamily(family: .Regular, size: 14)
    }
    
    let qrCheckInButton: UIButton = .init().then {
        $0.titleLabel?.textColor = .white
    }
    
    private let qrCheckInImageView: UIImageView = .init().then {
        $0.image = .init(named: "icon_qr")
        $0.contentMode = .scaleAspectFit
    }
    
    private let toolTipLabel: UILabel = .init().then {
        $0.text = "QR스캔으로 출석하세요"
        $0.textColor = .basicWhite
        $0.textAlignment = .center
        $0.font = .pretendardFontFamily(family: .Regular, size: 14)
        $0.clipsToBounds = true
    }
    
    private let toolTipTailView: UIImageView = .init().then {
        $0.image = .init(named: "icon_tooltip_tail")
        $0.contentMode = .scaleAspectFill
    }
    
    // MARK: - Properties
    
    // MARK: - Lifecycles
    override func layoutSubviews() {
        super.layoutSubviews()
        layout()
    }
    
    override func configureViews() {
        backgroundColor = .basicBlack
        addSubview(rootView)
        
        rootView.flex.define { flex in
            flex.addItem(greetingLabel)
                .marginTop(60)
                .marginHorizontal(24)
                .marginBottom(24)
            
            flex.addItem(attendanceView)
                .height(80)
                .marginHorizontal(24)
                .marginBottom(16)
            
            flex.addItem()
                .direction(.row)
                .justifyContent(.center)
                .marginHorizontal(24)
                .marginBottom(4)
                .define { flex in
                    flex.addItem(checkInHistoryButton)
                        .aspectRatio(1)
                        .cornerRadius(16)
                        .grow(1)
                        .marginRight(6)
                        .justifyContent(.center)
                        .alignItems(.center)
                        .define { flex in
                            flex.addItem(checkInHistoryImageView)
                                .marginBottom(8)
                                .size(48)
                            flex.addItem(checkInHistoryLabel)
                        }
                    flex.addItem(profileButton)
                        .aspectRatio(1)
                        .cornerRadius(16)
                        .grow(1)
                        .marginLeft(6)
                        .justifyContent(.center)
                        .alignItems(.center)
                        .define { flex in
                            flex.addItem(profileImageView)
                                .marginBottom(8)
                                .size(48)
                            flex.addItem(profileLabel)
                        }
                }
            
            flex.addItem()
                .position(.absolute)
                .bottom(96)
                .alignSelf(.center)
                .alignItems(.center)
                .define { flex in
                    flex.addItem(toolTipLabel)
                        .height(30)
                        .paddingHorizontal(10)
                        .backgroundColor(.gray800)
                        .cornerRadius(8)
                    flex.addItem(toolTipTailView)
                        .height(10)
                        .width(11)
                }
            
            flex.addItem(qrCheckInButton)
                .position(.absolute)
                .bottom(24)
                .alignSelf(.center)
                .height(64)
                .define { flex in
                    flex.addItem(qrCheckInImageView)
                        .size(64)
                }
        }
    }
    
    // MARK: - Public helpers
    func bindAttendances(_ attendances: [Attendance]) {
        attendanceView.bind(attendances: attendances)
        layout()
    }
    
    func bindEvent(_ event: DDDEvent, _ isAttendanceNeeded: Bool) {
        qrCheckInButton.isEnabled = isAttendanceNeeded
        qrCheckInImageView.isHidden = !isAttendanceNeeded
        toolTipLabel.isHidden = !isAttendanceNeeded
        toolTipTailView.isHidden = !isAttendanceNeeded
        
        if !isAttendanceNeeded {
            qrCheckInButton.setTitle("출석 완료!", for: .normal)
            qrCheckInButton.titleLabel?.flex.markDirty()
        }
        layout()
    }
    
    func bindProfile(_ profile: Member) {
        greetingLabel.text = "\(profile.name)님 반갑습니다 👋"
        greetingLabel.flex.markDirty()
        layout()
    }
    
    func hideToolTip() {
        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.toolTipLabel.alpha = 0
            self?.toolTipTailView.alpha = 0
        } completion: { [weak self] _ in
            self?.toolTipLabel.isHidden = true
            self?.toolTipTailView.isHidden = true
        }
    }
    
    // MARK: - Private helpers
    private func layout() {
        rootView.pin.all(pin.safeArea)
        rootView.flex.layout()
    }
}
