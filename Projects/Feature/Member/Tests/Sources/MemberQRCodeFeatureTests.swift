//
//  MemberQRCodeFeatureTests.swift
//  MemberTests
//
//  Created by DDD on 9/4/26.
//

import Testing

@testable import Member

import ComposableArchitecture

@MainActor
@Suite("MemberQRCodeFeature")
struct MemberQRCodeFeatureTests {
  @Test("QR 문자열 생성 실패는 loading을 종료한다")
  func createFailureStopsLoading() async {
    let store = TestStore(initialState: MemberQRCodeFeature.State()) {
      MemberQRCodeFeature()
    }

    await store.send(.inner(.onCreateQRCodeResponse(.failure(.invalidPayload)))) {
      $0.viewState = .failed
    }
  }

  @Test("QR 이미지가 생성되지 않으면 실패 상태를 표시한다")
  func nilImageShowsFailureState() async {
    let store = TestStore(initialState: MemberQRCodeFeature.State()) {
      MemberQRCodeFeature()
    }

    await store.send(.inner(.onGenerateQRCodeImage(.success(nil)))) {
      $0.viewState = .failed
    }
  }

  @Test("QR 생성 중에는 skeleton을 렌더링한다")
  func rendersLoadingSkeleton() {
    var state = MemberQRCodeFeature.State()
    state.didAppear = true
    state.viewState = .loading

    MemberViewRenderer.render(
      MemberQRCodeView(
        store: Store(initialState: state) {
          MemberQRCodeFeature()
        }
      )
    )
    MemberViewRenderer.render(MemberQRCodeSkeletonView())
  }
}
