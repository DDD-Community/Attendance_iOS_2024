//
//  ScheduleLiveDependencies.swift
//  ScheduleDomain
//
//  이 모듈이 소유한 live 구현을 스스로 등록한다.
//  조립 모듈의 목록에 등록하지 않아도 `@Dependency`가 live context에서 바로 해석한다.
//

import Dependencies
import ScheduleDomainInterface


extension ScheduleRepositoryDependency: DependencyKey {
  public static var liveValue: Value { ScheduleRepositoryImpl() }
}

extension ScheduleUseCaseDependency: DependencyKey {
  public static var liveValue: Value { ScheduleUseCaseImpl() }
}
