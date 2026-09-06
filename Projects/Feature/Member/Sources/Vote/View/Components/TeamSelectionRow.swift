//
//  TeamSelectionRow.swift
//  Member
//
//  Created by DDD on 6/11/26.
//

import SwiftUI

import DDDSharedUI

/// 팀 투표 1단계의 팀 선택 행 (이름 + 서비스명 + 체크박스/본인팀 칩).
/// 도메인 비의존 — feature 에서 모델을 매핑해 사용한다.
struct TeamSelectionRow: View {
  private let name: String
  private let serviceName: String?
  private let isOwnTeam: Bool
  private let isSelected: Bool
  private let onTap: () -> Void

  init(
    name: String,
    serviceName: String?,
    isOwnTeam: Bool,
    isSelected: Bool,
    onTap: @escaping () -> Void
  ) {
    self.name = name
    self.serviceName = serviceName
    self.isOwnTeam = isOwnTeam
    self.isSelected = isSelected
    self.onTap = onTap
  }

  var body: some View {
    HStack(spacing: 12) {
      VStack(alignment: .leading, spacing: 2) {
        Text(name)
          .pretendardFont(family: .Bold, size: 16)
          .foregroundStyle(isOwnTeam ? Color.gray60 : Color.staticWhite)

        if let serviceName, !serviceName.isEmpty {
          Text(serviceName)
            .pretendardFont(family: .Regular, size: 13)
            .foregroundStyle(.gray60)
        }
      }
      .frame(maxWidth: .infinity, alignment: .leading)

      if isOwnTeam {
        ownTeamChip
      } else {
        checkBox
      }
    }
    .padding(.vertical, 16)
    .contentShape(Rectangle())
    .onTapGesture {
      dismissKeyboard()
      guard !isOwnTeam else { return }
      DispatchQueue.main.async {
        onTap()
      }
    }
  }

  private var ownTeamChip: some View {
    Text("본인 팀")
      .pretendardFont(family: .Medium, size: 12)
      .foregroundStyle(.gray60)
      .padding(.horizontal, 8)
      .padding(.vertical, 4)
      .background {
        Capsule().fill(Color.gray90)
      }
  }

  private var checkBox: some View {
    RoundedRectangle(cornerRadius: 6)
      .fill(isSelected ? Color.blue40 : Color.clear)
      .overlay {
        if isSelected {
          RoundedRectangle(cornerRadius: 2)
            .fill(Color.staticWhite)
            .frame(width: 8, height: 8)
        } else {
          RoundedRectangle(cornerRadius: 6)
            .strokeBorder(Color.borderNormal, lineWidth: 1.5)
        }
      }
      .frame(width: 22, height: 22)
  }

}
