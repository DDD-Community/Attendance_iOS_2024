//
//  Attendance.swift
//  Entity
//
//  Created by DDD on 1/11/26.
//

import Foundation

import ProfileDomainInterface

public struct Attendance: Equatable, Identifiable {
  public let id: Int?
  public let userID: String
  public let userName, userInfo: String
  public let status:AttendanceStatus
  
  public init(
    id: Int?,
    userID: String,
    userName: String,
    userInfo: String,
    status: AttendanceStatus
  ) {
    self.id = id
    self.userID = userID
    self.userName = userName
    self.userInfo = userInfo
    self.status = status
  }
}

public extension Attendance {
  var selectTeamEntity: SelectTeams? {
    guard let teamPart = userInfo.split(separator: "/").first else { return nil }
    let normalized = teamPart.replacingOccurrences(of: " ", with: "").uppercased()
    switch normalized {
    case "WEB1팀": return .web1
    case "WEB2팀": return .web2
    case "IOS1팀": return .ios1
    case "IOS2팀": return .ios2
    case "ANDROID1팀", "AND1팀": return .and1
    case "ANDROID2팀", "AND2팀": return .and2
    default: return nil
    }
  }

  var selectPartEntity: SelectParts? {
    let parts = userInfo.split(separator: "/").map { String($0) }
    guard parts.count > 1 else { return nil }
    return SelectParts.from(apiKey: parts[1])
  }
}
