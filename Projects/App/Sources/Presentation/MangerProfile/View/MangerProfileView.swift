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
                
                
                NavigationBackButton(buttonAction: backAction)
                
                Spacer()
                
                
            }
        }
    }
}
