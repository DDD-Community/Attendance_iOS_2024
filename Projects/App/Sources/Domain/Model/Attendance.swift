//
//  Attendance.swift
//  DDDAttendance
//
//  Created by 고병학 on 6/6/24.
//

import Foundation

public struct Attendance: Codable, Hashable {
    var id: String
    var memberId: String
    var eventId: String
    var createdAt: Date
    var updatedAt: Date
    var attendanceType: AttendanceType
    var generation: Int
    
    init(
        id: String,
         memberId: String,
        eventId: String,
        createdAt: Date,
        updatedAt: Date,
        attendanceType: AttendanceType,
        generation: Int
    ) {
        self.id = id
        self.memberId = memberId
        self.eventId = eventId
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.attendanceType = attendanceType
        self.generation = generation
    }
    
    enum CodingKeys: String, CodingKey {
        case id, memberId, eventId, createdAt, updatedAt, attendanceType, generation
    }
    
    
}
