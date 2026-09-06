//
//  AttendanceStatus.swift
//  Entity
//
//  Created by DDD on 1/11/26.
//

import Foundation

import ProfileDomainInterface

public enum AttendanceStatus: String, CaseIterable, Equatable, Identifiable {
  case attended = "ATTENDED"
  case late = "LATE"
  case absent = "ABSENT"
  case defaults = "DEFAULT"

  public var id: String {
    rawValue
  }

  public var desc: String {
    switch self {
    case .attended:
      return "출석"
    case .late:
      return "지각"
    case .absent:
      return "결석"
      case .defaults:
        return "대기"
    }
  }

  public var apiKey: String {
    rawValue
  }

  public static func from(apiKey: String) -> AttendanceStatus? {
    AttendanceStatus(rawValue: apiKey.uppercased())
  }
}
