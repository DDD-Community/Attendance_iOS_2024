//
//  SignupInviteCodeView.swift
//  DDDAttendance
//
//  Created by 고병학 on 6/8/24.
//

import FlexLayout
import PinLayout
import Then

import DesignSystem
import UIKit

final class SignupInviteCodeView: BaseView {
    // MARK: - UI properties
    private let rootView: UIView = .init()
    
    private lazy var navigationBar: UICustomNavigationBar = .init().then {
        $0.addLeftButton(backButton)
    }
    
    let backButton: UIButton = .init().then {
        $0.setImage(UIImage(named: "icon_back"), for: .normal)
    }
    
    private let codeTitleLabel: UILabel = .init().then {
        $0.text = "초대코드를 입력해주세요"
        $0.textColor = .basicWhite
        $0.font = .pretendardFontFamily(family: .SemiBold, size: 24)
    }
    
    let codeTextField: UITextField = .init().then {
        $0.textColor = .white
        $0.font = .systemFont(ofSize: 32, weight: .semibold)
        $0.tintColor = .white
        $0.keyboardType = .numberPad
        $0.textContentType = .oneTimeCode
        $0.attributedPlaceholder = NSAttributedString(
            string: "0000",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.white.withAlphaComponent(0.5)]
        )
    }
    
    let textFieldClearButton: UIButton = .init().then {
        $0.setImage(.init(named: "icon_clear_field"), for: .normal)
    }
    
    let codeErrorLabel: UILabel = .init().then {
        $0.textColor = .systemRed
        $0.font = .systemFont(ofSize: 16, weight: .medium)
        $0.isHidden = true
    }
    
    private let nextButtonContainer: UIView = .init().then {
        $0.backgroundColor = .white
    }
    
    let nextButton: UIButton = .init().then {
        $0.setTitle("가입하기", for: .normal)
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
        backgroundColor = .basicBlack
        addSubview(rootView)
        addSubview(nextButtonContainer)
        
        nextButtonContainer.flex.define { flex in
            flex.addItem(nextButton)
                .width(100%)
                .height(56)
        }
        
        rootView.flex.define { flex in
            flex.addItem(navigationBar)
                .height(56)
                .width(100%)
            
            flex.addItem(codeTitleLabel)
                .marginTop(40)
                .marginBottom(100)
                .marginHorizontal(24)
            
            flex.addItem()
                .direction(.row)
                .alignItems(.center)
                .marginBottom(8)
                .marginHorizontal(24)
                .define { flex in
                    flex.addItem(codeTextField)
                        .grow(1)
                        .height(50)
                    flex.addItem(textFieldClearButton)
                        .size(24)
                }
            
            flex.addItem()
                .backgroundColor(.basicWhite)
                .height(1)
                .marginHorizontal(24)
                .marginBottom(8)
            
            flex.addItem(codeErrorLabel)
                .height(28)
                .marginHorizontal(24)
        }
    }
    
    // MARK: - Public helpers
    
    // MARK: - Private helpers
    private func layout() {
        nextButtonContainer.pin
            .height(56 + pin.safeArea.bottom)
            .horizontally()
            .bottom()
        nextButtonContainer.flex.layout()
        
        rootView.pin.top(pin.safeArea.top)
            .horizontally()
            .bottom()
        rootView.flex.layout()
    }
}
