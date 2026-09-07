//
//  ProfileUseCaseTest.swift
//  UseCaseTests
//
//  Created by DDD on 2026-04-16
//

import Foundation
import Testing

import AuthDomainInterface
@testable import ProfileDomain
@testable import ProfileDomainInterface

import ComposableArchitecture

@Suite("Profile UseCase Tests - Complete TDD Implementation")
@MainActor
struct ProfileUseCaseTest {
  // MARK: - Test Dependencies

  private var mockProfileRepository: MockProfileRepository!

  init() async {
    mockProfileRepository = MockProfileRepository()
  }

  // MARK: - Core Profile Tests (12 Test Cases)

  @Test("TC-001: 프로필 조회 성공 (Manager)")
  func get_profile_success_manager() async throws {
    // Given: Manager 프로필 설정
    let expectedProfile = ProfileEntity(
      userID: 123,
      name: "관리자 김철수",
      generation: "15기",
      team: SelectTeams.ios1,
      jobRole: SelectParts.ios,
      role: Staff.manager,
      manger: [StaffManaging.teamManaging, StaffManaging.attendanceCheck]
    )
    mockProfileRepository.configureGetProfileSuccess(expectedProfile)

    // When: 프로필 조회 실행
    let result = try await withDependencies {
      $0.profileRepository = mockProfileRepository
    } operation: {
      let useCase = ProfileUseCaseImpl()
      return try await useCase.getProfile()
    }

    // Then: Manager 프로필 검증
    #expect(result.userID == 123, "사용자 ID가 올바르게 조회되어야 함")
    #expect(result.name == "관리자 김철수", "이름이 올바르게 조회되어야 함")
    #expect(result.generation == "15기", "기수가 올바르게 조회되어야 함")
    #expect(result.team == SelectTeams.ios1, "팀이 올바르게 조회되어야 함")
    #expect(result.jobRole == SelectParts.ios, "직무가 올바르게 조회되어야 함")
    #expect(result.role == Staff.manager, "Manager 권한이 올바르게 설정되어야 함")
    #expect(result.manger?.count == 2, "관리 팀이 2개여야 함")
    #expect(mockProfileRepository.getProfileCallCount == 1, "Repository가 한 번 호출되어야 함")
  }

  @Test("TC-002: 프로필 조회 성공 (Member)")
  func get_profile_success_member() async throws {
    // Given: Member 프로필 설정
    let expectedProfile = ProfileEntity(
      userID: 456,
      name: "멤버 박영희",
      generation: "16기",
      team: SelectTeams.and1,
      jobRole: SelectParts.designer,
      role: Staff.member,
      manger: nil
    )
    mockProfileRepository.configureGetProfileSuccess(expectedProfile)

    // When: 프로필 조회 실행
    let result = try await withDependencies {
      $0.profileRepository = mockProfileRepository
    } operation: {
      let useCase = ProfileUseCaseImpl()
      return try await useCase.getProfile()
    }

    // Then: Member 프로필 검증
    #expect(result.userID == 456, "사용자 ID가 올바르게 조회되어야 함")
    #expect(result.name == "멤버 박영희", "이름이 올바르게 조회되어야 함")
    #expect(result.role == .member, "Member 권한이 올바르게 설정되어야 함")
    #expect(result.manger == nil, "Member는 관리 팀이 없어야 함")
  }

  @Test("TC-003: 프로필 조회 실패 (네트워크 오류)")
  func get_profile_failure_network() async throws {
    // Given: 네트워크 오류 설정
    mockProfileRepository.configureGetProfileFailure(ProfileError.unknownError("network unavailable"))

    // When & Then: 네트워크 오류 검증
    await #expect(throws: ProfileError.unknownError("network unavailable")) {
      try await withDependencies {
        $0.profileRepository = mockProfileRepository
      } operation: {
        let useCase = ProfileUseCaseImpl()
        _ = try await useCase.getProfile()
      }
    }

