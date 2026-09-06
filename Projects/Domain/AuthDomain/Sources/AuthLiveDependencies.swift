//
//  AuthLiveDependencies.swift
//  AuthDomain
//
//  이 모듈이 소유한 live 구현을 스스로 등록한다.
//  조립 모듈의 목록에 등록하지 않아도 `@Dependency`가 live context에서 바로 해석한다.
//

import Dependencies
import AuthDomainInterface


extension AuthRepositoryDependency: DependencyKey {
  public static var liveValue: Value { AuthRepositoryImpl() }
}

extension GoogleOAuthRepositoryDependencyKey: DependencyKey {
  public static var liveValue: Value { GoogleOAuthRepositoryImpl() }
}

extension AppleOAuthRepositoryDependencyKey: DependencyKey {
  public static var liveValue: Value { AppleOAuthRepositoryImpl() }
}

extension AppleAuthRequestDependency: DependencyKey {
  public static var liveValue: Value { AppleLoginRepositoryImpl() }
}

extension AuthUseCaseDependency: DependencyKey {
  public static var liveValue: Value { AuthUseCaseImpl() }
}

extension UnifiedOAuthUseCaseDependency: DependencyKey {
  public static var liveValue: Value { UnifiedOAuthUseCase() }
}

extension AppleOAuthProviderDependency: DependencyKey {
  public static var liveValue: Value { AppleOAuthProvider() }
}

extension GoogleOAuthProviderDependency: DependencyKey {
  public static var liveValue: Value { GoogleOAuthProvider() }
}
