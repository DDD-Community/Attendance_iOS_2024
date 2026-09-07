//
//  NetworkClientTests.swift
//  DDDNetworkTests
//
//  Created by DDD on 9/1/26.
//

import Foundation
import Testing

@testable import DDDNetwork
import DDDNetworkInterface

import Alamofire

@Suite("NetworkClient — 요청·응답 통합", .serialized)
struct NetworkClientTests {
  init() {
    URLProtocolStub.reset()
  }

  @Test("2xx 성공 응답을 모델로 디코딩한다")
  func success() async throws {
    URLProtocolStub.set(statusCode: 200, body: json(#"{"id":7,"name":"출석"}"#))

    let user = try await URLProtocolStub.makeClient().send(UserRequest())

    #expect(user == User(id: 7, name: "출석"))
    #expect(URLProtocolStub.recordedRequests.first?.url?.path == "/users/7")
  }

  @Test("4xx 응답의 code와 message를 ResponseError로 보존한다")
  func clientError() async {
    URLProtocolStub.set(
      statusCode: 400,
      body: json(#"{"code":"INVALID_REQUEST","message":"잘못된 요청"}"#)
    )

    await expectResponseError(UserRequest()) { error in
      #expect(error.httpStatus == 400)
      #expect(error.code == "INVALID_REQUEST")
      #expect(error.message == "잘못된 요청")
      #expect(error.isServerError == false)
    }
  }

  @Test("401 응답은 인증 실패로 분류한다")
  func unauthorized() async {
    URLProtocolStub.set(statusCode: 401, body: json(#"{"code":"TOKEN_EXPIRED"}"#))

    await expectResponseError(UserRequest()) { error in
      #expect(error.isUnauthorized)
      #expect(error.code == "TOKEN_EXPIRED")
    }
  }

  @Test("5xx 응답은 서버 오류로 분류한다")
  func serverError() async {
    URLProtocolStub.set(statusCode: 503, body: json("{}"))

    await expectResponseError(UserRequest()) { error in
      #expect(error.httpStatus == 503)
      #expect(error.isServerError)
      #expect(error.code == nil)
    }
  }

  @Test("인터넷 연결 실패는 transport.notConnected로 변환한다")
  func notConnected() async {
    URLProtocolStub.setError(URLError(.notConnectedToInternet))

    await expectTransportError(UserRequest()) { error in
      guard case .notConnected = error else {
        Issue.record("notConnected 기대, got \(error)")
        return
      }
    }
  }

  @Test("타임아웃은 transport.timedOut으로 변환한다")
  func timedOut() async {
    URLProtocolStub.setError(URLError(.timedOut))

    await expectTransportError(UserRequest()) { error in
      guard case .timedOut = error else {
        Issue.record("timedOut 기대, got \(error)")
        return
      }
    }
  }

  @Test("성공 응답의 JSON 형태가 다르면 decoding 에러로 변환한다")
  func decodingFailure() async {
    URLProtocolStub.set(statusCode: 200, body: json(#"{"id":"문자열"}"#))

    do {
      _ = try await URLProtocolStub.makeClient().send(UserRequest())
      Issue.record("decoding 에러가 발생해야 한다")
    } catch {
      guard case .decoding = error else {
        Issue.record("decoding 기대, got \(error)")
        return
      }
    }
  }

  @Test("204 빈 응답은 DDDEmptyResponse로 성공한다")
  func emptyResponse() async throws {
    URLProtocolStub.set(statusCode: 204)

    _ = try await URLProtocolStub.makeClient().send(PingRequest())
  }

  @Test("raw 응답은 실패 상태 코드와 바디를 그대로 보존한다")
  func rawResponse() async throws {
    let body = json(#"{"code":"WITHDRAW_FAILED","message":"탈퇴 실패"}"#)
    URLProtocolStub.set(statusCode: 400, body: body)

    let response = try await URLProtocolStub.makeClient().sendResponse(PingRequest())

    #expect(response.statusCode == 400)
    #expect(response.data == body)
  }

  @Test("raw 응답도 전송 실패는 DDDNetworkError로 변환한다")
  func rawResponseTransportFailure() async {
    URLProtocolStub.setError(URLError(.notConnectedToInternet))

    do {
      _ = try await URLProtocolStub.makeClient().sendResponse(PingRequest())
      Issue.record("transport 에러가 발생해야 한다")
    } catch {
      guard case .transport(.notConnected) = error else {
        Issue.record("transport.notConnected 기대, got \(error)")
        return
      }
    }
  }

  @Test("baseURL이 없으면 통신 전에 request.invalidURL로 실패한다")
  func missingBaseURL() async {
    do {
      _ = try await URLProtocolStub.makeClient(baseURL: nil).send(UserRequest())
      Issue.record("invalidURL 에러가 발생해야 한다")
    } catch {
      guard case .request(.invalidURL) = error else {
        Issue.record("request.invalidURL 기대, got \(error)")
        return
      }
    }
  }

  @Test("명시한 응답 타입으로 디코딩하는 send 오버로드도 같은 요청을 보낸다")
  func explicitResponseType() async throws {
    URLProtocolStub.set(statusCode: 200, body: json(#"{"id":8,"name":"운영진"}"#))

    let user = try await URLProtocolStub.makeClient().send(UserRequest(), as: User.self)

    #expect(user == User(id: 8, name: "운영진"))
  }

  @Test("빈 성공 바디에서 값을 기대하면 decoding.dataMissing으로 변환한다")
  func missingResponseData() async {
    URLProtocolStub.set(statusCode: 200)

    do {
      _ = try await URLProtocolStub.makeClient().send(UserRequest())
      Issue.record("dataMissing 에러가 발생해야 한다")
    } catch {
      guard case .decoding(.dataMissing) = error else {
        Issue.record("decoding.dataMissing 기대, got \(error)")
        return
      }
    }
  }

  @Test("응답 Content-Type이 Accept와 다르면 decoding 실패로 변환한다")
  func unacceptableContentType() async {
    URLProtocolStub.set(
      statusCode: 200,
      body: Data("not-json".utf8),
      headerFields: ["Content-Type": "text/plain"]
    )

    do {
      _ = try await URLProtocolStub.makeClient().send(AcceptingUserRequest())
      Issue.record("content type 에러가 발생해야 한다")
    } catch {
      guard case .decoding(.failed) = error else {
        Issue.record("decoding.failed 기대, got \(error)")
        return
      }
    }
  }

  @Test("취소 전송 오류는 transport.cancelled로 변환한다")
  func cancelled() async {
    URLProtocolStub.setError(URLError(.cancelled))

    await expectTransportError(UserRequest()) { error in
      guard case .cancelled = error else {
        Issue.record("cancelled 기대, got \(error)")
        return
      }
    }
  }

  @Test("분류되지 않은 전송 오류는 transport.unknown으로 보존한다")
  func unknownTransport() async {
    URLProtocolStub.setError(URLError(.badServerResponse))

    await expectTransportError(UserRequest()) { error in
      guard case .unknown = error else {
        Issue.record("unknown 기대, got \(error)")
        return
      }
    }
  }

  @Test("재시도 가능한 503 뒤 성공하면 선언한 정책에 따라 다시 요청한다")
  func retriesServerFailure() async throws {
    URLProtocolStub.setSequence([
      (503, json("{}")),
      (200, json(#"{"id":7,"name":"재시도 성공"}"#))
    ])

    let user = try await URLProtocolStub.makeClient().send(RetryingUserRequest())

    #expect(user.name == "재시도 성공")
    #expect(URLProtocolStub.recordedRequests.count == 2)
  }

  @Test("automatic 요청은 로그인 credential을 헤더에 적용한다")
  func automaticAuthorization() async throws {
    URLProtocolStub.set(statusCode: 200, body: json(#"{"id":7,"name":"인증"}"#))
    let credential = DDDCredential(accessToken: "access-token", refreshToken: "refresh-token")
    let store = ClientCredentialStore(credential: credential)
    let (authorizing, _) = SessionFactory.authorization(
      store: store,
      refresher: ClientTokenRefresher(credential: credential)
    )

    _ = try await URLProtocolStub.makeClient(authorizing: authorizing).send(UserRequest())

    #expect(
      URLProtocolStub.recordedRequests.first?.value(forHTTPHeaderField: "Authorization")
        == "Bearer access-token"
    )
  }

  @Test("authorization.none 요청은 로그인 상태여도 인증 헤더를 붙이지 않는다")
  func bypassesAuthorization() async throws {
    URLProtocolStub.set(statusCode: 204)
    let credential = DDDCredential(accessToken: "access-token", refreshToken: "refresh-token")
    let store = ClientCredentialStore(credential: credential)
    let (authorizing, _) = SessionFactory.authorization(
      store: store,
      refresher: ClientTokenRefresher(credential: credential)
    )

    _ = try await URLProtocolStub.makeClient(authorizing: authorizing).send(PublicPingRequest())

    #expect(URLProtocolStub.recordedRequests.first?.value(forHTTPHeaderField: "Authorization") == nil)
  }

  @Test("파라미터 인코딩 실패는 request.encodingFailed로 변환한다")
  func encodingFailure() async {
    do {
      _ = try await URLProtocolStub.makeClient().send(EncodingFailureRequest())
      Issue.record("encodingFailed 에러가 발생해야 한다")
    } catch {
      guard case .request(.encodingFailed) = error else {
        Issue.record("request.encodingFailed 기대, got \(error)")
        return
      }
      #expect(URLProtocolStub.recordedRequests.isEmpty)
    }
  }

  @Test("멀티파트 데이터와 파일 파트를 업로드하고 응답을 디코딩한다")
  func multipartUpload() async throws {
    URLProtocolStub.set(statusCode: 200, body: json(#"{"id":9,"name":"업로드"}"#))
    let fileURL = FileManager.default.temporaryDirectory
      .appendingPathComponent("ddd-network-upload-\(UUID().uuidString).txt")
    try Data("file".utf8).write(to: fileURL)
    defer { try? FileManager.default.removeItem(at: fileURL) }
    let request = MultipartRequest(parts: [
      DDDMultipartPart(name: "title", source: .data(Data("attendance".utf8))),
      DDDMultipartPart(
        name: "image",
        source: .file(fileURL),
        fileName: "image.txt",
        mimeType: "text/plain"
      ),
      DDDMultipartPart(name: "attachment", source: .file(fileURL))
    ])

    let user = try await URLProtocolStub.makeClient().upload(request)

    #expect(user == User(id: 9, name: "업로드"))
    #expect(URLProtocolStub.recordedRequests.first?.httpMethod == "POST")
    #expect(
      URLProtocolStub.recordedRequests.first?
        .value(forHTTPHeaderField: "Content-Type")?
        .hasPrefix("multipart/form-data; boundary=") == true
    )
  }

  @Test("presigned 파일 업로드는 PUT 바디, Content-Type, timeout을 반영한다")
  func fileUpload() async throws {
    URLProtocolStub.set(statusCode: 204)
    let request = FileUploadRequest(
      uploadURL: URL(string: "https://attendance.test/presigned")!,
      body: Data("image".utf8),
      contentType: "image/jpeg",
      timeoutInterval: 17
    )

    try await URLProtocolStub.makeClient().upload(request)

    let captured = try #require(URLProtocolStub.recordedRequests.first)
    #expect(captured.httpMethod == "PUT")
    #expect(captured.httpBody == request.body)
    #expect(captured.value(forHTTPHeaderField: "Content-Type") == "image/jpeg")
    #expect(captured.timeoutInterval == 17)
  }

  @Test("presigned 파일 업로드 HTTP 실패도 ResponseError로 변환한다")
  func fileUploadFailure() async {
    URLProtocolStub.set(
      statusCode: 403,
      body: json(#"{"code":"UPLOAD_DENIED","message":"거부됨"}"#)
    )
    let request = FileUploadRequest(
      uploadURL: URL(string: "https://attendance.test/presigned")!,
      body: Data(),
      contentType: "application/octet-stream",
      timeoutInterval: nil
    )

    do {
      try await URLProtocolStub.makeClient().upload(request)
      Issue.record("response 에러가 발생해야 한다")
    } catch {
      guard case let .response(response) = error else {
        Issue.record("response 기대, got \(error)")
        return
      }
      #expect(response.httpStatus == 403)
      #expect(response.code == "UPLOAD_DENIED")
    }
  }
}

private extension NetworkClientTests {
  func json(_ string: String) -> Data {
    Data(string.utf8)
  }

  func expectResponseError(
    _ request: some DDDDataRequest,
    assert: (ResponseError) -> Void
  ) async {
    do {
      _ = try await URLProtocolStub.makeClient().send(request)
      Issue.record("response 에러가 발생해야 한다")
    } catch {
      guard case let .response(responseError) = error else {
        Issue.record("response 기대, got \(error)")
        return
      }
      assert(responseError)
    }
  }

  func expectTransportError(
    _ request: some DDDDataRequest,
    assert: (TransportError) -> Void
  ) async {
    do {
      _ = try await URLProtocolStub.makeClient().send(request)
      Issue.record("transport 에러가 발생해야 한다")
    } catch {
      guard case let .transport(transportError) = error else {
        Issue.record("transport 기대, got \(error)")
        return
      }
      assert(transportError)
    }
  }
}

private struct UserRequest: DDDDataRequest {
  typealias Response = User

  let path = "users/7"
  let method: HTTPMethod = .get
  let maxRetryAttempts = 0
}

private struct PingRequest: DDDDataRequest {
  typealias Response = DDDEmptyResponse

  let path = "ping"
  let method: HTTPMethod = .get
  let maxRetryAttempts = 0
}

private struct PublicPingRequest: DDDDataRequest {
  typealias Response = DDDEmptyResponse

  let path = "ping"
  let method: HTTPMethod = .get
  let maxRetryAttempts = 0
  let authorization: DDDAuthorization = .none
}

private struct AcceptingUserRequest: DDDDataRequest {
  typealias Response = User

  let path = "users/7"
  let method: HTTPMethod = .get
  let headers: HTTPHeaders = [.accept("application/json")]
  let maxRetryAttempts = 0
}

private struct RetryingUserRequest: DDDDataRequest {
  typealias Response = User

  let path = "users/7"
  let method: HTTPMethod = .get
  let maxRetryAttempts = 1
}

private struct EncodingFailureRequest: DDDDataRequest {
  typealias Response = User

  let path = "users"
  let method: HTTPMethod = .post
  let parameters: (any Encodable & Sendable)? = ThrowingParameters()
  let maxRetryAttempts = 0
}

private struct ThrowingParameters: Encodable, Sendable {
  struct EncodingError: Error {}

  func encode(to _: Encoder) throws {
    throw EncodingError()
  }
}

private struct MultipartRequest: DDDUploadRequest {
  typealias Response = User

  let path = "uploads"
  let method: HTTPMethod = .post
  let parts: [DDDMultipartPart]
  let timeoutInterval: TimeInterval? = 11
  let maxRetryAttempts = 0
}

private struct FileUploadRequest: DDDFileUploadRequest {
  let uploadURL: URL
  let body: Data
  let contentType: String
  let timeoutInterval: TimeInterval?
}

private struct ClientTokenRefresher: TokenRefreshing {
  let credential: DDDCredential

  func refresh(_: DDDCredential) async throws(DDDNetworkError) -> DDDCredential {
    credential
  }
}

private final class ClientCredentialStore: CredentialStore, @unchecked Sendable {
  private let lock = NSLock()
  private var credential: DDDCredential?

  init(credential: DDDCredential?) {
    self.credential = credential
  }

  func load() -> DDDCredential? {
    lock.withLock { credential }
  }

  func save(_ credential: DDDCredential) {
    lock.withLock { self.credential = credential }
  }

  func clear() {
    lock.withLock { credential = nil }
  }
}

private struct User: Decodable, Equatable, Sendable {
  let id: Int
  let name: String
}
