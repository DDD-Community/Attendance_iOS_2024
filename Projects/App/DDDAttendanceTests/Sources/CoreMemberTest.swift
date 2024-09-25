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
    @Tag static var attendanceTest: Self
    @Tag static var memberListTest: Self
}

@MainActor
struct CoreMemberTest {
    let testScheduler = DispatchQueue.test
    
    @Suite(.tags(.selectPartTest))
    struct MemberSelectPartTest {
        @MainActor let testStore = TestStore(initialState: CoreMember.State()) {
            CoreMember()
        } withDependencies: {
            let fireBaseRepository = FireStoreRepository()
            $0.fireStoreUseCase = FireStoreUseCase(repository: fireBaseRepository)
        }
        
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
            
            await testStore.assert { state in
                #expect(state.selectPart == .pm, "이전 파트로 돌아갔는지 매칭")
            }
        }
        
    }
    
    @Suite(.tags(.attendanceTest))
    struct AttendanceTest {
        @MainActor let testStore = TestStore(initialState: CoreMember.State()) {
            CoreMember()
        } withDependencies: {
            let fireBaseRepository = FireStoreRepository()
            $0.fireStoreUseCase = FireStoreUseCase(repository: fireBaseRepository)
        }
        var mockAttendanceData = AttendanceDTO.mockAttendanceData()
        
        @Test("출석 데이터 관리 mockData 테스트", .tags(.attendanceTest))
        @MainActor func member_출석mock데이터추가() async throws {
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
            
            testStore.assert { state in
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
            testStore.assert { state in
                let failedAttendanceCheckInModel = state.attendanceCheckInModel.map { attendance in
                    let modifiedAttendance = attendance
                    #expect(modifiedAttendance.status != .present,  "status가 달라 매칭이 안되어 있는지 확인")
                    return modifiedAttendance
                }
                #expect(failedAttendanceCheckInModel != unexpectedAttendanceData , "데이터가 달라서 모델 매칭 안되는지 확인")
            }
            
        }
        
        @Test("출석 데이터 실패 테스트", .tags(.attendanceTest))
        func member_출석데이터실패_테스트() async throws {
            // 1. 실패 케이스에서 발생할 에러를 정의합니다.
            let expectedError = CustomError.firestoreError("출석 데이터를 불러오는 중 오류가 발생했습니다.")
            
            // 2. 상태 변경 테스트 전에 초기 상태를 명시적으로 검증합니다.
            await testStore.assert { state in
                #expect(state.isLoading == false, "초기 상태에서는 로딩 중이 아님")
                #expect(state.attendanceCheckInModel == [] , "초기 상태에서는 출석 데이터가 비어있음")
            }

            // 3. fetchAttendanceDataResponse 액션이 실패하는 상황을 시뮬레이션합니다.
            await testStore.send(.async(.fetchAttendanceDataResponse(.failure(expectedError)))) {
                $0.isLoading = true
                Log.error("출석 정보 데이터 에러", expectedError.localizedDescription)

                // 5. 실패했을 때 attendanceCheckInModel이 변경되지 않고 유지되는지 확인합니다.
                #expect($0.attendanceCheckInModel.isEmpty == true, "출석 데이터가 비어있어야 함")
            }

            await testStore.assert { state in
                #expect(state.isLoading == true, "에러 처리 중에는 로딩 상태여야 함")
                #expect(state.attendanceCheckInModel.isEmpty == true, "에러 발생 시 attendanceCheckInModel은 유지되어야 함")
            }
            
            await testStore.finish()
        }
        
        
        @Test("출석 날짜 필터링 테스트", .tags(.attendanceTest))
        @MainActor func coreMember_날짜선택() async throws {
            let selectDate = testStore.state.selectDate
            
            await testStore.send(.selectDate(date: selectDate)) {
                $0.selectDate = selectDate
                $0.selectDatePicker = false
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
            
            testStore.assert { state in
                #expect(state.attendanceCheckInModel == filterAttendanceData, "필터링 된 모델이 매칭 되는지")
                #expect(state.selectDate == selectDate, "날짜가 매칭이 되는지")

                #expect(state.isDateSelected == true, "날짜 선택 한게 매칭이 되었는지 ")
            }
            
            
            await testStore.send(.view(.updateAttendanceCountWithData(attendances: filterAttendanceData))) {
                $0.attendanceCount = filterAttendanceData.count
                #expect($0.attendanceCount == filterAttendanceData.count, "출석 된수가 매칭이 되는 지")
            }
            
            testStore.assert { state in
                #expect(state.attendanceCount == filterAttendanceData.count, "출석 된수가 매칭이 되는 지")
            }
             
        }
        
        @Test("출석 날짜 다르게 테스트", .tags(.attendanceTest))
        @MainActor func member_출석날짜를현재날짜말고_다른날짜로변경() async throws {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            
            guard let selectDateSecond = dateFormatter.date(from: "2024-09-16") else {
                fatalError("Invalid date format")
            }
            var date = testStore.state.selectDate
            date = selectDateSecond
            
            let filterAttendanceData = mockAttendanceData.filter {
                $0.updatedAt.formattedDateToString() == date.formattedDateToString()
            }
            
            await testStore.send(.selectDate(date: date)) {
                $0.selectDate = date
                $0.isDateSelected = true
                $0.selectDatePicker = false
            }
            testStore.exhaustivity = .off
            
            await testStore.send(.async(.fetchAttendanceDataResponse(.success(filterAttendanceData)))) {
                $0.attendanceCheckInModel = filterAttendanceData
                #expect($0.attendanceCheckInModel == filterAttendanceData, "모델이 같은지 테스트")
            }
            
            testStore.assert { state in
                #expect(state.attendanceCheckInModel == filterAttendanceData, "필터링 된 모델이 매칭 되는지")
                #expect(state.selectDate == date, "날짜가 매칭이 되는지")
                #expect(state.isDateSelected == true, "날짜 선택 한게 매칭이 되었는지 ")
            }
            
            await testStore.send(.view(.updateAttendanceCountWithData(attendances: filterAttendanceData))) {
                $0.attendanceCount = filterAttendanceData.count
                #expect($0.attendanceCount == filterAttendanceData.count, "출석 된수가 매칭이 되는 지")
            }
            
            testStore.assert { state in
                #expect(state.attendanceCount == filterAttendanceData.count, "출석 된수가 매칭이 되는 지")
            }
        }
        
    }
    
    
    @Suite(.tags(.memberListTest))
    struct MemberListTest {
        @MainActor let testStore = TestStore(initialState: CoreMember.State()) {
            CoreMember()
        } withDependencies: {
            let fireBaseRepository = FireStoreRepository()
            $0.fireStoreUseCase = FireStoreUseCase(repository: fireBaseRepository)
        }
        let mockMemberData =  MemberDTO.mockMemberData()
        
        @Test("출석 할 멤버 조회 리스트' 성공',", .tags(.memberListTest))
       func 출석멤버조회테스트() async throws {
            await testStore.send(.async(.fetchMemberDataResponse(.success(mockMemberData)))) {
                $0.attendaceMemberModel = mockMemberData
            }
            
           await testStore.assert { state in
                #expect(state.attendaceMemberModel == mockMemberData)
            }
            
        }
        
        @Test("출석 할 멤버 조회 리스트' 실패", .tags(.memberListTest))
        func member_리스트실패_테스트() async throws {
            // 1. 실패 케이스에서 발생할 에러를 정의합니다.
            let expectedError = CustomError.firestoreError("출석 데이터를 불러오는 중 오류가 발생했습니다.")
            
            // 2. 상태 변경 테스트 전에 초기 상태를 명시적으로 검증합니다.
            await testStore.assert { state in
                #expect(state.isLoading == false, "초기 상태에서는 로딩 중이 아님")
                #expect(state.attendaceMemberModel == [] , "초기 상태에서는 출석 멤버 데이터가 비어있음")
            }

            // 3. fetchAttendanceDataResponse 액션이 실패하는 상황을 시뮬레이션합니다.
            await testStore.send(.async(.fetchMemberDataResponse(.failure(expectedError)))) {
                $0.isLoading = true
                Log.error("출석 정보 멤버 데이터 에러", expectedError.localizedDescription)

                // 5. 실패했을 때 attendanceCheckInModel이 변경되지 않고 유지되는지 확인합니다.
                #expect($0.attendaceMemberModel.isEmpty == true, "출석 데이터가 비어있어야 함")
            }

            await testStore.assert { state in
                #expect(state.isLoading == true, "에러 처리 중에는 로딩 상태여야 함")
                #expect(state.attendaceMemberModel.isEmpty == true, "에러 발생 시 attendanceCheckInModel은 유지되어야 함")
            }
            
        }
        
        @Test("파이어 베이스 앱 테스트 추가", .tags(.memberListTest))
        func member_파이어베이스_테스트() async throws {
            let testStoreMemmberModel = await testStore.state.attendaceMemberModel
            
            await testStore.send(.async(.fetchMember)) {
                $0.attendaceMemberModel = testStoreMemmberModel
            }
            
//            await testStore.receive(.async(.fetchMemberDataResponse(.success(testStoreMemmberModel))), timeout: .seconds(1)) {
//                $0.attendaceMemberModel = $0.attendaceMemberModel
//            }
            
        }
    }
}
