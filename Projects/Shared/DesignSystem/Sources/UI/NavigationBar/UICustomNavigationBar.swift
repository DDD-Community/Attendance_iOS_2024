//
//  UICustomNavigationBar.swift
//  DesignSystem
//
//  Created by 고병학 on 7/27/24.
//

import FlexLayout
import PinLayout

import UIKit

public final class UICustomNavigationBar: UIView {
    
    // MARK: - UI properties
    private let rootView: UIView = .init()
    
    private let leftContainer: UIView = .init()
    
    private let rightContainer: UIView = .init()
    
    public private(set) var leftButtons: [UIButton] = []
    
    public private(set) var rightButtons: [UIButton] = []
    
    // MARK: - Properties
    
    // MARK: - Lifecycles
    public init() {
        super.init(frame: .zero)
        configureViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureViews() {
        addSubview(rootView)
        
        rootView.flex
            .direction(.row)
            .justifyContent(.spaceBetween)
            .alignItems(.center)
            .paddingHorizontal(8)
            .height(56)
            .define { flex in
                flex.addItem(leftContainer)
                    .height(100%)
                    .grow(1)
                    .columnGap(8)
                    .direction(.row)
                    .alignItems(.center)
                flex.addItem(rightContainer)
                    .height(100%)
                    .grow(1)
                    .columnGap(8)
                    .direction(.rowReverse)
                    .alignItems(.center)
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        layout()
    }
    
    // MARK: - Public helpers
    public func addLeftButton(_ button: UIButton) {
        self.leftButtons.append(button)
        self.leftContainer.flex.define { flex in
            flex.addItem(button)
        }
    }
    
    public func addLeftButtons(_ buttons: [UIButton]) {
        self.leftButtons.append(contentsOf: buttons)
        self.leftContainer.flex.define { flex in
            buttons.forEach { button in
                flex.addItem(button)
            }
        }
    }
    
    public func clearLeftButtons() {
        self.leftButtons.removeAll()
        self.leftContainer.subviews.forEach { $0.removeFromSuperview() }
    }
    
    public func addRightButton(_ button: UIButton) {
        self.rightButtons.append(button)
        self.rightContainer.flex.define { flex in
            flex.addItem(button)
        }
    }
    
    public func addRightButtons(_ buttons: [UIButton]) {
        self.rightButtons.append(contentsOf: buttons)
        self.rightContainer.flex.define { flex in
            buttons.forEach { button in
                flex.addItem(button)
            }
        }
    }
    
    public func clearRightButtons() {
        self.rightButtons.removeAll()
        self.rightContainer.subviews.forEach { $0.removeFromSuperview() }
    }
    
    public func clearButtons() {
        clearLeftButtons()
        clearRightButtons()
    }
    
    // MARK: - Private helpers
    private func layout() {
        rootView.pin.all()
        rootView.flex.layout()
    }
}
