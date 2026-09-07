//
//  FirebaseConfiguration.swift
//  DDDConfig
//

import Foundation

import FirebaseCore

/// Firebase SDK 부팅. 설정값은 앱 번들의 GoogleService-Info.plist 에서 읽는다.
///
/// Firebase 심볼은 이 모듈 밖으로 내보내지 않는다. 재수출하면 의존하지 않은 모듈까지
/// Firebase 를 쓸 수 있게 되어 DDDThirdParty 같은 umbrella 가 다시 생긴다.
public enum FirebaseConfiguration {
  public static func configure() {
    FirebaseApp.configure()
  }
}
