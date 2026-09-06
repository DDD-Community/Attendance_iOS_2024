//
//  DDDTabs.swift
//  DDDDesignKit
//

import SwiftUI

/// 텍스트 너비의 선택 인디케이터를 사용하는 가로 탭입니다.
public struct DDDTabs<Item: Identifiable>: View where Item.ID: Hashable {
  private let items: [Item]
  private let selectedID: Item.ID?
  private let title: (Item) -> String
  private var itemAccessibilityIdentifier: (Item) -> String? = { _ in nil }
  private let onSelect: (Item) -> Void

  @Namespace private var selectionNamespace

  public init(
    items: [Item],
    selectedID: Item.ID?,
    title: @escaping (Item) -> String,
    onSelect: @escaping (Item) -> Void
  ) {
    self.items = items
    self.selectedID = selectedID
    self.title = title
    self.onSelect = onSelect
  }

  public var body: some View {
    ScrollViewReader { proxy in
      VStack {
        ScrollView(.horizontal, showsIndicators: false) {
          HStack {
            ForEach(items) { item in
              tab(item)
            }
          }
          .padding(.horizontal, 24)
        }
        .scrollDisabled(true)

        Spacer()
          .frame(height: 12)

        DDDDivider(color: .borderInactive.opacity(0.12))
          .offset(y: -12)
      }
      .onChange(of: selectedID) { _, selectedID in
        guard let selectedID,
              items.contains(where: { $0.id == selectedID })
        else { return }

        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
          proxy.scrollTo(selectedID, anchor: .center)
        }
      }
    }
  }

  @ViewBuilder
  private func tab(_ item: Item) -> some View {
    let tab = Button {
      withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
        onSelect(item)
      }
    } label: {
      tabLabel(item)
    }
    .buttonStyle(.plain)
    .id(item.id)

    if let identifier = itemAccessibilityIdentifier(item) {
      tab.accessibilityIdentifier(identifier)
    } else {
      tab
    }
  }

  private func tabLabel(_ item: Item) -> some View {
    let isSelected = selectedID == item.id

    return VStack(spacing: .zero) {
      HStack(spacing: .zero) {
        Spacer()
          .frame(width: 16)

        tabTitle(item, isSelected: isSelected)

        Spacer()
          .frame(width: 16)
      }

      Spacer()
        .frame(height: 12)

      tabTitle(item, isSelected: isSelected)
        .hidden()
        .overlay {
          if isSelected {
            Rectangle()
              .fill(Color.blue40)
              .frame(height: 2)
              .matchedGeometryEffect(id: "dddTabsSelection", in: selectionNamespace)
          } else {
            Color.clear
              .frame(height: 2)
          }
        }
        .frame(height: 2)
        .accessibilityHidden(true)
    }
    .fixedSize(horizontal: true, vertical: false)
  }

  private func tabTitle(_ item: Item, isSelected: Bool) -> some View {
    Text(title(item))
      .pretendardFont(family: .Bold, size: 16)
      .foregroundStyle(isSelected ? Color.staticWhite : Color.gray600)
      .animation(.easeInOut(duration: 0.25), value: selectedID)
  }
}

public extension DDDTabs {
  /// 각 탭에 적용할 접근성 식별자를 설정합니다.
  func accessibilityIdentifier(
    _ identifier: @escaping (Item) -> String?
  ) -> Self {
    var copy = self
    copy.itemAccessibilityIdentifier = identifier
    return copy
  }
}
