//
//  SQLiteSharedValueStorage.swift
//  DDDStorage
//
//  Created by DDD on 9/4/26.
//

import Foundation

import DDDStorageInterface

import SQLiteData

@Table("sharedValues")
private struct SharedValueRecord: Sendable {
  @Column(primaryKey: true)
  let key: String
  let value: Data
}

struct SQLiteSharedValueStorage: SharedValueStorage {
  let identifier = SharedValueStorageIdentifier()
  private let database: any DatabaseWriter

  init(database: any DatabaseWriter) {
    self.database = database
  }

  func load(forKey key: String) throws -> Data? {
    try database.read { db in
      try SharedValueRecord.find(key).fetchOne(db)?.value
    }
  }

  func save(_ data: Data, forKey key: String) throws {
    try database.write { db in
      try SharedValueRecord
        .upsert { SharedValueRecord(key: key, value: data) }
        .execute(db)
    }
  }

  func remove(forKey key: String) throws {
    try database.write { db in
      try SharedValueRecord.find(key).delete().execute(db)
    }
  }
}
