//
//  ManagementStaffViewRenderTests.swift
//  ManagementTests
//
//  Created by DDD on 2026-09-03.
//
//  StaffView / AttendanceCheckView 와 출석 컴포넌트의 body 를 실제로 평가한다.
//  QRScannerView 는 카메라(DataScanner)를 붙잡아야 해서 렌더 대상에서 뺀다.
//

import ComposableArchitecture
import DDDDesignKit
import SwiftUI
import Testing

@testable import Management

@MainActor
@Suite("ManagementStaffViewRender")
struct ManagementStaffViewRenderTests {
  private func makeStaffStore(
    state: StaffFeature.State
  ) -> StoreOf<StaffFeature> {
    Store(initialState: state) {
      StaffFeature()
    } withDependencies: {
      $0.attendanceUseCase = ManagementSupportAttendanceUseCase()
      $0.scheduleUseCase = ManagementSupportScheduleUseCase()
      $0.qrCodeUseCase = ManagementSupportQRCodeUseCase()
      $0.continuousClock = ImmediateClock()
      $0.mainQueue = .immediate
    }
  }

  private func makeAttendanceStore(
    state: AttendanceCheckFeature.State
  ) -> StoreOf<AttendanceCheckFeature> {
    Store(initialState: state) {
      AttendanceCheckFeature()
    } withDependencies: {
      $0.attendanceUseCase = ManagementSupportAttendanceUseCase()
      $0.scheduleUseCase = ManagementSupportScheduleUseCase()
      $0.continuousClock = ImmediateClock()
      $0.mainQueue = .immediate
    }
  }

  private func loadedAttendanceState() -> AttendanceCheckFeature.State {
    var state = AttendanceCheckFeature.State()
    state.viewState = .loaded
    state.selectedSchedule = EntityFixtureSchedule.value
    state.attendanceSummary = ManagementSupportFixture.attendanceCount
    state.teams = .init(uniqueElements: ManagementSupportFixture.teams)
    state.selectedTeamID = 1
    state.settledTeamID = 1
    state.attendanceByTeam = [1: ManagementSupportFixture.attendances, 2: []]
    state.availableStatuses = .init(uniqueElements: ManagementSupportFixture.statuses)
    return state
  }

  // MARK: - StaffView

  @Test("기본 StaffView 는 출석 탭 본문을 렌더링한다")
  func rendersStaffViewAttendanceTab() {
    var state = StaffFeature.State()
    state.attendance = loadedAttendanceState()

    ManagementSupportViewRenderer.render(StaffView(store: makeStaffStore(state: state)))
  }

  @Test("출석 탭이 로딩 중이면 StaffView 는 스켈레톤 경로를 탄다")
  func rendersStaffViewAttendanceSkeleton() {
    var state = StaffFeature.State()
    state.attendance.viewState = .loading

    ManagementSupportViewRenderer.render(StaffView(store: makeStaffStore(state: state)))
  }

  @Test("출석 상태 갱신 중에는 전체 화면이 아닌 출석 카드 목록만 skeleton을 렌더링한다")
  func rendersStaffViewAttendanceListSkeleton() {
    var state = StaffFeature.State()
    state.attendance = loadedAttendanceState()
    state.attendance.viewState = .refreshingAttendanceList

    #expect(state.viewState == .loaded)
    ManagementSupportViewRenderer.render(StaffView(store: makeStaffStore(state: state)))
  }

  @Test("일정 탭이면 StaffView 는 일정 본문을 렌더링한다")
  func rendersStaffViewScheduleTab() {
    var state = StaffFeature.State()
    state.selectedItem = .schedule
    state.schedule.viewState = .loaded

    ManagementSupportViewRenderer.render(StaffView(store: makeStaffStore(state: state)))
  }

