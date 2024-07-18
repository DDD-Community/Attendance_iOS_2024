//
//  MangingTeam.swift
//  DDDAttendance
//
//  Created by 서원지 on 7/19/24.
//

public enum MangingTeam: String, CaseIterable {
    case ios1
    case ios2
    case and1
    case and2
    case web1
    case web2
    
    var mangingTeamDesc: String {
        switch self {
        case .ios1:
            return "iOS 1"
        case .ios2:
            return "iOS 2"
        case .and1:
            return "Android 1"
        case .and2:
            return "Android 2"
        case .web1:
            return "Web 1"
        case .web2:
            return "Web 2"
        }
    }
}
