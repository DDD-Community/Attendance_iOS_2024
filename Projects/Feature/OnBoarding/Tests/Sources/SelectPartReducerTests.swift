//
//  SelectPartReducerTests.swift
//  OnBoardingTests
//
//  SelectPartFeature 의 선택/해제, 직무 목록 조회, 다음 단계 분기를 검증한다.
//

import ComposableArchitecture
import OnBoardingDomainInterface
import ProfileDomainInterface
import Testing

@testable import OnBoarding

@MainActor
@Suite("SelectPartFeature")
struct SelectPartReducerTests {
  @Test("직무를 선택하면 세션에 반영되고 다음 버튼이 활성화된다")
  func selectPartButtonSelectsJob() async {
    let store = TestStore(initialState: SelectPartFeature.State()) {
      SelectPartFeature()
    }

    await store.send(.view(.selectPartButton(selectPart: OnBoardingCoverageFixture.iosJob))) {
      $0.selectPart = .ios
      $0.activeSelectPart = true
      $0.userSession.selectPart = .ios
    }
  }

  @Test("같은 직무를 다시 선택하면 선택이 해제되고 세션이 전체로 되돌아간다")
  func reselectingSameJobClearsSelection() async {
    var state = SelectPartFeature.State()
    state.selectPart = .ios
    state.activeSelectPart = true
    state.userSession.selectPart = .ios

    let store = TestStore(initialState: state) {
      SelectPartFeature()
    }

    await store.send(.view(.selectPartButton(selectPart: OnBoardingCoverageFixture.iosJob))) {
      $0.selectPart = nil
      $0.activeSelectPart = false
      $0.userSession.selectPart = .all
    }
  }

  @Test("초기 상태(.all)에서 다른 직무를 고르면 곧바로 선택된다")
  func selectingDifferentJobFromDefault() async {
    let store = TestStore(initialState: SelectPartFeature.State()) {
      SelectPartFeature()
    }

    await store.send(.view(.selectPartButton(selectPart: OnBoardingCoverageFixture.backendJob))) {
      $0.selectPart = .backend
      $0.activeSelectPart = true
      $0.userSession.selectPart = .backend
    }
  }

  @Test("onAppear 는 직무 목록을 조회해 상태에 채운다")
  func onAppearFetchesJobList() async {
    let store = TestStore(initialState: SelectPartFeature.State()) {
      SelectPartFeature()
    } withDependencies: {
      $0.onBoardingUseCase = StubOnBoardingRepository(jobs: OnBoardingCoverageFixture.jobs)
    }

    await store.send(.view(.onAppear))
    await store.receive(\.async)
    await store.receive(\.inner) {
      $0.viewState = .loaded
      $0.selectJobs = .init(uniqueElements: OnBoardingCoverageFixture.jobs)
    }
  }

  @Test("직무 목록 조회 실패는 로딩 상태를 종료한다")
  func jobListFailureFinishesLoading() async {
    let store = TestStore(initialState: SelectPartFeature.State()) {
      SelectPartFeature()
    } withDependencies: {
      $0.onBoardingUseCase = StubOnBoardingRepository(failure: .networkError)
    }

    await store.send(.view(.onAppear))
    await store.receive(\.async)
    await store.receive(\.inner) {
      $0.viewState = .loaded
    }
  }

  @Test("운영진이면 다음 단계에서 담당 업무 선택으로 이동한다")
  func nextStepForManagerGoesToManaging() async {
    var state = SelectPartFeature.State()
    state.userSession.userRole = .manager

    let store = TestStore(initialState: state) {
      SelectPartFeature()
    }

    await store.send(.delegate(.presentNextStep))
    await store.receive(\.delegate.presentManaging)
  }

  @Test("멤버면 다음 단계에서 팀 선택으로 이동한다")
  func nextStepForMemberGoesToSelectTeam() async {
    var state = SelectPartFeature.State()
    state.userSession.userRole = .member

    let store = TestStore(initialState: state) {
      SelectPartFeature()
    }

    await store.send(.delegate(.presentNextStep))
    await store.receive(\.delegate.presentSelectTeam)
  }

  @Test("binding 액션은 상태만 갱신한다")
  func bindingUpdatesStateOnly() async {
    let store = TestStore(initialState: SelectPartFeature.State()) {
      SelectPartFeature()
    }

    await store.send(.binding(.set(\.activeSelectPart, true))) {
      $0.activeSelectPart = true
    }
  }
}
