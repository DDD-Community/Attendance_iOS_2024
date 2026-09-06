//
//  MemberVoteView.swift
//  Member
//
//  Created by DDD on 6/11/26.
//

import SwiftUI
import DDDAccessibility

import DDDDesignKit

import ComposableArchitecture

/// [멤버] 투표 탭 컨테이너. 단계(Step)에 따라 팀 선택/피드백/완료 화면을 전환한다.
@ViewAction(for: MemberVoteFeature.self)
struct MemberVoteView: View {
  @Bindable var store: StoreOf<MemberVoteFeature>

  init(store: StoreOf<MemberVoteFeature>) {
    self.store = store
  }

  var body: some View {
    content()
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .background(Color.backGroundPrimary)
      .alert($store.scope(state: \.alert, action: \.scope.alert))
      .dddToast()
      .onAppear {
        send(.onAppear)
      }
  }

  @ViewBuilder
  private func content() -> some View {
    Group {
      switch store.step {
      case .loading:
        MemberVoteSkeletonView()

      case .empty:
        messageView(
          title: "진행 중인 투표가 없어요",
          description: "새로운 투표가 열리면 이곳에서 참여할 수 있어요."
        )

      case .alreadyVoted:
        messageView(
          title: "이미 투표에 참여했어요",
          description: "투표 결과는 집계 후 공개될 예정이에요."
        )

      case .teamSelect:
        if let info = store.teamTemplate {
          VoteTeamSelectView(
            info: info,
            initialAnswers: store.teamAnswers,
            onRequestExit: {
              send(.requestExit)
            },
            onNext: { answers in
              send(.teamSelectNext(answers))
            }
          )
        } else {
          MemberVoteSkeletonView()
        }

      case .feedback:
        if let info = store.feedbackTemplate {
          VoteFeedbackView(
            info: info,
            onBack: {
              send(.requestExit)
            },
            onSubmit: { answers in
              send(.submitFeedback(answers))
            }
          )
        } else {
          MemberVoteSkeletonView()
        }

      case .completed:
        completedView
      }
    }
    .dddAccessibilityID(MemberAccessibilityID.voteRoot)
  }

  @ViewBuilder
  private func messageView(
    title: String,
    description: String
  ) -> some View {
    VStack(spacing: 8) {
      Text(title)
        .pretendardFont(family: .Bold, size: 18)
        .foregroundStyle(.staticWhite)

      Text(description)
        .pretendardFont(family: .Medium, size: 14)
        .foregroundStyle(.textCaption)
        .multilineTextAlignment(.center)
    }
    .padding(.horizontal, 24)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
  }

  private var completedView: some View {
    VStack(spacing: 0) {
      Spacer()
        .frame(height: 192)

      Image(asset: .voteComplete)
        .resizable()
        .scaledToFit()
        .frame(width: 88, height: 88)

      Text("투표 완료!")
        .pretendardFont(family: .Bold, size: 28)
        .foregroundStyle(Color.staticWhite)
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)
        .padding(.top, 34)

      Text("소중한 한 표를 보내주셔서 감사해요.\nDDD 13기 모두 정말 고생 많았어요 🎉")
        .pretendardFont(family: .Regular, size: 16)
        .foregroundStyle(Color(hex: "B2B8BF"))
        .lineSpacing(8)
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)
        .padding(.top, 8)

      Text("결과는 최종 발표에서 공개될 예정이에요.")
        .pretendardFont(family: .Regular, size: 14)
        .foregroundStyle(Color(hex: "737880"))
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)
        .padding(.top, 54)

      Spacer(minLength: 0)
    }
    .padding(.horizontal, 20)
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
  }
}
