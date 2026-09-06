//
//  RepositoryUnderTest.swift
//  RepositoryTests
//
//  Created by DDD on 2026-09-02
//
//  Repository 는 networkClient·authService 를 @Dependency 로 받는다.
//  swift-dependencies 는 withDependencies 블록 안에서 만들어진 객체가 그 스코프를
//  물려받게 해주므로, 테스트는 여기서 만들어야 스텁이 실제로 적용된다.
//  블록 밖에서 생성하면 조용히 testValue(Unimplemented…)를 잡아 fatalError 로 죽는다.
//

import DDDAuthInterface
import DDDNetworkInterface

import Dependencies

/// 네트워크 스텁을 끼운 Repository 를 만든다.
func makeRepository<Repository>(
  client: any DDDNetworkClient,
  authService: (any AuthService)? = nil,
  _ build: () -> Repository
) -> Repository {
  return withDependencies {
    $0.networkClient = client
    if let authService {
      $0.authService = authService
    }
  } operation: {
    build()
  }
}
