//
//  MemberProfileDetailView.swift
//  DDDAttendance
//
//  Created by 고병학 on 7/27/24.
//

import FlexLayout
import PinLayout
import Then

import DesignSystem
import UIKit

final class MemberProfileDetailView: BaseView {
    // MARK: - UI properties
    private let rootView: UIView = .init()
    
    private lazy var navigationBar: UICustomNavigationBar = .init().then {
        $0.addLeftButton(self.backButton)
        $0.addRightButton(self.developerButton)
    }
    
    var backButton: UIButton = .init().then {
        $0.setImage(.init(named: "icon_back"), for: .normal)
    }
    
    var developerButton: UIButton = .init().then {
        $0.setImage(.init(named: "icon_developer"), for: .normal)
    }
    
    private let titleLabel: UILabel = .init().then {
        $0.text = "김디디의 프로필"
        $0.textColor = .basicWhite
        $0.font = .pretendardFontFamily(family: .SemiBold, size: 24)
    }
    
    private let sectionLabel: UILabel = .init().then {
        $0.text = "직군"
        $0.textColor = .gray600
        $0.font = .pretendardFontFamily(family: .SemiBold, size: 14)
    }
    
    private let sectionValueLabel: UILabel = .init().then {
        $0.textColor = .basicWhite
        $0.font = .pretendardFontFamily(family: .SemiBold, size: 24)
    }
    
    private let teamLabel: UILabel = .init().then {
        $0.text = "소속 팀"
        $0.textColor = .gray600
        $0.font = .pretendardFontFamily(family: .SemiBold, size: 14)
    }
    
    private let teamValueLabel: UILabel = .init().then {
        $0.textColor = .basicWhite
        $0.font = .pretendardFontFamily(family: .SemiBold, size: 24)
    }
    
    private let generationLabel: UILabel = .init().then {
        $0.text = "소속 기수"
        $0.textColor = .gray600
        $0.font = .pretendardFontFamily(family: .SemiBold, size: 14)
    }
    
    private let generationValueLabel: UILabel = .init().then {
        $0.textColor = .basicWhite
        $0.font = .pretendardFontFamily(family: .SemiBold, size: 24)
    }
    
    let logoutButton: UIButton = .init()
    
    private let logoutLabel: UILabel = .init().then {
        $0.text = "로그아웃"
        $0.textColor = .gray300
        $0.font = .pretendardFontFamily(family: .Regular, size: 16)
    }
    
    // MARK: - Properties
    
    // MARK: - Lifecycles
    override func configureViews() {
        backgroundColor = .basicBlack
        addSubview(rootView)
        
        rootView.flex.define { flex in
            flex.addItem(navigationBar)
            
            flex.addItem(titleLabel)
                .marginTop(8)
                .marginHorizontal(24)
                .marginBottom(24)
            
            flex.addItem(sectionLabel)
                .marginHorizontal(24)
                .height(30)
            
            flex.addItem(sectionValueLabel)
                .marginHorizontal(24)
                .height(30)
            
            flex.addItem(teamLabel)
                .marginTop(16)
                .marginHorizontal(24)
                .height(30)
            
            flex.addItem(teamValueLabel)
                .marginHorizontal(24)
                .height(30)
            
            flex.addItem(generationLabel)
                .marginTop(16)
                .marginHorizontal(24)
                .height(30)
            
            flex.addItem(generationValueLabel)
                .marginHorizontal(24)
                .height(30)
            
            flex.addItem(logoutButton)
                .position(.absolute)
                .left(24)
                .right(24)
                .bottom(8)
                .height(48)
                .justifyContent(.center)
                .alignItems(.center)
                .define { flex in
                    flex.addItem(logoutLabel)
                }
        }
    }
    
    // MARK: - Public helpers
    func bind(profile: Member) {
        titleLabel.text = "\(profile.name)님의 프로필"
        sectionValueLabel.text = profile.role.desc
        sectionValueLabel.flex.markDirty()
        teamValueLabel.text = "\(profile.memberTeam?.mangingTeamDesc ?? "iOS 1")팀"
        teamValueLabel.flex.markDirty()
        generationValueLabel.text = "\(profile.generation)기"
        generationValueLabel.flex.markDirty()
        layout()
    }
    
    // MARK: - Private helpers
    private func layout() {
        rootView.pin.all(pin.safeArea)
        rootView.flex.layout()
    }
}
