//
//  VoteTeamSelectView.swift
//  Member
//
//  Created by DDD on 6/11/26.
//

import SwiftUI

import DDDAccessibility
import DDDDesignKit
import VoteDomainInterface

/// [멤버] 투표 1단계 — 팀 선택 화면 (Figma: iOS/투표_1단계(팀 선택))
struct VoteTeamSelectView: View {
  private struct CategoryAnswer: Identifiable {
    let category: TeamVoteCategory
    var selectedTeamIds: Set<Int> = []
    var reason: String = ""
    var id: String { category.id }
  }

  private let info: TeamVoteTemplateInfo
  private let onRequestExit: () -> Void
  private let onNext: ([TeamVoteAnswer]) -> Void

  @State private var answers: [CategoryAnswer]

  init(
    info: TeamVoteTemplateInfo,
    initialAnswers: [TeamVoteAnswer] = [],
    onRequestExit: @escaping () -> Void = {},
    onNext: @escaping ([TeamVoteAnswer]) -> Void = { _ in }
  ) {
    let categories = Self.orderedCategories(info.template.categories)
    self.info = info
    self.onRequestExit = onRequestExit
    self.onNext = onNext
    _answers = State(
      initialValue: Self.makeInitialAnswers(
        categories: categories,
        storedAnswers: initialAnswers
      )
    )
  }

  var body: some View {
    VStack(spacing: 0) {
      ScrollView {
        VStack(alignment: .leading, spacing: 24) {
          StepProgressBar(currentStep: 1, totalSteps: 2)

          TeamVoteHeaderView(
            title: info.template.title,
            description: info.template.description,
            notice: info.template.notice
          )

          ForEach(answers.indices, id: \.self) { index in
            TeamVoteCategoryView(
              category: answers[index].category,
              teams: info.teams,
              selectedTeamIds: $answers[index].selectedTeamIds,
              reason: $answers[index].reason
            )
          }
        }
        .padding(.horizontal, 24)
        .padding(.top, 20)
        .padding(.bottom, 24)
      }
      .scrollIndicators(.hidden)

      nextButton
        .padding(.horizontal, 24)
        .padding(.top, 12)
        .padding(.bottom, 24)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.backGroundPrimary)
    .accessibilityElement(children: .contain)
    .dddAccessibilityID(MemberAccessibilityID.Vote.TeamSelect.root)
    .overlay(alignment: .leading) {
      edgeSwipeArea(gesture: edgeExitGesture)
    }
  }

  private static func orderedCategories(_ categories: [TeamVoteCategory]) -> [TeamVoteCategory] {
    categories.enumerated()
      .sorted { lhs, rhs in
        guard lhs.element.order != rhs.element.order else {
          return lhs.offset < rhs.offset
        }
        return lhs.element.order < rhs.element.order
      }
      .map(\.element)
  }

  private static func makeInitialAnswers(
    categories: [TeamVoteCategory],
    storedAnswers: [TeamVoteAnswer]
  ) -> [CategoryAnswer] {
    var answerByCategory: [String: TeamVoteAnswer] = [:]
    for answer in storedAnswers {
      answerByCategory[answer.categoryId] = answer
    }

    return categories.map { category in
      let storedAnswer = answerByCategory[category.id]
      return CategoryAnswer(
        category: category,
        selectedTeamIds: Set(storedAnswer?.teamIds ?? []),
        reason: storedAnswer?.reason ?? ""
      )
    }
  }

  private func makeTeamVoteAnswers() -> [TeamVoteAnswer] {
    answers.map { answer in
      let reason = answer.reason.trimmingCharacters(in: .whitespacesAndNewlines)
      return TeamVoteAnswer(
        categoryId: answer.category.id,
        teamIds: Array(answer.selectedTeamIds),
        reason: reason.isEmpty ? nil : reason
      )
    }
  }

  private var isNextEnabled: Bool {
    answers.allSatisfy { answer in
      !answer.selectedTeamIds.isEmpty && isReasonValid(answer)
    }
  }

  private func isReasonValid(_ answer: CategoryAnswer) -> Bool {
    guard answer.category.reasonRequired else { return true }
    return answer.reason.normalizedInputCharacterCount >= answer.category.reasonMinLength
      && answer.reason.count <= answer.category.reasonMaxLength
  }

  private var edgeExitGesture: some Gesture {
    DragGesture(minimumDistance: 20, coordinateSpace: .global)
      .onEnded { value in
        guard isBackSwipe(value) else { return }
        onRequestExit()
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

  private var nextButton: some View {
    Button {
      onNext(makeTeamVoteAnswers())
    } label: {
      Text("다음")
        .pretendardFont(family: .Bold, size: 16)
        .foregroundStyle(isNextEnabled ? .staticWhite : .gray60)
        .frame(maxWidth: .infinity)
        .frame(height: 55)
        .background {
          RoundedRectangle(cornerRadius: 14)
            .fill(isNextEnabled ? Color.blue40 : Color.gray80)
        }
    }
    .buttonStyle(.plain)
    .disabled(!isNextEnabled)
    .dddAccessibilityID(MemberAccessibilityID.Vote.TeamSelect.nextButton)
  }
}

private extension String {
  var normalizedInputCharacterCount: Int {
    split(whereSeparator: \.isWhitespace)
      .joined(separator: " ")
      .count
  }
}
