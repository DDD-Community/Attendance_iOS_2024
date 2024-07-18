//
//  EditEvent.swift
//  DDDAttendance
//
//  Created by 서원지 on 6/19/24.
//

import Foundation
import ComposableArchitecture
import KeychainAccess

import Service
import Utill

@Reducer
public struct ScheduleEvent {
    public init() {}
    
    @ObservableState
    public struct State: Equatable {
        var eventModel: [DDDEvent] = []
        var naivgationTitle: String = "기 일정"
        var isEditing: Bool = false
        var isEditEvent: Bool = false
        var offset: CGFloat = 0
        var selectedEvent: DDDEvent?
        var deleteImage: String = "minus.circle"
        var editMakeEventResaon: String = ""
        var editEventid: String = ""
        var editEventDate: Date = Date.now
        var generation: Int = .zero
        
        @Presents var destination: Destination.State?
        
        public init(
            eventModel: [DDDEvent] = [],
            generation: Int = .zero
            
        ) {
            self.eventModel = eventModel
            self.generation = generation
        }
    }
    
    public enum Action: BindableAction, ViewAction ,FeatureAction {
        case binding(BindingAction<State>)
        case destination(PresentationAction<Destination.Action>)
        case view(View)
        case async(AsyncAction)
        case inner(InnerAction)
        case navigation(NavigationAction)
    }
    
    //MARK: - 뷰 처리 액션
    public enum View {
        case presntEventModal
        case closePresntEventModal
        case closeEditEventModal
    }
    
    //MARK: - 비동기 처리 액션
    public enum AsyncAction: Equatable {
        case fetchEvent
        case observeEvent
        case fetchEventResponse(Result<[DDDEvent], CustomError>)
        case updateEventModel([DDDEvent])
        case deleteEvent
        case eventDeletedSuccessfully(eventID: String)
        case eventDeletionFailed(CustomError)
    }
    
    //MARK: - 앱내에서 사용하는 액선
    public enum InnerAction: Equatable {
        case tapEditEvent(eventName: String, eventID: String, eventStartDate: Date)
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
                
                //MARK: - ViewAction
                case .view(let View):
                switch View {
                    

                case .presntEventModal:
                    state.destination = .makeEvent(MakeEvent.State())
                    return .none
                    
                case .closePresntEventModal:
                    state.destination = nil
                    return .none
                    
                case .closeEditEventModal:
                    state.destination = nil
                    return .none
                }
                
                //MARK: - AsyncAction
                case .async(let AsyncAction):
                switch AsyncAction {
                    
                case .fetchEvent:
                    return .run { @MainActor send in
                        let fetchedDataResult = await Result {
                            try await fireStoreUseCase.fetchFireStoreData(from: .event , as: DDDEvent.self, shouldSave: true)
                        }
                        
                        switch fetchedDataResult {
                        case let .success(fetchedData):
                            send(.async(.fetchEventResponse(.success(fetchedData))))
                            await Task.sleep(seconds: 1)
                        case let .failure(error):
                            send(.async(.fetchEventResponse(.failure(CustomError.map(error)))))
                        }
                    }
               
                case .observeEvent:
                    return .run { @MainActor  send in
                        for await result in try await fireStoreUseCase.observeFireBaseChanges(from: .event, as: DDDEvent.self) {
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
                    
                case let .updateEventModel(newValue):
                    state.eventModel = [ ]
                    state.eventModel = newValue
                    return .run { @MainActor send in 
                        send(.async(.fetchEvent))
                        
                    }
                    
                case .deleteEvent:
                    return .run {  @MainActor send in
                        let fetchedEvent = await Result {
                            try await fireStoreUseCase.deleteEvent(from: .event)
                        }
                        
                        switch fetchedEvent {
                        case .success:
                            send(.async(.fetchEvent))
                        case .failure(let error):
                            send(.async(.eventDeletionFailed(CustomError.map(error))))
                        }
                        
                    }

                    
                case .eventDeletedSuccessfully(let eventID):
                    state.editEventid = eventID
                    return .none
                    
                case let .eventDeletionFailed(error):
                    Log.error("Error DeletingEvent", error)
                    return .none

                }
                
                //MARK: - InnerAction
            case .inner(let InnerAction):
                switch InnerAction {
                    
                case let .tapEditEvent(eventName: eventName,
                     eventID: eventID,
                     eventStartDate: eventStartDate):
                    state.editMakeEventResaon =  eventName
                    state.editEventid = eventID
                    let convertDate = "\(eventStartDate.formattedDateTimeToString(date: eventStartDate)) \(eventStartDate.formattedTime(date: eventStartDate))"
                    let convertDateString = convertDate.stringToTimeAndDate(convertDate)
                    state.editEventDate = convertDateString ?? Date()
                    state.destination = .editEventModal(
                        EditEventModal.State(
                            editMakeEventReason: eventName,
                            editEventID: eventID,
                            editEventStartTime:  eventStartDate
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
        .onChange(of: \.eventModel) { oldValue, newValue in
            Reduce { state, action in
                state.eventModel = newValue
                return .none
            }
        }
    }
}

