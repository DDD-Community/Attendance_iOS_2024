//
//  SignupMemberTeamReactor.swift
//  DDDAttendance
//
//  Created by 고병학 on 9/14/24.
//

import ReactorKit

import Foundation

final class SignupMemberTeamReactor: Reactor {
    struct State {
        var member: MemberRequestModel
        var isSignupSuccess: Bool?
    }
    
    enum Action {
        case didTapNextButton
        case selectTeam(ManagingTeam)
    }
    
    enum Mutation {
        case setTeam(ManagingTeam)
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
        case let .selectTeam(team):
            return .just(.setTeam(team))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case let .setTeam(team):
            newState.member.memberTeam = team
        case let .setSignupSuccess(isSuccess):
            newState.isSignupSuccess = isSuccess
        }
        return newState
    }
}

extension SignupMemberTeamReactor {
    private func signUp() -> Observable<Mutation> {
        let member: Member = .init(
            uid: self.currentState.member.uid,
            memberid: self.currentState.member.uid,
            name: self.currentState.member.name ?? "",
            role: self.currentState.member.memberPart ?? .all,
            memberType: .member,
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
