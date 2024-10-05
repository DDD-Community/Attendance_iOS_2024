//
//  EditEvent.swift
//  DDDAttendance
//
//  Created by 서원지 on 6/19/24.
//

import Foundation
import SwiftUI

import ComposableArchitecture
import KeychainAccess

import Service
import Utill
import DesignSystem
import Model
import LogMacro

@Reducer
public struct ScheduleEvent {
    public init() {}
    
    @ObservableState
    public struct State: Equatable {
        var eventModel: [DDDEventDTO] = []
        var naivgationTitle: String = "기 일정"
        var presentActionSheet: Bool = false
        var offset: CGFloat = 0
        var selectedEvent: DDDEvent?
        var deletedEventModel: DDDEventDTO? = nil
        var deleteImage: ImageAsset = .editEvent
        var editMakeEventResaon: String = ""
        var editEventid: String = ""
        var editEventDate: Date = Date.now
        var editEventEndDate: Date = Date.now
        
        var generation: Int = .zero
        var notEventText: String = "일정이 없습니다."
        var createScheduleText: String = "일정 등록"
        
        @Presents var destination: Destination.State?
        @Presents var confirmationDialog: ConfirmationDialogState<Action.ConfirmationDialog>?
        @Presents var alert: AlertState<Action.Alert>?
        
        public init(
            eventModel: [DDDEventDTO] = [],
            generation: Int = .zero
            
        ) {
            self.eventModel = eventModel
            self.generation = generation
        }
    }
    
    public enum Action: BindableAction, ViewAction ,FeatureAction {
        case binding(BindingAction<State>)
        case destination(PresentationAction<Destination.Action>)
        case confirmationDialog(PresentationAction<ConfirmationDialog>)
        case alert(PresentationAction<Alert>)
        case view(View)
        case async(AsyncAction)
        case inner(InnerAction)
        case navigation(NavigationAction)
        
        
        @CasePathable
        public enum ConfirmationDialog: Equatable {
            case editScheduleEventButtonTap(eventName: String, eventID: String, eventStartDate: Date, eventEndDate: Date)
            case deleteEventButtonTap(eventID: String)
        }
        
        @CasePathable
        public enum Alert: Equatable {
             case deleteEventAlertButtonTap(eventID: String)
           }
        
    }
    
    //MARK: - 뷰 처리 액션
    public enum View {
        case appear
        case presntEventModal
        case closePresntEventModal
        case closeEditEventModal
        case confirmationDialogButtonTapped(eventName: String, eventID: String, eventStartDate: Date, eventEndDate: Date)
        
    }
    
    //MARK: - 비동기 처리 액션
    public enum AsyncAction: Equatable {
        case fetchEvent
        case observeEvent
        case fetchEventResponse(Result<[DDDEventDTO], CustomError>)
        case updateEventModel([DDDEventDTO])
        case deleteEvent(eventID: String)
        case eventDeletedSuccessfully(eventID: String)
        case eventDeletionFailed(CustomError)
        case deleteEventResponse(Result<DDDEventDTO?, CustomError>)
    }
    
    //MARK: - 앱내에서 사용하는 액선
    public enum InnerAction: Equatable {
        case tapEditEvent(eventName: String, eventID: String, eventStartDate: Date, eventEndDate: Date)
       
        
        
    }
    
    
    //MARK: - 네비게이션 연결 액션
    public enum NavigationAction: Equatable {
        
    }
    
    @Reducer(state: .equatable)
    public enum Destination {
        case makeEvent(MakeEvent)
        case editEventModal(EditEventModal)
        
    }
    
    
    @Dependency(FireStoreUseCase.self) var fireStoreUseCase
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
                
            case .binding(_):
                return .none
                
            case .destination(_):
                return .none
                
                
            case let .alert(.presented(.deleteEventAlertButtonTap(eventID))):
                return .run { @MainActor send in
                    send(.async(.deleteEvent(eventID: eventID)))
                }
                                
            case .confirmationDialog(.presented(.editScheduleEventButtonTap(let eventName, let eventID,  let eventStartDate, let eventEndDate))):
                return .run {  send in
                    await send(.inner(.tapEditEvent(eventName: eventName, eventID: eventID, eventStartDate: eventStartDate, eventEndDate: eventEndDate)))
                }

            case .confirmationDialog(.presented(.deleteEventButtonTap(let eventID))):
                state.alert = AlertState {
                    TextState("정말 일정을 삭제할까요? ")
                } actions: {
                    
                    ButtonState(action: .deleteEventAlertButtonTap(eventID: eventID)) {
                        TextState("삭제하기")
                    }
                } message: {
                    TextState("삭제된 일정은 복구할 수 없습니다.")
                }
                return .none
                
            case .alert:
                return .none
                
                  case .confirmationDialog:
                    return .none
                
