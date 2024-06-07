//
//  SelectPart.swift
//  DDDAttendance
//
//  Created by 서원지 on 6/6/24.
//

import Foundation

public enum SelectPart: String, CaseIterable {
    case all
    case web
    case design
    case productManger
    case server
    case iOS
    case Android
    
    public var desc: String {
        switch self {
        case .all:
            return "전체"
        case .web:
            return "웹"
        case .design:
            return "디자이너"
        case .productManger:
            return "PM"
        case .server:
            return "서버"
        case .iOS:
            return "iOS"
        case .Android:
            return "안드로이드"
        }
    }
}
