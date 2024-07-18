//
//  CoreMemberMainView.swift
//  DDDAttendance
//
//  Created by 서원지 on 6/6/24.
//

import SwiftUI
import ComposableArchitecture
import SDWebImageSwiftUI

import DesignSystem
import Model

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
                
                attendaceHeaderView()
                
                selectAttendaceDate()
                
                attendanceStatus(selectPart: store.selectPart ?? .all)
                
                ScrollView(.vertical, showsIndicators: false) {
                    
                    selctAttendance(selectPart: store.selectPart ?? .all)
                    
                    Spacer()
                }
                .bounce(false)
                
            }
        }
      
        .task {
            store.send(.async(.fetchMember))
            store.send(.async(.fetchAttenDance))
            store.send(.view(.appearSelectPart(selectPart: .all)))
            store.send(.async(.fetchCurrentUser))
            store.send(.async(.observeAttendance))

        }
//        .onChange(of: store.attendaceModel) { oldValue , newValue in
//            store.send(.async(.updateAttendanceModel(newValue)))
//        }
        
//        .onChange(of: store.combinedAttendances, { oldValue, newValue in
//            store.send(.async(.updateAttendanceTypeModel(newValue)))
//            
//        })
        
        
        .gesture(
            DragGesture()
                .onEnded { value in
                    if value.translation.width < -UIScreen.screenWidth * 0.02 {
                        store.send(.view(.swipeNext))
//                        store.send(.async(.upDateFetchAttandanceMember(selectPart: store.selectPart ?? .all)))
//                        getAttendanceCount()
                        
                    } else if value.translation.width > UIScreen.screenWidth * 0.02 {
                        store.send(.view(.swipePrevious))
//                        store.send(.async(.upDateFetchAttandanceMember(selectPart: store.selectPart ?? .all)))
//                        getAttendanceCount()
                        
                    }
                }
        )
    }
}

extension CoreMemberMainView {
    
