import DDDStorageInterface
import Dependencies
import ProfileDomain
import ScheduleDomain

extension SessionCacheInvalidatorDependency: DependencyKey {
  public static var liveValue: any SessionCacheInvalidating {
    LiveSessionCacheInvalidator()
  }
}

private struct LiveSessionCacheInvalidator: SessionCacheInvalidating {
  @Dependency(\.profileLocalDataSource) private var profile
  @Dependency(\.scheduleLocalDataSource) private var schedule

  func invalidate() async {
    try? await profile.clear()
    try? await schedule.clear()
  }
}
