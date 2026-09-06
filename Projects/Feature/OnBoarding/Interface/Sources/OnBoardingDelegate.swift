//
//  OnBoardingDelegate.swift
//  OnBoardingInterface
//
//  Created by DDD on 2026-09-02
//
//  OnBoarding 이 바깥에 알리는 위임 계약.
//  온보딩은 단계별 리듀서가 여러 개라 계약도 단계마다 둔다.
//

import Foundation

import ComposableArchitecture

@CasePathable
public enum SelectTeamDelegate: Equatable, Sendable {
  case presentBack
  case presentMember
  case presentManager
  case presentLogin
  case presentProfile
}

@CasePathable
public enum SelectManagingDelegate: Equatable, Sendable {
  case presentBack
  case presentManager
  case presentMember
  case presentLogin
  case presentSelectTeam
  case presentProfile
}

@CasePathable
public enum SelectPartDelegate: Equatable, Sendable {
  case presentBack
  case presentManaging
  case presentSelectTeam
  case presentNextStep
}

@CasePathable
public enum OnBoardingNameDelegate: Equatable, Sendable {
  case presentBack
  case presentSignUpPart
}

@CasePathable
public enum InviteCodeDelegate: Equatable, Sendable {
  case presentBack
  case presentSignUpName
}
