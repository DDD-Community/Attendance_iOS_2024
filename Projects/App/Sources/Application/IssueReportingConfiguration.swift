//
//  IssueReportingConfiguration.swift
//  DDDAttendance
//
//  Created by DDD on 9/6/26.
//

#if DEBUG
import Foundation

import IssueReporting

/// AppReducer 의 ifCaseLet 경고만 걸러내고 나머지 이슈는 기본 런타임 경고로 넘긴다.
///
/// 로그아웃/세션 만료로 AppReducer.State 가 .auth 로 바뀌는 시점에, 아직 화면에 남아있는
/// Coordinator 뷰가 생명주기 액션(ProfileView 의 onAppear → fetchUser)을 이미 죽은 스코프로 보낸다.
/// Effect 가 아니라 뷰 생명주기라 .cancel(id:) 로 막을 수 없고,
/// 자식 리듀서가 부모 필터보다 먼저 돌기 때문에 리듀서 쪽에서도 막을 수 없다. 동작상 무해하다.
private struct AppReducerScopeIssueFilter: IssueReporter {
  private let base: any IssueReporter = .runtimeWarning

  func reportIssue(
    _ message: @autoclosure () -> String?,
    severity: IssueSeverity,
    fileID: StaticString,
    filePath: StaticString,
    line: UInt,
    column: UInt
  ) {
    let text = message()

    if let text,
       text.contains(#""ifCaseLet""#),
       text.contains("AppReducer.swift")
    {
      return
    }

    base.reportIssue(
      text,
      severity: severity,
      fileID: fileID,
      filePath: filePath,
      line: line,
      column: column
    )
  }
}

enum IssueReportingConfiguration {
  static func configure() {
    IssueReporters.current = [AppReducerScopeIssueFilter()]
  }
}
#endif
