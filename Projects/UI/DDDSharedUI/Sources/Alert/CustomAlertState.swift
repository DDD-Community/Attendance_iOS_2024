//
//  CustomAlertState.swift
//  DDDSharedUI
//
//  Created by DDD on 1/4/26.
//

import SwiftUI

import DDDDesignKit

import ComposableArchitecture

@ObservableState
public struct CustomAlertState<Action>: Equatable {
  public let title: String
  public let message: String
  public let confirmTitle: String
  public let cancelTitle: String
  public let isDestructive: Bool
  public let style: CustomAlertStyle
  public let checkboxTitle: String

  public init(
    title: String,
    message: String = "",
    confirmTitle: String = "확인",
    cancelTitle: String = "취소",
    isDestructive: Bool = false,
    style: CustomAlertStyle = .confirmation,
    checkboxTitle: String = ""
  ) {
    self.title = title
    self.message = message
    self.confirmTitle = confirmTitle
    self.cancelTitle = cancelTitle
    self.isDestructive = isDestructive
    self.style = style
    self.checkboxTitle = checkboxTitle
  }
}

public enum CustomAlertStyle: Equatable {
  case confirmation
  case consent
  /// 운영진 투표 시작 확인 전용 스타일 (다른 확인 팝업과 분리)
  case startConfirmation
  /// 운영진 투표 종료 확인 전용 스타일 (우측 빨강 버튼)
  case endConfirmation
}

@CasePathable
public enum CustomAlertAction: Equatable {
  case confirmTapped
  case cancelTapped
  case policyTapped
}

@Reducer
public struct CustomConfirmAlert {
  public init() {}

  public var body: some Reducer<CustomAlertState<CustomAlertAction>, CustomAlertAction> {
    EmptyReducer()
  }
}

public extension CustomAlertState where Action == CustomAlertAction {
  static func alert(
    title: String,
    message: String = "",
    confirmTitle: String = "확인",
    cancelTitle: String = "취소",
    isDestructive: Bool = false
  ) -> CustomAlertState<CustomAlertAction> {
    CustomAlertState(
      title: title,
      message: message,
      confirmTitle: confirmTitle,
      cancelTitle: cancelTitle,
      isDestructive: isDestructive,
      style: .confirmation,
      checkboxTitle: ""
    )
  }

  static func withdrawAccount() -> CustomAlertState<CustomAlertAction> {
    .alert(
      title: "정말 탈퇴하시겠습니까?",
      message: "탈퇴 시, 등록된 모든 출석 데이터가 삭제됩니다.",
      confirmTitle: "탈퇴하기",
      cancelTitle: "취소",
      isDestructive: true
    )
  }

  /// 투표 작성 화면 이탈 방지 모달.
  /// confirm("계속 작성") = 화면 유지, cancel("나가기") = 입력값 미저장 후 이탈.
  /// 좌측 회색 버튼이 confirm, 우측 파란 버튼이 cancel과 매칭된다.
  static func exitWriting() -> CustomAlertState<CustomAlertAction> {
    CustomAlertState(
      title: "정말 뒤로 가시겠어요?",
      message: "지금 나가면 작성 중인 내용이 저장되지 않아요.",
      confirmTitle: "계속 작성",
      cancelTitle: "나가기",
      isDestructive: false,
      style: .startConfirmation,
      checkboxTitle: ""
    )
  }

  /// 운영진 투표 시작 확인 모달.
  /// 좌측 회색 버튼이 confirm("취소") = 닫기, 우측 파란 버튼이 cancel("시작하기") = 투표 시작.
  static func startVote() -> CustomAlertState<CustomAlertAction> {
    CustomAlertState(
      title: "투표를 시작할까요?",
      message: "시작하면 멤버 메뉴에 '투표'가\n노출되고 참여를 받기 시작해요.",
      confirmTitle: "취소",
      cancelTitle: "시작하기",
      isDestructive: false,
      style: .startConfirmation,
      checkboxTitle: ""
    )
  }

  /// 운영진 투표 종료 확인 모달.
  /// 좌측 회색 confirm("취소") = 닫기, 우측 빨강 cancel("종료하기") = 투표 종료.
  static func endVote() -> CustomAlertState<CustomAlertAction> {
    CustomAlertState(
      title: "투표를 종료할까요?",
      message: "종료 후에는 투표를 다시 시작할 수 없어요.\n결과는 최종 발표에서 공개돼요.",
      confirmTitle: "취소",
      cancelTitle: "종료하기",
      isDestructive: true,
      style: .endConfirmation,
      checkboxTitle: ""
    )
  }

  static func logout() -> CustomAlertState<CustomAlertAction> {
    .alert(
      title: "로그아웃 하시겠습니까?",
      message: "다시 로그인해야 앱을 사용할 수 있습니다.",
      confirmTitle: "로그아웃",
      cancelTitle: "취소",
      isDestructive: false
    )
  }

  static func consent(
    title: String,
    message: String,
    checkboxTitle: String
  ) -> CustomAlertState<CustomAlertAction> {
    CustomAlertState(
      title: title,
      message: message,
      confirmTitle: "",
      cancelTitle: "",
      isDestructive: false,
      style: .consent,
      checkboxTitle: checkboxTitle
    )
  }

  static func privacyPolicyConsent() -> CustomAlertState<CustomAlertAction> {
    .consent(
      title: "개인정보처리방침에\n동의하시겠습니까?",
      message: "회원 가입 및 서비스 제공을 위해\n개인정보를 수집·이용합니다.",
      checkboxTitle: "개인정보처리방침 동의"
    )
  }

  static func appUpdate(
    version: String,
    releaseNotes: String? = nil
  ) -> CustomAlertState<CustomAlertAction> {
    let message = if let releaseNotes = releaseNotes, !releaseNotes.isEmpty {
      "새로운 버전 \(version)이 출시되었습니다!\n\n\(releaseNotes)\n\n더 나은 경험을 위해 업데이트하세요!"
    } else {
      "새로운 버전 \(version)이 준비되었습니다!\n\n더 나은 경험을 위해 지금 업데이트하세요!"
    }

    return .alert(
      title: "새로운 버전이 출시되었어요!",
      message: message,
      confirmTitle: "지금 업데이트",
      cancelTitle: "나중에 할게요",
      isDestructive: false
    )
  }
}
