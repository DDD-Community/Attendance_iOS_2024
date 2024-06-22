//
//  EditEventView.swift
//  DDDAttendance
//
//  Created by 서원지 on 6/19/24.
//

import SwiftUI
import SDWebImageSwiftUI
import ComposableArchitecture

public struct EditEventView: View {
    @Bindable var store: StoreOf<EditEvent>
    var backAction: () -> Void
    
    init(
        store: StoreOf<EditEvent>,
        backAction: @escaping () -> Void
    ) {
        self.store = store
        self.backAction = backAction
        
    }
    
    public var body: some View {
        ZStack {
            Color.basicBlack
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Spacer()
                    .frame(height: 20)
                
                CustomNavigationBar(backAction: backAction) {
                    store.send(.presntEventModal)
                }
                
                editEventNavigationTitle()
                
                ScrollView(.vertical, showsIndicators: false) {
                    if store.eventModel == [ ] {
                        createEvent()
                    } else {
                        editEventListView()
                    }
                }
                .bounce(false)
            }
            .onTapGesture {
                store.isEditing.toggle()
            }
        }
        .task {
            store.send(.fetchEvent)
            await Task.sleep(seconds: 1)
            store.send(.observeEvent)
        }
        .onChange(of: store.eventModel) { oldValue , newValue in
            store.send(.updateEventModel(newValue))
            
        }
        .sheet(item: $store.scope(state: \.destination?.makeEvent, action: \.destination.makeEvent)) { makeStore in
            MakeEventView(store: makeStore) {
                store.send(.closePresntEventModal)
            }
            .presentationDetents([.height(UIScreen.screenHeight * 0.65)])
            .presentationCornerRadius(20)
            .presentationDragIndicator(.hidden)
            .presentationBackground(Color.basicBlackDimmed)
        }
        
        .sheet(item: $store.scope(state: \.destination?.editEventModal, action: \.destination.editEventModal)) { editEventModalStore in
            EditEventModalView(store: editEventModalStore, completion: {
                store.send(.closeEditEventModal)
            })
            .presentationDetents([.height(UIScreen.screenHeight * 0.65)])
            .presentationCornerRadius(20)
            .presentationDragIndicator(.hidden)
            .presentationBackground(Color.basicBlackDimmed)
        }
        
    }
}

extension EditEventView {
    
    @ViewBuilder
    private func editEventNavigationTitle() -> some View {
        LazyVStack {
            Spacer()
                .frame(height: 20)
            
            HStack {
                Text(store.naivgationTitle)
                    .pretendardFont(family: .Bold, size: 30)
                    .foregroundColor(.basicWhite)
                
                Spacer()
            }
            
            Spacer()
                .frame(height: UIScreen.screenHeight * 0.02)
            
        }
        .padding(.horizontal, 20)
    }
    
    @ViewBuilder
    private func editEventListView() -> some View {
        VStack {
            ForEach(store.eventModel, id: \.self) { item in
                HStack {
                    editEventList(
                        name: item.name,
                        startTime: "\(item.startTime.formattedDateTimeToString(date: item.startTime)) \(item.startTime.formattedTime(date: item.startTime))",
                        endTime: "\(item.endTime.formattedDateTimeToString(date: item.endTime)) \(item.endTime.formattedTime(date: item.endTime))")
                    .offset(x: item == store.selectedEvent && store.isEditing ? -10 : 0)
                    .gesture(
                        DragGesture()
                            .onChanged { gesture in
                                withAnimation(.easeOut) {
                                    if gesture.translation.width < -40 {
                                        self.store.offset = gesture.translation.width
                                    }
                                }
                            }
                            .onEnded { _ in
                                withAnimation(.spring()) {
                                    if self.store.offset < -40 {
                                        self.store.selectedEvent = item
                                        self.store.isEditing = true
                                    }
                                    self.store.offset = 0
                                }
                            }
                    )
                    .onTapGesture {
                        store.send(.tapEditEvent(eventName:  item.name, eventID:  item.id ?? "", eventStartDate: item.startTime))
                    }
                    
                    if store.isEditing && item == store.selectedEvent {
                        VStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.statusWarning)
                                .frame(width: 80, height: 80)
                                .offset(x: -10)
                                .overlay {
                                    HStack {
                                        Spacer()
                                            .frame(width: 12)
                                        
                                        Image(systemName: store.deleteImage)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 40, height: 40)
                                            .onTapGesture {
                                                store.send(.deleteEvent)
                                                store.isEditing = false
                                            }
                                            .offset(x: -10)
                                        
                                        Spacer()
                                            .frame(width: 12)
                                    }
                                }
                        }
                        
                        Spacer()
                            .frame(width: 20)
                    }
                }
            }
        }
        .animation(.smooth, value: store.isEditing)
    }
    
    @ViewBuilder
    private func editEventList(
        name: String,
        startTime: String,
        endTime: String
    ) -> some View {
        HStack {
            VStack {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white, style: .init(lineWidth: 2))
                    .frame(height: 80)
                    .overlay {
                        HStack {
                            VStack(alignment: .leading) {
                                Spacer()
                                    .frame(height: 12)
                                Text(name)
                                    .foregroundColor(.white)
                                    .font(.system(size: 20, weight: .semibold))
                                
                                Spacer()
                                    .frame(height: 4)
                                
                                Text(" 시작 시간 : \(startTime)")
                                    .foregroundColor(.white)
                                    .font(.system(size: 16, weight: .regular))
                                
                                Spacer()
                                    .frame(height: 4)
                                
                                Text(" 종료 시간 : \(endTime)")
                                    .foregroundColor(.white)
                                    .font(.system(size: 16, weight: .regular))
                                
                                Spacer()
                                    .frame(height: 12)
                            }
                            
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                    }
                
                Spacer()
                    .frame(height: 10)
            }
            .padding(.horizontal, 20)
            
        }
    }
    
    @ViewBuilder
    private func createEvent() -> some View {
        VStack {
            Spacer()
                .frame(height: UIScreen.screenHeight * 0.1)
            
            AnimatedImage(name: "DDDLoding.gif", isAnimating: .constant(true))
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)
            
            Spacer()
                .frame(height: UIScreen.screenHeight * 0.3)
            
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.basicBlue200.opacity(0.4))
                .frame(height: 48)
                .padding(.horizontal, 20)
                .overlay {
                    Text("이벤트를 추가 해주세요")
                        .pretendardFont(family: .SemiBold, size: 20)
                        .foregroundColor(.basicWhite)
                }
                .onTapGesture {
                    store.send(.presntEventModal)
                }
            
            Spacer()
        }
    }
}


