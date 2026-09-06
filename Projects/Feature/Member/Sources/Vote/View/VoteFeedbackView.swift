//
//  VoteFeedbackView.swift
//  Member
//
//  Created by DDD on 6/11/26.
//

import SwiftUI

import DDDAccessibility
import DDDDesignKit
import VoteDomainInterface

/// [멤버] 투표 2단계 — 참여 경험 피드백 화면 (Figma: iOS/투표_2단계(피드백))
struct VoteFeedbackView: View {
  private struct QuestionAnswer: Identifiable {
    let question: FeedbackQuestion
    var selectedOptionIds: Set<String> = []
    var textValue: String = ""
    var boolAnswer: YesNoAnswer?
    var followUpTexts: [String: String] = [:]
    var id: String { question.id }
  }

  private let info: FeedbackTemplateInfo
  private let onBack: () -> Void
  private let onSubmit: ([FeedbackAnswer]) -> Void

  private let textMinLength = 5

  @State private var answers: [QuestionAnswer]

  init(
    info: FeedbackTemplateInfo,
    onBack: @escaping () -> Void = {},
    onSubmit: @escaping ([FeedbackAnswer]) -> Void = { _ in }
  ) {
    self.info = info
    self.onBack = onBack
    self.onSubmit = onSubmit
    _answers = State(initialValue: info.template.questions.map { QuestionAnswer(question: $0) })
  }

  var body: some View {
    VStack(spacing: 0) {
      ScrollViewReader { proxy in
        ScrollView {
          VStack(alignment: .leading, spacing: 28) {
            StepProgressBar(currentStep: 2, totalSteps: 2)

            headerView

            ForEach(answers.indices, id: \.self) { index in
              FeedbackQuestionView(
                index: index,
                question: answers[index].question,
                textMinLength: textMinLength,
                selectedOptionIds: $answers[index].selectedOptionIds,
                textValue: $answers[index].textValue,
                boolAnswer: $answers[index].boolAnswer,
                followUpTexts: $answers[index].followUpTexts
              )
              .id(index)
            }
          }
          .padding(.horizontal, 24)
          .padding(.top, 8)
          .padding(.bottom, 24)
        }
        .scrollIndicators(.hidden)
        // 마지막 문항 선택 시 해당 문항이 시야에서 벗어나지 않도록 다시 보이게 스크롤 (선택 확인 가능)
        .onChange(of: lastQuestionAnswerID) { _, _ in
          guard let lastIndex = answers.indices.last else { return }
          withAnimation(.easeInOut(duration: 0.25)) {
            proxy.scrollTo(lastIndex, anchor: .bottom)
          }
        }
      }

      submitButton
        .padding(.horizontal, 24)
        .padding(.top, 12)
        .padding(.bottom, 24)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.backGroundPrimary)
    .accessibilityElement(children: .contain)
    .dddAccessibilityID(MemberAccessibilityID.Vote.Feedback.root)
    .overlay(alignment: .leading) {
      edgeSwipeArea(gesture: edgeBackGesture)
    }
  }

  private var edgeBackGesture: some Gesture {
    DragGesture(minimumDistance: 20, coordinateSpace: .global)
      .onEnded { value in
        guard isBackSwipe(value) else { return }
        onBack()
      }
  }

  private func isBackSwipe(_ value: DragGesture.Value) -> Bool {
    value.startLocation.x <= 24
      && value.translation.width >= 80
      && abs(value.translation.height) <= 60
  }

  private func edgeSwipeArea(gesture: some Gesture) -> some View {
    Color.clear
      .frame(width: 24)
      .contentShape(Rectangle())
      .gesture(gesture)
  }

  private var headerView: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text(info.template.title)
        .pretendardFont(family: .Bold, size: 20)
        .foregroundStyle(.staticWhite)

      Text(info.template.description)
        .pretendardFont(family: .Medium, size: 14)
        .foregroundStyle(.textCaption)
        .fixedSize(horizontal: false, vertical: true)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
  }

  private func makeFeedbackAnswers() -> [FeedbackAnswer] {
    var result: [FeedbackAnswer] = []
    for answer in answers {
      switch answer.question.type {
      case .multiSelect, .teamSelect:
        result.append(FeedbackAnswer(
          questionId: answer.question.id,
          optionIds: Array(answer.selectedOptionIds),
          textValue: nil,
          boolValue: nil
        ))

      case .longText:
        let textValue = answer.textValue.trimmingCharacters(in: .whitespacesAndNewlines)
        result.append(FeedbackAnswer(
          questionId: answer.question.id,
          optionIds: nil,
          textValue: textValue.normalizedInputCharacterCount == 0 ? nil : textValue,
          boolValue: nil
        ))

      case .boolean:
        result.append(FeedbackAnswer(
          questionId: answer.question.id,
          optionIds: nil,
          textValue: nil,
          boolValue: answer.boolAnswer.map { $0 == .yes }
        ))
      }

      // followUp 텍스트 답변은 별도 질문으로 함께 제출한다.
      for (followUpId, text) in answer.followUpTexts {
        let textValue = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard textValue.normalizedInputCharacterCount > 0 else { continue }
        result.append(FeedbackAnswer(
          questionId: followUpId,
          optionIds: nil,
          textValue: textValue,
          boolValue: nil
        ))
      }
    }
    return result
  }

  private var lastQuestionAnswerID: String {
    guard let last = answers.last else { return "" }
    return "\(String(describing: last.boolAnswer))|\(last.selectedOptionIds.sorted().joined(separator: ","))"
  }

  private var isSubmitEnabled: Bool {
    answers.allSatisfy(isQuestionValid)
  }

  private func isQuestionValid(_ answer: QuestionAnswer) -> Bool {
    let question = answer.question

    switch question.type {
    case .multiSelect, .teamSelect:
      guard !question.required || !answer.selectedOptionIds.isEmpty else { return false }

      if let maxSelectableOptions = question.maxSelectableOptions,
         answer.selectedOptionIds.count > maxSelectableOptions
      {
        return false
      }

      return question.followUp.allSatisfy { followUp in
        isTextAnswerValid(
          answer.followUpTexts[followUp.id] ?? "",
          question: followUp
        )
      }

    case .longText:
      return isTextAnswerValid(answer.textValue, question: question)

    case .boolean:
      return !question.required || answer.boolAnswer != nil
    }
  }

  private func isTextAnswerValid(
    _ text: String,
    question: FeedbackQuestion
  ) -> Bool {
    let contentLength = text.normalizedInputCharacterCount

    if contentLength == 0 {
      return !question.required
    }

    return contentLength >= textMinLength
      && text.count <= (question.maxLength ?? 300)
  }

  private var submitButton: some View {
    Button {
      onSubmit(makeFeedbackAnswers())
    } label: {
      Text("제출하기")
        .pretendardFont(family: .Bold, size: 16)
        .foregroundStyle(isSubmitEnabled ? .staticWhite : .gray60)
        .frame(maxWidth: .infinity)
        .frame(height: 56)
        .background {
          RoundedRectangle(cornerRadius: 14)
            .fill(isSubmitEnabled ? Color.blue40 : Color.gray80)
        }
    }
    .buttonStyle(.plain)
    .disabled(!isSubmitEnabled)
    .dddAccessibilityID(MemberAccessibilityID.Vote.Feedback.submitButton)
  }
}

private extension String {
  var normalizedInputCharacterCount: Int {
    split(whereSeparator: \.isWhitespace)
      .joined(separator: " ")
      .count
  }
}
