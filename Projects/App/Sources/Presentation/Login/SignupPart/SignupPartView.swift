//
//  SignupPartView.swift
//  DDDAttendance
//
//  Created by 고병학 on 6/8/24.
//

import FlexLayout
import PinLayout
import Then

import UIKit

final class SignupPartView: BaseView {
    // MARK: - UI properties
    private let rootView: UIView = .init()
    
    private let partLabel: UILabel = .init().then {
        $0.text = "파트를 선택해주세요"
        $0.textColor = .white
        $0.textAlignment = .center
        $0.font = .systemFont(ofSize: 24, weight: .semibold)
    }
    
    let iOSButton: UIButton = .init().then {
        $0.setTitle("iOS", for: .normal)
        $0.setTitle("✅ iOS", for: .selected)
        $0.setTitleColor(.black, for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 24, weight: .semibold)
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 10
    }
    
    let webButton: UIButton = .init().then {
        $0.setTitle("WEB", for: .normal)
        $0.setTitle("✅ WEB", for: .selected)
        $0.setTitleColor(.black, for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 24, weight: .semibold)
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 10
    }
    
    let serverButton: UIButton = .init().then {
        $0.setTitle("SERVER", for: .normal)
        $0.setTitle("✅ SERVER", for: .selected)
        $0.setTitleColor(.black, for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 24, weight: .semibold)
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 10
    }
    
    let androidButton: UIButton = .init().then {
        $0.setTitle("ANDROID", for: .normal)
        $0.setTitle("✅ ANDROID", for: .selected)
        $0.setTitleColor(.black, for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 24, weight: .semibold)
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 10
    }
    
    let designerButton: UIButton = .init().then {
        $0.setTitle("DESIGNER", for: .normal)
        $0.setTitle("✅ DESIGNER", for: .selected)
        $0.setTitleColor(.black, for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 24, weight: .semibold)
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 10
    }
    
    let pmButton: UIButton = .init().then {
        $0.setTitle("PM", for: .normal)
        $0.setTitle("✅ PM", for: .selected)
        $0.setTitleColor(.black, for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 24, weight: .semibold)
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 10
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
            flex.addItem(partLabel)
                .marginTop(40)
                .marginBottom(20)
                .width(100%)
            
            flex.addItem()
                .direction(.row)
                .wrap(.wrap)
                .justifyContent(.center)
                .columnGap(10)
                .rowGap(10)
                .define { flex in
                    flex.addItem(iOSButton)
                        .width(45%)
                        .height(60)
                    
                    flex.addItem(webButton)
                        .width(45%)
                        .height(60)
                    
                    flex.addItem(serverButton)
                        .width(45%)
                        .height(60)
                    
                    flex.addItem(androidButton)
                        .width(45%)
                        .height(60)
                    
                    flex.addItem(designerButton)
                        .width(45%)
                        .height(60)
                    
                    flex.addItem(pmButton)
                        .width(45%)
                        .height(60)
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

