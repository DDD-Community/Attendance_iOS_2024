//
//  NetworkClient.swift
//  DDDNetwork
//
//  Copyright © 2026 DDD. All rights reserved.
//

import Foundation

import DDDNetworkInterface

import Alamofire

/// Alamofire 기반 `DDDNetworkClient` 구현.
///
/// 출석 서버는 성공 응답을 공통 래퍼 없이 페이로드 그대로 내려주고,
/// 실패는 HTTP status + `{ code, message }` 바디로 알린다.
/// 그래서 성공/실패 판정 기준은 HTTP status 이며, 성공 바디는 곧바로 `R.Response` 로 디코딩한다.
final class NetworkClient: DDDNetworkClient {
  /// 바디가 비어도 성공으로 볼 status. (201 Created / 202 Accepted / 204 No Content 등)
  private static let emptyResponseCodes: Set<Int> = [200, 201, 202, 204, 205]

  /// 조립된 Alamofire 세션
  private let session: Session
  /// 앱 서버 baseURL. Info.plist 에 BASE_URL 이 없으면 nil — 요청 시 `.request(.invalidURL)`.
  private let baseURL: URL?
  /// 요청별 인증 조립용 공유 인터셉터. nil 이면 인증 파이프라인 없는 클라이언트(plain).
  private let authorizing: AuthorizingInterceptor?

  init(
    session: Session,
    baseURL: URL?,
    authorizing: AuthorizingInterceptor? = nil
  ) {
    self.session = session
    self.baseURL = baseURL
    self.authorizing = authorizing
  }
}

// MARK: - DDDRequestClient (일반 요청)

extension NetworkClient: DDDRequestClient {
  func send<R: DDDDataRequest, T: Decodable & Sendable>(
    _ request: R,
    as type: T.Type
  ) async throws(DDDNetworkError) -> T {
    let dataRequest = try makeDataRequest(request)
    return try await handle(dataRequest, as: T.self)
  }

  func send<R: DDDDataRequest>(_ request: R) async throws(DDDNetworkError) -> R.Response {
    let dataRequest = try makeDataRequest(request)
    return try await handle(dataRequest, as: R.Response.self)
  }

  func sendResponse<R: DDDDataRequest>(_ request: R) async throws(DDDNetworkError) -> DDDHTTPResponse {
    let dataRequest = try makeDataRequest(request)
    let response = await dataRequest.serializingData(emptyResponseCodes: Self.emptyResponseCodes).response
    if let error = response.error, response.response == nil {
      throw Self.mapFailure(error, data: response.data, status: -1)
    }
    return DDDHTTPResponse(
      statusCode: response.response?.statusCode ?? -1,
      data: response.data ?? Data()
    )
  }

  /// 요청을 URLRequest 로 만들고 인증·재시도 인터셉터를 조립한다. 두 send 오버로드가 공유한다.
  private func makeDataRequest<R: DDDDataRequest>(_ request: R) throws(DDDNetworkError) -> DataRequest {
    // 1) DDDDataRequest → URLRequest (헤더 / 타임아웃 / 파라미터 인코딩)
    let base = try resolvedBaseURL()
    let urlRequest: URLRequest
    do {
      urlRequest = try request.asURLRequest(baseURL: base)
    } catch {
      throw .request(.encodingFailed(error))
    }

    // 2) 인증(요청의 authorization 정책)과 재시도를 요청별로 조립한다.
    return session.request(urlRequest, interceptor: interceptor(for: request))
  }
}

// MARK: - DDDUploadClient (멀티파트 업로드)

extension NetworkClient: DDDUploadClient {
  func upload<R: DDDUploadRequest>(_ request: R) async throws(DDDNetworkError) -> R.Response {
    let base = try resolvedBaseURL()
    let url = base.appendingPathComponent(request.path)
    // escaping 클로저에는 Sendable 값만 캡처한다.
    let parts = request.parts
    let timeout = request.timeoutInterval

    // UploadRequest 는 DataRequest 의 하위 → 응답 처리(handle)를 그대로 공유한다.
    let uploadRequest = session.upload(
      multipartFormData: { form in parts.forEach { Self.append($0, to: form) } },
      to: url,
      method: request.method,
      headers: request.headers,
      interceptor: interceptor(for: request),
      requestModifier: { urlRequest in
        if let timeout { urlRequest.timeoutInterval = timeout }
      }
    )
    return try await handle(uploadRequest, as: R.Response.self)
  }
}

// MARK: - DDDFileUploadClient (presigned 원본 바이트 PUT)

