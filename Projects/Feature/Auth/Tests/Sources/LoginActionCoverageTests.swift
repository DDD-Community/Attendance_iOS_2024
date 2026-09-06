//
//  LoginActionCoverageTests.swift
//  AuthTests
//
//  Created by DDD on 2026-09-03
//
//  LoginFeature 리듀서의 모든 액션 분기(binding/view/async/inner/scope/delegate)를
//  TestStore 로 태워 커버리지를 확보한다.
//

import AuthenticationServices
import ComposableArchitecture
import AuthDomainInterface
import Foundation
import Testing

@testable import Auth

@MainActor
@Suite("LoginFeature 액션 커버리지", .serialized)
struct LoginActionCoverageTests {
  // MARK: - binding

  /// BindingReducer 가 붙어 있어 binding 액션이 State 를 그대로 갱신하는지 확인한다.
  @Test("binding 액션은 nonce 를 그대로 반영한다")
  func binding_setNonce_updatesState() async {
    let store = Self.makeStore()

    await store.send(.binding(.set(\.nonce, "binding-nonce"))) {
      $0.nonce = "binding-nonce"
    }
  }

  // MARK: - view

  /// 소셜 버튼 탭이 곧바로 async 로그인 액션으로 위임되는지 확인한다.
  @Test("signInWithSocial 은 async 로그인 액션으로 위임된다")
  func view_signInWithSocial_forwardsToAsyncLogin() async {
    let store = Self.makeStore(oauthOutcome: .success(LoginTestFixture.member))
    store.exhaustivity = .off

    await store.send(.view(.signInWithSocial(social: .google)))
    await store.receive(\.async)
    #expect(store.state.currentSocialType == .google)

    await store.receive(\.inner)
    await store.receive(\.delegate.presentMemberMain)
    await store.finish()
  }

  /// showPolicyPopUp 이 개인정보 동의 팝업 State 를 세팅하는지 확인한다.
  @Test("showPolicyPopUp 은 개인정보 동의 팝업을 세팅한다")
  func view_showPolicyPopUp_presentsConsentAlert() async {
    let store = Self.makeStore()

    await store.send(.view(.showPolicyPopUp)) {
      $0.customAlert = .privacyPolicyConsent()
    }
  }

  // MARK: - async

  /// prepareAppleRequest 가 AppleAuthRequest 로부터 받은 nonce 를 State 에 보관하는지 확인한다.
  @Test("prepareAppleRequest 는 생성된 nonce 를 State 에 보관한다")
  func async_prepareAppleRequest_storesNonce() async {
    let store = Self.makeStore()
    store.exhaustivity = .off

    let request = ASAuthorizationAppleIDProvider().createRequest()
    await store.send(.async(.prepareAppleRequest(request)))

    #expect(store.state.nonce.isEmpty == false)
    await store.finish()
  }

  /// Apple 인증 결과가 실패면 credential 가드에 걸려 실패 응답으로 떨어지는지 확인한다.
  @Test("appleLogin 결과가 실패면 자격 증명 오류 응답으로 이어진다")
  func async_appleLogin_failureResult_routesToLoginFailure() async {
    let store = Self.makeStore()
    store.exhaustivity = .off

    let result = Result<ASAuthorization, Error>.failure(AuthError.userCancelled)
    await store.send(.async(.appleLogin(result, nonce: "valid-nonce")))

    #expect(store.state.currentSocialType == .apple)
    await store.receive(\.inner)
    await store.finish()
  }

  /// nonce 가 비어 있는 경계값에서도 동일하게 실패 응답으로 떨어지는지 확인한다.
  @Test("appleLogin 의 nonce 가 비어 있으면 실패 응답으로 이어진다")
  func async_appleLogin_emptyNonce_routesToLoginFailure() async {
    let store = Self.makeStore()
    store.exhaustivity = .off

    let result = Result<ASAuthorization, Error>.failure(AuthError.userCancelled)
    await store.send(.async(.appleLogin(result, nonce: "")))

    await store.receive(\.inner)
    await store.finish()
  }

  /// Google 로그인 정상 플로우가 세션 provider 를 갱신하고 멤버 화면으로 이동하는지 확인한다.
  @Test("google 로그인 성공은 provider 를 갱신하고 멤버 메인으로 이동한다")
  func async_login_google_success_navigatesToMemberMain() async {
    let store = Self.makeStore(oauthOutcome: .success(LoginTestFixture.member))
    store.exhaustivity = .off

    await store.send(.async(.login(socialType: .google)))
    #expect(store.state.currentSocialType == .google)
    #expect(store.state.userSession.provider == .google)

    await store.receive(\.inner)
    await store.receive(\.delegate.presentMemberMain)
    await store.finish()
  }

