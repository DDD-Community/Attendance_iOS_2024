//
//  RepositoryNetworkImplementationsTests.swift
//  DomainAssemblyTests
//
//  Created by DDD on 9/4/26.
//

import Foundation
import Testing

@testable import AppUpdateDomain
import AppUpdateDomainInterface
@testable import AttendanceDomain
import AttendanceDomainInterface
@testable import AuthDomain
import AuthDomainInterface
import DDDNetworkInterface
@testable import MyPageDomain
import MyPageDomainInterface
@testable import OnBoardingDomain
import OnBoardingDomainInterface
@testable import ProfileDomain
import ProfileDomainInterface
@testable import QRCodeDomain
import QRCodeDomainInterface
@testable import ScheduleDomain
import ScheduleDomainInterface
@testable import VoteDomain
import VoteDomainInterface

struct RepositoryNetworkImplementationsTests {
  @Test("온보딩 API 성공 응답 전체 경로")
  func onboardingSuccess() async throws {
    let client = StubNetworkClient([
      .response(200, #"{"generationId":1,"generationName":"12기","type":"MEMBER","description":"설명"}"#),
      .response(200, #"[{"key":"DESIGN","description":"디자인"}]"#),
      .response(200, #"[{"teamId":1,"name":"iOS"}]"#),
      .response(200, #"[{"key":"ADMIN","description":"운영"}]"#)
    ])
    let repository = makeRepository(client: client) { OnBoardingRepositoryImpl() }

    _ = try await repository.verifyCode(code: "CODE")
    #expect(try await repository.fetchJobs().count == 1)
    #expect(try await repository.fetchTeams(generationId: 1).count == 1)
    #expect(try await repository.fetchManaging().count == 1)
  }

  @Test("온보딩 코드 검증 실패는 verifyFailed")
  func onboardingVerifyFailure() async {
    let repository = makeRepository(client: failingClient()) { OnBoardingRepositoryImpl() }
    await #expect(throws: OnBoardingError.verifyFailed) {
      try await repository.verifyCode(code: "bad")
    }
  }

  @Test("온보딩 목록 실패는 networkError", arguments: [0, 1, 2])
  func onboardingListFailure(kind: Int) async {
    let repository = makeRepository(client: failingClient()) { OnBoardingRepositoryImpl() }
    await #expect(throws: OnBoardingError.networkError) {
      switch kind {
      case 0: _ = try await repository.fetchJobs()
      case 1: _ = try await repository.fetchTeams(generationId: 1)
      default: _ = try await repository.fetchManaging()
      }
    }
  }

  @Test("마이페이지 API 성공과 실패")
  func myPagePaths() async throws {
    let success = makeRepository(client: StubNetworkClient([
      .response(200, #"{"totalAttended":2,"totalLate":1,"totalAbsent":0}"#),
      .response(200, #"[{"id":1,"name":"세션","status":"ATTENDED","desc":"설명","month":9,"day":2}]"#)
    ])) { MyPageRepositoryImpl() }
    #expect(try await success.fetchAttendances().totalAttended == 2)
    #expect(try await success.fetchSchedules().count == 1)

    let failure = makeRepository(client: failingClient()) { MyPageRepositoryImpl() }
    await #expect(throws: MyPageError.loadFailed) { try await failure.fetchAttendances() }
  }

  @Test("회원가입 성공과 실패")
  func signUpPaths() async throws {
    let input = SignUpUserInput(
      name: "홍길동", generationId: 12, jobRole: .designer, teamId: 1,
      managerRoles: nil, provider: .google, token: "token",
      oauthRefreshToken: nil, invitationCode: "CODE"
    )
    let success = makeRepository(client: StubNetworkClient(json: #"""
    {
      "userId":1,"name":"홍길동","generation":"12기","team":"iOS",
      "jobRole":"DESIGN","managerRoles":null
    }
    """#)) { SignUpRepositoryImpl() }
    #expect(try await success.registerUser(input: input).name == "홍길동")

    let failure = makeRepository(client: failingClient()) { SignUpRepositoryImpl() }
    await #expect(throws: SignUpError.accountCreationFailed) {
      try await failure.registerUser(input: input)
    }
  }

  @Test("QR 생성과 검증 성공 경로")
  func qrSuccessPaths() async throws {
    let repository = makeRepository(client: StubNetworkClient([
      .response(200, #"{"id":1,"qrBase64":"aGVsbG8="}"#),
      .response(204),
      .response(200, #"{"message":"ok"}"#),
      .response(200, "not-json")
    ])) { QRCodeRepositoryImpl() }
    #expect(try await repository.createQRCode(userID: 1) == "aGVsbG8=")
    #expect(try await repository.qrValidateCheck(from: "one").isSuccess)
    #expect(try await repository.qrValidateCheck(from: "two").isSuccess)
    #expect(try await repository.qrValidateCheck(from: "three").isSuccess)
    #expect(await repository.generateQRCode(from: "invalid") == nil)
  }

  @Test("QR 검증 오류 응답 매핑", arguments: [
    (400, #"{"message":"유효하지 않음"}"#, QRCodeError.validationFailed("유효하지 않음")),
    (500, #"{"message":"server"}"#, .validationFailed("서버 오류 (코드: 500)")),
    (600, #"{"message":"other"}"#, .validationFailed("other")),
    (400, "not-json", .invalidPayload)
  ])
  func qrResponseErrors(status: Int, json: String, expected: QRCodeError) async {
    let repository = makeRepository(client: StubNetworkClient(statusCode: status, json: json)) { QRCodeRepositoryImpl() }
    await #expect(throws: expected) { try await repository.qrValidateCheck(from: "code") }
  }

  @Test("QR 네트워크 실패를 기능 오류로 변환")
  func qrNetworkFailures() async {
    let create = makeRepository(client: failingClient()) { QRCodeRepositoryImpl() }
    await #expect(throws: QRCodeError.createFailed) { try await create.createQRCode(userID: 1) }

    let validate = makeRepository(client: failingClient()) { QRCodeRepositoryImpl() }
    await #expect(throws: QRCodeError.validationFailed("QR 코드 검증 요청에 실패했습니다")) {
      try await validate.qrValidateCheck(from: "code")
    }
  }

  private func failingClient() -> StubNetworkClient {
    StubNetworkClient(error: .response(.init(httpStatus: 503)))
  }
}
