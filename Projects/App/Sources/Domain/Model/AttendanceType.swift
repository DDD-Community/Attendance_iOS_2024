//
//  AttendanceType.swift
//  DDDAttendance
//
//  Created by 고병학 on 6/6/24.
//

import Foundation

public enum AttendanceType: String, Codable {
    case present = "PRESENT"
    case absent = "ABSENT"
    case late = "LATE"
    case earlyLeave = "EARLY_LEAVE"
    case disease = "DISEASE"
    case run = "RUN"
    
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
        }
    }
}
