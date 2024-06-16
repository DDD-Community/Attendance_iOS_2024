//
//  MakeEventView.swift
//  DDDAttendance
//
//  Created by 서원지 on 6/15/24.
//

import SwiftUI

import ComposableArchitecture

public struct MakeEventView: View {
    @Bindable var store: StoreOf<MakeEvent>
    
    
    public init(store: StoreOf<MakeEvent>) {
        self.store = store
    }
    
    public var body: some View {
        ZStack {
            Color.basicBlackDimmed
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                makeEventTitle()
                
                selectEventDropDownMenu()
                
                if store.isSelectDropDownMenu {
                    
                } else {
                    selectAttentMemberType()
                }
                
                Spacer()
            }
        }
        .onTapGesture {
            store.send(.tapCloseDropDown)
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
                
                Spacer()
            }
            .padding(.horizontal ,20)
            
            Spacer()
                .frame(height: UIScreen.screenHeight * 0.01)
        }
    }
    
    @ViewBuilder
    private func selectEventDropDownMenu() -> some View{
        VStack {
            CustomDropdownMenu(
                isSelecting: $store.isSelectDropDownMenu,
                selectionTitle: $store.selectMakeEventReason
            )
        }
    }
    
    @ViewBuilder
    private func selectAttentMemberType() -> some View {
        LazyVStack {
            Spacer()
                .frame(height: UIScreen.main.bounds.height * 0.02)
            
            ScrollViewReader { proxy in
                HStack {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(SelectPart.allCases, id: \.self) { item in
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(store.selectPart == item ? Color.gray : Color.white, lineWidth: 1)
                                    .background(store.selectPart == item ? Color.basicWhite.opacity(0.7) : Color.clear)
                                    .cornerRadius(12)
                                    .frame(width: UIScreen.main.bounds.width * 0.23, height: 30)
                                    .overlay(
                                        Text(item.desc)
                                            .foregroundColor(.basicWhite)
                                            .pretendardFont(family: .Bold, size: 16)
                                    )
                                    .onTapGesture {
                                        store.send(.selectAttendaceMemberButton(selectPart: item))
                                       
                                    }
                                    .id(item)
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }
                .onChange(of: store.selectPart, { oldValue, newValue in
                    proxy.scrollTo(newValue, anchor: .center)
                })
            }
            
            Spacer()
                .frame(height: 20)
            
        }
    }
    
}

#Preview {
    MakeEventView(store: Store(initialState: MakeEvent.State(), reducer: {
        MakeEvent()
    }))
}
