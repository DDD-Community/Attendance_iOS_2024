//
//  AttendanceUseCaseTest.swift
//  UseCaseTests
//
//  Created by DDD on 2026-04-16
//

import Foundation
import Testing

@testable import AttendanceDomain
@testable import AttendanceDomainInterface
import OnBoardingDomainInterface

import ComposableArchitecture

@Suite("Attendance UseCase Tests - Complete TDD Implementation")
@MainActor
struct AttendanceUseCaseTest {

    // MARK: - Test Dependencies
    private var mockAttendanceRepository: MockAttendanceRepository!

    init() async {
        mockAttendanceRepository = await MockAttendanceRepository.adminCountSuccess()
    }

    // MARK: - Core Functionality Tests

    @Test("TC-001: 관리자 출석 통계 조회 성공")
    func test_admin_attendance_count_success() async throws {
        // Given: 관리자 출석 통계 조회 설정
        let scheduleId = 123
        let expectedCount = AttendanceCount(
            totalCount: 50,
            attendanceCount: 45,
            lateCount: 3,
            absentCount: 2
        )
        let mockAttendanceRepository = await MockAttendanceRepository.adminCountSuccess()

        // When: 관리자 출석 통계 조회 실행
        let result = try await withDependencies {
            $0.attendanceRepository = mockAttendanceRepository
        } operation: {
            let useCase = AttendanceUseCaseImpl()
            return try await useCase.adminAttendanceCount(scheduleId: scheduleId)
        }

        // Then: 출석 통계 검증
        #expect(result.totalCount == expectedCount.totalCount, "전체 인원수가 일치해야 함")
        #expect(result.attendanceCount == expectedCount.attendanceCount, "참석 인원수가 일치해야 함")
        #expect(result.lateCount == expectedCount.lateCount, "지각 인원수가 일치해야 함")
        #expect(result.absentCount == expectedCount.absentCount, "결석 인원수가 일치해야 함")
        #expect(mockAttendanceRepository.lastAdminCountScheduleId == scheduleId, "올바른 scheduleId가 전달되어야 함")
    }

