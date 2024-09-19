//
//  QRCheckInReactor.swift
//  DDDAttendance
//
//  Created by 고병학 on 6/11/24.
//

import ReactorKit

import Model
import Foundation

final class QRCheckInReactor: Reactor {
    
    struct State {
        var isCheckInSuccess: Bool?
        var profile: Member
        var isLoading: Bool = false
    }
    
    enum Action {
        case checkQR(String)
    }
    
    enum Mutation {
        case setCheckInSuccess(Bool)
        case setLoading(Bool)
    }
    
    let initialState: State
    private let userRepository: UserRepositoryProtocol
    private let eventRepository: EventRepositoryProtocol
    
    init(_ profile: Member) {
        self.initialState = .init(profile: profile)
        self.userRepository = UserRepository()
        self.eventRepository = EventRepository()
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .checkQR(let qr):
            let qrComponents: [String] = qr.components(separatedBy: "+")
            guard let coreMemberId: String = qrComponents[safe: 0],
                  let eventId: String = qrComponents[safe: 1],
                  let startTime: String = qrComponents[safe: 2],
                  let endTime: String = qrComponents[safe: 3] else {
                return .just(.setCheckInSuccess(false))
            }
            return .concat(
                .just(.setLoading(true)),
                checkQR(coreMemberId, eventId, startTime, endTime)
            )
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setCheckInSuccess(let isSuccess):
            newState.isCheckInSuccess = isSuccess
            newState.isLoading = false
       
        case .setLoading(let isLoading):
            newState.isLoading = isLoading
        }
        return newState
    }
}

extension QRCheckInReactor {
    private func checkQR(
        _ memberId: String,
        _ eventId: String,
        _ startTime: String,
        _ endTime: String
    ) -> Observable<Mutation> {
        return self.userRepository.fetchMember(memberId)
            .flatMap { [weak self] member in
                guard let self,
                      [MemberType.coreMember, .master].contains(member.memberType) else {
                    throw QRCheckInError.checkMember
                }
                return self.eventRepository.fetchTodayEvent()
            }
            .asObservable()
            .flatMap { [weak self] (event: DDDEvent) in
                guard let self,
                      let id: String = event.id,
                      eventId == id,
                      let attendanceType: AttendanceType = self.checkTime(startTime) else {
                    throw QRCheckInError.checkEvent
                }
                return self.checkIn(eventId, attendanceType)
            }
            .catch { error in
                print(error)
                return .just(.setCheckInSuccess(false))
            }
    }
    
    private func checkIn(
        _ eventId: String,
        _ attendanceType: AttendanceType
    ) -> Observable<Mutation> {
        let member: Member = currentState.profile
        let attendance: Attendance = .init(
            id: UUID().uuidString,
            memberId: member.uid,
            memberType: member.memberType,
            name: member.name,
            roleType: member.role,
            eventId: eventId,
            createdAt: .init(),
            updatedAt: .init(),
            status: attendanceType,
            generation: member.generation
        )
        return self.userRepository.checkMemberAttendance(attendance)
            .map { _ in .setCheckInSuccess(true) }
            .asObservable()
            .catch { error in
                print(error)
                return .just(.setCheckInSuccess(false))
            }
    }
    
    private func checkTime(_ startTime: String) -> AttendanceType? {
        let currentTime: Date = .init()
        let dateFormatter: DateFormatter = .init()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        guard let startDate: Date = dateFormatter.date(from: startTime) else { return nil }
        var attendanceType: AttendanceType?
        if currentTime.timeIntervalSince(startDate) <= 60 * 10 {
            attendanceType = .present
        } else if currentTime.timeIntervalSince(startDate) <= 60 * 60 * 2 {
            attendanceType = .late
        } else if currentTime.timeIntervalSince(startDate) > 60 * 60 * 2 {
            attendanceType = .absent
        }
        return attendanceType
    }
}

enum QRCheckInError: Error {
    case checkMember
    case checkEvent
    case checkIn
}