  /// Apple credential 이 없는 상태의 login 은 실패 경로(=appleOAuth 취소 ID 분기)를 탄다.
  @Test("credential 없는 apple 로그인은 실패 응답 경로를 탄다")
  func async_login_appleWithoutCredential_routesToLoginFailure() async {
    let store = Self.makeStore()
    store.exhaustivity = .off

    await store.send(.async(.login(socialType: .apple)))
    #expect(store.state.currentSocialType == .apple)
    #expect(store.state.userSession.provider == .apple)

    await store.receive(\.inner)
    await store.finish()
  }

  // MARK: - inner (성공)

  /// 기존 멤버 로그인은 역할을 저장하고 멤버 메인으로 이동한다.
  @Test("기존 멤버 로그인 성공은 역할 저장 후 멤버 메인으로 이동한다")
  func inner_loginResponse_existingMember_navigatesToMemberMain() async {
    let store = Self.makeStore()

    await store.send(.inner(.loginResponse(.success(LoginTestFixture.member)))) {
      $0.staffRole = .member
      $0.userSession.userRole = .member
    }
    await store.receive(\.delegate.presentMemberMain)
  }

  /// 운영진 로그인은 staffMain 으로 분기한다.
  @Test("운영진 로그인 성공은 운영진 메인으로 이동한다")
  func inner_loginResponse_manager_navigatesToStaffMain() async {
    let store = Self.makeStore()

    await store.send(.inner(.loginResponse(.success(LoginTestFixture.manager)))) {
      $0.staffRole = .manager
      $0.userSession.userRole = .manager
    }
    await store.receive(\.delegate.presentStaffMain)
  }

  /// role 이 nil 인 경계값은 member 로 기본 처리된다.
  @Test("role 이 nil 인 로그인 성공은 member 로 기본 처리된다")
  func inner_loginResponse_nilRole_defaultsToMember() async {
    let store = Self.makeStore()

    await store.send(.inner(.loginResponse(.success(LoginTestFixture.roleless)))) {
      $0.staffRole = .member
      $0.userSession.userRole = .member
    }
    await store.receive(\.delegate.presentMemberMain)
  }

  /// 신규 가입자는 editGeneration 잔재를 지우고 약관 팝업을 띄운다.
  @Test("신규 가입자 로그인 성공은 editGeneration 을 초기화하고 약관 팝업을 띄운다")
  func inner_loginResponse_newUser_showsPolicyPopUp() async {
    let store = Self.makeStore(configureState: { $0.editGeneration = true })

    await store.send(.inner(.loginResponse(.success(LoginTestFixture.newUser)))) {
      $0.staffRole = nil
      $0.userSession.userRole = .manager
      $0.editGeneration = false
    }
    await store.receive(\.view.showPolicyPopUp) {
      $0.customAlert = .privacyPolicyConsent()
    }
  }

  // MARK: - inner (실패)

  /// currentSocialType 이 apple 이면 Apple 전용 실패 토스트 분기를 탄다.
  @Test("apple 로그인 실패는 apple 전용 토스트 분기를 탄다")
  func inner_loginResponse_failure_appleBranch() async {
    let store = Self.makeStore(configureState: { $0.currentSocialType = .apple })
    store.exhaustivity = .off

    await store.send(.inner(.loginResponse(.failure(.invalidCredential("no credential")))))
    await store.finish()
  }

  /// currentSocialType 이 google 이면 구글 전용 실패 토스트 분기를 탄다.
  @Test("google 로그인 실패는 google 전용 토스트 분기를 탄다")
  func inner_loginResponse_failure_googleBranch() async {
    let store = Self.makeStore(configureState: { $0.currentSocialType = .google })
    store.exhaustivity = .off

    await store.send(.inner(.loginResponse(.failure(.loginFailed))))
    await store.finish()
  }

  /// socialType 이 없는 경계값은 기본 실패 토스트 분기를 탄다.
  @Test("socialType 이 없는 실패는 기본 토스트 분기를 탄다")
  func inner_loginResponse_failure_defaultBranch() async {
    let store = Self.makeStore()
    store.exhaustivity = .off

    await store.send(.inner(.loginResponse(.failure(.unknownError("boom")))))
    await store.finish()
  }

  // MARK: - scope (customAlert)

  /// 약관 동의 확인은 팝업을 닫고 0.3초 뒤 회원가입 초대 화면을 요청한다.
  @Test("약관 팝업 확인은 팝업을 닫고 지연 후 회원가입 초대를 요청한다")
  func scope_customAlert_confirmTapped_presentsSignUpInvite() async {
    let clock = TestClock()
    let store = Self.makeStore(
      clock: clock,
      configureState: { $0.customAlert = .privacyPolicyConsent() }
    )

    await store.send(.scope(.customAlert(.presented(.confirmTapped)))) {
      $0.customAlert = nil
    }

    await clock.advance(by: .seconds(0.3))
    await store.receive(\.delegate.presentSignUpInviteView)
    await store.finish()
  }

