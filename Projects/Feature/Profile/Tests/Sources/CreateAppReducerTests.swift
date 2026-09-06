//
//  CreateAppReducerTests.swift
//  ProfileTests
//
//  Created by DDD on 2026-09-03
//  Copyright © 2026 DDD , Ltd. All rights reserved.
//
//  앱 피드백 모달 리듀서. View/Async/Inner 액션은 케이스가 없어
//  실제로 도달 가능한 분기는 delegate 와 body 조립뿐이다.
//

import ComposableArchitecture
import ProfileInterface
import Testing

@testable import Profile

@MainActor
@Suite("CreateAppFeature 리듀서")
struct CreateAppReducerTests {
  @Test("presentWeb 위임 액션은 상태를 바꾸지 않고 상위로 전달된다")
  func presentWebDelegateKeepsStateUnchanged() async {
    let store = TestStore(initialState: CreateAppFeature.State()) {
      CreateAppFeature()
    }

    await store.send(.delegate(.presentWeb))
  }

  @Test("State 는 저장 값이 없으므로 항상 동등하다")
  func stateIsAlwaysEqual() {
    #expect(CreateAppFeature.State() == CreateAppFeature.State())
  }

  @Test("ProfileFeature.Destination 은 createApp 상태를 감싼다")
  func destinationWrapsCreateAppState() {
    let destination = ProfileFeature.Destination.State.createApp(CreateAppFeature.State())

    #expect(destination == .createApp(CreateAppFeature.State()))
  }
}
