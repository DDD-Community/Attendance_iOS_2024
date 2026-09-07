//
//  AttendanceEntityTest.swift
//  EntityTests
//
//  Created by DDD on 2026-01-30
//

import Testing

import AttendanceDomainInterface

@Suite("Attendance Entity Tests")
struct AttendanceEntityTest {

    @Test("Attendance Mock 데이터 생성 테스트")
    func test_Attendance_mock_data_creation() throws {
        // Given
        let attendance = Attendance(
            id: 1,
            userID: "user_001",
            userName: "김철수",
            userInfo: "iOS 1팀/iOS",
            status: .attended
        )

        // Then
        #expect(attendance.userID == "user_001")
        #expect(attendance.userName == "김철수")
        #expect(attendance.userInfo == "iOS 1팀/iOS")
        #expect(attendance.status == .attended)
    }

    @Test("AttendanceCount Mock 데이터 테스트")
    func test_AttendanceCount_mock_data() throws {
        // Given
        let count = AttendanceCount(attendanceCount: 18, lateCount: 2, absentCount: 0)

        // Then
        #expect(count.attendanceCount == 18)
        #expect(count.lateCount == 2)
        #expect(count.absentCount == 0)
    }

    @Test("EditAttendance 성공 응답 테스트")
    func test_EditAttendance_success_response() throws {
        // Given
        let response = EditAttendance(isSuccess: true, code: "200", message: "출석 수정 성공")

        // Then
        #expect(response.isSuccess == true)
        #expect(response.code == "200")
        #expect(response.message != nil)
    }

    @Test("Attendance 배열 Mock 데이터 테스트")
    func test_Attendance_array_mock_data() throws {
        // Given
        let attendances = [
            Attendance(id: 1, userID: "user_001", userName: "김철수", userInfo: "iOS 1팀/iOS", status: .attended),
            Attendance(id: 2, userID: "user_002", userName: "이영희", userInfo: "iOS 1팀/iOS", status: .late),
            Attendance(id: 3, userID: "user_003", userName: "박민수", userInfo: "iOS 2팀/iOS", status: .absent),
            Attendance(id: 4, userID: "user_004", userName: "최지우", userInfo: "WEB 1팀/FE", status: .attended),
            Attendance(id: 5, userID: "user_005", userName: "정하늘", userInfo: "AND 1팀/Android", status: .late)
        ]

        // Then
        #expect(attendances.count == 5)
        #expect(attendances[0].status == .attended)
        #expect(attendances[1].status == .late)
        #expect(attendances[2].status == .absent)
    }

    @Test("AttendanceStatus 랜덤 Mock 데이터 테스트")
    func test_AttendanceStatus_random_mock() throws {
        // Given & When
        let randomStatus = AttendanceStatus.allCases.randomElement() ?? .defaults

        // Then
        #expect(AttendanceStatus.allCases.contains(randomStatus))
    }

    @Test("EditAttendanceInput Mock 데이터 테스트")
    func test_EditAttendanceInput_mock_data() throws {
        // Given
        let input = EditAttendanceInput(
            attendanceId: 1,
            scheduleId: 5,
            status: .attended,
            userId: "user_001"
        )

        // Then
        #expect(input.userId == "user_001")
        #expect(input.scheduleId == 5)
        #expect(input.status == .attended)
        #expect(input.attendanceId == 1)
    }
}
