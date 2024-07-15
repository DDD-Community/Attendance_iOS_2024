//
//  DropdownMenuItemView.swift
//  DDDAttendance
//
//  Created by 서원지 on 6/15/24.
//

import SwiftUI

struct DropdownMenuItemView: View {
    @Binding var isSelecting: Bool
    @Binding var selectiontitle: String
    @Binding var selectionId: Int
    
    let item: DropdownItem
    
    var body: some View {
        Button(action: {
            isSelecting = false
            selectiontitle = item.title
            item.onSelect()
        }) {
            HStack {
                Text(item.title)
                    .foregroundColor(.basicWhite.opacity(0.7))
                    .pretendardFont(family: .Medium, size: 16)
                    .padding(.leading, 16)
                
                Spacer()
            }
            .frame(width: UIScreen.screenWidth - 40, height: 48)
        }
    }
}


