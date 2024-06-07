//
//  SignupInviteCodeReactor.swift
//  DDDAttendance
//
//  Created by 고병학 on 6/8/24.
//

import ReactorKit

import Foundation

final class SignupInviteCodeReactor: Reactor {
    struct State {
        var uid: String
        var name: String
        var part: MemberRoleType
        var inviteCode: String = ""
        var isSignupSuccess: Bool?
    }
    
    enum Action {
        case updateInviteCode(String)
        case signup
    }
    
    enum Mutation {
        case setInviteCode(String)
        case setSignupSuccess(Bool)
    }
    
    let initialState: State
    private let repository: UserRepositoryProtocol
    
    init(
        uid: String,
        name: String,
        part: MemberRoleType
    ) {
        self.initialState = State(uid: uid, name: name, part: part)
        self.repository = UserRepository()
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .updateInviteCode(inviteCode):
            return .just(.setInviteCode(inviteCode))
        case .signup:
            return signup()
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case let .setInviteCode(inviteCode):
            newState.inviteCode = inviteCode
        case let .setSignupSuccess(isSignupSuccess):
            newState.isSignupSuccess = isSignupSuccess
        }
        return newState
    }
}

extension SignupInviteCodeReactor {
    private func signup() -> Observable<Mutation> {
        return repository
            .validateInviteCode(currentState.inviteCode)
            .flatMap { [weak self] isValid -> Single<Bool> in
                guard let self, isValid else {
                    return .just(false)
                }
                let member: Member = .init(
                    uid: self.currentState.uid,
                    name: self.currentState.name,
                    role: self.currentState.part,
                    memberType: .member,
                    createdAt: Date(),
                    updatedAt: Date(),
                    generation: 11
                )
                return self.repository.saveMember(member)
            }
            .map { Mutation.setSignupSuccess($0) }
            .asObservable()
    }
}
