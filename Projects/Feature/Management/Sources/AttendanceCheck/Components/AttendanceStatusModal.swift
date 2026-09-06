//
//  AttendanceStatusModal.swift
//  Management
//
//  Created by DDD on 1/13/26.
//

import SwiftUI
import DDDAccessibility
import DDDDesignKit
import AttendanceDomainInterface

public struct AttendanceStatusModal: View {
  @State private var selectedStatus: AttendanceStatus

  private let title: String
  private let availableStatuses: [AttendanceStatus]
  private let confirmTitle: String
  private let onConfirm: (AttendanceStatus) -> Void // AttendanceStatus 반환
  private let onCancel: () -> Void

  public init(
    title: String = "출석 상태를 변경하시겠습니까?",
    initialStatus: AttendanceStatus = .attended,
    availableStatuses: [AttendanceStatus], // API에서 받은 배열 (필수)
    confirmTitle: String = "확인",
    onConfirm: @escaping (AttendanceStatus) -> Void, // AttendanceStatus 반환
    onCancel: @escaping () -> Void
  ) {
    self.title = title
    self._selectedStatus = State(initialValue: initialStatus)
    self.availableStatuses = availableStatuses
    self.confirmTitle = confirmTitle
    self.onConfirm = onConfirm
    self.onCancel = onCancel
  }

  public var body: some View {
    ZStack {
      Color.basicBlack
        .opacity(0.4)
        .edgesIgnoringSafeArea(.all)
        .onTapGesture {
          onCancel()
        }

      VStack(alignment: .center, spacing: 24) {
        Text(title)
          .dddFont(.title3NormalBold)
          .foregroundStyle(.staticWhite)
          .multilineTextAlignment(.center)

        AttendanceDropdown(
          selectedStatus: selectedStatus,
          availableStatuses: availableStatuses
        ) { newStatus in
          // AttendanceStatus 직접 받아서 설정
          selectedStatus = newStatus
        }

        Button {
          onConfirm(selectedStatus) // AttendanceStatus 직접 반환
        } label: {
          Text(confirmTitle)
            .pretendardFont(family: .Medium, size: 16)
            .foregroundStyle(.staticWhite)
            .frame(maxWidth: .infinity)
            .frame(height: 48)
        }
        .background(.blue40)
        .clipShape(.rect(cornerRadius: 20))
        .contentShape(.rect(cornerRadius: 20))
        .dddAccessibilityID(ManagementAccessibilityID.Attendance.modalConfirmButton)
      }
      .padding(.vertical, 32)
      .padding(.horizontal, 24)
      .frame(width: 320)
      .background(
        RoundedRectangle(cornerRadius: 20)
          .fill(.gray90)
      )
      .onTapGesture {}
      .accessibilityElement(children: .contain)
      .dddAccessibilityID(ManagementAccessibilityID.Attendance.modal)
    }
  }
}

// MARK: - AttendanceModalItem

public struct AttendanceModalItem: Identifiable, Equatable {
  public let id = UUID()
  public let title: String
  public let initialStatus: AttendanceStatus
  public let availableStatuses: [AttendanceStatus]
  public let confirmTitle: String
  public let onConfirm: (AttendanceStatus) -> Void // AttendanceStatus 반환
  public let onCancel: () -> Void

  public static func == (lhs: AttendanceModalItem, rhs: AttendanceModalItem) -> Bool {
    lhs.id == rhs.id &&
    lhs.title == rhs.title &&
    lhs.initialStatus == rhs.initialStatus &&
    lhs.availableStatuses == rhs.availableStatuses &&
    lhs.confirmTitle == rhs.confirmTitle
  }

  public init(
    title: String = "출석 상태를 변경하시겠습니까?",
    initialStatus: AttendanceStatus = .attended,
    availableStatuses: [AttendanceStatus], // API에서 받은 배열 (필수)
    confirmTitle: String = "확인",
    onConfirm: @escaping (AttendanceStatus) -> Void, // AttendanceStatus 반환
    onCancel: @escaping () -> Void
  ) {
    self.title = title
    self.initialStatus = initialStatus
    self.availableStatuses = availableStatuses
    self.confirmTitle = confirmTitle
    self.onConfirm = onConfirm
    self.onCancel = onCancel
  }
}

// MARK: - Predefined Items

public extension AttendanceModalItem {
  /// 출석 상태 변경 모달
  static func changeAttendanceStatus(
    currentStatus: AttendanceStatus = .attended,
    availableStatuses: [AttendanceStatus], // API에서 받은 배열 (필수)
    onConfirm: @escaping (AttendanceStatus) -> Void, // AttendanceStatus 반환
    onCancel: @escaping () -> Void
  ) -> AttendanceModalItem {
    AttendanceModalItem(
      title: "출석 상태를 변경하시겠습니까?",
      initialStatus: currentStatus,
      availableStatuses: availableStatuses,
      confirmTitle: "확인",
      onConfirm: onConfirm,
      onCancel: onCancel
    )
  }
}

#Preview {
  VStack {
    Text("Background Content")
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .background(.gray.opacity(0.2))
  }
  .overlay {
    AttendanceStatusModal(
      initialStatus: .attended,
      availableStatuses: [.attended, .late, .absent], // API 시뮬레이션
      onConfirm: { status in
      },
      onCancel: {
      }
    )
  }
}
