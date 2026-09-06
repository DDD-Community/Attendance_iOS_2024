//
//  OnBoardingRepositoryImpl.swift
//  OnBoardingDomain
//
//  Created by DDD on 12/30/25.
//

import Foundation

import APIEndpoint
import DDDNetworkInterface
import OnBoardingDomainInterface

import Dependencies

final public class OnBoardingRepositoryImpl: OnBoardingInterface {

  @Dependency(\.networkClient) private var client

  public init() {}

  // MARK: - 코드 검증
  public func verifyCode(
    code: String
  ) async throws(OnBoardingError) -> VerifyCodeEntity {
    do {
      let dto = try await client.send(
        OnBoardingService.verifyCode(code: code),
        as: VerifyCodeDTO.self
      )
      return dto.toDomain()
    } catch {
      throw .verifyFailed
    }
  }

  // MARK: - 직군 선택
  public func fetchJobs() async throws(OnBoardingError) -> [SelectJob] {
    do {
      let dtoArray = try await client.send(
        OnBoardingService.jobs,
        as: SelectJobsDTO.self
      )
      return dtoArray.data.toDomain()
    } catch {
      throw .networkError
    }
  }

  // MARK: - 팀 선택
  public func fetchTeams(
    generationId: Int
  ) async throws(OnBoardingError) -> [SelectTeamEntity] {
    do {
      let dto = try await client.send(
        OnBoardingService.teams(generationId: generationId),
        as: SelectTeamsDTO.self
      )
      return dto.data.toDomain()
    } catch {
      throw .networkError
    }
  }

  // MARK: - 매니저 역활 선택
  public func fetchManaging() async throws(OnBoardingError) -> [SelectManaging] {
    do {
      let dto = try await client.send(
        OnBoardingService.mangerRole,
        as: SelectMangerRoleDTO.self
      )
      return dto.data.toDomain()
    } catch {
      throw .networkError
    }
  }

}
