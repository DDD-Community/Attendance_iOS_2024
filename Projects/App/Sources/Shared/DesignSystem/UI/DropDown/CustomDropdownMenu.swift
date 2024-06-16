//
//  CustomDropdownMenu.swift
//  DDDAttendance
//
//  Created by 서원지 on 6/15/24.
//

import SwiftUI

public struct CustomDropdownMenu: View {
    @Binding var isSelecting: Bool
    @Binding var selectionTitle: String
    @State var selectedRowId = 0

    public init(
        isSelecting: Binding<Bool>,
        selectionTitle: Binding<String>
    ) {
        self._isSelecting = isSelecting
        self._selectionTitle = selectionTitle
    }
    
    public var body: some View {
        VStack {
            HStack {
                VStack {
                    Spacer()
                        .frame(height: 12)
                    
                    HStack {
                        Text(isSelecting ? "선택해주세요." : selectionTitle)
                            .pretendardFont(family: isSelecting ? .Medium : .Bold, size: 16)
                            .foregroundColor(isSelecting ? .basicGray7 : .basicWhite)
                            .padding(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 0))
                        Spacer()
                        
                        VStack {
                            Spacer()
                            Image(systemName: isSelecting ? "chevron.up" : "chevron.down")
                                .frame(width: 20, height: 20)
                                .foregroundColor(Color.basicWhite)
                                .padding(16)
                            Spacer()
                        }
                    }
                    .frame(height: 48)
                    ScrollView(.vertical, showsIndicators: false) {
                        if isSelecting {
                            
                            VStack(spacing: 0) {
                                DropdownMenuItemView(isSelecting: $isSelecting, selectiontitle: $selectionTitle, selectionId: $selectedRowId, item: .init(id: 1, title: "부스팅 데이 1", onSelect: {}))
                                DropdownMenuItemView(isSelecting: $isSelecting, selectiontitle: $selectionTitle, selectionId: $selectedRowId, item: .init(id: 2, title: "직군 모임 1", onSelect: {}))
                                DropdownMenuItemView(isSelecting: $isSelecting, selectiontitle: $selectionTitle, selectionId: $selectedRowId, item: .init(id: 3, title: "부스팅 데이 2", onSelect: {}))
                                DropdownMenuItemView(isSelecting: $isSelecting, selectiontitle: $selectionTitle, selectionId: $selectedRowId, item: .init(id: 4, title: "중간 발표", onSelect: {}))
                                DropdownMenuItemView(isSelecting: $isSelecting, selectiontitle: $selectionTitle, selectionId: $selectedRowId, item: .init(id: 5, title: "티키 타카 데이", onSelect: {}))
                                DropdownMenuItemView(isSelecting: $isSelecting, selectiontitle: $selectionTitle, selectionId: $selectedRowId, item: .init(id: 6, title: "직군 모임2", onSelect: {}))
                                DropdownMenuItemView(isSelecting: $isSelecting, selectiontitle: $selectionTitle, selectionId: $selectedRowId, item: .init(id: 7, title: "해커톤", onSelect: {}))
                                DropdownMenuItemView(isSelecting: $isSelecting, selectiontitle: $selectionTitle, selectionId: $selectedRowId, item: .init(id: 8, title: "최종 발표", onSelect: {}))
                                
                            }
                        }
                    }
                    
                    Spacer()
                        .frame(height: 4)
                }
            }
            .frame(width: UIScreen.screenWidth - 40, height: isSelecting ? UIScreen.screenHeight * 0.25 : 48)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(lineWidth: 1)
                    .foregroundColor(isSelecting ? Color.basicGray5 : Color.basicGray4 )
            )
            .padding(EdgeInsets(top: 12, leading: 20, bottom: 12, trailing: 20))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical)
        .cornerRadius(5)
        .onTapGesture {
            isSelecting.toggle()
        }
    }
    
}


