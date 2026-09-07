//
//  AuthDelegate.swift
//  AuthInterface
//
//  Created by DDD on 2026-09-02
//
//  Auth 가 바깥에 알리는 위임 계약.
//  구현(Reducer·State·View)이 아니라 계약만 둔다.
//

import Foundation

import ComposableArchitecture

@CasePathable
public enum LoginDelegate: Equatable, Sendable {
  case presentSignUpInviteView
  case presentStaffMain
  case presentMemberMain
  case presentWeb
}
