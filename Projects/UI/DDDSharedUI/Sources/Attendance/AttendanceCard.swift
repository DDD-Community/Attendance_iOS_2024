//
//  AttendanceCard.swift
//  DDDSharedUI
//
//  Created by DDD on 1/5/25.
//

import DDDDesignKit
import SwiftUI

public struct AttendanceCard: View {
  private let attendanceCount: Int
  private let lateCount: Int
  private let absentCount: Int
  private let showWarning: Bool
  private let onTapAbsentButton: (() -> Void)?
  
  public init(
    attendanceCount: Int,
    lateCount: Int,
    absentCount: Int,
    showWarning: Bool,
    onTapAbsentButton: (() -> Void)? = nil
  ) {
    self.attendanceCount = attendanceCount
    self.lateCount = lateCount
    self.absentCount = absentCount
    self.showWarning = showWarning
    self.onTapAbsentButton = onTapAbsentButton
  }
  
  public var body: some View {
    HStack(spacing: 0) {
      CardItem(status: .present, count: attendanceCount)
      
      Spacer()
      
      divider
      
      Spacer()
      
      CardItem(status: .late, count: lateCount)
      
      Spacer()
      
      divider
      
      Spacer()
      
      CardItem(
        status: .absent,
        count: absentCount,
        showWarning: showWarning,
        onTap: onTapAbsentButton
      )
    }
    .padding(24)
    .background(.borderInverse)
    .clipShape(RoundedRectangle(cornerRadius: 20))
  }
  
  private var divider: some View {
    DDDDivider(
      color: .borderDisabled,
      orientation: .vertical(height: 48)
    )
  }
}

private struct CardItem: View {
  private let status: AttendanceStatus
  private let count: Int
  private let showWarning: Bool
  private let onTap: (() -> Void)?
  
  init(
    status: AttendanceStatus,
    count: Int,
    showWarning: Bool = false,
    onTap: (() -> Void)? = nil
  ) {
    self.status = status
    self.count = count
    self.showWarning = showWarning
    self.onTap = onTap
  }
  
  var body: some View {
    VStack(alignment: .center, spacing: 4) {
      Text("\(count)")
        .pretendardFont(family: .Bold, size: 32)
        .foregroundStyle(count == 0 ? status.defaultColor : status.highlightColor)
      
      HStack(spacing: 4) {
        Text(status.label)
          .pretendardFont(family: .Medium, size: 16)
          .foregroundStyle(.textSecondary)
        
        if showWarning {
          Image(asset: .danger)
        }
      }
    }
    .frame(width: 68, height: 64)
    .onTapGesture {
      onTap?()
    }
  }
}

// MARK: - AttendanceStyle

private protocol AttendanceStyle {
  var label: String { get }
  var defaultColor: Color { get }
  var highlightColor: Color { get }
}

// MARK: - Concrete Styles

private struct PresentStyle: AttendanceStyle {
  let label: String = "출석"
  let defaultColor: Color = .textPrimary
  let highlightColor: Color = .textPrimary
}

private struct LateStyle: AttendanceStyle {
  let label: String = "지각"
  let defaultColor: Color = .textPrimary
  let highlightColor: Color = .statusCautionary
}

private struct AbsentStyle: AttendanceStyle {
  let label: String = "결석"
  let defaultColor: Color = .textPrimary
  let highlightColor: Color = .statusError
}

// MARK: - AttendanceStatus

private enum AttendanceStatus {
  case present
  case late
  case absent
  
  private var style: AttendanceStyle {
    switch self {
    case .present:
      return PresentStyle()
    case .late:
      return LateStyle()
    case .absent:
      return AbsentStyle()
    }
  }
  
  var label: String {
    style.label
  }
  
  var defaultColor: Color {
    style.defaultColor
  }
  
  var highlightColor: Color {
    style.highlightColor
  }
}
