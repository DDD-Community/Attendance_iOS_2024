//
//  SignupInviteCodeView.swift
//  DDDAttendance
//
//  Created by 고병학 on 6/8/24.
//

import FlexLayout
import PinLayout
import Then

import UIKit

final class SignupInviteCodeView: BaseView {
    // MARK: - UI properties
    private let rootView: UIView = .init()
    
    private let codeTitleLabel: UILabel = .init().then {
        $0.text = "초대코드"
        $0.textColor = .white
        $0.textAlignment = .center
        $0.font = .systemFont(ofSize: 24, weight: .semibold)
    }
    
    let codeTextField: UITextField = .init().then {
        $0.textColor = .white
        $0.textAlignment = .center
        $0.font = .systemFont(ofSize: 32, weight: .semibold)
        $0.tintColor = .white
        $0.keyboardType = .numberPad
        $0.textContentType = .oneTimeCode
        $0.attributedPlaceholder = NSAttributedString(
            string: "초대코드를 입력해주세요",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.white.withAlphaComponent(0.5)]
        )
    }
    
    private let nextButtonContainer: UIView = .init().then {
        $0.backgroundColor = .white
    }
    
    let nextButton: UIButton = .init().then {
        $0.setTitle("회원가입 하기", for: .normal)
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
        addSubview(nextButtonContainer)
        
        nextButtonContainer.flex.define { flex in
            flex.addItem(nextButton)
                .width(100%)
                .height(50)
        }
        
        rootView.flex.define { flex in
            flex.addItem(codeTitleLabel)
                .marginTop(40)
                .marginBottom(20)
            flex.addItem(codeTextField)
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
        
        rootView.pin.top(pin.safeArea.top)
            .horizontally()
            .bottom()
        rootView.flex.layout()
    }
}
