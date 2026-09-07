//
//  NetworkContainerTests.swift
//  ServiceAssemblyTests
//
//  Created by DDD on 9/1/26.
//

import Testing

import DDDAuthInterface
@testable import ServiceAssembly

import Dependencies

struct NetworkContainerTests {
  @Test
  func 인증서비스는_앱_생명주기_동안_같은_인스턴스를_사용한다() {
    let first = NetworkContainer.authService as AnyObject
    let second = NetworkContainer.authService as AnyObject

    #expect(first === second)
  }

  @Test
  func 인증클라이언트는_인증서비스와_함께_한번만_조립된다() {
    let first = NetworkContainer.authenticatedClient as AnyObject
    let second = NetworkContainer.authenticatedClient as AnyObject

    #expect(first === second)
  }

  @Test
  func 라이브_서비스는_ServiceAssembly에서_동일한_인스턴스로_등록된다() {
    withDependencies {
      $0.context = .live
      ServiceDependencyAssembly.register(into: &$0)
    } operation: {
      @Dependency(\.networkClient) var networkClient
      @Dependency(\.authService) var authService

      #expect(networkClient as AnyObject === NetworkContainer.authenticatedClient as AnyObject)
      #expect(authService as AnyObject === NetworkContainer.authService as AnyObject)
    }
  }
}
