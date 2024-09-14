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
        var inviteCode: String = ""
        var isCodeValid: Bool?
        var errorMessage: String?
        var memberType: MemberType?
    }
    
    enum Action {
        case updateInviteCode(String)
        case checkCode
        case reset
    }
    
    enum Mutation {
        case setInviteCode(String)
        case setCodeValid(Bool)
        case setCodeMemberType(MemberType)
        case setErrorMessage(String)
        case reset
    }
    
    let initialState: State
    private let repository: UserRepositoryProtocol
    
    init(uid: String) {
        self.initialState = State(uid: uid)
        self.repository = UserRepository()
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .reset:
            return .just(.reset)
        case let .updateInviteCode(inviteCode):
            return .just(.setInviteCode(inviteCode))
        case .checkCode:
            return checkCode()
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        newState.errorMessage = nil
        
        switch mutation {
        case let .setInviteCode(inviteCode):
            newState.inviteCode = inviteCode
        case let .setCodeValid(isValid):
            newState.isCodeValid = isValid
            if !isValid {
                newState.errorMessage = "코드가 유효하지 않아요"
            }
        case let .setErrorMessage(message):
            newState.errorMessage = message
        case let .setCodeMemberType(memberType):
            newState.memberType = memberType
        case .reset:
            newState.isCodeValid = nil
            newState.memberType = nil
        }
        return newState
    }
}

extension SignupInviteCodeReactor {
    private func checkCode() -> Observable<Mutation> {
        return repository
            .validateInviteCode(currentState.inviteCode)
            .asObservable()
            .flatMap { (isValidCode: Bool, isAdmin: Bool?) in
                guard let isAdmin else {
                    return Observable.just(Mutation.setCodeValid(false))
                }
                return Observable.merge(
                    .just(Mutation.setCodeValid(isValidCode)),
                    .just(Mutation.setCodeMemberType(isAdmin ? .coreMember : .member))
                )
            }
            .catch { error in
                print("🚨 \(error)")
                return .just(.setCodeValid(false))
            }
    }
}
