//
//  ProfileTestSupport.swift
//  ProfileTests
//
//  Created by DDD on 2026-09-03
//  Copyright © 2026 DDD , Ltd. All rights reserved.
//
//  Profile 테스트가 공유하는 스텁과 픽스처.
//  ProfileUseCase 는 프로토콜이라 그대로 대체하고,
//  Feature 테스트는 DomainInterface 계약만 스텁으로 교체한다.
//

import Foundation

import AuthDomainInterface
import ProfileDomainInterface

import ComposableArchitecture

// MARK: - 공유 픽스처

enum ProfileTestSupport {
  /// 멤버 역할 + 팀이 있는 기본 프로필.
  static let memberProfile = ProfileEntity(
    userID: 1,
    name: "김철수",
    generation: "2기",
    team: .ios1,
    jobRole: .ios,
    role: .member,
    manger: nil
  )

  /// 운영진 역할 + 담당 업무가 있는 프로필. (manager 분기 + managerRoles 비어있지 않음)
  static let managerProfile = ProfileEntity(
    userID: 2,
    name: "박매니저",
    generation: "11기",
    team: .and1,
    jobRole: .android,
    role: .manager,
    manger: [.teamManaging, .attendanceCheck]
  )

  /// 운영진이지만 담당 업무가 비어 있는 프로필. (managerRoles 비어있음 분기)
  static let managerProfileWithoutRoles = ProfileEntity(
    userID: 3,
    name: "이운영",
    generation: "11기",
    team: .web2,
    jobRole: .frontend,
    role: .manager,
    manger: []
  )

  /// 팀이 없는 멤버 프로필. (`team ?? .unknown` 분기)
  static let memberProfileWithoutTeam = ProfileEntity(
    userID: 4,
    name: "무소속",
    generation: "",
    team: nil,
    jobRole: .pm,
    role: .member,
    manger: nil
  )

  static let withdrawSuccess = WithdrawEntity(
    isSuccess: true,
    code: "200",
    message: "탈퇴 완료"
  )

  static let withdrawRejected = WithdrawEntity(
    isSuccess: false,
    code: "400",
    message: "탈퇴 불가"
  )

  static let authExitSuccess = AuthExitEntity(
    code: "200",
    message: "로그아웃 완료",
    detail: nil
  )

}

// MARK: - ProfileUseCase 스텁

struct StubProfileUseCase: ProfileUseCaseInterface {
  let cachedProfile: ProfileEntity?
  let getProfileResult: Result<ProfileEntity, ProfileError>
  let refreshProfileResult: Result<ProfileEntity, ProfileError>

  init(
    cachedProfile: ProfileEntity? = nil,
    getProfileResult: Result<ProfileEntity, ProfileError> = .failure(.loadFailed),
    refreshProfileResult: Result<ProfileEntity, ProfileError> = .failure(.loadFailed)
  ) {
    self.cachedProfile = cachedProfile
    self.getProfileResult = getProfileResult
    self.refreshProfileResult = refreshProfileResult
  }

  func getCachedProfile() async -> ProfileEntity? {
    cachedProfile
  }

  func getProfile() async throws(ProfileError) -> ProfileEntity {
    switch getProfileResult {
    case let .success(profile):
      return profile

    case let .failure(error):
      throw error
    }
  }

  func refreshProfile() async throws(ProfileError) -> ProfileEntity {
    switch refreshProfileResult {
    case let .success(profile):
      return profile

    case let .failure(error):
      throw error
    }
  }

  func editProfile(input _: EditProfileInput) async throws(EditProfileError) -> ProfileEntity {
    throw .profileUpdateFailed
  }
}

// MARK: - AuthRepository 스텁

struct StubAuthRepository: AuthInterface, AuthUseCaseInterface {
  let withdrawResult: Result<WithdrawEntity, AuthError>
  let logoutResult: Result<AuthExitEntity, AuthError>

  init(
    withdrawResult: Result<WithdrawEntity, AuthError> = .success(ProfileTestSupport.withdrawSuccess),
    logoutResult: Result<AuthExitEntity, AuthError> = .success(ProfileTestSupport.authExitSuccess)
  ) {
    self.withdrawResult = withdrawResult
    self.logoutResult = logoutResult
  }

  func login(provider _: SocialType, token _: String) async throws(AuthError) -> LoginEntity {
    throw .loginFailed
  }

  func refresh() async throws(AuthError) -> AuthTokens {
    throw .tokenRefreshFailed
  }

  func withDraw(token _: String) async throws(AuthError) -> WithdrawEntity {
    switch withdrawResult {
    case let .success(entity):
      return entity

    case let .failure(error):
      throw error
    }
  }

  func logout() async throws(AuthError) -> AuthExitEntity {
    switch logoutResult {
    case let .success(entity):
      return entity

    case let .failure(error):
      throw error
    }
  }

  func updateSessionCredential(with _: AuthTokens) async {}
}
