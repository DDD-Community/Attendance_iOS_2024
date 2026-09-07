//
//  EntityContractTests.swift
//  EntityTests
//
//  Created by DDD on 2026-09-02
//

import Foundation
import Testing

import AuthDomainInterface
import VoteDomainInterface


@Suite("Entity Contracts")
struct EntityContractTests {
  @Test("VoteStatus는 서버 상태 문자열을 UI 상태로 매핑한다")
  func voteStatusMapsServerStatus() {
    #expect(VoteStatus(serverStatus: "OPEN") == .inProgress)
    #expect(VoteStatus(serverStatus: "CLOSED") == .after)
    #expect(VoteStatus(serverStatus: "DRAFT") == .before)
  }

  @Test("AuthError.from은 이미 typed AuthError면 원본을 유지한다")
  func authErrorFromKeepsTypedError() {
    #expect(AuthError.from(AuthError.refreshTokenExpired) == .refreshTokenExpired)
  }
}
