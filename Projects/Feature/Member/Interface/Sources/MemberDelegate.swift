//
//  MemberDelegate.swift
//  MemberInterface
//
//  Created by DDD on 2026-09-02
//
//  Member 가 바깥에 알리는 위임 계약.
//

import ComposableArchitecture
import Foundation

@CasePathable
public enum MemberMainDelegate: Equatable, Sendable {
  case routeToQRCode
  case routeToProfile
}

@CasePathable
public enum MemberQRCodeDelegate: Equatable, Sendable {
  case presentBack
}

@CasePathable
public enum MemberVoteDelegate: Equatable, Sendable {
  case exitVote
}
