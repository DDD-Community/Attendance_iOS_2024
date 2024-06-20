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
        var part: SelectPart
        var isManager: Bool
        var inviteCode: String = ""
        var isSignupSuccess: Bool?
        var errorMessage: String?
    }
    
    enum Action {
        case updateInviteCode(String)
        case signup
    }
    
    enum Mutation {
        case setInviteCode(String)
        case setSignupSuccess(Bool)
        case setErrorMessage(String)
    }
    
    let initialState: State
    private let repository: UserRepositoryProtocol
    
    init(
        uid: String,
        name: String,
        isManager: Bool,
        part: SelectPart
    ) {
        self.initialState = State(
            uid: uid,
            name: name,
            part: part,
            isManager: isManager
        )
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
        case let .setErrorMessage(message):
            newState.errorMessage = message
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
                    memberType: self.currentState.isManager ? .coreMember : .member,
                    createdAt: Date(),
                    updatedAt: Date(),
                    generation: 11
                )
                return self.repository.saveMember(member)
            }
            .map { Mutation.setSignupSuccess($0) }
            .catch { error -> Single<Mutation> in
                guard error is UserRepositoryError else {
                    return .just(.setSignupSuccess(false))
                }
                switch error as! UserRepositoryError {
                case .invalidInviteCode:
                    return .just(.setErrorMessage("유효하지 않은 코드입니다."))
                default:
                    return .just(.setSignupSuccess(false))
                }
            }
            .asObservable()
    }
}
