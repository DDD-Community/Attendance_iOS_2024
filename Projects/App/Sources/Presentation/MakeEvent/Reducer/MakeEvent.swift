//
//  MakeEvent.swift
//  DDDAttendance
//
//  Created by 서원지 on 6/15/24.
//

import Foundation
import ComposableArchitecture
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
        var selectPart: SelectPart? = nil
        var eventModel: [DDDEvent] = []
        
    }
    
    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case tapCloseDropDown
        case selectAttendaceMemberButton(selectPart: SelectPart)
        case makeEventToFireBaseModel(eventName: String, eventDate: Date)
        case makeEventToFireBase(eventName: String)
        case observeEvent
        case fetchEventResponse(Result<[DDDEvent], CustomError>)
    }
    
    @Dependency(FireStoreUseCase.self) var fireStoreUseCase
    @Dependency(\.uuid) var uuid
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
                
            case .binding(_):
                return .none
                
            case .tapCloseDropDown:
                state.isSelectDropDownMenu = false
                return .none
                
            case let .selectAttendaceMemberButton(selectPart: selectPart):
                if state.selectPart == selectPart {
                    state.selectPart = nil
                } else {
                    state.selectPart = selectPart
                }
                return .none
                
            case let .makeEventToFireBase(eventName: eventName):
                let event = DDDEvent(
                    id: uuid.callAsFunction().uuidString,
                    name: eventName,
                    description: eventName,
                    startTime: Date(),
                    endTime: Date().addingTimeInterval(3600))
                state.eventModel = [event]
                return .run  { @MainActor  send in
                    let events = try await fireStoreUseCase.createEvent(event: event, from: "events")
                    Log.debug("event 생성", events)
                }
                
            case let .makeEventToFireBaseModel(eventName: eventName, eventDate: eventDate):
                let event = DDDEvent(
                    id: uuid.callAsFunction().uuidString,
                    name: eventName,
                    description: eventName,
                    startTime: eventDate,
                    endTime: eventDate.addingTimeInterval(3600))
                state.eventModel = [event]
                   
                return .none
                
            case .observeEvent:
                return .run { @MainActor send in 
                    for await result in try await fireStoreUseCase.observeFireBaseChanges(from: "events", as: DDDEvent.self) {
                         send(.fetchEventResponse(result))
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
        }
    }
}

