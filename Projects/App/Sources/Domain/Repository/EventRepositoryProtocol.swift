//
//  EventRepositoryProtocol.swift
//  DDDAttendance
//
//  Created by 고병학 on 6/10/24.
//

import RxSwift

import Foundation

import Model

protocol EventRepositoryProtocol {
    func fetchTodayEvent() -> Single<DDDEvent>
    func fetchEventList(generation: Int) -> Single<[DDDEvent]>
    func saveEvent(_ event: DDDEvent) -> Single<Bool>
    func updateEvent(_ event: DDDEvent) -> Single<Bool>
    func removeEvent(_ eventId: String) -> Single<Bool>
}

enum EventRepositoryError: Error {
    case eventNotExist
    case saveEvent
    case updateEvent
}
