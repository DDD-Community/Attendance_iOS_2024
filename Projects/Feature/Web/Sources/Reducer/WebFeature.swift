//
//  WebFeature.swift
//  Profile
//
//  Created by DDD on 1/4/26.
//

import Foundation
import ComposableArchitecture
import WebInterface


@Reducer
public struct WebFeature {
  public init() {}

  @ObservableState
  public struct State: Equatable {
    let url: String

    public init(url: String) {
      self.url = url
    }
  }

  /// 이동 계약은 WebInterface 에 있다. 호출부(`.backToRoot`)를 그대로 두기 위해 별칭만 받는다.
  public typealias Action = WebDelegate

  public var body: some Reducer<State, Action> {
    Reduce { state, action in
      switch action {
        case .backToRoot:
          return .none
      }
    }
  }
}
