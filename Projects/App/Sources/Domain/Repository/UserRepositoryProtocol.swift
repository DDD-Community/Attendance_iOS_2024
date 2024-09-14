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
    func fetchMember() -> Single<Member>
    func fetchMember(_ uid: String) -> Single<Member>
    func saveMember(_ member: Member) -> Single<Bool>
    func editMember(_ member: Member) -> Single<Bool>
    func logout() -> Single<Bool>
    
    func fetchAttendanceList() -> Single<[Attendance]>
    func checkMemberAttendance(_ attendance: Attendance) -> Single<Bool>
    func editMemberAttendance(_ userId: String, _ attendance: Attendance) -> Single<Bool>
    
    func validateInviteCode(_ code: String) -> Single<(Bool, Bool?)>
    func fetchInviteCodeList() -> Single<[InvitedCode]>
    func createInviteCode(_ expireDate: Date) -> Single<String>
    func removeInviteCode(_ code: String) -> Single<Bool>
}

public enum UserRepositoryError: Error {
    case logout
    case fetchMember
    case memberNotExist
    case saveMember
    case editMember
    case fetchAttendanceList
    case checkMemberAttendance
    case todayAttendanceDoesNotExist
    case editMemberAttendance
    case inviteCodeNotExist
    case invalidInviteCode
    case fetchInviteCodeList
    case createInviteCode
    case removeInviteCode
    case saveAttendance
}
