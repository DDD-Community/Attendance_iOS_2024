//
//  SNSLoginReactor.swift
//  DDDAttendance
//
//  Created by 고병학 on 6/6/24.
//

import ReactorKit

import Foundation

final class SNSLoginReactor: Reactor {
    
    struct State {
        var isCoreMember: Bool = false
        var oAuthTokenResponse: OAuthTokenResponse?
    }
    
    enum Action {
        case toggleIsCoreMember(Bool)
        case didTapAppleLogin
        case didTapGoogleLogin
    }
    
    enum Mutation {
        case setIsCoreMember(Bool)
        case setOAuthResult(OAuthTokenResponse)
    }
    
    var initialState: State
    
    init() {
        initialState = .init()
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .toggleIsCoreMember(isCoreMember):
            return .just(.setIsCoreMember(isCoreMember))
        case .didTapAppleLogin:
            return login(provider: .APPLE)
        case .didTapGoogleLogin:
            return login(provider: .GOOGLE)
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case let .setIsCoreMember(isCoreMember):
            newState.isCoreMember = isCoreMember
        case let .setOAuthResult(response):
            newState.oAuthTokenResponse = response
        }
        return newState
    }
}

extension SNSLoginReactor {
    private func login(provider: OAuthProvider) -> Observable<Mutation> {
        return provider.service.authorize()
            .asObservable()
            .map { .setOAuthResult($0) }
    }
}
