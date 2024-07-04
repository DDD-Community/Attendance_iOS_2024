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
        var eventModel: [DDDEvent] = []
        
        
    }
    
    public enum Action : BindableAction, FeatureAction {
        case path(StackAction<Path.State, Path.Action>)
        case binding(BindingAction<State>)
        case view(View)
        case async(AsyncAction)
        case inner(InnerAction)
        case navigation(NavigationAction)
    }
    
    @Reducer(state: .equatable)
    public enum Path {
        case coreMember(CoreMember)
        case qrCode(QrCode)
        case editEvent(EditEvent)
        case snsLogin(SNSLoginViewReducer)
    }
    
    public enum View {
        
    }
    
    public enum AsyncAction: Equatable {
        case fetchEvent
        case fetchEventResponse(Result<[DDDEvent], CustomError>)
    }
    
    public enum InnerAction: Equatable {
        case removePath
        case appearPath
        case removeAllPath
    }
    
    public enum NavigationAction: Equatable {
        
    }
    
    @Dependency(FireStoreUseCase.self) var fireStoreUseCase
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
                
            case let .path(action):
                switch action {
                case .element(id: _, action: .coreMember(.navigation(.presentQrcode))):
                    let userID = try? Keychain().get("userID")
                    let eventID = try? Keychain().getData("deleteEventIDs")
                    Log.debug("키체인", userID, eventID)
                    state.path.append(.qrCode(.init(userID: userID ?? "")))
                    
                case .element(id: _, action: .coreMember(.navigation(.presentEditEvent))):
                    state.path.append(.editEvent(.init(eventModel: state.eventModel)))
                    
                case .element(id: _, action: .editEvent(.creatEvents)):
                    state.path.append(.coreMember(.init()))
                    
                case .element(id: _, action: .coreMember(.navigation(.tapLogOut))):
                    state.path.append(.snsLogin(.init()))
                    
                default:
                    break
                }
                return .none
                                
            case  .binding(_):
                return .none
                
                //MARK: - ViewAction
            case .view(let View):
                switch View {
                    
                }
                
                //MARK: - AsyncAction
            case .async(let AsyncAction):
                switch AsyncAction {
                case .fetchEvent:
                    return .run { @MainActor send in
                        let fetchedDataResult = await Result {
                            try await fireStoreUseCase.fetchFireStoreData(
                                from: .event,
                                as: DDDEvent.self,
                                shouldSave: true
                            )
                        }
                        
                        switch fetchedDataResult {
                        case let .success(fetchedData):
                            send(.async(.fetchEventResponse(.success(fetchedData))))
                            await Task.sleep(seconds: 1)
                        case let .failure(error):
                            send(.async(.fetchEventResponse(.failure(CustomError.map(error)))))
                        }
                    }
                    
                case let .fetchEventResponse(fetchedData):
                    switch fetchedData {
                    case let .success(fetchedData):
                        state.eventModel = fetchedData
                    case let .failure(error):
                        Log.error("Error fetching data", error)
                    }
                    return .none
                }
                
                //MARK: - InnerAction
            case .inner(let InnerAction):
                switch InnerAction {
                case .appearPath:
                    state.path.append(.coreMember(.init()))
                    return .none
                    
                case .removePath:
                    state.path.removeLast()
                    return .none
                    
                case .removeAllPath:
                    state.path.removeAll()
                    return .none
                }
                
            case .navigation(let NavigationAction):
                switch NavigationAction {
                    
                }
            }
            
        }
        .forEach(\.path, action: \.path)
    }
}

