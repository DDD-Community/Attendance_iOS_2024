//
//  MyPageUseCaseTest.swift
//  UseCaseTests
//
//  Created by DDD on 2026-04-16
//

import Foundation
import Testing

@testable import MyPageDomain
@testable import MyPageDomainInterface

import ComposableArchitecture

@Suite("MyPage UseCase Tests - Complete TDD Implementation")
@MainActor
struct MyPageUseCaseTest {

    // MARK: - Test Dependencies
    private var mockMyPageRepository: MockMyPageRepository!
    private var myPageUseCase: MyPageUseCaseImpl!

    init() async {
        mockMyPageRepository = MockMyPageRepository()
        myPageUseCase = MyPageUseCaseImpl(repository: mockMyPageRepository)
    }

    // MARK: - Core MyPage Tests (10 Test Cases)

    @Test("TC-001: 내 출석 통계 조회 성공")
    func test_fetch_my_attendances_success() async throws {
        // Given: 성공적인 출석 통계 설정
        let expectedSummary = AttendanceSummaryResponse(
            totalAttended: 25,
            totalLate: 3,
            totalAbsent: 2
        )
        mockMyPageRepository.configureAttendancesSuccess(expectedSummary)

        // When: 출석 통계 조회 실행
        let result = try await withDependencies {
            $0.myPageRepository = mockMyPageRepository
        } operation: {
            return try await myPageUseCase.fetchAttendances()
        }

        // Then: 출석 통계 검증
        #expect(result.totalAttended == 25, "참석 횟수가 올바르게 조회되어야 함")
        #expect(result.totalLate == 3, "지각 횟수가 올바르게 조회되어야 함")
        #expect(result.totalAbsent == 2, "결석 횟수가 올바르게 조회되어야 함")
        #expect(mockMyPageRepository.fetchAttendancesCallCount == 1, "Repository가 한 번 호출되어야 함")
    }

    @Test("TC-002: 내 출석 통계 조회 실패")
    func test_fetch_my_attendances_failure() async throws {
        // Given: 네트워크 에러 설정
        mockMyPageRepository.configureAttendancesFailure(MyPageError.loadFailed)

        // When & Then: 에러 처리 검증
        await #expect(throws: MyPageError.loadFailed) {
            try await withDependencies {
                $0.myPageRepository = mockMyPageRepository
            } operation: {
                _ = try await myPageUseCase.fetchAttendances()
            }
        }

