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
        var userID: String? = ""
        var eventID: String? = ""
        var startTime: Date? = Date.now
        var qrCodeImage: Image? = nil
        var loadingQRImage: Bool = false
        var qrCodeReaderText: String = ""
        var eventModel: [DDDEvent] = []
        
        
        public init(userID: String? = nil, startTime: Date? = nil, eventID: String? = nil) {
            self.userID = userID
            self.startTime = startTime
            self.eventID = eventID
        }
    }
    
    public enum Action: BindableAction {
        case appearQRcodeUserid
        case generateQRCode
        case qrCodeGenerated(image: Image?)
        case binding(BindingAction<State>)
        case appearLoading
        case fetchEvent
        case fetchEventResponse(Result<[DDDEvent], CustomError>)
    }
    
    @Dependency(QrCodeUseCase.self) var qrCodeUseCase
    @Dependency(FireStoreUseCase.self) var fireStoreUseCase
    @Dependency(\.continuousClock) var clock
    
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
                    if eventID != "" {
                        await send(.fetchEvent)
                        let qrCodeGenerateString = String.combine(userID: userID ?? "", eventID: eventID ?? "", creationTime: startTime ?? Date())
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
                var userID = state.userID
                var eventID = state.eventID
                let startTime = state.startTime
                
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
                    state.eventID = state.eventModel.first?.id
                    let convertDate = (state.eventModel.first?.startTime.formattedDate(date: state.eventModel.first?.startTime ?? Date()) ?? "") +  (state.eventModel.first?.startTime.formattedTime(date: state.eventModel.first?.startTime ?? Date()) ?? "")
                    
                    state.startTime = convertDate.stringToTimeAndDate(convertDate)
                case let .failure(error):
                    Log.error("Error fetching data", error)
                }
                return .none
            }
        }
        
    }
}