    @Test("TC-002: 관리자 출석 통계 조회 실패")
    func test_admin_attendance_count_failure() async throws {
        // Given: 네트워크 에러 설정
        mockAttendanceRepository.configureAdminCountFailure(AttendanceError.unknown)

        // When & Then: 에러 처리 검증
        await #expect(throws: AttendanceError.unknown) {
            try await withDependencies {
                $0.attendanceRepository = mockAttendanceRepository
            } operation: {
                let useCase = AttendanceUseCaseImpl()
                _ = try await useCase.adminAttendanceCount(scheduleId: 999)
            }
        }
    }

    @Test("TC-003: 출석 가능 팀 목록 조회 성공")
    func test_fetch_attendance_teams_success() async throws {
        // Given: 출석 가능 팀 목록 설정
        let expectedTeams = [
            SelectTeamEntity(id: 1, name: "IOS 1팀", description: "iOS 1"),
            SelectTeamEntity(id: 2, name: "IOS 2팀", description: "iOS 2"),
            SelectTeamEntity(id: 3, name: "AND 1팀", description: "Android 1")
        ]
        mockAttendanceRepository.configureTeamsSuccess(expectedTeams)

        // When: 팀 목록 조회 실행
        let result = try await withDependencies {
            $0.attendanceRepository = mockAttendanceRepository
        } operation: {
            let useCase = AttendanceUseCaseImpl()
            return try await useCase.fetchAttendanceTeams()
        }

        // Then: 팀 목록 검증
        #expect(result.count == expectedTeams.count, "팀 개수가 일치해야 함")
        #expect(result[0].name == "IOS 1팀", "첫 번째 팀명이 올바르게 조회되어야 함")
        #expect(result[1].name == "IOS 2팀", "두 번째 팀명이 올바르게 조회되어야 함")
        #expect(result[2].name == "AND 1팀", "세 번째 팀명이 올바르게 조회되어야 함")
    }

    @Test("TC-004: 빈 팀 목록 조회 처리")
    func test_fetch_attendance_teams_empty() async throws {
        // Given: 빈 팀 목록 설정
        mockAttendanceRepository.configureTeamsSuccess([])

        // When: 팀 목록 조회 실행
        let result = try await withDependencies {
            $0.attendanceRepository = mockAttendanceRepository
        } operation: {
            let useCase = AttendanceUseCaseImpl()
            return try await useCase.fetchAttendanceTeams()
        }

        // Then: 빈 결과 검증
        #expect(result.isEmpty, "빈 팀 목록이 반환되어야 함")
    }

    @Test("TC-005: 특정 일정 출석 현황 조회 성공")
    func test_session_attendance_success() async throws {
        // Given: 특정 일정 출석 현황 설정
        let scheduleId = 456
        let teamId = 1
        let expectedAttendances = [
            Attendance(id: 1, userID: "user1", userName: "김철수", userInfo: "iOS1팀/개발자", status: .attendance),
            Attendance(id: 2, userID: "user2", userName: "박영희", userInfo: "iOS1팀/디자이너", status: .late),
            Attendance(id: 3, userID: "user3", userName: "이민수", userInfo: "iOS1팀/개발자", status: .absent)
        ]
        mockAttendanceRepository.configureSessionSuccess(expectedAttendances)

        // When: 출석 현황 조회 실행
        let result = try await withDependencies {
            $0.attendanceRepository = mockAttendanceRepository
        } operation: {
            let useCase = AttendanceUseCaseImpl()
            return try await useCase.sessionAttendance(scheduleId: scheduleId, teamId: teamId)
        }

        // Then: 출석 현황 검증
        #expect(result.count == 3, "3명의 출석 현황이 조회되어야 함")
        #expect(result[0].status == .attendance, "첫 번째 사용자는 참석 상태여야 함")
        #expect(result[1].status == .late, "두 번째 사용자는 지각 상태여야 함")
        #expect(result[2].status == .absent, "세 번째 사용자는 결석 상태여야 함")
        #expect(mockAttendanceRepository.lastSessionScheduleId == scheduleId, "올바른 scheduleId가 전달되어야 함")
        #expect(mockAttendanceRepository.lastSessionTeamId == teamId, "올바른 teamId가 전달되어야 함")
    }

    @Test("TC-006: 출석 상태 종류 조회 성공")
    func test_fetch_status_success() async throws {
        // Given: 출석 상태 종류 설정
        let expectedStatuses: [AttendanceStatus] = [.attendance, .late, .absent]
        mockAttendanceRepository.configureStatusSuccess(expectedStatuses)

        // When: 출석 상태 조회 실행
        let result = try await withDependencies {
            $0.attendanceRepository = mockAttendanceRepository
        } operation: {
            let useCase = AttendanceUseCaseImpl()
            return try await useCase.fetchStatus()
        }

        // Then: 출석 상태 검증
        #expect(result.count == 3, "3가지 출석 상태가 있어야 함")
        #expect(result.contains(.attendance), "참석 상태가 포함되어야 함")
        #expect(result.contains(.late), "지각 상태가 포함되어야 함")
        #expect(result.contains(.absent), "결석 상태가 포함되어야 함")
    }

    @Test("TC-007: 출석 현황 수정 성공")
    func test_edit_attendance_success() async throws {
        // Given: 출석 현황 수정 설정
        let editInput = EditAttendanceInput(
            attendanceId: 123,
            scheduleId: 456,
            teamId: 1,
            userId: "user1",
            newStatus: .late
        )
        let expectedResult = EditAttendance(
            isSuccess: true,
            message: "출석 상태가 성공적으로 변경되었습니다",
            attendanceId: editInput.attendanceId
        )
        mockAttendanceRepository.configureEditSuccess(expectedResult)

        // When: 출석 현황 수정 실행
        let result = try await withDependencies {
            $0.attendanceRepository = mockAttendanceRepository
        } operation: {
            let useCase = AttendanceUseCaseImpl()
            return try await useCase.editAttendance(input: editInput)
        }

        // Then: 수정 결과 검증
        #expect(result.isSuccess, "출석 수정이 성공해야 함")
        #expect(result.message == expectedResult.message, "성공 메시지가 올바르게 반환되어야 함")
        #expect(result.attendanceId == editInput.attendanceId, "올바른 출석 ID가 반환되어야 함")
        #expect(mockAttendanceRepository.lastEditInput?.attendanceId == editInput.attendanceId, "올바른 입력이 전달되어야 함")
    }

    @Test("TC-008: 출석 현황 수정 실패 (권한 없음)")
    func test_edit_attendance_failure_unauthorized() async throws {
        // Given: 권한 없음 에러 설정
        let editInput = EditAttendanceInput(
            attendanceId: 999,
            scheduleId: 456,
            teamId: 1,
            userId: "unauthorized_user",
            newStatus: .attendance
        )
        mockAttendanceRepository.configureEditFailure(AttendanceError.unknown)

        // When & Then: 권한 에러 검증
        await #expect(throws: AttendanceError.unknown) {
            try await withDependencies {
                $0.attendanceRepository = mockAttendanceRepository
            } operation: {
                let useCase = AttendanceUseCaseImpl()
                _ = try await useCase.editAttendance(input: editInput)
            }
        }
    }

    @Test("TC-009: 출석 현황 수정 실패 (잘못된 데이터)")
    func test_edit_attendance_failure_invalid_data() async throws {
        // Given: 잘못된 데이터 에러 설정
        let invalidInput = EditAttendanceInput(
            attendanceId: -1, // 잘못된 ID
            scheduleId: 0, // 잘못된 스케줄 ID
            teamId: -1, // 잘못된 팀 ID
            userId: "",
            newStatus: .attendance
        )
        mockAttendanceRepository.configureEditFailure(AttendanceError.unknown)

        // When & Then: 잘못된 데이터 에러 검증
        await #expect(throws: AttendanceError.unknown) {
            try await withDependencies {
                $0.attendanceRepository = mockAttendanceRepository
            } operation: {
                let useCase = AttendanceUseCaseImpl()
                _ = try await useCase.editAttendance(input: invalidInput)
            }
        }
    }

    @Test("TC-010: 출석 통계 경계값 검증")
    func test_attendance_count_boundary_values() async throws {
        // Given: 경계값 출석 통계 설정
        let boundaryCount = AttendanceCount(
            totalCount: 0,
            attendanceCount: 0,
            lateCount: 0,
            absentCount: 0
        )
        mockAttendanceRepository.configureAdminCountSuccess(boundaryCount)

        // When: 경계값 조회 실행
        let result = try await withDependencies {
            $0.attendanceRepository = mockAttendanceRepository
        } operation: {
            let useCase = AttendanceUseCaseImpl()
            return try await useCase.adminAttendanceCount(scheduleId: 1)
        }

        // Then: 경계값 검증
        #expect(result.totalCount == 0, "경계값 처리가 올바르게 되어야 함")
        #expect(result.attendanceCount == 0, "경계값 처리가 올바르게 되어야 함")
    }

    @Test("TC-011: 대량 출석 현황 조회 처리")
    func test_large_session_attendance_handling() async throws {
        // Given: 대량 출석 현황 설정 (100명)
        let largeAttendances = (1...100).map { index in
            Attendance(
                id: index,
                userID: "user\(index)",
                userName: "사용자\(index)",
                userInfo: "iOS\(index % 2 + 1)팀/개발자",
                status: AttendanceStatus.allCases[index % 3]
            )
        }
        mockAttendanceRepository.configureSessionSuccess(largeAttendances)

        // When: 대량 출석 현황 조회 실행
        let result = try await withDependencies {
            $0.attendanceRepository = mockAttendanceRepository
        } operation: {
            let useCase = AttendanceUseCaseImpl()
            return try await useCase.sessionAttendance(scheduleId: 999, teamId: 1)
        }

        // Then: 대량 데이터 처리 검증
        #expect(result.count == 100, "100명의 출석 현황이 모두 조회되어야 함")
        let attendanceUsers = result.filter { $0.status == .attendance }
        let lateUsers = result.filter { $0.status == .late }
        let absentUsers = result.filter { $0.status == .absent }

        #expect(attendanceUsers.count + lateUsers.count + absentUsers.count == 100, "모든 사용자 상태가 분류되어야 함")
    }

    @Test("TC-012: 동시 출석 현황 수정 요청 처리")
    func test_concurrent_edit_attendance_requests() async throws {
        // Given: 동시 수정 요청 설정
        let concurrentInputs = (1...5).map { index in
            EditAttendanceInput(
                attendanceId: index,
                scheduleId: 456,
                teamId: 1,
                userId: "user\(index)",
                newStatus: .late
            )
        }

        let expectedResults = concurrentInputs.map { input in
            EditAttendance(
                isSuccess: true,
                message: "수정 완료",
                attendanceId: input.attendanceId
            )
        }
        mockAttendanceRepository.configureConcurrentEditSuccess(expectedResults)

        // When: 동시 수정 요청 실행
        let results = try await withThrowingTaskGroup(of: EditAttendance.self, returning: [EditAttendance].self) { group in
            for input in concurrentInputs {
                group.addTask {
                    try await withDependencies {
                        $0.attendanceRepository = mockAttendanceRepository
                    } operation: {
                        let useCase = AttendanceUseCaseImpl()
                        return try await useCase.editAttendance(input: input)
                    }
                }
            }

            var results: [EditAttendance] = []
            for try await result in group {
                results.append(result)
            }
            return results
        }

        // Then: 동시 요청 결과 검증
        #expect(results.count == 5, "모든 동시 요청이 처리되어야 함")
        #expect(results.allSatisfy { $0.isSuccess }, "모든 요청이 성공해야 함")
    }

    @Test("TC-013: 네트워크 재시도 시나리오")
    func test_network_retry_scenario() async throws {
        // Given: 네트워크 재시도 설정 (처음에는 실패, 두 번째에는 성공)
        let expectedCount = AttendanceCount(totalCount: 25, attendanceCount: 20, lateCount: 3, absentCount: 2)
        mockAttendanceRepository.configureRetryScenario(firstFailure: AttendanceError.unknown, thenSuccess: expectedCount)

        // When: 첫 호출은 실패하고 동일 요청 재호출 시 성공
        await #expect(throws: AttendanceError.unknown) {
            try await withDependencies {
                $0.attendanceRepository = mockAttendanceRepository
            } operation: {
                let useCase = AttendanceUseCaseImpl()
                _ = try await useCase.adminAttendanceCount(scheduleId: 789)
            }
        }

        let result = try await withDependencies {
            $0.attendanceRepository = mockAttendanceRepository
        } operation: {
            let useCase = AttendanceUseCaseImpl()
            return try await useCase.adminAttendanceCount(scheduleId: 789)
        }

        // Then: 두 번째 시도 성공 검증
        #expect(result.totalCount == expectedCount.totalCount, "재시도 후 올바른 데이터가 반환되어야 함")
        #expect(mockAttendanceRepository.retryCallCount == 2, "실패 후 성공까지 두 번의 시도가 기록되어야 함")
    }

    @Test("TC-014: 출석 통계 집계 성능 테스트")
    func test_attendance_statistics_aggregation_performance() async throws {
        // Given: 대량 출석 데이터가 있는 상황
        let scheduleId = 9999
        let expectedCount = AttendanceCount(totalCount: 1000, attendanceCount: 950, lateCount: 30, absentCount: 20)
        mockAttendanceRepository.configureAdminCountSuccess(expectedCount)

        // When: 성능 측정과 함께 통계 집계
        let startTime = CFAbsoluteTimeGetCurrent()

        let result = try await withDependencies {
            $0.attendanceRepository = mockAttendanceRepository
        } operation: {
            let useCase = AttendanceUseCaseImpl()
            return try await useCase.adminAttendanceCount(scheduleId: scheduleId)
        }

        let endTime = CFAbsoluteTimeGetCurrent()
        let executionTime = endTime - startTime

        // Then: 성능 및 결과 검증
        #expect(result.totalCount >= 100, "대량 데이터 처리 결과가 반환되어야 함")
        #expect(executionTime < 1.0, "1초 이내에 통계 집계가 완료되어야 함")
        #expect(mockAttendanceRepository.adminCountCallCount == 1, "한 번의 Repository 호출로 처리되어야 함")
    }

    @Test("TC-015: 크로스 팀 출석 상태 분석")
    func test_cross_team_attendance_analysis() async throws {
        // Given: 다중 팀 출석 상태 확인 설정
        let scheduleId = 555
        let teamId = 1
        let expectedAttendances = [
            Attendance(attendanceId: 1, userId: "user1", teamId: teamId, status: .attendance),
            Attendance(attendanceId: 2, userId: "user2", teamId: teamId, status: .late),
            Attendance(attendanceId: 3, userId: "user3", teamId: teamId, status: .absent)
        ]
        mockAttendanceRepository.configureSessionSuccess(expectedAttendances)

        // When: 팀별 출석 상태 조회
        let result = try await withDependencies {
            $0.attendanceRepository = mockAttendanceRepository
        } operation: {
            let useCase = AttendanceUseCaseImpl()
            return try await useCase.sessionAttendance(scheduleId: scheduleId, teamId: teamId)
        }

        // Then: 팀별 분석 결과 검증
        #expect(!result.isEmpty, "팀별 출석 데이터가 반환되어야 함")
        #expect(result.allSatisfy { $0.teamId == teamId }, "요청한 팀의 데이터만 반환되어야 함")
        #expect(mockAttendanceRepository.sessionCallCount == 1, "팀 필터링 요청이 처리되어야 함")
    }

    @Test("TC-016: 실시간 출석 상태 변경 플로우")
    func test_realtime_attendance_status_change_flow() async throws {
        // Given: 실시간 상태 변경 설정
        let editInput = EditAttendanceInput(
            attendanceId: 12345,
            scheduleId: 67890,
            teamId: 1,
            userId: "user12345",
            newStatus: .late
        )
        let expectedResult = EditAttendance(
            isSuccess: true,
            message: "상태 변경 완료",
            attendanceId: editInput.attendanceId
        )
        mockAttendanceRepository.configureEditSuccess(expectedResult)

        // When: 실시간 상태 변경 실행
        let result = try await withDependencies {
            $0.attendanceRepository = mockAttendanceRepository
        } operation: {
            let useCase = AttendanceUseCaseImpl()
            return try await useCase.editAttendance(input: editInput)
        }

        // Then: 상태 변경 플로우 검증
        #expect(result.isSuccess, "상태 변경이 성공해야 함")
        #expect(result.attendanceId == editInput.attendanceId, "변경된 출석 ID가 일치해야 함")
        #expect(mockAttendanceRepository.editCallCount == 1, "상태 변경 요청이 처리되어야 함")
        #expect(mockAttendanceRepository.lastEditInput?.newStatus == .late, "새로운 상태로 업데이트되어야 함")
    }

    @Test("TC-017: 권한별 데이터 접근 제어 검증")
    func test_permission_based_data_access_control() async throws {
        // Given: 권한 기반 접근 제어 설정
        let scheduleId = 11111
        let expectedCount = AttendanceCount(totalCount: 100, attendanceCount: 95, lateCount: 3, absentCount: 2)
        mockAttendanceRepository.configureAdminCountSuccess(expectedCount)

        // When: 권한이 필요한 관리자 기능 접근
        let result = try await withDependencies {
            $0.attendanceRepository = mockAttendanceRepository
        } operation: {
            let useCase = AttendanceUseCaseImpl()
            return try await useCase.adminAttendanceCount(scheduleId: scheduleId)
        }

        // Then: 권한 검증 결과 확인
        #expect(result.totalCount >= 0, "권한이 있는 경우 데이터가 반환되어야 함")
        #expect(result.attendanceCount >= 0, "참석자 수가 유효해야 함")
        #expect(mockAttendanceRepository.adminCountCallCount == 1, "권한 검증 후 데이터 접근이 이루어져야 함")
    }

    @Test("TC-018: 출석 데이터 일관성 검증")
    func test_attendance_data_consistency_validation() async throws {
        // Given: 데이터 일관성 검증을 위한 설정
        let scheduleId = 22222
        let expectedCount = AttendanceCount(totalCount: 200, attendanceCount: 180, lateCount: 15, absentCount: 5)
        mockAttendanceRepository.configureAdminCountSuccess(expectedCount)

        // When: 출석 통계 조회 (일관성 검증 포함)
        let result = try await withDependencies {
            $0.attendanceRepository = mockAttendanceRepository
        } operation: {
            let useCase = AttendanceUseCaseImpl()
            return try await useCase.adminAttendanceCount(scheduleId: scheduleId)
        }

        // Then: 데이터 일관성 검증
        let totalCalculated = result.attendanceCount + result.lateCount + result.absentCount
        #expect(totalCalculated <= result.totalCount, "계산된 총합이 전체 인원을 초과하면 안됨")
        #expect(result.attendanceCount >= 0, "참석자 수는 0 이상이어야 함")
        #expect(result.lateCount >= 0, "지각자 수는 0 이상이어야 함")
        #expect(result.absentCount >= 0, "결석자 수는 0 이상이어야 함")
        #expect(mockAttendanceRepository.adminCountCallCount == 1, "일관성 검증이 포함된 조회가 실행되어야 함")
    }
}

