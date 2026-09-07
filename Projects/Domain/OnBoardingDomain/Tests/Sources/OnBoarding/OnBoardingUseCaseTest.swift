//
//  OnBoardingUseCaseTest.swift
//  UseCaseTests
//
//  Created by DDD on 2026-04-16
//

import Foundation
import Testing

@testable import OnBoardingDomain
@testable import OnBoardingDomainInterface

import ComposableArchitecture

@Suite("OnBoarding UseCase Tests - Complete TDD Implementation")
@MainActor
struct OnBoardingUseCaseTest {

    // MARK: - Test Dependencies
    private var mockOnBoardingRepository: OnBoardingRepositorySpy!

    init() async {
        mockOnBoardingRepository = OnBoardingRepositorySpy()
    }

    // MARK: - Core OnBoarding Tests (15 Test Cases)

    @Test("TC-001: 초대 코드 검증 성공 (Manager)")
    func test_verify_code_success_manager() async throws {
        // Given: Manager 초대 코드 검증 설정
        let inviteCode = "MANAGER2026"
        let expectedVerification = VerifyCodeEntity(
            generationID: 25,
            type: Staff.manager
        )
        mockOnBoardingRepository.configureVerifyCodeSuccess(expectedVerification)

        // When: 초대 코드 검증 실행
        let result = try await withDependencies {
            $0.onBoardingRepository = mockOnBoardingRepository
        } operation: {
            let useCase = OnBoardingUseCaseImpl()
            return try await useCase.verifyCode(code: inviteCode)
        }

        // Then: Manager 초대 코드 검증
        #expect(result.generationID == 25, "올바른 기수 ID가 반환되어야 함")
        #expect(result.type == Staff.manager, "Manager 권한이 설정되어야 함")
        #expect(mockOnBoardingRepository.lastVerifyCode == inviteCode, "올바른 코드가 전달되어야 함")
        #expect(mockOnBoardingRepository.verifyCodeCallCount == 1, "Repository가 한 번 호출되어야 함")
    }

    @Test("TC-002: 초대 코드 검증 성공 (Member)")
    func test_verify_code_success_member() async throws {
        // Given: Member 초대 코드 검증 설정
        let inviteCode = "MEMBER2026"
        let expectedVerification = VerifyCodeEntity(
            generationID: 26,
            type: .member
        )
        mockOnBoardingRepository.configureVerifyCodeSuccess(expectedVerification)

        // When: 초대 코드 검증 실행
        let result = try await withDependencies {
            $0.onBoardingRepository = mockOnBoardingRepository
        } operation: {
            let useCase = OnBoardingUseCaseImpl()
            return try await useCase.verifyCode(code: inviteCode)
        }

        // Then: Member 초대 코드 검증
        #expect(result.generationID == 26, "올바른 기수 ID가 반환되어야 함")
        #expect(result.type == Staff.member, "Member 권한이 설정되어야 함")
        #expect(mockOnBoardingRepository.lastVerifyCode == inviteCode, "올바른 코드가 전달되어야 함")
    }

    @Test("TC-003: 초대 코드 검증 실패 (잘못된 코드)")
    func test_verify_code_failure_invalid() async throws {
        // Given: 잘못된 초대 코드 에러 설정
        mockOnBoardingRepository.configureVerifyCodeFailure(OnBoardingError.invalidCode)

        // When & Then: 잘못된 코드 에러 검증
        await #expect(throws: OnBoardingError.invalidCode) {
            try await withDependencies {
                $0.onBoardingRepository = mockOnBoardingRepository
            } operation: {
                let useCase = OnBoardingUseCaseImpl()
                _ = try await useCase.verifyCode(code: "INVALID_CODE")
            }
        }

