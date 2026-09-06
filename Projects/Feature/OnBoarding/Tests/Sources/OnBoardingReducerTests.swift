//
//  OnBoardingReducerTests.swift
//  OnBoardingTests
//
//  Created by DDD on 2026-09-02
//  Copyright © 2026 DDD , Ltd. All rights reserved.
//

import ComposableArchitecture
import Testing
import OnBoardingDomainInterface

@testable import OnBoarding

@MainActor
@Suite("OnBoarding")
struct OnBoardingReducerTests {
  @Test("초대 코드 초기화는 네 칸과 포커스를 처음 상태로 되돌린다")
  func initInviteCodeClearsDigitsAndFocusesFirstField() async {
    var state = InviteCodeFeature.State()
    state.firstInviteCode = "1"
    state.secondInviteCode = "2"
    state.thirdInviteCode = "3"
    state.lastInviteCode = "4"
    state.focusedField = .last

    let store = TestStore(initialState: state) {
      InviteCodeFeature()
    }

    await store.send(.view(.initInviteCode)) {
      $0.firstInviteCode = ""
      $0.secondInviteCode = ""
      $0.thirdInviteCode = ""
      $0.lastInviteCode = ""
      $0.focusedField = .first
    }
  }

  @Test("초대 코드 검증 성공은 세션에 기수와 역할을 저장하고 이름 입력으로 이동한다")
  func inviteCodeSuccessStoresSessionAndNavigatesToName() async {
    var state = InviteCodeFeature.State()
    state.firstInviteCode = "A"
    state.secondInviteCode = "B"
    state.thirdInviteCode = "C"
    state.lastInviteCode = "D"
    let verification = VerifyCodeEntity(generationID: 13, type: .manager)

    let store = TestStore(initialState: state) {
      InviteCodeFeature()
    }

    await store.send(.inner(.verifyInviteCodeResponse(.success(verification)))) {
      $0.isNotAvailableCode = false
      $0.userSession.userRole = .manager
      $0.userSession.generationId = 13
      $0.userSession.inviteCode = "ABCD"
      $0.userSession.managing = []
      $0.userSession.selectTeam = .unknown
      $0.userSession.selectTeamId = nil
    }
    await store.receive(\.delegate.presentSignUpName)
  }

  @Test("이름이 여섯 글자 이상이면 다음 단계로 이동하지 않고 사용 불가 상태가 된다")
  func longNameMarksNameUnavailable() async {
    var state = OnBoardingNameFeature.State()
    state.userSession.name = "홍길동테스트"

    let store = TestStore(initialState: state) {
      OnBoardingNameFeature()
    }

    await store.send(.view(.checkIsAvailableName)) {
      $0.isNotAvailableName = true
    }
  }
}
