//
//  EntityErrorBehaviorTests.swift
//  DomainAssemblyTests
//
//  Created by DDD on 9/4/26.
//

import Foundation
import Testing

import AppUpdateDomainInterface
import AttendanceDomainInterface
import AuthDomainInterface
import MyPageDomainInterface
import OnBoardingDomainInterface
import ProfileDomainInterface
import QRCodeDomainInterface
import ScheduleDomainInterface
import VoteDomainInterface


@Suite("Entity error behavior")
struct EntityErrorBehaviorTests {
  @Test("AuthError의 모든 사용자 문구와 분류를 제공한다")
  func authErrorBehavior() {
    let descriptions: [(AuthError, String)] = [
      (.configurationMissing, "인증 설정이 올바르게 구성되지 않았습니다."),
      (.missingPresentingController, "프레젠트할 뷰 컨트롤러를 찾을 수 없습니다."),
      (.missingIDToken, "ID 토큰을 가져오지 못했습니다."),
      (.userCancelled, "사용자가 로그인을 취소했습니다."),
      (.invalidCredential("nonce"), "잘못된 자격 증명입니다: nonce"),
      (.loginFailed, "로그인에 실패했습니다."),
      (.tokenRefreshFailed, "로그인 정보를 갱신하지 못했습니다."),
      (.logoutFailed, "로그아웃에 실패했습니다."),
      (.needsTermsAgreement("약관 동의 필요"), "약관 동의 필요"),
      (.accountDeletionFailed, "회원 탈퇴에 실패했습니다."),
      (.accountDeletionNotAllowed, "회원 탈퇴 권한이 없습니다."),
      (.accountAlreadyDeleted, "이미 탈퇴된 계정입니다."),
      (.refreshTokenExpired, "로그인이 만료되었습니다. 다시 로그인해주세요."),
      (.unknownError("unknown"), "알 수 없는 오류가 발생했습니다: unknown")
    ]
    for (error, description) in descriptions {
      #expect(error.errorDescription == description)
      #expect(error.isNetworkError == false)
    }

    #expect(AuthError.loginFailed.isRetryable)
    #expect(AuthError.tokenRefreshFailed.isRetryable)
    #expect(AuthError.logoutFailed.isRetryable)
    #expect(AuthError.configurationMissing.isRetryable == false)
    #expect(AuthError.accountDeletionFailed.isAccountDeletionError)
    #expect(AuthError.accountDeletionNotAllowed.isAccountDeletionError)
    #expect(AuthError.accountAlreadyDeleted.isAccountDeletionError)
    #expect(AuthError.loginFailed.isAccountDeletionError == false)
    #expect(AuthError.refreshTokenExpired.isTokenExpiredError)
    #expect(AuthError.loginFailed.isTokenExpiredError == false)
    #expect(AuthError.from(AuthError.logoutFailed) == .logoutFailed)
    #expect(AuthError.from(TestFailure.sample).errorDescription?.contains("sample") == true)
  }

  @Test("EditProfileError의 모든 문구와 분류를 제공한다")
  func editProfileErrorBehavior() {
    let errors: [EditProfileError] = [
      .invalidField("이름"), .fieldTooShort("이름"), .fieldTooLong("이름"),
      .invalidTeam, .teamNotSelected, .teamNotAvailable,
      .invalidRole, .roleNotSelected, .roleNotAvailable,
      .invalidGeneration, .generationNotFound,
      .profileNotFound, .profileUpdateFailed, .profileLocked,
      .unknownError("unknown"), .userCancelled, .missingRequiredField("이름")
    ]
    for error in errors {
      #expect(error.errorDescription?.isEmpty == false)
      _ = error.failureReason
      #expect(error.recoverySuggestion?.isEmpty == false)
      #expect(error.isNetworkError == false)
    }

    #expect(EditProfileError.invalidField("x").isFieldError)
    #expect(EditProfileError.fieldTooShort("x").isFieldError)
    #expect(EditProfileError.fieldTooLong("x").isFieldError)
    #expect(EditProfileError.missingRequiredField("x").isFieldError)
    #expect(EditProfileError.invalidTeam.isFieldError == false)
    #expect(EditProfileError.invalidTeam.isTeamError)
    #expect(EditProfileError.teamNotSelected.isTeamError)
    #expect(EditProfileError.teamNotAvailable.isTeamError)
    #expect(EditProfileError.invalidRole.isTeamError == false)
    #expect(EditProfileError.invalidRole.isRoleError)
    #expect(EditProfileError.roleNotSelected.isRoleError)
    #expect(EditProfileError.roleNotAvailable.isRoleError)
    #expect(EditProfileError.invalidTeam.isRoleError == false)
    #expect(EditProfileError.profileUpdateFailed.isRetryable)
    #expect(EditProfileError.profileNotFound.isRetryable == false)
    #expect(EditProfileError.from(EditProfileError.profileLocked) == .profileLocked)
    #expect(EditProfileError.from(TestFailure.sample).errorDescription?.contains("sample") == true)
  }

