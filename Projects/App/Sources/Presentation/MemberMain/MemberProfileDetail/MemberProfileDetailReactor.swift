//
//  MemberProfileDetailReactor.swift
//  DDDAttendance
//
//  Created by 고병학 on 7/27/24.
//

import ReactorKit

import Foundation

final class MemberProfileDetailReactor: Reactor {
    enum Action {
        case fetchProfile
        case didTapLogout
    }
    
    enum Mutation {
        case setProfile(Member)
        case setLogoutSuccess(Bool)
    }
    
    struct State {
        var profile: Member?
        var isUserLoggedOut: Bool?
    }
    
    let initialState: State
    private let repository: UserRepositoryProtocol
    
    init() {
        self.initialState = State()
        self.repository = UserRepository()
        action.onNext(.fetchProfile)
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .fetchProfile: return self.fetchMemberProfile()
        case .didTapLogout: return self.logout()
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case let .setProfile(member):
            newState.profile = member
        case let .setLogoutSuccess(success):
            newState.isUserLoggedOut = success
        }
        return newState
    }
}

extension MemberProfileDetailReactor {
    private func fetchMemberProfile() -> Observable<Mutation> {
        return self.repository.fetchMember()
            .map { .setProfile($0) }
            .asObservable()
    }
    
    private func logout() -> Observable<Mutation> {
        return self.repository.logout()
            .map { Mutation.setLogoutSuccess($0) }
            .asObservable()
    }
}
