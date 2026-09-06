//
//  ProfileViewRenderingTests.swift
//  ProfileTests
//
//  Created by DDD on 2026-09-03
//  Copyright © 2026 DDD , Ltd. All rights reserved.
//
//  ProfileView / ProfileSkeletonView / CreateAppView 의 body 를 State 변형별로 실제 렌더링한다.
//  onAppear 의 fetchUser 가 네트워크를 타지 않도록 스텁 의존성을 심은 스토어만 사용한다.
//  userSession 은 전역 공유 상태라 직렬 실행하고 매번 원복한다.
//

import ComposableArchitecture
import SwiftUI
import Testing

@testable import Profile

@MainActor
@Suite("Profile 화면 렌더링", .serialized)
struct ProfileViewRenderingTests {
  // MARK: - ProfileView

  @Test("표시할 프로필이 없고 로딩 중이면 스켈레톤 화면을 그린다")
  func loadingWithoutProfileRendersSkeleton() {
    let store = ProfileViewRenderer.makeStore(state: emptySessionState(isLoading: true))
    defer { restoreSession(store) }

    ProfileViewRenderer.render(ProfileView(store: store))
  }

  @Test("표시할 프로필도 없고 로딩도 아니면 빈 프로필 카드를 그린다")
  func idleWithoutProfileRendersEmptyCard() {
    let store = ProfileViewRenderer.makeStore(state: emptySessionState(isLoading: false))
    defer { restoreSession(store) }

    ProfileViewRenderer.render(ProfileView(store: store))
  }

  @Test("멤버 프로필은 멤버 전용 카드로 그려진다")
  func memberProfileRendersMemberCard() {
    let store = ProfileViewRenderer.makeStore(profile: ProfileTestSupport.memberProfile)

    ProfileViewRenderer.render(ProfileView(store: store))
  }

  @Test("담당 업무가 있는 운영진 프로필은 담당 업무 영역까지 그려진다")
  func managerProfileWithRolesRendersManagingSection() {
    let store = ProfileViewRenderer.makeStore(profile: ProfileTestSupport.managerProfile)

    ProfileViewRenderer.render(ProfileView(store: store))
  }

  @Test("담당 업무가 비어 있는 운영진 프로필은 담당 업무 영역 없이 그려진다")
  func managerProfileWithoutRolesSkipsManagingSection() {
    let store = ProfileViewRenderer.makeStore(profile: ProfileTestSupport.managerProfileWithoutRoles)

    ProfileViewRenderer.render(ProfileView(store: store))
  }

  @Test("팀이 없는 프로필도 카드가 깨지지 않고 그려진다")
  func profileWithoutTeamRendersCard() {
    let store = ProfileViewRenderer.makeStore(profile: ProfileTestSupport.memberProfileWithoutTeam)

    ProfileViewRenderer.render(ProfileView(store: store))
  }

  @Test("로딩 중이어도 이미 프로필이 있으면 스켈레톤 대신 카드를 그린다")
  func loadingWithProfileStillRendersCard() {
    let store = ProfileViewRenderer.makeStore(
      profile: ProfileTestSupport.managerProfile,
      isLoading: true
    )

    ProfileViewRenderer.render(ProfileView(store: store))
  }

  // MARK: - 알럿 / 모달

  @Test("실패 알럿이 있으면 알럿을 붙인 채로 그려진다")
  func presentedAlertRenders() {
    var state = ProfileFeature.State()
    state.profile = ProfileTestSupport.memberProfile
    state.alert = AlertState {
      TextState("탈퇴실패")
    } actions: {
      ButtonState(action: .confirmTapped) {
        TextState("확인")
      }
    } message: {
      TextState("회원 탈퇴 실패")
    }

    let store = ProfileViewRenderer.makeStore(state: state)

    ProfileViewRenderer.render(ProfileView(store: store))
  }

  @Test("탈퇴 확인 팝업이 있으면 커스텀 알럿을 붙인 채로 그려진다")
  func presentedCustomAlertRenders() {
    var state = ProfileFeature.State()
    state.profile = ProfileTestSupport.memberProfile
    state.customAlert = .withdrawAccount()

    let store = ProfileViewRenderer.makeStore(state: state)

    ProfileViewRenderer.render(ProfileView(store: store))
  }

  @Test("로그아웃 확인 팝업이 있으면 커스텀 알럿을 붙인 채로 그려진다")
  func presentedLogoutAlertRenders() {
    var state = ProfileFeature.State()
    state.profile = ProfileTestSupport.managerProfile
    state.customAlert = .logout()

    let store = ProfileViewRenderer.makeStore(state: state)

    ProfileViewRenderer.render(ProfileView(store: store))
  }

  @Test("앱 피드백 모달이 열려 있으면 블러 배경과 시트를 함께 그린다")
  func presentedCreateAppDestinationRendersBlurAndSheet() {
    var state = ProfileFeature.State()
    state.profile = ProfileTestSupport.memberProfile
    state.destination = .createApp(.init())

    let store = ProfileViewRenderer.makeStore(state: state)

    ProfileViewRenderer.render(ProfileView(store: store))
  }

  // MARK: - 단독 컴포넌트

  @Test("스켈레톤 뷰는 단독으로도 그려진다")
  func skeletonViewRendersStandalone() {
    ProfileViewRenderer.render(ProfileSkeletonView())
  }

  @Test("앱 피드백 작성 뷰는 단독으로도 그려진다")
  func createAppViewRendersStandalone() {
    let store = Store(initialState: CreateAppFeature.State()) {
      CreateAppFeature()
    }

    ProfileViewRenderer.render(CreateAppView(store: store))
  }

  // MARK: - Helper

  /// 세션이 비어 있어 displayedProfile 이 nil 이 되는 State 를 만든다.
  private func emptySessionState(isLoading: Bool) -> ProfileFeature.State {
    var state = ProfileFeature.State()
    state.viewState = isLoading ? .loading : .loaded
    state.profile = nil
    state.$userSession.withLock { $0 = .empty }
    return state
  }

  /// 전역 공유 세션을 초기값으로 되돌린다.
  private func restoreSession(_ store: StoreOf<ProfileFeature>) {
    store.state.$userSession.withLock { $0 = .empty }
  }
}
