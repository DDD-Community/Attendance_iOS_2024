//
//  FirebaseService.swift
//  DDDAttendance
//
//  Created by 고병학 on 6/6/24.
//

import FirebaseAuth
import FirebaseFirestore
import RxSwift

import Shareds
import Model

import Foundation

final class FirebaseService {
    
    // MARK: - Invite code
    func validateInviteCode(_ code: String) -> Single<(Bool, Bool?)> {
        return Single.create { single in
            let db = Firestore.firestore()
            let inviteCodesRef = db.collection("invite_code")
            inviteCodesRef.whereField("code", isEqualTo: code).getDocuments { (querySnapshot, error) in
                var result: (Bool, Bool?) = (false, nil)
                if error != nil {
                    single(.success(result))
                    return
                }
                guard let documents = querySnapshot?.documents,
                      !documents.isEmpty,
                      let timeStamp = documents.first?.data()["expired_date"] as? Timestamp,
                      timeStamp.seconds > Int(Date().timeIntervalSince1970),
                      let isAdmin: Bool = documents.first?.data()["is_admin"] as? Bool
                else {
                    single(.failure(UserRepositoryError.invalidInviteCode))
                    return
                }
                result = (true, isAdmin)
                single(.success(result))
            }
            return Disposables.create()
        }
    }
    
    // MARK: - Member
    func logout() -> Single<Bool> {
        return Single.create { single in
            do {
                try Auth.auth().signOut()
                single(.success(true))
            } catch {
                single(.failure(UserRepositoryError.logout))
            }
            return Disposables.create()
        }
    }
    
    func fetchUID() -> Single<String> {
        return Single.create { single in
            guard let uid: String = Auth.auth().currentUser?.uid else {
                single(.failure(UserRepositoryError.memberNotExist))
                return Disposables.create()
            }
            single(.success(uid))
            return Disposables.create()
        }
    }
    
    func fetchMember(_ uid: String) -> Single<Member> {
        return Single.create { single in
            let db = Firestore.firestore()
            let userRef = db.collection("members").document(uid)
            userRef.getDocument { document, error in
                guard let document = document,
                      document.exists else {
                    single(.failure(UserRepositoryError.memberNotExist))
                    return
                }
                let data = document.data()
                let name: String = data?["name"] as? String ?? ""
                let roleType: String = data?["roleType"] as? String ?? ""
                let memberType: String = data?["memberType"] as? String ?? ""
                let createdAt: Date = data?["createdAt"] as? Date ?? Date()
                let updatedAt: Date = data?["updatedAt"] as? Date ?? Date()
                let generation: Int = data?["generation"] as? Int ?? 0
                let manging: String = data?["manging"] as? String ?? ""
                let memberTeam: String = data?["memberTeam"] as? String ?? ""
                let member: Member = .init(
                    uid: uid,
                    memberid: uid,
                    name: name,
                    role: SelectPart(rawValue: roleType) ?? .iOS,
                    memberType: MemberType(rawValue: memberType) ?? .notYet,
                    manging: Managing(rawValue: manging) ?? .notManging,
                    memberTeam: ManagingTeam(rawValue: memberTeam) ?? .notTeam,
                    createdAt: createdAt,
                    updatedAt: updatedAt,
                    generation: generation
                )
                single(.success(member))
            }
            return Disposables.create()
        }
    }
    
    func saveMember(_ member: Member) -> Single<Bool> {
        return Single.create { single in
            let db = Firestore.firestore()
            let userRef = db.collection("members").document(member.uid)
            
            let data: [String: Any] = [
                "name": member.name,
                "memberId" : member.memberid,
                "roleType": member.role.desc,
                "memberType": member.memberType.rawValue,
                "manging": member.manging?.rawValue ?? "",
                "memberTeam": member.memberTeam?.rawValue ?? "",
                "createdAt": member.createdAt,
                "updatedAt": member.updatedAt,
                "generation": member.generation
            ]
            userRef.setData(data) { error in
                guard error == nil else {
                    single(.failure(UserRepositoryError.saveMember))
                    return
                }
                single(.success(true))
            }
            return Disposables.create()
        }
    }
    
    // MARK: - Attendance
    func saveAttendance(_ attendance: Attendance) -> Single<Bool> {
        return Single.create { single in
            let db = Firestore.firestore()
            let attendanceRef = db.collection("attendance").document(attendance.id ?? "")
            let data: [String: Any] = [
                "id": attendance.id ?? "",
                "memberId": attendance.memberId ?? "",
                "eventId": attendance.eventId,
                "name": attendance.name,
                "date": Timestamp(date: attendance.createdAt),
                "updatedAt": Timestamp(date: attendance.updatedAt),
                "status": attendance.status?.rawValue ?? .none ?? "",
                "generation": attendance.generation,
                "memberType": attendance.memberType?.rawValue ?? .none ?? "",
                "roleType": attendance.roleType.rawValue
            ]
            attendanceRef.setData(data) { error in
                guard error == nil else {
                    single(.failure(UserRepositoryError.saveAttendance))
                    return
                }
                single(.success(true))
            }
            return Disposables.create()
        }
    }
    