        #expect(mockMyPageRepository.fetchAttendancesCallCount == 1, "실패해도 Repository는 호출되어야 함")
    }

    @Test("TC-003: 내 일정 목록 조회 성공")
    func test_fetch_my_schedules_success() async throws {
        // Given: 성공적인 일정 목록 설정
        let expectedSchedules = [
            AttendanceMyScheduleResponse(id: 1, name: "DDD 세미나", desc: "iOS 세미나", month: 4, day: 20, status: "attended"),
            AttendanceMyScheduleResponse(id: 2, name: "Android 워크샵", desc: "Android 개발", month: 4, day: 25, status: "late"),
            AttendanceMyScheduleResponse(id: 3, name: "월간 회의", desc: "정기 회의", month: 4, day: 30, status: "absent")
        ]
        mockMyPageRepository.configureSchedulesSuccess(expectedSchedules)

        // When: 일정 목록 조회 실행
        let result = try await withDependencies {
            $0.myPageRepository = mockMyPageRepository
        } operation: {
            return try await myPageUseCase.fetchSchedules()
        }

        // Then: 일정 목록 검증
        #expect(result.count == 3, "3개의 일정이 조회되어야 함")
        #expect(result[0].name == "DDD 세미나", "첫 번째 일정명이 올바르게 조회되어야 함")
        #expect(result[0].status == "attended", "첫 번째 일정 상태가 올바르게 조회되어야 함")
        #expect(result[1].status == "late", "두 번째 일정 상태가 올바르게 조회되어야 함")
        #expect(result[2].status == "absent", "세 번째 일정 상태가 올바르게 조회되어야 함")
        #expect(mockMyPageRepository.fetchSchedulesCallCount == 1, "Repository가 한 번 호출되어야 함")
    }

    @Test("TC-004: 내 일정 목록 조회 실패")
    func test_fetch_my_schedules_failure() async throws {
        // Given: 권한 없음 에러 설정
        mockMyPageRepository.configureSchedulesFailure(MyPageError.loadFailed)

        // When & Then: 권한 에러 검증
        await #expect(throws: MyPageError.loadFailed) {
            try await withDependencies {
                $0.myPageRepository = mockMyPageRepository
            } operation: {
                _ = try await myPageUseCase.fetchSchedules()
            }
        }
    }

    @Test("TC-005: 빈 출석 통계 조회")
    func test_fetch_my_attendances_empty() async throws {
        // Given: 빈 출석 통계 설정 (신규 사용자)
        let emptySummary = AttendanceSummaryResponse(
            totalAttended: 0,
            totalLate: 0,
            totalAbsent: 0
        )
        mockMyPageRepository.configureAttendancesSuccess(emptySummary)

        // When: 빈 출석 통계 조회 실행
        let result = try await withDependencies {
            $0.myPageRepository = mockMyPageRepository
        } operation: {
            return try await myPageUseCase.fetchAttendances()
        }

        // Then: 빈 통계 검증
        #expect(result.totalAttended == 0, "신규 사용자는 참석이 0이어야 함")
        #expect(result.totalLate == 0, "신규 사용자는 지각이 0이어야 함")
        #expect(result.totalAbsent == 0, "신규 사용자는 결석이 0이어야 함")
    }

    @Test("TC-006: 빈 일정 목록 조회")
    func test_fetch_my_schedules_empty() async throws {
        // Given: 빈 일정 목록 설정
        mockMyPageRepository.configureSchedulesSuccess([])

        // When: 빈 일정 목록 조회 실행
        let result = try await withDependencies {
            $0.myPageRepository = mockMyPageRepository
        } operation: {
            return try await myPageUseCase.fetchSchedules()
        }

        // Then: 빈 결과 검증
        #expect(result.isEmpty, "빈 일정 목록이 반환되어야 함")
    }

    @Test("TC-007: 출석률 계산 시뮬레이션")
    func test_attendance_rate_calculation_simulation() async throws {
        // Given: 출석률 계산을 위한 통계
        let summary = AttendanceSummaryResponse(
            totalAttended: 18,
            totalLate: 2,
            totalAbsent: 1
        )
        mockMyPageRepository.configureAttendancesSuccess(summary)

        // When: 출석 통계 조회 실행
        let result = try await withDependencies {
            $0.myPageRepository = mockMyPageRepository
        } operation: {
            return try await myPageUseCase.fetchAttendances()
        }

        // Then: 출석률 계산 검증 (클라이언트에서 계산)
        let totalEvents = result.totalAttended + result.totalLate + result.totalAbsent
        let attendanceRate = Double(result.totalAttended) / Double(totalEvents) * 100

        #expect(totalEvents == 21, "전체 이벤트 수가 올바르게 계산되어야 함")
        #expect(attendanceRate > 85.0, "출석률이 85% 이상이어야 함") // 18/21 ≈ 85.7%
        #expect(result.totalAttended == 18, "참석 횟수가 올바르게 반환되어야 함")
    }

    @Test("TC-008: 일정 등록 상태 분석")
    func test_schedule_registration_status_analysis() async throws {
        // Given: 다양한 상태의 일정들
        let schedules = [
            AttendanceMyScheduleResponse(id: 1, name: "참석 일정", desc: "참석함", month: 4, day: 1, status: "attended"),
            AttendanceMyScheduleResponse(id: 2, name: "지각 일정", desc: "지각함", month: 4, day: 2, status: "late"),
            AttendanceMyScheduleResponse(id: 3, name: "결석 일정", desc: "결석함", month: 4, day: 3, status: "absent"),
            AttendanceMyScheduleResponse(id: 4, name: "미등록 일정", desc: "아직 등록 안함", month: 4, day: 4, status: "not_registered"),
            AttendanceMyScheduleResponse(id: 5, name: "예정 일정", desc: "예정된 일정", month: 4, day: 5, status: "scheduled")
        ]
        mockMyPageRepository.configureSchedulesSuccess(schedules)

        // When: 일정 목록 조회 실행
        let result = try await withDependencies {
            $0.myPageRepository = mockMyPageRepository
        } operation: {
            return try await myPageUseCase.fetchSchedules()
        }

        // Then: 상태별 분석 검증
        let attendedSchedules = result.filter { $0.status == "attended" }
        let lateSchedules = result.filter { $0.status == "late" }
        let absentSchedules = result.filter { $0.status == "absent" }
        let notRegisteredSchedules = result.filter { $0.status == "not_registered" }
        let scheduledSchedules = result.filter { $0.status == "scheduled" }

        #expect(attendedSchedules.count == 1, "참석 일정이 1개 있어야 함")
        #expect(lateSchedules.count == 1, "지각 일정이 1개 있어야 함")
        #expect(absentSchedules.count == 1, "결석 일정이 1개 있어야 함")
        #expect(notRegisteredSchedules.count == 1, "미등록 일정이 1개 있어야 함")
        #expect(scheduledSchedules.count == 1, "예정 일정이 1개 있어야 함")
    }

    @Test("TC-009: 대량 개인 통계 데이터 처리")
    func test_large_personal_stats_data() async throws {
        // Given: 대량 통계 데이터
        let largeSummary = AttendanceSummaryResponse(
            totalAttended: 1000,
            totalLate: 50,
            totalAbsent: 25
        )
        mockMyPageRepository.configureAttendancesSuccess(largeSummary)

        // When: 대량 통계 조회 실행
        let result = try await withDependencies {
            $0.myPageRepository = mockMyPageRepository
        } operation: {
            return try await myPageUseCase.fetchAttendances()
        }

        // Then: 대량 데이터 처리 검증
        #expect(result.totalAttended == 1000, "대량 참석 데이터가 올바르게 처리되어야 함")
        #expect(result.totalLate == 50, "대량 지각 데이터가 올바르게 처리되어야 함")
        #expect(result.totalAbsent == 25, "대량 결석 데이터가 올바르게 처리되어야 함")

        let totalEvents = result.totalAttended + result.totalLate + result.totalAbsent
        #expect(totalEvents == 1075, "전체 이벤트 수가 올바르게 계산되어야 함")
    }

    @Test("TC-010: 동시 개인 데이터 요청 처리")
    func test_concurrent_personal_data_requests() async throws {
        // Given: 동시 요청을 위한 데이터 설정
        let testSummary = AttendanceSummaryResponse(
            totalAttended: 15,
            totalLate: 2,
            totalAbsent: 1
        )
        let testSchedules = [
            AttendanceMyScheduleResponse(id: 1, name: "동시성 테스트", desc: "동시 요청 테스트", month: 5, day: 1, status: "attended")
        ]
        mockMyPageRepository.configureAttendancesSuccess(testSummary)
        mockMyPageRepository.configureSchedulesSuccess(testSchedules)

        // When: 출석 통계와 일정 목록을 동시에 요청
        let (summaryResult, schedulesResult) = try await withThrowingTaskGroup(of: Any.self, returning: (AttendanceSummaryResponse, [AttendanceMyScheduleResponse]).self) { group in

            group.addTask {
                try await withDependencies {
                    $0.myPageRepository = mockMyPageRepository
                } operation: {
                    return try await myPageUseCase.fetchAttendances()
                }
            }

            group.addTask {
                try await withDependencies {
                    $0.myPageRepository = mockMyPageRepository
                } operation: {
                    return try await myPageUseCase.fetchSchedules()
                }
            }

            var summary: AttendanceSummaryResponse?
            var schedules: [AttendanceMyScheduleResponse]?

            for try await result in group {
                if let summaryRes = result as? AttendanceSummaryResponse {
                    summary = summaryRes
                } else if let schedulesRes = result as? [AttendanceMyScheduleResponse] {
                    schedules = schedulesRes
                }
            }

            return (summary!, schedules!)
        }

        // Then: 동시 요청 결과 검증
        #expect(summaryResult.totalAttended == 15, "출석 통계가 올바르게 반환되어야 함")
        #expect(summaryResult.totalLate == 2, "지각 통계가 올바르게 반환되어야 함")
        #expect(summaryResult.totalAbsent == 1, "결석 통계가 올바르게 반환되어야 함")
        #expect(schedulesResult.count == 1, "일정 목록이 올바르게 반환되어야 함")
        #expect(schedulesResult.first?.name == "동시성 테스트", "일정명이 올바르게 반환되어야 함")

        #expect(mockMyPageRepository.fetchAttendancesCallCount == 1, "출석 통계 Repository가 호출되어야 함")
        #expect(mockMyPageRepository.fetchSchedulesCallCount == 1, "일정 Repository가 호출되어야 함")
    }
}

