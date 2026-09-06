//
//  AttendanceDropdown.swift
//  Management
//
//  Created by DDD on 1/13/26.
//

import SwiftUI
import DDDAccessibility
import DDDDesignKit
import AttendanceDomainInterface

struct AttendanceDropdown: View {
  @State private var isExpanded = false
  @State private var selectedStatus: AttendanceStatus

  private let availableStatuses: [AttendanceStatus]
  private let onSelectionChanged: (AttendanceStatus) -> Void // AttendanceStatus 반환

  init(
    selectedStatus: AttendanceStatus,
    availableStatuses: [AttendanceStatus],
    onSelectionChanged: @escaping (AttendanceStatus) -> Void // AttendanceStatus 반환
  ) {
    self._selectedStatus = State(initialValue: selectedStatus)
    self.availableStatuses = availableStatuses
    self.onSelectionChanged = onSelectionChanged
  }

  var body: some View {
    dropdownHeader
      .overlay(dropdownOptionsOverlay, alignment: .topLeading)
      .zIndex(isExpanded ? 9999 : 1)
  }

  private var dropdownHeader: some View {
    Button {
      withAnimation(.easeInOut(duration: 0.2)) {
        isExpanded.toggle()
      }
    } label: {
      headerContent
    }
    .buttonStyle(.plain)
    .dddAccessibilityID(ManagementAccessibilityID.Attendance.modalStatusButton)
  }

  private var headerContent: some View {
    HStack {
      Text(selectedStatus.desc)
        .dddFont(.body2NormalMedium)
        .foregroundStyle(.staticWhite)

      Spacer()

      Image(systemName: "chevron.down")
        .renderingMode(.template)
        .font(.system(size: 14, weight: .medium))
        .foregroundStyle(.gray60)
        .rotationEffect(.degrees(isExpanded ? 180 : 0))
    }
    .padding(.horizontal, 16)
    .padding(.vertical, 12)
    .frame(height: 58)
    .background(.gray80)
    .clipShape(.rect(cornerRadius: 20))
    .overlay {
      RoundedRectangle(cornerRadius: 20)
        .stroke(.gray80, lineWidth: 1)
    }
  }

  private var dropdownOptionsOverlay: some View {
    Group {
      if isExpanded {
        dropdownOptions
      }
    }
  }

  private var dropdownOptions: some View {
    VStack(spacing: 0) {
      ForEach(availableStatuses, id: \.rawValue) { status in
        optionRow(for: status)

        if status != availableStatuses.last {
          optionDivider
        }
      }
    }
    .background(.gray80)
    .clipShape(.rect(cornerRadius: 8))
    .overlay {
      RoundedRectangle(cornerRadius: 8)
        .stroke(.gray70, lineWidth: 1)
    }
    .offset(y: 64)
    .transition(.opacity.combined(with: .scale(scale: 0.95, anchor: .top)))
  }

  private func optionRow(for status: AttendanceStatus) -> some View {
    Button {
      withAnimation(.easeInOut(duration: 0.2)) {
        selectedStatus = status
        isExpanded = false
        onSelectionChanged(status)
      }
    } label: {
      optionRowContent(for: status)
    }
    .buttonStyle(.plain)
    .dddAccessibilityID(ManagementAccessibilityID.Attendance.modalStatus(status))
  }

  private func optionRowContent(for status: AttendanceStatus) -> some View {
    HStack {
      Text(status.desc)
        .dddFont(.body2NormalMedium)
        .foregroundStyle(status == selectedStatus ? .blue40 : .staticWhite)

      Spacer()

      if status == selectedStatus {
        Image(systemName: "checkmark")
          .renderingMode(.template)
          .font(.system(size: 14, weight: .medium))
          .foregroundStyle(.blue40)
      }
    }
    .padding(.horizontal, 16)
    .padding(.vertical, 12)
    .frame(height: 44)
    .background(.gray80)
  }

  private var optionDivider: some View {
    DDDDivider(color: .gray70)
      .padding(.horizontal, 16)
  }
}

#Preview {
  VStack {
    AttendanceDropdown(
      selectedStatus: .attended,
      availableStatuses: AttendanceStatus.allCases
    ) { newStatus in
    }

    Spacer()
  }
  .padding()
  .background(.gray90)
}
