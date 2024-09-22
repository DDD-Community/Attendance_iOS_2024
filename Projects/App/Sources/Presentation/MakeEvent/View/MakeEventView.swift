//
//  MakeEventView.swift
//  DDDAttendance
//
//  Created by 서원지 on 6/15/24.
//

import SwiftUI

import ComposableArchitecture
import PopupView

import DesignSystem

public struct MakeEventView: View {
    @Bindable var store: StoreOf<MakeEvent>
    var completion: () -> Void
    
    public init(
        store: StoreOf<MakeEvent>,
        completion: @escaping () -> Void
    ) {
        self.store = store
        self.completion = completion
    }
    
    public var body: some View {
        ZStack {
            Color.gray800
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                makeEventTitle()
                
                selectEventDropDownMenu()
                
                if !store.isSelectDropDownMenu {
                    selectDateAndTimeText()
                        .offset(y: -40)
                    
                    Spacer().frame(height: 20)
                    
                    selectDateAndTime(text: "시작")
                        .offset(y: -40)
                    
                    Spacer().frame(height: 16)
                    
                    selectDateAndTime(text: "종료")
                        .offset(y: -40)
                }
                
                Spacer()
                    
                makeEventButton()
                    .padding(.bottom, -30)
            }
            .padding(.top, -20)
        }
        .onTapGesture {
            store.send(.view(.tapCloseDropDown))
        }
        .task {
            store.send(.async(.observeEvent))
        }
    }
}

extension MakeEventView {
    
    @ViewBuilder
    private func makeEventTitle() -> some View {
        VStack {
            Spacer()
                .frame(height: 44)
            
            HStack {
                Text(store.makeEventTitle)
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
                Text(store.selectMakeEventReasonTitle)
                    .foregroundStyle(Color.gray400)
                    .pretendardFont(family: .Medium, size: 18)
                
                Spacer()
            }
            .padding(.horizontal, 24)
            
            CustomDropdownMenu(
                isSelecting: $store.isSelectDropDownMenu,
                selectionTitle: $store.selectMakeEventReason
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
                            CustomDatePickerShortText(selectedDate: $store.selectMakeEventDate.sending(\.selectMakeEventDate), isTimeDate: false)
                        } else if text == "종료" {
                            CustomDatePickerShortText(selectedDate: $store.selectMakeEventEndDate.sending(\.selectMakeEventEndDate), isTimeDate: false)
                        }
                    }
                
                Spacer().frame(width: 6)
                
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.basicBlack.opacity(0.4))
                    .frame(width: UIScreen.main.bounds.width * 0.24, height: 34)
                    .overlay {
                        if text == "시작" {
                            CustomDatePickerShortText(selectedDate: $store.selectMakeEventDate.sending(\.selectMakeEventDate), isTimeDate: true)
                        } else if text == "종료" {
                            CustomDatePickerShortText(selectedDate: $store.selectMakeEventEndDate.sending(\.selectMakeEventEndDate), isTimeDate: true)
                        }
                    }
                
                Spacer()
            }
        }
        .padding(.horizontal, 24)
    }
    
    @ViewBuilder
    private func makeEventButton() -> some View {
        Rectangle()
            .fill(store.selectMakeEventReason == "이벤트 선택" ? Color.gray600 : Color.basicWhite)
            .frame(height: 90)
            .overlay {
                VStack {
                    Spacer().frame(height: 18)
                    
                    Text("등록")
                        .pretendardFont(family: .SemiBold, size: 20)
                        .foregroundColor(store.selectMakeEventReason == "이벤트 선택" ? Color.gray400 : Color.basicBlack)
                    
                    Spacer()
                }
            }
            .disabled(store.selectMakeEventReason == "이벤트 선택")
            .onTapGesture {
                if store.selectMakeEventReason != "이벤트 선택" {
                    store.send(.view(.makeEventToFireBase(eventName: store.selectMakeEventReason)))
                    completion()
                }
            }
    }
}


#Preview {
    MakeEventView(store: Store(initialState: MakeEvent.State(), reducer: {
        MakeEvent()
    }), completion: {})
}
