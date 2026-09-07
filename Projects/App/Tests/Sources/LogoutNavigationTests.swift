//
//  LogoutNavigationTests.swift
//  TestsTests
//
//  Created by DDD on 9/4/26.
//

import Testing

@testable import DDDAttendance

import ComposableArchitecture
import TCAFlow

@Suite("Logout navigation")
@MainActor
struct LogoutNavigationTests {
  @Test("Profile 로그아웃은 화면을 pop하지 않고 로그인 전환을 요청한다")
  func profileLogoutRequestsLoginWithoutPoppingRoutes() async {
    let store = TestStore(initialState: ProfileCoordinator.State()) {
      ProfileCoordinator()
    }

    await store.send(
      .router(
        .routeAction(
          id: 0,
          action: .profile(.delegate(.presentLogOut))
        )
      )
    )
    await store.receive {
      guard case .navigation(.presentLogin) = $0 else { return false }
      return true
    }
  }

  @Test("Member 로그아웃은 이전 화면으로 가지 않고 로그인 전환을 전달한다")
  func memberLogoutRequestsLoginWithoutPoppingRoutes() async {
    var initialState = MemberCoordinator.State()
    initialState.routes.append(.push(.profile(.init())))

    let store = TestStore(initialState: initialState) {
      MemberCoordinator()
    }

    await store.send(
      .router(
        .routeAction(
          id: 1,
          action: .profile(.navigation(.presentLogin))
        )
      )
    )
    await store.receive {
      guard case .navigation(.presentLogin) = $0 else { return false }
      return true
    }
  }

  @Test("Staff 로그아웃은 이전 화면으로 가지 않고 로그인 전환을 전달한다")
  func staffLogoutRequestsLoginWithoutPoppingRoutes() async {
    var initialState = StaffCoordinator.State()
    initialState.routes.append(.push(.profile(.init())))

    let store = TestStore(initialState: initialState) {
      StaffCoordinator()
    }

    await store.send(
      .router(
        .routeAction(
          id: 1,
          action: .profile(.navigation(.presentLogin))
        )
      )
    )
    await store.receive {
      guard case .navigation(.presentLogin) = $0 else { return false }
      return true
    }
  }
}
