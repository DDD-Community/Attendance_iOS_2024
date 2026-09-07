//
//  AuthRepositoryImplTests.swift
//  DomainAssemblyTests
//
//  Created by DDD on 9/4/26.
//

import Foundation
import Testing

@testable import AppUpdateDomain
@testable import AttendanceDomain
@testable import AuthDomain
import AuthDomainInterface
import DDDAuthInterface
import DDDNetworkInterface
@testable import MyPageDomain
@testable import OnBoardingDomain
@testable import ProfileDomain
@testable import QRCodeDomain
@testable import ScheduleDomain
@testable import VoteDomain

import Dependencies

struct AuthRepositoryImplTests {
  @Test("로그인 성공은 토큰을 AuthService에 반영")
  func loginSuccess() async throws {
    let service = AuthServiceSpy()
    let repository = makeRepository(client: StubNetworkClient(json: #"""
      {
        "name":"사용자","oauthProvider":"GOOGLE","message":"ok","isNewUser":false,
        "accessToken":"access","refreshToken":"refresh","role":"MEMBER"
      }
      """#), authService: service) { AuthRepositoryImpl() }
    let result = try await repository.login(provider: .google, token: "oauth")
    #expect(result.name == "사용자")
    #expect(await service.signedInTokens == ["access", "refresh"])
  }

  @Test("로그인 실패는 loginFailed")
  func loginFailure() async {
    let repository = makeRepository(client: failingClient(), authService: AuthServiceSpy()) { AuthRepositoryImpl() }
    await #expect(throws: AuthError.loginFailed) {
      try await repository.login(provider: .apple, token: "bad")
    }
  }

  @Test("토큰 재발급 성공과 오류 매핑")
  func refreshPaths() async throws {
    let service = AuthServiceSpy(refreshToken: "stored-refresh")
    let tokens = try await makeRepository(
      client: StubNetworkClient(json: #"{"accessToken":"new-a","refreshToken":"new-r"}"#),
      authService: service
    ) { AuthRepositoryImpl() }.refresh()
    #expect(tokens.accessToken == "new-a")

    for (status, expected) in [(401, AuthError.refreshTokenExpired), (503, .tokenRefreshFailed)] {
      await #expect(throws: expected) {
        try await makeRepository(
          client: StubNetworkClient(error: .response(.init(httpStatus: status))),
          authService: service
        ) { AuthRepositoryImpl() }.refresh()
      }
    }
  }

  @Test("로그아웃 성공 응답 형태를 모두 처리", arguments: [
    (204, ""), (200, #"{"message":"bye"}"#), (200, "not-json"),
    (400, #"{"message":"denied"}"#), (400, "plain error")
  ])
  func logoutResponses(status: Int, json: String) async throws {
    let service = AuthServiceSpy()
    let result = try await makeAuthRepository(
      client: StubNetworkClient(statusCode: status, json: json), service: service
    ).logout()
    if (200 ... 299).contains(status) {
      #expect(await service.signOutCount == 1)
    } else {
      #expect(result.message != nil)
    }
  }

  @Test("로그아웃 전송 실패는 logoutFailed")
  func logoutFailure() async {
    await #expect(throws: AuthError.logoutFailed) {
      try await makeAuthRepository(client: failingClient(), service: AuthServiceSpy()).logout()
    }
  }

  @Test("회원 탈퇴 성공과 실패 응답 형태를 모두 처리", arguments: [
    (204, ""), (200, #"{"message":"done"}"#), (200, "not-json"),
    (400, #"{"message":"denied"}"#), (400, "plain error")
  ])
  func withdrawResponses(status: Int, json: String) async throws {
    let result = try await makeAuthRepository(
      client: StubNetworkClient(statusCode: status, json: json), service: AuthServiceSpy()
    ).withDraw(token: "oauth")
    #expect(result.isSuccess == (200 ... 299).contains(status))
  }

  @Test("회원 탈퇴 전송 실패는 accountDeletionFailed")
  func withdrawFailure() async {
    await #expect(throws: AuthError.accountDeletionFailed) {
      try await makeAuthRepository(client: failingClient(), service: AuthServiceSpy()).withDraw(token: "oauth")
    }
  }

  @Test("세션 credential 갱신을 AuthService에 전달")
  func updateSessionCredential() async {
    let service = AuthServiceSpy()
    let repository = makeRepository(client: failingClient(), authService: service) { AuthRepositoryImpl() }
    await repository.updateSessionCredential(with: .init(accessToken: "a", refreshToken: "r"))
    #expect(await service.signedInTokens == ["a", "r"])
  }

  private func makeAuthRepository(
    client: any DDDNetworkClient,
    service: AuthServiceSpy
  ) async -> AuthRepositoryImpl {
    await withDependencies {
      $0.profileLocalDataSource = ProfileLocalDataSourceSpy()
      $0.scheduleLocalDataSource = ScheduleLocalDataSourceSpy()
    } operation: {
      makeRepository(client: client, authService: service) { AuthRepositoryImpl() }
    }
  }

  private func failingClient() -> StubNetworkClient {
    StubNetworkClient(error: .response(.init(httpStatus: 503)))
  }
}

private actor AuthServiceSpy: AuthService {
  var signedInTokens: [String] = []
  var signOutCount = 0
  var storedRefreshToken: String?
  var isLoggedIn: Bool { !signedInTokens.isEmpty }
  var refreshToken: String? { storedRefreshToken }

  init(refreshToken: String? = nil) {
    storedRefreshToken = refreshToken
  }

  func signIn(accessToken: String, refreshToken: String) {
    signedInTokens = [accessToken, refreshToken]
  }

  func signOut() {
    signedInTokens = []
    signOutCount += 1
  }
}

private actor ProfileLocalDataSourceSpy: ProfileLocalDataSourceProtocol {
  func loadUser() throws(ProfileError) -> ProfileEntity? { nil }
  func saveUser(_: ProfileEntity) throws(ProfileError) {}
  func clear() throws(ProfileError) {}
}

private actor ScheduleLocalDataSourceSpy: ScheduleLocalDataSourceProtocol {
  func loadAll() throws(ScheduleError) -> [Schedule]? { nil }
  func saveAll(_: [Schedule]) throws(ScheduleError) {}
  func clear() throws(ScheduleError) {}
}
