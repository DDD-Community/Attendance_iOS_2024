//
//  AttendanceCheckStatusCard.swift
//  FeatureSharedUI
//
//  Created by DDD on 1/27/25.
//

import DDDDesignKit
import DDDAccessibility
import SwiftUI
import AttendanceDomainInterface
import ProfileDomainInterface

public struct AttendanceCheckStatusCard: View {
  private let attendanceStatus: AttendanceStatus
  private let selectPart: SelectParts
  private let selectTeam: SelectTeams
  private let name: String
  private var accessibilityID: String?
  private var editAccessibilityID: String?
  private let editAction: () -> Void

  public init(
    attendanceStatus: AttendanceStatus,
    selectPart: SelectParts,
    selectTeam: SelectTeams,
    name: String,
    editAction: @escaping () -> Void
  ) {
    self.attendanceStatus = attendanceStatus
    self.selectPart = selectPart
    self.selectTeam = selectTeam
    self.name = name
    self.editAction = editAction
  }

  public var body: some View {
    VStack {
      VStack(spacing: .zero) {
        Spacer()
          .frame(height: 16)
        
        HStack {
          VStack(alignment: .leading, spacing: .zero) {
            HStack {
              Text(name)
                .dddFont(.title3NormalBold)
                .foregroundStyle(isDisabled ? .borderDisabled : .staticWhite)
              Spacer()
            }
            
            Text("\(selectTeam.attandanceCardDescription) / \(selectPart.desc) ")
              .dddFont(.body2NormalBold)
              .foregroundStyle(isDisabled ? .borderDisabled : .staticWhite)
              .minimumScaleFactor(0.7)
          }
          
          Spacer()
          
          HStack(spacing: .zero) {
            Text(attendanceStatus.desc)
              .dddFont(.body2NormalMedium)
              .foregroundStyle(isDisabled ? .borderDisabled : .staticWhite)
            
            Spacer()
              .frame(width: 12)
            
            Image(assetName: imageName)
              .resizable()
              .scaledToFit()
              .frame(width: 24, height: 24)

            Spacer()
              .frame(width: 9)

            Image(asset: .editAttendance)
              .resizable()
              .scaledToFit()
              .frame(width: 15, height: 15)
              .onTapGesture {
                editAction()
              }
              .applyAccessibilityIdentifier(editAccessibilityID)

          }
          
        }
        
        Spacer()
          .frame(height: 16)
      }
      .padding(.horizontal, 20)
    }
    .background(isDisabled ? .staticBlack : .borderInverse)
    .frame(height: 84)
    .cornerRadius(15)
    .overlay(
      // ABSENT일 때 점선 테두리 적용
      isDisabled ?
      RoundedRectangle(cornerRadius: 15)
        .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [5]))
        .foregroundColor(.borderDisabled) // 점선 색상 설정
      : nil
    )
    .padding(.vertical, isDisabled ? 2: 0)
    .accessibilityElement(children: .contain)
    .applyAccessibilityIdentifier(accessibilityID)
  }

  private var isDisabled: Bool {
    attendanceStatus == .absent || attendanceStatus == .defaults
  }

  private var imageName: String {
    switch attendanceStatus {
    case .attended:
      return "Present_icons"
    case .late:
      return "Late_icons"
    case .absent:
      return "Abesent_icons"
      case .defaults:
        return "Default_icons"

    }
  }
}

public extension AttendanceCheckStatusCard {
  func accessibilityIdentifier(_ identifier: String) -> Self {
    var copy = self
    copy.accessibilityID = identifier
    return copy
  }

  func editAccessibilityIdentifier(_ identifier: String) -> Self {
    var copy = self
    copy.editAccessibilityID = identifier
    return copy
  }
}

private extension View {
  @ViewBuilder
  func applyAccessibilityIdentifier(_ identifier: String?) -> some View {
    if let identifier {
      dddAccessibilityID(identifier)
    } else {
      self
    }
  }
}
