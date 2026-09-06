//
//  StaffFeatureTests.swift
//  ManagementTests
//
//  Created by DDD on 2026-09-02.
//

import ComposableArchitecture
import DDDDesignKit
import Testing

@testable import Management

@MainActor
@Suite("StaffFeature")
struct StaffFeatureTests {
  @Test("toggleDropDown은 드롭다운 펼침 상태를 반전한다")
  func toggleDropDownTogglesExpandedState() async {
    let store = TestStore(initialState: StaffFeature.State()) {
      StaffFeature()
    }

    await store.send(.view(.toggleDropDown)) {
      $0.isExpandedDropDown = true
    }
  }

  @Test("selectItem은 선택 값을 저장하고 드롭다운을 닫는다")
  func selectItemStoresSelectionAndClosesDropdown() async {
    var state = StaffFeature.State()
    state.isExpandedDropDown = true
    let store = TestStore(initialState: state) {
      StaffFeature()
    }

    await store.send(.view(.selectItem(.vote))) {
      $0.selectedItem = .vote
      $0.isExpandedDropDown = false
    }
  }

  @Test("presentQrcode는 기존 드롭다운을 닫고 QR destination을 표시한다")
  func presentQRCodeClosesDropdownAndPresentsDestination() async {
    var state = StaffFeature.State()
    state.isExpandedDropDown = true
    let store = TestStore(initialState: state) {
      StaffFeature()
    }

    await store.send(.view(.presentQrcode)) {
      $0.isExpandedDropDown = false
      $0.destination = .qrcode(.init())
    }
  }
}