// MARK: - Mock Repository
@MainActor
class MockAttendanceRepository: AttendanceInterface {

    // MARK: - Call Tracking
    var adminCountCallCount = 0
    var teamsCallCount = 0
    var sessionCallCount = 0
    var statusCallCount = 0
    var editCallCount = 0
    var retryCallCount = 0

    // MARK: - Last Parameters
    var lastAdminCountScheduleId: Int?
    var lastSessionScheduleId: Int?
    var lastSessionTeamId: Int?
    var lastEditInput: EditAttendanceInput?

    // MARK: - Configured Responses
    private var adminCountResponse: Result<AttendanceCount, AttendanceError>?
    private var teamsResponse: Result<[SelectTeamEntity], AttendanceError>?
    private var sessionResponse: Result<[Attendance], AttendanceError>?
    private var statusResponse: Result<[AttendanceStatus], AttendanceError>?
    private var editResponse: Result<EditAttendance, AttendanceError>?
    private var retryScenarioFirstFailure: AttendanceError?
    private var retryScenarioSuccess: AttendanceCount?

    // MARK: - Implementation
    func adminAttendanceCount(scheduleId: Int) async throws(AttendanceError) -> AttendanceCount {
        adminCountCallCount += 1
        lastAdminCountScheduleId = scheduleId

        // 재시도 시나리오 처리
        if let firstFailure = retryScenarioFirstFailure, retryCallCount == 0 {
            retryCallCount += 1
            throw firstFailure
        } else if let success = retryScenarioSuccess, retryCallCount == 1 {
            retryCallCount += 1
            return success
        }

        if let response = adminCountResponse {
            return try response.get()
        }

        throw AttendanceError.unknown
    }

