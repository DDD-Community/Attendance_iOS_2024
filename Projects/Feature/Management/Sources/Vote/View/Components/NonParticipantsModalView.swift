//
//  NonParticipantsModalView.swift
//  Management
//
//  Created by DDD on 6/11/26.
//

import SwiftUI

import DDDAccessibility
import DDDDesignKit
import VoteDomainInterface

extension View {
  func nonParticipantsModal(
    isPresented: Bool,
    isLoading: Bool,
    members: [NonParticipant],
    onClose: @escaping () -> Void
  ) -> some View {
    overlay {
      if isPresented {
        NonParticipantsModalView(isLoading: isLoading, members: members, onClose: onClose)
          .transition(.opacity)
          .dddAccessibilityID(ManagementAccessibilityID.Vote.nonParticipantsModal)
      }
    }
    .animation(.easeInOut(duration: 0.2), value: isPresented)
  }
}

struct NonParticipantsModalView: View {
  let isLoading: Bool
  let members: [NonParticipant]
  let onClose: () -> Void

  @State private var isContentVisible = false
  @State private var isAnimating = false

  var body: some View {
    ZStack {
      Color.black
        .opacity(isContentVisible ? 0.6 : 0)
        .ignoresSafeArea()
        .onTapGesture { dismiss() }

      card
        .offset(y: isContentVisible ? 0 : 120)
        .opacity(isContentVisible ? 1 : 0)
    }
    .onAppear {
      withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
        isContentVisible = true
      }
      withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
        isAnimating = true
      }
    }
  }

  private var card: some View {
    VStack(alignment: .leading, spacing: 4) {
      Text("투표 미참여 멤버")
        .pretendardFont(family: .Bold, size: 20)
        .foregroundStyle(.staticWhite)

      Text(isLoading ? "명단을 불러오고 있어요." : "총 \(members.count)명이 아직 투표하지 않았어요.")
        .pretendardFont(family: .Medium, size: 14)
        .foregroundStyle(.textCaption)

      if isLoading {
        skeletonList
      } else {
        memberList
      }

      Spacer().frame(height: 8)

      Button {
        dismiss()
      } label: {
        Text("닫기")
          .pretendardFont(family: .Bold, size: 15)
          .foregroundStyle(.staticWhite)
          .frame(maxWidth: .infinity)
          .frame(height: 48)
          .background {
            RoundedRectangle(cornerRadius: 10)
              .fill(Color.blue40)
          }
      }
      .buttonStyle(.plain)
    }
    .padding(.top, 24)
    .padding(.bottom, 16)
    .padding(.horizontal, 20)
    .background {
      RoundedRectangle(cornerRadius: 16)
        .fill(Color.gray90)
    }
    .padding(.horizontal, 24)
  }

  private var memberList: some View {
    ScrollView {
      VStack(spacing: 0) {
        ForEach(Array(members.enumerated()), id: \.element.id) { index, member in
          memberRow(member)

          if index < members.count - 1 {
            DDDDivider(color: .gray80)
          }
        }
      }
    }
    .frame(maxHeight: 360)
    .scrollBounceBehavior(.basedOnSize)
    .scrollIndicators(.hidden)
  }

  private var skeletonList: some View {
    VStack(spacing: 0) {
      ForEach(0 ..< 6, id: \.self) { index in
        skeletonRow

        if index < 5 {
          DDDDivider(color: .gray80)
        }
      }
    }
    .frame(height: 360, alignment: .top)
  }

  private var skeletonRow: some View {
    HStack(spacing: 8) {
      RoundedRectangle(cornerRadius: 6)
        .fill(skeletonFill)
        .frame(width: 48, height: 16)

      RoundedRectangle(cornerRadius: 6)
        .fill(skeletonFill)
        .frame(width: 56, height: 20)

      Spacer(minLength: 0)

      RoundedRectangle(cornerRadius: 6)
        .fill(skeletonFill)
        .frame(width: 36, height: 20)
    }
    .padding(.vertical, 12)
  }

  private var skeletonFill: LinearGradient {
    let base = Color.gray80.opacity(isAnimating ? 0.4 : 0.8)
    let tint = Color.blue20.opacity(isAnimating ? 0.1 : 0.2)
    return LinearGradient(colors: [base, tint, base], startPoint: .leading, endPoint: .trailing)
  }

  private func memberRow(_ member: NonParticipant) -> some View {
    HStack(spacing: 8) {
      Text(member.name)
        .pretendardFont(family: .Bold, size: 15)
        .foregroundStyle(.staticWhite)

      teamChip(member.teamName)

      Spacer(minLength: 0)

      if let attendance = member.attendance {
        attendanceChip(attendance)
      }
    }
    .padding(.vertical, 12)
  }

  private func teamChip(_ title: String) -> some View {
    Text(title)
      .pretendardFont(family: .Medium, size: 12)
      .foregroundStyle(.borderInactive)
      .padding(.horizontal, 8)
      .padding(.vertical, 3)
      .background {
        RoundedRectangle(cornerRadius: 6)
          .fill(Color.gray80)
      }
  }

  private func attendanceChip(_ mark: VoteAttendanceMark) -> some View {
    Text(mark.title)
      .pretendardFont(family: .Medium, size: 12)
      .foregroundStyle(attendanceTextColor(mark))
      .padding(.horizontal, 8)
      .padding(.vertical, 3)
      .background {
        RoundedRectangle(cornerRadius: 6)
          .fill(attendanceBackgroundColor(mark))
      }
  }

  private func attendanceTextColor(_ mark: VoteAttendanceMark) -> Color {
    switch mark {
    case .attended: return .attendanceAttendedText
    case .late: return .attendanceLateText
    case .absent: return .attendanceAbsentText
    }
  }

  private func attendanceBackgroundColor(_ mark: VoteAttendanceMark) -> Color {
    switch mark {
    case .attended: return .attendanceAttendedBg
    case .late: return .attendanceLateBg
    case .absent: return .attendanceAbsentBg
    }
  }

  private func dismiss() {
    withAnimation(.easeInOut(duration: 0.2)) {
      isContentVisible = false
    }
    onClose()
  }
}
