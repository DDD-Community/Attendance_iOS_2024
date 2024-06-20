//
//  QRCheckInReactor.swift
//  DDDAttendance
//
//  Created by 고병학 on 6/11/24.
//

import ReactorKit

import Foundation

final class QRCheckInReactor: Reactor {
    
    struct State {
        var isCheckInSuccess: Bool?
        var profile: Member
    }
    
    enum Action {
        case checkQR(String)
    }
    
    enum Mutation {
        case setCheckInSuccess(Bool)
    }
    
    let initialState: State
    
    init(_ profile: Member) {
        initialState = .init(profile: profile)
    }
    
    /*
     1. 운영진 QR 생성
        1-1) 운영진 UserID + 이벤트 ID + 시간 +
     
     
     */
}

extension QRCheckInReactor {
    private func checkQR(_ qr: String) -> Observable<Mutation> {
        return .empty()
    }
}
