//
//  SignupNameReactor.swift
//  DDDAttendance
//
//  Created by 고병학 on 6/8/24.
//

import ReactorKit

import Foundation

final class SignupNameReactor: Reactor {
    struct State {
        var member: MemberRequestModel
    }
    
    enum Action {
        case setName(String)
    }
    
    enum Mutation {
        case setName(String)
    }
    
    var initialState: State
    
    init(
        uid: String,
        memberType: MemberType
    ) {
        let member: MemberRequestModel = .init(
            uid: uid,
            memberType: memberType
        )
        self.initialState = .init(member: member)
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .setName(name):
            return .just(.setName(name))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation {
        case let .setName(name):
            state.member.name = name
        }
        return state
    }
}
