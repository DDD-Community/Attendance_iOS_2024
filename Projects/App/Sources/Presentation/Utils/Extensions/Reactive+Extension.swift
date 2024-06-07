//
//  Reactive+Extension.swift
//  DDDAttendance
//
//  Created by 고병학 on 6/6/24.
//

import UIKit

import RxSwift

// MARK: - UIButton
extension Reactive where Base: UIButton {
    public var throttleTap: Observable<Void> {
        return self.tap.throttle(RxTimeInterval.milliseconds(500), scheduler: MainScheduler.instance)
    }
}


