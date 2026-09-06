//
//  QRScannerView.swift
//  DDDAttendance
//
//  Created by DDD on 6/11/24.
//

import SwiftUI

import DDDAccessibility
import DDDDesignKit

import AttendanceDomainInterface
import ComposableArchitecture

struct QRScannerView: View {
  private let scannerSize: CGFloat = 240
  @Bindable var store: StoreOf<QRCodeFeature>

  init(store: StoreOf<QRCodeFeature>) {
    self.store = store
  }

  var body: some View {
    ZStack {
      // 1. 카메라 미리보기 + 데이터 스캐너
      qrScanningView()

      scanedTextViewWithBackGround()

      // 3. 왼쪽 상단 닫기 버튼
      navigationBar()
    }
    .accessibilityElement(children: .contain)
    .dddAccessibilityID(ManagementAccessibilityID.QRScanner.root)
    .onChange(of: store.scannedText) { _, newValue in
      // 스캔된 텍스트가 업데이트되면, 15초 후에 재스캔을 위해 상태 재활성화
      if !newValue.isEmpty {
        _Concurrency.Task {
          try? await _Concurrency.Task.sleep(for: .seconds(10)) // 15초 → 10초로 사용자 경험 개선
          await MainActor.run {
            store.scannedText = ""
            store.isScanning = true
          }
        }
      }
    }
    .alert($store.scope(state: \.alert, action: \.scope.alert))
    .onChange(of: store.validation?.isSuccess) { _, newValue in
      switch newValue {
      case true:
        _Concurrency.Task {
          try? await _Concurrency.Task.sleep(for: .seconds(0.8)) // 1초 → 0.8초로 반응성 개선
          await MainActor.run {
            store.send(.delegate(.presentBack))
          }
        }
      default:
        break
      }
    }
  }
}

private extension QRScannerView {
  @ViewBuilder
  func navigationBar() -> some View {
    VStack {
      HStack {
        Button {
          store.send(.delegate(.presentBack))
        } label: {
          Image(asset: .closeGray)
            .resizable()
            .scaledToFit()
            .frame(width: 36, height: 36)
        }
        .dddAccessibilityID(ManagementAccessibilityID.QRScanner.closeButton)
        Spacer()
      }
      Spacer()
    }
    .padding(24)
  }

  @ViewBuilder
  func qrScanningView() -> some View {
    QRScannerRepresentable(
      shouldStartScanning: $store.isScanning,
      scannedText: $store.scannedText,
      scannAction: {
        store.send(.async(.qrCodeValidate))
      },
      dataToScanFor: [.barcode(symbologies: [.qr])]
    )
    .ignoresSafeArea()
  }

  @ViewBuilder
  func scanedTextViewWithBackGround() -> some View {
    let attendanceStatus = store.validation?.status
    GeometryReader { proxy in
      let width = proxy.size.width
      let height = proxy.size.height
      // 화면 중앙에 scannerSize 크기의 네모 영역을 배치하기 위한 좌표 계산
      let rectX = (width - scannerSize) / 2
      let rectY = (height - scannerSize) / 2

      // (A) 반투명 오버레이 + 중앙 네모 영역은 투명하게
      Color.basicBlack.opacity(0.5)
        .mask(
          ZStack {
            Rectangle() // 전체 화면 채움
            RoundedRectangle(cornerRadius: 12)
              .frame(width: scannerSize, height: scannerSize)
              .position(
                x: rectX + scannerSize / 2,
                y: rectY + scannerSize / 2
              )
              .blendMode(.destinationOut)
          }
        )
        .compositingGroup()
        .ignoresSafeArea()

      // (B) 안내 문구 (네모 영역 위쪽에 배치)
      scanText(attendanceType: attendanceStatus)
        .dddAccessibilityID(ManagementAccessibilityID.QRScanner.resultText)
        .position(x: width / 2, y: rectY - 30)
    }
  }

  @ViewBuilder
  func scanText(
    attendanceType: AttendanceStatus?
  ) -> some View {
    switch attendanceType {
    case .attended:
      HStack(spacing: .zero) {
        Spacer()
        Image(asset: .qrCheck)
          .resizable()
          .scaledToFit()
          .frame(width: 24, height: 24)

        Spacer()
          .frame(width: 4)

        Text("출석이 완료됐어요!")
          .dddFont(.body1NormalMedium)
          .foregroundColor(.staticWhite)

        Spacer()
      }
    case .late:
      HStack(spacing: .zero) {
        Spacer()
        Image(asset: .qrCheck)
          .resizable()
          .scaledToFit()
          .frame(width: 24, height: 24)

        Spacer()
          .frame(width: 4)

        Text("10분 초과로 지각이에요")
          .dddFont(.body1NormalMedium)
          .foregroundColor(.staticWhite)
          .dddFont(.body1NormalMedium)

        Spacer()
      }
    case .absent:
      HStack(spacing: .zero) {
        Spacer()
        Image(asset: .qrCheck)
          .resizable()
          .scaledToFit()
          .frame(width: 24, height: 24)

        Spacer()
          .frame(width: 4)

        Text("30분 초과로 결석이에요")
          .dddFont(.body1NormalMedium)
          .foregroundColor(.staticWhite)

        Spacer()
      }
    default:
      Text(store.isUseQRCode ? "이미 사용된 QR 코드입니다." : "QR 코드를 스캔해 주세요")
        .dddFont(.body1NormalMedium)
        .foregroundColor(.staticWhite)
    }
  }
}
