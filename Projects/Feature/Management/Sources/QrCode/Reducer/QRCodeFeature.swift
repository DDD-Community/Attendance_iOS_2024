//
//  QRCodeFeature.swift
//  DDDAttendance
//
//  Created by DDD on 6/11/24.
//

import DDDCoreLogger
import Foundation

import DDDSharedUI
import ManagementInterface
import QRCodeDomainInterface

import ComposableArchitecture

@Reducer
public struct QRCodeFeature {
  public init() {}

  @ObservableState
  public struct State: Equatable {
    var scannedText = ""
    var isScanning = true

    var validation: QRValidateEntity?
    var isUseQRCode: Bool = false
    @Presents public var alert: AlertState<AlertAction>?

    public init() {}
  }

  public enum Action: ViewAction, BindableAction {
    case binding(BindingAction<State>)
    case view(View)
    case async(AsyncAction)
    case inner(InnerAction)
    case scope(ScopeAction)
    case delegate(DelegateAction)

  }

  //MARK: - ViewAction
  @CasePathable
  public enum View {
    case stopScanning
  }

  @CasePathable
  public enum ScopeAction {
    case alert(PresentationAction<AlertAction>)
  }

  @CasePathable
  public enum AlertAction {
    case confirmTapped
  }


  //MARK: - AsyncAction 비동기 처리 액션
  public enum AsyncAction: Equatable {
    case qrCodeValidate
  }

  //MARK: - 앱내에서 사용하는 액션
  public enum InnerAction: Equatable {
    case qrCodeValidateResponse(Result<QRValidateEntity, QRCodeError>)
  }

  //MARK: - DelegateAction
  public typealias DelegateAction = QRCodeDelegate

  private struct QRCodeCancel: Hashable {}

  @Dependency(\.mainQueue) var mainQueue

  @Dependency(\.qrCodeUseCase) var qrCodeUseCase

  public var body: some Reducer<State, Action> {
    BindingReducer()
    Reduce { state, action in
      switch action {
      case .binding(_):
        return .none

      case .view(let viewAction):
        return handleViewAction(state: &state, action: viewAction)

      case .async(let asyncAction):
        return handleAsyncAction(state: &state, action: asyncAction)

      case .inner(let innerAction):
        return handleInnerAction(state: &state, action: innerAction)

      case .delegate(let delegateAction):
        return handleDelegateAction(state: &state, action: delegateAction)

        case .scope(let scopeAction):
          switch scopeAction {
          case .alert:
            return .none
          }
      }
    }
    .ifLet(\.$alert, action: \.scope.alert)
  }
}

extension QRCodeFeature {
  private func handleViewAction(
    state: inout State,
    action: View
  ) -> Effect<Action> {
    switch action {
    case .stopScanning:
      state.isScanning = false
      return .none
    }
  }

  private func handleAsyncAction(
    state: inout State,
    action: AsyncAction
  ) -> Effect<Action> {
    switch action {
    case .qrCodeValidate:
      return .run { [
        scannedText = state.scannedText
      ] send in
        let qrCodeValidateResult = await Result {
          try await qrCodeUseCase.qrValidateCheck(from: scannedText)
        }
          .mapError(QRCodeError.from)
        return await send(.inner(.qrCodeValidateResponse(qrCodeValidateResult)))
      }
      .debounce(id: QRCodeCancel(), for: 0.3, scheduler: mainQueue)
    }
  }

  private func handleDelegateAction(
    state _: inout State,
    action: DelegateAction
  ) -> Effect<Action> {
    switch action {
    case .presentBack:
      return .none
    }
  }

  private func handleInnerAction(
    state: inout State,
    action: InnerAction
  ) -> Effect<Action> {
    switch action {
    case .qrCodeValidateResponse(let result):
      switch result {
      case .success(let qrCodeValidateData):
        state.validation = qrCodeValidateData
        state.isUseQRCode = false

        if qrCodeValidateData.isSuccess {
          state.isScanning = false
        }
        return .none


      case .failure(let error):
        DDDLogger.error("qr 검증 실패: \(error.localizedDescription)", category: .network)
        state.isUseQRCode = true
          // 서버에서 온 사용자 친화적 메시지 사용
          let alertTitle: String
          let alertMessage: String

          // 전송 실패는 도메인이 구분하지 않으므로 서버가 준 거절 사유만 따로 보여준다.
          switch error {
          case let .validationFailed(message):
            alertTitle = "QR 출석실패"
            alertMessage = message
          default:
            alertTitle = "QR 인식 실패"
            alertMessage = error.errorDescription ?? "QR 코드를 다시 스캔해 주세요"
          }

          state.alert = AlertState {
            TextState(alertTitle)
          } actions: {
            ButtonState(action: .confirmTapped) {
              TextState("확인")
            }
          } message: {
            TextState(alertMessage)
          }
          return .none
      }

    }
  }
}
