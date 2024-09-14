//
//  MembeRequestModel.swift
//  DDDAttendance
//
//  Created by 고병학 on 9/14/24.
//

import Foundation

struct MemberRequestModel: Codable {
    var uid: String
    var name: String?
    var memberType: MemberType
    var memberPart: SelectPart?
    
    /// 운영진이 아니면 nil
    var coreMemberRole: Managing?
    
    var memberTeam: ManagingTeam?
}
