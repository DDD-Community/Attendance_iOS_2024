//
//  DDDCoreUITests.swift
//  DDDCoreUITests
//
//  Created by DDD on 9/4/26.
//

import SwiftUI
import Testing
import UIKit

@testable import DDDCoreUI

@Suite("DDDCoreUI", .serialized)
@MainActor
struct DDDCoreUITests {
  @Test("지연 View는 body 평가 전까지 콘텐츠를 만들지 않는다")
  func lazyViewDefersContentConstruction() {
    var constructionCount = 0
    let view = DDDLazyView {
      constructionCount += 1
      return Color.clear
    }

    #expect(constructionCount == 0)
    _ = view.body
    #expect(constructionCount == 1)
  }

  @Test("키보드 종료 API는 first responder가 없어도 안전하다")
  func dismissKeyboardWithoutFirstResponder() {
    Color.clear.dismissKeyboard()
    _ = Color.clear.dismissKeyboardOnTap()
  }

  @Test("SwiftUI Color가 RGB hex를 변환한다")
  func colorHexConversion() {
    let color = UIColor(Color(hex: "#3366CC"))
    var red: CGFloat = 0
    var green: CGFloat = 0
    var blue: CGFloat = 0
    var alpha: CGFloat = 0

    #expect(color.getRed(&red, green: &green, blue: &blue, alpha: &alpha))
    #expect(abs(red - 0.2) < 0.01)
    #expect(abs(green - 0.4) < 0.01)
    #expect(abs(blue - 0.8) < 0.01)
  }

  @Test("UIColor가 RGB hex를 변환한다")
  func uiColorHexConversion() {
    let color = UIColor(hex: "FF8000")
    var red: CGFloat = 0
    var green: CGFloat = 0
    var blue: CGFloat = 0
    var alpha: CGFloat = 0

    #expect(color.getRed(&red, green: &green, blue: &blue, alpha: &alpha))
    #expect(abs(red - 1.0) < 0.01)
    #expect(abs(green - (128.0 / 255.0)) < 0.01)
    #expect(abs(blue) < 0.01)
    #expect(abs(alpha - 1.0) < 0.01)
  }

  @Test("이미지 원형 처리 결과가 원본 크기를 유지한다")
  func roundedImagesPreserveSize() throws {
    let source = UIGraphicsImageRenderer(size: CGSize(width: 20, height: 12)).image { context in
      UIColor.red.setFill()
      context.fill(CGRect(x: 0, y: 0, width: 20, height: 12))
    }

    let rounded = try #require(source.roundedImage())
    let cornered = try #require(source.setRoundedCorners())

    #expect(rounded.size == source.size)
    #expect(cornered.size == source.size)
  }

  @Test("뒤로가기 gesture는 이전 화면이 있을 때만 시작한다")
  func popGestureRequiresPreviousController() {
    let navigationController = UINavigationController(rootViewController: UIViewController())

    #expect(navigationController.canBeginInteractivePopGesture == false)
    navigationController.pushViewController(UIViewController(), animated: false)
    #expect(navigationController.canBeginInteractivePopGesture)
  }

  @Test("SwiftUI가 비활성화한 뒤로가기 gesture를 push 화면에서 복구한다")
  func restoresDisabledPopGestureForPushedController() throws {
    let navigationController = UINavigationController(rootViewController: UIViewController())
    navigationController.pushViewController(UIViewController(), animated: false)

    let gesture = try #require(navigationController.interactivePopGestureRecognizer)
    gesture.isEnabled = false
    gesture.delegate = nil

    navigationController.restoreInteractivePopGesture()

    #expect(gesture.isEnabled)
    #expect((gesture.delegate as AnyObject?) === navigationController)
  }

  @Test("화면 크기 토큰이 main screen 값과 일치한다")
  func screenSizeTokensMatchMainScreen() {
    #expect(UIScreen.screenWidth == UIScreen.main.bounds.width)
    #expect(UIScreen.screenHeight == UIScreen.main.bounds.height)
    #expect(UIScreen.screenSize == UIScreen.main.bounds.size)
  }

}
