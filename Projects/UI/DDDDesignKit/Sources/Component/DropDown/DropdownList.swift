//
//  DropdownList.swift
//  DDDDesignKit
//
//  Created by DDD on 1/16/25.
//

import SwiftUI

public struct DropdownList: View {
  private var items: [String]
  @Binding var selectedItem: SelectDropDownItem
  @Binding var isExpanded: Bool
  
  public init(
    items: [String],
    selectedItem: Binding<SelectDropDownItem>,
    isExpanded: Binding<Bool>
  ) {
    self.items = items
    self._selectedItem = selectedItem
    self._isExpanded = isExpanded
  }
  
  public var body: some View {
    VStack(spacing: 0) {
      ForEach(items, id: \.self) { item in
        VStack(spacing: 0) {
          HStack {
            Text(item) // item은 이미 desc 값임
              .foregroundColor(selectedItem.desc == item ? .staticWhite : .borderInactive)
              .dddFont(.title3NormalBold)
              .padding()
            
            Spacer()
          }
          .onTapGesture {
            withAnimation {
              if let matchedItem = SelectDropDownItem.allCases.first(where: { $0.desc == item }) {
                selectedItem = matchedItem
              }
              isExpanded = false
            }
          }
          .background(.borderDisabled)
          .frame(width: 140)
          
          // Divider 추가 (마지막 항목 제외)
          if item != items.last {
            DDDDivider(color: .borderInverse)
          }
        }
      }
    }
    .background(.borderDisabled)
    .cornerRadius(12)
  }
}


func solution(_ income: [Int], _outlay: [Int], cash: Int) -> Int {
  return 0
}

// MARK: - 체이닝 설정
//
// 값 타입 사본을 돌려주므로 호출 순서에 영향받지 않는다.
// 기존 init 은 그대로 두어, 체이닝은 선택지로만 더한다.
public extension DropdownList {
  /// `items` 을 바꾼 사본을 돌려준다.
  func items(_ items: [String]) -> Self {
    var copy = self
    copy.items = items
    return copy
  }
}
