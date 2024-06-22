//
//  SplashReactor.swift
//  DDDAttendance
//
//  Created by 고병학 on 6/8/24.
//

import FirebaseAuth
import ReactorKit

import Foundation

final class SplashReactor: Reactor {
    
    struct State {
        var memberType: MemberType?
    }
    
    enum Action {
        case fetchSignedUser
    }
    
    enum Mutation {
        case setMemberType(MemberType)
    }
    
    let initialState: State
    private let repository: UserRepositoryProtocol
    
    init() {
        self.initialState = .init()
        self.repository = UserRepository()
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .fetchSignedUser: return fetchSignedUser()
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case let .setMemberType(memberType):
            newState.memberType = memberType
        }
        return newState
    }
    
    private func fetchSignedUser() -> Observable<Mutation> {
        return self.repository.fetchMember()
            .map { .setMemberType($0.memberType) }
            .asObservable()
            .catch { error in
                print(error)
                return .just(.setMemberType(.notYet))
            }
    }
}
