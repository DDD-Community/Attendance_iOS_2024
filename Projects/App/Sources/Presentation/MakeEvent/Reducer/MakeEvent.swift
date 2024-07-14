//
//  MakeEvent.swift
//  DDDAttendance
//
//  Created by 서원지 on 6/15/24.
//

import Foundation
import ComposableArchitecture
import KeychainAccess

import Service

@Reducer
public struct MakeEvent {
    public init() {}
    
    @ObservableState
    public struct State: Equatable {
        public init() {}
        
        var makeEventTitle: String = "이벤트 생성"
        var isSelectDropDownMenu: Bool = false
        var selectMakeEventReason: String = "이번주 세션 이벤트를 선택 해주세요!"
        var selectMakeEventReasonTitle: String =  "생성할 이벤트 이름을 선택 해주세요!"
        var selectMakeEventTiltle: String = "이벤트를 생성할 날짜를 선택해주세요!"
        var selectPart: SelectPart? = nil
        var eventModel: [DDDEvent] = []
        var selectMakeEventDate: Date = Date.now
        var selectMakeEventDatePicker: Bool = false
    }
    
    public enum Action: BindableAction, ViewAction, FeatureAction {
        case binding(BindingAction<State>)
        case selectMakeEventDate(date: Date)
        case selectMakeEventDatePicker(isBool: Bool)
        case view(View)
        case async(AsyncAction)
        case inner(InnerAction)
        case navigation(NavigationAction)
    }
    
    //MARK: - 뷰 처리 액션
    public enum View {
        case tapCloseDropDown
        case selectMakeEventDatePicker(isBool: Bool)
        case makeEventToFireBase(eventName: String)
    }
    
    //MARK: - 비동기 처리 액션
    public enum AsyncAction: Equatable {
        case observeEvent
        case fetchEventResponse(Result<[DDDEvent], CustomError>)
        case makeEventToFireBase(eventName: String)
    }
    
    //MARK: - 앱내에서 사용하는 액선
    public enum InnerAction: Equatable {
        
    }
    
    //MARK: - 네비게이션 연결 액션
    public enum NavigationAction: Equatable {
        
    }
    
    @Dependency(FireStoreUseCase.self) var fireStoreUseCase
    @Dependency(\.uuid) var uuid
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
                
            case .binding(_):
                return .none
                
            case .binding(\.selectMakeEventDate):
                state.selectMakeEventDate = state.selectMakeEventDate
                return .none
                
            case .binding(\.selectMakeEventDatePicker):
                state.selectMakeEventDatePicker.toggle()
                return .none
                
            case .selectMakeEventDate(let date):
                state.selectMakeEventDate = date
                return .none
                
            case .selectMakeEventDatePicker(let isBool):
                state.selectMakeEventDatePicker = isBool
                return .none
                
                //MARK: - ViewAction
                case .view(let View):
                switch View {
                case .tapCloseDropDown:
                    state.isSelectDropDownMenu = false
                    return .none
                    
                    
                case .selectMakeEventDatePicker(var isBool):
                    isBool.toggle()
                    state.selectMakeEventDatePicker.toggle()
                    return .none
                    
                case let .makeEventToFireBase(eventName: eventName):
                    let convertStartDate = state.selectMakeEventDate.formattedDate(date: state.selectMakeEventDate)
                    let convertTime = state.selectMakeEventDate.formattedTime(date: state.selectMakeEventDate)
                    let convertDate = convertStartDate + convertTime
                    let convertStringToDate = state.selectMakeEventDate.formattedFireBaseStringToDate(dateString: convertDate)
                    let event = DDDEvent(
                        id: UUID().uuidString,
                        name: eventName,
                        startTime: convertStringToDate,
                        endTime: convertStringToDate.addingTimeInterval(1800))
                    state.eventModel = [event]
                    return .run  { @MainActor  send in
                        let events = try await fireStoreUseCase.createEvent(event: event, from: .event)
                        Log.debug("event 생성", events)
                    }
                }
                
                //MARK: - AsyncAction
                case .async(let AsyncAction):
                switch AsyncAction {
                case .observeEvent:
                    return .run { @MainActor send in
                        for await result in try await fireStoreUseCase.observeFireBaseChanges(
                            from: .event,
                            as: DDDEvent.self
                        ) {
                            send(.async(.fetchEventResponse(result)))
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
                    
                case let .makeEventToFireBase(eventName: eventName):
                    let convertStartDate = state.selectMakeEventDate.formattedDate(date: state.selectMakeEventDate)
                    let convertTime = state.selectMakeEventDate.formattedTime(date: state.selectMakeEventDate)
                    let convertDate = convertStartDate + convertTime
                    let convertStringToDate = state.selectMakeEventDate.formattedFireBaseStringToDate(dateString: convertDate)
                    let event = DDDEvent(
                        id: UUID().uuidString,
                        name: eventName,
                        startTime: convertStringToDate,
                        endTime: convertStringToDate.addingTimeInterval(1800))
                    state.eventModel = [event]
                    return .run  { @MainActor  send in
                        let events = try await fireStoreUseCase.createEvent(event: event, from: .event)
                        Log.debug("event 생성", events)
                    }
                }
                
                //MARK: - InnerAction
            case .inner(let InnerAction):
                switch InnerAction {
                    
                }
                
                //MARK: - NavigationAction
            case .navigation(let NavigationAction):
                switch NavigationAction {
                    
                }
            }
        }
        .onChange(of: \.eventModel) { oldValue, newValue in
            Reduce { state, action in
                state.eventModel = newValue
                return .none
            }
        }
    }
}