  @Test("일정 탭이 로딩 중이면 일정 스켈레톤 경로를 탄다")
  func rendersStaffViewScheduleSkeleton() {
    var state = StaffFeature.State()
    state.selectedItem = .schedule
    state.schedule.viewState = .loading

    ManagementSupportViewRenderer.render(StaffView(store: makeStaffStore(state: state)))
  }

  @Test("투표 탭이면 StaffView 는 투표 본문을 렌더링한다")
  func rendersStaffViewVoteTab() {
    var state = StaffFeature.State()
    state.selectedItem = .vote
    state.vote.viewState = .loaded

    ManagementSupportViewRenderer.render(StaffView(store: makeStaffStore(state: state)))
  }

  @Test("투표 탭이 로딩 중이면 투표 스켈레톤 경로를 탄다")
  func rendersStaffViewVoteSkeleton() {
    var state = StaffFeature.State()
    state.selectedItem = .vote
    state.vote.viewState = .loading

    ManagementSupportViewRenderer.render(StaffView(store: makeStaffStore(state: state)))
  }

  @Test("드롭다운이 펼쳐진 StaffView 는 오버레이까지 렌더링한다")
  func rendersStaffViewWithExpandedDropDown() {
    var state = StaffFeature.State()
    state.isExpandedDropDown = true
    state.attendance.viewState = .loaded

    ManagementSupportViewRenderer.render(StaffView(store: makeStaffStore(state: state)))
  }

  @Test("StaffSkeletonView 단독 렌더링")
  func rendersStaffSkeletonView() {
    ManagementSupportViewRenderer.render(StaffSkeletonView())
  }

  // MARK: - AttendanceCheckView

  @Test("데이터가 채워진 AttendanceCheckView 를 렌더링한다")
  func rendersAttendanceCheckViewLoaded() {
    ManagementSupportViewRenderer.render(
      AttendanceCheckView(store: makeAttendanceStore(state: loadedAttendanceState()))
    )
  }

  @Test("데이터가 비어 있는 AttendanceCheckView 를 렌더링한다")
  func rendersAttendanceCheckViewEmpty() {
    ManagementSupportViewRenderer.render(
      AttendanceCheckView(store: makeAttendanceStore(state: AttendanceCheckFeature.State()))
    )
  }

  @Test("출석 수정 모달이 떠 있는 AttendanceCheckView 를 렌더링한다")
  func rendersAttendanceCheckViewWithModal() {
    var state = loadedAttendanceState()
    state.attendanceModal = .adminStatusChangeWithAvailable(
      availableStatuses: ManagementSupportFixture.statuses
    )

    ManagementSupportViewRenderer.render(
      AttendanceCheckView(store: makeAttendanceStore(state: state))
    )
  }

  // MARK: - 출석 컴포넌트

  @Test("AttendanceStatusModal 은 전달받은 상태 목록을 렌더링한다")
  func rendersAttendanceStatusModal() {
    ManagementSupportViewRenderer.render(
      AttendanceStatusModal(
        availableStatuses: ManagementSupportFixture.statuses,
        onConfirm: { _ in },
        onCancel: {}
      )
    )
  }

  @Test("AttendanceStatusModal 은 제목과 확인 문구를 바꿔도 렌더링된다")
  func rendersAttendanceStatusModalWithCustomTitle() {
    ManagementSupportViewRenderer.render(
      AttendanceStatusModal(
        title: "늦은 시간입니다.\n지각 또는 결석만 가능합니다.",
        initialStatus: .late,
        availableStatuses: [.late, .absent],
        confirmTitle: "변경하기",
        onConfirm: { _ in },
        onCancel: {}
      )
    )
  }

  @Test("AttendanceDropdown 은 선택 상태를 렌더링한다")
  func rendersAttendanceDropdown() {
    ManagementSupportViewRenderer.render(
      AttendanceDropdown(
        selectedStatus: .attended,
        availableStatuses: ManagementSupportFixture.statuses,
        onSelectionChanged: { _ in }
      )
    )
  }
}