    func fetchAttendanceHistory(_ uid: String) -> Single<[Attendance]> {
        return Single.create { single in
            let db = Firestore.firestore()
            let attendanceRef = db.collection("attendance").whereField("memberId", isEqualTo: uid)
            attendanceRef.getDocuments {
                querySnapshot,
                error in
                guard let documents = querySnapshot?.documents else {
                    single(.failure(UserRepositoryError.fetchAttendanceList))
                    return
                }
                let attendances: [Attendance] = documents.compactMap { document in
                    let data = document.data()
                    let id: String = data["id"] as? String ?? ""
                    let name: String = data["name"] as? String ?? ""
                    let memberId: String = data["memberId"] as? String ?? ""
                    let eventId: String = data["eventId"] as? String ?? ""
                    let createdAt: Date = (data["date"] as? Timestamp)?.dateValue() ?? Date()
                    let updatedAt: Date = (data["updatedAt"] as? Timestamp)?.dateValue() ?? Date()
                    let status: AttendanceType = AttendanceType(rawValue: data["status"] as? String ?? "") ?? .absent
                    let generation: Int = data["generation"] as? Int ?? 0
                    let memberType: MemberType = MemberType(rawValue: data["memberType"] as? String ?? "") ?? .member
                    let roleType : SelectPart = SelectPart(rawValue:  data["roleType"] as? String ?? "") ?? .all
                    return Attendance(
                        id: id,
                        memberId: memberId,
                        memberType: memberType,
                        name: name,
                        roleType: roleType,
                        eventId: eventId,
                        createdAt: createdAt,
                        updatedAt: updatedAt,
                        status: status,
                        generation: generation
                    )
                }
                single(.success(attendances))
            }
            return Disposables.create()
        }
    }
    
    // MARK: - Event
    func fetchTodayEvent() -> Single<DDDEvent> {
        return Single.create { [weak self] single in
            let db = Firestore.firestore()
            let eventRef = db.collection("events")
                .whereField("startTime", isGreaterThan: Date().startOfDay)
                .whereField("startTime", isLessThan: Date().endOfDay)
            eventRef.getDocuments { querySnapshot, error in
                guard let documents = querySnapshot?.documents,
                      !documents.isEmpty,
                      let data = documents.first?.data(),
                      let event = self?.convertEventData(data) else {
                    single(.failure(EventRepositoryError.eventNotExist))
                    return
                }
                single(.success(event))
            }
            return Disposables.create()
        }
    }
    
    func fetchEventList(generation: Int) -> Single<[DDDEvent]> {
        return Single.create { [weak self] single in
            let db = Firestore.firestore()
            let eventRef = db.collection("events").whereField("generation", isEqualTo: generation)
            eventRef.getDocuments { querySnapshot, error in
                guard let documents = querySnapshot?.documents else {
                    single(.failure(EventRepositoryError.eventNotExist))
                    return
                }
                let events: [DDDEvent] = documents.compactMap { document in
                    let data = document.data()
                    return self?.convertEventData(data)
                }
                single(.success(events))
            }
            return Disposables.create()
        }
    }
    
    func saveEvent(_ event: DDDEvent) -> Single<Bool> {
        return Single.create { [weak self] single in
            let db = Firestore.firestore()
            guard event.id != nil else {
                single(.failure(EventRepositoryError.saveEvent))
                return Disposables.create()
            }
            let eventRef = db.collection("events").document()
            let data: [String: Any] = self?.convertEvent(event) ?? [:]
            eventRef.setData(data) { error in
                guard error == nil else {
                    single(.failure(EventRepositoryError.saveEvent))
                    return
                }
                single(.success(true))
            }
            return Disposables.create()
        }
    }
    
    func updateEvent(_ event: DDDEvent) -> Single<Bool> {
        return Single.create { [weak self] single in
            let db = Firestore.firestore()
            guard let eventId: String = event.id else {
                single(.failure(EventRepositoryError.updateEvent))
                return Disposables.create()
            }
            let eventRef = db.collection("events").document(eventId)
            let data: [String: Any] = self?.convertEvent(event) ?? [:]
            eventRef.updateData(data) { error in
                guard error == nil else {
                    single(.failure(EventRepositoryError.updateEvent))
                    return
                }
                single(.success(true))
            }
            return Disposables.create()
        }
    }
    
    func removeEvent(_ eventId: String) -> Single<Bool> {
        return Single.create { single in
            let db = Firestore.firestore()
            let eventRef = db.collection("events").document(eventId)
            eventRef.delete { error in
                guard error == nil else {
                    single(.failure(EventRepositoryError.saveEvent))
                    return
                }
                single(.success(true))
            }
            return Disposables.create()
        }
    }
    
    // MARK: - Auth
    func auth(_ credential: AuthCredential) -> Single<AuthDataResult> {
        return Single.create { single in
            Auth.auth().signIn(with: credential) { authResult, error in
                if let authResult {
                    single(.success(authResult))
                } else {
                    single(.failure(error ?? OAuthError.firebaseLoginError))
                }
            }
            return Disposables.create()
        }
    }
    
}

extension FirebaseService {
    private func convertEventData(_ data: [String: Any]?) -> DDDEvent {
        let id: String = data?["id"] as? String ?? ""
        let name: String = data?["name"] as? String ?? ""
        let description: String = data?["description"] as? String ?? ""
        let startTime: Date = (data?["startTime"] as? Timestamp)?.dateValue() ?? Date()
        let endTime: Date = (data?["endTime"] as? Timestamp)?.dateValue() ?? Date()
        let generation: Int = data?["generation"] as? Int ?? 0
        return DDDEvent(
            id: id,
            name: name,
            description: description,
            startTime: startTime,
            endTime: endTime,
            generation: generation
        )
    }
    
    private func convertEvent(_ event: DDDEvent) -> [String: Any] {
        return [
            "id": event.id as Any,
            "name": event.name,
            "description": event.description as Any,
            "startTime": Timestamp(date: event.startTime),
            "endTime": Timestamp(date: event.endTime),
            "generation": event.generation as Any
        ]
    }
}
