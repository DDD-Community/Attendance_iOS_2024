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
    let testStore = TestStore(initialState: CoreMember.State()) {
        CoreMember()
    } withDependencies: {
        let fireBaseRepository = FireStoreRepository()
        $0.fireStoreUseCase = FireStoreUseCase(repository: fireBaseRepository)
    }
    @Dependency(\.fireStoreUseCase) var fireStoreUseCase

    
    @Test func coreMember_파트선택() async throws {
        // 선택된 파트를 나타냅니다.
        let selectPart: SelectPart = .iOS
        
        // appearSelectPart 액션을 보낸 후 상태 변화를 검증합니다.
        await testStore.send(.view(.appearSelectPart(selectPart: selectPart))) {
            // 기대하는 상태 변화
            $0.selectPart = .iOS
            $0.isActiveBoldText = false
        }
        
    
        // 이후 발생할 액션을 receive로 검증합니다. 여기서는 특정 액션을 기대하지 않으므로 제거 가능합니다.
         testStore.assert { state in
            state.selectPart = selectPart
             state.isActiveBoldText = false
        }
       
        
        
        await testStore.send(.view(.selectPartButton(selectPart: selectPart))) {
            $0.selectPart = .iOS
            $0.isActiveBoldText = true
        }
        
        testStore.assert { state in
           state.selectPart = selectPart
            state.isActiveBoldText = true
       }
       
    }
    
//    @Test func coreMember_날짜선택() async throws {
//        let selectDate : Date = Date.now
//        await testStore.send(.selectDate(date: selectDate))
//    }
//
//    @Test func fetchCoreMember_리스트테스트() async throws {
//        let expectation = XCTestExpectation(description: "유저 리스트 fetch")
//        await testStore.send(.async(.fetchMember))
//    }
//    
//    @Test func attendaceModel_업데이트테스트() async throws {
//        let expectation = XCTestExpectation(description: "attendaceModel 업데이트")
//        let updateDate = Date.now
//        let convertDateToString = updateDate.formattedFireBaseDate(date: updateDate)
//        let convertStringToDate = updateDate.formattedFireBaseStringToDate(dateString: convertDateToString)
//        
//        guard let memberID = try? Keychain().get("userID") else {
//            return  XCTFail("memberID 를 못가져왔습니다")
//        }
//        
//        await testStore.send(.async(.fetchCurrentUser))
//        
//        let updateModel = Attendance(
//            id: UUID().uuidString,
//            memberId: memberID,
//            name: "DDD",
//            roleType: .iOS,
//            eventId: UUID().uuidString,
//            createdAt: Date(),
//            updatedAt: convertStringToDate,
//            status: .absent,
//            generation: 11
//        )
//        
//        await testStore.send(.async(.fetchMember))
//        
////        await testStore.send(.async(.updateAttendanceModel([updateModel])))
//        
//        Log.test("테스트 모델", updateModel)
//    }
//    
//    @Test func test_실시간데이터로드() async throws {
//        let expectation = XCTestExpectation(description: "유저 데이터 실시간데이터로드")
//        await testStore.send(.async(.observeAttendance))
//    }
//    
//    @Test func test_유저정보가져오기() async throws {
//        let expectation = XCTestExpectation(description: "로그인한 유저 가져오기")
//        await testStore.send(.async(.fetchCurrentUser))
//    }
}
