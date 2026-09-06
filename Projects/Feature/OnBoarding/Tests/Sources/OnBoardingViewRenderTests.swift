//
//  OnBoardingViewRenderTests.swift
//  OnBoardingTests
//
//  온보딩 5개 화면의 body 와 @ViewBuilder 헬퍼가 실제로 평가되도록
//  상태 조합별로 렌더링한다. 크래시 없이 레이아웃이 끝나는 것이 통과 조건이다.
//

import ComposableArchitecture
import OnBoardingDomainInterface
import ProfileDomainInterface
import Testing

@testable import OnBoarding

@MainActor
@Suite("OnBoardingViewRendering")
struct OnBoardingViewRenderTests {
  // MARK: - InviteCode

  @Test("초대 코드 화면은 빈 입력 상태에서 렌더링된다")
  func renderInviteCodeEmpty() {
    let store = Store(initialState: InviteCodeFeature.State()) {
      InviteCodeFeature()
    } withDependencies: {
      $0.onBoardingUseCase = StubOnBoardingRepository()
    }

    OnBoardingViewRenderer.render(InviteCodeView(store: store))
  }

  @Test("초대 코드 화면은 네 칸이 모두 채워진 상태에서 렌더링된다")
  func renderInviteCodeFilled() {
    var state = InviteCodeFeature.State()
    state.firstInviteCode = "1"
    state.secondInviteCode = "2"
    state.thirdInviteCode = "3"
    state.lastInviteCode = "4"
    state.focusedField = .last

    let store = Store(initialState: state) {
      InviteCodeFeature()
    } withDependencies: {
      $0.onBoardingUseCase = StubOnBoardingRepository()
    }

    OnBoardingViewRenderer.render(InviteCodeView(store: store))
  }

  @Test("초대 코드 화면은 오류 표시 상태에서 에러 문구까지 렌더링된다")
  func renderInviteCodeInvalid() {
    var state = InviteCodeFeature.State()
    state.firstInviteCode = "9"
    state.isNotAvailableCode = true

    let store = Store(initialState: state) {
      InviteCodeFeature()
    } withDependencies: {
      $0.onBoardingUseCase = StubOnBoardingRepository()
    }

    OnBoardingViewRenderer.render(InviteCodeView(store: store))
  }

  // MARK: - OnBoardingNameFeature

  @Test("이름 입력 화면은 기본 상태에서 렌더링된다")
  func renderNameDefault() {
    let store = Store(initialState: OnBoardingNameFeature.State()) {
      OnBoardingNameFeature()
    }

    OnBoardingViewRenderer.render(OnBoardingNameView(store: store))
  }

  @Test("이름 입력 화면은 사용 불가 상태에서 에러 문구까지 렌더링된다")
  func renderNameUnavailable() {
    var state = OnBoardingNameFeature.State()
    state.userSession.name = "홍길동"
    state.isNotAvailableName = true

    let store = Store(initialState: state) {
      OnBoardingNameFeature()
    }

    OnBoardingViewRenderer.render(OnBoardingNameView(store: store))
  }

  // MARK: - SelectPart

  @Test("직무 선택 화면은 로딩 상태에서 렌더링된다")
  func renderSelectPartLoading() {
    var state = SelectPartFeature.State()
    state.viewState = .loading

    let store = Store(initialState: state) {
      SelectPartFeature()
    } withDependencies: {
      $0.onBoardingUseCase = StubOnBoardingRepository(jobs: OnBoardingCoverageFixture.jobs)
    }

    OnBoardingViewRenderer.render(SelectPartView(store: store))
  }

  @Test("직무 선택 화면은 목록이 채워지고 선택된 상태에서 렌더링된다")
  func renderSelectPartLoaded() {
    var state = SelectPartFeature.State()
    state.viewState = .loaded
    state.selectJobs = .init(uniqueElements: OnBoardingCoverageFixture.jobs)
    state.selectPart = .ios
    state.activeSelectPart = true

    let store = Store(initialState: state) {
      SelectPartFeature()
    } withDependencies: {
      $0.onBoardingUseCase = StubOnBoardingRepository(jobs: OnBoardingCoverageFixture.jobs)
    }

    OnBoardingViewRenderer.render(SelectPartView(store: store))
  }

  // MARK: - SelectManaging

