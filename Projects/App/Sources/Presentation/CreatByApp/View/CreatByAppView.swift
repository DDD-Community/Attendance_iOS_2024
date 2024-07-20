//
//  CreatByAppView.swift
//  DDDAttendance
//
//  Created by 서원지 on 7/21/24.
//

import SwiftUI
import ComposableArchitecture

import DesignSystem

public struct CreatByAppView: View {
    @Bindable var store: StoreOf<CreatByApp>
    var backAction: () -> Void = { }
    
    
    public init(
        store: StoreOf<CreatByApp>,
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
                
                NavigationBackButton(buttonAction: backAction)
                
                createByAppTitle()
                
                createByAppRoleType(roleType: .design, userName: store.creatByAppDesigner)
                
                createByAppRoleType(roleType: .iOS, userName: store.creatByAppiOS)
                
                createByAppRoleType(roleType: .android, userName: store.creatByAppAndroid)
                
                Spacer()
                
            }
        }
    }
}
 
extension CreatByAppView {
    
    @ViewBuilder
    private func createByAppTitle() -> some View {
        VStack {
            Spacer()
                .frame(height: 22)
            
            HStack {
                Text(store.creatByAppTitle)
                    .pretendardFont(family: .SemiBold, size: 24)
                    .foregroundStyle(Color.basicWhite)
                
                Spacer()
            }
            
            
            Spacer()
                .frame(height: 8)
        }
        .padding(.horizontal, 24)
    }
    
    @ViewBuilder
    private func createByAppRoleType(roleType: SelectPart, userName: String) -> some View {
        VStack(alignment: .leading) {
            Spacer()
                .frame(height: 16)
            
            HStack {
                Text(roleType.attendanceListDesc)
                    .pretendardFont(family: .SemiBold, size: 14)
                    .foregroundStyle(Color.gray600)
                
                Spacer()
            }
            
            Spacer()
                .frame(height: 12)
            
            HStack {
                Text(userName)
                    .pretendardFont(family: .SemiBold, size: 24)
                    .foregroundColor(Color.basicWhite)
                
                Spacer()
            }
            
        }
        .padding(.horizontal, 24)
    }
}
