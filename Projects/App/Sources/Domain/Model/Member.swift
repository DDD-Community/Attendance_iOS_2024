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
    var memberid: String
    var name: String
    var role: SelectPart
    var memberType: MemberType
    var manging: Managing?
    var memberTeam: ManagingTeam?
    var snsURL: String?
    var createdAt: Date
    var updatedAt: Date
    
    /// 기수
    var generation: Int
}
