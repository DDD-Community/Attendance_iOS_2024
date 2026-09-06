//
//  WebRepresentableView.swift
//  Profile
//
//  Created by DDD on 1/4/26.
//

import SwiftUI
import WebKit

import DDDAnimation
import DDDDesignKit


public struct WebRepresentableView: UIViewRepresentable {

  // MARK: - URL to load
  private var urlToLoad: String

  public init(urlToLoad: String) {
    self.urlToLoad = urlToLoad
  }

  public func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }

  public func makeUIView(context: Context) -> UIView {
    // 컨테이너
    let containerView = UIView()
    containerView.backgroundColor = UIColor(red: 26/255.0, green: 26/255.0, blue: 26/255.0, alpha: 1.0)

    // WKWebView
    let configuration = WKWebViewConfiguration()
    let webView = WKWebView(frame: .zero, configuration: configuration)
    webView.scrollView.showsVerticalScrollIndicator = false
    webView.scrollView.minimumZoomScale = 1.0
    webView.scrollView.maximumZoomScale = 1.0
    webView.navigationDelegate = context.coordinator
    webView.uiDelegate = context.coordinator
    webView.allowsLinkPreview = true
    webView.backgroundColor = UIColor(red: 26/255.0, green: 26/255.0, blue: 26/255.0, alpha: 1.0)
    webView.translatesAutoresizingMaskIntoConstraints = false

    // AnimatedImage로 로딩 GIF 표시
    let loadingContainer = createAnimatedImageLoader(coordinator: context.coordinator)
    loadingContainer.translatesAutoresizingMaskIntoConstraints = false

    containerView.addSubview(webView)
    containerView.addSubview(loadingContainer)

    NSLayoutConstraint.activate([
      // WebView는 전체
      webView.topAnchor.constraint(equalTo: containerView.topAnchor),
      webView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
      webView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
      webView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),

      // 로딩 컨테이너는 중앙
      loadingContainer.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
      loadingContainer.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
      loadingContainer.widthAnchor.constraint(equalToConstant: 200),
      loadingContainer.heightAnchor.constraint(equalToConstant: 200),
    ])

    // 코디네이터가 참조 보관
    context.coordinator.webView = webView
    context.coordinator.loadingIndicator = loadingContainer

    // 로드 직전에 로딩 컨테이너 표시
    loadingContainer.alpha = 1

    // 로드
    _Concurrency.Task {
      await loadURLInWebView(urlToLoad: urlToLoad, webView: webView)
    }

    return containerView
  }

  func loadURLInWebView(urlToLoad: String, webView: WKWebView) async {
    guard let url = URL(string: urlToLoad) else {
      return
    }
    let request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy)

    await MainActor.run {
      webView.configuration.upgradeKnownHostsToHTTPS = true
      webView.configuration.preferences.minimumFontSize = 16
      webView.load(request)
    }
  }

  public func updateUIView(_ uiView: UIView, context: Context) {
    // 필요 시 업데이트
  }

  // MARK: - AnimatedImage Loading Helper Functions

  private func createAnimatedImageLoader(coordinator: Coordinator) -> UIView {
    let containerView = UIView()
    containerView.backgroundColor = .clear

    // SwiftUI AnimatedImage를 UIKit에 임베드 - 조건부 애니메이션으로 메모리 최적화
    let animatedImageView = UIHostingController(rootView: AnyView(
      DDDAnimationView(.loading, isAnimating: .constant(true))
        .frame(width: 200, height: 200)
        .opacity(1) // alpha로 제어될 가시성에 맞춰 애니메이션 효율성 확보
    ))

    // Coordinator에서 강한 참조로 보관 (메모리 누수 방지)
    coordinator.animatedImageController = animatedImageView

    animatedImageView.view.backgroundColor = .clear
    animatedImageView.view.translatesAutoresizingMaskIntoConstraints = false

    containerView.addSubview(animatedImageView.view)

    NSLayoutConstraint.activate([
      animatedImageView.view.topAnchor.constraint(equalTo: containerView.topAnchor),
      animatedImageView.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
      animatedImageView.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
      animatedImageView.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
    ])

    return containerView
  }

  // MARK: - Coordinator
  public class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
    var parent: WebRepresentableView
    weak var webView: WKWebView?
    weak var loadingIndicator: UIView?

    // UIHostingController 메모리 누수 방지를 위한 강한 참조 보관
    var animatedImageController: UIHostingController<AnyView>?

    init(_ parent: WebRepresentableView) {
      self.parent = parent
    }

    deinit {
      // 메모리 정리
      animatedImageController?.willMove(toParent: nil)
      animatedImageController?.view.removeFromSuperview()
      animatedImageController?.removeFromParent()
      animatedImageController = nil
    }

    // MARK: - WKNavigationDelegate

    public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
      // 로딩 시작 → AnimatedImage 표시 (MainActor 최적화)
      Task { @MainActor [weak self] in
        guard let self = self, let loadingIndicator = self.loadingIndicator else { return }
        loadingIndicator.alpha = 1
      }
    }

    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
      // 로딩 완료 → AnimatedImage 숨김(페이드아웃)
      hideLoadingIndicator()
    }

    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
      hideLoadingIndicator()
    }

    public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
      hideLoadingIndicator()
    }

    private func hideLoadingIndicator() {
      Task { @MainActor [weak self] in
        guard let self = self, let loadingIndicator = self.loadingIndicator else { return }

        UIView.animate(withDuration: 0.3, animations: {
          loadingIndicator.alpha = 0
        })
      }
    }
  }
}
