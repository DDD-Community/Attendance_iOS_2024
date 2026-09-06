//
//  SignUpUseCaseInterface.swift
//  OnBoardingDomainInterface
//
//  Created by DDD on 9/3/26.
//

import AuthDomainInterface

import Dependencies

public protocol SignUpUseCaseInterface: Sendable {
  func registerUser(userSession: UserSession) async throws(SignUpError) -> SignUpUser
}

public struct MockSignUpUseCase: SignUpUseCaseInterface {
  public init() {}

  public func registerUser(userSession: UserSession) async throws(SignUpError) -> SignUpUser {
    SignUpUser(
      name: userSession.name,
      email: "",
      generation: String(userSession.generationId),
      team: userSession.selectTeam,
      managing: userSession.managing,
      selectPart: userSession.selectPart
    )
  }
}

public enum SignUpUseCaseDependency: TestDependencyKey {
  public static let testValue: any SignUpUseCaseInterface = MockSignUpUseCase()
  public static let previewValue: any SignUpUseCaseInterface = testValue
}

public extension DependencyValues {
  var signUpUseCase: any SignUpUseCaseInterface {
    get { self[SignUpUseCaseDependency.self] }
    set { self[SignUpUseCaseDependency.self] = newValue }
  }
}
