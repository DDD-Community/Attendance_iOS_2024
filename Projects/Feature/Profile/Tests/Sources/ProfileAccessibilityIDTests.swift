//
//  ProfileAccessibilityIDTests.swift
//  ProfileTests
//

import Testing

@testable import Profile

@Suite("Profile accessibility ID")
struct ProfileAccessibilityIDTests {
  @Test("프로필 화면의 Maestro ID 계약")
  func identifiers() {
    #expect(ProfileAccessibilityID.Main.root == "profile.main.root")
    #expect(ProfileAccessibilityID.Main.skeleton == "profile.main.skeleton")
    #expect(ProfileAccessibilityID.Main.card == "profile.main.card")
    #expect(ProfileAccessibilityID.Main.generationEditButton == "profile.main.generationeditbutton")
    #expect(ProfileAccessibilityID.Main.withdrawButton == "profile.main.withdrawbutton")
    #expect(ProfileAccessibilityID.Main.version == "profile.main.version")
    #expect(ProfileAccessibilityID.Main.privacyPolicyButton == "profile.main.privacypolicybutton")
    #expect(ProfileAccessibilityID.Main.backButton == "profile.main.backbutton")
    #expect(ProfileAccessibilityID.Main.infoButton == "profile.main.infobutton")
  }

  @Test("만든 사람들 모달의 Maestro ID 계약")
  func createAppIdentifiers() {
    #expect(ProfileAccessibilityID.CreateApp.root == "profile.createapp.root")
    #expect(ProfileAccessibilityID.CreateApp.closeButton == "profile.createapp.closebutton")
    #expect(ProfileAccessibilityID.CreateApp.feedbackButton == "profile.createapp.feedbackbutton")
  }
}
