//
//  AttendanceType.swift
//  Model
//
//  Created by 서원지 on 7/14/24.
//

import Foundation

public enum AttendanceType: String, Codable {
    case present = "PRESENT"
    case absent = "ABSENT"
    case late = "LATE"
    case earlyLeave = "EARLY_LEAVE"
    case disease = "DISEASE"
    case run = "RUN"
    case notAttendance
    
    var desc: String {
        switch self {
        case .present:
            return "PRESENT"
        case .absent:
            return "ABSENT"
        case .late:
            return "LATE"
        case .earlyLeave:
            return "EARLY_LEAVE"
        case .disease:
            return "DISEASE"
        case .run:
            return "RUN"
            
        case .notAttendance:
            return "NONE"
        }
    }
}

