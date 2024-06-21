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

@Reducer
public struct EditEvent {
    public init() {}
    
    @ObservableState
    public struct State: Equatable {
        var eventModel: [DDDEvent] = []
        var naivgationTitle: String = "이벤트 수정"
        var isEditing: Bool = false
        var offset: CGFloat = 0
        var selectedEvent: DDDEvent?
        var deleteImage: String = "minus.circle"
        
        @Presents var destination: Destination.State?
        public init() {}
    }
    
    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case fetchEvent
        case observeEvent
        case fetchEventResponse(Result<[DDDEvent], CustomError>)
        case deleteEvent
        case eventDeletedSuccessfully(eventID: String)
        case eventDeletionFailed(CustomError)
        case creatEvents
        case updateEventModel([DDDEvent])
        case destination(PresentationAction<Destination.Action>)
        case presntEventModal
        case closePresntEventModal
    }
    
    @Reducer(state: .equatable)
    public enum Destination {
        case makeEvent(MakeEvent)
        
    }
    
    
    @Dependency(FireStoreUseCase.self) var fireStoreUseCase
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
                
            case .binding(_):
                return .none
                
            case .fetchEvent:
                return .run { @MainActor send in
                    let fetchedDataResult = await Result {
                        try await fireStoreUseCase.fetchFireStoreData(from: "events", as: DDDEvent.self, shouldSave: true)
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
           
            case .observeEvent:
                return .run { send in
                    for await result in try await fireStoreUseCase.observeFireBaseChanges(from: "events", as: DDDEvent.self) {
                         await send(.fetchEventResponse(result))
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
                
                
            case .deleteEvent:
                return .run {  send in
                    let fetchedEvent = await Result {
                        try await fireStoreUseCase.deleteEvent(from: "events")
                    }
                    
                    switch fetchedEvent {
                    case .success:
                        await send(.eventDeletedSuccessfully(eventID: ""))
                    case .failure(let error):
                        await send(.eventDeletionFailed(CustomError.map(error)))
                    }
                    
                }
                
            case .eventDeletedSuccessfully(_):
                return .none
                
            case let .eventDeletionFailed(error):
                Log.error("Error DeletingEvent", error)
                return .none
                
           
            case .creatEvents:
                return .none
                
            case  let .updateEventModel(newValue):
                state.eventModel = []
                state.eventModel = newValue
                return .none
                
            case .destination(_):
                return .none
                
            case .presntEventModal:
                state.destination = .makeEvent(MakeEvent.State())
                return .none
                
            case .closePresntEventModal:
                state.destination = nil
                return .none
                
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

