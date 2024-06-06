//
//  CoreMemberMainView.swift
//  DDDAttendance
//
//  Created by 서원지 on 6/6/24.
//

import SwiftUI
import ComposableArchitecture


struct CoreMemberMainView: View {
    @Bindable var store: StoreOf<CoreMember>
    
    init(store: StoreOf<CoreMember>) {
        self.store = store
    }
    
    var body: some View {
        ZStack {
            Color.basicBlack
                .edgesIgnoringSafeArea(.all)
            
            ScrollView(.vertical) {
                
                titleView()
                
                attendanceStatus()
                Spacer()
            }
        }
    }
}

extension CoreMemberMainView {
    
    fileprivate func titleView() -> some View {
        VStack {
            Spacer()
                .frame(height: UIScreen.screenHeight*0.02)
            
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
    
    fileprivate func attendanceStatus() -> some View {
        LazyVStack {
            Spacer()
                .frame(height: UIScreen.screenHeight * 0.03)
            
            LazyHStack {
                ScrollView(.horizontal) {
                    
                }
            }
            
            
        }
    }
    
}


#Preview {
    CoreMemberMainView(store: Store(initialState: CoreMember.State(), reducer: {
        CoreMember()
    }))
}
