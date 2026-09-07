//
//  AuthEntityTest.swift
//  EntityTests
//
//  Created by DDD on 2026-01-30
//

import Testing

import AuthDomainInterface

@Suite("Auth Entity Tests")
struct AuthEntityTest {

    @Test("AuthTokens Mock 데이터 생성 테스트")
    func test_AuthTokens_mock_data_creation() throws {
        // Given
        let tokens = AuthTokens(
            accessToken: "mock_access_token",
            refreshToken: "mock_refresh_token",
            oauthRefreshToken: "mock_oauth_refresh_token"
        )

        // Then
        #expect(tokens.accessToken.contains("mock_access_token"))
        #expect(tokens.refreshToken.contains("mock_refresh_token"))
        #expect(tokens.oauthRefreshToken != nil)
    }

    @Test("LoginEntity Google 사용자 테스트")
    func test_LoginEntity_google_user() throws {
        // Given
        let loginEntity = LoginEntity(
            name: "김철수",
            isNewUser: false,
            provider: .google,
            token: AuthTokens(accessToken: "access", refreshToken: "refresh"),
            role: .member
        )

        // Then
        #expect(loginEntity.name == "김철수")
        #expect(loginEntity.provider == .google)
        #expect(loginEntity.isNewUser == false)
        #expect(loginEntity.role == .member)
    }

    @Test("AppleOAuthPayload Mock 데이터 테스트")
    func test_AppleOAuthPayload_mock_data() throws {
        // Given
        let payload = AppleOAuthPayload(
            idToken: "mock_apple_id_token",
            authorizationCode: "mock_authorization_code",
            displayName: "Kim Chulsu",
            nonce: "mock_nonce"
        )

        // Then
        #expect(payload.idToken.contains("mock_apple_id_token"))
        #expect(payload.displayName == "Kim Chulsu")
        #expect(payload.authorizationCode != nil)
    }

    @Test("WithdrawEntity 성공 응답 테스트")
    func test_WithdrawEntity_success_response() throws {
        // Given
        let withdraw = WithdrawEntity(isSuccess: true, code: "200", message: "회원 탈퇴 성공")

        // Then
        #expect(withdraw.isSuccess == true)
        #expect(withdraw.code == "200")
        #expect(withdraw.message != nil)
    }

    @Test("AuthExitEntity 로그아웃 테스트")
    func test_AuthExitEntity_logout() throws {
        // Given
        let authExit = AuthExitEntity(code: "200", message: "로그아웃 성공")

        // Then
        #expect(authExit.code == "200")
        #expect(authExit.message?.contains("로그아웃") == true)
    }

    @Test("Google OAuth Payload 토큰 테스트")
    func test_GoogleOAuthPayload_tokens() throws {
        // Given
        let payload = GoogleOAuthPayload(
            idToken: "mock_google_id_token",
            accessToken: "mock_google_access_token",
            authorizationCode: "mock_authorization_code",
            displayName: "Kim Chulsu"
        )

        // Then
        #expect(payload.idToken.contains("mock_google_id_token"))
        #expect(payload.accessToken?.contains("mock_google_access_token") == true)
        #expect(payload.displayName == "Kim Chulsu")
    }
}
