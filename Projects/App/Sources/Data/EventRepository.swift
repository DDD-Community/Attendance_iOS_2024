//
//  EventRepository.swift
//  DDDAttendance
//
//  Created by 고병학 on 6/10/24.
//

import Firebase
import RxSwift

import Foundation
import Model

final class EventRepository: EventRepositoryProtocol {
    
    private let firebaseService: FirebaseService = .init()
    
    func fetchTodayEvent() -> Single<DDDEvent> {
        return firebaseService.fetchTodayEvent()
    }
    
    func fetchEventList(generation: Int) -> Single<[DDDEvent]> {
        return firebaseService.fetchEventList(generation: generation)
    }
    
    func saveEvent(_ event: DDDEvent) -> Single<Bool> {
        return firebaseService.saveEvent(event)
    }
    
    func updateEvent(_ event: DDDEvent) -> Single<Bool> {
        return firebaseService.updateEvent(event)
    }
    
    func removeEvent(_ eventId: String) -> Single<Bool> {
        return firebaseService.removeEvent(eventId)
    }
}
