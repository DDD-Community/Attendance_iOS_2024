//
//  QrCode.swift
//  DDDAttendance
//
//  Created by 서원지 on 6/11/24.
//

import Foundation
import SwiftUI

import Service

import ComposableArchitecture
import KeychainAccess

@Reducer
public struct QrCode {
    public init() {}
    
    @ObservableState
    public struct State: Equatable {
        public init(userID: String? = nil, startTime: Date? = nil, eventID: String? = nil) {
            self.userID = userID
            self.startTime = startTime
            self.eventID = eventID
        }
        
        var userID: String? = ""
        var eventID: String? = ""
        var startTime: Date? = Date.now
        var qrCodeImage: Image? = nil
        var loadingQRImage: Bool = false
        var qrCodeReaderText: String = ""
        var eventModel: [DDDEvent] = []
        @Presents var destination: Destination.State?
        
        
    }
    
    public enum Action: BindableAction {
        case appearQRcodeUserid
        case generateQRCode
        case qrCodeGenerated(image: Image?)
        case binding(BindingAction<State>)
        case appearLoading
        case fetchEvent
        case fetchEventResponse(Result<[DDDEvent], CustomError>)
        case destination(PresentationAction<Destination.Action>)
        case presntEventModal
        case closeMakeEventModal
        case observeEvent
        case updateEventModel([DDDEvent])
    }
    
    @Dependency(QrCodeUseCase.self) var qrCodeUseCase
    @Dependency(FireStoreUseCase.self) var fireStoreUseCase
    @Dependency(\.continuousClock) var clock
    
    @Reducer(state: .equatable)
    public enum Destination {
        case makeEvent(MakeEvent)
    }
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .appearLoading:
                return .run { send in
                    try await self.clock.sleep(for: .milliseconds(700))
                    await send(.appearQRcodeUserid)
                }
                
            case .appearQRcodeUserid:
                if state.userID == "" {
                    state.loadingQRImage = true
                } else {
                    state.loadingQRImage.toggle()
                }
                return .none
                
            case .generateQRCode:
                let userID = state.userID
                let eventID = state.eventID
                let startTime = state.startTime
                return .run { send in
                    if eventID != "" && userID == userID {
                        await send(.fetchEvent)
                        let convertDateString = startTime?.formattedFireBaseDate(date: startTime ?? Date())
                        let convertStringToDate = startTime?.formattedFireBaseStringToDate(dateString: convertDateString ?? "")
                        let qrCodeGenerateString = String.makeQrCodeValue(
                            userID: userID ?? "",
                            eventID: eventID ?? "",
                            startTime: convertStringToDate ?? Date(),
                            endTime: convertStringToDate?.addingTimeInterval(1800) ?? Date()
                        )
                        let qrCodeImage = await qrCodeUseCase.generateQRCode(from: qrCodeGenerateString)
                        Log.debug(qrCodeGenerateString)
                        await send(.qrCodeGenerated(image: qrCodeImage))
                    }
                }
                
            case let .qrCodeGenerated(image: qrCodeImage):
                state.qrCodeImage = qrCodeImage
                return .none
                
            case .binding(_):
                return .none
                
            case .fetchEvent:
                return .run { @MainActor send in
                    let fetchedDataResult = await Result {
                        try await fireStoreUseCase.fetchFireStoreData(from: "events", as: DDDEvent.self, shouldSave: false)
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
                    let todayEvents = Date().filterEventsForToday(events: state.eventModel)

                    if let todayEvent = todayEvents.first {
                        state.startTime = todayEvent.startTime
                        state.eventID = todayEvent.id
                        Log.debug("Today's event found: \(todayEvent.id)")
                    } else {
                        Log.debug("No event for today.")
                    }
                case let .failure(error):
                    Log.error("Error fetching data", error)
                }
                return .none
                
            case .observeEvent:
                return .run {  send in
                    for await result in try await fireStoreUseCase.observeFireBaseChanges(from: "events", as: DDDEvent.self) {
                        await send(.fetchEventResponse(result))
                    }
                }
                
            case let .updateEventModel(newValue):
                state.eventModel = []
                state.eventModel = newValue
                return .none
                
            case .presntEventModal:
                state.destination = .makeEvent(MakeEvent.State())
                return .none
                
            case .closeMakeEventModal:
                state.destination = nil
                return .none
                
            case .destination(_):
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

