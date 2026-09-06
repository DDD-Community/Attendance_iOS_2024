//
//  ProfileDelegate.swift
//  ProfileInterface
//
//  Created by DDD on 2026-09-02
//
//  Profile 이 바깥에 알리는 위임 계약.
//

import Foundation

import ComposableArchitecture

@CasePathable
public enum ProfileDelegate: Equatable, Sendable {
  case presentBack
  case presentLogOut
  case presentCreateByApp
  case presentPrivacyPolicy
  case presentEditGeneration
  case presentAppPeedBackWeb
}

@CasePathable
public enum CreateAppDelegate: Equatable, Sendable {
  case presentBack
  case presentWeb
}
