//
//  Attendance.swift
//  DDDAttendance
//
//  Created by 고병학 on 6/6/24.
//

import FirebaseFirestore

public struct Attendance: Codable, Hashable {
    var id: String
    var memberId: String
    var name: String
    var roleType: SelectPart
    var eventId: String
    var createdAt: Date
    var updatedAt: Date
    var attendanceType: AttendanceType
    var generation: Int
    
    init(
        id: String,
        memberId: String,
        name: String,
        roleType: SelectPart,
        eventId: String,
        createdAt: Date,
        updatedAt: Date,
        attendanceType: AttendanceType,
        generation: Int
    ) {
        self.id = id
        self.memberId = memberId
        self.name = name
        self.roleType = roleType
        self.eventId = eventId
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.attendanceType = attendanceType
        self.generation = generation
    }
    
    enum CodingKeys: String, CodingKey {
        case memberId, name, roleType, eventId, createdAt, updatedAt, attendanceType, generation
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = "" // Placeholder, will be set later from document ID
        self.memberId = try container.decode(String.self, forKey: .memberId)
        self.name = try container.decode(String.self, forKey: .name)
        self.roleType = try container.decode(SelectPart.self, forKey: .roleType)
        self.eventId = try container.decode(String.self, forKey: .eventId)
        self.createdAt = try container.decode(Date.self, forKey: .createdAt)
        self.updatedAt = try container.decode(Date.self, forKey: .updatedAt)
        self.attendanceType = try container.decode(AttendanceType.self, forKey: .attendanceType)
        self.generation = try container.decode(Int.self, forKey: .generation)
    }
    
    public init(from document: DocumentSnapshot) throws {
        let data = document.data() ?? [:]
        self.id = document.documentID
        self.memberId = data["memberId"] as? String ?? ""
        self.name = data["name"] as? String ?? ""
        self.roleType = SelectPart(rawValue: data["roleType"] as? String ?? "") ?? .all // Adjust accordingly
        self.eventId = data["eventId"] as? String ?? ""
        self.createdAt = (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()
        self.updatedAt = (data["updatedAt"] as? Timestamp)?.dateValue() ?? Date()
        self.attendanceType = AttendanceType(rawValue: data["attendanceType"] as? String ?? "") ?? .run // Adjust accordingly
        self.generation = data["generation"] as? Int ?? 0
    }
}

