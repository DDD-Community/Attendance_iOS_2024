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

extension Tag {
    @Tag static var selectPartTest: Self
}

@Suite(.tags(.selectPartTest))
//@MainActor
struct CoreMemberTest {
    @MainActor let testStore = TestStore(initialState: CoreMember.State()) {
        CoreMember()
    } withDependencies: {
        let fireBaseRepository = FireStoreRepository()
        $0.fireStoreUseCase = FireStoreUseCase(repository: fireBaseRepository)
    }
    
    var mockAttendanceData = Attendance.mockData()
    let mockMemberData = Attendance.mockMemberData()
    let testScheduler = DispatchQueue.test
    
    @Test("member_파트선택_성공", .tags(.selectPartTest))
    func coreMember_파트선택() async throws {
        // 선택된 파트를 나타냅니다.
        let expectation = XCTestExpectation(description: "member_파트선택")
        let selectPart: SelectPart? = .iOS
        
        // appearSelectPart 액션을 보낸 후 상태 변화를 검증합니다.
        await testStore.send(.view(.appearSelectPart(selectPart: selectPart ?? .all))) {
            // 기대하는 상태 변화
            $0.selectPart = .iOS
            $0.isActiveBoldText = false
        }
        
        // 이후 발생할 액션을 receive로 검증합니다. 여기서는 특정 액션을 기대하지 않으므로 제거 가능합니다.
        await testStore.assert { state in
            #expect(state.selectPart == selectPart)
            #expect(state.isActiveBoldText == false)
        }
        
        
        await testStore.send(.view(.selectPartButton(selectPart: selectPart ?? .all))) {
            $0.selectPart = .iOS
            $0.isActiveBoldText = true
        }
        
        await testStore.assert { state in
            #expect(state.selectPart == selectPart)
            #expect(state.isActiveBoldText == true)
        }
        XCTAssertNil(expectation)
        
//        await testStore.finish()
//        testStore.exhaustivity = .off
    }
    
    
    @Test("다음 파트로 선택 swipe 테스트", .tags(.selectPartTest))
    func member_다음파트로선택swipe() async throws {
          
        await testStore.send(.view(.selectPartButton(selectPart: .pm))) {
            $0.selectPart = .pm
            $0.isActiveBoldText = true
        }
        
        await testStore.send(.view(.swipeNext)) {
            $0.selectPart = .design
        }
        
        await testStore.assert { state in
            #expect(state.selectPart == .design, "파트 변경 이 되었는지")
            #expect(state.isActiveBoldText == true , "선택이 되면서 텍스트가 볼트 가 되었느지")
        }
        
    }
    
    @Test("이전 파트로 돌아가기 swipePrevious 테스트", .tags(.selectPartTest))
    func member_이전파트로돌아가기swipePrevious() async throws {
        await testStore.send(.view(.selectPartButton(selectPart: .design))) {
            $0.selectPart = .design
            $0.isActiveBoldText = true
        }
        
        await testStore.send(.view(.swipePrevious)) {
            $0.selectPart = .pm
        }
    }
    
    @Test("출석 데이터 관리 mockData 테스트")
    func member_출석mock데이터추가() async throws {
        await testStore.send(.async(.fetchAttendanceDataResponse(.success(mockAttendanceData)))) {
            let selectedDate = Calendar.current.startOfDay(for: $0.selectDate)
            let updatedMockAttendanceData = mockAttendanceData.map { attendance in
                var modifiedAttendance = attendance
                if !Calendar.current.isDate(attendance.updatedAt, inSameDayAs: selectedDate) {
                    modifiedAttendance.status = .notAttendance
                }
                return modifiedAttendance
            }
            
            $0.attendanceCheckInModel = updatedMockAttendanceData
        }
        
        await testStore.assert { state in
            var updatedAttendanceCheckInModel = state.attendanceCheckInModel.map { attendance in
                let modifiedAttendance = attendance
                if modifiedAttendance.roleType == .android && modifiedAttendance.roleType == .iOS {
                    #expect(modifiedAttendance.status == .notAttendance, "Expected Android attendance status to be .notAttendance")
                    #expect(modifiedAttendance.status == .notAttendance, "Expected iOS attendance status to be .notAttendance")
                }
                return modifiedAttendance
            }
            #expect(updatedAttendanceCheckInModel == state.attendanceCheckInModel , "Expected attendance model to be updated accordingly")
            updatedAttendanceCheckInModel = mockAttendanceData
        }
        
        // 실패 케이스를 위한 새로운 상태
        let unexpectedAttendanceData = mockAttendanceData.map { attendance in
            var modifiedAttendance = attendance
            // 상태를 일부러 잘못 설정
            modifiedAttendance.status = .present
            return modifiedAttendance
        }
        
        // 실패 케이스에서 상태를 검증하여 기대와 다르게 설정되었는지 확인
        await testStore.assert { state in
            let failedAttendanceCheckInModel = state.attendanceCheckInModel.map { attendance in
                let modifiedAttendance = attendance
                #expect(modifiedAttendance.status != .present,  "status가 달라 매칭이 안되어 있는지 확인")
                return modifiedAttendance
            }
            #expect(failedAttendanceCheckInModel != unexpectedAttendanceData , "데이터가 달라서 모델 매칭 안되는지 확인")
        }
        
        await testStore.finish()
         testStore.exhaustivity = .off
        
    }
    
