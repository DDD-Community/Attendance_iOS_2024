//
//  JWTDecoderTests.swift
//  DDDAuthTests
//
//  Created by DDD on 9/1/26.
//

import Foundation
import Testing

@testable import DDDAuth

struct JWTDecoderTests {
  @Test
  func JWT의_exp를_만료시각으로_변환한다() throws {
    let payload = Data(#"{"exp":1893456000}"#.utf8)
      .base64EncodedString()
      .replacingOccurrences(of: "+", with: "-")
      .replacingOccurrences(of: "/", with: "_")
      .replacingOccurrences(of: "=", with: "")
    let token = "header.\(payload).signature"

    let expiration = try #require(JWTDecoder.decodeExpiration(token))

    #expect(expiration == Date(timeIntervalSince1970: 1_893_456_000))
  }

  @Test
  func 잘못된_JWT는_nil을_반환한다() {
    #expect(JWTDecoder.decodeExpiration("invalid") == nil)
  }
}
