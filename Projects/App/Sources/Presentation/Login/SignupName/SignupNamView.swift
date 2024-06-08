//
//  SignupNamView.swift
//  DDDAttendance
//
//  Created by 고병학 on 6/8/24.
//

import FlexLayout
import PinLayout
import Then

import UIKit

final class SignupNamView: BaseView {
    
    // MARK: - UI properties
    private let rootView: UIView = .init()
    
    private let nameTitleLabel: UILabel = .init().then {
        $0.text = "이름"
        $0.textColor = .white
        $0.textAlignment = .center
        $0.font = .systemFont(ofSize: 24, weight: .semibold)
    }
    
    let nameTextField: UITextField = .init().then {
        $0.textColor = .white
        $0.textAlignment = .center
        $0.font = .systemFont(ofSize: 32, weight: .semibold)
        $0.tintColor = .white
        $0.textContentType = .name
        $0.attributedPlaceholder = NSAttributedString(
            string: "이름을 입력해주세요",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.white.withAlphaComponent(0.5)]
        )
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
        addSubview(nextButtonContainer)
        
        nextButtonContainer.flex.define { flex in
            flex.addItem(nextButton)
                .width(100%)
                .height(50)
        }
        
        rootView.flex.define { flex in
            flex.addItem(nameTitleLabel)
                .marginTop(40)
                .marginBottom(20)
            flex.addItem(nameTextField)
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
