//
//  Attendance.swift
//  DDDAttendance
//
//  Created by 고병학 on 6/6/24.
//

import FirebaseFirestore

import Model

public struct Attendance: Codable, Hashable {
    var id: String
    var memberId: String
    var memberType: MemberType?
    var name: String
    var roleType: SelectPart
    var eventId: String
    var createdAt: Date
    var updatedAt: Date
    var status: AttendanceType
    var generation: Int
    
    init(
        id: String,
        memberId: String,
        memberType: MemberType? = nil,
        name: String,
        roleType: SelectPart,
        eventId: String,
        createdAt: Date,
        updatedAt: Date,
        status: AttendanceType,
        generation: Int
    ) {
        self.id = id
        self.memberId = memberId
        self.memberType = memberType
        self.name = name
        self.roleType = roleType
        self.eventId = eventId
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.status = status
        self.generation = generation
    }
    
    enum CodingKeys: String, CodingKey {
        case id, memberId, name, roleType, eventId, createdAt, updatedAt, status, generation, memberType
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(String.self, forKey: .id) ?? ""
        self.memberId = try container.decodeIfPresent(String.self, forKey: .memberId) ?? ""
        self.memberType = try container.decodeIfPresent(MemberType.self, forKey: .memberType) ?? .coreMember
        self.name = try container.decodeIfPresent(String.self, forKey: .name) ?? ""
        self.roleType = try container.decodeIfPresent(SelectPart.self, forKey: .roleType) ?? .all
        self.eventId = try container.decodeIfPresent(String.self, forKey: .eventId) ?? ""
        self.createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt) ?? Date()
        self.updatedAt = try container.decodeIfPresent(Date.self, forKey: .updatedAt) ?? Date()
        self.status = try Attendance.decodeStatus(from: container)
        self.generation = try container.decodeIfPresent(Int.self, forKey: .generation) ?? 0
    }
    
    public init(from document: DocumentSnapshot) throws {
        let data = document.data() ?? [:]
        self.id = document.documentID
        self.memberId = data["memberId"] as? String ?? ""
        self.memberType = MemberType(rawValue: data["memberType"] as? String ?? "") ?? .coreMember
        self.name = data["name"] as? String ?? ""
        self.roleType = SelectPart(rawValue: data["roleType"] as? String ?? "") ?? .all
        self.eventId = data["eventId"] as? String ?? ""
        self.createdAt = (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()
        self.updatedAt = (data["updatedAt"] as? Timestamp)?.dateValue() ?? Date()
        self.status = Attendance.decodeStatus(from: data)
        self.generation = data["generation"] as? Int ?? 0
    }
    
    private static func decodeStatus(from container: KeyedDecodingContainer<CodingKeys>) throws -> AttendanceType {
        if let statusString = try container.decodeIfPresent(String.self, forKey: .status),
           let status = AttendanceType(rawValue: statusString) {
            return status
        }
        return .run  // Use a default value if the status string is invalid
    }
    
    private static func decodeStatus(from data: [String: Any]) -> AttendanceType {
        if let statusString = data["status"] as? String,
           let status = AttendanceType(rawValue: statusString) {
            return status
        }
        return .run  // Use a default value if the status string is invalid
    }
    
    mutating func merge(with other: Attendance) {
            self.id = self.id.isEmpty ? other.id : self.id
            self.memberId = self.memberId.isEmpty ? other.memberId : self.memberId
            self.memberType = self.memberType ?? other.memberType
            self.name = self.name.isEmpty ? other.name : self.name
            self.roleType = self.roleType == .all ? other.roleType : self.roleType
            self.eventId = self.eventId.isEmpty ? other.eventId : self.eventId
            self.createdAt = (self.createdAt == Date()) ? other.createdAt : self.createdAt
            self.updatedAt = (self.updatedAt == Date()) ? other.updatedAt : self.updatedAt
            self.status = (self.status == .run) ? other.status : self.status
            self.generation = (self.generation == 0) ? other.generation : self.generation
        }
    
//    mutating func mergeAttendance(primary: Attendance, secondary: Attendance) -> Attendance {
//        return Attendance(
//            id: primary.id.isEmpty ? secondary.id : primary.id,
//            memberId: primary.memberId.isEmpty ? secondary.memberId : primary.memberId,
//            memberType: primary.memberType == .coreMember ? secondary.memberType : primary.memberType,
//            name: primary.name.isEmpty ? secondary.name : primary.name,
//            roleType: primary.roleType == .all ? secondary.roleType : primary.roleType,
//            eventId: primary.eventId.isEmpty ? secondary.eventId : primary.eventId,
//            createdAt: primary.createdAt == Date() ? secondary.createdAt : primary.createdAt,
//            updatedAt: primary.updatedAt == Date() ? secondary.updatedAt : primary.updatedAt,
//            status: primary.status == .run ? secondary.status : primary.status,
//            generation: primary.generation == 0 ? secondary.generation : primary.generation
//        )
//    }
}
