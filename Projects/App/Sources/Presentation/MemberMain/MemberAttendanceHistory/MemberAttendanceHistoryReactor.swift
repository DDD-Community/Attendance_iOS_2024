//
//  MemberAttendanceHistoryReactor.swift
//  DDDAttendance
//
//  Created by 고병학 on 6/27/24.
//

import ReactorKit

import Model
import Foundation

final class MemberAttendanceHistoryReactor: Reactor {
    enum Action {
        case fetchProfile
        case fetchAttendanceList
    }
    
    enum Mutation {
        case setProfile(Member)
        case setEvents([DDDEvent])
        case setAttendanceList([Attendance])
    }
    
    struct State {
        var profile: Member?
        var events: [DDDEvent] = []
        var attendanceList: [Attendance] = []
    }
    
    let initialState: State
    private let repository: UserRepositoryProtocol
    private let eventRepository: EventRepositoryProtocol
    
    init() {
        self.initialState = State()
        self.repository = UserRepository()
        self.eventRepository = EventRepository()
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
        case let .setEvents(events):
            newState.events = events
        case let .setAttendanceList(attendanceList):
            newState.attendanceList = attendanceList.map { attendance in
                var attendance: Attendance = attendance
                attendance.name = newState.events
                    .filter({ $0.id == attendance.eventId })
                    .first?.name ?? ""
                return attendance
            }
        }
        return newState
    }
}

extension MemberAttendanceHistoryReactor {
    private func fetchAttendanceList() -> Observable<Mutation> {
        self.eventRepository
            .fetchEventList(generation: 11)
            .asObservable()
            .flatMap { [weak self] events -> Observable<Mutation> in
                guard let self else { return .empty() }
                let fetchAttendance: Observable<Mutation> = self.repository
                    .fetchAttendanceList()
                    .asObservable()
                    .map { Mutation.setAttendanceList($0) }
                return .concat(
                    .just(.setEvents(events)),
                    fetchAttendance
                )
            }
    }
    
    private func fetchMemberProfile() -> Observable<Mutation> {
        return repository.fetchMember()
            .map { Mutation.setProfile($0) }
            .asObservable()
    }
}
