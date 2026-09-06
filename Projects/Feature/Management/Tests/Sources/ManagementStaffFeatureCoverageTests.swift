//
//  ManagementStaffFeatureCoverageTests.swift
//  ManagementTests
//
//  Created by DDD on 2026-09-03.
//
//  StaffFeatureTests 가 다루지 않는 StaffFeature 의 나머지 분기(위임·바인딩·자식 스코프)를 훑는다.
//

import ComposableArchitecture
import DDDDesignKit
import Testing

@testable import Management

@MainActor
@Suite("ManagementStaffFeatureCoverage")
struct ManagementStaffFeatureCoverageTests {
  @Test("초기 상태는 출석 탭이고 드롭다운이 접혀 있다")
  func initialStateIsAttendanceTab() {
    let state = StaffFeature.State()

    #expect(state.isExpandedDropDown == false)
    #expect(state.selectedItem == .attendance)
    #expect(state.destination == nil)
  }

  @Test("QR presentBack 은 destination 을 내리고 출석 갱신을 한 번 요청한다")
  func qrPresentBackDismissesAndRefreshesAttendance() async {
    var state = StaffFeature.State()
    state.destination = .qrcode(.init())
    state.attendance.viewState = .loading

    let store = TestStore(initialState: state) {
      StaffFeature()
    }

    await store.send(.destination(.presented(.qrcode(.delegate(.presentBack))))) {
      $0.destination = nil
    }
    await store.receive(\.attendance)
  }

  @Test("closeDropDown 은 펼쳐진 드롭다운만 접는다")
  func closeDropDownCollapsesDropdown() async {
    var state = StaffFeature.State()
    state.isExpandedDropDown = true

    let store = TestStore(initialState: state) {
      StaffFeature()
    }

    await store.send(.view(.closeDropDown)) {
      $0.isExpandedDropDown = false
    }
  }

  @Test("드롭다운 항목은 일정으로도 바뀐다")
  func selectScheduleDropDownItem() async {
    let store = TestStore(initialState: StaffFeature.State()) {
      StaffFeature()
    }

    await store.send(.view(.selectItem(.schedule))) {
      $0.selectedItem = .schedule
    }
  }

  @Test("isExpandedDropDown 바인딩은 상태를 그대로 반영한다")
  func bindingUpdatesExpandedFlag() async {
    let store = TestStore(initialState: StaffFeature.State()) {
      StaffFeature()
    }

    await store.send(.binding(.set(\.isExpandedDropDown, true))) {
      $0.isExpandedDropDown = true
    }
  }

  @Test("운영진 프로필 위임은 드롭다운을 닫는다")
  func presentManagerProfileDelegateClosesDropdown() async {
    var state = StaffFeature.State()
    state.isExpandedDropDown = true

    let store = TestStore(initialState: state) {
      StaffFeature()
    }

    await store.send(.delegate(.presentManagerProfile)) {
      $0.isExpandedDropDown = false
    }
  }

  @Test("일정 위임은 상태를 바꾸지 않고 바깥으로만 알린다")
  func presentScheduleDelegateKeepsState() async {
    let store = TestStore(initialState: StaffFeature.State()) {
      StaffFeature()
    }

    await store.send(.delegate(.presentSchedule))
  }

  @Test("QR destination 의 액션은 자식 리듀서까지 전달된다")
  func destinationActionReachesQRCodeChild() async {
    var state = StaffFeature.State()
    state.destination = .qrcode(.init())

    let store = TestStore(initialState: state) {
      StaffFeature()
    }

    await store.send(.destination(.presented(.qrcode(.view(.stopScanning))))) {
      var qrCodeState = QRCodeFeature.State()
      qrCodeState.isScanning = false
      $0.destination = .qrcode(qrCodeState)
    }
  }

  @Test("destination dismiss 는 QR 화면을 내린다")
  func destinationDismissClearsQRCode() async {
    var state = StaffFeature.State()
    state.destination = .qrcode(.init())

    let store = TestStore(initialState: state) {
      StaffFeature()
    }

    await store.send(.destination(.dismiss)) {
      $0.destination = nil
    }
  }

  @Test("출석 탭 스코프 액션은 AttendanceCheckFeature 자식 상태를 바꾼다")
  func attendanceCheckScopeForwardsAction() async {
    let store = TestStore(initialState: StaffFeature.State()) {
      StaffFeature()
    }

    await store.send(.attendance(.view(.tapSelectDate))) {
      $0.attendance.destination = .scheduleModal(.init())
    }
  }

}
