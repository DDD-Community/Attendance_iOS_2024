//
//  UserSessionSharedKey.swift
//  AuthDomainInterface
//
//  Created by DDD on 9/4/26.
//

import Foundation

import DDDStorageInterface
import ProfileDomainInterface

import Dependencies
import Sharing

public extension SharedReaderKey where Self == PersistentSharedKey<UserSession>.Default {
  /// 앱 실행 사이에 유지되는 사용자 세션 메타데이터입니다.
  ///
  /// OAuth token과 서버 access token은 SQLite에 기록하지 않고 기존 Keychain 수명주기를 유지합니다.
  static var userSession: Self {
    return Self[
      .persistent(
        "UserSession",
        encode: { session in
          try JSONEncoder().encode(UserSessionSnapshot(session))
        },
        decode: { data in
          try JSONDecoder().decode(UserSessionSnapshot.self, from: data).userSession
        }
      ),
      default: .empty
    ]
  }
}

public extension SharedReaderKey where Self == PersistentSharedKey<Staff?>.Default {
  /// 로그인 여부를 나타내는 역할 값입니다. 기존 UserDefaults 값은 첫 조회 때 SQLite로 이전합니다.
  static var staffRole: Self {
    @Dependency(\.defaultAppStorage) var legacyStore

    return Self[
      .persistent(
        "staffRole",
        encode: { role in
          try JSONEncoder().encode(StaffRoleSnapshot(role: role?.rawValue))
        },
        decode: { data in
          let snapshot = try JSONDecoder().decode(StaffRoleSnapshot.self, from: data)
          return snapshot.role.flatMap(Staff.init(rawValue:))
        },
        legacyData: { [legacyStore] in
          guard let role = legacyStore.string(forKey: "staffRole") else {
            return nil
          }
          return try JSONEncoder().encode(StaffRoleSnapshot(role: role))
        }
      ),
      default: nil
    ]
  }
}

private struct StaffRoleSnapshot: Codable, Sendable {
  let role: String?
}

private struct UserSessionSnapshot: Codable, Sendable {
  let schemaVersion: Int
  let userID: Int
  let name: String
  let selectPart: String
  let userRole: String
  let managing: [String]
  let provider: String
  let selectTeam: String
  let selectTeamId: Int?
  let generationId: Int
  let generation: String
  let inviteCode: String

  init(_ session: UserSession) {
    self.schemaVersion = 1
    self.userID = session.userID
    self.name = session.name
    self.selectPart = session.selectPart.rawValue
    self.userRole = session.userRole.rawValue
    self.managing = session.managing.map(\.rawValue)
    self.provider = session.provider.rawValue
    self.selectTeam = session.selectTeam.rawValue
    self.selectTeamId = session.selectTeamId
    self.generationId = session.generationId
    self.generation = session.generation
    self.inviteCode = session.inviteCode
  }

  var userSession: UserSession {
    return UserSession(
      userID: userID,
      name: name,
      selectPart: SelectParts(rawValue: selectPart) ?? .all,
      userRole: Staff(rawValue: userRole) ?? .member,
      managing: managing.compactMap(StaffManaging.init(rawValue:)),
      provider: SocialType(rawValue: provider) ?? .apple,
      selectTeam: SelectTeams(rawValue: selectTeam) ?? .unknown,
      selectTeamId: selectTeamId,
      token: "",
      generationId: generationId,
      accessToken: "",
      oauthRefreshToken: nil,
      inviteCode: inviteCode,
      generation: generation
    )
  }
}
