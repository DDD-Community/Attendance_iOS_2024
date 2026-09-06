//
//  ProfileReducerTests.swift
//  ProfileTests
//
//  Created by DDD on 2026-09-02
//  Copyright © 2026 DDD , Ltd. All rights reserved.
//

import ComposableArchitecture
import Testing
import AuthDomainInterface
import ProfileDomainInterface

@testable import Profile

@MainActor
@Suite("ProfileFeature")
struct ProfileReducerTests {
  @Test("appearModal 액션은 앱 피드백 작성 화면을 destination에 표시한다")
  func appearModalPresentsCreateAppDestination() async {
    let store = TestStore(initialState: ProfileFeature.State()) {
      ProfileFeature()
    }

    await store.send(.view(.appearModal)) {
      $0.destination = .createApp(.init())
    }
  }

  @Test("closeModal 액션은 표시 중인 destination을 닫는다")
  func closeModalDismissesDestination() async {
    var state = ProfileFeature.State()
    state.destination = .createApp(.init())

    let store = TestStore(initialState: state) {
      ProfileFeature()
    }

    await store.send(.view(.closeModal)) {
      $0.destination = nil
    }
  }

  @Test("showLogoutAlert 액션은 로그아웃 확인 팝업을 표시한다")
  func showLogoutAlertPresentsLogoutConfirmation() async {
    let store = TestStore(initialState: ProfileFeature.State()) {
      ProfileFeature()
    }

    await store.send(.view(.showLogoutAlert)) {
      $0.customAlert = .logout()
    }
  }

  @Test("fetchUserResponse 성공은 로딩을 끄고 프로필을 저장한다")
  func fetchUserSuccessStoresProfileAndStopsLoading() async {
    var state = ProfileFeature.State()
    state.viewState = .loading
    let profile = Self.memberProfile

    let store = TestStore(initialState: state) {
      ProfileFeature()
    }

    await store.send(.inner(.fetchUserResponse(.success(profile)))) {
      $0.viewState = .loaded
      $0.profile = profile
    }
  }

  @Test("네트워크 프로필이 없으면 세션의 마지막 프로필을 즉시 표시한다")
  func displayedProfileFallsBackToUserSession() {
    var state = ProfileFeature.State()
    let originalSession = state.userSession
    defer {
      state.$userSession.withLock { $0 = originalSession }
    }

    state.$userSession.withLock {
      $0 = UserSession(
        userID: 7,
        name: "김철수",
        selectPart: .ios,
        userRole: .member,
        selectTeam: .ios2,
        generation: "2기"
      )
    }

    #expect(state.displayedProfile?.userID == 7)
    #expect(state.displayedProfile?.name == "김철수")
    #expect(state.displayedProfile?.team == .ios2)
  }

  @Test("logoutResponses 성공은 로그아웃 navigation을 보낸다")
  func logoutSuccessSendsLogoutNavigation() async {
    let store = TestStore(initialState: ProfileFeature.State()) {
      ProfileFeature()
    }

    await store.send(.inner(.logoutResponses(.success(ProfileTestSupport.authExitSuccess))))
    await store.receive(\.delegate.presentLogOut)
  }

  @Test("deleteUserResponse 성공이 아니면 로그아웃 navigation을 보내지 않는다")
  func deleteUserNonSuccessDoesNotNavigate() async {
    let response = WithdrawEntity(isSuccess: false, code: "400", message: "failed")
    let store = TestStore(initialState: ProfileFeature.State()) {
      ProfileFeature()
    }

    await store.send(.inner(.deleteUserResponse(.success(response))))
  }
}

private extension ProfileReducerTests {
  static let memberProfile = ProfileEntity(
    userID: 1,
    name: "김철수",
    generation: "2기",
    team: .ios1,
    jobRole: .ios,
    role: .member,
    manger: nil
  )
}
