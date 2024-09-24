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
                        Text(selectionTitle == "선택해주세요." ? "선택해주세요." : selectionTitle)
                            .pretendardFont(family: selectionTitle == "선택해주세요." ? .Medium : .Bold, size: 16)
                            .foregroundColor(selectionTitle == "선택해주세요." || selectionTitle == "이벤트 선택" ? Color.gray600 : Color.basicWhite)
                            .padding(.leading, 16)
                            .offset(y: isSelecting ? -10 : 0)
                            .onTapGesture {
                                isSelecting.toggle()
                                if !isSelecting {
                                    selectionTitle = "이벤트 선택"
                                }
                            }
                        Spacer()
                        
                        VStack {
                            Spacer()
                            Image(asset: isSelecting ? .arrow_up : .arrow_down)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 12, height: 8)
                                .foregroundColor(Color.gray600)
                                .offset(y: isSelecting ? -10 : 0)
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
                RoundedRectangle(cornerRadius: 5)
                    .stroke(Color.basicBlack.opacity(0.4), lineWidth: 1)
                    .foregroundColor(isSelecting ? Color.basicWhite : Color.gray600 )
                    .blur(radius: isSelecting ? 10 : 0)
            )
            .background(Color.basicBlack.opacity(0.4))
            .cornerRadius(5)
            
            .padding(EdgeInsets(top: 12, leading: 20, bottom: 12, trailing: 20))
        }
//        .frame(maxWidth: .infinity)
        .padding(.vertical)
        .cornerRadius(5)
        .onTapGesture {
            isSelecting.toggle()
        }
    }
}



