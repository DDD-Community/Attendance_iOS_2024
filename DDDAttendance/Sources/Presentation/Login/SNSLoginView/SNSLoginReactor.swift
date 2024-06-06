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
        var userUID: String?
        var memberType: MemberType?
        
        var errorMessage: String?
    }
    
    enum Action {
        case toggleIsCoreMember(Bool)
        case didTapAppleLogin
        case didTapGoogleLogin
        case checkIsSignedMember(OAuthTokenResponse)
        case checkMemberType(uid: String)
    }
    
    enum Mutation {
        case reset
        case setIsCoreMember(Bool)
        case setOAuthResult(OAuthTokenResponse)
        case setUID(String)
        case setMemberType(MemberType?)
        case setErrorMessage(String)
    }
    
    var initialState: State
    let userRepository: UserRepositoryProtocol
    
    init() {
        initialState = .init()
        userRepository = DefaultUserRepository()
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .toggleIsCoreMember(isCoreMember):
            return .just(.setIsCoreMember(isCoreMember))
        case .didTapAppleLogin:
            return .concat(.just(.reset), login(provider: .APPLE))
        case .didTapGoogleLogin:
            return .concat(.just(.reset), login(provider: .GOOGLE))
        case let .checkIsSignedMember(response):
            return login(response)
        case let .checkMemberType(uid):
            return checkMemberType(uid)
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        newState.errorMessage = nil
        switch mutation {
        case .reset:
            newState = .init()
        case let .setIsCoreMember(isCoreMember):
            newState.isCoreMember = isCoreMember
        case let .setOAuthResult(response):
            newState.oAuthTokenResponse = response
        case let .setUID(UID):
            newState.userUID = UID
        case let .setMemberType(memberType):
            newState.memberType = memberType
        case let .setErrorMessage(message):
            newState.errorMessage = message
        }
        return newState
    }
}

extension SNSLoginReactor {
    private func login(provider: DDDOAuthProvider) -> Observable<Mutation> {
        return provider.service.authorize()
            .map { Mutation.setOAuthResult($0) }
            .asObservable()
    }
    
    private func login(_ response: OAuthTokenResponse) -> Observable<Mutation> {
        guard let credential = response.credential else { return .empty() }
        return FirebaseService().auth(credential)
            .map { Mutation.setUID($0.user.uid) }
            .catch { return .just(.setErrorMessage($0.localizedDescription)) }
            .asObservable()
    }
    
    private func checkMemberType(_ uid: String) -> Observable<Mutation> {
        return userRepository.fetchMember(uid)
            .map { Mutation.setMemberType($0.memberType) }
            .catch { _ in .just(.setMemberType(.notYet)) }
            .asObservable()
    }
}