  @Test("SignUpError의 모든 문구와 분류를 제공한다")
  func signUpErrorBehavior() {
    let errors: [SignUpError] = [
      .invalidInviteCode, .expiredInviteCode,
      .invalidJob, .jobNotSelected, .jobNotAvailable,
      .accountAlreadyExists, .accountCreationFailed,
      .nameTooShort, .nameTooLong,
      .unknownError("unknown"), .userCancelled, .missingRequiredField("이름")
    ]
    for error in errors {
      #expect(error.errorDescription?.isEmpty == false)
      _ = error.failureReason
      #expect(error.recoverySuggestion?.isEmpty == false)
      #expect(error.isNetworkError == false)
      #expect(error.isRetryable == false)
    }

    #expect(SignUpError.invalidInviteCode.isInviteCodeError)
    #expect(SignUpError.expiredInviteCode.isInviteCodeError)
    #expect(SignUpError.invalidJob.isInviteCodeError == false)
    #expect(SignUpError.invalidJob.isJobError)
    #expect(SignUpError.jobNotSelected.isJobError)
    #expect(SignUpError.jobNotAvailable.isJobError)
    #expect(SignUpError.nameTooLong.isJobError == false)
    #expect(SignUpError.from(SignUpError.invalidJob) == .invalidJob)
    #expect(SignUpError.from(TestFailure.sample).errorDescription?.contains("sample") == true)
  }

  @Test("ProfileError의 모든 문구와 분류를 제공한다")
  func profileErrorBehavior() {
    let errors: [ProfileError] = [
      .profileNotFound, .profileAccessDenied, .profileDataCorrupted,
      .loadFailed, .cacheFailed, .invalidSession,
      .unknownError("unknown"), .userCancelled, .missingRequiredField("이름")
    ]
    for error in errors {
      #expect(error.errorDescription?.isEmpty == false)
      _ = error.failureReason
      #expect(error.recoverySuggestion?.isEmpty == false)
      #expect(error.isRetryable == false)
    }

    for error in [ProfileError.profileNotFound, .profileAccessDenied, .profileDataCorrupted, .loadFailed, .invalidSession] {
      #expect(error.isFetchError)
    }
    #expect(ProfileError.cacheFailed.isFetchError == false)
    #expect(ProfileError.profileAccessDenied.requiresUserAction)
    #expect(ProfileError.profileNotFound.requiresUserAction == false)
    #expect(ProfileError.from(ProfileError.loadFailed) == .loadFailed)
    #expect(ProfileError.from(TestFailure.sample).errorDescription?.contains("sample") == true)
  }

  @Test("QR 및 앱 업데이트 오류의 모든 분기를 제공한다")
  func qrAndAppUpdateErrorBehavior() {
    let qrErrors: [QRCodeError] = [
      .generationFailed, .invalidPayload, .imageRenderingFailed, .createFailed,
      .validationFailed("검증 실패"), .userNotFound, .invalidSession, .unknownError("unknown")
    ]
    for error in qrErrors {
      #expect(error.errorDescription?.isEmpty == false)
      #expect(error.recoverySuggestion?.isEmpty == false)
    }
    #expect(QRCodeError.from(QRCodeError.generationFailed) == .generationFailed)
    #expect(QRCodeError.from(TestFailure.sample).errorDescription?.contains("sample") == true)

    let appErrors: [AppUpdateError] = [
      .invalidBundleId, .appNotFound, .lookupFailed, .invalidResponse, .unknownError
    ]
    for error in appErrors {
      #expect(error.errorDescription?.isEmpty == false)
    }
    #expect(AppUpdateError.from(AppUpdateError.appNotFound) == .appNotFound)
    #expect(AppUpdateError.from(TestFailure.sample) == .unknownError)
    #expect(MyPageError.loadFailed.errorDescription == "마이페이지 정보를 불러오지 못했습니다")
  }

