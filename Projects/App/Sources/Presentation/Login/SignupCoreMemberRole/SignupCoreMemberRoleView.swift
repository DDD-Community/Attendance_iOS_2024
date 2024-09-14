//
//  SignupCoreMemberRoleView.swift
//  DDDAttendance
//
//  Created by 고병학 on 9/14/24.
//

import FlexLayout
import PinLayout
import Then

import DesignSystem
import UIKit

final class SignupCoreMemberRoleView: BaseView {
    // MARK: - UI properties
    private let rootView: UIView = .init()
    
    private lazy var navigationBar: UICustomNavigationBar = .init().then {
        $0.addLeftButton(backButton)
    }
    
    let backButton: UIButton = .init().then {
        $0.setImage(UIImage(named: "icon_back"), for: .normal)
    }
    
    private let partLabel: UILabel = .init().then {
        $0.text = "담당 업무를 선택해주세요"
        $0.textColor = .white
        $0.font = .systemFont(ofSize: 24, weight: .bold)
    }
    
    let teamManagingButton: UIButton = .init().then {
        $0.setTitle("팀 매니징", for: .normal)
        $0.setTitleColor(.gray800, for: .normal)
        $0.setTitleColor(.white, for: .selected)
        $0.titleLabel?.font = .systemFont(ofSize: 32, weight: .bold)
        $0.contentHorizontalAlignment = .leading
    }
    
    let calendarButton: UIButton = .init().then {
        $0.setTitle("일정 관리", for: .normal)
        $0.setTitleColor(.gray800, for: .normal)
        $0.setTitleColor(.white, for: .selected)
        $0.titleLabel?.font = .systemFont(ofSize: 32, weight: .bold)
        $0.contentHorizontalAlignment = .leading
    }
    
    let photoButton: UIButton = .init().then {
        $0.setTitle("사진 촬영", for: .normal)
        $0.setTitleColor(.gray800, for: .normal)
        $0.setTitleColor(.white, for: .selected)
        $0.titleLabel?.font = .systemFont(ofSize: 32, weight: .bold)
        $0.contentHorizontalAlignment = .leading
    }
    
    let rentPlaceButton: UIButton = .init().then {
        $0.setTitle("장소 대관", for: .normal)
        $0.setTitleColor(.gray800, for: .normal)
        $0.setTitleColor(.white, for: .selected)
        $0.titleLabel?.font = .systemFont(ofSize: 32, weight: .bold)
        $0.contentHorizontalAlignment = .leading
    }
    
    let snsManageButton: UIButton = .init().then {
        $0.setTitle("SNS 관리", for: .normal)
        $0.setTitleColor(.gray800, for: .normal)
        $0.setTitleColor(.white, for: .selected)
        $0.titleLabel?.font = .systemFont(ofSize: 32, weight: .bold)
        $0.contentHorizontalAlignment = .leading
    }
    
    let attendanceCheckButton: UIButton = .init().then {
        $0.setTitle("출석 체크", for: .normal)
        $0.setTitleColor(.gray800, for: .normal)
        $0.setTitleColor(.white, for: .selected)
        $0.titleLabel?.font = .systemFont(ofSize: 32, weight: .bold)
        $0.contentHorizontalAlignment = .leading
    }
    
    private let nextButtonContainer: UIView = .init().then {
        $0.backgroundColor = .white
    }
    
    let nextButton: UIButton = .init().then {
        $0.setTitle("다음", for: .normal)
        $0.setTitleColor(.black, for: .normal)
        $0.setTitleColor(.systemGray4, for: .disabled)
        $0.titleLabel?.font = .systemFont(ofSize: 24, weight: .semibold)
        $0.isEnabled = false
    }
    
    // MARK: - Properties
    
    // MARK: - Lifecycles
    override func layoutSubviews() {
        super.layoutSubviews()
        layout()
    }
    
    override func configureViews() {
        backgroundColor = .black
        addSubview(rootView)
        rootView.flex.define { flex in
            flex.addItem(navigationBar)
                .height(56)
                .width(100%)
            
            flex.addItem(partLabel)
                .marginTop(50)
                .marginHorizontal(32)
                .marginBottom(48)
                .height(26)
            
            flex.addItem()
                .marginHorizontal(32)
                .rowGap(24)
                .define { flex in
                    flex.addItem(teamManagingButton)
                        .height(38)
                    
                    flex.addItem(calendarButton)
                        .height(38)
                    
                    flex.addItem(photoButton)
                        .height(38)
                    
                    flex.addItem(rentPlaceButton)
                        .height(38)
                    
                    flex.addItem(snsManageButton)
                        .height(38)
                    
                    flex.addItem(attendanceCheckButton)
                        .height(38)
                }
        }
        
        addSubview(nextButtonContainer)
        nextButtonContainer.flex.define { flex in
            flex.addItem(nextButton)
                .width(100%)
                .height(50)
        }
        
    }
    
    // MARK: - Public helpers
    
    // MARK: - Private helpers
    private func layout() {
        nextButtonContainer.pin
            .height(50 + pin.safeArea.bottom)
            .horizontally()
            .bottom()
        nextButtonContainer.flex.layout()
        
        rootView.pin.all(pin.safeArea)
        rootView.flex.layout()
    }
}
