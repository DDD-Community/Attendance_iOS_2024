//
//  ManagementScheduleModalReducerTests.swift
//  ManagementTests
//
//  Created by DDD on 2026-09-03.
//
//  ScheduleModalFeature 의 SWR(캐시 우선) 조회 분기와 선택/확인/델리게이트 경로를 훑는다.
//  네트워크 경로에는 0.6초 지연이 있어 TestClock 으로 시간을 직접 민다.
//

import ComposableArchitecture
import ManagementInterface
import Testing

@testable import Management

@MainActor
@Suite("ManagementScheduleModal")
struct ManagementScheduleModalReducerTests {
  /// 캐시가 있으면 지연 없이 즉시 목록을 채운다(백그라운드 갱신은 이어서 돈다).
  @Test("캐시가 있으면 지연 없이 즉시 목록을 채운다")
  func fetchScheduleUsesCacheFirst() async {
    var stub = ManagementScheduleUseCaseStub()
    stub.cached = ManagementScheduleFixture.all
    stub.schedules = ManagementScheduleFixture.all

    let store = TestStore(initialState: ScheduleModalFeature.State()) {
      ScheduleModalFeature()
    } withDependencies: {
      $0.scheduleUseCase = stub
      $0.continuousClock = TestClock()
    }

    await store.send(.async(.fetchSchedule))
    await store.receive(\.inner) {
      $0.viewState = .loaded
      $0.schedules = .init(uniqueElements: ManagementScheduleFixture.all)
    }
  }

  /// 캐시가 없으면 0.6초 지연 뒤 네트워크 응답을 반영한다.
  @Test("캐시가 없으면 0.6초 지연 후 네트워크 응답을 반영한다")
  func fetchScheduleFallsBackToNetwork() async {
    let clock = TestClock()
    var stub = ManagementScheduleUseCaseStub()
    stub.cached = nil
    stub.schedules = ManagementScheduleFixture.all

    let store = TestStore(initialState: ScheduleModalFeature.State()) {
      ScheduleModalFeature()
    } withDependencies: {
      $0.scheduleUseCase = stub
      $0.continuousClock = clock
    }

    await store.send(.async(.fetchSchedule))
    await clock.advance(by: .seconds(0.6))
    await store.receive(\.inner) {
      $0.viewState = .loaded
      $0.schedules = .init(uniqueElements: ManagementScheduleFixture.all)
    }
  }

  /// 캐시가 "있지만 비어있는" 경계값은 캐시 미스와 같게 네트워크로 넘어가야 한다.
  @Test("빈 캐시는 캐시 미스와 동일하게 네트워크 경로를 탄다")
  func emptyCacheFallsBackToNetwork() async {
    let clock = TestClock()
    var stub = ManagementScheduleUseCaseStub()
    stub.cached = []
    stub.schedules = [ManagementScheduleFixture.demoDay]

    let store = TestStore(initialState: ScheduleModalFeature.State()) {
      ScheduleModalFeature()
    } withDependencies: {
      $0.scheduleUseCase = stub
      $0.continuousClock = clock
    }

    await store.send(.async(.fetchSchedule))
    await clock.advance(by: .seconds(0.6))
    await store.receive(\.inner) {
      $0.viewState = .loaded
      $0.schedules = .init(uniqueElements: [ManagementScheduleFixture.demoDay])
    }
  }

  /// 이미 목록이 차 있으면 재조회에서 로딩 스켈레톤을 띄우지 않는다.
  @Test("목록이 이미 있으면 재조회 시 로딩을 표시하지 않는다")
  func refetchWithExistingListSkipsLoading() async {
    let clock = TestClock()
    var stub = ManagementScheduleUseCaseStub()
    stub.cached = nil
    stub.schedules = ManagementScheduleFixture.all

    // 재조회는 첫 로드가 끝난 뒤 상황이므로 .loaded 에서 출발한다.
    var state = ScheduleModalFeature.State()
    state.viewState = .loaded
    state.schedules = .init(uniqueElements: [ManagementScheduleFixture.orientation])

    let store = TestStore(initialState: state) {
      ScheduleModalFeature()
    } withDependencies: {
      $0.scheduleUseCase = stub
      $0.continuousClock = clock
    }

    await store.send(.async(.fetchSchedule))
    await clock.advance(by: .seconds(0.6))
    await store.receive(\.inner) {
      $0.schedules = .init(uniqueElements: ManagementScheduleFixture.all)
    }
  }

  /// 실패해도 로딩만 내리고 기존 목록은 남긴다.
  @Test("스케줄 조회 실패는 로딩만 내리고 목록을 유지한다")
  func fetchScheduleFailureKeepsList() async {
    let clock = TestClock()
    var stub = ManagementScheduleUseCaseStub()
    stub.cached = nil
    stub.error = .loadFailed

    let store = TestStore(initialState: ScheduleModalFeature.State()) {
      ScheduleModalFeature()
    } withDependencies: {
      $0.scheduleUseCase = stub
      $0.continuousClock = clock
    }

    await store.send(.async(.fetchSchedule))
    await clock.advance(by: .seconds(0.6))
    await store.receive(\.inner) {
      $0.viewState = .loaded
    }
    #expect(store.state.schedules.isEmpty)
  }

  /// 다른 일정을 고르면 선택이 교체된다(같은 일정 재선택 해제는 기존 스위트가 커버).
  @Test("다른 일정을 선택하면 선택이 교체된다")
  func selectingAnotherScheduleReplacesSelection() async {
    var state = ScheduleModalFeature.State()
    state.selectedSchedule = ManagementScheduleFixture.orientation

    let store = TestStore(initialState: state) {
      ScheduleModalFeature()
    }

    await store.send(.view(.selectSchedule(item: ManagementScheduleFixture.midterm))) {
      $0.selectedSchedule = ManagementScheduleFixture.midterm
    }
  }

  /// 확인 버튼은 선택값을 델리게이트로 흘려보낸다.
  @Test("확인 버튼은 선택한 일정을 델리게이트로 전달한다")
  func confirmSelectionSendsDelegate() async {
    var state = ScheduleModalFeature.State()
    state.selectedSchedule = ManagementScheduleFixture.midterm

    let store = TestStore(initialState: state) {
      ScheduleModalFeature()
    }

    await store.send(.view(.confirmSelection))
    await store.receive(
      \.delegate,
      .selectScheduleCompleted(selectedSchedule: ManagementScheduleFixture.midterm)
    )
  }

  /// 선택이 없으면 확인 버튼은 무시된다.
  @Test("선택이 없으면 확인 버튼은 아무 일도 하지 않는다")
  func confirmSelectionWithoutSelectionDoesNothing() async {
    let store = TestStore(initialState: ScheduleModalFeature.State()) {
      ScheduleModalFeature()
    }

    await store.send(.view(.confirmSelection))
  }

}