    #expect(mockProfileRepository.getProfileCallCount == 1, "실패해도 Repository는 호출되어야 함")
  }

  @Test("TC-004: 프로필 수정 성공 (Member → Manager 승급)")
  func edit_profile_success_promotion() async throws {
    // Given: Member에서 Manager로 승급하는 프로필 수정
    let userSession = UserSession(
      userID: 789,
      name: "승급자 이민수",
      selectPart: SelectParts.ios,
      userRole: Staff.manager, // 승급됨
      managing: [StaffManaging.teamManaging, StaffManaging.attendanceCheck],
      selectTeam: SelectTeams.ios2,
      selectTeamId: 1,
      generationId: 17,
      inviteCode: "PROMOTE123",
      generation: "17기"
    )

    let expectedUpdatedProfile = ProfileEntity(
      userID: 789,
      name: "승급자 이민수",
      generation: "17기",
      team: SelectTeams.ios2,
      jobRole: SelectParts.ios,
      role: Staff.manager, // 승급된 권한
      manger: [StaffManaging.teamManaging, StaffManaging.attendanceCheck]
    )
    mockProfileRepository.configureEditProfileSuccess(expectedUpdatedProfile)

    // When: 프로필 수정 실행
    let result = try await withDependencies {
      $0.profileRepository = mockProfileRepository
    } operation: {
      let useCase = ProfileUseCaseImpl()
      return try await useCase.editUser(userSession: userSession)
    }

    // Then: 승급된 프로필 검증
    #expect(result.role == Staff.manager, "Manager로 승급되어야 함")
    #expect(result.manger?.count == 2, "관리 팀이 설정되어야 함")
    #expect(result.name == "승급자 이민수", "이름이 올바르게 업데이트되어야 함")
    #expect(mockProfileRepository.lastEditInput?.managerRoles?.count == 2, "관리 역할이 전달되어야 함")
    #expect(mockProfileRepository.editProfileCallCount == 1, "Repository가 한 번 호출되어야 함")
  }

  @Test("TC-005: 프로필 수정 성공 (Member 정보 업데이트)")
  func edit_profile_success_member_update() async throws {
    // Given: Member 정보 업데이트
    let userSession = UserSession(
      userID: 101,
      name: "업데이트 최지혜",
      selectPart: SelectParts.designer,
      userRole: Staff.member,
      managing: [],
      selectTeam: SelectTeams.and2,
      selectTeamId: 2,
      generationId: 18,
      inviteCode: "UPDATE456",
      generation: "18기"
    )

    let expectedUpdatedProfile = ProfileEntity(
      userID: 101,
      name: "업데이트 최지혜",
      generation: "18기",
      team: SelectTeams.and2,
      jobRole: SelectParts.designer,
      role: Staff.member,
      manger: nil
    )
    mockProfileRepository.configureEditProfileSuccess(expectedUpdatedProfile)

    // When: Member 프로필 수정 실행
    let result = try await withDependencies {
      $0.profileRepository = mockProfileRepository
    } operation: {
      let useCase = ProfileUseCaseImpl()
      return try await useCase.editUser(userSession: userSession)
    }

    // Then: 업데이트된 Member 프로필 검증
    #expect(result.role == Staff.member, "Member 권한이 유지되어야 함")
    #expect(result.manger == nil, "Member는 관리 권한이 없어야 함")
    #expect(result.team == SelectTeams.and2, "팀이 올바르게 업데이트되어야 함")
    #expect(result.jobRole == SelectParts.designer, "직무가 올바르게 업데이트되어야 함")
    #expect(mockProfileRepository.lastEditInput?.managerRoles == nil, "Manager 역할이 전달되지 않아야 함")
  }

  @Test("TC-005-1: 운영진에서 멤버로 기수 변경 시 managerRoles 제외")
  func edit_profile_demote_to_member_omits_manager_roles() async throws {
    // Given: 이전 운영진 권한이 세션에 남아 있지만 초대코드 검증 결과가 Member인 경우
    let userSession = UserSession(
      userID: 202,
      name: "멤버 전환자",
      selectPart: SelectParts.ios,
      userRole: Staff.member,
      managing: [StaffManaging.teamManaging, StaffManaging.attendanceCheck],
      selectTeam: SelectTeams.ios1,
      selectTeamId: 1,
      generationId: 19,
      inviteCode: "MEMBER999",
      generation: "19기"
    )

    let expectedUpdatedProfile = ProfileEntity(
      userID: 202,
      name: "멤버 전환자",
      generation: "19기",
      team: SelectTeams.ios1,
      jobRole: SelectParts.ios,
      role: Staff.member,
      manger: nil
    )
    mockProfileRepository.configureEditProfileSuccess(expectedUpdatedProfile)

    // When: Member 초대코드 기준 프로필 수정 실행
    let result = try await withDependencies {
      $0.profileRepository = mockProfileRepository
    } operation: {
      let useCase = ProfileUseCaseImpl()
      return try await useCase.editUser(userSession: userSession)
    }

    // Then: 기존 운영진 업무가 남아 있어도 Member 요청에는 managerRoles가 없어야 함
    #expect(result.role == Staff.member, "Member로 변경되어야 함")
    #expect(result.manger == nil, "Member 응답에는 관리 권한이 없어야 함")
    #expect(mockProfileRepository.lastEditInput?.managerRoles == nil, "Member 변경 요청에는 managerRoles가 전달되지 않아야 함")
    #expect(mockProfileRepository.editProfileCallCount == 1, "Repository가 한 번 호출되어야 함")
  }

  @Test("TC-006: 프로필 수정 실패 (권한 없음)")
  func edit_profile_failure_unauthorized() async throws {
    // Given: 권한 없음 에러 설정
    let userSession = UserSession(
      userID: 999,
      name: "권한없음",
      selectPart: SelectParts.ios,
      userRole: Staff.member,
      managing: [],
      selectTeam: SelectTeams.ios1,
      selectTeamId: 1,
      generationId: 1,
      inviteCode: "INVALID",
      generation: "1기"
    )
    mockProfileRepository.configureEditProfileFailure(EditProfileError.profileLocked)

    // When & Then: 권한 오류 검증
    await #expect(throws: EditProfileError.profileLocked) {
      try await withDependencies {
        $0.profileRepository = mockProfileRepository
      } operation: {
        let useCase = ProfileUseCaseImpl()
        _ = try await useCase.editUser(userSession: userSession)
      }
    }
  }

  @Test("TC-007: UserSession 동기화 검증")
  func user_session_synchronization() async throws {
    // Given: UserSession 동기화를 위한 프로필 설정
    let profile = ProfileEntity(
      userID: 555,
      name: "동기화 테스트",
      generation: "19기",
      team: SelectTeams.ios1,
      jobRole: SelectParts.pm,
      role: Staff.manager,
      manger: [StaffManaging.teamManaging]
    )
    mockProfileRepository.configureGetProfileSuccess(profile)

    // When: 프로필 조회로 UserSession 동기화
    _ = try await withDependencies {
      $0.profileRepository = mockProfileRepository
    } operation: {
      let useCase = ProfileUseCaseImpl()
      return try await useCase.getProfile()
    }

    // Then: UserSession 동기화는 실제 @Shared에서 처리됨을 확인
    // (Mock으로는 @Shared 상태를 직접 검증할 수 없지만, UseCase 로직이 정상 동작함을 확인)
    #expect(mockProfileRepository.getProfileCallCount == 1, "프로필 조회가 호출되어야 함")
  }

  @Test("TC-008: 권한 승급 시나리오 (Member → Manager)")
  func authority_promotion_scenario() async throws {
    // Given: 권한 승급 시나리오
    // 1. 기존 Member 프로필 조회
    let memberProfile = ProfileEntity(
      userID: 333,
      name: "승급대상자",
      generation: "20기",
      team: SelectTeams.and1,
      jobRole: SelectParts.ios,
      role: Staff.member,
      manger: nil
    )
    mockProfileRepository.configureGetProfileSuccess(memberProfile)

    // 2. Manager로 승급된 프로필
    let managerProfile = ProfileEntity(
      userID: 333,
      name: "승급대상자",
      generation: "20기",
      team: SelectTeams.and1,
      jobRole: SelectParts.ios,
      role: Staff.manager,
      manger: [StaffManaging.teamManaging]
    )
    mockProfileRepository.configureEditProfileSuccess(managerProfile)

    // When: 승급 프로세스 실행
    let initialProfile = try await withDependencies {
      $0.profileRepository = mockProfileRepository
    } operation: {
      let useCase = ProfileUseCaseImpl()
      return try await useCase.getProfile()
    }

    let promotedUserSession = UserSession(
      userID: 333,
      name: "승급대상자",
      selectPart: SelectParts.ios,
      userRole: Staff.manager, // 승급
      managing: [StaffManaging.teamManaging],
      selectTeam: SelectTeams.and1,
      selectTeamId: 1,
      generationId: 20,
      inviteCode: "PROMOTION",
      generation: "20기"
    )

    let updatedProfile = try await withDependencies {
      $0.profileRepository = mockProfileRepository
    } operation: {
      let useCase = ProfileUseCaseImpl()
      return try await useCase.editUser(userSession: promotedUserSession)
    }

    // Then: 승급 프로세스 검증
    #expect(initialProfile.role == Staff.member, "초기에는 Member여야 함")
    #expect(initialProfile.manger == nil, "초기에는 관리 권한이 없어야 함")
    #expect(updatedProfile.role == Staff.manager, "승급 후 Manager여야 함")
    #expect(updatedProfile.manger?.count == 1, "승급 후 관리 권한이 있어야 함")
  }

  @Test("TC-009: 팀 변경 시나리오")
  func team_change_scenario() async throws {
    // Given: 팀 변경 시나리오
    let userSession = UserSession(
      userID: 777,
      name: "팀변경자",
      selectPart: SelectParts.designer,
      userRole: Staff.member,
      managing: [],
      selectTeam: SelectTeams.web1,
      selectTeamId: 3,
      generationId: 21,
      inviteCode: "TEAMCHANGE",
      generation: "21기"
    )

    let expectedProfile = ProfileEntity(
      userID: 777,
      name: "팀변경자",
      generation: "21기",
      team: SelectTeams.web1,
      jobRole: SelectParts.designer,
      role: Staff.member,
      manger: nil
    )
    mockProfileRepository.configureEditProfileSuccess(expectedProfile)

    // When: 팀 변경 실행
    let result = try await withDependencies {
      $0.profileRepository = mockProfileRepository
    } operation: {
      let useCase = ProfileUseCaseImpl()
      return try await useCase.editUser(userSession: userSession)
    }

    // Then: 팀 변경 검증
    #expect(result.team == SelectTeams.web1, "팀이 WEB 1으로 변경되어야 함")
    #expect(result.jobRole == SelectParts.designer, "직무가 Designer로 설정되어야 함")
    #expect(mockProfileRepository.lastEditInput?.teamId == 3, "올바른 팀 ID가 전달되어야 함")
  }

  @Test("TC-010: 직접 EditProfileInput 사용")
  func direct_edit_profile_input() async throws {
    // Given: 직접적인 EditProfileInput 사용
    let directInput = EditProfileInput(
      name: "직접수정",
      generationId: 22,
      jobRole: SelectParts.pm,
      teamId: 4,
      managerRoles: [
        StaffManaging.teamManaging,
        StaffManaging.photo,
        StaffManaging.attendanceCheck
      ],
      inviteCode: "DIRECT123"
    )

    let expectedProfile = ProfileEntity(
      userID: 888,
      name: "직접수정",
      generation: "22기",
      team: SelectTeams.ios2,
      jobRole: SelectParts.pm,
      role: Staff.manager,
      manger: [StaffManaging.teamManaging, StaffManaging.photo, StaffManaging.attendanceCheck]
    )
    mockProfileRepository.configureEditProfileSuccess(expectedProfile)

    // When: 직접 EditProfile 호출
    let result = try await withDependencies {
      $0.profileRepository = mockProfileRepository
    } operation: {
      let useCase = ProfileUseCaseImpl()
      return try await useCase.editProfile(input: directInput)
    }

    // Then: 직접 수정 검증
    #expect(result.name == "직접수정", "이름이 올바르게 수정되어야 함")
    #expect(result.jobRole == SelectParts.pm, "직무가 올바르게 수정되어야 함")
    #expect(result.manger?.count == 3, "3개 팀 관리 권한이 있어야 함")
    #expect(mockProfileRepository.lastEditInput?.name == "직접수정", "올바른 입력이 전달되어야 함")
  }

  @Test("TC-011: 대량 관리 팀 처리")
  func large_management_teams() async throws {
    // Given: 대량 관리 팀을 가진 Manager
    let largeManagingTeams: [StaffManaging] = [
      StaffManaging.teamManaging,
      StaffManaging.scheduleReminder,
      StaffManaging.photo,
      StaffManaging.locationRental,
      StaffManaging.attendanceCheck
    ]
    let userSession = UserSession(
      userID: 111,
      name: "수퍼매니저",
      selectPart: SelectParts.ios,
      userRole: Staff.manager,
      managing: largeManagingTeams,
      selectTeam: SelectTeams.ios1,
      selectTeamId: 1,
      generationId: 23,
      inviteCode: "SUPER123",
      generation: "23기"
    )

    let expectedProfile = ProfileEntity(
      userID: 111,
      name: "수퍼매니저",
      generation: "23기",
      team: SelectTeams.ios1,
      jobRole: SelectParts.ios,
      role: Staff.manager,
      manger: largeManagingTeams
    )
    mockProfileRepository.configureEditProfileSuccess(expectedProfile)

    // When: 대량 관리 팀 수정 실행
    let result = try await withDependencies {
      $0.profileRepository = mockProfileRepository
    } operation: {
      let useCase = ProfileUseCaseImpl()
      return try await useCase.editUser(userSession: userSession)
    }

    // Then: 대량 관리 팀 검증
    #expect(result.manger?.count == 5, "5개 팀을 관리해야 함")
    #expect(result.manger?.contains(StaffManaging.teamManaging) == true, "팀매니징 권한이 있어야 함")
    #expect(result.manger?.contains(StaffManaging.scheduleReminder) == true, "일정 리마인드 권한이 있어야 함")
    #expect(result.manger?.contains(StaffManaging.photo) == true, "사진 촬영 권한이 있어야 함")
    #expect(mockProfileRepository.lastEditInput?.managerRoles?.count == 5, "5개 관리 역할이 전달되어야 함")
  }

  @Test("TC-012: 동시 프로필 요청 처리")
  func concurrent_profile_requests() async throws {
    // Given: 동시 요청을 위한 프로필 설정
    let testProfile = ProfileEntity(
      userID: 999,
      name: "동시성 테스트",
      generation: "24기",
      team: SelectTeams.and1,
      jobRole: SelectParts.ios,
      role: Staff.member,
      manger: nil
    )
    mockProfileRepository.configureGetProfileSuccess(testProfile)

    // When: 5개의 동시 프로필 조회 요청
    let results = try await withThrowingTaskGroup(of: ProfileEntity.self, returning: [ProfileEntity].self) { group in
      for _ in 1 ... 5 {
        group.addTask {
          try await withDependencies {
            $0.profileRepository = mockProfileRepository
          } operation: {
            let useCase = ProfileUseCaseImpl()
            return try await useCase.getProfile()
          }
        }
      }

      var results: [ProfileEntity] = []
      for try await result in group {
        results.append(result)
      }
      return results
    }

    // Then: 동시 요청 결과 검증
    #expect(results.count == 5, "모든 동시 요청이 완료되어야 함")
    #expect(results.allSatisfy { $0.userID == 999 }, "모든 결과가 동일한 사용자 ID를 가져야 함")
    #expect(results.allSatisfy { $0.name == "동시성 테스트" }, "모든 결과가 동일한 이름을 가져야 함")
    #expect(results.allSatisfy { $0.role == Staff.member }, "모든 결과가 동일한 권한을 가져야 함")
    #expect(mockProfileRepository.getProfileCallCount == 5, "Repository가 5번 호출되어야 함")
  }
}

