//
//  LoginReducerTests.swift
//  AuthTests
//
//  Created by DDD on 2026-09-02
//

import ComposableArchitecture
import AuthDomainInterface
import Testing

@testable import Auth

@MainActor
@Suite("LoginReducer")
struct LoginReducerTests {
  @Test("showPolicyPopUp 액션은 개인정보 동의 팝업을 표시한다")
  func showPolicyPopUpPresentsPrivacyConsentAlert() async {
    let store = TestStore(initialState: LoginFeature.State()) {
      LoginFeature()
    }

    await store.send(.view(.showPolicyPopUp)) {
      $0.customAlert = .privacyPolicyConsent()
    }
  }

  @Test("기존 멤버 로그인 성공은 역할을 저장하고 멤버 화면 이동을 요청한다")
  func existingMemberLoginSuccessNavigatesToMember() async {
    let store = TestStore(initialState: LoginFeature.State()) {
      LoginFeature()
    }

    await store.send(.inner(.loginResponse(.success(Self.memberLogin)))) {
      $0.staffRole = .member
      $0.userSession.userRole = .member
    }
    await store.receive(\.delegate.presentMemberMain)
  }
}

private extension LoginReducerTests {
  static let memberLogin = LoginEntity(
    name: "김철수",
    isNewUser: false,
    provider: .apple,
    token: AuthTokens(
      accessToken: "access-token",
      refreshToken: "refresh-token",
      oauthRefreshToken: nil
    ),
    role: .member
  )
}
