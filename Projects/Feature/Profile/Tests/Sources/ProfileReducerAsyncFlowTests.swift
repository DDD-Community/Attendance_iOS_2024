//
//  ProfileReducerAsyncFlowTests.swift
//  ProfileTests
//
//  Created by DDD on 2026-09-03
//  Copyright © 2026 DDD , Ltd. All rights reserved.
//
//  ProfileFeature 의 비동기 이펙트(fetchUser / deleteUser / logout)와
//  destination 이 만들어내는 액션 흐름을 검증한다.
//

import ComposableArchitecture
import Foundation
import Testing
import AuthDomainInterface
import ProfileDomainInterface

@testable import Profile

@MainActor
@Suite("ProfileFeature 비동기 흐름")
struct ProfileReducerAsyncFlowTests {
  // MARK: - fetchUser

  @Test("캐시가 있으면 캐시를 먼저 표시하고 이어서 서버 갱신 결과로 덮어쓴다")
  func fetchUserWithCacheEmitsCachedThenRefreshed() async {
    let cached = ProfileTestSupport.memberProfile
    let refreshed = ProfileTestSupport.managerProfile

    let store = TestStore(initialState: ProfileFeature.State()) {
      ProfileFeature()
    } withDependencies: {
      $0.profileUseCase = StubProfileUseCase(
        cachedProfile: cached,
        getProfileResult: .success(cached),
        refreshProfileResult: .success(refreshed)
      )
    }

    await store.send(.async(.fetchUser))

    await store.receive(\.inner.fetchUserResponse) {
      $0.viewState = .loaded
      $0.profile = cached
    }

    await store.receive(\.inner.fetchUserResponse) {
      $0.profile = refreshed
    }
  }

  @Test("캐시가 있어도 서버 갱신이 실패하면 캐시 프로필이 그대로 남는다")
  func fetchUserWithCacheKeepsCachedWhenRefreshFails() async {
    let cached = ProfileTestSupport.memberProfile

    let store = TestStore(initialState: ProfileFeature.State()) {
      ProfileFeature()
    } withDependencies: {
      $0.profileUseCase = StubProfileUseCase(
        cachedProfile: cached,
        getProfileResult: .success(cached),
        refreshProfileResult: .failure(.profileNotFound)
      )
    }

    await store.send(.async(.fetchUser))

    await store.receive(\.inner.fetchUserResponse) {
      $0.viewState = .loaded
      $0.profile = cached
    }

    await store.receive(\.inner.fetchUserResponse)

    #expect(store.state.profile == cached)
  }

  @Test("캐시가 없으면 로딩을 켠 뒤 서버 조회 결과를 저장한다")
  func fetchUserWithoutCacheTurnsOnLoadingThenStoresProfile() async {
    let fetched = ProfileTestSupport.managerProfile

    let store = TestStore(initialState: ProfileFeature.State()) {
      ProfileFeature()
    } withDependencies: {
      $0.profileUseCase = StubProfileUseCase(
        cachedProfile: nil,
        getProfileResult: .success(fetched),
        refreshProfileResult: .success(fetched)
      )
    }

    await store.send(.async(.fetchUser))

    await store.receive(\.inner.setLoading)

    await store.receive(\.inner.fetchUserResponse) {
      $0.viewState = .loaded
      $0.profile = fetched
    }
  }

  @Test("캐시도 없고 서버 조회도 실패하면 로딩만 꺼지고 프로필은 비어 있다")
  func fetchUserFailureTurnsOffLoadingAndKeepsProfileNil() async {
    let store = TestStore(initialState: ProfileFeature.State()) {
      ProfileFeature()
    } withDependencies: {
      $0.profileUseCase = StubProfileUseCase(
        cachedProfile: nil,
        getProfileResult: .failure(.profileAccessDenied),
        refreshProfileResult: .failure(.profileAccessDenied)
      )
    }

    await store.send(.async(.fetchUser))

    await store.receive(\.inner.setLoading)

    await store.receive(\.inner.fetchUserResponse) {
      $0.viewState = .loaded
    }

    #expect(store.state.profile == nil)
  }

  @Test("기수 변경 중에는 기존 프로필을 다시 조회하지 않는다")
  func fetchUserWhileEditingGenerationIsIgnored() async {
    let suiteName = "ProfileReducerAsyncFlowTests.\(UUID().uuidString)"
    let appStorage = UserDefaults(suiteName: suiteName)!
    defer { appStorage.removePersistentDomain(forName: suiteName) }

    let initialState = withDependencies {
      $0.defaultAppStorage = appStorage
    } operation: {
      var state = ProfileFeature.State()
      state.$editGeneration.withLock { $0 = true }
      return state
    }

    let store = TestStore(initialState: initialState) {
      ProfileFeature()
    } withDependencies: {
      $0.defaultAppStorage = appStorage
      $0.profileUseCase = StubProfileUseCase(
        cachedProfile: nil,
        getProfileResult: .success(ProfileTestSupport.memberProfile)
      )
    }

    await store.send(.async(.fetchUser))
    await store.finish()
  }

