//
//  MemberAccessibilityIDTests.swift
//  MemberTests
//

import Testing

@testable import Member

@Suite("Member accessibility ID")
struct MemberAccessibilityIDTests {
  @Test("멤버 화면의 고정 ID 계약")
  func fixedIdentifiers() {
    #expect(MemberAccessibilityID.root == "member.home.root")
    #expect(MemberAccessibilityID.skeleton == "member.home.skeleton")
    #expect(MemberAccessibilityID.dropdown == "member.home.dropdown")
    #expect(MemberAccessibilityID.Vote.skeleton == "member.vote.skeleton")
    #expect(MemberAccessibilityID.Vote.TeamSelect.root == "member.vote.teamselect.root")
    #expect(MemberAccessibilityID.Vote.TeamSelect.nextButton == "member.vote.teamselect.nextbutton")
    #expect(MemberAccessibilityID.Vote.Feedback.root == "member.vote.feedback.root")
    #expect(MemberAccessibilityID.Vote.Feedback.submitButton == "member.vote.feedback.submitbutton")
    #expect(MemberAccessibilityID.QRCode.root == "member.qrcode.root")
    #expect(MemberAccessibilityID.QRCode.image == "member.qrcode.image")
    #expect(MemberAccessibilityID.QRCode.backButton == "member.qrcode.backbutton")
    #expect(MemberAccessibilityID.QRCode.skeleton == "member.qrcode.skeleton")
  }

  @Test("반복 항목 ID는 안정적인 도메인 키를 붙인다")
  func dynamicIdentifiers() {
    #expect(MemberAccessibilityID.schedule(12) == "member.schedule.12")
    #expect(MemberAccessibilityID.dropdownItem("vote") == "member.home.dropdown.item.vote")
    #expect(
      MemberAccessibilityID.Vote.TeamSelect.category("best")
        == "member.vote.teamselect.category.best"
    )
    #expect(
      MemberAccessibilityID.Vote.TeamSelect.reasonField("best")
        == "member.vote.teamselect.category.best.reasonfield"
    )
    #expect(MemberAccessibilityID.Vote.TeamSelect.teamRow(4) == "member.vote.teamselect.team.4")
    #expect(
      MemberAccessibilityID.Vote.Feedback.question("q1")
        == "member.vote.feedback.question.q1"
    )
    #expect(
      MemberAccessibilityID.Vote.Feedback.option("q1", "o2")
        == "member.vote.feedback.question.q1.option.o2"
    )
  }
}
