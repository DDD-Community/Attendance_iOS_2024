//
//  StorageAssembly.swift
//  CoreAssembly
//
//  Created by DDD on 9/1/26.
//

import DDDStorage
import DDDStorageInterface

import Dependencies

public enum StorageAssembly {
  public static func secureStorage() -> any SecureStorage {
    return StorageFactory.secureStorage
  }

  public static func sharedValueStorage() -> any SharedValueStorage {
    return StorageFactory.sharedValueStorage
  }

  public static func register(into values: inout DependencyValues) {
    StorageFactory.register(into: &values)
  }
}