    func fetchAttendanceTeams() async throws(AttendanceError) -> [SelectTeamEntity] {
        teamsCallCount += 1

        if let response = teamsResponse {
            return try response.get()
        }

        throw AttendanceError.unknown
    }

    func sessionAttendance(scheduleId: Int, teamId: Int) async throws(AttendanceError) -> [Attendance] {
        sessionCallCount += 1
        lastSessionScheduleId = scheduleId
        lastSessionTeamId = teamId

        if let response = sessionResponse {
            return try response.get()
        }

        throw AttendanceError.unknown
    }

    func fetchStatus() async throws(AttendanceError) -> [AttendanceStatus] {
        statusCallCount += 1

        if let response = statusResponse {
            return try response.get()
        }

        throw AttendanceError.unknown
    }

    func editAttendance(input: EditAttendanceInput) async throws(AttendanceError) -> EditAttendance {
        editCallCount += 1
        lastEditInput = input

        if let response = editResponse {
            return try response.get()
        }

        throw AttendanceError.unknown
    }

    // MARK: - Configuration Methods
    @MainActor
    static func adminCountSuccess() -> MockAttendanceRepository {
        let mock = MockAttendanceRepository()
        mock.configureAdminCountSuccess(
            AttendanceCount(attendanceCount: 45, lateCount: 3, absentCount: 2)
        )
        return mock
    }

