//
//  AttendanceType.swift
//  DDDAttendance
//
//  Created by 고병학 on 6/6/24.
//

import Foundation

enum AttendanceType: String, Codable {
    case present = "PRESENT"
    case absent = "ABSENT"
    case late = "LATE"
    case earlyLeave = "EARLY_LEAVE"
    case disease = "DISEASE"
    case run = "RUN"
}
