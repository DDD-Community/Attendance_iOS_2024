//
//  CoreMemberTest.swift
//  DDDAttendanceTests
//
//  Created by 서원지 on 6/27/24.
//

import Foundation
import Testing

import ComposableArchitecture
import KeychainAccess
import Service

@testable import DDDAttendance
import XCTest


@MainActor
struct CoreMemberTest {
    let testStore  = TestStore(initialState: CoreMember.State()) {
        CoreMember()
    }
    
    @Test func coreMember_파트선택() async throws {
        let selectPart: SelectPart = .iOS
        await testStore.send(.view(.appearSelectPart(selectPart: selectPart)))
    }
    
    @Test func coreMember_날짜선택() async throws {
        let selectDate : Date = Date.now
        await testStore.send(.selectDate(date: selectDate))
    }

    @Test func fetchCoreMember_리스트테스트() async throws {
        let expectation = XCTestExpectation(description: "유저 리스트 fetch")
        await testStore.send(.async(.fetchMember))
    }
    
    @Test func attendaceModel_업데이트테스트() async throws {
        let expectation = XCTestExpectation(description: "attendaceModel 업데이트")
        let updateDate = Date.now
        let convertDateToString = updateDate.formattedFireBaseDate(date: updateDate)
        let convertStringToDate = updateDate.formattedFireBaseStringToDate(dateString: convertDateToString)
        
        guard let memberID = try? Keychain().get("userID") else {
            return  XCTFail("memberID 를 못가져왔습니다")
        }
        
        await testStore.send(.async(.fetchCurrentUser))
        
        let updateModel = Attendance(
            id: UUID().uuidString,
            memberId: memberID,
            name: "DDD",
            roleType: .iOS,
            eventId: UUID().uuidString,
            createdAt: Date(),
            updatedAt: convertStringToDate,
            attendanceType: .absent,
            generation: 11
        )
        
        await testStore.send(.async(.fetchMember))
        
        await testStore.send(.async(.updateAttendanceModel([updateModel])))
        
        Log.test("테스트 모델", updateModel)
    }
    
    @Test func test_실시간데이터로드() async throws {
        let expectation = XCTestExpectation(description: "유저 데이터 실시간데이터로드")
        await testStore.send(.async(.observeAttendance))
    }
    
    @Test func test_유저정보가져오기() async throws {
        let expectation = XCTestExpectation(description: "로그인한 유저 가져오기")
        await testStore.send(.async(.fetchCurrentUser))
    }
}
