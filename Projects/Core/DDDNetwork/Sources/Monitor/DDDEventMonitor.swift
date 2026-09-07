//
//  DDDEventMonitor.swift
//  DDDNetwork
//
//  Copyright © 2026 DDD. All rights reserved.
//

import Foundation

import DDDCoreLogger

import Alamofire

/// 요청 / 응답 / 에러를 한 덩어리로 묶어 로깅하는 `EventMonitor`.
/// 로깅은 `DDDLogger(.network)` 에 위임 — 정상은 debug, 에러는 error 레벨.
struct DDDEventMonitor: EventMonitor {
  let queue = DispatchQueue(label: "io.DDD.Attendance.network.logger")

  /// 바디 로그 최대 길이 (초과 시 잘라냄)
  private let maxBodyLength = 4096

  // MARK: 요청 생성 실패 (URL / 파라미터 인코딩 등 — 전송 전)

  func request(_: Request, didFailToCreateURLRequestWithError error: AFError) {
    DDDLogger.error("❌ [요청 생성 실패] \(error.localizedDescription)", category: .network)
  }

  // MARK: 요청 + 응답 (응답 시점에 한 덩어리로 묶어서 로깅)

  func request(
    _: DataRequest,
    didParseResponse response: DataResponse<some Sendable, AFError>
  ) {
    let urlRequest = response.request
    let method = urlRequest?.httpMethod ?? "?"
    let url = urlRequest?.url?.absoluteString ?? "?"
    let status = response.response?.statusCode ?? -1
    let milliseconds = Int((response.metrics?.taskInterval.duration ?? 0) * 1000)
    let isFailure = response.error != nil

    var lines = ["\(isFailure ? "❌" : "✅") \(method) \(url) → \(status) (\(milliseconds)ms)"]

    // ── 요청 ──
    if let headers = urlRequest?.allHTTPHeaderFields, !headers.isEmpty {
      lines.append("  · Request Headers\n\(format(headers))")
    }
    if let body = urlRequest?.httpBody, !body.isEmpty {
      lines.append("  · Request Body\n\(indent(prettyBody(body)))")
    }

    // ── 응답 ──
    if let error = response.error {
      if case let .responseSerializationFailed(.decodingFailed(underlying)) = error,
         let decodingError = underlying as? DecodingError
      {
        lines.append(describe(decodingError))
      } else {
        lines.append("  · Error\n       \(error.localizedDescription)")
        if let underlying = error.underlyingError {
          lines.append("       underlying: \(underlying.localizedDescription)")
        }
      }
    }
    if let data = response.data, !data.isEmpty {
      lines.append("  · Response Body\n\(indent(prettyBody(data)))")
    }

    let message = lines.joined(separator: "\n")
    if isFailure {
      DDDLogger.error(message, category: .network)
    } else {
      DDDLogger.debug(message, category: .network)
    }
  }
}

private extension DDDEventMonitor {
  /// `DecodingError` 를 "종류 · 위치 · 상세" 세 줄로 정리한다.
  /// 원시 Response Body 와 분리해 무엇이 왜 틀렸는지만 짚는다.
  func describe(_ error: DecodingError) -> String {
    func location(_ context: DecodingError.Context, key: String? = nil) -> String {
      var parts = context.codingPath.map(\.stringValue)
      if let key { parts.append(key) }
      return parts.isEmpty ? "(root)" : parts.joined(separator: ".")
    }

    let kind: String
    let place: String
    let detail: String
    switch error {
    case let .keyNotFound(key, context):
      kind = "keyNotFound"
      place = location(context, key: key.stringValue)
      detail = "'\(key.stringValue)' 키가 응답에 없음"
    case let .typeMismatch(type, context):
      kind = "typeMismatch"
      place = location(context)
      detail = "기대 타입 \(type)"
    case let .valueNotFound(type, context):
      kind = "valueNotFound"
      place = location(context)
      detail = "\(type) 필수인데 null"
    case let .dataCorrupted(context):
      kind = "dataCorrupted"
      place = location(context)
      detail = context.debugDescription
    @unknown default:
      kind = "unknown"
      place = "-"
      detail = String(describing: error)
    }

    return [
      "  · Decoding Error",
      "       종류: \(kind)",
      "       위치: \(place)",
      "       상세: \(detail)"
    ].joined(separator: "\n")
  }

  /// 헤더를 정렬해 한 줄씩 들여쓰기.
  func format(_ headers: [String: String]) -> String {
    headers
      .sorted { $0.key < $1.key }
      .map { "       \($0.key): \($0.value)" }
      .joined(separator: "\n")
  }

  /// 여러 줄 텍스트를 들여쓰기 (바디 블록 정렬용).
  func indent(_ text: String) -> String {
    text.split(separator: "\n", omittingEmptySubsequences: false)
      .map { "       \($0)" }
      .joined(separator: "\n")
  }

  /// JSON 이면 pretty-print, 아니면 UTF-8 문자열. 길면 잘라낸다.
  func prettyBody(_ data: Data) -> String {
    let text: String = if let object = try? JSONSerialization.jsonObject(with: data),
                          let pretty = try? JSONSerialization.data(
                            withJSONObject: object,
                            options: [.prettyPrinted, .withoutEscapingSlashes]
                          ),
                          let string = String(data: pretty, encoding: .utf8)
    {
      string
    } else {
      String(data: data, encoding: .utf8) ?? "<\(data.count) bytes>"
    }
    guard text.count > maxBodyLength else { return text }
    return text.prefix(maxBodyLength) + "… (truncated)"
  }
}
