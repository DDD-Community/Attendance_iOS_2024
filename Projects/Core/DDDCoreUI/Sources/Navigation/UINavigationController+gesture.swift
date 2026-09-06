//
//  UINavigationController+gesture.swift
//  DDDCoreUI
//
//  Created by DDD on 7/20/24.
//  Interactive-pop restoration adapted from SwiftUIX 0.2.3 CocoaNavigationView (MIT).
//  Copyright (c) 2024 Vatsal Manot.
//

import SwiftUI
import UIKit

extension UINavigationController: UIKit.UIGestureRecognizerDelegate {
  override open func viewDidLoad() {
    super.viewDidLoad()

    restoreInteractivePopGesture()
  }

  public func gestureRecognizerShouldBegin(_: UIGestureRecognizer) -> Bool {
    canBeginInteractivePopGesture
  }

  /// 루트 화면에서는 interactive pop을 막고, 이전 화면이 있을 때만 허용합니다.
  var canBeginInteractivePopGesture: Bool {
    viewControllers.count > 1
  }

  /// SwiftUI가 custom back button을 위해 비활성화한 native pop gesture를 복구합니다.
  func restoreInteractivePopGesture() {
    guard let interactivePopGestureRecognizer else { return }

    interactivePopGestureRecognizer.delegate = self
    interactivePopGestureRecognizer.isEnabled = canBeginInteractivePopGesture
  }
}

public extension View {
  /// Native back button을 숨기면서 edge swipe 뒤로가기는 유지합니다.
  func dddNavigationBarBackButtonHidden(_ isHidden: Bool = true) -> some View {
    modifier(DDDNavigationBackButtonModifier(isHidden: isHidden))
  }
}

private struct DDDNavigationBackButtonModifier: ViewModifier {
  let isHidden: Bool

  func body(content: Content) -> some View {
    content
      .navigationBarBackButtonHidden(isHidden)
      .background {
        if isHidden {
          InteractivePopGestureRestorer()
            .frame(width: .zero, height: .zero)
            .allowsHitTesting(false)
        }
      }
  }
}

private struct InteractivePopGestureRestorer: UIViewControllerRepresentable {
  func makeUIViewController(context _: Context) -> ResolverViewController {
    ResolverViewController()
  }

  func updateUIViewController(_ viewController: ResolverViewController, context _: Context) {
    viewController.restoreGestureWhenReady()
  }

  final class ResolverViewController: UIViewController {
    override func didMove(toParent parent: UIViewController?) {
      super.didMove(toParent: parent)
      restoreGestureWhenReady()
    }

    override func viewDidAppear(_ animated: Bool) {
      super.viewDidAppear(animated)
      restoreGestureWhenReady()
    }

    func restoreGestureWhenReady() {
      DispatchQueue.main.async { [weak self] in
        self?.navigationController?.restoreInteractivePopGesture()
      }
    }
  }
}
