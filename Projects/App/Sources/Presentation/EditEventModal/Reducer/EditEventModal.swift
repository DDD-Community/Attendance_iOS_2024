//
//  EditEventModal.swift
//  DDDAttendance
//
//  Created by 서원지 on 6/21/24.
//

import Foundation
import ComposableArchitecture

import FirebaseFirestore

import Service
import Utill

import Model
import LogMacro

@Reducer
public struct EditEventModal {
    public init() {}
    
    @ObservableState
    public struct State: Equatable {
        public init() {}
        
        var editEventModalTitle: String = "일정 등록"
        var isSelectEditDropDownMenu: Bool = false
        var editMakeEventReason: String = "이벤트 선택"
        var editEventReasonTitle: String =  "등록할 일정을 선택해 주세요."
        var selectMakeEventTiltle: String = "시작과 종료 시간을 정해주세요."
        var editEventID: String? = ""
        var editEventStartTime: Date = Date.now
        var editEventEndTime: Date = Date.now
        var selectEditEventDatePicker: Bool = false
        var updateEventData: DDDEvent? = nil
        var eventModel: [DDDEvent] = [ ]
        var generation: Int = .zero
        
        public init(
            editMakeEventReason: String = "이번주 세션 이벤트를 선택 해주세요!",
            editEventID: String? = nil,
            editEventStartTime: Date = Date.now,
            editEventEndTime: Date = Date.now,
            generation: Int = .zero
        ) {
            self.editMakeEventReason = editMakeEventReason
            self.editEventID = editEventID
            self.editEventStartTime = editEventStartTime
            self.editEventEndTime = editEventEndTime
            self.generation = generation
        }
        
    }
    
    public enum Action: BindableAction, ViewAction, FeatureAction {
        case binding(BindingAction<State>)
        case selectMakeEventDate(date: Date)
        case selectMakeEventEndDate(date: Date)
        case selectEditEventDatePicker(isBool: Bool)
        case view(View)
        case async(AsyncAction)
        case inner(InnerAction)
        case navigation(NavigationAction)
    }
    
    //MARK: - 뷰 처리 액션
    public enum View {
        case tapCloseDropDown
        case selectEditEventDatePOPUP(isBool: Bool)
    }
    
    //MARK: - 비동기 처리 액션
    public enum AsyncAction: Equatable {
        case editEvent
        case editEventResponse(Result<DDDEvent? , CustomError>)
    }
    
    //MARK: - 앱내에서 사용하는 액선
    public enum InnerAction: Equatable {
        
    }
    
    //MARK: - 네비게이션 연결 액션
    public enum NavigationAction: Equatable {
        
    }
    
    @Dependency(FireStoreUseCase.self) var fireStoreUseCase
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding(_):
                return .none
                
            case .selectMakeEventDate(let date):
                state.editEventStartTime = date
                return .none
                
            case .selectMakeEventEndDate(let date):
                state.editEventEndTime = date
                return .none
                
            case .selectEditEventDatePicker(let isBool):
                state.selectEditEventDatePicker = isBool
                return .none
                
            //MARK: - ViewAction
            case .view(let View):
                switch View {
                case .tapCloseDropDown:
                    state.isSelectEditDropDownMenu = false
                    return .none
                    
                case .selectEditEventDatePOPUP(var isBool):
                    isBool.toggle()
                    state.selectEditEventDatePicker.toggle()
                    return .none
                }
                
            //MARK: - AsyncAction
            case .async(let AsyncAction):
                switch AsyncAction {
                case .editEvent:
                    let eventID = state.editEventID
                    let startTime: Date
                    if state.editEventStartTime == .now {
                        let convertStartDate = state.editEventStartTime.formattedFireBaseDate(date: state.editEventStartTime)
                        startTime = state.editEventStartTime.formattedFireBaseStringToDate(dateString: convertStartDate)
                        #logDebug("시작 날짜가 선택되지 않음. 현재 시간으로 설정.")
                    } else {
                        let convertStartDate = state.editEventStartTime.formattedFireBaseDate(date: state.editEventStartTime)
                        startTime = state.editEventStartTime.formattedFireBaseStringToDate(dateString: convertStartDate)
                        #logDebug("선택된 시작 날짜: \(startTime)")
                    }

                    var endTime: Date
                    if state.editEventStartTime == .now  || state.editEventStartTime == state.editEventEndTime{
                        endTime = startTime.addingTimeInterval(1800)
                        #logDebug("마침 날짜가 선택되지 않음. 30분 추가됨.")
                    } else  {
                        let convertEndDate = state.editEventEndTime.formattedFireBaseDate(date: state.editEventEndTime)
                        endTime = state.editEventEndTime.formattedFireBaseStringToDate(dateString: convertEndDate)
                        #logDebug("선택된 마침 날짜: \(endTime)")
                    }
                    
                    let event = DDDEvent(
                        id: state.editEventID,
                        name: state.editMakeEventReason,
                        startTime: startTime,
                        endTime: endTime,
                        generation: state.generation
                    )
                    
                    return .run { send in
                        let fetchedEventResult = await Result {
                            try await fireStoreUseCase.editEvent(
                                event: event,
                                in: .event,
                                eventID: eventID ?? ""
                            )
                        }
                        
                        switch fetchedEventResult {
                        case .success(let fetchedEventData):
                            if let fetchedEventData = fetchedEventData {
                                await send(.async(.editEventResponse(.success(fetchedEventData))))
                            }
                        case .failure(let error):
                            await send(.async(.editEventResponse(.failure(CustomError.encodingError(error.localizedDescription)))))
                        }
                    }

                case .editEventResponse(let result):
                    switch result {
                    case .success(let editEventData):
                        state.updateEventData = editEventData
                    case .failure(let error):
                        #logError("이벤트 업데이트 실패", error.localizedDescription)
                    }
                    return .none
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
    }
}

