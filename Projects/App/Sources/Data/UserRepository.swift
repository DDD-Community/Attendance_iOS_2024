//
//  UserRepository.swift
//  DDDAttendance
//
//  Created by 고병학 on 6/8/24.
//

import RxSwift

import Foundation

final class UserRepository: UserRepositoryProtocol {
    
    private let firebaseService = FirebaseService()
    
    /// Firestore에서 uid를 이용하여 Member를 가져온다.
    func fetchMember() -> Single<Member> {
        return firebaseService.fetchUID()
            .flatMap { [weak self] uid in
                guard let self else { throw UserRepositoryError.fetchMember }
                return self.firebaseService.fetchMember(uid)
            }
    }
    
    func fetchMember(_ uid: String) -> Single<Member> {
        return self.firebaseService.fetchMember(uid)
    }
    
    /// Firestore에 Member를 저장한다.
    func saveMember(_ member: Member) -> Single<Bool> {
        return firebaseService.saveMember(member)
    }
    
    func editMember(_ member: Member) -> Single<Bool> {
        return Single.create { single in
            // Firestore에 Member를 수정한다.
            return Disposables.create()
        }
    }
    
    func logout() -> Single<Bool> {
        return firebaseService.logout()
    }
    
    func fetchAttendanceList() -> Single<[Attendance]> {
        return firebaseService.fetchUID()
            .flatMap { [weak self] uid in
                guard let self else { throw UserRepositoryError.fetchMember }
                return self.firebaseService.fetchAttendanceHistory(uid)
            }
    }
    
    func checkMemberAttendance(_ attendance: Attendance) -> Single<Bool> {
        return firebaseService.saveAttendance(attendance)
    }
    
    func editMemberAttendance(_ userId: String, _ attendance: Attendance) -> Single<Bool> {
        return Single.create { single in
            // Firestore에서 userId와 attendance를 이용하여 Member의 출석 여부를 수정한다.
            return Disposables.create()
        }
    }
    
    func validateInviteCode(_ code: String) -> Single<(Bool, Bool?)> {
        return firebaseService.validateInviteCode(code)
    }
    
    func fetchInviteCodeList() -> Single<[InvitedCode]> {
        return Single.create { single in
            // Firestore에서 Invite Code List를 가져온다.
            return Disposables.create()
        }
    }
    
    func createInviteCode(_ expireDate: Date) -> Single<String> {
        return Single.create { single in
            // Firestore에 expireDate를 이용하여 Invite Code를 생성한다.
            return Disposables.create()
        }
    }
    
    func removeInviteCode(_ code: String) -> Single<Bool> {
        return Single.create { single in
            // Firestore에서 code를 이용하여 Invite Code를 삭제한다.
            return Disposables.create()
        }
    }
    
}
