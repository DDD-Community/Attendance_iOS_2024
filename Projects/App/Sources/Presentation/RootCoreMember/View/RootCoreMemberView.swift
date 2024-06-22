//
//  RootCoreMemberView.swift
//  DDDAttendance
//
//  Created by 서원지 on 6/11/24.
//

import SwiftUI
import ComposableArchitecture

struct RootCoreMemberView: View {
    @Bindable var store: StoreOf<RootCoreMember>
    
    var body: some View {
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
            VStack {
                CoreMemberMainView(store: Store(initialState: CoreMember.State(), reducer: {
                    CoreMember()
                }))
            }
            .onAppear {
                store.send(.appearPath)
            }
            
        } destination: { swithStore in
            switch swithStore.case {
            case let .coreMember(coreStore):
                CoreMemberMainView(store: coreStore)
                    .navigationBarBackButtonHidden()
                
            case let .qrCode(qrCodeStore):
                QrCodeView(store: qrCodeStore) {
                    store.send(.removePath)
                }
                .navigationBarBackButtonHidden()
                
            case let .editEvent(editEventStore):
                EditEventView(store: editEventStore) {
                    store.send(.removePath)
                } 
                .navigationBarBackButtonHidden()
                
            case let .snsLogin(snsLoginStore):
                SNSLoginViewRepresentable(store: snsLoginStore)
                    .navigationBarBackButtonHidden()
            }
        }
    }
}

#Preview {
    RootCoreMemberView(store: Store(initialState: RootCoreMember.State(), reducer: {
        RootCoreMember()
    }))
}
