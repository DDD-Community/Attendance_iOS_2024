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
    var test: FireStoreRepository = FireStoreRepository()
    
    init(store: StoreOf<CoreMember>) {
        self.store = store
    }
    
    var body: some View {
        ZStack {
            Color.black
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                titleView()
                
                attendanceStatus(selectPart: store.selectPart ?? .all)
                
                selctAttendance(selectPart: store.selectPart ?? .all)
                
                ScrollView(.vertical, showsIndicators: false) {
                    Spacer()
                }
            }
        }
        .task {
            store.send(.fetchMember)
        }
        .onAppear {
            store.send(.appearSelectPart(selectPart: .all))
        }
        .gesture(
            DragGesture()
                .onEnded { value in
                    if value.translation.width < -UIScreen.screenWidth * 0.02 {
                        store.send(.swipeNext)
                    } else if value.translation.width > UIScreen.screenWidth * 0.02 {
                        store.send(.swipePrevious)
                    }
                }
        )
        
        
    }
    
    private func registerDependencies() {
        Task {
            await AppDIContainer.shared.registerDependencies()
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
    
    fileprivate func attendanceStatus(selectPart: SelectPart) -> some View {
        LazyVStack {
                    Spacer()
                        .frame(height: UIScreen.main.bounds.height * 0.03)
                    
                    ScrollViewReader { proxy in
                        HStack {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    ForEach(SelectPart.allCases, id: \.self) { item in
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(store.selectPart == item ? Color.gray : Color.white, lineWidth: 1)
                                            .background(store.selectPart == item ? Color.famous : Color.clear)
                                            .cornerRadius(12)
                                            .frame(width: UIScreen.main.bounds.width * 0.23, height: 30)
                                            .overlay(
                                                Text(item.desc)
                                                    .foregroundColor(.white)
                                                    .font(.system(size: 16))
                                                    .bold()
                                            )
                                            .onTapGesture {
                                                store.send(.selectPartButton(selectPart: item))
                                            }
                                            .id(item)
                                    }
                                }
                            }
                        }
                        .onChange(of: store.selectPart, { oldValue, newValue in
                            proxy.scrollTo(newValue, anchor: .center)
                        })
                    }
                    
                    Spacer()
                        .frame(height: 20)
            
        }
    }
    
    fileprivate func selctAttendance(selectPart: SelectPart) -> some View {
        
        LazyVStack {
            switch store.selectPart {
            case .all:
                Spacer()
                    .frame(height: UIScreen.screenHeight * 0.2)
                
                Text("\(store.selectPart?.desc ?? "")")
                    .font(.system(size: 20))
                    .foregroundColor(.white)
                
                attendanceList()
                
                Spacer()
                
            case .web:
                
                Spacer()
                    .frame(height: UIScreen.screenHeight * 0.4)
                
                Text("\(store.selectPart?.desc ?? "")")
                    .font(.system(size: 20))
                    .foregroundColor(.white)
                
                
            case .iOS:
                Spacer()
                    .frame(height: UIScreen.screenHeight * 0.4)
                
                Text("\(store.selectPart?.desc ?? "")")
                    .foregroundColor(.white)
                
            default:
                EmptyView()
            }
        }
    }
    
    fileprivate func attendanceMemberList() -> some View {
        
    }
    
    
    fileprivate func attendanceList() -> some View {
        VStack {
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.basicWhite, style: .init(lineWidth: 1))
                .frame(height: 60)
                .overlay {
                    HStack {
                        
                        VStack {
                            Spacer()
                                .frame(height: 12)
                            Text("DDD")
                                .foregroundColor(.basicWhite)
                            
                            Spacer()
                                .frame(height: 4)
                            
                            Text("\(store.selectPart?.desc ?? "")")
                                .foregroundColor(.basicWhite)
                            
                            Spacer()
                                .frame(height: 12)
                            
                        }
                        
                        Spacer()
                        
                        Image(systemName: "checkmark")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .foregroundColor(Color.primaryOrange)
                        
                    }
                    .padding(.horizontal, 20)
                }
            
        }
        .padding(.horizontal , 20)
        
    }
}


#Preview {
    CoreMemberMainView(store: Store(initialState: CoreMember.State(), reducer: {
        CoreMember()
    }))
}
