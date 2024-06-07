//
//  Attendance.swift
//  DDDAttendance
//
//  Created by 고병학 on 6/6/24.
//

import Foundation

struct Attendance: Codable, Hashable {
    var id: String
    var memberId: String
    var eventId: String
    var createdAt: Date
    var updatedAt: Date
    var attendanceType: AttendanceType
    
    /// 기수
    var generation: Int
}
