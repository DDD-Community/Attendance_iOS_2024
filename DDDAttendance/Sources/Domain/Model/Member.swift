//
//  Member.swift
//  DDDAttendance
//
//  Created by 고병학 on 6/6/24.
//

import Foundation

struct Member: Codable, Hashable {
    /// Firebase Auth의 uid
    var uid: String
    var name: String
    var role: MemberRoleType
    var memberType: MemberType
    var snsURL: String?
    var updatedAt: Date
    
    /// 기수
    var generation: Int
}