                //MARK: - ViewAction
                case .view(let View):
                switch View {
                    
                case .presntEventModal:
                    state.destination = .makeEvent(MakeEvent.State(generation: state.generation))
                    return .none
                    
                case .closePresntEventModal:
                    state.destination = nil
                    return .none
                    
                case .closeEditEventModal:
                    state.destination = nil
                    return .none
                    
                case .appear:
                    return .concatenate (
                        Effect.run { send in  await send(.async(.fetchEvent))},
                        Effect.run { send in await send(.async(.observeEvent)) }
                    )
                    
                case .confirmationDialogButtonTapped(let eventName, let eventID,  let eventStartDate, let eventEndDate):
                    state.confirmationDialog = ConfirmationDialogState {
                        TextState("")
                    } actions: {
                       
                        ButtonState(role: .cancel) {
                            TextState("취소")
                                .font(.system(size: 17, weight: .bold))
                        }
                        
                        ButtonState(action: .editScheduleEventButtonTap(eventName: eventName, eventID: eventID, eventStartDate: eventStartDate, eventEndDate: eventEndDate)) {
                            TextState("일정수정")
                                .font(.system(size: 17, weight: .bold))
                        }
                        
                        ButtonState(role: .destructive, action: .deleteEventButtonTap(eventID: eventID)) {
                            TextState("일정삭제")
                                .font(.system(size: 17, weight: .bold))
                        }
                        
                    }
                    return .none
                    
                }
                
                //MARK: - AsyncAction
                case .async(let AsyncAction):
                switch AsyncAction {
                    
                case .fetchEvent:
                    return .run { @MainActor send in
                        let fetchedDataResult = await Result {
                            try await fireStoreUseCase.fetchFireStoreData(
                                from: .event ,
                                as: DDDEvent.self,
                                shouldSave: false)
                        }
                        
                        switch fetchedDataResult {
                        case let .success(fetchedData):
                            let fetchedDataToDTO = fetchedData.map { $0.toModel() }
                            send(.async(.fetchEventResponse(.success(fetchedDataToDTO))))
                        case let .failure(error):
                            send(.async(.fetchEventResponse(.failure(CustomError.map(error)))))
                        }
                    }
               
                case .observeEvent:
                    return .run { @MainActor  send in
                        for await result in try await fireStoreUseCase.observeFireBaseChanges(from: .event, as: DDDEventDTO.self) {
                            send(.async(.fetchEventResponse(result)))
                        }
                    }
                    
                case let .fetchEventResponse(fetchedData):
                    switch fetchedData {
                    case let .success(fetchedData):
                        let sortedData = fetchedData.sorted {
                            $0.startTime < $1.startTime
                        }
                        
                        state.eventModel = sortedData
                    case let .failure(error):
                        #logError("Error fetching data", error.localizedDescription)
                    }
                    return .none
                    
                case let .updateEventModel(newValue):
                    state.eventModel = [ ]
                    state.eventModel = newValue
                    return .run { @MainActor send in 
                        send(.async(.fetchEvent))
                        
                    }
                    
                case .deleteEvent(let eventID):
                    return .run {  send in
                        let fetchedEvent = await Result {
                            try await fireStoreUseCase.deleteEvent(from: .event, eventID: eventID)
                        }
                        
                        switch fetchedEvent {
                        case .success(let deleteData):
                            if let deleteData = deleteData {
                                await send(.async(.deleteEventResponse(.success(deleteData))))
                                await send(.async(.fetchEvent))
                            }
                        
                        case .failure(let error):
                             await send(.async(.deleteEventResponse(.failure(CustomError.encodingError(error.localizedDescription)))))
                        }
                        
                    }

                case .deleteEventResponse(let result):
                    switch result {
                    case .success(let deleteResult):
                        state.deletedEventModel = deleteResult
                    case .failure(let error):
                        #logError("이벤트 삭제 실패", error.localizedDescription)
                    }
                    return .none
                    
                case .eventDeletedSuccessfully(let eventID):
                    state.editEventid = eventID
                    return .none
                    
                case let .eventDeletionFailed(error):
                    #logError("Error DeletingEvent", error)
                    return .none

                }
                
                //MARK: - InnerAction
            case .inner(let InnerAction):
                switch InnerAction {
                    
                    
                case let .tapEditEvent(eventName: eventName,
                     eventID: eventID,
                     eventStartDate: eventStartDate,
                    eventEndDate: eventEndDate
                ):
                    state.editMakeEventResaon =  eventName
                    state.editEventid = eventID
                    let convertDate = "\(eventStartDate.formattedDateTimeToString(date: eventStartDate)) \(eventStartDate.formattedTime(date: eventStartDate))"
                    let convertDateString = convertDate.stringToTimeAndDate(convertDate)
                    let convertEndDate = "\(eventEndDate.formattedDateTimeToString(date: eventEndDate)) \(eventStartDate.formattedTime(date: eventStartDate))"
                    let convertEndDateString = convertEndDate.stringToTimeAndDate(convertEndDate)
                    let generation = state.generation
                    state.editEventDate = convertDateString ?? Date()
                    state.editEventEndDate = convertEndDateString ?? Date()
                    state.destination = .editEventModal(
                        EditEventModal.State(
                            editMakeEventReason: eventName,
                            editEventID: eventID,
                            editEventStartTime:  eventStartDate,
                            editEventEndTime: eventEndDate,
                            generation: generation
                        ))
                    return .none
                    
                
                }
                
                //MARK: - NavigationAction
            case .navigation(let NavigationAction):
                switch NavigationAction {
                    
                }
            }
        }
        .ifLet(\.$destination, action: \.destination)
        .ifLet(\.$confirmationDialog, action: \.confirmationDialog)
        .ifLet(\.$alert, action: \.alert)
        .onChange(of: \.eventModel) { oldValue, newValue in
            Reduce { state, action in
                state.eventModel = newValue
                return .none
            }
        }
    }
}

