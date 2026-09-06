//
//  SelectManagingReducerTests.swift
//  OnBoardingTests
//
//  SelectManagingFeature 의 담당 업무 토글, 목록 조회, 가입/기수변경 분기를 검증한다.
//

import ComposableArchitecture
import Foundation
import AuthDomainInterface
import OnBoardingDomainInterface
import ProfileDomainInterface
import Testing

@testable import OnBoarding

@MainActor
@Suite("SelectManagingFeature")
struct SelectManagingReducerTests {
  // MARK: - ViewAction

  @Test("목록이 비어 있으면 onAppear 가 담당 업무 목록을 조회한다")
  func onAppearFetchesManagingList() async {
    let store = TestStore(initialState: SelectManagingFeature.State()) {
      SelectManagingFeature()
    } withDependencies: {
      $0.onBoardingUseCase = StubOnBoardingRepository(managings: OnBoardingCoverageFixture.managings)
    }

    await store.send(.view(.onAppear))
    await store.receive(\.async)
    await store.receive(\.inner) {
      $0.viewState = .loaded
      $0.managers = .init(uniqueElements: OnBoardingCoverageFixture.managings)
    }
  }

  @Test("목록이 이미 있으면 onAppear 는 다시 조회하지 않는다")
  func onAppearSkipsFetchWhenListAlreadyLoaded() async {
    var state = SelectManagingFeature.State()
    state.managers = .init(uniqueElements: OnBoardingCoverageFixture.managings)

    let store = TestStore(initialState: state) {
      SelectManagingFeature()
    }

    await store.send(.view(.onAppear))
  }

  @Test("담당 업무 목록 조회 실패는 로딩 상태를 종료한다")
  func managingListFailureFinishesLoading() async {
    let store = TestStore(initialState: SelectManagingFeature.State()) {
      SelectManagingFeature()
    } withDependencies: {
      $0.onBoardingUseCase = StubOnBoardingRepository(failure: .verifyFailed)
    }

    await store.send(.view(.onAppear))
    await store.receive(\.async)
    await store.receive(\.inner) {
      $0.viewState = .loaded
    }
  }

  @Test("담당 업무를 처음 누르면 세션에 추가되고 버튼이 활성화된다")
  func selectManagingButtonAppendsManaging() async {
    let store = TestStore(initialState: SelectManagingFeature.State()) {
      SelectManagingFeature()
    }
    store.exhaustivity = .off

    await store.send(.view(.selectManagingButton(selectManaging: OnBoardingCoverageFixture.photoManaging))) {
      $0.userSession.managing = [.photo]
    }
  }

  @Test("이미 선택된 담당 업무를 다시 누르면 제거되고 버튼이 비활성화된다")
  func selectManagingButtonRemovesManaging() async {
    var state = SelectManagingFeature.State()
    state.userSession.managing = [.photo]

    let store = TestStore(initialState: state) {
      SelectManagingFeature()
    }

    await store.send(.view(.selectManagingButton(selectManaging: OnBoardingCoverageFixture.photoManaging))) {
      $0.userSession.managing = []
    }
  }

  // MARK: - 회원가입 / 기수 변경

  @Test("가입 완료는 회원가입을 호출하고 운영진 홈으로 이동한다")
  func signUpNavigatesToManager() async {
    var state = SelectManagingFeature.State()
    state.editGeneration = false
    state.userSession.userRole = .manager

    let store = TestStore(initialState: state) {
      SelectManagingFeature()
    } withDependencies: {
      $0.signUpUseCase = StubSignUpUseCase()
    }
    store.exhaustivity = .off

    await store.send(.view(.signUp))
    await store.receive(\.async)
    await store.receive(\.inner) {
      $0.staffRole = .manager
    }
    await store.receive(\.delegate.presentManager)
  }

  @Test("회원가입 실패는 실패 알럿을 표시한다")
  func signUpFailurePresentsAlert() async {
    let store = TestStore(initialState: SelectManagingFeature.State()) {
      SelectManagingFeature()
    } withDependencies: {
      $0.signUpUseCase = StubSignUpUseCase(failure: .accountCreationFailed)
    }

    let error = SignUpError.accountCreationFailed

    await store.send(.view(.signUp))
    await store.receive(\.async)
    await store.receive(\.inner) {
      $0.alert = AlertState {
        TextState("회원가입 실패")
      } actions: {
        ButtonState(action: .confirmTapped) {
          TextState("확인")
        }
      } message: {
        TextState(error.errorDescription ?? "알 수 없는 오류가 발생했습니다.")
      }
    }
  }

