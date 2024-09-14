//
//  SignupMemberTeamReactor.swift
//  DDDAttendance
//
//  Created by 고병학 on 9/14/24.
//

import ReactorKit

import Foundation

final class SignupMemberTeamReactor: Reactor {
    struct State {
        var member: MemberRequestModel
    }
    
    enum Action {
        case selectTeam(ManagingTeam)
    }
    
    enum Mutation {
        case setTeam(ManagingTeam)
    }
    
    let initialState: State
    
    init(member: MemberRequestModel) {
        self.initialState = State(member: member)
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .selectTeam(team):
            return .just(.setTeam(team))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case let .setTeam(team):
            newState.member.memberTeam = team
        }
        return newState
    }
}

