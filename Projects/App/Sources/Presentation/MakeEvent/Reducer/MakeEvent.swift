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
import Utill
import Model
import LogMacro

@Reducer
public struct MakeEvent {
    public init() {}
    
    @ObservableState
    public struct State: Equatable {
        
        
        var makeEventTitle: String = "일정 등록"
        var isSelectDropDownMenu: Bool = false
        var selectMakeEventReason: String = "이벤트 선택"
        var selectMakeEventReasonTitle: String =  "등록할 일정을 선택해 주세요."
        var selectMakeEventTiltle: String = "시작과 종료 시간을 정해주세요."
        var selectPart: SelectPart? = nil
        var eventModel: [DDDEvent] = []
        var selectMakeEventDate: Date = Date.now
        var selectMakeEventEndDate: Date = Date.now
        var eventID: String?
        var generation: Int = .zero
        var selectMakeEventDatePicker: Bool = false
        
        public init(
            generation: Int = .zero
        ) {
            self.generation = generation
        }
        
    }
    
    public enum Action: BindableAction, ViewAction, FeatureAction {
        case binding(BindingAction<State>)
        case selectMakeEventDate(date: Date)
        case selectMakeEventEndDate(date: Date)
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
                
            case .binding(\.selectMakeEventDatePicker):
                state.selectMakeEventDatePicker.toggle()
                return .none
                
            case .selectMakeEventDate(let date):
                state.selectMakeEventDate = date
                return .none
                
            case .selectMakeEventEndDate(let date):
                state.selectMakeEventEndDate = date
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
                       let startTime: Date
                    if state.selectMakeEventDate == .now {
                           let convertStartDate = state.selectMakeEventDate.formattedFireBaseDate(date: state.selectMakeEventDate)
                           startTime = state.selectMakeEventDate.formattedFireBaseStringToDate(dateString: convertStartDate)
                        #logDebug("시작 날짜가 선택되지 않음. 현재 시간으로 설정.")
                       } else {
                           let convertStartDate = state.selectMakeEventDate.formattedFireBaseDate(date: state.selectMakeEventDate)
                           startTime = state.selectMakeEventDate.formattedFireBaseStringToDate(dateString: convertStartDate)
                           #logDebug("선택된 시작 날짜: \(startTime)")
                       }

                       var endTime: Date
                    if state.selectMakeEventEndDate != state.selectMakeEventDate || state.selectMakeEventEndDate == .now  {
                           endTime = startTime.addingTimeInterval(1800)
                        #logDebug("마침 날짜가 선택되지 않음. 30분 추가됨.")
                       } else {
                           let convertEndDate = state.selectMakeEventEndDate.formattedFireBaseDate(date: state.selectMakeEventEndDate)
                           endTime = state.selectMakeEventEndDate.formattedFireBaseStringToDate(dateString: convertEndDate)
                           #logDebug("선택된 마침 날짜: \(endTime)")
                       }

                       let event = DDDEvent(
                           id: UUID().uuidString,
                           name: eventName,
                           startTime: startTime,
                           endTime: endTime,
                           generation: state.generation
                       )

                       state.eventModel = [event]
                    
                    return .run { @MainActor send in
                        let events = try await fireStoreUseCase.createEvent(event: event, from: .event, uuid: event.id ?? "")
                        #logDebug("event 생성", events)
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
                        #logError("Error fetching data", error)
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
                        let events = try await fireStoreUseCase.createEvent(event: event, from: .event, uuid: UUID().uuidString)
                        #logDebug("event 생성", events)
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

