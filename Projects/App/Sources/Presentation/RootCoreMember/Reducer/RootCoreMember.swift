//
//  RootCoreMember.swift
//  DDDAttendance
//
//  Created by 서원지 on 6/11/24.
//

import Foundation

import Service

import ComposableArchitecture
import KeychainAccess

@Reducer
public struct RootCoreMember {
    public init() {}
    
    @ObservableState
    public struct State: Equatable {
        public init() {}
        
        var path: StackState<Path.State> = .init()
    }
    
    public enum Action : BindableAction {
        case path(StackAction<Path.State, Path.Action>)
        case binding(BindingAction<State>)
        case removePath
        case appearPath
        case removeAllPath
    }
    
    @Reducer(state: .equatable)
    public enum Path {
        case coreMember(CoreMember)
        case qrCode(QrCode)
        case editEvent(EditEvent)
        case snsLogin(SNSLoginViewReducer)
    }
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
                
            case .appearPath:
                state.path.append(.coreMember(.init()))
                return .none
                
            case let .path(action):
                switch action {
                case .element(id: _, action: .coreMember(.presentQrcode)):
                    let userID = try? Keychain().get("userID")
                    Log.debug("키체인", userID)
                    state.path.append(.qrCode(.init(userID: userID ?? "")))
                    
                case .element(id: _, action: .coreMember(.presentEditEvent)):
                    state.path.append(.editEvent(.init()))
                    
                case .element(id: _, action: .editEvent(.creatEvents)):
                    state.path.append(.coreMember(.init()))
                    
                case .element(id: _, action: .coreMember(.tapLogOut)):
                    state.path.append(.snsLogin(.init()))
                    
                default:
                    break
                }
                return .none
                
                
            case .removePath:
                state.path.removeLast()
                return .none
                
            case .removeAllPath:
                state.path.removeAll()
                return .none
                
            case  .binding(_):
                return .none
            }
        }
        .forEach(\.path, action: \.path)
    }
}

