//
//  SignupPartReactor.swift
//  DDDAttendance
//
//  Created by 고병학 on 6/8/24.
//

import ReactorKit

import Foundation

final class SignupPartReactor: Reactor {
    struct State {
        var uid: String
        var name: String
        var isManager: Bool
        var selectedPart: MemberRoleType?
    }
    
    enum Action {
        case selectPart(MemberRoleType)
    }
    
    enum Mutation {
        case setPart(MemberRoleType)
    }
    
    let initialState: State
    
    init(
        uid: String,
        name: String,
        isManager: Bool
    ) {
        self.initialState = State(
            uid: uid,
            name: name,
            isManager: isManager,
            selectedPart: nil
        )
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .selectPart(part):
            return .just(.setPart(part))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case let .setPart(part):
            newState.selectedPart = part
        }
        return newState
    }
}
