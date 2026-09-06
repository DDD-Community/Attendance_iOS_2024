//
//  DDDSharedUIViewTests.swift
//  DDDSharedUITests
//
//  Created by DDD on 9/4/26.
//

import SwiftUI
import Testing
import UIKit

import DDDDesignKit
@testable import DDDSharedUI

@MainActor
@Suite("DDDSharedUI rendering")
struct DDDSharedUIViewTests {
  @Test("공유 UI의 주요 상태를 모두 렌더링한다")
  func rendersPublicComponents() {
    render(
      AttendanceCard(
        attendanceCount: 3,
        lateCount: 1,
        absentCount: 2,
        showWarning: true
      )
    )
    render(
      AttendanceCard(
        attendanceCount: 0,
        lateCount: 0,
        absentCount: 0,
        showWarning: false
      )
    )
    render(
      AttendanceStatusText(
        name: "홍길동",
        generataion: "13",
        roleType: "운영진",
        nameColor: .primary,
        roleTypeColor: .secondary,
        generationColor: .gray,
        backGroudColor: .black
      )
    )
    render(SelectPartItem(content: "iOS", isActive: true, completion: {}))
    render(SelectPartItem(content: "Server", isActive: false, completion: {}))
    render(SelectTeamIteam(content: "Team 1", isActive: true, completion: {}))
    render(SelectTeamIteam(content: "Team 2", isActive: false, completion: {}))
    render(SignUpPartText(content: "파트", title: "파트를 선택해 주세요", subtitle: "하나만 선택할 수 있어요"))
    render(SignUpPartText(content: "파트", title: "파트를 선택해 주세요", subtitle: ""))
  }

  @Test("일정 셀의 기본, 스탬프, 점선 상태를 렌더링한다")
  func rendersScheduleCellStates() {
    let basic = ScheduleCellStyle(
      backgroundColor: .white,
      stampImage: nil,
      dashBorder: false,
      monthDayOpacity: 1,
      titleDescriptionOpacity: 1
    )
    let completed = ScheduleCellStyle(
      backgroundColor: .gray,
      stampImage: Image(systemName: "checkmark.seal"),
      dashBorder: true,
      monthDayOpacity: 0.5,
      titleDescriptionOpacity: 0.5
    )

    render(ScheduleCell(month: 9, day: 2, title: "정기 모임", description: "서울", style: basic))
    render(ScheduleCell(month: 9, day: 9, title: "세션", description: "온라인", style: completed))
  }

  @Test("alert popup의 모든 style을 렌더링한다")
  func rendersAlertPopups() {
    let alertItems = [
      AlertItem.withdrawAccount(onConfirm: {}, onCancel: {}),
      AlertItem.deleteData(dataName: "일정", onConfirm: {}, onCancel: {}),
      AlertItem.logout(onConfirm: {}, onCancel: {}),
      AlertItem.saveChanges(onConfirm: {}, onCancel: {}),
    ]
    for item in alertItems {
      build(Color.clear.dddConfirmationPopup(item: item))
    }
    build(Color.clear.dddConfirmationPopup(item: nil))
    build(Color.clear.dddConfirmationPopup(isPresented: true, title: "제목", message: "메시지", onConfirm: {}, onCancel: {}))
    build(Color.clear.dddConfirmationPopup(isPresented: false, title: "제목", message: "", onConfirm: {}, onCancel: {}))

    let states: [CustomAlertState<CustomAlertAction>] = [
      .alert(title: "일반"), .withdrawAccount(), .exitWriting(), .startVote(),
      .endVote(), .logout(), .privacyPolicyConsent(),
      .appUpdate(version: "2.0", releaseNotes: "개선"),
      .appUpdate(version: "2.0", releaseNotes: nil),
      .appUpdate(version: "2.0", releaseNotes: ""),
    ]
    for state in states {
      build(
        CustomConfirmationPopup(
          title: state.title,
          message: state.message,
          confirmTitle: state.confirmTitle,
          cancelTitle: state.cancelTitle,
          isDestructive: state.isDestructive,
          style: state.style,
          checkboxTitle: state.checkboxTitle,
          onConfirm: {}, onCancel: {}, onPolicyTap: {}
        )
      )
    }
    #expect(states.count == 10)
  }

  /// 유닛 테스트에서 UIHostingController 로 레이아웃을 강제하면
  /// ViewModifier 가 감싼 뷰에서 SwiftUI 가 body 평가를 거부하며 프로세스가 죽는다.
  private func build(_ view: some View) {
    _ = view
  }

  private func render<V: View>(_ view: V) {
    _ = view.body
    let controller = UIHostingController(rootView: view)
    controller.view.frame = CGRect(x: 0, y: 0, width: 390, height: 844)
    controller.view.setNeedsLayout()
    controller.view.layoutIfNeeded()
    #expect(controller.view.bounds.width == 390)
  }
}
