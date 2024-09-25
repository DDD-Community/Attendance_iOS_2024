//
//  AttendanceDTO.swift
//  DDDAttendance
//
//  Created by 서원지 on 9/23/24.
//

import Model
import Foundation
import SwiftUI
import DesignSystem

public struct AttendanceDTO: Codable, Equatable {
    var id: String
    var memberId: String
    var memberType: MemberType
    var name: String
    var roleType: SelectPart
    var eventId: String
    var updatedAt: Date
    var status: AttendanceType?
    var generation: Int

    init(
        id: String,
        memberId: String,
        memberType: MemberType,
        name: String,
        roleType: SelectPart,
        eventId: String,
        updatedAt: Date,
        status: AttendanceType? = nil,
        generation: Int
    ) {
        self.id = id
        self.memberId = memberId
        self.memberType = memberType
        self.name = name
        self.roleType = roleType
        self.eventId = eventId
        self.updatedAt = updatedAt
        self.status = status
        self.generation = generation
    }
}

extension AttendanceDTO {
    func backgroundColor(
        isBackground: Bool = false,
        isNameColor: Bool = false,
        isGenerationColor: Bool = false,
        isRoletTypeColor: Bool = false
    ) -> Color {
        switch self.status {
        case .present:
            switch (isBackground, isNameColor, isGenerationColor, isRoletTypeColor) {
            case (true, _, _, _):
                return .basicWhite
            case (_, true, _, _):
                return .basicBlack
            case (_, _, true, _):
                return .gray600
            case (_, _, _, true):
                return .basicBlack
            default:
                return .gray800 // Default color if none match
            }
        case .late:
            switch (isBackground, isNameColor, isGenerationColor, isRoletTypeColor) {
            case (true, _, _, _):
                return .gray800
            case (_, true, _, _):
                return .gray600
            case (_, _, true, _):
                return .gray600
            case (_, _, _, true):
                return .gray600
            default:
                return .gray800
            }
        case .run:
            switch (isBackground, isNameColor, isGenerationColor, isRoletTypeColor) {
            case (true, _, _, _):
                return .gray800
            case (_, true, _, _):
                return .gray600
            case (_, _, true, _):
                return .gray600
            case (_, _, _, true):
                return .gray600
            default:
                return .gray800
            }
            
        case nil:
            switch (isBackground, isNameColor, isGenerationColor, isRoletTypeColor) {
            case (true, _, _, _):
                return .gray800
            case (_, true, _, _):
                return .gray600
            case (_, _, true, _):
                return .gray600
            case (_, _, _, true):
                return .gray600
            default:
                return .gray800
            }
            
        default:
            switch (isBackground, isNameColor, isGenerationColor, isRoletTypeColor) {
            case (true, _, _, _):
                return .gray800
            case (_, true, _, _):
                return .gray600
            case (_, _, true, _):
                return .gray600
            case (_, _, _, true):
                return .gray600
            default:
                return .gray800
            }
        }
    }
}

extension AttendanceDTO {
    static func generateCustomMemberId() -> String {
        let uuidPart = UUID().uuidString.replacingOccurrences(of: "-", with: "").prefix(22)
        return String(uuidPart)
    }
    
    static func mockAttendanceData() -> [AttendanceDTO] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        // Parse the dates for the DTO
        guard let specificDate = dateFormatter.date(from: "2024-09-16") else {
            fatalError("Invalid date format")
        }
        
        guard let specificCreateDate = dateFormatter.date(from: "2024-09-15") else {
            fatalError("Invalid date format")
        }

        // Return mock DTO data
        return [
            AttendanceDTO(
                id: UUID().uuidString,
                memberId: generateCustomMemberId(),
                memberType: .member,
                name: "DDD iOS",
                roleType: .iOS,
                eventId: "",
                updatedAt: Date(), // Set to current date
                status: .late,
                generation: 11
            ),
            AttendanceDTO(
                id: UUID().uuidString,
                memberId: generateCustomMemberId(),
                memberType: .member,
                name: "DDD Android",
                roleType: .android,
                eventId: UUID().uuidString,
                updatedAt: specificDate, // Use the specific update date
                status: .present,
                generation: 11
            )
        ]
    }
}
