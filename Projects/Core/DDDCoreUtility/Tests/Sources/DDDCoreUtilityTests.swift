//
//  DDDCoreUtilityTests.swift
//  DDDCoreUtilityTests
//
//  Created by DDD on 9/4/26.
//

import Foundation
import Testing

@testable import DDDCoreUtility

@Suite("DDDCoreUtility 날짜 포맷")
struct AppDateFormatTests {
  @Test("서버 날짜 문자열을 서울 시간 기준 Date로 파싱한다")
  func parsesServerDateStringUsingSeoulTimeZone() throws {
    let date = try #require("2026-09-01 09:30:00".date)

    let timestamp = date.timeIntervalSince1970

    #expect(timestamp == 1_788_222_600)
  }

  @Test("Date를 yyyy-MM-dd 포맷으로 변환한다")
  func formatsDateAsYearMonthDay() {
    let date = Date(timeIntervalSince1970: 1_788_222_600)

    let formatted = date.formatted(.yearMonthDay)

    #expect(formatted == "2026-09-01")
  }

  @Test("지정된 포맷과 맞지 않는 문자열은 파싱하지 않는다")
  func returnsNilWhenDateFormatDoesNotMatch() {
    let date = "2026/09/01".date(as: .yearMonthDay)

    #expect(date == nil)
  }

  @Test("지정한 타임존의 자정으로 날짜를 파싱한다")
  func parsesDateUsingProvidedTimeZone() throws {
    let timeZone = try #require(TimeZone(identifier: "America/Los_Angeles"))
    let date = try #require("2026-09-05".date(as: .yearMonthDay, timeZone: timeZone))
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = timeZone

    let components = calendar.dateComponents([.year, .month, .day, .hour], from: date)
    #expect(components.year == 2026)
    #expect(components.month == 9)
    #expect(components.day == 5)
    #expect(components.hour == 0)
  }
}

@Suite("DDDCoreUtility QR 문자열")
struct QRCodeValueTests {
  @Test("QR 값은 사용자, 이벤트, 시작 시간, 30분 연장된 종료 시간을 포함한다")
  func includesUserEventStartTimeAndExtendedEndTime() {
    let startTime = Date(timeIntervalSince1970: 1_788_222_600)
    let endTime = Date(timeIntervalSince1970: 1_788_226_200)

    let value = String.makeQrCodeValue(
      userID: "user-1",
      eventID: "event-1",
      startTime: startTime,
      endTime: endTime
    )

    let fields = value.split(separator: "+", omittingEmptySubsequences: false)
    #expect(fields.count == 4)
    #expect(fields[0] == "user-1")
    #expect(fields[1] == "event-1")
    #expect(String(fields[2]) == startTime.formatted(.dateTime))
    #expect(String(fields[3]) == endTime.addingTimeInterval(1800).formatted(.dateTime))
  }
}

@Suite("DDDCoreUtility JWT")
struct JWTUtilsTests {
  @Test("JWT payload에서 만료 시간을 Date로 추출한다")
  func extractsExpirationDateFromJWT() throws {
    let token = makeJWT(payload: ["exp": 1_788_222_600])

    let expirationDate = try #require(JWTUtils.expirationDate(from: token))

    #expect(expirationDate.timeIntervalSince1970 == 1_788_222_600)
  }

  @Test("JWT payload에서 문자열 필드를 추출한다")
  func extractsStringValueFromPayload() throws {
    let token = makeJWT(payload: ["type": "manager"])

    let userType: String = try #require(JWTUtils.getUserType(from: token))

    #expect(userType == "manager")
  }

  @Test("base64url padding 없는 JWT payload를 디코딩한다")
  func decodesBase64URLPayloadWithoutPadding() throws {
    let token = makeJWT(payload: ["type": "member", "name": "DDD"])

    let payload = try #require(JWTUtils.decodePayload(from: token))

    #expect(payload["type"] as? String == "member")
    #expect(payload["name"] as? String == "DDD")
  }

  @Test("형식이 맞지 않는 JWT는 payload를 반환하지 않는다")
  func returnsNilForMalformedJWT() {
    let payload = JWTUtils.decodePayload(from: "header.payload")

    #expect(payload == nil)
  }

  @Test("만료 시간이 지난 JWT는 만료 상태로 판단한다")
  func marksExpiredTokenAsExpired() {
    let token = makeJWT(payload: ["exp": 1])

    #expect(JWTUtils.isExpired(token))
  }

  @Test("만료 시간을 읽을 수 없는 JWT는 만료 상태로 판단한다")
  func marksTokenWithoutExpirationAsExpired() {
    let token = makeJWT(payload: ["type": "member"])

    #expect(JWTUtils.isExpired(token))
  }
}

private func makeJWT(payload: [String: Any]) -> String {
  let header = ["alg": "none", "typ": "JWT"]
  return [
    base64URLEncodedJSONObject(header),
    base64URLEncodedJSONObject(payload),
    "signature"
  ].joined(separator: ".")
}

private func base64URLEncodedJSONObject(_ object: [String: Any]) -> String {
  let data = try! JSONSerialization.data(withJSONObject: object, options: [.sortedKeys])
  return data
    .base64EncodedString()
    .replacingOccurrences(of: "+", with: "-")
    .replacingOccurrences(of: "/", with: "_")
    .replacingOccurrences(of: "=", with: "")
}
