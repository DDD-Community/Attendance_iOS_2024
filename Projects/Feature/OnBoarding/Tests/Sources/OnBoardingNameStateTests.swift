//
//  OnBoardingNameStateTests.swift
//  OnBoardingTests
//
//  OnBoardingNameFeature 의 enableButton 계산 규칙과 나머지 액션 분기를 검증한다.
//  (5자 이하/6자 이상 이동 시나리오는 OnBoardingNameReducerTests 가 담당한다)
//

import Testing

@testable import OnBoarding

import ComposableArchitecture

@MainActor
@Suite("OnBoardingNameState")
struct OnBoardingNameStateTests {
  @Test("이름이 비어 있으면 다음 버튼이 비활성화된다")
  func emptyNameDisablesButton() {
    let state = OnBoardingNameFeature.State()

    #expect(state.enableButton == false)
  }

  @Test("이름이 있어도 사용 불가 표시면 다음 버튼이 비활성화된다")
  func unavailableNameDisablesButton() {
    var state = OnBoardingNameFeature.State()
    state.userSession.name = "철수"
    state.isNotAvailableName = true

    #expect(state.enableButton == false)
  }

  @Test("이름이 있고 사용 가능하면 다음 버튼이 활성화된다")
  func availableNameEnablesButton() {
    var state = OnBoardingNameFeature.State()
    state.userSession.name = "철수"

    #expect(state.enableButton == true)
  }

  @Test("이름이 비어 있으면 검증을 눌러도 다음 화면으로 이동하지 않는다")
  func emptyNameDoesNotNavigate() async {
    let store = TestStore(initialState: OnBoardingNameFeature.State()) {
      OnBoardingNameFeature()
    }

    await store.send(.view(.checkIsAvailableName))
  }

  @Test("경계값 5자 이름은 사용 가능하고 다음 화면으로 이동한다")
  func boundaryFiveCharacterNameNavigates() async {
    var state = OnBoardingNameFeature.State()
    state.userSession.name = "가나다라마"

    let store = TestStore(initialState: state) {
      OnBoardingNameFeature()
    }

    await store.send(.view(.checkIsAvailableName))
    await store.receive(\.delegate.presentSignUpPart)
  }

  @Test("initSignUpName 은 입력한 이름을 그대로 유지한다")
  func initSignUpNameKeepsEnteredName() async {
    var state = OnBoardingNameFeature.State()
    state.userSession.name = "철수"

    let store = TestStore(initialState: state) {
      OnBoardingNameFeature()
    }

    await store.send(.view(.initSignUpName))
    #expect(store.state.userSession.name == "철수")
  }

  @Test("delegate 액션은 부수효과 없이 소비된다")
  func delegateActionProducesNoEffect() async {
    let store = TestStore(initialState: OnBoardingNameFeature.State()) {
      OnBoardingNameFeature()
    }

    await store.send(.delegate(.presentSignUpPart))
  }

  @Test("binding 액션은 상태만 갱신한다")
  func bindingUpdatesStateOnly() async {
    let store = TestStore(initialState: OnBoardingNameFeature.State()) {
      OnBoardingNameFeature()
    }

    await store.send(.binding(.set(\.isNotAvailableName, true))) {
      $0.isNotAvailableName = true
    }
  }
}
