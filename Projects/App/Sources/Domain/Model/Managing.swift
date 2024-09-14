//
//  Manging.swift
//  DDDAttendance
//
//  Created by 서원지 on 7/19/24.
//

import Foundation

public enum Managing: String, CaseIterable, Codable {
    case accountiConsulting
    case photographer
    case scheduleManagement
    case instagramManagement
    case attendanceCheck
    case projectTeamManging
    
    var mangingDesc: String {
        switch self {
        case .accountiConsulting:
            return "회계, MC"
        case .photographer:
            return "포토 그래퍼"
        case .scheduleManagement:
            return "일정 관리 (공지)"
        case .instagramManagement:
            return "인스타그램"
        case .attendanceCheck:
            return "출석 체크"
        case .projectTeamManging:
            return "팀매니징"
        }
    }

}
