//
//  Modules.swift
//  Plugins
//
//  레이어별 모듈 카탈로그(단일 출처).
//  모듈 추가 = case 한 줄. rawValue 가 실제 타깃명이라 오타로 깨지지 않는다.
//

import Foundation
import ProjectDescription

public enum FeatureModule: String, CaseIterable {
  case sharedUI = "FeatureSharedUI"
  case auth = "Auth"
  case management = "Management"
  case profile = "Profile"
  case member = "Member"
  case onBoarding = "OnBoarding"
  case web = "Web"

  /// Projects/Feature/<name>
  var path: Path {
    return .relativeToFeature(rawValue)
  }
}

public enum CoreModule: String, CaseIterable {
  case assembly = "CoreAssembly"
  case logger = "DDDCoreLogger"
  case network = "DDDNetwork"
  case storage = "DDDStorage"
  case coreUI = "DDDCoreUI"
  case coreUtility = "DDDCoreUtility"
  case thirdParty = "DDDThirdParty"

  /// Projects/Core/<name>
  var path: Path {
    return .relativeToCore(rawValue)
  }
}

public enum ServiceModule: String, CaseIterable {
  case accessibility = "DDDAccessibility"
  case assembly = "ServiceAssembly"
  case api = "API"
  case apiEndpoint = "APIEndpoint"
  case auth = "DDDAuth"

  /// Projects/Service/<name>
  var path: Path {
    return .relativeToService(rawValue)
  }
}

public enum DomainModule: String, CaseIterable {
  case assembly = "DomainAssembly"
  case appUpdate = "AppUpdateDomain"
  case auth = "AuthDomain"
  case attendance = "AttendanceDomain"
  case myPage = "MyPageDomain"
  case onBoarding = "OnBoardingDomain"
  case profile = "ProfileDomain"
  case qrCode = "QRCodeDomain"
  case schedule = "ScheduleDomain"
  case vote = "VoteDomain"
  /// Projects/Domain/<name>
  var path: Path {
    return .relativeToDomain(rawValue)
  }
}

public enum UIModule: String, CaseIterable {
  case animation = "DDDAnimation"
  case designKit = "DDDDesignKit"
  case sharedUI = "DDDSharedUI"

  /// Projects/UI/<name>
  var path: Path {
    return .relativeToUI(rawValue)
  }
}
