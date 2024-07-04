//
//  MakeEventView.swift
//  DDDAttendance
//
//  Created by 서원지 on 6/15/24.
//

import SwiftUI

import ComposableArchitecture
import PopupView

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
            Color.basicBlackDimmed
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                makeEventTitle()
                
                selectEventDropDownMenu()
                
                if store.isSelectDropDownMenu {
                    
                    Spacer()
                        .frame(height: UIScreen.screenHeight * 0.15)
                    
                } else {
                    selectDateAndTime()
                    
                    Spacer()
                        .frame(height: 10)
                    
                }
                

                makeEvenetButton()
                
                Spacer()
            }
            .popup(isPresented: $store.selectMakeEventDatePicker.sending(\.selectMakeEventDatePicker)) {
                CustomPopUPDatePickerView(selectDate:  $store.selectMakeEventDate.sending(\.selectMakeEventDate))
            } customize: {
                $0
                    .backgroundColor(Color.basicBlack.opacity(0.4))
                    .type(.floater(verticalPadding: UIScreen.screenHeight * 0.2))
                    .position(.bottom)
                    .animation(.spring)
                    .closeOnTapOutside(true)
                    .closeOnTap(true)
                
            }
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
                .frame(height: UIScreen.screenHeight * 0.03)
            
            HStack {
                Text(store.makeEventTitle)
                    .pretendardFont(family: .Bold, size: 20)
                    .foregroundColor(.basicWhite)
                
                Spacer()
            }
            .padding(.horizontal ,20)
            
            Spacer()
                .frame(height: 20)
        }
    }
    
    @ViewBuilder
    private func selectEventDropDownMenu() -> some View{
        VStack {
            HStack {
                Text(store.selectMakeEventReasonTitle)
                    .foregroundStyle(Color.basicWhite)
                    .pretendardFont(family: .Bold, size: 18)
                
                Spacer()
            }
            .padding(.horizontal, 20)
            
            CustomDropdownMenu(
                isSelecting: $store.isSelectDropDownMenu,
                selectionTitle: $store.selectMakeEventReason
            )
            .offset(y: -10)
        }
    }
    
    @ViewBuilder
    private func selectDateAndTime() -> some View {
        VStack {
            HStack {
                Text(store.selectMakeEventTiltle)
                    .foregroundStyle(Color.basicWhite)
                    .pretendardFont(family: .Bold, size: 18)
                
                Spacer()
            }
            
            Spacer()
                .frame(height: 20)
            
            HStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.basicBlue200.opacity(0.4))
                    .frame(width: UIScreen.screenWidth * 0.45 , height: 35)
                    .overlay {
                            HStack {
                                Spacer()
                                    .frame(width: 12)
                                
                                Text(store.selectMakeEventDate.formattedDate(date: store.selectMakeEventDate))
                                    .pretendardFont(family: .Regular, size: 14)
                                    .foregroundColor(Color.basicWhite)
                                    .onTapGesture {
                                        store.send(.view(.selectMakeEventDatePicker(isBool: store.selectMakeEventDatePicker)))
                                    }
                                
                                Spacer()
                            }
                            
                            Spacer()

                    }
                
                Spacer()
                    .frame(width: 12)
                
                
                DatePicker(selection: $store.selectMakeEventDate.sending(\.selectMakeEventDate), in: ...Date() ,displayedComponents: .hourAndMinute, label: {})
                    .frame(width: UIScreen.screenWidth * 0.2)
                    .offset(x: -UIScreen.screenWidth * 0.01)
                
                Spacer()
            }
            
            Spacer()
            
        }
        .padding(.horizontal, 20)
    }
    
    @ViewBuilder
    private func makeEvenetButton() -> some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color.basicGray1BG.opacity(0.3))
            .frame(height: 48)
            .padding(.horizontal, 20)
            .overlay {
                Text("이벤트 생성")
                    .pretendardFont(family: .SemiBold, size: 20)
                    .foregroundColor(Color.basicWhite)
            }
            .disabled(store.selectMakeEventReason != "이번주 세션 이벤트를 선택 해주세요!")
            .onTapGesture {
                if store.selectMakeEventReason != "이번주 세션 이벤트를 선택 해주세요!" {
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
