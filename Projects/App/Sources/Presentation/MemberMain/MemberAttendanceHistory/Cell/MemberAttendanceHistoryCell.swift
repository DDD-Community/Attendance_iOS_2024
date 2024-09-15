//
//  MemberAttendanceHistoryCell.swift
//  DDDAttendance
//
//  Created by 고병학 on 6/27/24.
//

import FlexLayout
import PinLayout
import Then

import UIKit
import Model

final class MemberAttendanceHistoryCell: UICollectionViewCell {
    // MARK: - UI properties
    private let rootView: UIView = .init().then {
        $0.clipsToBounds = true
    }
    
    private let sessionTitleLabel: UILabel = .init().then {
        $0.textColor = .basicBlack
        $0.font = .pretendardFontFamily(family: .SemiBold, size: 16)
    }
    
    private let attendanceStatusLabel: UILabel = .init().then {
        $0.textColor = .gray600
        $0.font = .pretendardFontFamily(family: .Regular, size: 16)
    }
    
    private let dateLabel: UILabel = .init().then {
        $0.textColor = .basicBlack
        $0.font = .pretendardFontFamily(family: .Regular, size: 16)
    }
    
    // MARK: - Properties
    static let identifier: String = "\(MemberAttendanceHistoryCell.self)"
    
    // MARK: - Lifecycles
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configureViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureViews() {
        contentView.addSubview(rootView)
        
        rootView.flex
            .direction(.row)
            .justifyContent(.spaceBetween)
            .alignItems(.center)
            .paddingHorizontal(16)
            .paddingVertical(20)
            .cornerRadius(8)
            .define { flex in
                flex.addItem()
                    .direction(.row)
                    .alignItems(.center)
                    .height(16)
                    .define { flex in
                        flex.addItem(sessionTitleLabel)
                            .marginRight(4)
                        flex.addItem(attendanceStatusLabel)
                    }
                
                flex.addItem(dateLabel)
                    .height(16)
            }
    }
    
    // MARK: - Public helpers
    func bind(attendance: Attendance) {
        sessionTitleLabel.text = attendance.name
        sessionTitleLabel.flex.markDirty()
        attendanceStatusLabel.text = "/ \(attendance.status?.rawValue ?? "")"
        attendanceStatusLabel.flex.markDirty()
        dateLabel.text = Date.formattedDateTimeText(date: attendance.createdAt)
        dateLabel.flex.markDirty()
        
        rootView.backgroundColor = [AttendanceType.present, .late].contains(attendance.status) ? .gray200 : .gray800
        
        layout()
    }
    
    // MARK: - Private helpers
    private func layout() {
        rootView.pin.all()
        rootView.flex.layout()
    }
}
