//
//  AuthUseCaseInterface.swift
//  AuthDomainInterface
//
//  Created by DDD on 9/3/26.
//

import AuthenticationServices

import Dependencies

public protocol AuthUseCaseInterface: Sendable {
  func login(provider: SocialType, token: String) async throws(AuthError) -> LoginEntity
  func refresh() async throws(AuthError) -> AuthTokens
  func withDraw(token: String) async throws(AuthError) -> WithdrawEntity
  func logout() async throws(AuthError) -> AuthExitEntity
  func updateSessionCredential(with tokens: AuthTokens) async
}

extension MockAuthRepository: AuthUseCaseInterface {}

public enum AuthUseCaseDependency: TestDependencyKey {
  public static let testValue: any AuthUseCaseInterface = MockAuthRepository()
  public static let previewValue: any AuthUseCaseInterface = testValue
}

public extension DependencyValues {
  var authUseCase: any AuthUseCaseInterface {
    get { self[AuthUseCaseDependency.self] }
    set { self[AuthUseCaseDependency.self] = newValue }
  }
}

public protocol UnifiedOAuthUseCaseInterface: Sendable {
  func processOAuthFlow(
    with socialType: SocialType,
    appleCredential: ASAuthorizationAppleIDCredential?,
    nonce: String?,
    googleToken: String?
  ) async -> Result<LoginEntity, AuthError>
}

public struct MockUnifiedOAuthUseCase: UnifiedOAuthUseCaseInterface {
  public init() {}

  public func processOAuthFlow(
    with socialType: SocialType,
    appleCredential: ASAuthorizationAppleIDCredential?,
    nonce: String?,
    googleToken: String?
  ) async -> Result<LoginEntity, AuthError> {
    .failure(.invalidCredential("OAuth 테스트 구현이 주입되지 않았습니다"))
  }
}

public enum UnifiedOAuthUseCaseDependency: TestDependencyKey {
  public static let testValue: any UnifiedOAuthUseCaseInterface = MockUnifiedOAuthUseCase()
  public static let previewValue: any UnifiedOAuthUseCaseInterface = testValue
}

public extension DependencyValues {
  var unifiedOAuthUseCase: any UnifiedOAuthUseCaseInterface {
    get { self[UnifiedOAuthUseCaseDependency.self] }
    set { self[UnifiedOAuthUseCaseDependency.self] = newValue }
  }
}
