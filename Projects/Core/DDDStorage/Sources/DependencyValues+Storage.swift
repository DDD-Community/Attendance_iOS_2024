import DDDStorageInterface
import Dependencies
import SQLiteData

extension AppDatabaseDependency: DependencyKey {
  public static var liveValue: (any DatabaseWriter)? {
    StorageFactory.databaseWriter
  }
}

extension SharedValueStorageDependency: DependencyKey {
  public static var liveValue: any SharedValueStorage {
    StorageFactory.sharedValueStorage
  }
}
