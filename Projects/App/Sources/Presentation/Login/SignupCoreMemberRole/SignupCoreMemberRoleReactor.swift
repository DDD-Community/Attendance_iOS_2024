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
        var isSignupSuccess: Bool?
    }
    
    enum Action {
        case didTapNextButton
        case selectRole(Managing)
    }
    
    enum Mutation {
        case setRole(Managing)
        case setSignupSuccess(Bool)
    }
    
    let initialState: State
    private let repository: UserRepositoryProtocol
    
    init(member: MemberRequestModel) {
        self.initialState = State(member: member)
        self.repository = UserRepository()
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .didTapNextButton:
            return signUp()
        case let .selectRole(role):
            return .just(.setRole(role))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case let .setRole(role):
            newState.member.coreMemberRole = role
        case let .setSignupSuccess(isSuccess):
            newState.isSignupSuccess = isSuccess
        }
        return newState
    }
}

extension SignupCoreMemberRoleReactor {
    private func signUp() -> Observable<Mutation> {
        let member: Member = .init(
            uid: self.currentState.member.uid,
            memberid: self.currentState.member.uid,
            name: self.currentState.member.name ?? "",
            role: self.currentState.member.memberPart ?? .all,
            memberType: .coreMember,
            manging: self.currentState.member.coreMemberRole,
            memberTeam: self.currentState.member.memberTeam,
            createdAt: Date(),
            updatedAt: Date(),
            generation: 11
        )
        return self.repository.saveMember(member)
            .map { Mutation.setSignupSuccess($0) }
            .catch { error -> Single<Mutation> in
                guard error is UserRepositoryError else {
                    return .just(.setSignupSuccess(false))
                }
                switch error as? UserRepositoryError {
                default: return .just(.setSignupSuccess(false))
                }
            }
            .asObservable()
    }
}
