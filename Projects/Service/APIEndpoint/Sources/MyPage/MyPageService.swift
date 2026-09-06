//
//  MyPageService.swift
//  Service
//
//  Created by DDD on 1/12/26.
//

import Foundation

import API
import DDDNetworkInterface

import Alamofire

public enum MyPageService: DDDDataRequest, Sendable {
  case fetchAttendances
  case fetchSchedules

  public var path: String {
    return AttendanceDomain.myPage.url + urlPath
  }

  private var urlPath: String {
    switch self {
    case .fetchAttendances:
      return MyPageAPI.fetchAttendances.urlPath
    case .fetchSchedules:
      return MyPageAPI.fetchSchedules.urlPath
    }
  }

  public var method: HTTPMethod {
    switch self {
    case .fetchAttendances, .fetchSchedules:
      return .get
    }
  }
}
