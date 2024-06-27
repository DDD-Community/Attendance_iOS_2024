//
//  EditEventModal.swift
//  DDDAttendance
//
//  Created by 서원지 on 6/21/24.
//

import Foundation
import ComposableArchitecture
import Service
import FirebaseFirestore

@Reducer
public struct EditEventModal {
    public init() {}
    
    @ObservableState
    public struct State: Equatable {
        public init() {}
        
        var editEventModalTitle: String = "이벤트 수정"
        var isSelectEditDropDownMenu: Bool = false
        var editMakeEventReason: String = "이번주 세션 이벤트를 선택 해주세요!"
        var editEventReasonTitle: String =  "수정할 이벤트 이름을 선택 해주세요!"
        var selectMakeEventTiltle: String = "수정할 날짜를 선택해주세요!"
        var editEventID: String? = ""
        var editEventStartTime: Date = Date.now
        var selectEditEventDatePicker: Bool = false
        var selectedEvent: DDDEvent?
        var eventModel: [DDDEvent] = [ ]
        
        public init(
            editMakeEventReason: String = "이번주 세션 이벤트를 선택 해주세요!",
            editEventID: String? = nil,
            editEventStartTime: Date = Date.now
        ) {
            self.editMakeEventReason = editMakeEventReason
            self.editEventID = editEventID
            self.editEventStartTime = editEventStartTime
        }
        
    }
    
    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case fetchEvent
        case tapCloseDropDown
        case fetchEventResponse(Result<[DDDEvent], CustomError>)
        case editEventResponse(Result<DDDEvent, CustomError>)
        case selectMakeEventDate(date: Date)
        case saveEvent
        case selectEditEventDatePicker(isBool: Bool)
        
    }
    
    @Dependency(FireStoreUseCase.self) var fireStoreUseCase
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding(_):
                return .none
                    
            case .saveEvent:
                let convertStartDate = state.editEventStartTime.formattedDate(date: state.editEventStartTime)
                let convertTime = state.editEventStartTime.formattedTime(date: state.editEventStartTime)
                let convertDate = state.editEventStartTime.formattedFireBaseDate(date: state.editEventStartTime)
                let convertStringToDate = state.editEventStartTime.formattedFireBaseStringToDate(dateString: convertDate)
                let event = DDDEvent(
                    name: state.editMakeEventReason,
                    startTime: convertStringToDate,
                    endTime: convertStringToDate.addingTimeInterval(1800)
                )
                
                return .run { send in
                    let fetchedEventResult = await Result {
                        try await fireStoreUseCase.editEvent(
                            event: event,
                            in: .event
                        )
                    }
                }

            case let .editEventResponse(result):
                switch result {
                case .success(let updatedEvent):
                    state.selectedEvent = updatedEvent
                    state.editMakeEventReason = updatedEvent.name
                    state.editEventStartTime = updatedEvent.startTime
                    state.editEventStartTime = updatedEvent.endTime.addingTimeInterval(1800)
                    Log.debug("Event successfully updated in state")
                case .failure(let error):
                    Log.error("Failed to update event: \(error)")
                }
                return .none
                
            case .fetchEvent:
                return .run { @MainActor send in
                    let fetchedDataResult = await Result {
                        try await fireStoreUseCase.fetchFireStoreData(
                            from: .event,
                            as: DDDEvent.self,
                            shouldSave: true)
                    }
                    
                    switch fetchedDataResult {
                    case let .success(fetchedData):
                        send(.fetchEventResponse(.success(fetchedData)))
                        await Task.sleep(seconds: 1)
                        send(.fetchEvent)
                    case let .failure(error):
                        send(.fetchEventResponse(.failure(CustomError.map(error))))
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
                
            case .tapCloseDropDown:
                state.isSelectEditDropDownMenu = false
                return .none
                
            case .selectMakeEventDate(let date):
                state.editEventStartTime = date
                return .none
                
            case .selectEditEventDatePicker(let isBool):
                state.selectEditEventDatePicker = isBool
                return .none
                
                
            }
        }
    }
}

