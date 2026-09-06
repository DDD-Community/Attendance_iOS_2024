//
//  ScheduleRequest.swift
//  Service
//
//  Created by DDD on 9/1/26.
//

import Foundation

import API
import DDDNetworkInterface

import Alamofire

public enum ScheduleRequest: DDDDataRequest, Sendable {
  case getSchedule

  public var path: String {
    switch self {
    case .getSchedule:
      return "api/schedules" + ScheduleAPI.schedule.description
    }
  }

  public var method: HTTPMethod {
    switch self {
    case .getSchedule:
      return .get
    }
  }
}
