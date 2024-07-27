//
//  AttendanceStatusView.swift
//  DDDAttendance
//
//  Created by 고병학 on 7/27/24.
//

import FlexLayout
import PinLayout
import Then

import UIKit

final class AttendanceStatusView: BaseView {
    // MARK: - UI properties
    private let rootView: UIView = .init()
    
    private let presentLabel: UILabel = .init().then {
        $0.text = "출석"
        $0.font = .pretendardFontFamily(family: .Regular, size: 14)
        $0.textColor = .gray400
    }
    
    private let presentCountLabel: UILabel = .init().then {
        $0.text = "0회"
        $0.font = .pretendardFontFamily(family: .SemiBold, size: 18)
        $0.textColor = .basicWhite
    }
    
    private let lateLabel: UILabel = .init().then {
        $0.text = "지각"
        $0.font = .pretendardFontFamily(family: .Regular, size: 14)
        $0.textColor = .gray400
    }
    
    private let lateCountLabel: UILabel = .init().then {
        $0.text = "0회"
        $0.font = .pretendardFontFamily(family: .SemiBold, size: 18)
        $0.textColor = .basicWhite
    }
    
    private let absentLabel: UILabel = .init().then {
        $0.text = "결석"
        $0.font = .pretendardFontFamily(family: .Regular, size: 14)
        $0.textColor = .gray400
    }
    
    private let absentCountLabel: UILabel = .init().then {
        $0.text = "0회"
        $0.font = .pretendardFontFamily(family: .SemiBold, size: 18)
        $0.textColor = .basicWhite
    }
    
    // MARK: - Properties
    
    // MARK: - Lifecycles
    override func layoutSubviews() {
        super.layoutSubviews()
        layout()
    }
    
    override func configureViews() {
        addSubview(rootView)
        rootView.flex.define { flex in
            flex.addItem()
                .direction(.row)
                .alignItems(.center)
                .justifyContent(.center)
                .height(80)
                .backgroundColor(.gray800.withAlphaComponent(0.4))
                .cornerRadius(16)
                .columnGap(30)
                .define { flex in
                    flex.addItem()
                        .justifyContent(.center)
                        .alignItems(.center)
                        .define { flex in
                            flex.addItem(presentLabel)
                                .marginBottom(8)
                                .height(14)
                            flex.addItem(presentCountLabel)
                                .height(18)
                        }
                    
                    flex.addItem()
                        .height(48)
                        .width(1)
                        .backgroundColor(.gray600)
                    
                    flex.addItem()
                        .justifyContent(.center)
                        .alignItems(.center)
                        .define { flex in
                            flex.addItem(lateLabel)
                                .marginBottom(8)
                                .height(14)
                            flex.addItem(lateCountLabel)
                                .height(18)
                        }
                    
                    flex.addItem()
                        .height(48)
                        .width(1)
                        .backgroundColor(.gray600)
                    
                    flex.addItem()
                        .justifyContent(.center)
                        .alignItems(.center)
                        .define { flex in
                            flex.addItem(absentLabel)
                                .marginBottom(8)
                                .height(14)
                            flex.addItem(absentCountLabel)
                                .height(18)
                        }
                }
        }
    }
    
    // MARK: - Public helpers
    func bind(attendances: [Attendance]) {
        let attendances = attendances.reduce(into: (attendance: 0, late: 0, absent: 0)) { result, attendance in
            switch attendance.status {
            case .present:
                result.attendance += 1
            case .late:
                result.late += 1
            case .absent:
                result.absent += 1
            default: return
            }
        }
        
        presentCountLabel.text = "\(attendances.attendance)회"
        presentCountLabel.flex.markDirty()
        
        lateCountLabel.text = "\(attendances.late)회"
        lateCountLabel.flex.markDirty()
        
        absentCountLabel.text = "\(attendances.absent)회"
        absentCountLabel.flex.markDirty()
        
        layout()
    }
    
    // MARK: - Private helpers
    private func layout() {
        rootView.pin.all()
        rootView.flex.layout()
    }
}
