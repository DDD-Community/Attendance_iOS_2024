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

import Utill
import Model
import LogMacro

@Reducer
public struct QrCode {
    public init() {}
    
    @ObservableState
    public struct State: Equatable {
        public init(
            userID: String? = nil,
            startTime: Date? = nil,
            endTime: Date? = nil,
            eventID: String? = nil
        ) {
            self.userID = userID
            self.startTime = startTime
            self.endTime = endTime
            self.eventID = eventID
        }
        
        var userID: String? = ""
        var eventID: String? = ""
        var startTime: Date? = Date.now
        var endTime: Date? = Date.now
        var qrCodeImage: Image? = nil
        var loadingQRImage: Bool = false
        var qrCodeReaderText: String = "로딩중!"
        var eventModel: [DDDEvent] = []
        @Presents var destination: Destination.State?
        
        
    }
    
    public enum Action: BindableAction, FeatureAction {
        case binding(BindingAction<State>)
        case destination(PresentationAction<Destination.Action>)
        
        case view(View)
        case async(AsyncAction)
        case inner(InnerAction)
        case navigation(NavigationAction)
    }
    
    @Dependency(QrCodeUseCase.self) var qrCodeUseCase
    @Dependency(FireStoreUseCase.self) var fireStoreUseCase
    @Dependency(\.continuousClock) var clock
    
    //MARK: - View 애션
    public enum View {
        case qrCodeGenerated(image: Image?)
        case appearLoading
        case presntEventModal
        case closeMakeEventModal
        case appearQRcodeUserid
    }
    
    //MARK: - 비동기 처리 액션
    public enum AsyncAction: Equatable {
        case fetchEvent
        case fetchEventResponse(Result<[DDDEvent], CustomError>)
        case updateEventModel([DDDEvent])
        case observeEvent
        case generateQRCode
    }
    
    //MARK: - 해당 뷰에서 사용하는 액선
    public enum InnerAction: Equatable {
        
    }
    
    //MARK: - 네비게이션 연결 액션
    public enum NavigationAction: Equatable {
        case presentSchedule
    }
    
    @Reducer(state: .equatable)
    public enum Destination {
        case makeEvent(MakeEvent)
    }
    
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
                    
                case let .qrCodeGenerated(image: qrCodeImage):
                    state.qrCodeImage = qrCodeImage
                    return .none
                    
                case .appearLoading:
                    return .run { send in
                        try await self.clock.sleep(for: .milliseconds(700))
                        await send(.view(.appearQRcodeUserid))
                    }
                    
                case .presntEventModal:
                    state.destination = .makeEvent(MakeEvent.State())
                    return .none
                    
                case .closeMakeEventModal:
                    state.destination = nil
                    return .none
                    
                case .appearQRcodeUserid:
                    if state.userID == "" {
                        state.loadingQRImage = true
                    } else {
                        state.loadingQRImage.toggle()
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
                                from: .event,
                                as: DDDEvent.self,
                                shouldSave: false
                            )
                        }
                        
                        switch fetchedDataResult {
                        case let .success(fetchedData):
                            send(.async(.fetchEventResponse(.success(fetchedData))))
                            await Task.sleep(seconds: 1)
                        case let .failure(error):
                            send(.async(.fetchEventResponse(.failure(CustomError.map(error)))))
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
                            state.endTime = todayEvent.endTime
                            #logDebug("Today's event found: \(todayEvent.id)")
                            if todayEvent.id != "" {
                                if state.loadingQRImage == true {
                                    state.qrCodeReaderText = "QR스캔으로 출석하세요!"
                                }
                            }
                        } else {
                            state.qrCodeReaderText = "오늘은 일정이 없습니다!"
                            #logDebug("No event for today.")
                        }
                    case let .failure(error):
                        #logError("Error fetching data", error)
                    }
                    return .none
                    
                case .observeEvent:
                    return .run {  send in
                        for await result in try await fireStoreUseCase.observeFireBaseChanges(
                            from: .event,
                            as: DDDEvent.self
                        ) {
                            await send(.async(.fetchEventResponse(result)))
                        }
                    }
                    
                case let .updateEventModel(newValue):
                    state.eventModel = []
                    state.eventModel = newValue
                    return .none
                    
                case .generateQRCode:
                    let userID = state.userID
                    let eventID = state.eventID
                    let startTime = state.startTime
                    let endTime = state.endTime
                    return .run { send in
                        if eventID != "" && userID == userID {
                            await send(.async(.fetchEvent))
                            let convertDateString = startTime?.formattedFireBaseDate(date: startTime ?? Date())
                            let convertStringToDate = startTime?.formattedFireBaseStringToDate(dateString: convertDateString ?? "")
                            let convertEndDateString = endTime?.formattedFireBaseDate(date: endTime ?? Date())
                            let convertEndStringToDate = endTime?.formattedFireBaseStringToDate(dateString: convertEndDateString ?? "")
                            let qrCodeGenerateString = String.makeQrCodeValue(
                                userID: userID ?? "",
                                eventID: eventID ?? "",
                                startTime: convertStringToDate ?? Date(),
                                endTime: convertEndStringToDate ?? Date()
                            )
                            let qrCodeImage = await qrCodeUseCase.generateQRCode(from: qrCodeGenerateString)
                            #logDebug(qrCodeGenerateString)
                            await send(.view(.qrCodeGenerated(image: qrCodeImage)))
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
                case .presentSchedule:
                    return .none
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

