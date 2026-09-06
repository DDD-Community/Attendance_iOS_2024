//
//  SelectTeamReducerTests.swift
//  OnBoardingTests
//
//  SelectTeamFeature 리듀서의 view / async / inner / delegate / scope / binding 분기를 모두 태운다.
//

import ComposableArchitecture
import Foundation
import AuthDomainInterface
import OnBoardingDomainInterface
import ProfileDomainInterface
import Testing

@testable import OnBoarding

@MainActor
@Suite("SelectTeamReducer")
struct SelectTeamReducerTests {
  // MARK: - ViewAction

  @Test("팀을 처음 선택하면 세션에 팀과 팀ID가 저장되고 버튼이 활성화된다")
  func selectTeamButtonSelectsTeamAndEnablesButton() async {
    let store = TestStore(initialState: SelectTeamFeature.State()) {
      SelectTeamFeature()
    }

    await store.send(.view(.selectTeamButton(selectTeam: OnBoardingCoverageFixture.iosTeam))) {
      $0.selectTeam = .ios1
      $0.activeButton = true
      $0.userSession.selectTeam = .ios1
      $0.userSession.selectTeamId = 1
    }
  }

  @Test("같은 팀을 다시 선택하면 선택이 해제되고 버튼이 비활성화된다")
  func reselectingSameTeamClearsSelection() async {
    var state = SelectTeamFeature.State()
    state.selectTeam = .ios1
    state.activeButton = true
    state.userSession.selectTeam = .ios1
    state.userSession.selectTeamId = 1

    let store = TestStore(initialState: state) {
      SelectTeamFeature()
    }

    await store.send(.view(.selectTeamButton(selectTeam: OnBoardingCoverageFixture.iosTeam))) {
      $0.selectTeam = nil
      $0.activeButton = false
      $0.userSession.selectTeam = .unknown
      $0.userSession.selectTeamId = nil
    }
  }

  @Test("onAppear 는 팀 목록 조회를 시작하고 응답을 상태에 반영한다")
  func onAppearFetchesTeamList() async {
    let store = TestStore(initialState: SelectTeamFeature.State()) {
      SelectTeamFeature()
    } withDependencies: {
      $0.onBoardingUseCase = StubOnBoardingRepository(teams: OnBoardingCoverageFixture.teams)
    }

    await store.send(.view(.onAppear))
    await store.receive(\.async)
    await store.receive(\.inner) {
      $0.teams = .init(uniqueElements: OnBoardingCoverageFixture.teams)
      $0.viewState = .loaded
    }
  }

  @Test("팀 목록 조회 실패는 로그만 남기고 상태를 바꾸지 않는다")
  func teamListFailureKeepsLoadingState() async {
    let store = TestStore(initialState: SelectTeamFeature.State()) {
      SelectTeamFeature()
    } withDependencies: {
      $0.onBoardingUseCase = StubOnBoardingRepository(failure: .networkError)
    }

    await store.send(.view(.onAppear))
    await store.receive(\.async)
    // 실패해도 loading 은 내려야 스켈레톤이 걷힌다.
    await store.receive(\.inner) {
      $0.viewState = .loaded
    }
  }

  // MARK: - 회원가입 경로

  @Test("운영진이 가입 완료를 누르면 팀매니징이 자동 추가되고 운영진 홈으로 이동한다")
  func managerSignUpAppendsTeamManagingAndNavigatesToManager() async {
    var state = SelectTeamFeature.State()
    state.userSession.userRole = .manager
    state.editGeneration = false

    let store = TestStore(initialState: state) {
      SelectTeamFeature()
    } withDependencies: {
      $0.signUpUseCase = StubSignUpUseCase()
    }
    store.exhaustivity = .off

    await store.send(.view(.signUp)) {
      $0.userSession.managing = [.teamManaging]
    }
    await store.receive(\.async)
    await store.receive(\.inner) {
      $0.staffRole = .manager
    }
    await store.receive(\.delegate.presentManager)
  }

  @Test("멤버가 가입 완료를 누르면 멤버 홈으로 이동한다")
  func memberSignUpNavigatesToMember() async {
    var state = SelectTeamFeature.State()
    state.userSession.userRole = .member
    state.editGeneration = false

    let store = TestStore(initialState: state) {
      SelectTeamFeature()
    } withDependencies: {
      $0.signUpUseCase = StubSignUpUseCase()
    }
    store.exhaustivity = .off

    await store.send(.view(.signUp))
    await store.receive(\.async)
    await store.receive(\.inner) {
      $0.staffRole = .member
    }
    await store.receive(\.delegate.presentMember)
  }

