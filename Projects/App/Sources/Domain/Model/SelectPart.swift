//
//  SelectPart.swift
//  DDDAttendance
//
//  Created by 서원지 on 6/6/24.
//

import Foundation

public enum SelectPart: String, CaseIterable, Codable {
    case all
    case pm = "PM"
    case design = "Designer"
    case android = "Android"
    case iOS
    case web = "FE"
    case server = "BE"
    
    public var desc: String {
        switch self {
        case .all:
            return "전체"
        case .pm:
            return "PM"
        case .design:
            return "Designer"
        case .android:
            return "Android"
        case .iOS:
            return "iOS"
        case .web:
            return "FE"
        case .server:
            return "BE"
        }
    }
    
    public var attendanceListDesc: String {
        switch self {
        case .all:
            return "전체"
        case .pm:
            return "PM"
        case .design:
            return "Designer"
        case .android:
            return "Android"
        case .iOS:
            return "iOS"
        case .web:
            return "FE"
        case .server:
            return "BE"
        }
    }
    
    public var isDescEqualToAttendanceListDesc: Bool {
        return desc == attendanceListDesc
    }
    
    public static var allParts: [SelectPart] {
        return [.pm, .design, .android, .iOS, .web, .server]
    }
}
