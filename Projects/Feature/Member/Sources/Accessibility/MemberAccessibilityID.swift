//
//  MemberAccessibilityID.swift
//  Member
//

enum MemberAccessibilityID {
  static let root = "member.home.root"
  static let skeleton = "member.home.skeleton"
  static let sectionButton = "member.home.sectionbutton"
  static let qrButton = "member.home.qrbutton"
  static let profileButton = "member.home.profilebutton"
  static let attendanceSummary = "member.attendance.summary"
  static let attendanceSummarySkeleton = "member.attendance.summary.skeleton"
  static let scheduleList = "member.schedule.list"
  static let voteRoot = "member.vote.root"
  static let dropdown = "member.home.dropdown"

  static func schedule(_ scheduleID: Int) -> String {
    "member.schedule.\(scheduleID)"
  }

  /// `HomeTab` 은 Reducer 타입이라 Accessibility 네임스페이스에서 참조하지 않고
  /// rawValue 만 받아 ID 를 만든다.
  static func dropdownItem(_ tabRawValue: String) -> String {
    "member.home.dropdown.item.\(tabRawValue)"
  }

  enum Vote {
    static let skeleton = "member.vote.skeleton"

    enum TeamSelect {
      static let root = "member.vote.teamselect.root"
      static let nextButton = "member.vote.teamselect.nextbutton"

      static func category(_ categoryID: String) -> String {
        "member.vote.teamselect.category.\(categoryID)"
      }

      static func reasonField(_ categoryID: String) -> String {
        "member.vote.teamselect.category.\(categoryID).reasonfield"
      }

      static func teamRow(_ teamID: Int) -> String {
        "member.vote.teamselect.team.\(teamID)"
      }
    }

    enum Feedback {
      static let root = "member.vote.feedback.root"
      static let submitButton = "member.vote.feedback.submitbutton"

      static func question(_ questionID: String) -> String {
        "member.vote.feedback.question.\(questionID)"
      }

      static func option(_ questionID: String, _ optionID: String) -> String {
        "member.vote.feedback.question.\(questionID).option.\(optionID)"
      }
    }
  }

  enum QRCode {
    static let root = "member.qrcode.root"
    static let image = "member.qrcode.image"
    static let backButton = "member.qrcode.backbutton"
    static let skeleton = "member.qrcode.skeleton"
  }
}
