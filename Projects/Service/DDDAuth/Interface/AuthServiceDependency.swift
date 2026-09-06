//
//  AuthServiceDependency.swift
//  DDDAuthInterface
//
//  Created by DDD on 2026-09-02
//
//  인증 서비스의 DependencyKey.
//
//  liveValue 는 Keychain·네트워크 세션을 함께 다루므로 상위 조립 레이어가 등록한다.
//  여기서는 계약과 테스트값만 둔다.
//

import Foundation

import Dependencies

public enum AuthServiceDependency: TestDependencyKey {
  public static var testValue: any AuthService {
    UnimplementedAuthService()
  }
}

public extension DependencyValues {
  var authService: any AuthService {
    get { self[AuthServiceDependency.self] }
    set { self[AuthServiceDependency.self] = newValue }
  }
}

/// 등록하지 않은 채 인증을 건드리면 알려주는 기본값.
/// 조용히 성공을 돌려주면 로그인 관련 테스트가 통과해버린다.
public struct UnimplementedAuthService: AuthService {
  public init() {}

  public var isLoggedIn: Bool {
    get async { reportUnimplemented() }
  }

  public var refreshToken: String? {
    get async { reportUnimplemented() }
  }

  public func signIn(accessToken: String, refreshToken: String) async {
    reportUnimplemented()
  }

  public func signOut() async {
    reportUnimplemented()
  }

  private func reportUnimplemented() -> Never {
    fatalError(
      "authService 가 등록되지 않았다. 테스트라면 withDependencies 로 스텁을 넣고, "
        + "앱이라면 ServiceAssembly 의 liveValue 등록을 확인할 것."
    )
  }
}
