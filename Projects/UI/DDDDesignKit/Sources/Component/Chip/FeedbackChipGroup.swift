//
//  FeedbackChipGroup.swift
//  DDDDesignKit
//
//  Created by DDD on 6/10/26.
//

import SwiftUI

/// 서버에서 내려온 칩 목록을 받아 자동 줄바꿈으로 배치하는 다중 선택 그룹.
/// `items`만 갈아끼우면 칩 개수/내용이 그대로 반영된다.
public struct FeedbackChipGroup: View {
  private var items: [ChipItem]
  @Binding private var selectedIDs: Set<String>
  private var horizontalSpacing: CGFloat
  private var verticalSpacing: CGFloat
  private var itemAccessibilityIdentifier: (ChipItem) -> String? = { _ in nil }

  public init(
    items: [ChipItem],
    selectedIDs: Binding<Set<String>>,
    horizontalSpacing: CGFloat = 8,
    verticalSpacing: CGFloat = 8
  ) {
    self.items = items
    _selectedIDs = selectedIDs
    self.horizontalSpacing = horizontalSpacing
    self.verticalSpacing = verticalSpacing
  }

  public var body: some View {
    FlowLayout(
      horizontalSpacing: horizontalSpacing,
      verticalSpacing: verticalSpacing
    ) {
      ForEach(items) { item in
        chip(item)
      }
    }
  }

  @ViewBuilder
  private func chip(_ item: ChipItem) -> some View {
    let view = FeedbackChip(
      title: item.title,
      isSelected: selectedIDs.contains(item.id)
    ) {
      toggle(item.id)
    }

    if let identifier = itemAccessibilityIdentifier(item) {
      view.accessibilityIdentifier(identifier)
    } else {
      view
    }
  }

  private func toggle(_ id: String) {
    if selectedIDs.contains(id) {
      selectedIDs.remove(id)
    } else {
      selectedIDs.insert(id)
    }
  }
}

#Preview {
  struct PreviewContainer: View {
    private let items = [
      "OT", "부스팅 데이", "직군세션1",
      "UT 1차", "중간 발표", "티키타카",
      "UT 2차", "직군세션 2", "최종 발표"
    ].map { ChipItem(id: $0, title: $0) }

    @State private var selected: Set<String> = ["OT", "중간 발표", "최종 발표"]

    var body: some View {
      FeedbackChipGroup(items: items, selectedIDs: $selected)
        .padding(24)
        .frame(maxWidth: 375, alignment: .leading)
        .background(Color.backGroundPrimary)
    }
  }
  return PreviewContainer()
}

// MARK: - 체이닝 설정

//
// 값 타입 사본을 돌려주므로 호출 순서에 영향받지 않는다.
// 기존 init 은 그대로 두어, 체이닝은 선택지로만 더한다.
public extension FeedbackChipGroup {
  /// `items` 을 바꾼 사본을 돌려준다.
  func items(_ items: [ChipItem]) -> Self {
    var copy = self
    copy.items = items
    return copy
  }

  /// `horizontalSpacing` 을 바꾼 사본을 돌려준다.
  func horizontalSpacing(_ horizontalSpacing: CGFloat) -> Self {
    var copy = self
    copy.horizontalSpacing = horizontalSpacing
    return copy
  }

  /// `verticalSpacing` 을 바꾼 사본을 돌려준다.
  func verticalSpacing(_ verticalSpacing: CGFloat) -> Self {
    var copy = self
    copy.verticalSpacing = verticalSpacing
    return copy
  }

  /// 각 칩에 적용할 접근성 식별자를 설정합니다.
  func accessibilityIdentifier(
    _ identifier: @escaping (ChipItem) -> String?
  ) -> Self {
    var copy = self
    copy.itemAccessibilityIdentifier = identifier
    return copy
  }
}
