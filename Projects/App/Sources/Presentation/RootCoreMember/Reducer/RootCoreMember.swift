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

@Reducer
public struct RootCoreMember {
    public init() {}
    
    @ObservableState
    public struct State: Equatable {
        public init() {}
        
        var path: StackState<Path.State> = .init()
        var eventModel: [DDDEvent] = []
        var attendaceModel : [Attendance] = []
        var combinedAttendances: [Attendance] = []
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
        case fetchEventResponse(Result<[DDDEvent], CustomError>)
        
        case fetchMember
        case fetchAttenDance
        case fetchDataResponse(Result<[Attendance], CustomError>)
        case fetchAttendanceHistory(String)
        case updateAttendanceTypeModel([Attendance])
        case fetchAttendanceHistoryResponse(Result<[Attendance], CustomError>)
        case fetchAttendanceDataResponse(Result<[Attendance], CustomError>)
        
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
                    Log.debug("키체인", userID, eventID)
                    state.path.append(.qrCode(.init(userID: userID ?? "")))
                    
                case .element(id: _, action: .coreMember(.navigation(.presentSchedule))):
                    state.path.append(.scheduleEvent(.init(eventModel: state.eventModel, generation: state.attendaceModel.first?.generation ?? .zero)))
                    
                case .element(id: _, action: .mangeProfile(.navigation(.tapLogOut))):
                    state.path.append(.snsLogin(.init()))
                    
                case .element(id: _, action: .coreMember(.navigation(.presentMangerProfile))):
                    state.path.append(.mangeProfile(.init()))
                    
                case .element(id: _, action: .mangeProfile(.navigation(.presentCreatByApp))):
                    state.path.append(.createByApp(.init()))
                    
                    
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
                            let filterData = fetchedData.filter { $0.memberType == .member || $0.name != ""}
                            send(.async(.fetchDataResponse(.success(filterData))))
                        case let .failure(error):
                            send(.async(.fetchDataResponse(.failure(CustomError.map(error)))))
                        }
                        
                    }
                    
                case let .fetchDataResponse(fetchedData):
                    switch fetchedData {
                    case let .success(fetchedData):
                        let filteredData = fetchedData.filter { $0.memberType == .member && !$0.name.isEmpty }
                        
                        state.attendaceModel = filteredData
                        
//                        state.combinedAttendances = state.attendaceModel
                    case let .failure(error):
                        Log.error("Error fetching data", error)
                    }
                    return .none
                    
                    
                case .fetchAttenDance:
                    // Swift 6 and later requires the nonisolated keyword to avoid data race errors
                    // var attendanceModel = state.attendanceModel
                    return .run { @MainActor send in
                        let fetchedDataResult = await Result {
                            try await fireStoreUseCase.fetchFireStoreData(
                                from: .attendance,
                                as: Attendance.self,
                                shouldSave: false)
                        }
                        switch fetchedDataResult {
                        case let .success(fetchedData):
                            send(.async(.fetchMember))
                            send(.async(.fetchAttendanceDataResponse(.success(fetchedData))))
                            
                            let uids = Set(fetchedData.map { $0.memberId })
                            
                            for uid in uids {
                                send(.async(.fetchMember))
                                send(.async(.fetchAttendanceHistory(uid ?? "")))
                            }
                            
                        case let .failure(error):
                            send(.async(.fetchAttendanceDataResponse(.failure(CustomError.map(error)))))
                        }
                    }
                    
                case let .fetchAttendanceHistory(uid):
                    return .run { @MainActor send in
                        for await result in try await fireStoreUseCase.fetchAttendanceHistory(uid, from: .attendance) {
                            send(.async(.fetchAttendanceHistoryResponse(result)))
                        }
                    }
                    
                case let .fetchAttendanceHistoryResponse(result):
                    switch result {
                    case let .success(attendances):
                        return .send(.async(.updateAttendanceTypeModel(attendances)))
                        
                    case let .failure(error):
                        return .send(.async(.fetchAttendanceDataResponse(.failure(error))))
                    }
                    
                case let .fetchAttendanceDataResponse(fetchedAttendanceData):
                    switch fetchedAttendanceData {
                    case let .success(fetchedData):

//                        let statusDict = Dictionary(uniqueKeysWithValues: fetchedData.map { ($0.memberId, $0.status) })
                        let statusDict: [String: AttendanceType?] = .init(uniqueKeysWithValues: fetchedData.map({ ($0.id, $0.status) }) )
                        
                        var updatedCombinedAttendances = state.combinedAttendances
                        
                        for index in updatedCombinedAttendances.indices {
                            if let updatedStatus = statusDict[updatedCombinedAttendances[index].id] {
                                updatedCombinedAttendances[index].status = updatedStatus
                            }
                        }
                        
                        state.combinedAttendances = updatedCombinedAttendances
                        Log.debug("combinedAttendances2", state.combinedAttendances)
                        
                        // If needed, also update state.attendaceModel similarly
                        var updatedAttendaceModel: [Attendance] = []
                        for data in state.attendaceModel {
                            let updatedStatus = statusDict[data.id] ?? .none
                            let updatedAttendance = Attendance(
                                id: data.id,
                                memberId: data.memberId ?? "",
                                memberType: data.memberType,
                                name: data.name,
                                roleType: data.roleType,
                                eventId: data.eventId,
                                createdAt: data.createdAt,
                                updatedAt: data.updatedAt,
                                status: updatedStatus,
                                generation: data.generation
                            )
                            updatedAttendaceModel.append(updatedAttendance)
                            Log.debug("combinedAttendances2", updatedAttendance)
                            state.attendaceModel = [updatedAttendance]
                        }
                        
//                        state.attendaceModel = updatedAttendaceModel
                        Log.debug("combinedAttendances3", state.attendaceModel)
                        
                    case let .failure(error):
                        Log.error("Error fetching data", error)
                    }
                    return .none
                    
                case let .updateAttendanceTypeModel(attendances):
                    state.combinedAttendances = attendances
                    
                    // Create a dictionary to quickly find the status by memberId from fetched data
