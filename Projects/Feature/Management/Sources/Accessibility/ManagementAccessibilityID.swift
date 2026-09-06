//
//  ManagementAccessibilityID.swift
//  Management
//

import AttendanceDomainInterface
import DDDDesignKit

enum ManagementAccessibilityID {
  enum Staff {
    static let root = "management.staff.root"
    static let skeleton = "management.staff.skeleton"
    static let sectionButton = "management.staff.sectionbutton"
    static let qrButton = "management.staff.qrbutton"
    static let profileButton = "management.staff.profilebutton"
    static let dropdown = "management.staff.dropdown"

    /// `SelectDropDownItem.attendance` 의 rawValue 가 "attandance" 오타라
    /// rawValue 대신 명시적으로 매핑해 테스트 ID 에 오타가 새지 않게 한다.
    static func dropdownItem(_ item: SelectDropDownItem) -> String {
      switch item {
      case .attendance: "management.staff.dropdown.item.attendance"
      case .schedule: "management.staff.dropdown.item.schedule"
      case .vote: "management.staff.dropdown.item.vote"
      }
    }
  }

  enum Attendance {
    static let root = "management.attendance.root"
    static let dateButton = "management.attendance.datebutton"
    static let summary = "management.attendance.summary"
    static let list = "management.attendance.list"
    static let listSkeleton = "management.attendance.list.skeleton"
    static let modal = "management.attendance.modal"
    static let modalStatusButton = "management.attendance.modal.statusbutton"
    static let modalConfirmButton = "management.attendance.modal.confirmbutton"

    static func team(_ teamID: Int) -> String {
      "management.attendance.team.\(teamID)"
    }

    static func card(userID: String) -> String {
      "management.attendance.card.\(userID)"
    }

    static func cardEditButton(userID: String) -> String {
      "\(card(userID: userID)).editbutton"
    }

    static func modalStatus(_ status: AttendanceStatus) -> String {
      "management.attendance.modal.status.\(status.apiKey.lowercased())"
    }
  }

  enum Schedule {
    static let root = "management.schedule.root"
    static let header = "management.schedule.header"
    static let list = "management.schedule.list"
    static let skeleton = "management.schedule.skeleton"

    static func card(_ scheduleID: Int) -> String {
      "management.schedule.card.\(scheduleID)"
    }
  }

  enum Vote {
    static let root = "management.vote.root"
    static let skeleton = "management.vote.skeleton"
    static let statusChip = "management.vote.statuschip"
    static let startButton = "management.vote.startbutton"
    static let endButton = "management.vote.endbutton"
    static let nonParticipantsButton = "management.vote.nonparticipantsbutton"
    static let nonParticipantsModal = "management.vote.nonparticipantsmodal"
  }

  enum QRScanner {
    static let root = "management.qrscanner.root"
    static let closeButton = "management.qrscanner.closebutton"
    static let resultText = "management.qrscanner.resulttext"
  }

  enum ScheduleModal {
    static let root = "management.schedule.modal"
    static let skeleton = "management.schedule.modal.skeleton"
    static let list = "management.schedule.modal.list"
    static let confirmButton = "management.schedule.modal.confirmbutton"

    static func item(_ scheduleID: Int) -> String {
      "management.schedule.modal.item.\(scheduleID)"
    }
  }
}
