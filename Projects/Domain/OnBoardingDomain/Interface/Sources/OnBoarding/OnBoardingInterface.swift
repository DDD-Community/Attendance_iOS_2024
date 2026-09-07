//
//  OnBoardingInterface.swift
//  DomainInterface
//
//  Created by DDD on 12/30/25.
//

import Foundation

import AuthDomainInterface
import ProfileDomainInterface

import Dependencies



public protocol OnBoardingInterface: Sendable {
  func verifyCode(code: String) async throws(OnBoardingError) -> VerifyCodeEntity
  func fetchJobs() async throws(OnBoardingError) -> [SelectJob]
  func fetchTeams(generationId: Int) async throws(OnBoardingError) -> [SelectTeamEntity]
  func fetchManaging() async throws(OnBoardingError) -> [SelectManaging]
}

public enum OnBoardingRepositoryDependency: TestDependencyKey {

  public static var testValue: OnBoardingInterface {
    MockOnBoardingRepository()
  }

  public static var previewValue: OnBoardingInterface = testValue
}

public extension DependencyValues {
  var onBoardingRepository: OnBoardingInterface {
    get { self[OnBoardingRepositoryDependency.self] }
    set { self[OnBoardingRepositoryDependency.self] = newValue }
  }
}
