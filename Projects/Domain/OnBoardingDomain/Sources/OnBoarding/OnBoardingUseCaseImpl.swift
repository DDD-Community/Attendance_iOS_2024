//
//  OnBoardingUseCaseImpl.swift
//  OnBoardingDomain
//
//  Created by DDD on 12/30/25.
//

import OnBoardingDomainInterface

import Dependencies


public struct OnBoardingUseCaseImpl: OnBoardingUseCaseInterface {
  @Dependency(\.onBoardingRepository) var repository

  public init() {}


  public func verifyCode(
    code: String
  ) async throws(OnBoardingError) -> VerifyCodeEntity {
    return try await repository.verifyCode(code: code)
  }

  public func fetchJobs() async throws(OnBoardingError) -> [SelectJob] {
    return try await repository.fetchJobs()
  }

  public func fetchTeams(
    generationId: Int
  ) async throws(OnBoardingError) -> [SelectTeamEntity] {
    return try await repository.fetchTeams(generationId: generationId)
  }

  public func fetchManaging() async throws(OnBoardingError) -> [SelectManaging] {
    return try await repository.fetchManaging()
  }
}
