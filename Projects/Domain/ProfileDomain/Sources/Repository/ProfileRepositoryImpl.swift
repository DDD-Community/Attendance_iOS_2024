//
//  ProfileRepositoryImpl.swift
//  ProfileDomain
//
//  Created by DDD on 7/23/25.
//

import Combine
import Foundation

import APIEndpoint
import DDDNetworkInterface
import ProfileDomainInterface

import ComposableArchitecture
import Dependencies

public final class ProfileRepositoryImpl: ProfileInterface, @unchecked Sendable {
  @Shared(.staffRole) var staffRole
  @Dependency(\.profileLocalDataSource) private var localDataSource

  @Dependency(\.networkClient) private var client

  public init() {}

  // MARK: - 프로필 조회

  // MARK: - 캐시 즉시 조회 (당일 만료, 네트워크 호출 없음)
  public func getCachedProfile() async -> ProfileEntity? {
    try? await localDataSource.loadUser()
  }

  // MARK: - 강제 refresh (캐시 무시, 항상 네트워크 + 캐시 저장)

  public func refreshProfile() async throws(ProfileError) -> ProfileEntity {
    try await fetchAndCacheProfile()
  }

  public func getProfile() async throws(ProfileError) -> ProfileEntity {
    // SWR: 캐시 hit이면 즉시 반환 + 백그라운드에서 fresh 갱신
    if let cached = try? await localDataSource.loadUser() {
      _Concurrency.Task.detached { [weak self] in
        _ = try? await self?.fetchAndCacheProfile()
      }
      return cached
    }

    // 캐시 miss → 네트워크 호출 후 캐시 저장
    return try await fetchAndCacheProfile()
  }

  private func fetchAndCacheProfile() async throws(ProfileError) -> ProfileEntity {
    // 1. 저장된 역할 정보 확인
    // staffRole이 명확하게 있으면 해당 엔드포인트 호출
    if let role = staffRole {
      switch role {
      case .manager:
        do {
          let dto = try await client.send(ProfileService.getAdminProfile, as: ProfileDTO.self)
          let profile = dto.toDomain()
          try? await localDataSource.saveUser(profile)
          return profile
        } catch {
          throw Self.mapLoadError(error)
        }
      case .member:
        do {
          let dto = try await client.send(ProfileService.getUserProfile, as: ProfileDTO.self)
          let profile = dto.toDomain()
          try? await localDataSource.saveUser(profile)
          return profile
        } catch {
          throw Self.mapLoadError(error)
        }
      }
    }

    // 2. 역할 정보가 없으면, 유저 프로필을 먼저 시도 (가장 일반적인 케이스)
    // 실패 시 어드민 프로필 시도.
    do {
      let dto = try await client.send(ProfileService.getUserProfile, as: ProfileDTO.self)
      let profile = dto.toDomain()
      try? await localDataSource.saveUser(profile)
      return profile
    } catch {
      do {
        let dto = try await client.send(ProfileService.getAdminProfile, as: ProfileDTO.self)
        let profile = dto.toDomain()
        try? await localDataSource.saveUser(profile)
        return profile
      } catch {
        throw Self.mapLoadError(error)
      }
    }
  }

  // MARK: - 프로필 수정

  public func editProfile(
    input: EditProfileInput
  ) async throws(EditProfileError) -> ProfileEntity {
    do {
      let body = input.toRequestDTO()
      let dto = try await client.send(ProfileService.editProfile(body: body), as: ProfileDTO.self)
      let profile = dto.toDomain()
      try? await localDataSource.saveUser(profile)
      return profile
    } catch {
      throw Self.mapEditError(error)
    }
  }

  private static func mapLoadError(_ error: DDDNetworkError) -> ProfileError {
    switch error {
    case let .response(responseError):
      switch responseError.httpStatus {
      case 401:
        return .invalidSession
      case 403:
        return .profileAccessDenied
      case 404:
        return .profileNotFound
      default:
        return .loadFailed
      }
    case .decoding:
      return .profileDataCorrupted
    default:
      return .loadFailed
    }
  }

  private static func mapEditError(_ error: DDDNetworkError) -> EditProfileError {
    guard case let .response(responseError) = error else {
      return .profileUpdateFailed
    }
    switch responseError.httpStatus {
    case 404:
      return .profileNotFound
    case 423:
      return .profileLocked
    default:
      return .profileUpdateFailed
    }
  }
}