//                    let statusDict = Dictionary(uniqueKeysWithValues: attendances.map { ($0.memberId, $0.status) })
                    let statusDict: [String: AttendanceType?] = Dictionary(uniqueKeysWithValues: attendances.map { ($0.id, $0.status) })
                    
                    // combinedAttendances에서 상태 업데이트
                    var updatedCombinedAttendances = state.combinedAttendances
                    for index in updatedCombinedAttendances.indices {
                        if let updatedStatus = statusDict[updatedCombinedAttendances[index].id] {
                            updatedCombinedAttendances[index].status = updatedStatus
                        }
                    }
                    
                    
                    // attendaceModel을 업데이트하여 바뀐 값을 반영
                    let updatedAttendaceModel: [Attendance] = state.attendaceModel.map { data in
                            let updatedStatus = statusDict[data.id]
                            return Attendance(
                                id: data.id,
                                memberId: data.memberId ?? "",
                                memberType: data.memberType,
                                name: data.name,
                                roleType: data.roleType,
                                eventId: data.eventId,
                                createdAt: data.createdAt,
                                updatedAt: data.updatedAt, // updatedAt를 현재 시간으로 설정
                                status: updatedStatus ?? data.status, // 새로운 상태가 있으면 사용, 없으면 기존 상태 유지
                                generation: data.generation
                            )
                        Log.debug("updatedStatus", updatedStatus)
                        }
                    
                    state.attendaceModel = updatedAttendaceModel
                    Log.debug("updatedAttendanceModel", updatedAttendaceModel)
                    Log.debug("updatedAttendanceModel", state.attendaceModel)
                    return .none
                }
                
                //MARK: - InnerAction
            case .inner(let InnerAction):
                switch InnerAction {
                case .appearPath:
                    state.path.append(.coreMember(.init(attendaceModel: state.attendaceModel, combinedAttendances: state.combinedAttendances)))
                    return .run { @MainActor send in
                        send(.coreStoreAction(.async(.fetchAttenDance)))
                    }
                    
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

