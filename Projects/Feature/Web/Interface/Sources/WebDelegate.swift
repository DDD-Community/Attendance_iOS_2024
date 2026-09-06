//
//  WebDelegate.swift
//  WebInterface
//
//  Created by DDD on 2026-09-02
//
//  Web 이 바깥에 알리는 위임 계약.
//  Web 은 화면을 띄우고 닫는 것 외에 외부와 주고받을 것이 없어 계약도 한 가지다.
//

import Foundation

import ComposableArchitecture

@CasePathable
public enum WebDelegate: Equatable, Sendable {
  case backToRoot
}
