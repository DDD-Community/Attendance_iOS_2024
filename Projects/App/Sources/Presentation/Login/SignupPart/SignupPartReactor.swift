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
        var selectedPart: SelectPart?
    }
    
    enum Action {
        case selectPart(SelectPart)
    }
    
    enum Mutation {
        case setPart(SelectPart)
    }
    
    let initialState: State
    
    init(uid: String, name: String) {
        self.initialState = State(
            uid: uid,
            name: name,
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
