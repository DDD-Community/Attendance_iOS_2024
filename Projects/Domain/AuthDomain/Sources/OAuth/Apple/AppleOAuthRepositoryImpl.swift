//
//  AppleOAuthRepositoryImpl.swift
//  AuthDomain
//
//  Created by DDD on 12/29/25.
//

import AuthenticationServices
import Foundation

import AuthDomainInterface
import DDDCoreLogger

import ComposableArchitecture

#if canImport(UIKit)
import UIKit
#endif

public final class AppleOAuthRepositoryImpl: NSObject, AppleOAuthInterface, @unchecked Sendable {
  @Dependency(\.appleManger) var appleLoginManger
  @Shared(.appStorage("appleUserName")) var appleUserName: String?

  private var currentNonce: String?
  private var signInContinuation: CheckedContinuation<Result<AppleOAuthPayload, AuthError>, Never>?
  private var isSigningIn: Bool = false

  public override init() {

  }
  public func signInWithCredential(
    _ credential: ASAuthorizationAppleIDCredential,
    nonce: String
  ) async throws(AuthError) -> AppleOAuthPayload {
    // 받은 credential으로 직접 payload 생성
    guard let identityTokenData = credential.identityToken,
          let identityToken = String(data: identityTokenData, encoding: .utf8)
    else {
      throw .missingIDToken
    }

    let authorizationCode = credential.authorizationCode.flatMap { String(data: $0, encoding: .utf8) }
    let displayName = formatDisplayName(credential.fullName)

    return AppleOAuthPayload(
      idToken: identityToken,
      authorizationCode: authorizationCode,
      displayName: displayName,
      nonce: nonce
    )
  }

  @MainActor
  public func signIn() async throws(AuthError) -> AppleOAuthPayload {
    // 중복 요청은 기존 인증 화면과 continuation을 덮어쓰지 않도록 거부한다.
    if isSigningIn {
      throw .invalidCredential("이미 로그인이 진행 중입니다")
    }

    let result = await withCheckedContinuation { continuation in
      self.isSigningIn = true
      self.signInContinuation = continuation

      let request = ASAuthorizationAppleIDProvider().createRequest()
      let nonce = appleLoginManger.prepare(request)
      self.currentNonce = nonce

      let controller = ASAuthorizationController(authorizationRequests: [request])
      controller.delegate = self
      controller.presentationContextProvider = self
      controller.performRequests()
    }
    return try result.get()
  }

  private func formatDisplayName(_ components: PersonNameComponents?) -> String? {
    guard let components else { return nil }
    let formatter = PersonNameComponentsFormatter()
    let name = formatter.string(from: components).trimmingCharacters(in: .whitespacesAndNewlines)
    return name.isEmpty ? nil : name
  }
}

// MARK: - ASAuthorizationControllerDelegate
extension AppleOAuthRepositoryImpl: ASAuthorizationControllerDelegate {
  public func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
    guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else {
      signInContinuation?.resume(returning: .failure(.invalidCredential("Invalid credential type")))
      resetSignInState()
      return
    }

    guard let nonce = currentNonce else {
      signInContinuation?.resume(returning: .failure(.missingIDToken))
      resetSignInState()
      return
    }

    guard let identityTokenData = credential.identityToken,
          let identityToken = String(data: identityTokenData, encoding: .utf8) else {
      signInContinuation?.resume(returning: .failure(.missingIDToken))
      resetSignInState()
      return
    }

    let displayName = formatDisplayName(credential.fullName)
    let authorizationCode = credential.authorizationCode.flatMap { String(data: $0, encoding: .utf8) }

    let payload = AppleOAuthPayload(
      idToken: identityToken,
      authorizationCode: authorizationCode,
      displayName: displayName,
      nonce: nonce
    )

    self.$appleUserName.withLock { $0 = displayName }

    DDDLogger.info("Apple Sign In successful for user: \(displayName ?? "unknown"), \(appleUserName)", category: .auth)
    signInContinuation?.resume(returning: .success(payload))
    resetSignInState()
  }

  public func authorizationController(
    controller: ASAuthorizationController,
    didCompleteWithError error: Error
  ) {
    let nsError = error as NSError

    if nsError.code == ASAuthorizationError.canceled.rawValue {
      signInContinuation?.resume(returning: .failure(.userCancelled))
    } else {
      DDDLogger.error("Apple Sign In failed: \(error.localizedDescription)", category: .auth)
      signInContinuation?.resume(returning: .failure(.invalidCredential(error.localizedDescription)))
    }

    resetSignInState()
  }

  private func resetSignInState() {
    signInContinuation = nil
    currentNonce = nil
    isSigningIn = false
  }
}

// MARK: - ASAuthorizationControllerPresentationContextProviding
extension AppleOAuthRepositoryImpl: ASAuthorizationControllerPresentationContextProviding {
  public func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
#if canImport(UIKit)
    return UIApplication.shared.connectedScenes
      .compactMap { ($0 as? UIWindowScene)?.keyWindow }
      .first ?? ASPresentationAnchor()
#else
    return ASPresentationAnchor()
#endif
  }
}