  @Test("AttendanceError의 문구와 서버 매핑을 제공한다")
  func attendanceErrorBehavior() {
    let errors: [AttendanceError] = [
      .invalidDate, .loadFailed, .updateFailed, .rejected("출석일이 아닙니다"), .unknown
    ]
    for error in errors {
      #expect(error.errorDescription?.isEmpty == false)
      #expect(error.failureReason?.isEmpty == false)
      #expect(error.recoverySuggestion?.isEmpty == false)
    }
    #expect(AttendanceError.from(AttendanceError.invalidDate) == .invalidDate)
    #expect(AttendanceError.from(TestFailure.sample) == .unknown)
    #expect(AttendanceError.from(statusCode: 400, message: "거절") == .rejected("거절"))
    #expect(AttendanceError.from(statusCode: 499, message: "거절") == .rejected("거절"))
    #expect(AttendanceError.from(statusCode: 400, message: "") == .unknown)
    #expect(AttendanceError.from(statusCode: 500, message: "서버") == .unknown)
  }

  @Test("ScheduleError의 문구와 상태 매핑을 제공한다")
  func scheduleErrorBehavior() {
    let errors: [ScheduleError] = [.invalidDate, .loadFailed, .cacheFailed, .unknown]
    for error in errors {
      #expect(error.errorDescription?.isEmpty == false)
      #expect(error.failureReason?.isEmpty == false)
      #expect(error.recoverySuggestion?.isEmpty == false)
    }
    #expect(ScheduleError.from(ScheduleError.invalidDate) == .invalidDate)
    #expect(ScheduleError.from(TestFailure.sample) == .unknown)
    #expect(ScheduleError.from(statusCode: 400) == .invalidDate)
    #expect(ScheduleError.from(statusCode: 500) == .unknown)
  }

  @Test("VoteError의 모든 문구와 서버 코드 매핑을 제공한다")
  func voteErrorBehavior() {
    let errors: [VoteError] = [
      .noActiveVote, .notFound, .managerOnly, .invalidStatus,
      .alreadyOpen, .requestFailed, .invalidResponse, .unknown
    ]
    for error in errors {
      #expect(error.errorDescription?.isEmpty == false)
      #expect(error.failureReason?.isEmpty == false)
      #expect(error.recoverySuggestion?.isEmpty == false)
    }
    #expect(VoteError.from(VoteError.alreadyOpen) == .alreadyOpen)
    #expect(VoteError.from(TestFailure.sample) == .unknown)

    let mappings: [(Int, String?, VoteError)] = [
      (500, "VOTE_NO_ACTIVE", .noActiveVote),
      (500, "DATA_NOT_FOUND", .notFound),
      (500, "VOTE_NOT_FOUND", .notFound),
      (500, "MANAGER_ONLY", .managerOnly),
      (500, "VOTE_MANAGER_NOT_ALLOWED", .managerOnly),
      (500, "VOTE_ALREADY_OPEN", .alreadyOpen),
      (500, "VOTE_INVALID_STATUS", .invalidStatus),
      (500, "VOTE_NOT_DRAFT", .invalidStatus),
      (500, "VOTE_NOT_OPEN", .invalidStatus),
      (500, "VALIDATION_ERROR", .invalidStatus),
      (403, nil, .managerOnly),
      (404, nil, .notFound),
      (500, nil, .unknown)
    ]
    for (status, code, expected) in mappings {
      #expect(VoteError.from(statusCode: status, code: code) == expected)
    }
  }
}

private enum TestFailure: String, Error, LocalizedError {
  case sample

  var errorDescription: String? { rawValue }
}
