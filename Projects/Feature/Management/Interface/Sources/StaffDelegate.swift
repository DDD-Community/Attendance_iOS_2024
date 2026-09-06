//
//  StaffDelegate.swift
//  ManagementInterface
//
//  Created by DDD on 2026-09-02
//
//  Management 가 바깥에 알리는 위임 계약.
//
//  Management 밖으로 전달하거나 상위 Feature가 소비하는 이동 계약을 여기에 둔다.
//

import ComposableArchitecture
import Foundation

@CasePathable
public enum StaffDelegate: Equatable, Sendable {
  case presentSchedule
  case presentManagerProfile
}

@CasePathable
public enum QRCodeDelegate: Equatable, Sendable {
  case presentBack
}
