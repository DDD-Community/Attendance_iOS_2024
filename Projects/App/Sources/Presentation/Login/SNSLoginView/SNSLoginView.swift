//
//  SNSLoginView.swift
//  DDDAttendance
//
//  Created by 고병학 on 6/6/24.
//

import FlexLayout
import PinLayout
import Then

import UIKit
import DesignSystem

final class SNSLoginView: BaseView {
    // MARK: - UI properties
    private let rootView: UIView = .init()
    
    private let dddLabel: UILabel = .init().then {
        $0.text = "DDD"
        $0.textColor = .white
        $0.textAlignment = .center
        $0.font = .systemFont(ofSize: 48, weight: .bold)
    }
    
    let appleLoginButton: UIButton = .init().then {
        $0.setTitle(" Apple로 계속하기", for: .normal)
        $0.setTitleColor(.black, for: .normal)
        $0.setImage(UIImage(systemName: "apple.logo"), for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        $0.backgroundColor = .white
        $0.tintColor = .black
        $0.layer.cornerRadius = 28
    }
    
    let googleLoginButton: UIButton = .init().then {
        $0.setTitle("Google로 계속하기", for: .normal)
    }
    
    // MARK: - Properties
    
    // MARK: - Lifecycles
    override func layoutSubviews() {
        super.layoutSubviews()
        layout()
    }
    
    override func configureViews() {
        backgroundColor = UIColor.basicBlack
        addSubview(rootView)
        
        rootView.flex.justifyContent(.spaceBetween).define { flex in
            flex.addItem(dddLabel)
                .width(100%)
                .marginTop(100)
            
            flex.addItem().define { flex in
                flex.addItem(appleLoginButton)
                    .height(56)
                    .marginHorizontal(16)
                    .marginBottom(20)
                flex.addItem(googleLoginButton)
                    .height(56)
                    .cornerRadius(28)
                    .marginHorizontal(16)
            }
        }
    }
    
    // MARK: - Public helpers
    
    // MARK: - Private helpers
    private func layout() {
        rootView.pin.all(pin.safeArea)
        rootView.flex.layout()
    }
}

//#Preview {
//    SNSLoginView()
//}
