//
//  LiveDependencyRegistrationTests.swift
//  DomainAssemblyTests
//
//  Created by DDD on 9/2/26.
//

import Dependencies
import AppUpdateDomainInterface
import AttendanceDomainInterface
import AuthDomainInterface
import MyPageDomainInterface
import OnBoardingDomainInterface
import ProfileDomainInterface
import QRCodeDomainInterface
import ScheduleDomainInterface
import ServiceAssembly
import VoteDomainInterface
import Testing

@testable import DomainAssembly

@Suite("DomainAssembly 라이브 의존성")
struct LiveDependencyRegistrationTests {
  /// live context 에서 Repository liveValue 가 전부 해석되는지 확인한다.
  /// 조립 모듈의 등록이 dead strip 으로 링크에서 빠지면 여기서 먼저 깨진다.
  /// authService 는 ServiceAssembly 소관이라 NetworkContainerTests 가 검증한다.
  @Test("모든 Repository가 live context에서 등록된다")
  func resolvesAllLiveDependencies() {
    withDependencies {
      $0.context = .live
      ServiceDependencyAssembly.register(into: &$0)
    } operation: {
      @Dependency(\.attendanceRepository) var attendanceRepository
      @Dependency(\.scheduleRepository) var scheduleRepository
      @Dependency(\.qrCodeRepository) var qrCodeRepository
      @Dependency(\.authRepository) var authRepository
      @Dependency(\.googleOAuthRepository) var googleOAuthRepository
      @Dependency(\.appleOAuthRepository) var appleOAuthRepository
      @Dependency(\.appleManger) var appleAuthRequest
      @Dependency(\.onBoardingRepository) var onBoardingRepository
      @Dependency(\.signUpRepository) var signUpRepository
      @Dependency(\.profileRepository) var profileRepository
      @Dependency(\.myPageRepository) var myPageRepository
      @Dependency(\.appUpdateRepository) var appUpdateRepository
      @Dependency(\.voteRepository) var voteRepository

      #expect(attendanceRepository is AttendanceRepositoryImpl)
      #expect(scheduleRepository is ScheduleRepositoryImpl)
      #expect(qrCodeRepository is QRCodeRepositoryImpl)
      #expect(authRepository is AuthRepositoryImpl)
      #expect(googleOAuthRepository is GoogleOAuthRepositoryImpl)
      #expect(appleOAuthRepository is AppleOAuthRepositoryImpl)
      #expect(appleAuthRequest is AppleLoginRepositoryImpl)
      #expect(onBoardingRepository is OnBoardingRepositoryImpl)
      #expect(signUpRepository is SignUpRepositoryImpl)
      #expect(profileRepository is ProfileRepositoryImpl)
      #expect(myPageRepository is MyPageRepositoryImpl)
      #expect(appUpdateRepository is AppUpdateRepositoryImpl)
      #expect(voteRepository is VoteRepositoryImpl)
    }
  }
}
