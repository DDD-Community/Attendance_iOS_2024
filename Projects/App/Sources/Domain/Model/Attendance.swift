//
//  Attendance.swift
//  DDDAttendance
//
//  Created by 고병학 on 6/6/24.
//

import FirebaseFirestore

import Model
import DesignSystem
import SwiftUI

public struct Attendance: Codable, Hashable {
    var id: String?
    var memberId: String?
    var memberType: MemberType?
    var manging: Managing?
    var memberTeam: ManagingTeam?
    var name: String
    var roleType: SelectPart
    var eventId: String
    var createdAt: Date
    var updatedAt: Date
    var status: AttendanceType?
    var generation: Int

    init(
        id: String,
        memberId: String? = nil,
        memberType: MemberType? = nil,
        manging: Managing? = nil,
        memberTeam: ManagingTeam? = nil,
        name: String,
        roleType: SelectPart,
        eventId: String,
        createdAt: Date,
        updatedAt: Date,
        status: AttendanceType? = nil,
        generation: Int
    ) {
        self.id = id
        self.memberId = memberId
        self.memberType = memberType
        self.manging = manging
        self.memberTeam = memberTeam
        self.name = name
        self.roleType = roleType
        self.eventId = eventId
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.status = status
        self.generation = generation
    }

    enum CodingKeys: String, CodingKey {
        case id, memberId, name, roleType, eventId
        case createdAt, updatedAt, status, generation, memberType
        case manging, memberTeam
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(String.self, forKey: .id) ?? ""
        self.memberId = try container.decodeIfPresent(String.self, forKey: .memberId) ?? ""
        self.memberType = try container.decodeIfPresent(MemberType.self, forKey: .memberType) ?? .coreMember
        self.manging = try container.decodeIfPresent(Managing.self, forKey: .manging) ?? .notManging
        self.memberTeam = try container.decodeIfPresent(ManagingTeam.self, forKey: .memberTeam) ?? .notTeam
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
        self.manging = Managing(rawValue: data["manging"] as? String ?? "") ?? .notManging
        self.memberTeam = ManagingTeam(rawValue: data["memberTeam"] as? String ?? "") ?? .notTeam
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
        return .run
    }
    
    private static func decodeStatus(from data: [String: Any]) -> AttendanceType {
        if let statusString = data["status"] as? String,
           let status = AttendanceType(rawValue: statusString) {
            return status
        }
        return .run
    }
    
    mutating func merge(with other: Attendance) {
        self.id = ((self.id?.isEmpty) != nil) ? other.id : self.id
        self.memberId = ((self.memberId?.isEmpty) != nil) ? other.memberId : self.memberId
        self.memberType = self.memberType ?? other.memberType
        self.name = self.name.isEmpty ? other.name : self.name
        self.roleType = self.roleType == .all ? other.roleType : self.roleType
        self.eventId = self.eventId.isEmpty ? other.eventId : self.eventId
        self.createdAt = (self.createdAt == Date()) ? other.createdAt : self.createdAt
        self.updatedAt = (self.updatedAt == Date()) ? other.updatedAt : self.updatedAt
        self.status = (self.status == .run) ? other.status : self.status
        self.generation = (self.generation == 0) ? other.generation : self.generation
    }
    
}


extension Attendance {
    static func generateCustomMemberId() -> String {
        let uuidPart = UUID().uuidString.replacingOccurrences(of: "-", with: "").prefix(22)
        return String(uuidPart)
    }
    
    static func mockData() -> [Attendance] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        guard let specificDate = dateFormatter.date(from: "2024-09-16") else {
            fatalError("Invalid date format")
        }
        
        guard let specificCreateDate = dateFormatter.date(from: "2024-09-15") else {
            fatalError("Invalid date format")
        }
        
        

        return [
            Attendance(
                id: UUID().uuidString,
                memberId: generateCustomMemberId(),
                memberType: .member,
                name: "DDD iOS",
                roleType: .iOS,
                eventId: "",
                createdAt: Date(),
                updatedAt: Date(),  
                status: .late,
                generation: 11
            ),
            Attendance(
                id: UUID().uuidString,
                memberId: generateCustomMemberId(),
                memberType: .member,
                name: "DDD Android",
                roleType: .android,
                eventId: UUID().uuidString,
                createdAt: specificCreateDate,
                updatedAt: specificDate,
                status: .present,
                generation: 11
            )
        ]
    }
    
    
    func toMemberDTO() -> MemberDTO {
        return MemberDTO(
            memberId: self.memberId ?? "",
            memberType: self.memberType ?? .coreMember,
            manging: self.manging ?? .notManging,
            memberTeam: self.memberTeam ?? .notTeam,
            name: self.name,
            roleType: self.roleType,
            createdAt: self.createdAt,
            updatedAt: self.updatedAt,
            status: self.status,
            generation: self.generation
        )
    }
    
    func toAttendanceDTO() -> AttendanceDTO {
        return AttendanceDTO(
            id: self.id ?? "",
            memberId: self.memberId ?? "",
            memberType: self.memberType ?? .coreMember,
            name: self.name,
            roleType: self.roleType,
            eventId: self.eventId,
            updatedAt: self.updatedAt,
            status: self.status,
            generation: self.generation
        )
    }
}
