//
//  DropdownMenuItemView.swift
//  DDDAttendance
//
//  Created by DDD on 6/15/24.
//

import SwiftUI

import DDDCoreUI

struct DropdownMenuItemView: View {
  @Binding private var isSelecting: Bool
  @Binding private var selectiontitle: String
  @Binding private var selectionId: Int
  
  private let item: DropdownItem
  
  init(
    isSelecting: Binding<Bool>,
    selectiontitle: Binding<String>,
    selectionId: Binding<Int>,
    item: DropdownItem
  ) {
    self._isSelecting = isSelecting
    self._selectiontitle = selectiontitle
    self._selectionId = selectionId
    self.item = item
  }
  
  var body: some View {
    Button(action: {
      isSelecting = false
      selectiontitle = item.title
      item.onSelect()
    }) {
      HStack {
        Text(item.title)
          .foregroundColor(.staticWhite.opacity(0.7))
          .pretendardFont(family: .Medium, size: 16)
          .padding(.leading, 16)
        
        Spacer()
      }
      .frame(width: UIScreen.screenWidth - 40, height: 48)
    }
  }
}
