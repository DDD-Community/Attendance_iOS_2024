//
//  SplashView.swift
//  DDDAttendance
//
//  Created by 고병학 on 6/6/24.
//

import FlexLayout
import PinLayout
import Then
import Gifu

import UIKit

final class SplashView: BaseView {
    
    private let animatedImageView: GIFImageView = {
        let imageView = GIFImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    // MARK: - Properties
    
    // MARK: - Lifecycles
    override func layoutSubviews() {
        super.layoutSubviews()
        layout()
    }
    
    override func configureViews() {
        backgroundColor = .basicBlack
        
        if let gifURL = Bundle.main.url(forResource: "DDDLoding", withExtension: "gif") {
            animatedImageView.animate(withGIFURL: gifURL)
        }
        
        flex.justifyContent(.center)
            .alignItems(.center)
            .define { flex in
                flex.addItem(animatedImageView)
                    .width(200)
                    .height(200)
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
