//
//  AttendanceRequest.swift
//  Service
//
//  Created by DDD on 9/1/26.
//

import Foundation

import API
import DDDNetworkInterface

import Alamofire

public enum AttendanceRequest: DDDDataRequest, Sendable {
  case adminAttendanceCount(scheduleId: Int)
  case fetchTeams
  case sessionAttendance(body: AttendanceRequestDTO)
  case status
  case editAttendance(body: EditAttendanceRequestDTO)

  public var path: String {
    switch self {
    case let .adminAttendanceCount(scheduleId):
      return "api/admin" + AttendanceAPI.adminAttendanceCount(scheduleId: scheduleId).description
    case .fetchTeams:
      return "api/admin" + AttendanceAPI.fetchTeams.description
    case let .sessionAttendance(body):
      return "api/admin" + AttendanceAPI.sessionAttendances(
        scheduleId: body.scheduleId,
        teamId: body.teamId
      ).description
    case .status:
      return "api/attendances" + AttendanceAPI.status.description
    case .editAttendance:
      return "api/attendances" + AttendanceAPI.editAttendance.description
    }
  }

  public var method: HTTPMethod {
    switch self {
    case .adminAttendanceCount, .fetchTeams, .sessionAttendance, .status:
      return .get
    case .editAttendance:
      return .put
    }
  }

  public var parameters: (any Encodable & Sendable)? {
    switch self {
    case let .sessionAttendance(body):
      return body
    case let .editAttendance(body):
      return body
    case .adminAttendanceCount, .fetchTeams, .status:
      return nil
    }
  }
}