  @Test("회원가입 실패는 실패 알럿을 표시한다")
  func signUpFailurePresentsAlert() async {
    let store = TestStore(initialState: SelectTeamFeature.State()) {
      SelectTeamFeature()
    }

    let error = SignUpError.accountAlreadyExists

    await store.send(.inner(.signUpUserResponse(.failure(error)))) {
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

  // MARK: - 기수 변경(프로필 수정) 경로

  @Test("기수 변경 중이면 가입 완료가 프로필 수정을 호출하고 운영진 홈으로 이동한다")
  func editGenerationSignUpEditsProfile() async {
    let profile = OnBoardingCoverageFixture.managerProfile
    let authUseCase = MockAuthRepository.refreshSuccess()
    let appStorage = UserDefaults.inMemory
    let inMemoryStorage = InMemoryStorage()
    appStorage.set(true, forKey: "editGeneration")

    let store = TestStore(initialState: SelectTeamFeature.State()) {
      SelectTeamFeature()
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
    #expect(authUseCase.getRefreshCallCount() == 1)
    #expect(authUseCase.getUpdateCredentialCallCount() == 1)
  }

  @Test("기수 변경 후 토큰 갱신 실패 시 운영진 API를 호출하지 않고 로그인으로 이동한다")
  func credentialRefreshFailureNavigatesToLogin() async {
    let profile = OnBoardingCoverageFixture.managerProfile
    let appStorage = UserDefaults.inMemory
    let inMemoryStorage = InMemoryStorage()
    appStorage.set(true, forKey: "editGeneration")

    let store = TestStore(initialState: SelectTeamFeature.State()) {
      SelectTeamFeature()
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

  @Test("프로필 수정 결과가 멤버면 멤버 홈으로 이동한다")
  func editProfileMemberNavigatesToMember() async {
    var state = SelectTeamFeature.State()
    state.editGeneration = true

    let profile = OnBoardingCoverageFixture.memberProfile

    let store = TestStore(initialState: state) {
      SelectTeamFeature()
    }

    await store.send(.inner(.editProfileResponse(.success(profile)))) {
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
  }

  @Test("프로필 수정 실패는 기수 변경 플래그를 내리고 실패 알럿을 표시한다")
  func editProfileFailurePresentsAlert() async {
    var state = SelectTeamFeature.State()
    state.editGeneration = true

    let store = TestStore(initialState: state) {
      SelectTeamFeature()
    }

    let error = ProfileError.loadFailed

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

  @Test("프로필 수정 API 실패는 매핑된 ProfileError 로 전달된다")
  func editProfileUseCaseFailureIsMapped() async {
    var state = SelectTeamFeature.State()
    state.editGeneration = true

    let store = TestStore(initialState: state) {
      SelectTeamFeature()
    } withDependencies: {
      $0.profileUseCase = StubProfileUseCase(editFailure: .profileUpdateFailed)
    }
    store.exhaustivity = .off

    await store.send(.view(.signUp))
    await store.receive(\.async)
    await store.receive(\.inner)
  }

  // MARK: - Delegate / Scope / Binding

  @Test("delegate 액션은 모두 부수효과 없이 소비된다")
  func delegateActionsProduceNoEffect() async {
    let store = TestStore(initialState: SelectTeamFeature.State()) {
      SelectTeamFeature()
    }

    await store.send(.delegate(.presentMember))
    await store.send(.delegate(.presentManager))
    await store.send(.delegate(.presentLogin))
    await store.send(.delegate(.presentProfile))
  }

  @Test("알럿을 닫으면 alert 상태가 비워진다")
  func dismissingAlertClearsState() async {
    var state = SelectTeamFeature.State()
    state.alert = AlertState {
      TextState("회원가입 실패")
    } actions: {
      ButtonState(action: .confirmTapped) {
        TextState("확인")
      }
    }

    let store = TestStore(initialState: state) {
      SelectTeamFeature()
    }

    await store.send(.scope(.alert(.dismiss))) {
      $0.alert = nil
    }
  }

  @Test("binding 액션은 상태만 바꾸고 부수효과가 없다")
  func bindingUpdatesStateOnly() async {
    let store = TestStore(initialState: SelectTeamFeature.State()) {
      SelectTeamFeature()
    }

    await store.send(.binding(.set(\.activeButton, true))) {
      $0.activeButton = true
    }
  }
}