  // MARK: - deleteUser

  @Test("탈퇴 확인 팝업의 확인은 탈퇴 요청을 태우고 로그아웃 화면 이동을 요청한다")
  func withdrawConfirmRunsDeleteUserAndRequestsLogoutNavigation() async {
    var initialState = ProfileFeature.State()
    initialState.customAlert = .withdrawAccount()

    let store = TestStore(initialState: initialState) {
      ProfileFeature()
    } withDependencies: {
      $0.authUseCase = StubAuthRepository()
    }

    await store.send(.scope(.customAlert(.presented(.confirmTapped)))) {
      $0.customAlert = nil
    }

    await store.receive(\.async.deleteUser)

    await store.receive(\.inner.deleteUserResponse)

    await store.receive(\.delegate.presentLogOut)
  }

  @Test("탈퇴 응답이 isSuccess=false 면 화면 이동을 요청하지 않는다")
  func deleteUserRejectedDoesNotNavigate() async {
    let store = TestStore(initialState: ProfileFeature.State()) {
      ProfileFeature()
    } withDependencies: {
      $0.authUseCase = StubAuthRepository(
        withdrawResult: .success(ProfileTestSupport.withdrawRejected)
      )
    }

    await store.send(.async(.deleteUser))

    await store.receive(\.inner.deleteUserResponse)
  }

  @Test("탈퇴 요청이 실패하면 탈퇴 실패 알럿을 띄운다")
  func deleteUserFailurePresentsWithdrawFailureAlert() async {
    let error = AuthError.accountDeletionFailed

    let store = TestStore(initialState: ProfileFeature.State()) {
      ProfileFeature()
    } withDependencies: {
      $0.authUseCase = StubAuthRepository(withdrawResult: .failure(error))
    }

    await store.send(.async(.deleteUser))

    await store.receive(\.inner.deleteUserResponse) {
      $0.alert = AlertState {
        TextState("탈퇴실패")
      } actions: {
        ButtonState(action: .confirmTapped) {
          TextState("확인")
        }
      } message: {
        TextState("회원 탈퇴 실패: \(String(describing: error.errorDescription ?? error.localizedDescription))")
      }
    }
  }

  // MARK: - logout

  @Test("로그아웃 확인 팝업의 확인은 로그아웃 요청을 태우고 로그아웃 화면 이동을 요청한다")
  func logoutConfirmRunsLogoutAndRequestsLogoutNavigation() async {
    var initialState = ProfileFeature.State()
    initialState.customAlert = .logout()

    let store = TestStore(initialState: initialState) {
      ProfileFeature()
    } withDependencies: {
      $0.authUseCase = StubAuthRepository()
    }

    await store.send(.scope(.customAlert(.presented(.confirmTapped)))) {
      $0.customAlert = nil
    }

    await store.receive(\.async.logout)

    await store.receive(\.inner.logoutResponses)

    await store.receive(\.delegate.presentLogOut)
  }

  @Test("로그아웃 요청이 실패하면 로그아웃 실패 알럿을 띄운다")
  func logoutFailurePresentsLogoutFailureAlert() async {
    let error = AuthError.logoutFailed

    let store = TestStore(initialState: ProfileFeature.State()) {
      ProfileFeature()
    } withDependencies: {
      $0.authUseCase = StubAuthRepository(logoutResult: .failure(error))
    }

    await store.send(.async(.logout))

    await store.receive(\.inner.logoutResponses) {
      $0.alert = AlertState {
        TextState("로그 아웃 실패")
      } actions: {
        ButtonState(action: .confirmTapped) {
          TextState("확인")
        }
      } message: {
        TextState("로그 아웃 실패: \(String(describing: AuthError.unknownError(error.errorDescription ?? "")))")
      }
    }
  }

  // MARK: - destination

  @Test("앱 피드백 모달의 웹 이동 위임은 모달을 닫고 잠시 뒤 웹 화면 이동을 요청한다")
  func createAppPresentWebClosesModalThenRequestsFeedbackWeb() async {
    let clock = TestClock()

    var initialState = ProfileFeature.State()
    initialState.destination = .createApp(.init())

    let store = TestStore(initialState: initialState) {
      ProfileFeature()
    } withDependencies: {
      $0.continuousClock = clock
    }

    await store.send(.destination(.presented(.createApp(.delegate(.presentWeb))))) {
      $0.destination = nil
    }

    await clock.advance(by: .seconds(0.05))

    await store.receive(\.delegate.presentAppPeedBackWeb)
  }
}