        #expect(mockOnBoardingRepository.verifyCodeCallCount == 1, "실패해도 Repository는 호출되어야 함")
    }

    @Test("TC-004: 초대 코드 검증 실패 (만료된 코드)")
    func test_verify_code_failure_expired() async throws {
        // Given: 만료된 초대 코드 에러 설정
        mockOnBoardingRepository.configureVerifyCodeFailure(OnBoardingError.verifyFailed)

        // When & Then: 만료된 코드 에러 검증
        await #expect(throws: OnBoardingError.verifyFailed) {
            try await withDependencies {
                $0.onBoardingRepository = mockOnBoardingRepository
            } operation: {
                let useCase = OnBoardingUseCaseImpl()
                _ = try await useCase.verifyCode(code: "EXPIRED_CODE")
            }
        }
    }

    @Test("TC-005: 직무 목록 조회 성공")
    func test_fetch_jobs_success() async throws {
        // Given: 성공적인 직무 목록 설정
        let expectedJobs = [
            SelectJob(jobKeys: "developer", job: .ios),
            SelectJob(jobKeys: "designer", job: SelectParts.designer),
            SelectJob(jobKeys: "planner", job: .pm),
            SelectJob(jobKeys: "backend", job: .backend)
        ]
        mockOnBoardingRepository.configureJobsSuccess(expectedJobs)

        // When: 직무 목록 조회 실행
        let result = try await withDependencies {
            $0.onBoardingRepository = mockOnBoardingRepository
        } operation: {
            let useCase = OnBoardingUseCaseImpl()
            return try await useCase.fetchJobs()
        }

        // Then: 직무 목록 검증
        #expect(result.count == 4, "4개의 직무가 조회되어야 함")
        #expect(result[0].jobKeys == "developer", "개발자 직무가 포함되어야 함")
        #expect(result[1].jobKeys == "designer", "디자이너 직무가 포함되어야 함")
        #expect(result[2].jobKeys == "planner", "기획자 직무가 포함되어야 함")
        #expect(result[3].jobKeys == "backend", "백엔드 직무가 포함되어야 함")
        #expect(mockOnBoardingRepository.fetchJobsCallCount == 1, "Repository가 한 번 호출되어야 함")
    }

    @Test("TC-006: 직무 목록 조회 실패")
    func test_fetch_jobs_failure() async throws {
        // Given: 네트워크 에러 설정
        mockOnBoardingRepository.configureJobsFailure(OnBoardingError.networkError)

        // When & Then: 네트워크 에러 검증
        await #expect(throws: OnBoardingError.networkError) {
            try await withDependencies {
                $0.onBoardingRepository = mockOnBoardingRepository
            } operation: {
                let useCase = OnBoardingUseCaseImpl()
                _ = try await useCase.fetchJobs()
            }
        }
    }

    @Test("TC-007: 팀 목록 조회 성공")
    func test_fetch_teams_success() async throws {
        // Given: 성공적인 팀 목록 설정
        let generationId = 25
        let expectedTeams = [
            SelectTeamEntity(teamId: 1, teams: SelectTeams.ios1),
            SelectTeamEntity(teamId: 2, teams: SelectTeams.ios2),
            SelectTeamEntity(teamId: 3, teams: SelectTeams.and1),
            SelectTeamEntity(teamId: 4, teams: SelectTeams.web1)
        ]
        mockOnBoardingRepository.configureTeamsSuccess(expectedTeams)

        // When: 팀 목록 조회 실행
        let result = try await withDependencies {
            $0.onBoardingRepository = mockOnBoardingRepository
        } operation: {
            let useCase = OnBoardingUseCaseImpl()
            return try await useCase.fetchTeams(generationId: generationId)
        }

        // Then: 팀 목록 검증
        #expect(result.count == 4, "4개의 팀이 조회되어야 함")
        #expect(result[0].teams.description == "IOS 1팀", "IOS 1팀이 포함되어야 함")
        #expect(result[1].teams.description == "IOS 2팀", "IOS 2팀이 포함되어야 함")
        #expect(result[2].teams.description == "AND 1팀", "AND 1팀이 포함되어야 함")
        #expect(result[3].teams.description == "WEB 1팀", "WEB 1팀이 포함되어야 함")
        #expect(mockOnBoardingRepository.lastFetchTeamsGenerationId == generationId, "올바른 기수 ID가 전달되어야 함")
        #expect(mockOnBoardingRepository.fetchTeamsCallCount == 1, "Repository가 한 번 호출되어야 함")
    }

    @Test("TC-008: 팀 목록 조회 실패 (잘못된 기수)")
    func test_fetch_teams_failure_invalid_generation() async throws {
        // Given: 잘못된 기수 에러 설정
        mockOnBoardingRepository.configureTeamsFailure(OnBoardingError.unknownError)

        // When & Then: 잘못된 기수 에러 검증
        await #expect(throws: OnBoardingError.unknownError) {
            try await withDependencies {
                $0.onBoardingRepository = mockOnBoardingRepository
            } operation: {
                let useCase = OnBoardingUseCaseImpl()
                _ = try await useCase.fetchTeams(generationId: -1) // 잘못된 기수
            }
        }
    }

    @Test("TC-009: 관리 권한 목록 조회 성공")
    func test_fetch_managing_success() async throws {
        // Given: 성공적인 관리 권한 목록 설정
        let expectedManaging = [
            SelectManaging(managingKeys: "TEAM_MANAGING", managing: .teamManaging),
            SelectManaging(managingKeys: "SCHEDULE_REMINDER", managing: .scheduleReminder),
            SelectManaging(managingKeys: "PHOTO", managing: .photo),
            SelectManaging(managingKeys: "LOCATION_RENTAL", managing: .locationRental)
        ]
        mockOnBoardingRepository.configureManagingSuccess(expectedManaging)

        // When: 관리 권한 목록 조회 실행
        let result = try await withDependencies {
            $0.onBoardingRepository = mockOnBoardingRepository
        } operation: {
            let useCase = OnBoardingUseCaseImpl()
            return try await useCase.fetchManaging()
        }

        // Then: 관리 권한 목록 검증
        #expect(result.count == 4, "4개의 관리 권한이 조회되어야 함")
        #expect(result[0].managing.desc == "팀매니징", "팀매니징 권한이 포함되어야 함")
        #expect(result[1].managing.desc == "일정 리마인드", "일정 리마인드 권한이 포함되어야 함")
        #expect(result[2].managing.desc == "사진 촬영", "사진 촬영 권한이 포함되어야 함")
        #expect(result[3].managing.desc == "장소 대관", "장소 대관 권한이 포함되어야 함")
        #expect(mockOnBoardingRepository.fetchManagingCallCount == 1, "Repository가 한 번 호출되어야 함")
    }

    @Test("TC-010: 관리 권한 목록 조회 실패 (권한 없음)")
    func test_fetch_managing_failure_unauthorized() async throws {
        // Given: 권한 없음 에러 설정
        mockOnBoardingRepository.configureManagingFailure(OnBoardingError.unknownError)

        // When & Then: 권한 없음 에러 검증
        await #expect(throws: OnBoardingError.unknownError) {
            try await withDependencies {
                $0.onBoardingRepository = mockOnBoardingRepository
            } operation: {
                let useCase = OnBoardingUseCaseImpl()
                _ = try await useCase.fetchManaging()
            }
        }
    }

    @Test("TC-011: 완전한 온보딩 플로우 시뮬레이션")
    func test_complete_onboarding_flow() async throws {
        // Given: 완전한 온보딩 플로우 설정
        let inviteCode = "COMPLETE2026"
        let generationId = 27

        // 1. 초대 코드 검증
        let verifyResult = VerifyCodeEntity(generationID: generationId, type: Staff.manager)
        mockOnBoardingRepository.configureVerifyCodeSuccess(verifyResult)

        // 2. 직무 목록
        let jobs = [
            SelectJob(jobKeys: "developer", job: .ios),
            SelectJob(jobKeys: "designer", job: SelectParts.designer)
        ]
        mockOnBoardingRepository.configureJobsSuccess(jobs)

        // 3. 팀 목록
        let teams = [
            SelectTeamEntity(teamId: 1, teams: SelectTeams.ios1),
            SelectTeamEntity(teamId: 2, teams: SelectTeams.web1)
        ]
        mockOnBoardingRepository.configureTeamsSuccess(teams)

        // 4. 관리 권한 목록 (Manager인 경우)
        let managing = [
            SelectManaging(managingKeys: "TEAM_MANAGING", managing: .teamManaging),
            SelectManaging(managingKeys: "PHOTO", managing: .photo)
        ]
        mockOnBoardingRepository.configureManagingSuccess(managing)

        // When: 완전한 온보딩 플로우 실행
        let (verifyCodeResult, jobsResult, teamsResult, managingResult) = try await withDependencies {
            $0.onBoardingRepository = mockOnBoardingRepository
        } operation: {
            let useCase = OnBoardingUseCaseImpl()

            let verify = try await useCase.verifyCode(code: inviteCode)
            let jobs = try await useCase.fetchJobs()
            let teams = try await useCase.fetchTeams(generationId: verify.generationID)
            let managing = try await useCase.fetchManaging()

            return (verify, jobs, teams, managing)
        }

        // Then: 완전한 플로우 검증
        #expect(verifyCodeResult.generationID == generationId, "올바른 기수가 검증되어야 함")
        #expect(verifyCodeResult.type == Staff.manager, "Manager 권한이 검증되어야 함")
        #expect(jobsResult.count == 2, "직무 목록이 조회되어야 함")
        #expect(teamsResult.count == 2, "팀 목록이 조회되어야 함")
        #expect(managingResult.count == 2, "관리 권한 목록이 조회되어야 함")

        // Repository 호출 횟수 검증
        #expect(mockOnBoardingRepository.verifyCodeCallCount == 1, "초대 코드 검증이 호출되어야 함")
        #expect(mockOnBoardingRepository.fetchJobsCallCount == 1, "직무 조회가 호출되어야 함")
        #expect(mockOnBoardingRepository.fetchTeamsCallCount == 1, "팀 조회가 호출되어야 함")
        #expect(mockOnBoardingRepository.fetchManagingCallCount == 1, "관리 권한 조회가 호출되어야 함")
    }

    @Test("TC-012: 빈 목록 처리")
    func test_empty_list_handling() async throws {
        // Given: 빈 목록들 설정
        mockOnBoardingRepository.configureJobsSuccess([])
        mockOnBoardingRepository.configureTeamsSuccess([])
        mockOnBoardingRepository.configureManagingSuccess([])

        // When: 빈 목록 조회 실행
        let (jobsResult, teamsResult, managingResult) = try await withDependencies {
            $0.onBoardingRepository = mockOnBoardingRepository
        } operation: {
            let useCase = OnBoardingUseCaseImpl()

            let jobs = try await useCase.fetchJobs()
            let teams = try await useCase.fetchTeams(generationId: 1)
            let managing = try await useCase.fetchManaging()

            return (jobs, teams, managing)
        }

        // Then: 빈 목록 처리 검증
        #expect(jobsResult.isEmpty, "빈 직무 목록이 반환되어야 함")
        #expect(teamsResult.isEmpty, "빈 팀 목록이 반환되어야 함")
        #expect(managingResult.isEmpty, "빈 관리 권한 목록이 반환되어야 함")
    }

    @Test("TC-013: 직무/팀 선택 조합 검증")
    func test_job_team_combination_validation() async throws {
        // Given: 특정 직무와 팀 조합 설정
        let developerJobs = [
            SelectJob(jobKeys: "developer", job: .ios),
            SelectJob(jobKeys: "backend", job: .backend)
        ]
        let techTeams = [
            SelectTeamEntity(teamId: 1, teams: SelectTeams.ios1),
            SelectTeamEntity(teamId: 2, teams: SelectTeams.and1),
            SelectTeamEntity(teamId: 3, teams: SelectTeams.web2)
        ]

        mockOnBoardingRepository.configureJobsSuccess(developerJobs)
        mockOnBoardingRepository.configureTeamsSuccess(techTeams)

        // When: 직무와 팀 목록 조회
        let (jobs, teams) = try await withDependencies {
            $0.onBoardingRepository = mockOnBoardingRepository
        } operation: {
            let useCase = OnBoardingUseCaseImpl()

            let jobs = try await useCase.fetchJobs()
            let teams = try await useCase.fetchTeams(generationId: 25)

            return (jobs, teams)
        }

        // Then: 직무/팀 조합 검증
        let developerJob = jobs.first { $0.job == .ios }
        let backendJob = jobs.first { $0.job == .backend }
        let iosTeam = teams.first { $0.teams.description.contains("IOS") }
        let androidTeam = teams.first { $0.teams.description.contains("AND") }
        let webTeam = teams.first { $0.teams.description.contains("WEB") }

        #expect(developerJob != nil, "개발자 직무가 있어야 함")
        #expect(backendJob != nil, "백엔드 직무가 있어야 함")
        #expect(iosTeam != nil, "iOS 팀이 있어야 함")
        #expect(androidTeam != nil, "Android 팀이 있어야 함")
        #expect(webTeam != nil, "WEB 팀이 있어야 함")
    }

    @Test("TC-014: 대량 데이터 처리")
    func test_large_data_handling() async throws {
        // Given: 대량 팀 데이터 설정 (50개 팀)
        let largeTeams: [SelectTeamEntity] = (1...50).map { index in
            let validTeams: [SelectTeams] = [SelectTeams.ios1, SelectTeams.ios2, SelectTeams.and1, SelectTeams.and2, SelectTeams.web1, SelectTeams.web2]
            return SelectTeamEntity(
                teamId: index,
                teams: validTeams[(index - 1) % validTeams.count]
            )
        }
        mockOnBoardingRepository.configureTeamsSuccess(largeTeams)

        // When: 대량 팀 데이터 조회 실행
        let result = try await withDependencies {
            $0.onBoardingRepository = mockOnBoardingRepository
        } operation: {
            let useCase = OnBoardingUseCaseImpl()
            return try await useCase.fetchTeams(generationId: 30)
        }

        // Then: 대량 데이터 처리 검증
        #expect(result.count == 50, "50개 팀이 모두 조회되어야 함")
        #expect(result.first?.id == 1, "첫 번째 팀 ID가 1이어야 함")
        #expect(result.last?.id == 50, "마지막 팀 ID가 50이어야 함")
        #expect(
            result.allSatisfy { [SelectTeams.ios1, SelectTeams.ios2, SelectTeams.and1, SelectTeams.and2, SelectTeams.web1, SelectTeams.web2].contains($0.teams) },
            "모든 팀이 현재 Entity가 인식하는 팀이어야 함"
        )
    }

    @Test("TC-015: 동시 온보딩 요청 처리")
    func test_concurrent_onboarding_requests() async throws {
        // Given: 동시 요청을 위한 데이터 설정
        let testJobs = [SelectJob(jobKeys: "developer", job: .ios)]
        let testTeams = [SelectTeamEntity(teamId: 1, teams: SelectTeams.ios1)]

        mockOnBoardingRepository.configureJobsSuccess(testJobs)
        mockOnBoardingRepository.configureTeamsSuccess(testTeams)

        // When: 직무와 팀 목록을 동시에 요청
        let results = try await withThrowingTaskGroup(of: Any.self, returning: ([SelectJob], [SelectTeamEntity]).self) { group in

            group.addTask {
                try await withDependencies {
                    $0.onBoardingRepository = mockOnBoardingRepository
                } operation: {
                    let useCase = OnBoardingUseCaseImpl()
                    return try await useCase.fetchJobs()
                }
            }

            group.addTask {
                try await withDependencies {
                    $0.onBoardingRepository = mockOnBoardingRepository
                } operation: {
                    let useCase = OnBoardingUseCaseImpl()
                    return try await useCase.fetchTeams(generationId: 25)
                }
            }

            var jobs: [SelectJob]?
            var teams: [SelectTeamEntity]?

            for try await result in group {
                if let jobsResult = result as? [SelectJob] {
                    jobs = jobsResult
                } else if let teamsResult = result as? [SelectTeamEntity] {
                    teams = teamsResult
                }
            }

            return (jobs!, teams!)
        }

        // Then: 동시 요청 결과 검증
        #expect(results.0.count == 1, "직무 목록이 올바르게 반환되어야 함")
        #expect(results.1.count == 1, "팀 목록이 올바르게 반환되어야 함")
        #expect(results.0.first?.jobKeys == "developer", "개발자 직무가 반환되어야 함")
        #expect(results.1.first?.teams.description == "IOS 1팀", "IOS 1팀이 반환되어야 함")

        #expect(mockOnBoardingRepository.fetchJobsCallCount == 1, "직무 Repository가 호출되어야 함")
        #expect(mockOnBoardingRepository.fetchTeamsCallCount == 1, "팀 Repository가 호출되어야 함")
    }
}

