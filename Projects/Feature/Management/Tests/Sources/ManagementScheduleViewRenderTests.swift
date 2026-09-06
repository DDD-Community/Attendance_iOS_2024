//
//  ManagementScheduleViewRenderTests.swift
//  ManagementTests
//
//  Created by DDD on 2026-09-03.
//
//  Schedule / ScheduleModalFeature 화면과 컴포넌트의 body 를 실제로 평가한다.
//  ScheduleView 는 loading 값으로 스켈레톤과 목록 두 갈래를 갖는다.
//

import ComposableArchitecture
import SwiftUI
import Testing

@testable import Management

@MainActor
@Suite("ManagementScheduleViewRender")
struct ManagementScheduleViewRenderTests {
  private func makeScheduleStore(
    state: ScheduleFeature.State
  ) -> StoreOf<ScheduleFeature> {
    var stub = ManagementScheduleUseCaseStub()
    stub.schedules = ManagementScheduleFixture.all

    return Store(initialState: state) {
      ScheduleFeature()
    } withDependencies: {
      $0.scheduleUseCase = stub
    }
  }

  private func makeModalStore(
    state: ScheduleModalFeature.State
  ) -> StoreOf<ScheduleModalFeature> {
    var stub = ManagementScheduleUseCaseStub()
    stub.cached = ManagementScheduleFixture.all
    stub.schedules = ManagementScheduleFixture.all

    return Store(initialState: state) {
      ScheduleModalFeature()
    } withDependencies: {
      $0.scheduleUseCase = stub
      $0.continuousClock = ImmediateClock()
    }
  }

  // MARK: - ScheduleView

  /// 로딩 분기: ScheduleSkeletonView 로 대체되는 경로.
  @Test("로딩 중 ScheduleView 는 스켈레톤 경로를 렌더링한다")
  func rendersScheduleViewLoading() {
    var state = ScheduleFeature.State()
    state.viewState = .loading

    ManagementViewRenderer.render(ScheduleView(store: makeScheduleStore(state: state)))
  }

  /// 목록 분기: ForEach 로 카드가 그려지는 경로.
  @Test("목록이 있는 ScheduleView 를 렌더링한다")
  func rendersScheduleViewWithItems() {
    var state = ScheduleFeature.State()
    state.hasFetchedSchedule = true
    state.viewState = .loaded
    state.schedules = .init(uniqueElements: ManagementScheduleFixture.all)

    ManagementViewRenderer.render(ScheduleView(store: makeScheduleStore(state: state)))
  }

  /// 빈 목록 경계값.
  @Test("빈 목록의 ScheduleView 를 렌더링한다")
  func rendersScheduleViewEmpty() {
    var state = ScheduleFeature.State()
    state.hasFetchedSchedule = true
    state.viewState = .loaded

    ManagementViewRenderer.render(ScheduleView(store: makeScheduleStore(state: state)))
  }

  // MARK: - Schedule 컴포넌트

  @Test("ScheduleHeaderView 를 렌더링한다")
  func rendersScheduleHeader() {
    ManagementViewRenderer.render(ScheduleHeaderView())
  }

  @Test("ScheduleSkeletonView 를 렌더링한다")
  func rendersScheduleSkeleton() {
    ManagementViewRenderer.render(ScheduleSkeletonView())
  }

  @Test("ScheduleCardView 를 일반 값과 빈 설명 값으로 렌더링한다")
  func rendersScheduleCard() {
    ManagementViewRenderer.render(
      ScheduleCardView(month: "9", day: "2", title: "OT", description: "오리엔테이션")
    )

    ManagementViewRenderer.render(
      ScheduleCardView(month: "12", day: "31", title: "", description: "")
    )
  }

  // MARK: - ScheduleModalView

  /// 로딩 분기: ScheduleModalSkeletonView 로 대체되는 경로.
  @Test("로딩 중 ScheduleModalView 는 스켈레톤 경로를 렌더링한다")
  func rendersScheduleModalLoading() {
    var state = ScheduleModalFeature.State()
    state.viewState = .loading

    ManagementViewRenderer.render(ScheduleModalView(store: makeModalStore(state: state)))
  }

  /// 목록 + 선택 상태: 선택 테두리 분기까지 태운다.
  @Test("선택된 일정이 있는 ScheduleModalView 를 렌더링한다")
  func rendersScheduleModalWithSelection() {
    var state = ScheduleModalFeature.State()
    state.viewState = .loaded
    state.schedules = .init(uniqueElements: ManagementScheduleFixture.all)
    state.selectedSchedule = ManagementScheduleFixture.midterm

    ManagementViewRenderer.render(ScheduleModalView(store: makeModalStore(state: state)))
  }

  /// 선택이 없어 확인 버튼이 비활성인 경계값.
  @Test("선택이 없는 ScheduleModalView 를 렌더링한다")
  func rendersScheduleModalWithoutSelection() {
    var state = ScheduleModalFeature.State()
    state.viewState = .loaded
    state.schedules = .init(uniqueElements: ManagementScheduleFixture.all)

    ManagementViewRenderer.render(ScheduleModalView(store: makeModalStore(state: state)))
  }

  @Test("ScheduleModalSkeletonView 를 렌더링한다")
  func rendersScheduleModalSkeleton() {
    ManagementViewRenderer.render(ScheduleModalSkeletonView())
  }
}
