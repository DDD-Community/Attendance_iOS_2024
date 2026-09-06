//
//  ManagementQRCodeReducerTests.swift
//  ManagementTests
//
//  Created by DDD on 2026-09-03.
//
//  QRCodeFeature 의 view / binding / async / inner / scope 분기를 TestStore 로 훑는다.
//

import ComposableArchitecture
import Testing

@testable import Management

@MainActor
@Suite("ManagementQRCode")
struct ManagementQRCodeReducerTests {
  @Test("초기 상태는 스캔 중이고 검증 결과가 비어 있다")
  func initialStateIsScanning() {
    let state = QRCodeFeature.State()

    #expect(state.isScanning)
    #expect(state.scannedText.isEmpty)
    #expect(state.validation == nil)
    #expect(state.isUseQRCode == false)
  }

  @Test("stopScanning 은 스캔 상태를 끈다")
  func stopScanningTurnsOffScanning() async {
    let store = TestStore(initialState: QRCodeFeature.State()) {
      QRCodeFeature()
    }

    await store.send(.view(.stopScanning)) {
      $0.isScanning = false
    }
  }

  @Test("scannedText 바인딩은 스캔한 문자열을 보관한다")
  func bindingStoresScannedText() async {
    let store = TestStore(initialState: QRCodeFeature.State()) {
      QRCodeFeature()
    }

    await store.send(.binding(.set(\.scannedText, "qr-payload"))) {
      $0.scannedText = "qr-payload"
    }
  }

  @Test("검증에 성공하면 결과를 담고 스캔을 멈춘다")
  func validateSuccessStopsScanning() async {
    var stub = ManagementSupportQRCodeUseCase()
    stub.validateResult = .success(ManagementSupportFixture.qrValidateSuccess)

    let store = TestStore(initialState: QRCodeFeature.State()) {
      QRCodeFeature()
    } withDependencies: {
      $0.qrCodeUseCase = stub
      $0.mainQueue = .immediate
    }

    await store.send(.binding(.set(\.scannedText, "qr-payload"))) {
      $0.scannedText = "qr-payload"
    }

    await store.send(.async(.qrCodeValidate))

    await store.receive(\.inner) {
      $0.validation = ManagementSupportFixture.qrValidateSuccess
      $0.isUseQRCode = false
      $0.isScanning = false
    }
  }

  @Test("검증 응답이 실패 플래그면 스캔을 멈추지 않는다")
  func validateUnsuccessfulKeepsScanning() async {
    var stub = ManagementSupportQRCodeUseCase()
    stub.validateResult = .success(ManagementSupportFixture.qrValidateFailure)

    let store = TestStore(initialState: QRCodeFeature.State()) {
      QRCodeFeature()
    } withDependencies: {
      $0.qrCodeUseCase = stub
      $0.mainQueue = .immediate
    }

    await store.send(.async(.qrCodeValidate))

    await store.receive(\.inner) {
      $0.validation = ManagementSupportFixture.qrValidateFailure
      $0.isUseQRCode = false
    }
  }

  @Test("검증 호출이 실패하면 인식 실패 알럿을 띄운다")
  func validateThrowShowsScanFailureAlert() async {
    var stub = ManagementSupportQRCodeUseCase()
    stub.validateResult = .failure(.validationFailed("검증 실패"))

    let store = TestStore(initialState: QRCodeFeature.State()) {
      QRCodeFeature()
    } withDependencies: {
      $0.qrCodeUseCase = stub
      $0.mainQueue = .immediate
    }

    await store.send(.async(.qrCodeValidate))

    await store.receive(\.inner) {
      $0.isUseQRCode = true
      $0.alert = AlertState {
        TextState("QR 출석실패")
      } actions: {
        ButtonState(action: .confirmTapped) {
          TextState("확인")
        }
      } message: {
        TextState("검증 실패")
      }
    }
  }

  @Test("validationFailed 에러는 서버 메시지를 그대로 알럿에 싣는다")
  func validationFailedErrorShowsServerMessage() async {
    let store = TestStore(initialState: QRCodeFeature.State()) {
      QRCodeFeature()
    }

    await store.send(.inner(.qrCodeValidateResponse(.failure(.validationFailed("이미 출석했습니다"))))) {
      $0.isUseQRCode = true
      $0.alert = AlertState {
        TextState("QR 출석실패")
      } actions: {
        ButtonState(action: .confirmTapped) {
          TextState("확인")
        }
      } message: {
        TextState("이미 출석했습니다")
      }
    }
  }

  @Test("알럿 확인을 누르면 알럿이 닫힌다")
  func alertConfirmDismissesAlert() async {
    var state = QRCodeFeature.State()
    state.alert = AlertState {
      TextState("QR 인식 실패")
    } actions: {
      ButtonState(action: .confirmTapped) {
        TextState("확인")
      }
    }

    let store = TestStore(initialState: state) {
      QRCodeFeature()
    }

    await store.send(.scope(.alert(.presented(.confirmTapped)))) {
      $0.alert = nil
    }
  }

  @Test("알럿 dismiss 는 알럿 상태만 비운다")
  func alertDismissClearsState() async {
    var state = QRCodeFeature.State()
    state.alert = AlertState {
      TextState("QR 인식 실패")
    } actions: {
      ButtonState(action: .confirmTapped) {
        TextState("확인")
      }
    }

    let store = TestStore(initialState: state) {
      QRCodeFeature()
    }

    await store.send(.scope(.alert(.dismiss))) {
      $0.alert = nil
    }
  }
}
