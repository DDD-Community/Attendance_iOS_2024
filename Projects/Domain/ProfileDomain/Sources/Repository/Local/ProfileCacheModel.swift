//
//  ProfileCacheModel.swift
//  ProfileDomain
//
//  Created by DDD on 5/12/26.
//

import Foundation

import ProfileDomainInterface

import SQLiteData

@Table("profileCache")
struct ProfileCacheRecord: Equatable, Sendable {
  @Column(primaryKey: true)
  let cacheKey: String
  @Column(as: Date.UnixTimeRepresentation.self)
  let cachedAt: Date
  let userID: Int
  let name: String
  let generation: String
  let teamRawValue: String?
  let jobRoleRawValue: String
  let roleRawValue: String
  let managerRolesData: Data?

  init(
    cacheKey: String,
    cachedAt: Date,
    userID: Int,
    name: String,
    generation: String,
    teamRawValue: String?,
    jobRoleRawValue: String,
    roleRawValue: String,
    managerRolesData: Data?
  ) {
    self.cacheKey = cacheKey
    self.cachedAt = cachedAt
    self.userID = userID
    self.name = name
    self.generation = generation
    self.teamRawValue = teamRawValue
    self.jobRoleRawValue = jobRoleRawValue
    self.roleRawValue = roleRawValue
    self.managerRolesData = managerRolesData
  }

  // 만료: 당일
  var isExpired: Bool {
    !Calendar.current.isDate(cachedAt, inSameDayAs: Date())
  }

  func toDomain() -> ProfileEntity {
    let managerRoles = managerRolesData.flatMap {
      try? JSONDecoder().decode([String].self, from: $0)
    }
    return ProfileEntity(
      userID: userID,
      name: name,
      generation: generation,
      team: teamRawValue.flatMap { SelectTeams(rawValue: $0) },
      jobRole: SelectParts(rawValue: jobRoleRawValue) ?? .all,
      role: Staff(rawValue: roleRawValue) ?? .member,
      manger: managerRoles?.compactMap { StaffManaging(rawValue: $0) }
    )
  }
}

extension ProfileEntity {
  func toCacheRecord(cacheKey: String, cachedAt: Date = Date()) throws -> ProfileCacheRecord {
    ProfileCacheRecord(
      cacheKey: cacheKey,
      cachedAt: cachedAt,
      userID: userID,
      name: name,
      generation: generation,
      teamRawValue: team?.rawValue,
      jobRoleRawValue: jobRole.rawValue,
      roleRawValue: role.rawValue,
      managerRolesData: try manger.map { roles in
        try JSONEncoder().encode(roles.map(\.rawValue))
      }
    )
  }
}

enum ProfileCacheKey {
  static let user = "profile.user.default"
}
