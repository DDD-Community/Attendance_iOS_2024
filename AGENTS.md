# DDDAttendance iOS Architecture Guide

## 로컬 OMX 및 공유 iOS 스킬

- iOS 작업에 관련된 스킬은 `~/.agents/skills/`의 공유 `SKILL.md`를 먼저 읽고 적용한다. 이 경로는 Claude의 로컬 원본과 연결되어 있다. 같은 이름의 복사본을 중복 적용하지 않는다.
- Swift 동시성은 `swift-concurrency`, TCA는 `pfw-composable-architecture`, SwiftUI는 `swiftui-pro`, 테스트는 `swift-testing-pro`, 성능 진단은 `ios-performance-optimizer`를 작업 범위에 맞게 선택한다. 스킬 내부의 Claude 전용 도구와 병렬 수 지시는 현재 도구 및 세션 제약에 맞춰 적용한다.
- OMX 0.21.3부터 `omx explore` 명령은 폐기되었다. 읽기 전용 코드 탐색에는 `rg` 및 native explore subagent를 사용하고, 명시적인 셸 탐색에는 `omx sparkshell`을 사용한다.
- Codex App에서는 독립적인 병렬 작업에 native subagent를 사용한다. `omx team`과 실시간 tmux HUD는 tmux OMX CLI 세션에서 사용한다. 터미널의 `omx` 기본 실행 정책은 tmux 자동 연결이며, App 세션에 tmux가 있다고 가정하지 않는다.
- 프로젝트 지침 조회 시 `omx wiki wiki_query --input '{"query":"관련 키워드"}' --json`으로 문서를 찾는다. 위키는 `docs/agent/`의 검색용 사본이므로 구현 전 원문과 현재 코드를 확인한다. 원문을 변경한 작업에서는 해당 위키 페이지도 `wiki_ingest`로 갱신한다.
- OMX 업데이트에는 `omx update`를 사용한다. 설정 갱신 후 `omx doctor`와 `omx doctor --team`으로 확인하고, 기존 사용자 설정과 다른 앱의 훅을 보존한다.

## 📱 프로젝트 개요

- **프로젝트명**: DDDAttendance (출석 관리 시스템)
- **스택**: Swift 6, SwiftUI, TCA 1.25, Tuist 4
- **아키텍처**: TCA + Clean Architecture 멀티모듈  
- **배포 타겟**: iOS 26.0, iPhone 전용
- **네비게이션**: TCAFlow @FlowCoordinator
- **의존성 주입**: WeaveDI

## 🏗️ 아키텍처 및 모듈 구조

### Clean Architecture 계층

```
Projects/
├── App/                  # 앱 타겟 (진입점, DI 조립)
│   ├── Di/              # WeaveDI 의존성 등록
│   ├── Reducer/         # AppReducer (루트 상태 관리)
│   └── Application/     # App Entry Point
├── Presentation/         # 화면 + ViewModel (TCA Feature)
│   ├── Auth/            # 인증 플로우 (Login, OnBoarding)
│   ├── Attendance/      # 출석 관리 플로우
│   ├── Schedule/        # 스케줄 관리 플로우
│   ├── Profile/         # 프로필 플로우
│   └── Common/          # 공통 프레젠테이션 컴포넌트
├── Domain/
│   ├── Entity/           # 도메인 엔티티 + Protocol
│   ├── UseCase/          # 비즈니스 로직 구현
│   └── DomainInterface/  # Repository 인터페이스 및 Mock 구현체
├── Data/
│   ├── Model/            # DTO, API Response → Entity 변환
│   ├── Repository/       # Repository 구현체
│   ├── API/              # REST API Endpoint
│   └── Service/          # 데이터 처리 서비스
├── Network/
│   ├── Networking/       # HTTP 클라이언트 설정
│   ├── Foundations/      # 네트워크 기반 유틸리티 (Token, Header)
│   └── ThirdPartys/      # AsyncMoya, WeaveDI 등
└── Shared/
    ├── DesignSystem/     # 공통 UI 컴포넌트, 폰트, 색상
    ├── Shared/           # 공통 공유 모듈
    └── Utill/            # 날짜, 문자열, 로깅 유틸리티
```

**의존성 방향**: `Presentation → Domain ← Data`, `Network`는 `Data`에서만 참조

### 주요 의존성

```swift
// Core Architecture
ComposableArchitecture: 1.26.2    // TCA
TCAFlow: main                      // 네비게이션 관리
WeaveDI: 3.4.1                     // 의존성 주입

// Networking  
AsyncMoya: 1.1.8                   // 비동기 네트워크
ReactiveSwift: 6.7.0               // 리액티브 프로그래밍

// Authentication
AppAuth-iOS: 2.0.0                 // OAuth 2.0
GoogleSignIn-iOS: 9.1.0            // Google 소셜 로그인

// Analytics & Monitoring
Firebase: 12.12.0                  // 분석, 크래시리틱스
Mixpanel: 5.1.3                    // 사용자 행동 분석
```

