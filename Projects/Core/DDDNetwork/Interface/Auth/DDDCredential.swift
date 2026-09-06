//
//  DDDCredential.swift
//  DDDNetworkInterface
//
//  Copyright © 2026 DDD. All rights reserved.
//

import Foundation

import Alamofire

/// 인증 토큰 묶음.
public struct DDDCredential: AuthenticationCredential, Sendable, Equatable {
  public let accessToken: String
  public let refreshToken: String
  /// 액세스 토큰 만료 시각 (nil 이면 만료 판정 안 함 — 401 을 받고 나서야 갱신한다)
  public let expiresAt: Date?
  /// 만료 직전 미리 갱신할 여유 시간(초). 만료 round-trip / 401 을 피하려고 둔다.
  public let refreshLeeway: TimeInterval

  public init(
    accessToken: String,
    refreshToken: String,
    expiresAt: Date? = nil,
    refreshLeeway: TimeInterval = 5 * 60
  ) {
    self.accessToken = accessToken
    self.refreshToken = refreshToken
    self.expiresAt = expiresAt
    self.refreshLeeway = refreshLeeway
  }

  /// 만료(leeway 포함) 임박 시 refresh 필요.
  /// Alamofire `AuthenticationInterceptor` 가 요청 전에 이 값을 검사해 401 을 받기 전에 미리 갱신한다.
  public var requiresRefresh: Bool {
    guard let expiresAt else { return false }
    return Date() >= expiresAt.addingTimeInterval(-refreshLeeway)
  }
}