  @Test("기수 변경 중이면 가입 완료가 프로필 수정을 호출하고 멤버 홈으로 이동한다")
  func editGenerationNavigatesToMember() async {
    let profile = OnBoardingCoverageFixture.memberProfile
    let authUseCase = MockAuthRepository.refreshSuccess()
    let appStorage = UserDefaults.inMemory
    let inMemoryStorage = InMemoryStorage()
    appStorage.set(true, forKey: "editGeneration")

    let store = TestStore(initialState: SelectManagingFeature.State()) {
      SelectManagingFeature()
    } withDependencies: {
      $0.defaultAppStorage = appStorage
      $0.defaultInMemoryStorage = inMemoryStorage
      $0.profileUseCase = StubProfileUseCase(profile: profile)
      $0.authUseCase = authUseCase
    }
    store.exhaustivity = .off

    await store.send(.view(.signUp))
    await store.receive(\.async)
    await store.receive(\.inner) {
      $0.editGeneration = false
      $0.staffRole = .member
      $0.userSession.userID = profile.userID
      $0.userSession.name = profile.name
      $0.userSession.generation = profile.generation
      $0.userSession.selectTeam = .web1
      $0.userSession.selectPart = profile.jobRole
      $0.userSession.userRole = .member
      $0.userSession.managing = []
    }
    await store.receive(\.delegate.presentMember)
    #expect(authUseCase.getRefreshCallCount() == 1)
    #expect(authUseCase.getUpdateCredentialCallCount() == 1)
  }

  @Test("기수 변경 후 토큰 갱신 실패 시 운영진 API를 호출하지 않고 로그인으로 이동한다")
  func credentialRefreshFailureNavigatesToLogin() async {
    let profile = OnBoardingCoverageFixture.managerProfile
    let appStorage = UserDefaults.inMemory
    let inMemoryStorage = InMemoryStorage()
    appStorage.set(true, forKey: "editGeneration")

    let store = TestStore(initialState: SelectManagingFeature.State()) {
      SelectManagingFeature()
    } withDependencies: {
      $0.defaultAppStorage = appStorage
      $0.defaultInMemoryStorage = inMemoryStorage
      $0.profileUseCase = StubProfileUseCase(profile: profile)
      $0.authUseCase = MockAuthRepository.tokenExpired()
    }
    store.exhaustivity = .off(showSkippedAssertions: false)

    await store.send(.view(.signUp))
    await store.receive(\.async)
    await store.receive(\.inner)
    await store.receive(\.delegate.presentLogin)
    #expect(store.state.editGeneration == false)
    #expect(store.state.staffRole == .manager)
  }

  @Test("프로필 수정 결과가 운영진이면 운영진 홈으로 이동한다")
  func editProfileManagerNavigatesToManager() async {
    var state = SelectManagingFeature.State()
    state.editGeneration = true

    let profile = OnBoardingCoverageFixture.managerProfile

    let store = TestStore(initialState: state) {
      SelectManagingFeature()
    }

    await store.send(.inner(.editProfileResponse(.success(profile)))) {
      $0.editGeneration = false
      $0.staffRole = .manager
      $0.userSession.userID = profile.userID
      $0.userSession.name = profile.name
      $0.userSession.generation = profile.generation
      $0.userSession.selectTeam = .ios1
      $0.userSession.selectPart = profile.jobRole
      $0.userSession.userRole = .manager
      $0.userSession.managing = [.teamManaging]
    }
    await store.receive(\.delegate.presentManager)
  }

  @Test("프로필 수정 실패는 기수 변경 플래그를 내리고 실패 알럿을 표시한다")
  func editProfileFailurePresentsAlert() async {
    var state = SelectManagingFeature.State()
    state.editGeneration = true

    let store = TestStore(initialState: state) {
      SelectManagingFeature()
    }

    let error = ProfileError.profileNotFound

    await store.send(.inner(.editProfileResponse(.failure(error)))) {
      $0.editGeneration = false
      $0.alert = AlertState {
        TextState("프로필 수정 실패")
      } actions: {
        ButtonState(action: .confirmTapped) {
          TextState("확인")
        }
      } message: {
        TextState(error.errorDescription ?? "알 수 없는 오류가 발생했습니다.")
      }
    }
  }

  // MARK: - Delegate / Scope / Binding

  @Test("delegate 액션은 모두 부수효과 없이 소비된다")
  func delegateActionsProduceNoEffect() async {
    let store = TestStore(initialState: SelectManagingFeature.State()) {
      SelectManagingFeature()
    }

    await store.send(.delegate(.presentManager))
    await store.send(.delegate(.presentMember))
    await store.send(.delegate(.presentLogin))
    await store.send(.delegate(.presentSelectTeam))
    await store.send(.delegate(.presentProfile))
  }

  @Test("알럿을 닫으면 alert 상태가 비워진다")
  func dismissingAlertClearsState() async {
    var state = SelectManagingFeature.State()
    state.alert = AlertState {
      TextState("회원가입 실패")
    } actions: {
      ButtonState(action: .confirmTapped) {
        TextState("확인")
      }
    }

    let store = TestStore(initialState: state) {
      SelectManagingFeature()
    }

    await store.send(.scope(.alert(.dismiss))) {
      $0.alert = nil
    }
  }

  @Test("binding 액션은 상태만 갱신한다")
  func bindingUpdatesStateOnly() async {
    let store = TestStore(initialState: SelectManagingFeature.State()) {
      SelectManagingFeature()
    }

    await store.send(.binding(.set(\.viewState, .loaded))) {
      $0.viewState = .loaded
    }
  }
}
