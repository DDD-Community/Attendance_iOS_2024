//
//  SelectDropDownItem.swift
//  Presentation
//
//  Created by DDD on 1/16/25.
//

import Foundation

public enum SelectDropDownItem: String, CaseIterable, Codable {
  case attendance = "attandance"
  case schedule
  case vote
  
  public var desc: String {
    switch self {
    case .attendance:
      return "출석"
    case .schedule:
      return "일정"
    case .vote:
      return "투표"
    }
  }
  
  public static var item: [String] {
    SelectDropDownItem.allCases.map { $0.desc }
  }
}
