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

import Utill
import Model
import LogMacro

@Reducer
public struct RootCoreMember {
    public init() {}
    
    @ObservableState
    public struct State: Equatable {
        public init() {}
        
        var path: StackState<Path.State> = .init()
        var eventModel: [DDDEventDTO] = []
        var attendaceMemberModel : [MemberDTO] = []
        var coreStore = CoreMember.State()
        
    }
    
    public enum Action : BindableAction, FeatureAction {
        case coreStoreAction(CoreMember.Action)
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
        case scheduleEvent(ScheduleEvent)
        case snsLogin(SNSLoginViewReducer)
        case mangeProfile(MangerProfile)
        case createByApp(CreatByApp)
        
    }
    
    public enum View {
        case appearMember
    }
    
    public enum AsyncAction: Equatable {
        case fetchEvent
        case fetchEventResponse(Result<[DDDEventDTO], CustomError>)
        case fetchMember
        case fetchDataResponse(Result<[MemberDTO], CustomError>)
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
        Scope(state: \.coreStore, action: \.coreStoreAction) {
            CoreMember()
        }
        BindingReducer()
        Reduce { state, action in
            switch action {
                
            case let .path(action):
                switch action {
                case .element(id: _, action: .coreMember(.navigation(.presentQrcode))):
                    let userID = try? Keychain().get("userID")
                    let eventID = try? Keychain().getData("deleteEventIDs")
                    #logDebug("키체인", userID, eventID)
                    state.path.append(.qrCode(.init(userID: userID ?? "")))
                    
                case .element(id: _, action: .coreMember(.navigation(.presentSchedule))):
                    state.path.append(.scheduleEvent(.init(eventModel: state.eventModel, generation: state.attendaceMemberModel.first?.generation ?? .zero)))
                    
                case .element(id: _, action: .mangeProfile(.navigation(.tapLogOut))):
                    state.path.append(.snsLogin(.init()))
                    
                case .element(id: _, action: .coreMember(.navigation(.presentMangerProfile))):
                    state.path.append(.mangeProfile(.init()))
                    
                case .element(id: _, action: .mangeProfile(.navigation(.presentCreatByApp))):
                    state.path.append(.createByApp(.init()))
                    
                case .element(id: _, action: .qrCode(.navigation(.presentSchedule))):
                    state.path.append(.scheduleEvent(.init(eventModel: state.eventModel, generation: state.attendaceMemberModel.first?.generation ?? .zero)))
//                    return .run { send in
//                        await send(.async(.fetchMember))
//                    }
                    
                    
                default:
                    break
                }
                return .none
                                
            case  .binding(_):
                return .none
                
                
                //MARK: - ViewAction
            case .view(let View):
                switch View {
                case .appearMember:
                    return .run { @MainActor  send in
                        send(.coreStoreAction(.async(.fetchAttenDance)))
                        send(.coreStoreAction(.async(.fetchMember)))
                    }
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
                            let filterData = fetchedData.map { $0.toModel()}
                            send(.async(.fetchEventResponse(.success(filterData))))
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
                        #logError("Error fetching data", error)
                    }
                    return .none
                    
                case .fetchMember:
                    return .run { @MainActor send  in
                        let fetchedDataResult = await Result {
                            try await fireStoreUseCase.fetchFireStoreData(
                                from: .member,
                                as: Attendance.self,
                                shouldSave: false)
                        }
                        
                        switch fetchedDataResult {
                        case let .success(fetchedData):
                            let filterData = fetchedData
                                .filter { $0.memberType == .member && $0.name != "" }
                                .map { $0.toMemberDTO() }
                            send(.async(.fetchDataResponse(.success(filterData))))
                        case let .failure(error):
                            send(.async(.fetchDataResponse(.failure(CustomError.map(error)))))
                        }
                    }
                    
                case let .fetchDataResponse(fetchedData):
                    switch fetchedData {
                    case let .success(fetchedData):
                        let userID = try? Keychain().get("userID")
                        
                        state.attendaceMemberModel = fetchedData
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
                
            default:
                return .none
            }
            
        }
        .forEach(\.path, action: \.path)
    }
}

