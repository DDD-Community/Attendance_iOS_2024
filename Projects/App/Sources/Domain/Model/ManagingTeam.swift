//
//  MangingTeam.swift
//  DDDAttendance
//
//  Created by 서원지 on 7/19/24.
//

public enum ManagingTeam: String, CaseIterable, Codable {
    case ios1 = "iOS_1"
    case ios2 = "iOS_2"
    case and1 = "Android_1"
    case and2 = "Android_2"
    case web1 = "Web_1"
    case web2 = "Web_2"
    case notTeam = "NotTeam"
    
    
    case unknown

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        
        if rawValue.isEmpty {
            self = .unknown
        } else {
            self = ManagingTeam(rawValue: rawValue) ?? .unknown
        }
    }


    var mangingTeamDesc: String {
        switch self {
        case .ios1:
            return "iOS 1"
        case .ios2:
            return "iOS 2"
        case .and1:
            return "Android 1"
        case .and2:
            return "Android 2"
        case .web1:
            return "Web 1"
        case .web2:
            return "Web 2"
        case .notTeam:
            return ""
        case .unknown:
            return "Unknown Team" // Optional: Description for the unknown case
        }
    }
}

