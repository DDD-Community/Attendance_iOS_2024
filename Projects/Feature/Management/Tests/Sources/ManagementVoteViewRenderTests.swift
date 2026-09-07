//
//  ManagementVoteViewRenderTests.swift
//  ManagementTests
//
//  Created by DDD on 2026-09-03.
//
//  VoteView / VoteSkeletonView / NonParticipantsModalView 의 body 를 실제로 평가한다.
//  상태별로 다른 @ViewBuilder 분기가 열리므로 State 변형마다 한 번씩 렌더링한다.
//

import SwiftUI
import Testing

import DDDDesignKit
@testable import Management
import VoteDomainInterface

import ComposableArchitecture

@MainActor
@Suite("ManagementVoteViewRender")
struct ManagementVoteViewRenderTests {
  private func makeStore(
    state: VoteFeature.State,
    stub: ManagementVoteUseCaseStub = ManagementVoteUseCaseStub()
  ) -> StoreOf<VoteFeature> {
    Store(initialState: state) {
      VoteFeature()
    } withDependencies: {
      $0.voteUseCase = stub
    }
  }

  /// 투표 전 상태: 시작 버튼 + "투표 시작 전이에요" 문구 경로.
  @Test("투표 전 상태의 VoteView 를 렌더링한다")
  func rendersBeforeState() {
    let store = makeStore(state: VoteFeature.State())

    ManagementViewRenderer.render(VoteView(store: store))

    #expect(store.voteStatus == .before)
  }

  /// 진행 중 + 집계 있음: 미참여 확인 버튼과 종료 버튼, 참여율 문구 경로.
  @Test("진행 중이고 참여 현황이 있는 VoteView 를 렌더링한다")
  func rendersInProgressWithParticipation() {
    var state = VoteFeature.State()
    state.voteStatus = .inProgress
    state.participation = VoteParticipation(
      voteId: 1,
      status: .inProgress,
      totalMembers: 20,
      respondedMembers: 8,
      participationRate: 40
    )

    let store = makeStore(state: state)

    ManagementViewRenderer.render(VoteView(store: store))

    #expect(store.participation?.respondedMembers == 8)
  }

  /// 진행 중인데 집계가 아직 없는 경계: "집계 중이에요" 문구 경로.
  @Test("진행 중이지만 참여 현황이 없는 VoteView 를 렌더링한다")
  func rendersInProgressWithoutParticipation() {
    var state = VoteFeature.State()
    state.voteStatus = .inProgress

    let store = makeStore(state: state)

    ManagementViewRenderer.render(VoteView(store: store))

    #expect(store.participation == nil)
  }

  /// 종료 + 집계 있음: 종료 안내 뷰와 최종 참여 문구 경로.
  @Test("종료되고 참여 현황이 있는 VoteView 를 렌더링한다")
  func rendersAfterWithParticipation() {
    var state = VoteFeature.State()
    state.voteStatus = .after
    state.participation = VoteParticipation(
      voteId: 1,
      status: .after,
      totalMembers: 20,
      respondedMembers: 19,
      participationRate: 95
    )

    let store = makeStore(state: state)

    ManagementViewRenderer.render(VoteView(store: store))

    #expect(store.voteStatus == .after)
  }

  /// 종료인데 집계가 비어 있는 경계: "집계 완료" 문구 경로.
  @Test("종료되었지만 참여 현황이 없는 VoteView 를 렌더링한다")
  func rendersAfterWithoutParticipation() {
    var state = VoteFeature.State()
    state.voteStatus = .after

    let store = makeStore(state: state)

    ManagementViewRenderer.render(VoteView(store: store))

    #expect(store.participation == nil)
  }

  /// 로딩 스켈레톤 뷰 단독 렌더링.
  @Test("VoteSkeletonView 를 렌더링한다")
  func rendersVoteSkeleton() {
    ManagementViewRenderer.render(VoteSkeletonView())
  }

  /// 미참여자 모달의 로딩 스켈레톤 경로.
  @Test("로딩 중 미참여자 모달을 렌더링한다")
  func rendersNonParticipantsModalLoading() {
    ManagementViewRenderer.render(
      NonParticipantsModalView(isLoading: true, members: [], onClose: {})
    )
  }

  /// 출석/지각/결석/미표시가 모두 섞인 목록으로 칩 색상 분기를 태운다.
  @Test("명단이 있는 미참여자 모달을 렌더링한다")
  func rendersNonParticipantsModalWithMembers() {
    ManagementViewRenderer.render(
      NonParticipantsModalView(
        isLoading: false,
        members: ManagementVoteFixture.nonParticipants,
        onClose: {}
      )
    )
  }

  /// 명단이 비어 있는 경계값.
  @Test("빈 명단의 미참여자 모달을 렌더링한다")
  func rendersNonParticipantsModalEmpty() {
    ManagementViewRenderer.render(
      NonParticipantsModalView(isLoading: false, members: [], onClose: {})
    )
  }

  /// overlay 모디파이어의 표시/비표시 두 분기.
  @Test("nonParticipantsModal 모디파이어의 표시와 비표시 경로를 렌더링한다")
  func rendersNonParticipantsModalModifier() {
    ManagementViewRenderer.render(
      Color.clear.nonParticipantsModal(
        isPresented: true,
        isLoading: false,
        members: ManagementVoteFixture.nonParticipants,
        onClose: {}
      )
    )

    ManagementViewRenderer.render(
      Color.clear.nonParticipantsModal(
        isPresented: false,
        isLoading: false,
        members: [],
        onClose: {}
      )
    )
  }
}
