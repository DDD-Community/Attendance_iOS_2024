//
//  EditEventModalView.swift
//  DDDAttendance
//
//  Created by 서원지 on 6/21/24.
//

import SwiftUI
import ComposableArchitecture
import PopupView
import DesignSystem

public struct EditEventModalView: View {
    @Bindable var store: StoreOf<EditEventModal>
    var completion: () -> Void
    var selectMakeEventReason: String?
    
    public init(
        store: StoreOf<EditEventModal>,
        completion: @escaping () -> Void,
        selectMakeEventReason: String? = nil
    ) {
        self.store = store
        self.completion = completion
        self.selectMakeEventReason = selectMakeEventReason
    }
    
    public var body: some View {
        ZStack {
            Color.gray800
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                editEventTitle()
                
                selectEventDropDownMenu()
                
                if !store.isSelectEditDropDownMenu {
                    selectDateAndTimeText()
                        .offset(y: -40)
                        
                    Spacer()
                        .frame(height: 20)
                    
                    selectDateAndTime(text: "시작")
                        .offset(y: -40)
                        
                    
                    Spacer()
                        .frame(height: 16)
                    
                    selectDateAndTime(text: "종료")
                        .offset(y: -40)

                }
                
                Spacer()
                    
                editEventButton()
                    .padding(.bottom, -30)
            }
            .padding(.top, -20)
        }
        .onTapGesture {
            store.send(.view(.tapCloseDropDown))
        }
    }
}

extension EditEventModalView {
    
    @ViewBuilder
    private func editEventTitle() -> some View {
        VStack {
            Spacer()
                .frame(height: 44)
            
            HStack {
                Text(store.editEventModalTitle)
                    .pretendardFont(family: .Bold, size: 20)
                    .foregroundStyle(Color.basicWhite)
                
                Spacer()
            }
            .padding(.horizontal, 24)
            
            Spacer()
                .frame(height: 16)
        }
    }
    
    @ViewBuilder
    private func selectEventDropDownMenu() -> some View {
        VStack {
            HStack {
                Text(store.selectMakeEventTiltle)
                    .foregroundStyle(Color.gray400)
                    .pretendardFont(family: .Medium, size: 18)
                
                Spacer()
            }
            .padding(.horizontal, 24)
            
            CustomDropdownMenu(
                isSelecting: $store.isSelectEditDropDownMenu,
                selectionTitle: $store.editMakeEventReason
            )
            .offset(y: -24)
        }
    }
    
    @ViewBuilder
    private func selectDateAndTimeText() -> some View {
        HStack {
            Text(store.selectMakeEventTiltle)
                .foregroundStyle(Color.gray400)
                .pretendardFont(family: .Medium, size: 18)
            
            Spacer()
        }
        .padding(.horizontal, 24)
    }
    
    @ViewBuilder
    private func selectDateAndTime(text: String) -> some View {
        VStack {
            HStack {
                Text(text)
                    .pretendardFont(family: .Regular, size: 16)
                    .foregroundStyle(Color.gray600)
                
                Spacer().frame(width: 8)
                
                RoundedRectangle(cornerRadius: 5)
                    .fill(Color.basicBlack.opacity(0.4))
                    .frame(width: UIScreen.main.bounds.width * 0.3, height: 34)
                    .overlay {
                        if text == "시작" {
                            CustomDatePickerShortText(selectedDate: $store.editEventStartTime.sending(\.selectMakeEventDate), isTimeDate: false)
                        } else if text == "종료" {
                            CustomDatePickerShortText(selectedDate: $store.editEventEndTime.sending(\.selectMakeEventEndDate), isTimeDate: false)
                        }
                        
                    }
                
                Spacer().frame(width: 6)
                
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.basicBlack.opacity(0.4))
                    .frame(width: UIScreen.main.bounds.width * 0.24, height: 34)
                    .overlay {
                        if text == "시작" {
                            CustomDatePickerShortText(selectedDate: $store.editEventStartTime.sending(\.selectMakeEventDate), isTimeDate: true)
                        } else if text == "종료" {
                            CustomDatePickerShortText(selectedDate: $store.editEventEndTime.sending(\.selectMakeEventEndDate), isTimeDate: true)
                        }
                    }
                
                Spacer()
            }
        }
        .padding(.horizontal, 24)
    }
    
    @ViewBuilder
    private func editEventButton() -> some View {
        Rectangle()
            .fill(store.editMakeEventReason == "이벤트 선택" || store.editMakeEventReason == selectMakeEventReason ? Color.gray600 : Color.basicWhite)
            .frame(height: 90)
            .overlay {
                VStack {
                    Spacer().frame(height: 18)
                    
                    Text("수정")
                        .pretendardFont(family: .SemiBold, size: 20)
                        .foregroundColor(store.editMakeEventReason == "이벤트 선택" || store.editMakeEventReason == selectMakeEventReason ? Color.gray400 : Color.basicBlack)
                    
                    Spacer()
                }
            }
            .disabled(store.editMakeEventReason == "이벤트 선택")
            .onTapGesture {
                if store.editMakeEventReason != "이벤트 선택" {
                    store.send(.async(.editEvent))
                    completion()
                }
            }
    }
}