// MARK: - Test Data Structures
// MARK: - Mock Repository
@MainActor
class OnBoardingRepositorySpy: OnBoardingInterface {

    // MARK: - Call Tracking
    var verifyCodeCallCount = 0
    var fetchJobsCallCount = 0
    var fetchTeamsCallCount = 0
    var fetchManagingCallCount = 0

    // MARK: - Last Parameters
    var lastVerifyCode: String?
    var lastFetchTeamsGenerationId: Int?

    // MARK: - Configured Responses
    private var verifyCodeResponse: Result<VerifyCodeEntity, OnBoardingError>?
    private var jobsResponse: Result<[SelectJob], OnBoardingError>?
    private var teamsResponse: Result<[SelectTeamEntity], OnBoardingError>?
    private var managingResponse: Result<[SelectManaging], OnBoardingError>?

    // MARK: - Implementation
    func verifyCode(code: String) async throws(OnBoardingError) -> VerifyCodeEntity {
        verifyCodeCallCount += 1
        lastVerifyCode = code

        if let response = verifyCodeResponse {
            return try response.get()
        }

        throw OnBoardingError.unknownError
    }

    func fetchJobs() async throws(OnBoardingError) -> [SelectJob] {
        fetchJobsCallCount += 1

        if let response = jobsResponse {
            return try response.get()
        }

        throw OnBoardingError.unknownError
    }

