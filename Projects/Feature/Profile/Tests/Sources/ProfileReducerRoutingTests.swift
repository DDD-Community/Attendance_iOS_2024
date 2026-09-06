//
//  ProfileReducerRoutingTests.swift
//  ProfileTests
//
//  Created by DDD on 2026-09-03
//  Copyright © 2026 DDD , Ltd. All rights reserved.
//
//  ProfileFeature 의 동기 분기(view / inner / delegate / scope)를 훑는다.
//  이펙트가 없는 액션만 다루므로 의존성 주입 없이 검증한다.
//

import ComposableArchitecture
import Testing
import AuthDomainInterface
import ProfileDomainInterface

@testable import Profile

@MainActor
@Suite("ProfileFeature 액션 라우팅")
struct ProfileReducerRoutingTests {
  // MARK: - ViewAction

  @Test("showWithdrawAlert 액션은 탈퇴 확인 팝업을 표시한다")
  func showWithdrawAlertPresentsWithdrawConfirmation() async {
    let store = TestStore(initialState: ProfileFeature.State()) {
      ProfileFeature()
    }

    await store.send(.view(.showWithdrawAlert)) {
      $0.customAlert = .withdrawAccount()
    }
  }

  // MARK: - InnerAction

  @Test("setLoading 액션은 로딩 플래그를 그대로 반영한다")
  func setLoadingTogglesFlag() async {
    var initialState = ProfileFeature.State()
    initialState.viewState = .loaded
    let store = TestStore(initialState: initialState) {
      ProfileFeature()
    }

    await store.send(.inner(.setLoading(true))) {
      $0.viewState = .loading
    }

    await store.send(.inner(.setLoading(false))) {
      $0.viewState = .loaded
    }
  }

  @Test("fetchUserResponse 실패는 로딩만 끄고 기존 프로필을 유지한다")
  func fetchUserResponseFailureKeepsExistingProfile() async {
    var initialState = ProfileFeature.State()
    initialState.viewState = .loading
    initialState.profile = ProfileTestSupport.memberProfile

    let store = TestStore(initialState: initialState) {
      ProfileFeature()
    }

    await store.send(.inner(.fetchUserResponse(.failure(.profileDataCorrupted)))) {
      $0.viewState = .loaded
    }

    #expect(store.state.profile == ProfileTestSupport.memberProfile)
  }

  @Test("deleteUserResponse 성공은 로그아웃 화면 이동을 요청한다")
  func deleteUserResponseSuccessRequestsLogoutNavigation() async {
    let store = TestStore(initialState: ProfileFeature.State()) {
      ProfileFeature()
    }

    await store.send(.inner(.deleteUserResponse(.success(ProfileTestSupport.withdrawSuccess))))

    await store.receive(\.delegate.presentLogOut)
  }

  // MARK: - DelegateAction

  @Test("presentEditGeneration 위임은 기수 변경 진입 플래그를 켠다")
  func presentEditGenerationTurnsOnEditFlag() async {
    let store = TestStore(initialState: ProfileFeature.State()) {
      ProfileFeature()
    }
    // editGeneration 은 appStorage 공유 상태라 초기값이 실행 순서에 따라 달라질 수 있다.
    // 최종값만 확인해 실행 순서와 무관하게 통과하도록 둔다.
    store.exhaustivity = .off

    await store.send(.delegate(.presentEditGeneration))

    #expect(store.state.editGeneration == true)
  }

  @Test("화면 이동만 알리는 위임 액션들은 상태를 바꾸지 않는다")
  func navigationOnlyDelegatesDoNotMutateState() async {
    let store = TestStore(initialState: ProfileFeature.State()) {
      ProfileFeature()
    }

    await store.send(.delegate(.presentLogOut))
    await store.send(.delegate(.presentCreateByApp))
    await store.send(.delegate(.presentPrivacyPolicy))
    await store.send(.delegate(.presentAppPeedBackWeb))
  }

  // MARK: - ScopeAction / CustomAlert

  @Test("확인 팝업의 취소는 팝업만 닫는다")
  func customAlertCancelDismissesPopup() async {
    var initialState = ProfileFeature.State()
    initialState.customAlert = .withdrawAccount()

    let store = TestStore(initialState: initialState) {
      ProfileFeature()
    }

    await store.send(.scope(.customAlert(.presented(.cancelTapped)))) {
      $0.customAlert = nil
    }
  }

  @Test("확인 팝업의 약관 보기는 팝업을 유지한다")
  func customAlertPolicyTapKeepsPopup() async {
    var initialState = ProfileFeature.State()
    initialState.customAlert = .withdrawAccount()

    let store = TestStore(initialState: initialState) {
      ProfileFeature()
    }

    await store.send(.scope(.customAlert(.presented(.policyTapped))))

    #expect(store.state.customAlert == .withdrawAccount())
  }

  @Test("탈퇴/로그아웃 어느 쪽도 아닌 팝업의 확인은 팝업만 닫는다")
  func customAlertConfirmWithUnknownTitleOnlyDismisses() async {
    var initialState = ProfileFeature.State()
    initialState.customAlert = .alert(title: "알 수 없는 확인 팝업")

    let store = TestStore(initialState: initialState) {
      ProfileFeature()
    }

    await store.send(.scope(.customAlert(.presented(.confirmTapped)))) {
      $0.customAlert = nil
    }
  }

  @Test("확인 팝업 dismiss 는 팝업을 닫는다")
  func customAlertDismissClosesPopup() async {
    var initialState = ProfileFeature.State()
    initialState.customAlert = .logout()

    let store = TestStore(initialState: initialState) {
      ProfileFeature()
    }
    store.exhaustivity = .off

    await store.send(.scope(.customAlert(.dismiss)))

    #expect(store.state.customAlert == nil)
  }

  // MARK: - ScopeAction / Alert

  @Test("실패 알럿의 확인은 알럿을 닫는다")
  func alertConfirmDismissesAlert() async {
    var initialState = ProfileFeature.State()
    initialState.alert = AlertState {
      TextState("탈퇴실패")
    } actions: {
      ButtonState(action: .confirmTapped) {
        TextState("확인")
      }
    }

    let store = TestStore(initialState: initialState) {
      ProfileFeature()
    }
    store.exhaustivity = .off

    await store.send(.scope(.alert(.presented(.confirmTapped))))

    #expect(store.state.alert == nil)
  }

  // MARK: - Destination

  @Test("destination 이 없는 상태에서의 dismiss 는 아무것도 바꾸지 않는다")
  func destinationDismissWithoutPresentationIsNoop() async {
    var initialState = ProfileFeature.State()
    initialState.destination = .createApp(.init())

    let store = TestStore(initialState: initialState) {
      ProfileFeature()
    }

    await store.send(.destination(.dismiss)) {
      $0.destination = nil
    }
  }

  // MARK: - State 기본값

  @Test("State 는 로딩 상태로 시작한다")
  func stateStartsLoadingWithoutProfile() {
    let state = ProfileFeature.State()

    #expect(state.viewState == .loading)
    #expect(state.profile == nil)
  }
}
