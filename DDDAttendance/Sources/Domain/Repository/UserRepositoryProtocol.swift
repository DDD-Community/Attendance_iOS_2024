//
//  UserRepositoryProtocol.swift
//  DDDAttendance
//
//  Created by 고병학 on 6/6/24.
//

import RxSwift

import Foundation

protocol UserRepositoryProtocol {
    
    /// Firebase Auth의 uid를 이용하여 Member를 가져온다.
    func fetchMember(_ uid: String) -> Single<Member>
    func saveMember(_ member: Member) -> Single<Bool>
    func editMember(_ member: Member) -> Single<Bool>
    
    func fetchAttendanceList(_ userId: String) -> Single<[Attendance]>
    func checkMemberAttendance(_ userId: String, _ time: Date) -> Single<Bool>
    func editMemberAttendance(_ userId: String, _ attendance: Attendance) -> Single<Bool>
    
    func validateInviteCode(_ code: String) -> Single<Bool>
    func fetchInviteCodeList() -> Single<[InvitedCode]>
    func createInviteCode(_ expireDate: Date) -> Single<String>
    func removeInviteCode(_ code: String) -> Single<Bool>
}

enum UserRepositoryError: Error {
    case fetchMember
    case memberNotExist
    case saveMember
    case editMember
    case fetchAttendanceList
    case checkMemberAttendance
    case editMemberAttendance
    case validateInviteCode
    case fetchInviteCodeList
    case createInviteCode
    case removeInviteCode    
}

final class DefaultUserRepository: UserRepositoryProtocol {
        
        func fetchMember(_ uid: String) -> Single<Member> {
            return Single.create { single in
                // Firestore에서 uid를 이용하여 Member를 가져온다.
                single(.failure(UserRepositoryError.fetchMember))
                return Disposables.create()
            }
        }
        
        func saveMember(_ member: Member) -> Single<Bool> {
            return Single.create { single in
                // Firestore에 Member를 저장한다.
                return Disposables.create()
            }
        }
        
        func editMember(_ member: Member) -> Single<Bool> {
            return Single.create { single in
                // Firestore에 Member를 수정한다.
                return Disposables.create()
            }
        }
        
        func fetchAttendanceList(_ userId: String) -> Single<[Attendance]> {
            return Single.create { single in
                // Firestore에서 userId를 이용하여 Attendance List를 가져온다.
                return Disposables.create()
            }
        }
        
        func checkMemberAttendance(_ userId: String, _ time: Date) -> Single<Bool> {
            return Single.create { single in
                // Firestore에서 userId와 time을 이용하여 Attendance를 체크한다.
                return Disposables.create()
            }
        }
        
        func editMemberAttendance(_ userId: String, _ attendance: Attendance) -> Single<Bool> {
            return Single.create { single in
                // Firestore에서 userId와 attendance를 이용하여 Attendance를 수정한다.
                return Disposables.create()
            }
        }
        
        func validateInviteCode(_ code: String) -> Single<Bool> {
            return Single.create { single in
                // Firestore에서 code를 이용하여 Invite Code를 검증한다.
                return Disposables.create()
            }
        }
        
        func fetchInviteCodeList() -> Single<[InvitedCode]> {
            return Single.create { single in
                // Firestore에서 Invite Code List를 가져온다.
                return Disposables.create()
            }
        }
        
        func createInviteCode(_ expireDate: Date) -> Single<String> {
            return Single.create { single in
                // Firestore에 Invite Code를 생성한다.
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
