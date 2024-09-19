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
                CoreMemberMainView(store: store.scope(state: \.coreStore, action: \.coreStoreAction)) 
            }
            .onAppear {
                store.send(.inner(.appearPath))
                store.send(.async(.fetchMember))
                store.send(.async(.fetchEvent))
            }
            
        } destination: { swithStore in
            switch swithStore.case {
            case let .coreMember(coreStore):
                CoreMemberMainView(store: coreStore)
                    .navigationBarBackButtonHidden()
                
            case let .qrCode(qrCodeStore):
                QrCodeView(store: qrCodeStore) {
                    store.send(.inner(.removePath))
                }
                .navigationBarBackButtonHidden()
                
            case let .scheduleEvent(scheduleEventStore):
                ScheduleEventView(store: scheduleEventStore) {
                    store.send(.inner(.removePath))
                }
                .navigationBarBackButtonHidden()
                
            case let .snsLogin(snsLoginStore):
                SNSLoginViewRepresentable(store: snsLoginStore)
                    .navigationBarBackButtonHidden()
                
            case let .mangeProfile(mangeProfileStore):
                MangerProfileView(store: mangeProfileStore) {
                    store.send(.inner(.removePath))
                }
                .navigationBarBackButtonHidden()
                
            case let .createByApp(creatByAppStore):
                CreatByAppView(store: creatByAppStore) {
                    store.send(.inner(.removePath))
                }
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
