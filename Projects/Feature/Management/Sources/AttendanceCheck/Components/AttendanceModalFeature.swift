//
//  AttendanceModalFeature.swift
//  Management
//
//  Created by DDD on 1/13/26.
//

import SwiftUI
import ComposableArchitecture
import AttendanceDomainInterface

// MARK: - AttendanceModalState

@ObservableState
public struct AttendanceModalState<Action>: Equatable {
  public let title: String
  public let initialStatus: AttendanceStatus
  public let availableStatuses: [AttendanceStatus]
  public let confirmTitle: String

  public init(
    title: String = "출석 상태를 변경하시겠습니까?",
    initialStatus: AttendanceStatus = .attended,
    availableStatuses: [AttendanceStatus],
    confirmTitle: String = "확인"
  ) {
    self.title = title
    self.initialStatus = initialStatus
    self.availableStatuses = availableStatuses
    self.confirmTitle = confirmTitle
  }
}

// MARK: - AttendanceModalAction

@CasePathable
public enum AttendanceModalAction: BindableAction, Equatable {
  case binding(BindingAction<AttendanceModalState<AttendanceModalAction>>)
  case confirmTapped(AttendanceStatus) // 선택된 AttendanceStatus
  case cancelTapped
}

// MARK: - AttendanceModalReducer

@Reducer
public struct AttendanceModalFeature {
  public init() {}

  public var body: some Reducer<AttendanceModalState<AttendanceModalAction>, AttendanceModalAction> {
    BindingReducer()
    Reduce { state, action in
      switch action {
      case .binding(_):
        return .none
      case .confirmTapped, .cancelTapped:
        return .none
      }
    }
  }
}

// MARK: - Factory Methods (ProfileFeature customAlert 패턴)

public extension AttendanceModalState where Action == AttendanceModalAction {
  /// 기본 출석 상태 변경 모달
  static func changeAttendanceStatus(
    availableStatuses: [AttendanceStatus],
    currentStatus: AttendanceStatus = .attended
  ) -> AttendanceModalState<AttendanceModalAction> {
    AttendanceModalState(
      title: "출석 상태를 변경하시겠습니까?",
      initialStatus: currentStatus,
      availableStatuses: availableStatuses,
      confirmTitle: "확인"
    )
  }

  /// 늦은 시간 제한된 옵션 모달
  static func lateTimeStatusChange(
    availableStatuses: [AttendanceStatus] = [.late, .absent]
  ) -> AttendanceModalState<AttendanceModalAction> {
    AttendanceModalState(
      title: "늦은 시간입니다.\n지각 또는 결석만 가능합니다.",
      initialStatus: .late,
      availableStatuses: availableStatuses,
      confirmTitle: "확인"
    )
  }

  /// 관리자용 전체 상태 변경 모달
  static func adminStatusChange(
    currentStatus: AttendanceStatus
  ) -> AttendanceModalState<AttendanceModalAction> {
    AttendanceModalState(
      title: "출석 상태를 변경하시겠습니까?",
      initialStatus: currentStatus,
      availableStatuses: AttendanceStatus.allCases,
      confirmTitle: "변경하기"
    )
  }

  /// 사용 가능한 상태 목록을 받는 관리자 모달
  static func adminStatusChangeWithAvailable(
    availableStatuses: [AttendanceStatus],
    currentStatus: AttendanceStatus = .attended
  ) -> AttendanceModalState<AttendanceModalAction> {
    AttendanceModalState(
      title: "출석 상태를 변경하시겠습니까?",
      initialStatus: currentStatus,
      availableStatuses: availableStatuses,
      confirmTitle: "변경하기"
    )
  }
}
