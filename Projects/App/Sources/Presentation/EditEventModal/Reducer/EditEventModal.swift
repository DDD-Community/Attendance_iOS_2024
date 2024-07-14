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
    
    public enum Action: BindableAction, ViewAction, FeatureAction {
        case binding(BindingAction<State>)
        case selectMakeEventDate(date: Date)
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
        case saveEvent
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
                case .saveEvent:
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

