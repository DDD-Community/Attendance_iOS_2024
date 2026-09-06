//
//  AppDelegate+Configuration.swift
//  DDDAttendance
//
//  앱 기동 시 초기화. 관심사별 configureX() 로 나눠 두고 configure() 가 순서대로 호출한다.
//  DI 는 각 모듈이 스스로 등록하므로(어셈블리 레이어) 여기서 컨테이너를 부트스트랩하지 않는다.
//

import Foundation

import DDDConfig
import DDDDesignKit

extension AppDelegate {
  func configure() {
    configureFonts()
    configureFirebase()
  }

  func configureFonts() {
    PretendardFontFamily.registerFonts()
  }

  func configureFirebase() {
    FirebaseConfiguration.configure()
  }
}
