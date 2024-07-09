//
//  CoreMemberMainView.swift
//  DDDAttendance
//
//  Created by 서원지 on 6/6/24.
//

import SwiftUI
import ComposableArchitecture
import SDWebImageSwiftUI

struct CoreMemberMainView: View {
    @Bindable var store: StoreOf<CoreMember>
    
    
    init(store: StoreOf<CoreMember>) {
        self.store = store
    }
    
    var body: some View {
        ZStack {
            Color.basicBlack
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                
                navigationTrallingButton()
                
                titleView()
                
                selectAttendaceDate()
                
                attendanceStatus(selectPart: store.selectPart ?? .all)
                
                ScrollView(.vertical, showsIndicators: false) {
                    
                    selctAttendance(selectPart: store.selectPart ?? .all)
                    
                    Spacer()
                }
                .bounce(false)
                
            }
        }
        .sheet(item: $store.scope(state: \.destination?.makeEvent, action: \.destination.makeEvent)) { makeEvent in
            MakeEventView(store: makeEvent, completion:  {
                store.send(.view(.closePresntEventModal))
            })
                .frame(width: UIScreen.screenWidth)
                .presentationDetents([.height(UIScreen.screenHeight * 0.65)])
                .presentationCornerRadius(20)
                .presentationDragIndicator(.hidden)
                .presentationBackground(Color.basicBlackDimmed)
        }
        
        .task {
            store.send(.async(.fetchMember))
            store.send(.async(.fetchAttenDance))
            store.send(.view(.appearSelectPart(selectPart: .all)))
            store.send(.async(.fetchCurrentUser))
            store.send(.async(.observeAttendance))
            store.send(.async(.observeAttendanceCheck))
        }
        .onChange(of: store.attendaceModel) { oldValue , newValue in
            store.send(.async(.updateAttendanceModel(newValue)))
        }
        
        .gesture(
            DragGesture()
                .onEnded { value in
                    if value.translation.width < -UIScreen.screenWidth * 0.02 {
                        store.send(.view(.swipeNext))
                        store.send(.async(.upDateFetchMember(selectPart: store.selectPart ?? .all)))
                        
                    } else if value.translation.width > UIScreen.screenWidth * 0.02 {
                        store.send(.view(.swipePrevious))
                        store.send(.async(.upDateFetchMember(selectPart: store.selectPart ?? .all)))
                    }
                }
        )
    }
}

extension CoreMemberMainView {
    
    @ViewBuilder
    fileprivate func titleView() -> some View {
        VStack {
            HStack {
                Text(store.headerTitle)
                    .foregroundStyle(Color.basicWhite)
                    .font(.system(size: 30))
                    .fontDesign(.rounded)
                    .bold(true)
                
                Spacer()
            }
            .padding(.horizontal, 20)
        }
    }
    
