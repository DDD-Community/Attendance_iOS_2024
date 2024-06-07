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
        var name: String = ""
        var uid: String
    }
    
    enum Action {
        case setName(String)
    }
    
    enum Mutation {
        case setName(String)
    }
    
    var initialState: State
    
    init(uid: String) {
        self.initialState = .init(uid: uid)
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
            state.name = name
        }
        return state
    }
}
