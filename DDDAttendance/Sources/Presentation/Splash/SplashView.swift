//
//  SplashView.swift
//  DDDAttendance
//
//  Created by 고병학 on 6/6/24.
//

import FlexLayout
import PinLayout
import Then

import UIKit

final class SplashView: BaseView {
    
    // MARK: - UI properties
    private let label: UILabel = .init().then {
        $0.text = "DDD"
        $0.textColor = .white
        $0.font = .systemFont(ofSize: 64, weight: .black)
        $0.textAlignment = .center
    }
    
    // MARK: - Properties
    
    // MARK: - Lifecycles
    override func layoutSubviews() {
        super.layoutSubviews()
        layout()
    }
    
    override func configureViews() {
        backgroundColor = .black
        flex.justifyContent(.center)
            .alignItems(.center)
            .define { flex in
                flex.addItem(label)
                    .width(100%)
            }
    }
    
    // MARK: - Public helpers
    
    // MARK: - Private helpers
    private func layout() {
        flex.layout()
    }
}

#Preview {
    SplashView()
}
