//
//  ManagementAccessibilityIDTests.swift
//  ManagementTests
//

import AttendanceDomainInterface
import DDDDesignKit
import Testing

@testable import Management

@Suite("Management accessibility ID")
struct ManagementAccessibilityIDTests {
  @Test("운영진 출석 화면의 고정 ID 계약")
  func fixedIdentifiers() {
    #expect(ManagementAccessibilityID.Staff.root == "management.staff.root")
    #expect(ManagementAccessibilityID.Staff.skeleton == "management.staff.skeleton")
    #expect(ManagementAccessibilityID.Attendance.root == "management.attendance.root")
    #expect(ManagementAccessibilityID.Attendance.summary == "management.attendance.summary")
    #expect(ManagementAccessibilityID.Attendance.list == "management.attendance.list")
    #expect(ManagementAccessibilityID.Attendance.listSkeleton == "management.attendance.list.skeleton")
    #expect(ManagementAccessibilityID.ScheduleModal.root == "management.schedule.modal")
    #expect(ManagementAccessibilityID.ScheduleModal.skeleton == "management.schedule.modal.skeleton")
    #expect(ManagementAccessibilityID.ScheduleModal.list == "management.schedule.modal.list")
    #expect(ManagementAccessibilityID.ScheduleModal.confirmButton == "management.schedule.modal.confirmbutton")
    #expect(ManagementAccessibilityID.Staff.dropdown == "management.staff.dropdown")
    #expect(ManagementAccessibilityID.Schedule.root == "management.schedule.root")
    #expect(ManagementAccessibilityID.Schedule.header == "management.schedule.header")
    #expect(ManagementAccessibilityID.Schedule.list == "management.schedule.list")
    #expect(ManagementAccessibilityID.Schedule.skeleton == "management.schedule.skeleton")
    #expect(ManagementAccessibilityID.Vote.root == "management.vote.root")
    #expect(ManagementAccessibilityID.Vote.skeleton == "management.vote.skeleton")
    #expect(ManagementAccessibilityID.Vote.statusChip == "management.vote.statuschip")
    #expect(ManagementAccessibilityID.Vote.startButton == "management.vote.startbutton")
    #expect(ManagementAccessibilityID.Vote.endButton == "management.vote.endbutton")
    #expect(ManagementAccessibilityID.Vote.nonParticipantsButton == "management.vote.nonparticipantsbutton")
    #expect(ManagementAccessibilityID.Vote.nonParticipantsModal == "management.vote.nonparticipantsmodal")
    #expect(ManagementAccessibilityID.QRScanner.root == "management.qrscanner.root")
    #expect(ManagementAccessibilityID.QRScanner.closeButton == "management.qrscanner.closebutton")
    #expect(ManagementAccessibilityID.QRScanner.resultText == "management.qrscanner.resulttext")
  }

  @Test("반복 항목 ID는 안정적인 도메인 키를 붙인다")
  func dynamicIdentifiers() {
    #expect(ManagementAccessibilityID.Attendance.team(7) == "management.attendance.team.7")
    #expect(
      ManagementAccessibilityID.Attendance.card(userID: "member-id")
        == "management.attendance.card.member-id"
    )
    #expect(
      ManagementAccessibilityID.Attendance.cardEditButton(userID: "member-id")
        == "management.attendance.card.member-id.editbutton"
    )
    #expect(
      ManagementAccessibilityID.Attendance.modalStatus(.late)
        == "management.attendance.modal.status.late"
    )
    #expect(
      ManagementAccessibilityID.ScheduleModal.item(42)
        == "management.schedule.modal.item.42"
    )
    #expect(ManagementAccessibilityID.Schedule.card(9) == "management.schedule.card.9")
    #expect(
      ManagementAccessibilityID.Staff.dropdownItem(.attendance)
        == "management.staff.dropdown.item.attendance"
    )
    #expect(
      ManagementAccessibilityID.Staff.dropdownItem(.schedule)
        == "management.staff.dropdown.item.schedule"
    )
    #expect(ManagementAccessibilityID.Staff.dropdownItem(.vote) == "management.staff.dropdown.item.vote")
  }
}
