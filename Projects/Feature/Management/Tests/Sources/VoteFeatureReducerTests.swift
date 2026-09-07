//
//  VoteFeatureReducerTests.swift
//  ManagementTests
//
//  Created by DDD on 2026-09-02
//  Copyright © 2026 DDD , Ltd. All rights reserved.
//

import Testing

@testable import Management
import VoteDomainInterface

import ComposableArchitecture

@MainActor
@Suite("VoteFeature")
struct VoteFeatureReducerTests {
  @Test("onAppear는 로딩 상태로 전환하고 투표 목록 조회를 요청한다")
  func onAppearStartsLoadingAndFetchesVotes() async {
    let store = TestStore(initialState: VoteFeature.State()) {
      VoteFeature()
    }

    await store.send(.view(.onAppear)) {
      $0.hasFetchedVotes = true
    }
    await store.receive(\.async.fetchVotes)
    await store.receive(\.inner.votesResponse) {
      $0.viewState = .loaded
    }
  }

  @Test("빈 투표 목록은 투표 상태를 before로 유지한다")
  func emptyVotesKeepBeforeStatus() async {
    var state = VoteFeature.State()
    state.viewState = .loading
    state.voteId = 1
    state.voteStatus = .inProgress

    let store = TestStore(initialState: state) {
      VoteFeature()
    }

    await store.send(.inner(.votesResponse(.success([])))) {
      $0.viewState = .loaded
      $0.voteId = nil
      $0.voteStatus = .before
    }
  }

  @Test("미참여자 조회 성공은 로딩을 끄고 목록을 저장한다")
  func nonRespondersSuccessStoresMembers() async {
    var state = VoteFeature.State()
    state.isNonParticipantsLoading = true
    let members = [
      NonParticipant(id: 1, name: "김철수", teamName: "iOS 1팀")
    ]

    let store = TestStore(initialState: state) {
      VoteFeature()
    }

    await store.send(.inner(.nonRespondersResponse(.success(members)))) {
      $0.isNonParticipantsLoading = false
      $0.nonParticipants = members
    }
  }
}
