//
//  AuthRequest.swift
//  Service
//
//  Created by DDD on 9/1/26.
//

import Foundation

import API
import DDDNetworkInterface

import Alamofire

public enum AuthRequest: DDDDataRequest, Sendable {
  case login(body: OAuthLoginRequest)
  case refresh(refreshToken: String)
  case withdraw(token: String)
  case logout

  public var path: String {
    return api.path
  }

  public var method: HTTPMethod {
    switch self {
    case .login, .refresh, .logout:
      return .post
    case .withdraw:
      return .delete
    }
  }

  public var authorization: DDDAuthorization {
    switch self {
    case .login, .refresh:
      return .none
    case .withdraw, .logout:
      return .automatic
    }
  }

  public var parameters: (any Encodable & Sendable)? {
    switch self {
    case let .login(body):
      return body
    case let .refresh(refreshToken):
      return RefreshTokenParameter(refreshToken: refreshToken)
    case let .withdraw(token):
      return WithdrawTokenParameter(token: token)
    case .logout:
      return nil
    }
  }

  private var api: AuthAPI {
    switch self {
    case .login:
      return .login
    case .refresh:
      return .refresh
    case .withdraw:
      return .withDraw
    case .logout:
      return .logout
    }
  }
}

private struct RefreshTokenParameter: Encodable, Sendable {
  let refreshToken: String
}

private struct WithdrawTokenParameter: Encodable, Sendable {
  let token: String
}
