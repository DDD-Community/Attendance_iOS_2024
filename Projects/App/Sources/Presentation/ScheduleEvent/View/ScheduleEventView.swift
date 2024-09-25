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
                
                CustomNavigationBar(backAction: backAction, addAction: {
                    store.send(.view(.presntEventModal))
                }, image: .plus)
                
                scheduleEventNavigationTitle()
                
                if store.eventModel == [ ] {
                    createEvent()
                       
                } else  {
                    ScrollView(.vertical, showsIndicators: false) {
                        editEventListView()
                    }
                    .bounce(true)
                }
            }
        }
        .task {
            store.send(.view(.appear))
        }
        
        .onChange(of: store.eventModel) { oldValue , newValue in
            store.send(.async(.updateEventModel(newValue)))
            
        }
        
        .sheet(item: $store.scope(state: \.destination?.makeEvent, action: \.destination.makeEvent)) { makeStore in
            MakeEventView(store: makeStore) {
                store.send(.view(.closePresntEventModal))
                store.send(.async(.fetchEvent))
            }
            .presentationDetents([.height(UIScreen.screenHeight * 0.55)])
            .presentationCornerRadius(20)
            .presentationDragIndicator(.visible)
            
        }
        
        .sheet(item: $store.scope(state: \.destination?.editEventModal, action: \.destination.editEventModal)) { editEventModalStore in
            EditEventModalView(store: editEventModalStore, completion: {
                store.send(.view(.closeEditEventModal))
                store.send(.async(.fetchEvent))
            }, selectMakeEventReason: store.editMakeEventResaon)
            .presentationDetents([.height(UIScreen.screenHeight * 0.55)])
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
                        
                    
                    ForEach(groupedEvents[month] ?? [], id: \.id) { item in
                        scheduleEventList(
                            eventName: item.name,
                            startTime: "\(item.startTime.formattedDateTimeToString(date: item.startTime)) \(item.startTime.formattedTime(date: item.startTime))",
                            endTime: "\(item.endTime.formattedDateTimeToString(date: item.endTime)) \(item.endTime.formattedTime(date: item.endTime))", completion: {
                                store.send(.view(.confirmationDialogButtonTapped(
                                    eventName: item.name,
                                    eventID: item.id,
                                    eventStartDate: item.startTime,
                                    eventEndDate: item.endTime)
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
                        
                        VStack {
                            Image(asset: store.deleteImage)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 3, height: 13)
                                .onTapGesture {
                                    completion()
                                }
                        }
                        .frame(height: 24)
                    
                    }
                    .frame(height: 24)
                   
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
               
            
            RoundedRectangle(cornerRadius: 5)
                .fill(Color.basicWhite)
                .frame(height: 90)
                .padding(.bottom, -30)
            
                .overlay {
                    VStack {
                        Spacer()
                            .frame(height: 18)
                        
                        Text("일정 등록")
                            .pretendardFont(family: .SemiBold, size: 20)
                            .foregroundStyle(Color.basicBlack)
                        
                        Spacer()
                    }
                }
                .onTapGesture {
                    store.send(.view(.presntEventModal))
                }
            
//            Spacer()
            
        }
    }
}