    @ViewBuilder
    fileprivate func navigationTrallingButton() -> some View {
        VStack {
            Spacer()
                .frame(height: UIScreen.screenHeight * 0.025)
            
            HStack {
                Spacer()
                
                Image(systemName: store.mangerProfilemage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .foregroundStyle(Color.gray400)
                    .onTapGesture {
                        store.send(.navigation(.presentMangerProfile))
                    }
                
                Spacer()
                    .frame(width: 6)
                
                Image(asset: store.qrcodeImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .foregroundStyle(Color.gray400)
                    .onTapGesture {
                        store.send(.navigation(.presentQrcode))
                    }
                
                Spacer()
                    .frame(width: 6)
                
                Image(asset: store.eventImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .foregroundStyle(Color.gray400)
                    .onTapGesture {
                        store.send(.navigation(.presentSchedule))
                    }
            }
            
            Spacer()
                .frame(height: UIScreen.screenHeight * 0.02)
        }
        .padding(.horizontal, 20)
    }
    
    @ViewBuilder
    fileprivate func attendaceHeaderView() -> some View {
        VStack {
            HStack {
                Text(store.headerTitle)
                    .pretendardFont(family: .SemiBold, size: 24)
                    .foregroundStyle(Color.basicWhite)
                
                Spacer()
            }
            .padding(.horizontal, 24)
        }
    }
    
    @ViewBuilder
    fileprivate func selectAttendaceDate() -> some View {
        VStack {
            Spacer()
                .frame(height: 24)
            
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.gray800.opacity(0.4))
                .frame(height: 40)
                .padding(.horizontal, 20)
                .overlay {
                    CustomDatePIckerText(selectedDate: $store.selectDate.sending(\.selectDate))
                    
            }
        }
    }
    
    @ViewBuilder
    fileprivate func attendanceStatus(selectPart: SelectPart) -> some View {
        LazyVStack {
            Spacer()
                .frame(height: 16)
            
            ScrollViewReader { proxy in
                HStack {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(SelectPart.allCases, id: \.self) { item in
                                HStack {
                                    Spacer()
                                        .frame(width: 16)
                                    
                                    Text(item.attendanceListDesc)
                                        .pretendardFont(family: .Bold, size: 16)
                                        .foregroundColor(store.selectPart == item ? Color.basicWhite : Color.gray600)
                                    
                                    Spacer()
                                        .frame(width: 16)
                                    
                                    if item != .server {
                                        Divider()
                                            .background(Color.gray800)
                                            .frame(width: 16, height: 20)
                                    }
                                        
                                }
                                .onTapGesture {
                                    store.send(.view(.selectPartButton(selectPart: item)))
                                    store.send(.async(.upDateFetchAttandanceMember(selectPart: item)))
                                }
                                .id(item)
                            }
                        }
                        .padding(.horizontal, 10)
                    }
                }
                .onChange(of: store.selectPart, { oldValue, newValue in
                    proxy.scrollTo(newValue, anchor: .center)
                })
            }
            
        }
    }
    
   
    @ViewBuilder
    fileprivate func selctAttendance(selectPart: SelectPart) -> some View {
        LazyVStack {
            switch store.selectPart {
            case .all:
                if store.attendaceModel.isEmpty  && store.attendaceModel ==  [] {
                   
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
                if store.attendaceModel.isEmpty  && store.attendaceModel ==  [] {
                   
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
            .frame(height: 16)
        
        VStack {
            attendanceMemberCount(count: store.attendanceCount)
            
            switch roleType {
            case .all:
                ScrollView(.vertical, showsIndicators: false) {
                    ForEach(store.attendaceModel, id: \.self) { item in
                        AttendanceStatusText(
                            name: item.name,
                            generataion: "\(item.generation)",
                            roleType: item.roleType.attendanceListDesc,
                            nameColor: getBackgroundColor(
                                for: item.memberId ?? "",
                                generationColor: (item.status == .run || item.status == nil ? Color.gray600 : store.attenaceNameColor) ?? Color.gray600,
                                matchingAttendances: item,
                                isNameColor: true
                            ),
                            roleTypeColor: getBackgroundColor(
                                for: item.memberId ?? "",
                                generationColor: (item.status == .run || item.status == nil ? Color.gray600 : store.attenaceRoleTypeColor) ?? Color.gray600 ,
                                matchingAttendances: item,
                                isRoletTypeColor: true
                            ),
                            generationColor: getBackgroundColor(
                                for: item.memberId ?? "",
                                generationColor: (item.status == .run || item.status == nil ? Color.gray600 : store.attenaceGenerationColor) ?? Color.gray800,
                                matchingAttendances: item,
                                isGenerationColor: true
                            ),
                            backGroudColor: getBackgroundColor(
                                for: item.memberId ?? "",
                                generationColor: (item.status == .run || item.status == nil ? Color.gray800 : store.attenaceBackGroudColor) ?? Color.gray800,
                                matchingAttendances: item,
                                isBackground: true
                            )
                        )
                        .id(item.memberId)
                        .onTapGesture(perform: {
                            print("tap \(item.status)")
                        })
                        .onAppear {
                            store.send(.async(.fetchMember))
                            if item.status == .present || item.status == .late {
//                                getAttendanceCount()
//                                store.send(.view(.updateAttendanceCount(count:  store.attendanceCount)))
                            }
                        }
                        Spacer()
                    }
                }

                
            default:
                ForEach(store.attendaceModel.filter { $0.roleType == roleType}, id: \.self) { item in
                    AttendanceStatusText(
                        name: item.name,
                        generataion: "\(item.generation)",
                        roleType: item.roleType.desc,
                        nameColor: getBackgroundColor(
                            for: item.memberId ?? "",
                            generationColor: (item.status == .run || item.status == nil ? Color.gray600 : store.attenaceNameColor) ?? Color.gray600,
                            matchingAttendances: item,
                            isNameColor: true
                        ),
                        roleTypeColor: getBackgroundColor(
                            for: item.memberId ?? "",
                            generationColor: (item.status == .run || item.status == nil ? Color.gray600 : store.attenaceRoleTypeColor) ?? Color.gray600 ,
                            matchingAttendances: item,
                            isRoletTypeColor: true
                        ),
                        generationColor: getBackgroundColor(
                            for: item.memberId ?? "",
                            generationColor: (item.status == .run || item.status == nil ? Color.gray600 : store.attenaceGenerationColor) ?? Color.gray800,
                            matchingAttendances: item,
                            isGenerationColor: true
                        ),
                        backGroudColor: getBackgroundColor(
                            for: item.memberId ?? "",
                            generationColor: (item.status == .run || item.status == nil ? Color.gray800 : store.attenaceBackGroudColor) ?? Color.gray800,
                            matchingAttendances: item,
                            isBackground: true
                        )
                    )
                    .id(item.memberId)
                    .onAppear{
                        store.send(.async(.fetchMember))
                        if item.roleType == roleType {
//                            store.send(.view(.updateAttendanceCount(count:  store.attendanceCount)))
                        } else if item.status == .present {
//                            store.send(.view(.updateAttendanceCount(count:  store.attendanceCount)))
                        } else {
//                            store.send(.view(.updateAttendanceCount(count:  store.attendanceCount)))
                        }
                    }

                    Spacer()
                }
            }
        }
    }
    
    func getBackgroundColor(
            for memberId: String,
            generationColor: Color,
            matchingAttendances: Attendance,
            isBackground: Bool = false,
            isNameColor: Bool = false,
            isGenerationColor: Bool = false,
            isRoletTypeColor: Bool = false
        ) -> Color {
            let matchingAttendancesList = store.combinedAttendances.filter { $0.memberId == memberId }
            // Handle the case where all combinedAttendances count matches
            if matchingAttendancesList.count == store.combinedAttendances.count {
                if let backgroundColor = matchingAttendancesList.first?.backgroundColor(
                    isBackground: isBackground,
                    isNameColor: isNameColor,
                    isGenerationColor: isGenerationColor,
                    isRoletTypeColor: isRoletTypeColor
                ) {
                    if isNameColor {
                        return generationColor == backgroundColor ? generationColor : backgroundColor
                    } else if isGenerationColor {
                        return generationColor == backgroundColor ? generationColor : backgroundColor
                    } else if isRoletTypeColor {
                        return generationColor == backgroundColor ? generationColor : backgroundColor
                    } else if backgroundColor == generationColor {
                        return generationColor
                    } else {
                        return backgroundColor
                    }
                } else {
                    return .gray // Return gray if the background color does not match the generation color
                }
            } else  if matchingAttendancesList.count != store.combinedAttendances.count {
                if let backgroundColor = matchingAttendancesList.first?.backgroundColor(
                    isBackground: isBackground,
                    isNameColor: isNameColor,
                    isGenerationColor: isGenerationColor,
                    isRoletTypeColor: isRoletTypeColor
                ) {
                    if isNameColor {
                        return generationColor == backgroundColor ? generationColor : backgroundColor
                    } else if isGenerationColor {
                        return generationColor == backgroundColor ? generationColor : backgroundColor
                    } else if isRoletTypeColor {
                        return generationColor == backgroundColor ? generationColor : backgroundColor
                    } else if isBackground {
                        return generationColor == backgroundColor ? generationColor : backgroundColor
                    } else {
                        return backgroundColor
                    }
                } else {
                    return generationColor
                }
            } else {
                return .gray
            }
        }

    func getAttendanceCount() {
        var newAttendanceCount = 0

        for index in store.attendaceModel.indices {
            let attendance = store.attendaceModel[index]
            
            if attendance.status == .present {
                newAttendanceCount += 1
            } else if attendance.status == .late {
                newAttendanceCount -= 1
            }
        }
        
        store.attendanceCount = newAttendanceCount
    }
    
    @ViewBuilder
    private func attendanceMemberCount(count:  Int) -> some View {
        VStack {
            HStack {
                Text("\(count) / \(store.attendaceModel.count) 명")
                    .pretendardFont(family: .Regular, size: 16)
                    .foregroundStyle(Color.basicWhite)
                
                Spacer()
                
            }
            
            Spacer()
                .frame(height: 16)
            
        }
        .padding(.horizontal ,24)
    }
    
}