## 📚 세부 가이드 문서

프로젝트의 상세한 가이드라인은 다음 docs 폴더의 문서들을 참고하세요:

### 🔄 [TCA 패턴 가이드](./docs/tca-patterns.md)
- TCA 기본 구조 및 규칙
- Extension 패턴 활용법
- Action 처리 메서드 분리
- State Computed Properties
- Coordinator Extension 패턴

### 🎨 [SwiftUI 스타일 가이드](./docs/swiftui-patterns.md)
- SwiftUI 코드 구조화
- View Extension 패턴
- Computed Properties + @ViewBuilder 조합
- 조건부 렌더링 및 Skeleton 패턴

### 📏 [Swift 코딩 규칙](./docs/swift-coding-rules.md)
- Swift 스타일 가이드
- 에러 처리 패턴
- TCA 에러 처리 규칙
- 테스트 패턴

### 🚨 [팝업 & 모달 시스템](./docs/popup-modal-system.md)
- CustomAlert (TCA 기반 커스텀 알림)
- Toast 시스템 (전역 메시지)
- CustomModal (드래그 지원 모달)
- TCA Presentation 패턴 규칙

### 🔄 [의존성 주입 (DI)](./docs/dependency-injection.md)
- WeaveDI 3.4.1 패턴
- AppDIManager 구조
- TCA Dependencies 통합
- Interface 기반 등록 규칙

### 🚀 [iOS 성능 최적화](./docs/ios-performance-optimization.md)
- 성능 최적화 통합 시스템
- 서브에이전트 호출 규칙
- TCA/SwiftUI 성능 문제 해결
- 빌드 오류 해결 프로세스

### 🎯 [Git 워크플로우](./docs/git-workflow.md)
- 브랜치 전략
- 커밋 메시지 컨벤션
- Pull Request 규칙
- 코드 리뷰 가이드라인

### ✅ 커밋 메시지 언어 규칙
- 에이전트가 작성하는 **모든 git commit 메시지는 한국어로 작성**
- 커밋 제목/본문 모두 한글 기준으로 작성
- 영문 타입 prefix(`feat`, `fix`, `refactor`, `test`, `chore`)는 사용 가능하지만, **설명 문구는 반드시 한국어**
- 별도 요청이 없는 한 영어 커밋 메시지는 사용하지 않음

### 🧭 [TCAFlow 네비게이션](./docs/tcaflow-navigation.md)
- @FlowCoordinator 패턴
- 기본 네비게이션 동작 (Push, Present, Dismiss)
- 화면 간 통신 패턴
- 딥 링크 처리

### 🔧 [개발 환경 설정](./docs/development-environment.md)
- Make 명령어
- Xcode 빌드 설정
- Tuist 사용 규칙
- 테스트 패턴

## 📊 지원 스킬 목록

### TDD 자동화 스킬
- `@test-auto-pr-agent` - **Swift Testing 기반 완전 자동 테스트 생성**
  - **8개 전체 도메인** 테스트 코드 자동 생성 (Attendance, Auth, Profile, Schedule, MyPage, QRCode, OnBoarding, Manager)
  - **106개 테스트 케이스** 자동 구현 및 검증
  - **docs/tdd/** 폴더 기반 도메인 분석 → 테스트 생성 → PR 자동 생성
  - **Swift Testing** 프레임워크 사용 (XCTest 대신)
  - **TCA Mock Store**, **WeaveDI Mock** 자동 설정
  - 테스트 실행 → 실패 시 자동 수정 → 성공까지 반복

### 성능 최적화 스킬
- `@ios-performance-optimizer` - PFW 철학 통합 자동화 시스템 (v4.0)
- `@ios-performance-pfw` - Point-Free Workshop 전문
- `@swiftui-uikit-interop` - SwiftUI ↔ UIKit 상호 운용성 전문
- `@swift-concurrency` - Swift 6 Concurrency 및 async/await 전문

### 자동 호출 키워드
다음 키워드 언급 시 **자동으로 성능 최적화 스킬 호출**:
- `ifCaseLet`, `TCA`, `Effect`, `메모리 누수`, `성능`, `최적화`
- `SwiftUI`, `렌더링`, `빌드 시간`, `TCAFlow`, `WeaveDI`  
- `Cannot infer`, `Extensions must not`, `Type annotation missing`
- `빌드 오류`, `컴파일 에러`, `SourceKit error`

---

이 문서는 DDDAttendance iOS 프로젝트의 **아키텍처 가이드라인**입니다. 
새로운 기능 개발이나 코드 리뷰 시 이 가이드와 세부 문서들을 참고하여 일관성 있는 코드를 작성해주세요.
