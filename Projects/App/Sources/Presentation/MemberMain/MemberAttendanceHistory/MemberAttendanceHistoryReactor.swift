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
        case fetchAttendanceList
    }
    
    enum Mutation {
        case setAttendanceList([Attendance])
    }
    
    struct State {
        var attendanceList: [Attendance] = []
    }
    
    let initialState: State
    private let repository: UserRepositoryProtocol
    
    init() {
        self.initialState = State()
        self.repository = UserRepository()
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .fetchAttendanceList: return fetchAttendanceList()
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
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
}
