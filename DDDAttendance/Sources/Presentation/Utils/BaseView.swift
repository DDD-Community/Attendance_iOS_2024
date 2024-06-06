//
//  BaseView.swift
//  DDDAttendance
//
//  Created by 고병학 on 6/6/24.
//

import UIKit

class BaseView: UIView {
    
    init() {
        super.init(frame: .zero)
        configureLayout()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureLayout() {}
}
