//
//  AppDateFormat.swift
//  DDDCoreUtility
//
//  Copyright © 2026 DDD. All rights reserved.
//

import Foundation

public enum AppDateFormat: String, CaseIterable, Sendable {
  case dateTime = "yyyy-MM-dd HH:mm:ss"
  case yearMonthDay = "yyyy-MM-dd"
  case fullKoreanDate = "yyyy년 MM월 dd일"
  case yearMonthDayDotted = "yyyy.MM.dd"
}

private enum AppDateFormatter {
  private static let locale = Locale(identifier: "en_US_POSIX")
  private static let timeZone = TimeZone(identifier: "Asia/Seoul") ?? .gmt
  private static let calendar = Calendar(identifier: .gregorian)

  /// 서버 날짜 문자열 파싱 전용
  static let parser: DateFormatter = {
    let formatter = DateFormatter()
    formatter.locale = locale
    formatter.timeZone = timeZone
    formatter.calendar = calendar
    formatter.dateFormat = AppDateFormat.dateTime.rawValue
    return formatter
  }()

  /// 화면 출력 전용
  private static let formatters: [AppDateFormat: DateFormatter] = Dictionary(
    uniqueKeysWithValues: AppDateFormat.allCases.map { format in
      let formatter = DateFormatter()
      formatter.locale = locale
      formatter.timeZone = timeZone
      formatter.calendar = calendar
      formatter.dateFormat = format.rawValue

      return (format, formatter)
    }
  )

  static subscript(format: AppDateFormat) -> DateFormatter {
    formatters[format]!
  }

  /// DateFormatter가 다른 구분자까지 관대하게 허용하지 않도록 문자열 왕복 결과를 검사한다.
  static func date(from value: String, format: AppDateFormat) -> Date? {
    let formatter = self[format]
    guard let date = formatter.date(from: value), formatter.string(from: date) == value else {
      return nil
    }
    return date
  }

  static func date(
    from value: String,
    format: AppDateFormat,
    timeZone: TimeZone
  ) -> Date? {
    let formatter = DateFormatter()
    formatter.locale = locale
    formatter.timeZone = timeZone
    formatter.calendar = calendar
    formatter.dateFormat = format.rawValue

    guard let date = formatter.date(from: value), formatter.string(from: date) == value else {
      return nil
    }
    return date
  }
}

public extension String {
  var date: Date? {
    guard
      let date = AppDateFormatter.parser.date(from: self),
      AppDateFormatter.parser.string(from: date) == self
    else {
      return nil
    }
    return date
  }

  func date(as format: AppDateFormat) -> Date? {
    return AppDateFormatter.date(from: self, format: format)
  }

  func date(as format: AppDateFormat, timeZone: TimeZone) -> Date? {
    AppDateFormatter.date(from: self, format: format, timeZone: timeZone)
  }
}

public extension Date {
  func formatted(_ format: AppDateFormat) -> String {
    AppDateFormatter[format].string(from: self)
  }

  func formatted(_ format: AppDateFormat, timeZone: TimeZone) -> String {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.timeZone = timeZone
    formatter.calendar = Calendar(identifier: .gregorian)
    formatter.dateFormat = format.rawValue
    return formatter.string(from: self)
  }
}
