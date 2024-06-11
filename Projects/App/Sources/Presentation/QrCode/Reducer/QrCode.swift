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
        var userID: String = ""
        var eventID: String = ""
        var creationTime: Date = Date()
        var qrCodeImage: Image? = nil
        var loadingQRImage: Bool = false
        
        public init(userID: String) {
            self.userID = userID
        }
    }
    
    public enum Action: Equatable, BindableAction {
        case appearQRcodeUserid
        case generateQRCode
        case qrCodeGenerated(image: Image?)
        case binding(BindingAction<State>)
        case appearLoading
    }
    
    @Dependency(QrCodeUseCase.self) var qrCodeUseCase
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
                let creationTime = state.creationTime
                
                Log.debug(state.userID, state.eventID, state.creationTime)
                return .run { send in
                    let combinedString = String.combine(userID: userID, eventID: eventID, creationTime: creationTime)
                    let qrCodeImage = await qrCodeUseCase.generateQRCode(from: combinedString)
                    await send(.qrCodeGenerated(image: qrCodeImage))
                }

            case let .qrCodeGenerated(image: qrCodeImage):
                state.qrCodeImage = qrCodeImage
                return .none
                
            case .binding(_):
                return .none
            }
        }
    }
}

