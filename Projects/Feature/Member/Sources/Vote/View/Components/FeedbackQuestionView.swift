//
//  FeedbackQuestionView.swift
//  Member
//
//  Created by DDD on 6/11/26.
//

import SwiftUI

import DDDAccessibility
import DDDDesignKit
import VoteDomainInterface

/// 피드백 2단계의 질문 한 개 블록. 질문 타입(MULTI_SELECT/LONG_TEXT/BOOLEAN)에 맞춰 렌더링.
struct FeedbackQuestionView: View {
  let index: Int
  let question: FeedbackQuestion
  let textMinLength: Int
  @Binding var selectedOptionIds: Set<String>
  @Binding var textValue: String
  @Binding var boolAnswer: YesNoAnswer?
  @Binding var followUpTexts: [String: String]

  private let defaultPlaceholder = "자유롭게 의견을 남겨주세요."

  var body: some View {
    content
      .accessibilityElement(children: .contain)
      .dddAccessibilityID(MemberAccessibilityID.Vote.Feedback.question(question.id))
  }

  @ViewBuilder
  private var content: some View {
    switch question.type {
    case .multiSelect, .teamSelect:
      multiSelectView
    case .longText:
      longTextView
    case .boolean:
      booleanView
    }
  }

  private var titleText: String {
    "\(index + 1). \(question.title)"
  }

  private var multiSelectView: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text(titleText)
        .pretendardFont(family: .Bold, size: 16)
        .foregroundStyle(.staticWhite)
        .frame(maxWidth: .infinity, alignment: .leading)

      if let helpText = question.helpText, !helpText.isEmpty {
        Text(helpText)
          .pretendardFont(family: .Medium, size: 14)
          .foregroundStyle(.textCaption)
          .frame(maxWidth: .infinity, alignment: .leading)
      }

      FeedbackChipGroup(
        items: (question.options ?? []).map { ChipItem(id: $0.id, title: $0.label) },
        selectedIDs: $selectedOptionIds
      )
      .accessibilityIdentifier { item in
        MemberAccessibilityID.Vote.Feedback.option(question.id, item.id)
      }

      ForEach(question.followUp) { followUp in
        FeedbackTextEditor(
          placeholder: defaultPlaceholder,
          text: followUpBinding(for: followUp.id)
        )
        .title(followUp.title)
        .titleStyle(.secondary)
        .minLength(textMinLength)
        .maxLength(followUp.maxLength ?? 300)
      }
    }
  }

  private var longTextView: some View {
    FeedbackTextEditor(
      placeholder: defaultPlaceholder,
      text: $textValue
    )
    .title(titleText)
    .description(question.helpText)
    .minLength(textMinLength)
    .maxLength(question.maxLength ?? 300)
  }

  private var booleanView: some View {
    VStack(alignment: .leading, spacing: 12) {
      FeedbackYesNoQuestion(
        question: titleText,
        answer: $boolAnswer
      )
    }
  }

  /// followUp 은 id 로 식별되는 중첩 답변이라 컴포넌트 내부에서만 키 바인딩을 만든다.
  private func followUpBinding(for id: String) -> Binding<String> {
    Binding(
      get: { followUpTexts[id] ?? "" },
      set: { followUpTexts[id] = $0 }
    )
  }
}