    @ViewBuilder
    fileprivate func attendanceStatus(selectPart: SelectPart) -> some View {
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
                                    .background(store.selectPart == item ? Color.famous : Color.clear)
                                    .cornerRadius(12)
                                    .frame(width: UIScreen.main.bounds.width * 0.23, height: 30)
                                    .overlay(
                                        Text(item.desc)
                                            .foregroundColor(.white)
                                            .pretendardFont(family: .Bold, size: 16)
                                    )
                                    .onTapGesture {
                                        store.send(.view(.selectPartButton(selectPart: item)))
                                        store.send(.async(.upDateFetchMember(selectPart: item)))
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
    
    @ViewBuilder
    fileprivate func selctAttendance(selectPart: SelectPart) -> some View {
        LazyVStack {
            switch store.selectPart {
            case .all:
                if store.combinedAttendances.isEmpty {
                   
                    VStack {
                        Spacer()
                            .frame(height: UIScreen.screenHeight * 0.2)
                        
                        AnimatedImage(name: "DDDLoding.gif", isAnimating: .constant(true))
                            .resizable()
                            .scaledToFit()
                            .frame(width: 200, height: 200)
                        
                        Spacer()
                    }
                    
                } else {
                    attendanceMemberList(roleType: selectPart)
                }
                
            default:
                if store.combinedAttendances.isEmpty {
                   
                    VStack {
                        Spacer()
                            .frame(height: UIScreen.screenHeight * 0.2)
                        
                        AnimatedImage(name: "DDDLoding.gif", isAnimating: .constant(true))
                            .resizable()
                            .scaledToFit()
                            .frame(width: 200, height: 200)
                        
                        Spacer()
                    }
                    
                } else {
                    attendanceMemberList(roleType: selectPart)
                }
            }
        }
    }
    
    @ViewBuilder
    fileprivate func attendanceMemberList(roleType: SelectPart) -> some View {
        Spacer()
            .frame(height: 20)
        
        VStack {
            switch roleType {
            case .all:
                ScrollView(.vertical ,showsIndicators: false) {
                    ForEach(store.combinedAttendances, id: \.self) { item in
                        attendanceList(name: "\(item.name) \(item.generation) 기", roleType: item.roleType.desc, attendanceType: item.status)
                            .onAppear {
                                store.send(.view(.fetchAttanceTypeImage(attenace: item.status)))
                            }
                        
                        Spacer()
                    }
                }
                
            default:
                ForEach(store.combinedAttendances.filter { $0.roleType == roleType}, id: \.self) { item in
                    attendanceList(name: "\(item.name) \(item.generation) 기", roleType: item.roleType.desc, attendanceType: item.status)
                        .onAppear {
                            store.send(.view(.fetchAttanceTypeImage(attenace: item.status)))
                        }
                    Spacer()
                }
            }
        }
    }
    
    @ViewBuilder
    fileprivate func attendanceList(name: String,  roleType: String, attendanceType: AttendanceType) -> some View {
        VStack {
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.basicWhite, style: .init(lineWidth: 1))
                .frame(height: 60)
                .overlay {
                    HStack {
                        VStack(alignment: .leading) {
                            Spacer()
                                .frame(height: 12)
                            Text(name)
                                .foregroundColor(.basicWhite)
                                .pretendardFont(family: .SemiBold, size: 20)
                            
                            Spacer()
                                .frame(height: 4)
                            
                            Text(roleType)
                                .foregroundColor(.basicWhite)
                                .pretendardFont(family: .Regular, size: 16)
                            
                            Spacer()
                                .frame(height: 12)
                            
                        }
                        
                        Spacer()
                        
                    
                        Image(systemName: store.attenaceTypeImageName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .foregroundColor(store.attenaceTypeColor)
                        
                    }
                    .padding(.horizontal, 20)
                }
            
            Spacer()
                .frame(height: 8)
        }
        .padding(.horizontal , 20)
        
    }
    
    @ViewBuilder
    fileprivate func selectAttendaceDate() -> some View {
        VStack {
            Spacer()
                .frame(height: 20)
            
            HStack {
                
                DatePicker(selection: $store.selectDate.sending(\.selectDate), 
                           in: ...Date(), displayedComponents: [.date]) { }
                .frame(width: UIScreen.screenWidth * 0.35)
                .environment(\.locale, Locale(identifier: "ko_KR"))
                .labelsHidden()
               
                Spacer()
                
            }
            Spacer()
                .frame(height: 20)
            
        }
        .frame(height:  30)
    }
    
    @ViewBuilder
    fileprivate func navigationTrallingButton() -> some View {
        VStack {
            Spacer()
                .frame(height: UIScreen.screenHeight * 0.025)
            
            HStack {
                Image(systemName: store.editEventImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .foregroundColor(.basicWhite)
                    .onTapGesture {
                        store.send(.navigation(.presentEditEvent))
                    }
                
                
                Spacer()
                
                Image(systemName: store.qrcodeImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .foregroundColor(.basicWhite)
                    .onTapGesture {
                        store.send(.navigation(.presentQrcode))
                    }
                
                Spacer()
                    .frame(width: 12)
                
                Image(systemName: store.eventImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .foregroundColor(.basicWhite)
                    .onTapGesture {
                        store.send(.view(.presntEventModal))
                    }
                
                Spacer()
                    .frame(width: 12)
                
                Image(systemName: store.logOutImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .foregroundColor(.basicWhite)
                    .onTapGesture {
                        store.send(.navigation(.tapLogOut))
                    }
            }
            
            Spacer()
                .frame(height: UIScreen.screenHeight * 0.02)
        }
        .padding(.horizontal, 20)
    }
    
}


#Preview {
    CoreMemberMainView(store: Store(initialState: CoreMember.State(), reducer: {
        CoreMember()
    }))
}