    func fetchTeams(generationId: Int) async throws(OnBoardingError) -> [SelectTeamEntity] {
        fetchTeamsCallCount += 1
        lastFetchTeamsGenerationId = generationId

        if let response = teamsResponse {
            return try response.get()
        }

        throw OnBoardingError.unknownError
    }

    func fetchManaging() async throws(OnBoardingError) -> [SelectManaging] {
        fetchManagingCallCount += 1

        if let response = managingResponse {
            return try response.get()
        }

        throw OnBoardingError.unknownError
    }

    // MARK: - Configuration Methods
    func configureVerifyCodeSuccess(_ verification: VerifyCodeEntity) {
        verifyCodeResponse = .success(verification)
    }

    func configureVerifyCodeFailure(_ error: Error) {
        verifyCodeResponse = .failure(OnBoardingError.from(error))
    }

    func configureJobsSuccess(_ jobs: [SelectJob]) {
        jobsResponse = .success(jobs)
    }

    func configureJobsFailure(_ error: Error) {
        jobsResponse = .failure(OnBoardingError.from(error))
    }

    func configureTeamsSuccess(_ teams: [SelectTeamEntity]) {
        teamsResponse = .success(teams)
    }

    func configureTeamsFailure(_ error: Error) {
        teamsResponse = .failure(OnBoardingError.from(error))
    }

    func configureManagingSuccess(_ managing: [SelectManaging]) {
        managingResponse = .success(managing)
    }

    func configureManagingFailure(_ error: Error) {
        managingResponse = .failure(OnBoardingError.from(error))
    }
}
