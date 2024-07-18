//
//  MemberType.swift
//  DDDAttendance
//
//  Created by 고병학 on 6/6/24.
//

import Foundation

enum MemberType: String, Codable {
    case master = "MASTER"
    case coreMember = "CORE_MEMBER"
    case member = "MEMBER"
    case run = "RUN"
    case notYet = "NOT_YET"
    
    
    var memberDesc: String {
        switch self {
        case .master:
            return "회장"
        case .coreMember:
            return "운영진"
        case .member:
            return "멤버"
        case .run:
            return "탈주"
        case .notYet:
            return ""
        }
    }
}