    @Test("출석 날짜 필터링 테스트")
    func coreMember_날짜선택() async throws {
        let selectDate = await testStore.state.selectDate
        
        await testStore.send(.selectDate(date: selectDate)) {
            $0.selectDate = selectDate
            $0.selectDatePicker = true
            $0.isDateSelected = true
        }
        testStore.exhaustivity = .off
        
        let filterAttendanceData = mockAttendanceData.filter {
            $0.updatedAt.formattedDateToString() == selectDate.formattedDateToString()
        }
        await testStore.send(.async(.fetchAttendanceDataResponse(.success(filterAttendanceData)))) {
            $0.attendanceCheckInModel = filterAttendanceData
            #expect($0.attendanceCheckInModel == filterAttendanceData, "'출석 모델 필터링 테스트")
        }
        
        await testStore.assert { state in
            #expect(state.attendanceCheckInModel == filterAttendanceData, "필터링 된 모델이 매칭 되는지")
            #expect(state.selectDate == selectDate, "날짜가 매칭이 되는지")
            #expect(state.selectDatePicker == true, "날짜 피커를 선택 한게 매칭이 되었는지")
            #expect(state.isDateSelected == true, "날짜 선택 한게 매칭이 되었는지 ")
        }
        
        
        await testStore.send(.view(.updateAttendanceCountWithData(attendances: filterAttendanceData))) {
            $0.attendanceCount = filterAttendanceData.count
            #expect($0.attendanceCount == filterAttendanceData.count, "출석 된수가 매칭이 되는 지")
        }
        
        await testStore.assert { state in
            #expect(state.attendanceCount == filterAttendanceData.count, "출석 된수가 매칭이 되는 지")
        }
        
        await testStore.finish()
        testStore.exhaustivity = .off
        
    }
    
    @Test("출석 날짜 다르게 테스트")
    func member_출석날짜를현재날짜말고_다른날짜로변경() async throws {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        guard let selectDateSecond = dateFormatter.date(from: "2024-09-16") else {
            fatalError("Invalid date format")
        }
        var date = testStore.state.selectDate
        date = selectDateSecond
        
        var filterAttendanceData = mockAttendanceData.filter {
            $0.updatedAt.formattedDateToString() == date.formattedDateToString()
        }
        
        await testStore.send(.selectDate(date: date)) {
            $0.selectDate = date
            $0.selectDatePicker = true
            $0.isDateSelected = true
        }
        testStore.exhaustivity = .off
        
        await testStore.send(.async(.fetchAttendanceDataResponse(.success(filterAttendanceData)))) {
            $0.attendanceCheckInModel = filterAttendanceData
            #expect($0.attendanceCheckInModel == filterAttendanceData, "모델이 같은지 테스트")
        }
        
        await testStore.assert { state in
            #expect(state.attendanceCheckInModel == filterAttendanceData, "필터링 된 모델이 매칭 되는지")
            #expect(state.selectDate == date, "날짜가 매칭이 되는지")
            #expect(state.selectDatePicker == true, "날짜 피커를 선택 한게 매칭이 되었는지")
            #expect(state.isDateSelected == true, "날짜 선택 한게 매칭이 되었는지 ")
        }
        
        await testStore.send(.view(.updateAttendanceCountWithData(attendances: filterAttendanceData))) {
            $0.attendanceCount = filterAttendanceData.count
            #expect($0.attendanceCount == filterAttendanceData.count, "출석 된수가 매칭이 되는 지")
        }
        
        await testStore.assert { state in
            #expect(state.attendanceCount == filterAttendanceData.count, "출석 된수가 매칭이 되는 지")
        }
        
        await testStore.finish()
        testStore.exhaustivity = .off
    }
    
    
    

    //
    //        @Test func fetchCoreMember_리스트테스트() async throws {
    //            let expectation = XCTestExpectation(description: "유저 리스트 fetch")
    //            await testStore.send(.async(.fetchMember))
    //        }
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
