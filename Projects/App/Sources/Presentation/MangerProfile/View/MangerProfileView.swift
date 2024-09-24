//
//  MangerProfileView.swift
//  DDDAttendance
//
//  Created by 서원지 on 7/17/24.
//

import SwiftUI

import DesignSystem

import ComposableArchitecture

public struct MangerProfileView: View {
    @Bindable var store: StoreOf<MangerProfile>
    var backAction: () -> Void
    
    public init(
        store: StoreOf<MangerProfile>,
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
                    store.send(.navigation(.presentCreatByApp))
                }, image: .pet)
                
                
                mangerProfile()
                
                logoutButton()
                
            }
            .task {
                store.send(.async(.fetchMangeProfile))
                store.send(.async(.fetchUser))
            }
        }
    }
}

extension MangerProfileView {
    
    @ViewBuilder
    private func mangerProfile() -> some View {
        VStack {
            ForEach(store.attendaceModel.filter{ $0.memberId == store.user?.uid }, id: \.memberId) { data in
                Spacer()
                    .frame(height: 8)
                
                managerProfileName(name: data.name, memberType: data.memberType)
                
                mangerTextComponent(
                    title: store.mangerProfileRoleType,
                    subTitle: data.roleType.attendanceListDesc,
                    mangingTeam: "",
                    isManging: false,
                    isGeneration: false
                )
                
                mangerTextComponent(
                    title: store.mangerProfileManging,
                    subTitle: data.manging.mangingDesc,
                    mangingTeam: "",
                    isManging: false,
                    isGeneration: false
                )
                
                mangerTextComponent(
                    title: store.mangerProfileGeneration,
                    subTitle: "\(data.generation)",
                    mangingTeam: "",
                    isManging: false,
                    isGeneration: true
                )
            }
        }
    }
    
    
    @ViewBuilder
    private func managerProfileName(
        name: String,
        memberType: MemberType
    ) -> some View {
        LazyVStack {
            Spacer()
                .frame(height: 30)
            
            HStack {
                Text("\(name)\(store.mangeProfileName)")
                    .pretendardFont(family: .SemiBold, size: 24)
                    .foregroundStyle(Color.basicWhite)
                Spacer()
                    .frame(width: 8)
                
                if memberType == .coreMember {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray800)
                        .frame(width: 54, height: 24)
                        .overlay {
                            Text(memberType.memberDesc)
                                .pretendardFont(family: .Regular, size: 14)
                                .foregroundStyle(Color.basicBlue)
                        }
                }
                
                
                Spacer()
                
            }
            
        }
        .padding(.horizontal, 24)
    }

    @ViewBuilder
    private func mangerTextComponent(
        title: String,
        subTitle: String,
        mangingTeam: String,
        isManging: Bool,
        isGeneration: Bool
    ) -> some View {
    LazyVStack {
        Spacer()
            .frame(height: 16)
        
        HStack {
            Text(title)
                .pretendardFont(family: .SemiBold, size: 14)
                .foregroundColor(Color.gray600)
            
            Spacer()
        }
        
        Spacer()
            .frame(height: 8)
        
        if isManging {
            HStack {
                Text("\(subTitle) / \(mangingTeam)팀")
                    .pretendardFont(family: .SemiBold, size: 24)
                    .foregroundColor(Color.basicWhite)
                
                Spacer()
            }
        } else if isGeneration {
            HStack {
                Text("\(subTitle)기")
                    .pretendardFont(family: .SemiBold, size: 24)
                    .foregroundColor(Color.basicWhite)
                
                Spacer()
            }
        } else {
            HStack {
                Text(subTitle)
                    .pretendardFont(family: .SemiBold, size: 24)
                    .foregroundColor(Color.basicWhite)
                
                Spacer()
            }
        }
    }
    .padding(.horizontal, 24)
    
}
    
    @ViewBuilder
    private func logoutButton() -> some View {
        VStack {
            Spacer()
            
            HStack(alignment: .center) {
                Text(store.logoutText)
                    .pretendardFont(family: .Regular, size: 16)
                    .foregroundStyle(Color.gray300)
                    .underline(true, color: Color.gray300)
            }
            .onTapGesture {
                store.send(.navigation(.tapLogOut))
            }
            
            Spacer()
                .frame(height: 24)
        }
        .padding(.horizontal, 24)
    }
    
    
}
