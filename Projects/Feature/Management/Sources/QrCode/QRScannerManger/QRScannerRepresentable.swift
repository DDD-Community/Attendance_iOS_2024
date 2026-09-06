//
//  QRScannerRepresentable.swift
//  Presentation
//
//  Created by DDD on 4/6/25.
//

import SwiftUI
import VisionKit

import DDDCoreLogger


struct QRScannerRepresentable: UIViewControllerRepresentable {
  @Binding var shouldStartScanning: Bool
  @Binding var scannedText: String
  var scannAction: () -> Void = {}

  var dataToScanFor: Set<DataScannerViewController.RecognizedDataType>

  // MARK: - Coordinator
  class Coordinator: NSObject, DataScannerViewControllerDelegate {
    var parent: QRScannerRepresentable
    var scanTimeoutTask: DispatchWorkItem?
    var lastScannedText: String?
    var lastScannedTime: Date?

    // 재사용 가능한 백그라운드 큐 (메모리 누수 방지)
    private let timeoutQueue = DispatchQueue(label: "qr.scan.timeout", qos: .background)

    init(_ parent: QRScannerRepresentable) {
      self.parent = parent
    }

    func resetLastScanned() {
      lastScannedText = nil
      lastScannedTime = nil
    }

    // 사용자가 탭했을 때 호출 (원한다면 사용)
    func dataScanner(_ dataScanner: DataScannerViewController, didTapOn item: RecognizedItem) {
      switch item {
      case .text(let text):
        parent.scannedText = text.transcript
      case .barcode(let barcode):
        parent.scannedText = barcode.payloadStringValue ?? "Unable to decode the scanned code"
      default:
        DDDLogger.debug("Unexpected item", category: .attendance)
      }
    }

    // 인식된 아이템이 업데이트될 때 호출됨
    func dataScanner(_ dataScanner: DataScannerViewController,
                     didUpdate items: [RecognizedItem],
                     allItems: [RecognizedItem]) {
      for item in items {
        if case let .barcode(barcode) = item {
          let text = barcode.payloadStringValue ?? ""
          // 최근에 같은 텍스트를 30초 이내에 스캔했다면 무시
          if let lastText = lastScannedText,
             let lastTime = lastScannedTime,
             lastText == text,
             Date().timeIntervalSince(lastTime) < 30 {
            // 30초 이내에는 무시

            DDDLogger.debug("30초 이내 같은 QR 무시: \(text)", category: .attendance)

            continue
          }
          // 새로운 텍스트이거나 30초 지난 경우만 처리
          lastScannedText = text
          lastScannedTime = Date()
          parent.scannedText = text
          Task { @MainActor [weak self] in
            dataScanner.stopScanning()
            self?.parent.shouldStartScanning = false
            self?.parent.scannAction()
          }
          // 30초 후 다시 같은 텍스트 허용 (초기화)
          scanTimeoutTask?.cancel()
          let task = DispatchWorkItem { [weak self] in
            self?.resetLastScanned()
          }
          scanTimeoutTask = task
          timeoutQueue.asyncAfter(deadline: .now() + 15, execute: task)
          break
        }
      }
    }

  }

  // MARK: - UIViewControllerRepresentable
  func makeUIViewController(context: Context) -> DataScannerViewController {
    let dataScannerVC = DataScannerViewController(
      recognizedDataTypes: dataToScanFor,
      qualityLevel: .accurate,
      recognizesMultipleItems: true,
      isHighFrameRateTrackingEnabled: true,
      isPinchToZoomEnabled: true,
      isGuidanceEnabled: true,
      isHighlightingEnabled: true
    )
    dataScannerVC.delegate = context.coordinator
    return dataScannerVC
  }

  func updateUIViewController(_ uiViewController: DataScannerViewController, context: Context) {
    let isScanning = uiViewController.isScanning
    if shouldStartScanning, !isScanning {
      do {
        try uiViewController.startScanning()
      } catch {
        DDDLogger.debug("Failed to start scanning: \(error)", category: .attendance)
      }
    } else if !shouldStartScanning, isScanning {
      uiViewController.stopScanning()
    }
  }

  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }

  // startScanning() 호출을 비동기 함수로 감싸기 위한 래퍼
  private func startScanningAsync(_ uiViewController: DataScannerViewController) async throws {
    try await withCheckedThrowingContinuation { continuation in
      DispatchQueue.main.async {
        do {
          try uiViewController.startScanning()
          continuation.resume(returning: ())
        } catch {
          continuation.resume(throwing: error)
        }
      }
    }
  }
}
