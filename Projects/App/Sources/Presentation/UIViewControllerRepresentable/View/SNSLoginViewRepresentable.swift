//
//  SNSLoginViewRepresentable.swift
//  DDDAttendance
//
//  Created by 서원지 on 6/21/24.
//

import SwiftUI
import ComposableArchitecture
import DesignSystem

public struct SNSLoginViewRepresentable: View {
    @Bindable var store: StoreOf<SNSLoginViewReducer>
    
    public var body: some View {
        ZStack {
            Color.basicBlack
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                SNSLoginViewControllerRepresentable()
            }
        }
    }
}

#Preview {
    SNSLoginViewControllerRepresentable()
}
