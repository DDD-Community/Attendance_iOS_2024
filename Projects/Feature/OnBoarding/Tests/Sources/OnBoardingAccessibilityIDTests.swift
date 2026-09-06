//
//  OnBoardingAccessibilityIDTests.swift
//  OnBoardingTests
//

import Testing

@testable import OnBoarding

@Suite("OnBoarding accessibility ID")
struct OnBoardingAccessibilityIDTests {
  @Test("온보딩 각 단계의 고정 ID 계약")
  func fixedIdentifiers() {
    #expect(OnBoardingAccessibilityID.Name.root == "onboarding.name.root")
    #expect(OnBoardingAccessibilityID.Name.textField == "onboarding.name.textfield")
    #expect(OnBoardingAccessibilityID.Name.nextButton == "onboarding.name.nextbutton")
    #expect(OnBoardingAccessibilityID.SelectTeam.root == "onboarding.selectteam.root")
    #expect(OnBoardingAccessibilityID.SelectTeam.list == "onboarding.selectteam.list")
    #expect(OnBoardingAccessibilityID.SelectTeam.skeleton == "onboarding.selectteam.skeleton")
    #expect(OnBoardingAccessibilityID.SelectTeam.nextButton == "onboarding.selectteam.nextbutton")
    #expect(OnBoardingAccessibilityID.SelectPart.root == "onboarding.selectpart.root")
    #expect(OnBoardingAccessibilityID.SelectPart.list == "onboarding.selectpart.list")
    #expect(OnBoardingAccessibilityID.SelectPart.skeleton == "onboarding.selectpart.skeleton")
    #expect(OnBoardingAccessibilityID.SelectPart.nextButton == "onboarding.selectpart.nextbutton")
    #expect(OnBoardingAccessibilityID.SelectManaging.root == "onboarding.selectmanaging.root")
    #expect(OnBoardingAccessibilityID.SelectManaging.list == "onboarding.selectmanaging.list")
    #expect(OnBoardingAccessibilityID.SelectManaging.skeleton == "onboarding.selectmanaging.skeleton")
    #expect(OnBoardingAccessibilityID.SelectManaging.nextButton == "onboarding.selectmanaging.nextbutton")
    #expect(OnBoardingAccessibilityID.InviteCode.root == "onboarding.invitecode.root")
    #expect(OnBoardingAccessibilityID.InviteCode.backButton == "onboarding.invitecode.backbutton")
    #expect(OnBoardingAccessibilityID.InviteCode.confirmButton == "onboarding.invitecode.confirmbutton")
  }

  @Test("반복 항목 ID는 안정적인 도메인 키를 붙인다")
  func dynamicIdentifiers() {
    #expect(OnBoardingAccessibilityID.SelectTeam.item(3) == "onboarding.selectteam.item.3")
    #expect(OnBoardingAccessibilityID.SelectPart.item("iOS") == "onboarding.selectpart.item.iOS")
    #expect(
      OnBoardingAccessibilityID.SelectManaging.item("TEAM_MANAGING")
        == "onboarding.selectmanaging.item.TEAM_MANAGING"
    )
    #expect(
      OnBoardingAccessibilityID.InviteCode.textField("first")
        == "onboarding.invitecode.textfield.first"
    )
  }
}
