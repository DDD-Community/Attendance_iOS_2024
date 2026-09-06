//
//  SplashFeatureTests.swift
//  DDDAttendanceTests
//
//  Created by DDD on 2026-09-02
//  Copyright © 2026 DDD , Ltd. All rights reserved.
//

import DDDAuthInterface
import FeatureAssembly
import Testing

@testable import DDDAttendance

@MainActor
@Suite("SplashFeature")
struct SplashFeatureTests {
  @Test("업데이트가 없고 멤버 프로필 fetch가 끝났으면 멤버 화면으로 이동한다")
  func upToDateMemberNavigatesToMemberAfterProfileFetch() async {
    var state = SplashFeature.State()
    state.staffRole = .member
    state.isProfileFetchCompleted = true

    let store = TestStore(initialState: state) {
      SplashFeature()
    }

    await store.send(.inner(.checkAppUpdateResponse(.success(nil)))) {
      $0.isUpdateCheckCompleted = true
    }
    await store.receive(\.delegate.presentMember)
  }

  @Test("업데이트가 필요하면 앱스토어 URL을 저장하고 업데이트 팝업을 표시한다")
  func updateAvailablePresentsUpdateAlert() async {
    let store = TestStore(initialState: SplashFeature.State()) {
      SplashFeature()
    }

    await store.send(.inner(.checkAppUpdateResponse(.success(.init(
      currentVersion: "1.0.0",
      latestVersion: "1.2.3",
      releaseNotes: "[v 1.2.3]\n- bug fixes",
      appStoreUrl: "https://apps.apple.com/app/id123",
      isUpdateAvailable: true
    ))))) {
      $0.isUpdateCheckCompleted = true
      $0.appStoreURL = "https://apps.apple.com/app/id123"
      $0.customAlert = .alert(
        title: "새로운 버전이 출시되었어요!",
        message: "새로운 버전 1.2.3이 출시되었습니다!\n\n더 나은 경험을 위해 지금 업데이트하세요!",
        confirmTitle: "지금 업데이트",
        cancelTitle: "나중에 할게요",
        isDestructive: false
      )
    }
  }

  @Test("프로필 조회 실패는 인증 세션을 종료하고 로그인 화면으로 이동한다")
  func profileFetchFailureSignsOutAndNavigatesToLogin() async {
    let authService = AuthServiceSpy()
    let store = TestStore(initialState: SplashFeature.State()) {
      SplashFeature()
    } withDependencies: {
      $0.authService = authService
    }

    await store.send(.inner(.fetchUserResponse(.failure(.invalidSession))))
    await store.receive(\.delegate.presentLogin)
    #expect(authService.didSignOut)
  }

  @Test("업데이트 팝업 취소 시 프로필 fetch가 끝났으면 현재 역할에 맞춰 이동한다")
  func cancelUpdateAlertNavigatesAfterProfileFetchCompleted() async {
    var state = SplashFeature.State()
    state.staffRole = .manager
    state.customAlert = .alert(
      title: "새로운 버전이 출시되었어요!",
      message: "업데이트가 필요합니다.",
      confirmTitle: "지금 업데이트",
      cancelTitle: "나중에 할게요",
      isDestructive: false
    )
    state.isProfileFetchCompleted = true

    let store = TestStore(initialState: state) {
      SplashFeature()
    }

    await store.send(.scope(.customAlert(.presented(.cancelTapped)))) {
      $0.customAlert = nil
    }
    await store.receive(\.delegate.presentStaff)
  }
}

private extension SplashFeatureTests {

}

private final class AuthServiceSpy: AuthService, @unchecked Sendable {
  private(set) var didSignOut = false
  var isLoggedIn: Bool { get async { false } }
  var refreshToken: String? { get async { nil } }

  func signIn(accessToken _: String, refreshToken _: String) async {}

  func signOut() async {
    didSignOut = true
  }
}
