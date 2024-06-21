//
//  SNSLoginViewRepresentable.swift
//  DDDAttendance
//
//  Created by 서원지 on 6/21/24.
//

import SwiftUI
import ComposableArchitecture

public struct SNSLoginViewRepresentable: View {
    @Bindable var store: StoreOf<SNSLoginViewReducer>
    
    public var body: some View {
        SNSLoginViewControllerRepresentable()
    }
}

#Preview {
    SNSLoginViewControllerRepresentable()
}
