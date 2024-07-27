//
//  MemberAttendanceHistoryReactor.swift
//  DDDAttendance
//
//  Created by 고병학 on 6/27/24.
//

import ReactorKit

import Foundation

final class MemberAttendanceHistoryReactor: Reactor {
    enum Action {
        case fetchProfile
        case fetchAttendanceList
    }
    
    enum Mutation {
        case setProfile(Member)
        case setAttendanceList([Attendance])
    }
    
    struct State {
        var profile: Member?
        var attendanceList: [Attendance] = []
    }
    
    let initialState: State
    private let repository: UserRepositoryProtocol
    
    init() {
        self.initialState = State()
        self.repository = UserRepository()
        action.onNext(.fetchProfile)
        action.onNext(.fetchAttendanceList)
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .fetchProfile: return fetchMemberProfile()
        case .fetchAttendanceList: return fetchAttendanceList()
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case let .setProfile(member):
            newState.profile = member
        case let .setAttendanceList(attendanceList):
            newState.attendanceList = attendanceList
        }
        return newState
    }
}

extension MemberAttendanceHistoryReactor {
    private func fetchAttendanceList() -> Observable<Mutation> {
        return repository.fetchAttendanceList()
            .map { Mutation.setAttendanceList($0) }
            .asObservable()
    }
    
    private func fetchMemberProfile() -> Observable<Mutation> {
        return repository.fetchMember()
            .map { Mutation.setProfile($0) }
            .asObservable()
    }
}
