//
//  InviteCodeReducerTests.swift
//  OnBoardingTests
//
//  InviteCodeFeature 의 포커스 이동, 코드 검증 성공/실패, 알럿 분기를 검증한다.
//

import ComposableArchitecture
import OnBoardingDomainInterface
import ProfileDomainInterface
import Testing

@testable import OnBoarding

@MainActor
@Suite("InviteCodeFeature")
struct InviteCodeReducerTests {
  // MARK: - 계산 프로퍼티

  @Test("네 칸을 이어 붙인 값이 전체 초대 코드가 된다")
  func totalInviteCodeConcatenatesFields() {
    var state = InviteCodeFeature.State()
    state.firstInviteCode = "1"
    state.secondInviteCode = "2"
    state.thirdInviteCode = "3"
    state.lastInviteCode = "4"

    #expect(state.totalInviteCode == "1234")
    #expect(state.enableButton == true)
  }

  @Test("한 칸이라도 비어 있으면 다음 버튼이 비활성화된다")
  func enableButtonRequiresEveryField() {
    var state = InviteCodeFeature.State()
    state.firstInviteCode = "1"
    state.secondInviteCode = "2"
    state.thirdInviteCode = "3"

    #expect(state.enableButton == false)
  }

  @Test("코드가 유효하지 않다고 표시되면 네 칸이 모두 차 있어도 버튼이 비활성화된다")
  func enableButtonIsFalseWhenCodeMarkedInvalid() {
    var state = InviteCodeFeature.State()
    state.firstInviteCode = "1"
    state.secondInviteCode = "2"
    state.thirdInviteCode = "3"
    state.lastInviteCode = "4"
    state.isNotAvailableCode = true

    #expect(state.enableButton == false)
  }

  // MARK: - ViewAction

  @Test("focusChanged 는 포커스 위치를 상태에 반영한다")
  func focusChangedUpdatesFocusedField() async {
    let store = TestStore(initialState: InviteCodeFeature.State()) {
      InviteCodeFeature()
    }

    await store.send(.view(.focusChanged(.third))) {
      $0.focusedField = .third
    }

    await store.send(.view(.focusChanged(nil))) {
      $0.focusedField = nil
    }
  }

  // MARK: - AsyncAction

  @Test("초대 코드 검증에 성공하면 세션을 갱신하고 이름 입력으로 이동한다")
  func verifyInviteCodeSuccessUpdatesSession() async {
    var state = InviteCodeFeature.State()
    state.firstInviteCode = "A"
    state.secondInviteCode = "B"
    state.thirdInviteCode = "C"
    state.lastInviteCode = "D"
    state.isNotAvailableCode = true
    state.userSession.managing = [.photo]
    state.userSession.selectTeam = .ios1
    state.userSession.selectTeamId = 1

    let verification = OnBoardingCoverageFixture.memberCode

    let store = TestStore(initialState: state) {
      InviteCodeFeature()
    } withDependencies: {
      $0.onBoardingUseCase = StubOnBoardingRepository(verifiedCode: verification)
    }

    await store.send(.async(.verifyInviteCode(code: "ABCD")))
    await store.receive(\.inner.verifyInviteCodeResponse) {
      $0.isNotAvailableCode = false
      $0.userSession.userRole = .member
      $0.userSession.generationId = 14
      $0.userSession.inviteCode = "ABCD"
      $0.userSession.managing = []
      $0.userSession.selectTeam = .unknown
      $0.userSession.selectTeamId = nil
    }
    await store.receive(\.delegate.presentSignUpName)
  }

  @Test("초대 코드 검증에 실패하면 오류 알럿을 띄우고 코드 입력을 무효로 표시한다")
  func verifyInviteCodeFailurePresentsAlert() async {
    let store = TestStore(initialState: InviteCodeFeature.State()) {
      InviteCodeFeature()
    } withDependencies: {
      $0.onBoardingUseCase = StubOnBoardingRepository(failure: .invalidCode)
    }

    await store.send(.async(.verifyInviteCode(code: "0000")))
    await store.receive(\.inner.verifyInviteCodeResponse) {
      $0.isNotAvailableCode = true
      $0.alert = AlertState {
        TextState("오류")
      } actions: {
        ButtonState(action: .confirmTapped) {
          TextState("확인")
        }
      } message: {
        TextState("잘못된 초대 코드입니다. 다시 입력해 주세요.\n\(SignUpError.invalidInviteCode.errorDescription ?? "")")
      }
    }
  }

  // MARK: - Delegate / Scope / Binding

  @Test("delegate 액션은 부수효과 없이 소비된다")
  func delegateActionProducesNoEffect() async {
    let store = TestStore(initialState: InviteCodeFeature.State()) {
      InviteCodeFeature()
    }

    await store.send(.delegate(.presentSignUpName))
  }

  @Test("알럿을 닫으면 alert 상태가 비워진다")
  func dismissingAlertClearsState() async {
    var state = InviteCodeFeature.State()
    state.alert = AlertState {
      TextState("오류")
    } actions: {
      ButtonState(action: .confirmTapped) {
        TextState("확인")
      }
    }

    let store = TestStore(initialState: state) {
      InviteCodeFeature()
    }

    await store.send(.scope(.alert(.dismiss))) {
      $0.alert = nil
    }
  }

  @Test("binding 액션은 입력 칸 상태만 갱신한다")
  func bindingUpdatesStateOnly() async {
    let store = TestStore(initialState: InviteCodeFeature.State()) {
      InviteCodeFeature()
    }

    await store.send(.binding(.set(\.firstInviteCode, "7"))) {
      $0.firstInviteCode = "7"
    }
  }
}
