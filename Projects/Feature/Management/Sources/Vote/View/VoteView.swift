//
//  VoteView.swift
//  Management
//
//  Created by DDD on 6/11/26.
//

import SwiftUI

import DDDAccessibility
import DDDDesignKit

import ComposableArchitecture

@ViewAction(for: VoteFeature.self)
public struct VoteView: View {
  @Bindable public var store: StoreOf<VoteFeature>

  public init(store: StoreOf<VoteFeature>) {
    self.store = store
  }

  public var body: some View {
    VStack(alignment: .leading, spacing: 20) {
      voteHeaderView()

      voteStatusView()

      switch store.voteStatus {
      case .before:
        startVoteButton()
      case .inProgress:
        checkNonParticipantsButton()
        endVoteButton()
      case .after:
        checkNonParticipantsButton()
        endedNoticeView()
      }

      Spacer()
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    .padding(.top, 20)
    .padding(.horizontal, 24)
    .accessibilityElement(children: .contain)
    .dddAccessibilityID(ManagementAccessibilityID.Vote.root)
    .onAppear {
      send(.onAppear)
    }
    .onDisappear {
      send(.onDisappear)
    }
  }
}

extension VoteView {
  @ViewBuilder
  func voteHeaderView() -> some View {
    VStack(alignment: .leading, spacing: 6) {
      HStack {
        Text("투표 관리")
          .dddFont(.tilte1NormalBold)
          .foregroundStyle(.staticWhite)

        Spacer()
      }

      Text("운영진 전용 화면이에요. 투표 진행을 관리할 수 있어요.")
        .dddFont(.body3NormalMedium)
        .foregroundStyle(.textCaption)
    }
  }

  @ViewBuilder
  func voteStatusView() -> some View {
    VStack(spacing: 0) {
      HStack(spacing: 0) {
        Text("투표 상태")
          .dddFont(.body3NormalMedium)
          .foregroundStyle(.textCaption)

        Spacer()

        statusChip()
      }
      .padding(.vertical, 14)

      DDDDivider(color: .gray80)

      HStack(spacing: 0) {
        Text("참여 현황")
          .dddFont(.body3NormalMedium)
          .foregroundStyle(.textCaption)

        Spacer()

        Text(participationText)
          .dddFont(.body3NormalMedium)
          .foregroundStyle(store.voteStatus == .before ? Color.textCaption : Color.staticWhite)
          .multilineTextAlignment(.trailing)
      }
      .padding(.vertical, 14)
    }
    .padding(.horizontal, 16)
    .padding(.vertical, 4)
    .frame(maxWidth: .infinity)
    .background {
      RoundedRectangle(cornerRadius: 12)
        .fill(.gray90)
    }
  }

  @ViewBuilder
  func statusChip() -> some View {
    Text(statusChipTitle)
      .pretendardFont(family: .Bold, size: 12)
      .foregroundStyle(statusChipForeground)
      .padding(.horizontal, 10)
      .padding(.vertical, 4)
      .background {
        RoundedRectangle(cornerRadius: 6)
          .fill(statusChipBackground)
      }
      .dddAccessibilityID(ManagementAccessibilityID.Vote.statusChip)
  }

  var statusChipTitle: String {
    switch store.voteStatus {
    case .before: return "투표 전"
    case .inProgress: return "진행 중"
    case .after: return "투표 종료"
    }
  }

  var statusChipForeground: Color {
    switch store.voteStatus {
    case .before: return .borderInactive
    case .inProgress: return .staticWhite
    case .after: return .textCaption
    }
  }

  var statusChipBackground: Color {
    switch store.voteStatus {
    case .before, .after: return .gray80
    case .inProgress: return .blue40
    }
  }

  var participationText: String {
    switch store.voteStatus {
    case .before:
      return "투표 시작 전이에요"
    case .inProgress:
      guard let p = store.participation else { return "집계 중이에요" }
      return "\(p.totalMembers)명 중 \(p.respondedMembers)명 참여 (\(p.participationRate)%)"
    case .after:
      guard let p = store.participation else { return "집계 완료" }
      return "최종 \(p.respondedMembers)명 참여 (\(p.participationRate)%)"
    }
  }

  @ViewBuilder
  func startVoteButton() -> some View {
    CustomButton(
      action: {
        send(.tappedStartVoteButton)
      },
      title: "투표 시작하기",
      config: CustomButtonConfig.createVoteButton()
    )
    .isEnable(true)
    .dddAccessibilityID(ManagementAccessibilityID.Vote.startButton)
  }

  @ViewBuilder
  func checkNonParticipantsButton() -> some View {
    Button {
      send(.tappedCheckNonParticipants)
    } label: {
      HStack(spacing: 8) {
        Text("미참여 인원 확인하기")
          .pretendardFont(family: .Bold, size: 15)
          .foregroundStyle(.staticWhite)

        Image(systemName: "arrow.right")
          .font(.system(size: 14, weight: .bold))
          .foregroundStyle(.staticWhite)
      }
      .frame(maxWidth: .infinity)
      .frame(height: 52)
      .overlay {
        RoundedRectangle(cornerRadius: 10)
          .strokeBorder(Color.borderNormal, lineWidth: 1)
      }
    }
    .buttonStyle(.plain)
    .dddAccessibilityID(ManagementAccessibilityID.Vote.nonParticipantsButton)
  }

  @ViewBuilder
  func endVoteButton() -> some View {
    CustomButton(
      action: {
        send(.tappedEndVoteButton)
      },
      title: "투표 종료하기",
      config: CustomButtonConfig.createEndVoteButton()
    )
    .isEnable(true)
    .dddAccessibilityID(ManagementAccessibilityID.Vote.endButton)
  }

  @ViewBuilder
  func endedNoticeView() -> some View {
    Text("투표가 종료되었어요")
      .pretendardFont(family: .Bold, size: 16)
      .foregroundStyle(.textCaption)
      .frame(maxWidth: .infinity)
      .frame(height: 52)
      .background {
        RoundedRectangle(cornerRadius: 10)
          .fill(Color.gray80)
      }
  }
}

#Preview {
  VoteView(store: .init(initialState: VoteFeature.State(), reducer: {
    VoteFeature()
  }))
  .background(Color.backGroundPrimary)
}
