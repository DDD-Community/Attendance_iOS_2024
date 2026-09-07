//
//  AuthRepositoryImpl.swift
//  AuthDomain
//
//  Created by DDD on 7/23/25.
//

import Foundation

import APIEndpoint
import AuthDomainInterface
import DDDAuthInterface
import DDDCoreLogger
import DDDNetworkInterface
import DDDStorageInterface

import Dependencies

public final class AuthRepositoryImpl: AuthInterface, @unchecked Sendable {
  @Dependency(\.sessionCacheInvalidator) private var sessionCacheInvalidator

  @Dependency(\.networkClient) private var client
  @Dependency(\.authService) private var authService

  public init() {}

  // MARK: - 로그인 API
  public func login(
    provider socialProvider: SocialType,
    token: String
  ) async throws(AuthError) -> LoginEntity {
    do {
      let dto = try await client.send(
        AuthRequest.login(
          body: OAuthLoginRequest(provider: socialProvider.description, token: token)
        ),
        as: LoginResponseDTO.self
      )
      let entity = dto.toDomain()
      await authService.signIn(
        accessToken: entity.token.accessToken,
        refreshToken: entity.token.refreshToken
      )
      return entity
    } catch {
      throw .loginFailed
    }
  }

  // MARK: - 토큰 재발급
  public func refresh() async throws(AuthError) -> AuthTokens {
    let refreshToken = await authService.refreshToken ?? ""

    do {
      let dto = try await client.send(
        AuthRequest.refresh(refreshToken: refreshToken),
        as: TokenDTO.self
      )
      let refreshData = dto.toDomain()
      return refreshData
    } catch {
      DDDLogger.debug("🔍 [AuthRepositoryImpl] Refresh failed: \(error)", category: .auth)

      if case let DDDNetworkError.response(responseError) = error,
         responseError.isUnauthorized {
        throw .refreshTokenExpired
      }

      throw .tokenRefreshFailed
    }
  }

  // MARK: - 로그아웃
  public func logout() async throws(AuthError) -> AuthExitEntity {
    do {
      let response = try await client.sendResponse(AuthRequest.logout)
      let decoder = JSONDecoder()

      if (200 ... 299).contains(response.statusCode) {
        await authService.signOut()
        await sessionCacheInvalidator.invalidate()
        if response.data.isEmpty {
          return AuthExitEntity()
        }
        if let successDTO = try? decoder.decode(LogOutDTO.self, from: response.data) {
          return successDTO.toDomain()
        }
        return AuthExitEntity()
      }

      if let errorDTO = try? decoder.decode(LogOutDTO.self, from: response.data) {
        return errorDTO.toDomain()
      }

      let errorMessage = String(data: response.data, encoding: .utf8)
      return AuthExitEntity(message: errorMessage)
    } catch {
      throw .logoutFailed
    }
  }

  // MARK: - 계정 삭제
  public func withDraw(token: String) async throws(AuthError) -> WithdrawEntity {
    do {
      let response = try await client.sendResponse(AuthRequest.withdraw(token: token))
      let decoder = JSONDecoder()

      if (200 ... 299).contains(response.statusCode) {
        await authService.signOut()
        await sessionCacheInvalidator.invalidate()
        if response.data.isEmpty {
          return WithdrawEntity(isSuccess: true)
        }
        if let successDTO = try? decoder.decode(WithdrawDTO.self, from: response.data) {
          return successDTO.toDomain(isSuccess: true)
        }
        return WithdrawEntity(isSuccess: true)
      }

      if let errorDTO = try? decoder.decode(WithdrawDTO.self, from: response.data) {
        return errorDTO.toDomain(isSuccess: false)
      }
      return WithdrawEntity(
        isSuccess: false,
        message: String(data: response.data, encoding: .utf8)
      )
    } catch {
      throw .accountDeletionFailed
    }
  }

  // MARK: - 세션 Credential 업데이트

  public func updateSessionCredential(with tokens: AuthTokens) async {
    await authService.signIn(
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken
    )
  }
}
