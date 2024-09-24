//
//  Manging.swift
//  DDDAttendance
//
//  Created by 서원지 on 7/19/24.
//

import Foundation

public enum Managing: String, CaseIterable, Codable {
    case accountiConsulting = "Accounti_Consulting"
    case photographer = "PhotoGrapher"
    case scheduleManagement = "Schedule_Management"
    case instagramManagement = "Instagram_Management"
    case attendanceCheck = "Attendance_Check"
    case projectTeamManging = "Project_TeamManging"
    case notManging = "NotManging"
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        
        if rawValue.trimmingCharacters(in: .whitespaces).isEmpty {
            self = .notManging
        } else {
            self = Managing(rawValue: rawValue) ?? .notManging
        }
    }

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
        case .notManging:
            return ""
        }
    }
}