  @Test("담당 업무 선택 화면은 로딩 상태에서 렌더링된다")
  func renderSelectManagingLoading() {
    var state = SelectManagingFeature.State()
    state.viewState = .loading

    let store = Store(initialState: state) {
      SelectManagingFeature()
    } withDependencies: {
      $0.onBoardingUseCase = StubOnBoardingRepository(managings: OnBoardingCoverageFixture.managings)
    }

    OnBoardingViewRenderer.render(SelectManagingView(store: store))
  }

  @Test("담당 업무 선택 화면은 운영진일 때 다음 버튼으로 렌더링된다")
  func renderSelectManagingForManager() {
    var state = SelectManagingFeature.State()
    state.viewState = .loaded
    state.managers = .init(uniqueElements: OnBoardingCoverageFixture.managings)
    state.userSession.userRole = .manager

    let store = Store(initialState: state) {
      SelectManagingFeature()
    } withDependencies: {
      $0.onBoardingUseCase = StubOnBoardingRepository(managings: OnBoardingCoverageFixture.managings)
    }

    OnBoardingViewRenderer.render(SelectManagingView(store: store))
  }

  @Test("담당 업무 선택 화면은 멤버일 때 가입완료 버튼으로 렌더링된다")
  func renderSelectManagingForMember() {
    var state = SelectManagingFeature.State()
    state.viewState = .loaded
    state.managers = .init(uniqueElements: OnBoardingCoverageFixture.managings)
    state.userSession.userRole = .member

    let store = Store(initialState: state) {
      SelectManagingFeature()
    } withDependencies: {
      $0.onBoardingUseCase = StubOnBoardingRepository(managings: OnBoardingCoverageFixture.managings)
    }

    OnBoardingViewRenderer.render(SelectManagingView(store: store))
  }

  // MARK: - SelectTeamFeature

  @Test("팀 선택 화면은 로딩 상태에서 렌더링된다")
  func renderSelectTeamLoading() {
    var state = SelectTeamFeature.State()
    state.viewState = .loading

    let store = Store(initialState: state) {
      SelectTeamFeature()
    } withDependencies: {
      $0.onBoardingUseCase = StubOnBoardingRepository(teams: OnBoardingCoverageFixture.teams)
      $0.signUpUseCase = StubSignUpUseCase()
      $0.profileUseCase = StubProfileUseCase()
    }

    OnBoardingViewRenderer.render(SelectTeamView(store: store))
  }

  @Test("팀 선택 화면은 목록이 채워지고 팀이 선택된 상태에서 렌더링된다")
  func renderSelectTeamLoaded() {
    var state = SelectTeamFeature.State()
    state.viewState = .loaded
    state.teams = .init(uniqueElements: OnBoardingCoverageFixture.teams)
    state.selectTeam = .ios1
    state.activeButton = true
    state.userSession.selectTeam = .ios1

    let store = Store(initialState: state) {
      SelectTeamFeature()
    } withDependencies: {
      $0.onBoardingUseCase = StubOnBoardingRepository(teams: OnBoardingCoverageFixture.teams)
      $0.signUpUseCase = StubSignUpUseCase()
      $0.profileUseCase = StubProfileUseCase()
    }

    OnBoardingViewRenderer.render(SelectTeamView(store: store))
  }

  @Test("팀 선택 화면은 실패 알럿이 떠 있는 상태에서도 렌더링된다")
  func renderSelectTeamWithAlert() {
    var state = SelectTeamFeature.State()
    state.viewState = .loaded
    state.teams = .init(uniqueElements: OnBoardingCoverageFixture.teams)
    state.alert = AlertState {
      TextState("회원가입 실패")
    } actions: {
      ButtonState(action: .confirmTapped) {
        TextState("확인")
      }
    } message: {
      TextState("알 수 없는 오류가 발생했습니다.")
    }

    let store = Store(initialState: state) {
      SelectTeamFeature()
    } withDependencies: {
      $0.onBoardingUseCase = StubOnBoardingRepository(teams: OnBoardingCoverageFixture.teams)
      $0.signUpUseCase = StubSignUpUseCase()
      $0.profileUseCase = StubProfileUseCase()
    }

    OnBoardingViewRenderer.render(SelectTeamView(store: store))
  }
}
