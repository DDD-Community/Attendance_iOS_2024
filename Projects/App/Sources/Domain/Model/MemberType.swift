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
}
