//
//  MemberMainViewRenderTests.swift
//  MemberTests
//
//  Created by DDD on 9/4/26.
//

import ComposableArchitecture
import Testing

@testable import Member

@MainActor
@Suite("MemberMainView 렌더링")
struct MemberMainViewRenderTests {
  @Test("멤버 홈 로딩 상태는 skeleton을 렌더링한다")
  func rendersLoadingSkeleton() {
    var state = MemberMainFeature.State()
    state.didAppear = true
    state.viewState = .loading

    MemberViewRenderer.render(
      MemberMainView(
        store: Store(initialState: state) {
          MemberMainFeature()
        }
      )
    )
  }

  @Test("멤버 홈 skeleton을 단독으로 렌더링한다")
  func rendersSkeletonView() {
    MemberViewRenderer.render(MemberMainSkeletonView())
  }

  @Test("출석 갱신 상태는 출석 카드 skeleton만 렌더링한다")
  func rendersAttendanceCardSkeleton() {
    var state = MemberMainFeature.State()
    state.didAppear = true
    state.viewState = .loaded
    state.attendanceViewState = .loading

    MemberViewRenderer.render(
      MemberMainView(
        store: Store(initialState: state) {
          MemberMainFeature()
        }
      )
    )
  }

  @Test("멤버 투표 로딩 상태는 투표 화면 skeleton을 렌더링한다")
  func rendersVoteLoadingSkeleton() {
    var state = MemberMainFeature.State()
    state.didAppear = true
    state.viewState = .loaded
    state.selectedHomeTab = .vote
    state.vote.step = .loading

    MemberViewRenderer.render(
      MemberMainView(
        store: Store(initialState: state) {
          MemberMainFeature()
        }
      )
    )
    MemberViewRenderer.render(MemberVoteSkeletonView())
  }
}
