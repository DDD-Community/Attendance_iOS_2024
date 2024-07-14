//
//  EditEventModalView.swift
//  DDDAttendance
//
//  Created by 서원지 on 6/21/24.
//

import SwiftUI
import ComposableArchitecture
import PopupView

public struct EditEventModalView: View {
    @Bindable var store: StoreOf<EditEventModal>
    var completion: ()  -> Void
    
    public init(
        store: StoreOf<EditEventModal>,
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
                editEventModalTitle()
                
                selectEventDropDownMenu()
                
                if store.isSelectEditDropDownMenu {
                    
                    Spacer()
                        .frame(height: UIScreen.screenHeight * 0.15)
                    
                } else {
                    selectDateAndTime()
                    
                    Spacer()
                        .frame(height: 10)
                    
                }
                
                editEvenetButton()
                
                Spacer()
                
            }
            .popup(isPresented: $store.selectEditEventDatePicker.sending(\.selectEditEventDatePicker)) {
                CustomPopUPDatePickerView(selectDate: $store.editEventStartTime)
            } customize: {
                $0
                    .backgroundColor(Color.basicBlack.opacity(0.4))
                    .type(.floater(verticalPadding: UIScreen.screenHeight * 0.2))
                    .position(.bottom)
                    .animation(.smooth)
                    .closeOnTapOutside(true)
                    .closeOnTap(true)
                
            }
        }
        
        .onTapGesture {
            store.send(.view(.tapCloseDropDown))
        }
    }
}


extension EditEventModalView {
    
    @ViewBuilder
    fileprivate func editEventModalTitle() -> some View {
        VStack {
            Spacer()
                .frame(height: UIScreen.screenHeight * 0.03)
            
            HStack {
                Text(store.editEventModalTitle)
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
                Text(store.editEventReasonTitle)
                    .foregroundStyle(Color.basicWhite)
                    .pretendardFont(family: .Bold, size: 18)
                
                Spacer()
            }
            .padding(.horizontal, 20)
            
            CustomDropdownMenu(
                isSelecting: $store.isSelectEditDropDownMenu,
                selectionTitle: $store.editMakeEventReason
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
                            
                            Text(store.editEventStartTime.formattedDate(date: store.editEventStartTime))
                                .pretendardFont(family: .Regular, size: 14)
                                .foregroundColor(Color.basicWhite)
                                .onTapGesture {
                                    store.send(.view(.selectEditEventDatePOPUP(isBool: store.selectEditEventDatePicker)))
                                }
                            
                            Spacer()
                        }
                        
                        Spacer()
                        
                    }
                
                Spacer()
                    .frame(width: 12)
                
                DatePicker(selection: $store.editEventStartTime.sending(\.selectMakeEventDate), in: ...Date() ,displayedComponents: .hourAndMinute, label: {})
                    .frame(width: UIScreen.screenWidth * 0.2)
                    .offset(x: -UIScreen.screenWidth * 0.01)
                
                Spacer()
            }
            
            Spacer()
            
        }
        .padding(.horizontal, 20)
    }
    
    @ViewBuilder
    private func editEvenetButton() -> some View {
        VStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.basicGray1BG.opacity(0.3))
                .frame(height: 48)
                .padding(.horizontal, 20)
                .overlay {
                    Text("이벤트 수정")
                        .pretendardFont(family: .SemiBold, size: 20)
                        .foregroundColor(Color.basicWhite)
                }
                .disabled(store.editMakeEventReason != "이번주 세션 이벤트를 선택 해주세요!")
                .onTapGesture {
                    if store.editMakeEventReason != "이번주 세션 이벤트를 선택 해주세요!" {
                        store.send(.async(.saveEvent))
                        completion()
                    }
                }
        }
    }
}