  /// 취소는 팝업만 닫고 아무 효과도 내지 않는다.
  @Test("약관 팝업 취소는 팝업만 닫는다")
  func scope_customAlert_cancelTapped_dismissesAlert() async {
    let store = Self.makeStore(configureState: { $0.customAlert = .privacyPolicyConsent() })

    await store.send(.scope(.customAlert(.presented(.cancelTapped)))) {
      $0.customAlert = nil
    }
  }

  /// 약관 링크 탭은 팝업을 유지한 채 웹 이동을 위임한다.
  @Test("약관 링크 탭은 팝업을 유지한 채 웹 이동을 위임한다")
  func scope_customAlert_policyTapped_presentsWeb() async {
    let store = Self.makeStore(configureState: { $0.customAlert = .privacyPolicyConsent() })

    await store.send(.scope(.customAlert(.presented(.policyTapped))))
    await store.receive(\.delegate.presentWeb)

    #expect(store.state.customAlert != nil)
  }

  /// dismiss 는 ifLet 이 팝업 State 를 비운다.
  @Test("dismiss 는 팝업 State 를 비운다")
  func scope_customAlert_dismiss_clearsAlert() async {
    let store = Self.makeStore(configureState: { $0.customAlert = .privacyPolicyConsent() })

    await store.send(.scope(.customAlert(.dismiss))) {
      $0.customAlert = nil
    }
  }

  // MARK: - delegate

  /// delegate 는 상위가 처리하는 계약이라 리듀서 내부에서는 무효과여야 한다.
  @Test("delegate 액션은 State 변경도 효과도 만들지 않는다")
  func delegate_allCases_produceNoEffect() async {
    let store = Self.makeStore()

    await store.send(.delegate(.presentSignUpInviteView))
    await store.send(.delegate(.presentStaffMain))
    await store.send(.delegate(.presentMemberMain))
    await store.send(.delegate(.presentWeb))
  }
}

// MARK: - Helpers

private extension LoginActionCoverageTests {
  /// @Shared(appStorage/inMemory) 가 테스트 간에 새지 않도록 저장소를 격리한 TestStore 를 만든다.
  ///
  /// `initialState` 는 autoclosure 라서 TestStore 내부(공유 상태 추적기가 설치된 컨텍스트)에서
  /// 평가된다. State 를 미리 만들어 넘기면 추적기에 등록되지 않으므로 반드시 클로저 안에서 조립한다.
  static func makeStore(
    clock: TestClock<Duration> = TestClock(),
    oauthOutcome: Result<LoginEntity, AuthError>? = nil,
    configureState: (inout LoginFeature.State) -> Void = { _ in }
  ) -> TestStore<LoginFeature.State, LoginFeature.Action> {
    let appStorage = UserDefaults.inMemory
    let inMemoryStorage = InMemoryStorage()

    return TestStore(
      initialState: {
        var state = LoginFeature.State()
        configureState(&state)
        return state
      }()
    ) {
      LoginFeature()
    } withDependencies: {
      $0.defaultAppStorage = appStorage
      $0.defaultInMemoryStorage = inMemoryStorage
      $0.continuousClock = clock
      if let oauthOutcome {
        $0.unifiedOAuthUseCase = StubUnifiedOAuthUseCase(outcome: oauthOutcome)
      }
    }
  }
}

/// 기본 testValue 는 항상 실패를 돌려주므로, 로그인 성공 경로를 태우려면 결과를 주입해야 한다.
private struct StubUnifiedOAuthUseCase: UnifiedOAuthUseCaseInterface {
  let outcome: Result<LoginEntity, AuthError>

  func processOAuthFlow(
    with _: SocialType,
    appleCredential _: ASAuthorizationAppleIDCredential?,
    nonce _: String?,
    googleToken _: String?
  ) async -> Result<LoginEntity, AuthError> {
    outcome
  }
}

// MARK: - Fixtures

enum LoginTestFixture {
  static let member = LoginEntity(
    name: "김철수",
    isNewUser: false,
    provider: .apple,
    token: AuthTokens(
      accessToken: "access-token",
      refreshToken: "refresh-token",
      oauthRefreshToken: nil
    ),
    role: .member
  )

  static let manager = LoginEntity(
    name: "박운영",
    isNewUser: false,
    provider: .google,
    token: AuthTokens(
      accessToken: "manager-access-token",
      refreshToken: "manager-refresh-token",
      oauthRefreshToken: "manager-oauth-token"
    ),
    role: .manager
  )

  static let roleless = LoginEntity(
    name: "역할없음",
    isNewUser: false,
    provider: .google,
    token: AuthTokens(
      accessToken: "roleless-access-token",
      refreshToken: "roleless-refresh-token",
      oauthRefreshToken: nil
    ),
    role: nil
  )

  static let newUser = LoginEntity(
    name: "신규유저",
    isNewUser: true,
    provider: .apple,
    token: AuthTokens(
      accessToken: "new-access-token",
      refreshToken: "new-refresh-token",
      oauthRefreshToken: nil
    ),
    role: .manager
  )
}
