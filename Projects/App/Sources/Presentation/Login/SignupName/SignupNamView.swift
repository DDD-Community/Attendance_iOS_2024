//
//  SignupNamView.swift
//  DDDAttendance
//
//  Created by 고병학 on 6/8/24.
//

import FlexLayout
import PinLayout
import Then

import DesignSystem
import UIKit

final class SignupNamView: BaseView {
    
    // MARK: - UI properties
    private let rootView: UIView = .init()
    
    private lazy var navigationBar: UICustomNavigationBar = .init().then {
        $0.addLeftButton(backButton)
    }
    
    let backButton: UIButton = .init().then {
        $0.setImage(UIImage(named: "icon_back"), for: .normal)
    }
    
    private let nameTitleLabel: UILabel = .init().then {
        $0.text = "이름이 어떻게 되시나요?"
        $0.textColor = .white
        $0.font = .systemFont(ofSize: 24, weight: .bold)
    }
    
    private let nameSubTitleLabel: UILabel = .init().then {
        $0.text = "본명으로 입력해주세요."
        $0.textColor = .gray400
        $0.font = .systemFont(ofSize: 16)
    }
    
    let nameTextField: UITextField = .init().then {
        $0.textColor = .white
        $0.font = .systemFont(ofSize: 32, weight: .semibold)
        $0.tintColor = .white
        $0.textContentType = .name
        $0.attributedPlaceholder = NSAttributedString(
            string: "이름을 입력해주세요",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.white.withAlphaComponent(0.5)]
        )
    }
    
    let textFieldClearButton: UIButton = .init().then {
        $0.setImage(.init(named: "icon_clear_field"), for: .normal)
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
            flex.addItem(navigationBar)
                .height(56)
                .width(100%)
            
            flex.addItem(nameTitleLabel)
                .height(26)
                .marginTop(50)
                .marginHorizontal(32)
                .marginBottom(10)
            
            flex.addItem(nameSubTitleLabel)
                .height(16)
                .marginHorizontal(32)
                .marginBottom(80)
            
            flex.addItem()
                .direction(.row)
                .alignItems(.center)
                .marginHorizontal(32)
                .marginBottom(8)
                .define { flex in
                    flex.addItem(nameTextField)
                        .height(50)
                        .grow(1)
                    flex.addItem(textFieldClearButton)
                        .size(24)
                }
            
            flex.addItem()
                .backgroundColor(.basicWhite)
                .height(1)
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