extension NetworkClient: DDDFileUploadClient {
  func upload(_ request: some DDDFileUploadRequest) async throws(DDDNetworkError) {
    var urlRequest = URLRequest(url: request.uploadURL)
    urlRequest.method = .put
    urlRequest.httpBody = request.body
    urlRequest.setValue(request.contentType, forHTTPHeaderField: "Content-Type")
    if let timeout = request.timeoutInterval {
      urlRequest.timeoutInterval = timeout
    }

    let response = await session.request(urlRequest, interceptor: request.retryPolicy)
      .validate()
      .serializingData(emptyResponseCodes: Self.emptyResponseCodes)
      .response

    if case let .failure(afError) = response.result {
      throw Self.mapFailure(afError, data: response.data, status: response.response?.statusCode ?? -1)
    }
  }
}

// MARK: - 요청별 인터셉터

private extension NetworkClient {
  /// baseURL 이 없으면 요청을 만들 수 없다 — 조용히 넘기지 않고 즉시 실패시킨다.
  func resolvedBaseURL() throws(DDDNetworkError) -> URL {
    guard let baseURL else { throw .request(.invalidURL) }
    return baseURL
  }

  /// 요청의 인증 정책에 따라 인터셉터를 조립한다.
  func interceptor(for request: some DDDEndpoint) -> any RequestInterceptor {
    guard let authorizing, request.authorization == .automatic else {
      return request.retryPolicy
    }
    return Interceptor(interceptors: [authorizing, request.retryPolicy])
  }
}

// MARK: - Response Handling (send / upload 공유)

private extension NetworkClient {
  /// 응답을 `T` 로 디코딩한다. 실패 판정은 `validate()` 의 HTTP status 검증이 맡고,
  /// 실패 바디에 담긴 `{ code, message }` 는 `ResponseError` 로 살려 낸다.
  func handle<T: Decodable & Sendable>(
    _ dataRequest: DataRequest,
    as _: T.Type
  ) async throws(DDDNetworkError) -> T {
    let response = await dataRequest
      .validate()
      .serializingDecodable(T.self, emptyResponseCodes: Self.emptyResponseCodes)
      .response

    switch response.result {
    case let .success(value):
      return value
    case let .failure(afError):
      throw Self.mapFailure(afError, data: response.data, status: response.response?.statusCode ?? -1)
    }
  }
}

// MARK: - Multipart 매핑

private extension NetworkClient {
  /// `DDDMultipartPart` → Alamofire `MultipartFormData` 한 파트 추가.
  static func append(_ part: DDDMultipartPart, to form: MultipartFormData) {
    switch part.source {
    case let .data(data):
      form.append(data, withName: part.name, fileName: part.fileName, mimeType: part.mimeType)
    case let .file(url):
      if let fileName = part.fileName, let mimeType = part.mimeType {
        form.append(url, withName: part.name, fileName: fileName, mimeType: mimeType)
      } else {
        form.append(url, withName: part.name)
      }
    }
  }
}

// MARK: - Error 매핑

private extension NetworkClient {
  /// `AFError` 를 파이프라인 단계별 `DDDNetworkError` 로 좁힌다.
  static func mapFailure(_ error: AFError, data: Data?, status: Int) -> DDDNetworkError {
    switch error {
    // 상태코드 검증 실패 — 서버가 내려준 에러. 바디의 code/message 를 살린다.
    case .responseValidationFailed(.unacceptableStatusCode):
      let body = data.flatMap { try? JSONDecoder().decode(ErrorBody.self, from: $0) }
      return .response(ResponseError(httpStatus: status, code: body?.code, message: body?.message))

    // 응답 디코딩 실패 — DDDEventMonitor 가 원시 바디와 함께 로깅한다.
    case let .responseSerializationFailed(.decodingFailed(decodingError)):
      return .decoding(.failed(decodingError))

    // 값을 기대했는데 바디가 비어 있음
    case .responseSerializationFailed(.inputDataNilOrZeroLength),
         .responseSerializationFailed(.invalidEmptyResponse):
      return .decoding(.dataMissing)

    // 서버가 JSON 아닌 응답을 줌 (콘텐츠 타입 불일치)
    case .responseValidationFailed(.unacceptableContentType),
         .responseValidationFailed(.missingContentType):
      return .decoding(.failed(error))

    // 전송 실패(오프라인 / 타임아웃 / 취소) 및 그 외(요청 적응·재시도 실패, TLS 등)
    default:
      return .transport(mapTransportError(error))
    }
  }

  /// `AFError` → `TransportError` (연결 없음 / 타임아웃 / 취소 / 기타).
  static func mapTransportError(_ error: AFError) -> TransportError {
    if case .explicitlyCancelled = error {
      return .cancelled
    }
    guard let urlError = error.underlyingError as? URLError else {
      return .unknown(error)
    }
    switch urlError.code {
    case .notConnectedToInternet, .dataNotAllowed, .networkConnectionLost:
      return .notConnected
    case .timedOut:
      return .timedOut
    case .cancelled:
      return .cancelled
    default:
      return .unknown(error)
    }
  }
}