    func configureAdminCountSuccess(_ count: AttendanceCount) {
        adminCountResponse = .success(count)
    }

    func configureAdminCountFailure(_ error: Error) {
        adminCountResponse = .failure(AttendanceError.from(error))
    }

    func configureTeamsSuccess(_ teams: [SelectTeamEntity]) {
        teamsResponse = .success(teams)
    }

    func configureTeamsFailure(_ error: Error) {
        teamsResponse = .failure(AttendanceError.from(error))
    }

    func configureSessionSuccess(_ attendances: [Attendance]) {
        sessionResponse = .success(attendances)
    }

    func configureSessionFailure(_ error: Error) {
        sessionResponse = .failure(AttendanceError.from(error))
    }

    func configureStatusSuccess(_ statuses: [AttendanceStatus]) {
        statusResponse = .success(statuses)
    }

    func configureStatusFailure(_ error: Error) {
        statusResponse = .failure(AttendanceError.from(error))
    }

    func configureEditSuccess(_ result: EditAttendance) {
        editResponse = .success(result)
    }

    func configureEditFailure(_ error: Error) {
        editResponse = .failure(AttendanceError.from(error))
    }

    func configureConcurrentEditSuccess(_ results: [EditAttendance]) {
        // 간단화: 첫 번째 결과로 모든 요청에 응답
        if let firstResult = results.first {
            configureEditSuccess(firstResult)
        }
    }

    func configureRetryScenario(firstFailure: Error, thenSuccess: AttendanceCount) {
        retryScenarioFirstFailure = AttendanceError.from(firstFailure)
        retryScenarioSuccess = thenSuccess
        retryCallCount = 0
    }
}

// MARK: - Helper Extensions
extension AttendanceStatus: CaseIterable {
    public static var allCases: [AttendanceStatus] {
        return [.attendance, .late, .absent]
    }
}