// MARK: - Mock Repository

@MainActor
final class MockProfileRepository: ProfileInterface {
  // MARK: - Call Tracking

  var getProfileCallCount = 0
  var editProfileCallCount = 0

  // MARK: - Last Parameters

  var lastEditInput: EditProfileInput?

  // MARK: - Configured Responses

  private var getProfileResponse: Result<ProfileEntity, ProfileError>?
  private var editProfileResponse: Result<ProfileEntity, EditProfileError>?

  // MARK: - Implementation

  func getProfile() async throws(ProfileError) -> ProfileEntity {
    getProfileCallCount += 1

    if let response = getProfileResponse {
      return try response.get()
    }

    throw ProfileError.unknownError("not configured")
  }

  func editProfile(input: EditProfileInput) async throws(EditProfileError) -> ProfileEntity {
    editProfileCallCount += 1
    lastEditInput = input

    if let response = editProfileResponse {
      return try response.get()
    }

    throw EditProfileError.unknownError("not configured")
  }

  func getCachedProfile() async -> ProfileEntity? {
    try? getProfileResponse?.get()
  }

  func refreshProfile() async throws(ProfileError) -> ProfileEntity {
    try await getProfile()
  }

  // MARK: - Configuration Methods

  func configureGetProfileSuccess(_ profile: ProfileEntity) {
    getProfileResponse = .success(profile)
  }

  func configureGetProfileFailure(_ error: Error) {
    getProfileResponse = .failure(ProfileError.from(error))
  }

  func configureEditProfileSuccess(_ profile: ProfileEntity) {
    editProfileResponse = .success(profile)
  }

  func configureEditProfileFailure(_ error: Error) {
    editProfileResponse = .failure(EditProfileError.from(error))
  }
}
