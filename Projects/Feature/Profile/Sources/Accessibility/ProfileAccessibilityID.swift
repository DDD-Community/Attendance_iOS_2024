//
//  ProfileAccessibilityID.swift
//  Profile
//

enum ProfileAccessibilityID {
  enum Main {
    static let root = "profile.main.root"
    static let skeleton = "profile.main.skeleton"
    static let card = "profile.main.card"
    static let generationEditButton = "profile.main.generationeditbutton"
    static let withdrawButton = "profile.main.withdrawbutton"
    static let version = "profile.main.version"
    static let privacyPolicyButton = "profile.main.privacypolicybutton"
    static let backButton = "profile.main.backbutton"
    /// 우측 상단 info 버튼. "만든 사람들" 모달을 연다.
    static let infoButton = "profile.main.infobutton"
  }

  enum CreateApp {
    static let root = "profile.createapp.root"
    static let closeButton = "profile.createapp.closebutton"
    /// 설계 문서의 `confirmButton` 자리다. 실제 화면의 확인 동작은 "앱 피드백 남기기" 뿐이라
    /// 이름을 화면에 맞춘다.
    static let feedbackButton = "profile.createapp.feedbackbutton"
  }
}
