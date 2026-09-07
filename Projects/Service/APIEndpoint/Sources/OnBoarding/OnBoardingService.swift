//
//  OnBoardingService.swift
//  Service
//
//  Created by DDD on 12/30/25.
//

import Foundation

import API
import DDDNetworkInterface

import Alamofire

public enum OnBoardingService: DDDDataRequest, Sendable {
  case verifyCode(code: String)
  case jobs
  case teams(generationId: Int)
  case mangerRole

  public var path: String {
    return AttendanceDomain.onboarding.url + urlPath
  }

  private var urlPath: String {
    switch self {
    case .verifyCode:
      return OnBoardingAPI.verifyCode.description
    case .jobs:
      return OnBoardingAPI.jobs.description
    case .teams:
      return OnBoardingAPI.teams.description
    case .mangerRole:
      return OnBoardingAPI.mangerRole.description
    }
  }

  public var authorization: DDDAuthorization {
    return .none
  }

  public var parameters: (any Encodable & Sendable)? {
    switch self {
    case let .verifyCode(code):
      return CodeParameter(code: code)
    case .jobs, .mangerRole:
      return nil
    case let .teams(generationId):
      return GenerationIDParameter(generationId: generationId)
    }
  }

  public var method: HTTPMethod {
    switch self {
    case .verifyCode, .jobs, .teams, .mangerRole:
      return .get
    }
  }
}

private struct CodeParameter: Encodable, Sendable {
  let code: String
}

private struct GenerationIDParameter: Encodable, Sendable {
  let generationId: Int
}
