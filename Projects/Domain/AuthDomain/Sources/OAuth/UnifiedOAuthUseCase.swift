//
//  UnifiedOAuthUseCase.swift
//  AuthDomain
//
//  Created by DDD on 12/29/25.
//

import AuthenticationServices
import Foundation

import AuthDomainInterface
import DDDCoreLogger

import Dependencies
import Sharing

/// 통합 OAuth UseCase - 로그인/회원가입 플로우를 하나로 통합
public struct UnifiedOAuthUseCase: UnifiedOAuthUseCaseInterface {
  @Dependency(\.authRepository) private var authRepository: AuthInterface
  @Dependency(\.appleOAuthProvider) private var appleProvider: AppleOAuthProviderInterface
  @Dependency(\.googleOAuthProvider) private var googleProvider: GoogleOAuthProviderInterface
  @Shared(.userSession) var userSession
  @Shared(.staffRole) var staffRole
  @Shared(.appStorage("appleUserName")) var savedAppleUserName: String?

  public init() {}
}

// MARK: - Public Interface

public extension UnifiedOAuthUseCase {

  /// 통합 소셜 로그인 처리
  func socialLogin(
    with socialType: SocialType,
    appleCredential: ASAuthorizationAppleIDCredential? = nil,
    nonce: String? = nil,
    googleToken: String? = nil
  ) async throws(AuthError) -> LoginEntity {
    switch socialType {
    case .apple:
      guard let credential = appleCredential, let nonce = nonce else {
        throw AuthError.invalidCredential("Apple 로그인에 필요한 credential 또는 nonce가 없습니다")
      }
      return try await appleLogin(credential: credential, nonce: nonce)
    case .google:
      guard let token = googleToken else {
        throw AuthError.invalidCredential("Google 로그인에 필요한 token이 없습니다")
      }
      return try await googleLogin(token: token)
    }
  }

  /// Apple 로그인 처리
  func appleLogin(
    credential: ASAuthorizationAppleIDCredential,
    nonce: String
  ) async throws(AuthError) -> LoginEntity {
    let payload = try await appleProvider.signInWithCredential(
      credential: credential,
      nonce: nonce
    )
    DDDLogger.debug("apple authcode: \(payload.authorizationCode ?? "none")", category: .auth)

    // Apple 로그인 시 이름 저장 로직 개선
    let userName: String = {
      if let displayName = payload.displayName, !displayName.isEmpty {
        // 새로운 이름이 있으면 UserDefaults에 저장
        self.$savedAppleUserName.withLock { $0 = displayName }
        return displayName
      } else {
        // 이름이 없으면 이전에 저장된 이름 사용, 그것도 없으면 빈 문자열
        return self.savedAppleUserName ?? ""
      }
    }()

    self.$userSession.withLock {
      $0.token = payload.authorizationCode ?? ""
      $0.accessToken = payload.idToken
      $0.oauthRefreshToken = payload.idToken
      $0.name = userName
    }
    let loginEntity = try await authRepository.login(
      provider: .apple,
      token: payload.authorizationCode ?? ""
    )

    // UserSession에 oauthRefreshToken 설정 (Apple 로그인의 경우)
    self.$userSession.withLock {
      $0.oauthRefreshToken = loginEntity.token.oauthRefreshToken
    }

    syncRole(from: loginEntity)
    return loginEntity
  }

  /// Google 로그인 처리
  func googleLogin(
    token: String
  ) async throws(AuthError) -> LoginEntity {
    let processedToken = try await googleProvider.signInWithToken(token: token)
    self.$userSession.withLock { $0.token = processedToken }
    let loginEntity = try await authRepository.login(
      provider: .google,
      token: processedToken
    )
    syncRole(from: loginEntity)

    return loginEntity
  }

  /// OAuth 플로우 처리 (TCA용)
  func processOAuthFlow(
    with socialType: SocialType,
    appleCredential: ASAuthorizationAppleIDCredential? = nil,
    nonce: String? = nil,
    googleToken: String? = nil
  ) async -> Result<LoginEntity, AuthError> {
    do {
      let result = try await socialLogin(
        with: socialType,
        appleCredential: appleCredential,
        nonce: nonce,
        googleToken: googleToken
      )
      return .success(result)
    } catch {
      return .failure(error)
    }
  }
}

private extension UnifiedOAuthUseCase {
  /// 로그인 결과를 프로필 API 선택에 사용하는 역할 저장소와 동기화한다.
  /// 신규 사용자는 온보딩에서 역할이 확정되므로 이전 계정의 값을 반드시 제거한다.
  func syncRole(from loginEntity: LoginEntity) {
    guard !loginEntity.isNewUser else {
      $staffRole.withLock { $0 = nil }
      return
    }

    let role = loginEntity.role ?? .member
    $userSession.withLock { $0.userRole = role }
    $staffRole.withLock { $0 = role }
  }
}
