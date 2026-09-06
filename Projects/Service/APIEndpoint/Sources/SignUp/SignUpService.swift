//
//  SignUpService.swift
//  Service
//
//  Created by DDD on 5/7/25.
//

import Foundation

import API
import DDDNetworkInterface

import Alamofire

public enum SignUpService: DDDDataRequest, Sendable {
  // Mark : - 회원가입
  case signUpUser(body: SignUpUserRequestDTO)

  public var path: String {
    return AttendanceDomain.user.url + urlPath
  }

  private var urlPath: String {
    switch self {
    case .signUpUser:
      return SignUpAPI.signUpUser.signUpDescription
    }
  }

  public var method: HTTPMethod {
    switch self {
    case .signUpUser:
      return .post
    }
  }

  public var authorization: DDDAuthorization {
    return .none
  }

  public var parameters: (any Encodable & Sendable)? {
    switch self {
    case let .signUpUser(body):
      return body
    }
  }
}