// MARK: - Mock Repository
@MainActor
class MockMyPageRepository: MyPageInterface {

    // MARK: - Call Tracking
    var fetchAttendancesCallCount = 0
    var fetchSchedulesCallCount = 0

    // MARK: - Configured Responses
    private var attendancesResponse: Result<AttendanceSummaryResponse, MyPageError>?
    private var schedulesResponse: Result<[AttendanceMyScheduleResponse], MyPageError>?

    // MARK: - Implementation
    func fetchAttendances() async throws(MyPageError) -> AttendanceSummaryResponse {
        fetchAttendancesCallCount += 1

        if let response = attendancesResponse {
            return try response.get()
        }

        throw MyPageError.loadFailed
    }

    func fetchSchedules() async throws(MyPageError) -> [AttendanceMyScheduleResponse] {
        fetchSchedulesCallCount += 1

        if let response = schedulesResponse {
            return try response.get()
        }

        throw MyPageError.loadFailed
    }

    // MARK: - Configuration Methods
    func configureAttendancesSuccess(_ summary: AttendanceSummaryResponse) {
        attendancesResponse = .success(summary)
    }

    func configureAttendancesFailure(_ error: Error) {
        attendancesResponse = .failure(MyPageError.loadFailed)
    }

    func configureSchedulesSuccess(_ schedules: [AttendanceMyScheduleResponse]) {
        schedulesResponse = .success(schedules)
    }

    func configureSchedulesFailure(_ error: Error) {
        schedulesResponse = .failure(MyPageError.loadFailed)
    }
}
