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
                
                ScrollView(.vertical) {
                    
                    selctAttendance(selectPart: store.selectPart ?? .all)
                    
                    Spacer()
                }
                .scrollIndicators(.hidden)
                .onAppear {
                    UIScrollView.appearance().bounces = false
                }
            }
        }
      
        .task {
            store.send(.async(.fetchMember))
            store.send(.async(.fetchCurrentUser))
        }
        
        .onAppear {
            store.send(.async(.fetchAttenDance))
            store.send(.view(.appearSelectPart(selectPart: .all)))
        }
        
        .onChange(of: store.attendanceCheckInModel) { oldValue, newValue in
            store.send(.async(.fetchAttendanceDataResponse(.success(newValue))))
        }
        
        .gesture(
            DragGesture()
                .onEnded { value in
                    if value.translation.width < -UIScreen.screenWidth * 0.02 {
                        store.send(.view(.swipeNext))
                        store.send(.async(.upDateFetchAttandanceMember(selectPart: store.selectPart ?? .all)))
                        
                    } else if value.translation.width > UIScreen.screenWidth * 0.02 {
                        store.send(.view(.swipePrevious))
                        store.send(.async(.upDateFetchAttandanceMember(selectPart: store.selectPart ?? .all)))
                        
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
                
                Image(asset: store.mangerProfilemage)
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
                    .frame(width: 20, height: 20)
                    .foregroundStyle(Color.gray400)
                    .onTapGesture {
                        store.send(.navigation(.presentQrcode))
                    }
                
                Spacer()
                    .frame(width: 6)
                
                Image(asset: store.eventImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .foregroundStyle(Color.gray400)
                    .onTapGesture {
                        store.send(.navigation(.presentSchedule))
                    }
                
                Spacer()
                    .frame(width: 8)
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
                    VStack {
                        Spacer()
                            .frame(height: 12)
                        
                        CustomDatePIckerText(
                            selectedDate: $store.selectDate.sending(\.selectDate)
                        )
                        
                        Spacer()
                            .frame(height: 12)
                    }
            }
        }
    }
    
    @ViewBuilder
    fileprivate func attendanceStatus(
        selectPart: SelectPart
    ) -> some View {
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
                                            .frame(width: 14, height: 20)
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
                if store.attendaceMemberModel.isEmpty  && store.attendaceMemberModel ==  [] {
                   
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
                    }
                    
                } else {
                    attendanceMemberList(roleType: selectPart)
                }
                
            default:
                if store.attendanceCheckInModel.isEmpty  && store.attendanceCheckInModel ==  [] {
                   
                    VStack {
                        Spacer()
                            .frame(height: 16)
                        
                        
                        attendanceMemberCount(count: store.attendanceCount)
                        
                        Spacer()
                            .frame(height: UIScreen.screenHeight * 0.15)
                       
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
        
        VStack(spacing: .zero) {
            attendanceMemberCount(count: store.attendanceCount)
            
            switch roleType {
            case .all:
                ScrollView(.vertical, showsIndicators: false) {
                    ForEach(store.attendaceMemberModel, id: \.memberId) { item in
                        AttendanceStatusText(
                            name: item.name,
                            generataion: "\(item.generation)",
                            roleType: item.roleType.attendanceListDesc,
                            nameColor: Color.basicWhite.opacity(0.4),
                            roleTypeColor: Color.basicWhite.opacity(0.4),
                            generationColor: Color.basicWhite.opacity(0.4),
                            backGroudColor: Color.gray800.opacity(0.4)
                        )
                        .id(item.memberId)
                    }
                }
                .onAppear {
                    UIScrollView.appearance().bounces = false
                }

                
            default:
                ForEach(store.attendanceCheckInModel.filter { $0.roleType == roleType}, id: \.id) { item in
                    AttendanceStatusText(
                        name: item.name,
                        generataion: "\(item.generation)",
                        roleType: item.roleType.desc,
                        nameColor: getBackgroundColor(
                            for: item.id,
                            generationColor: (item.status == .run || item.status == nil ? Color.gray600 : store.attenaceNameColor) ?? Color.gray600,
                            matchingAttendances: item,
                            isNameColor: true
                        ),
                        roleTypeColor: getBackgroundColor(
                            for: item.id,
                            generationColor: (item.status == .run || item.status == nil ? Color.gray600 : store.attenaceRoleTypeColor) ?? Color.gray600 ,
                            matchingAttendances: item,
                            isRoletTypeColor: true
                        ),
                        generationColor: getBackgroundColor(
                            for: item.id,
                            generationColor: (item.status == .run || item.status == nil ? Color.gray600 : store.attenaceGenerationColor) ?? Color.gray800,
                            matchingAttendances: item,
                            isGenerationColor: true
                        ),
                        backGroudColor: getBackgroundColor(
                            for: item.id,
                            generationColor: (item.status == .run || item.status == nil ? .gray800 : store.attenaceBackGroudColor) ?? Color.gray800,
                            matchingAttendances: item,
                            isBackground: true
                        )
                    )
                    .id(item.id)

                }
                .onAppear {
                    UIScrollView.appearance().bounces = false
                }
            }
        }
    }
    
    func getBackgroundColor(
            for memberId: String,
            generationColor: Color,
            matchingAttendances: AttendanceDTO,
            isBackground: Bool = false,
            isNameColor: Bool = false,
            isGenerationColor: Bool = false,
            isRoletTypeColor: Bool = false
        ) -> Color {
            let matchingAttendancesList = store.attendanceCheckInModel.filter { $0.id == memberId }
            if matchingAttendancesList.count == store.attendanceCheckInModel.count {
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
                    return Color.gray800
                }
            } else  if matchingAttendancesList.count != store.attendanceCheckInModel.count {
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
                return Color.gray800
            }
        }

    @ViewBuilder
    private func attendanceMemberCount(count:  Int) -> some View {
        VStack {
            HStack {
                Text("\(count) / \(store.attendaceMemberModel.count) 명")
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
