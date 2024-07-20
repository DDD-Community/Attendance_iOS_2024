//
//  EditEventView.swift
//  DDDAttendance
//
//  Created by 서원지 on 6/19/24.
//

import SwiftUI

import SDWebImageSwiftUI
import ComposableArchitecture
import Collections

import DesignSystem


public struct ScheduleEventView: View {
    @Bindable var store: StoreOf<ScheduleEvent>
    var backAction: () -> Void
    
    init(
        store: StoreOf<ScheduleEvent>,
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
                    .frame(height: 16)
                
                CustomNavigationBar(backAction: backAction) {
                    store.send(.view(.presntEventModal))
                }
                
                scheduleEventNavigationTitle()
                
                ScrollView(.vertical, showsIndicators: false) {
                    if store.eventModel == [ ] {
                        createEvent()
                    } else {
                        editEventListView()
                    }
                }
                .bounce(false)
            }
        }
        .task {
            store.send(.async(.fetchEvent))
            await Task.sleep(seconds: 1)
            store.send(.async(.observeEvent))
        }
        
        .onChange(of: store.eventModel) { oldValue , newValue in
            store.send(.async(.updateEventModel(newValue)))
            
        }
        
        .sheet(item: $store.scope(state: \.destination?.makeEvent, action: \.destination.makeEvent)) { makeStore in
            MakeEventView(store: makeStore) {
                store.send(.view(.closePresntEventModal))
            }
            .presentationDetents([.height(UIScreen.screenHeight * 0.65)])
            .presentationCornerRadius(20)
            .presentationDragIndicator(.visible)
            
        }
        
        .sheet(item: $store.scope(state: \.destination?.editEventModal, action: \.destination.editEventModal)) { editEventModalStore in
            EditEventModalView(store: editEventModalStore, completion: {
                store.send(.view(.closeEditEventModal))
            }, selectMakeEventReason: store.editMakeEventResaon)
            .presentationDetents([.height(UIScreen.screenHeight * 0.65)])
            .presentationCornerRadius(20)
            .presentationDragIndicator(.visible)
        }
        
        .confirmationDialog($store.scope(state: \.confirmationDialog, action: \.confirmationDialog))
        .alert($store.scope(state: \.alert, action: \.alert))
               
    }
}

extension ScheduleEventView {
    
    @ViewBuilder
    private func scheduleEventNavigationTitle() -> some View {
        LazyVStack {
            Spacer()
                .frame(height: 14)
            
            HStack {
                Text("\(store.generation)\(store.naivgationTitle)")
                    .pretendardFont(family: .SemiBold, size: 24)
                    .foregroundStyle(Color.basicWhite)
                
                Spacer()
            }
            
            Spacer()
                .frame(height: 24)
            
        }
        .padding(.horizontal, 24)
    }
    
    @ViewBuilder
    private func editEventListView() -> some View {
        VStack {
            let groupedEvents = OrderedDictionary(grouping: store.eventModel) { data in
                return data.startTime.extractDate(date: data.startTime)
            }
            
            ForEach(groupedEvents.keys.sorted(), id: \.self) { month in
                VStack(alignment: .leading) {
                    HStack {
                        Text(month)
                            .foregroundStyle(Color.gray600)
                            .pretendardFont(family: .SemiBold, size: 14)
                    }
                    
                    Spacer()
                        .frame(height: 16)
                        
                    
                    ForEach(groupedEvents[month] ?? [], id: \.self) { item in
                        scheduleEventList(
                            eventName: item.name,
                            startTime: "\(item.startTime.formattedDateTimeToString(date: item.startTime)) \(item.startTime.formattedTime(date: item.startTime))",
                            endTime: "\(item.endTime.formattedDateTimeToString(date: item.endTime)) \(item.endTime.formattedTime(date: item.endTime))", completion: {
                                store.send(.view(.confirmationDialogButtonTapped(
                                    eventName: item.name,
                                    eventID: item.id ?? "",
                                    eventStartDate: item.startTime)
                                ))
                            })
                    }
                    
                }
            }
            .padding(.horizontal, 24)
        }
    }
    
    @ViewBuilder
    private func scheduleEventList(
        eventName: String,
        startTime: String,
        endTime: String,
        completion: @escaping () -> Void
    ) -> some View {
        VStack {
            HStack {
                Rectangle()
                    .fill(Color.gray800)
                    .frame(width: 4, height: 88)
                
                Spacer()
                    .frame(width: 16)
                
                VStack(alignment: .leading) {
                    Spacer()
                        .frame(height: 10)
                    
                    HStack {
                        Text(eventName)
                            .pretendardFont(family: .Bold, size: 20)
                            .foregroundStyle(Color.basicWhite)
                        
                        Spacer()
                        
                        Image(systemName: store.deleteImage)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 10, height: 24)
                            .foregroundStyle(Color.gray400)
                            .rotationEffect(.degrees(90))
                            .onTapGesture {
                                completion()
                            }
                    
                    }
                   
                    Spacer()
                        .frame(height: 14)
                    
                    Text("시작 시간 : \(startTime)")
                        .pretendardFont(family: .Regular, size: 14)
                        .foregroundStyle(Color.gray400)
                    
                    Spacer()
                        .frame(height: 8)
                    
                    Text("종료 시간 : \(endTime)")
                        .pretendardFont(family: .Regular, size: 14)
                        .foregroundStyle(Color.gray400)
                    
                    Spacer()
                        .frame(height: 8)
                }
                
                Spacer()
                
            }
            
            Spacer()
                .frame(height: 16)
        }
    }
    
    @ViewBuilder
    private func createEvent() -> some View {
        VStack {
            Spacer()
                .frame(height: UIScreen.screenHeight * 0.2)
           
            Image(asset: .logo)
                .resizable()
                .scaledToFit()
                .frame(width: 64, height: 72)
            
            Spacer()
                .frame(height: 16)
            
            Text(store.notEventText)
                .pretendardFont(family: .Regular, size: 16)
                .foregroundStyle(Color.gray800)
            
            Spacer()
                .frame(height: UIScreen.screenHeight * 0.35)
            
            Rectangle()
                .fill(Color.basicWhite)
                .frame(height: 90)
                .overlay {
                    VStack {
                        Spacer()
                            .frame(height: 18)
                        
                        Text("일정 등록")
                            .pretendardFont(family: .SemiBold, size: 20)
                            .foregroundStyle(Color.basicBlack)
                        
                    }
                }
                .onTapGesture {
                    store.send(.view(.presntEventModal))
                }
            
            Spacer()
        }
    }
}


