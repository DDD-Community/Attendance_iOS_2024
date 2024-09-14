//
//  SignupCoreMemberRoleReactor.swift
//  DDDAttendance
//
//  Created by 고병학 on 9/14/24.
//

import ReactorKit

import Foundation

final class SignupCoreMemberRoleReactor: Reactor {
    struct State {
        var member: MemberRequestModel
    }
    
    enum Action {
        case selectRole(Managing)
    }
    
    enum Mutation {
        case setRole(Managing)
    }
    
    let initialState: State
    
    init(member: MemberRequestModel) {
        self.initialState = State(member: member)
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .selectRole(role):
            return .just(.setRole(role))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case let .setRole(role):
            newState.member.coreMemberRole = role
        }
        return newState
    }
}
