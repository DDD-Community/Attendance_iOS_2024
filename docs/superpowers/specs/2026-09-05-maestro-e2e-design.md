# Maestro E2E 풀테스트·스모크 테스트 설계

작성일: 2026-09-05
브랜치: `feature/mestro-e2e`

## 목표

앱 전 화면에 Maestro 선택자용 accessibility identifier를 부여하고, 이를 기반으로
스모크 스위트(≤5분)와 풀 E2E 스위트를 구성한다.

성공 기준:

1. `maestro test .maestro/flows/smoke_test.yaml` 이 5분 내 통과한다.
2. `maestro test .maestro/flows/full_test.yaml` 이 전 화면을 거쳐 통과한다.
3. 모든 화면이 화면 단위 flow 파일 하나로 대응된다.
4. `.maestro/bin/verify-ids.sh` 가 yaml이 참조하는 ID와 Swift 상수 집합의 불일치를 잡아낸다.

## 현황

- ID 부여된 파일 11개 / 뷰 파일 37개
- ID 네임스페이스 4개: `AuthAccessibilityID`, `MemberAccessibilityID`,
  `ManagementAccessibilityID`, `ProfileAccessibilityID`
- 부여 수단: `DDDAccessibility` 모듈의 `View.dddAccessibilityID(_:)`
- 플로우 17개 (splash / login 4 / management 6 / member 3 / profile 2 + 루트 full_test)
- 스모크 진입점 없음

## 범위 결정

포함하지 않는다:

- 온보딩 5화면 flow — 신규 계정이 필요해 반복 실행 불가. ID는 부여한다.
- 탈퇴 확정 flow — 계정이 소멸해 반복 실행 불가. ID는 부여한다.
- QR 카메라 스캔 결과 — 시뮬레이터가 카메라를 지원하지 않는다. 진입까지만 검증한다.
- 투표 최종 제출 — 서버 상태를 바꾸고 재제출이 불가능할 수 있다. 제출 직전까지 검증한다.

## 1. Accessibility ID 체계

명명 규칙은 기존을 따른다: `<feature>.<screen>.<element>`, 전부 소문자,
동적 항목은 `static func`.

### 신규 네임스페이스

| 파일 | 내용 |
| --- | --- |
| `Feature/OnBoarding/Sources/Accessibility/OnBoardingAccessibilityID.swift` | `Name`, `SelectTeam`, `SelectPart`, `SelectManaging`, `InviteCode` 5화면. 각각 root·list·item(id)·nextButton·textField·skeleton 중 해당하는 것 |
| `Feature/Web/Sources/Accessibility/WebAccessibilityID.swift` | `root`, `backButton` |

### 기존 네임스페이스 확장

| 네임스페이스 | 추가 |
| --- | --- |
| `ManagementAccessibilityID` | `Staff.dropdown`, `Staff.dropdownItem(_:)`, `Schedule`(root/list/card(id)/header/skeleton), `Vote`(root/statusChip/startButton/endButton/nonParticipantsButton/nonParticipantsModal/skeleton), `QRScanner`(root/closeButton/resultText) |
| `MemberAccessibilityID` | `Vote.TeamSelect`(root/category(id)/reasonField/nextButton), `Vote.Feedback`(root/question(id)/option(id)/submitButton), `Vote.skeleton`, `QRCode`(root/image/backButton/skeleton), `homeSkeleton` |
| `ProfileAccessibilityID` | `CreateApp`(root/closeButton/confirmButton) |
| `AuthAccessibilityID` | 변경 없음 |

### 공통 컴포넌트: ID 주입 패턴

`HomeDropdownMenu`는 `DDDDesignKit`(UI 레이어)에 있어 Feature 네임스페이스를
참조할 수 없다. 현재 탭 전환 항목에 선택자가 전혀 없어 일정·투표 탭 flow가 불가능하다.

해결: `HomeDropdownMenu.Entry`에 `accessibilityID: String` 필드를 추가하고
호출부(`StaffView`, `MemberMainView`)에서 주입한다. DesignKit은 ID 문자열의 의미를
모르고 전달만 한다. `AttendanceCheckStatusCard`가 이미 쓰는 패턴과 같다.

`ScheduleCardView` 등 다른 공유 컴포넌트도 같은 방식으로 처리한다.

## 2. 플로우 구조

A안(단독 실행 가능성)과 B안(세션 재사용)을 결합한다.

```
.maestro/flows/
  smoke_test.yaml            # 신규 진입점, 목표 5분 이내
  full_test.yaml             # 확장
  _shared/
    switch_section.yaml      # 드롭다운 탭 전환, env: SECTION_ID
  splash/  login/            # 기존 유지
  management/
    login_to_home.yaml  home_smoke.yaml  attendance_refresh.yaml
    team_switch.yaml    schedule_change.yaml
    schedule_tab.yaml   vote_tab.yaml    qr_scanner.yaml     # 신규
    full_test.yaml
  member/
    login_to_home.yaml  home_smoke.yaml
    schedule_list.yaml  qr_code.yaml                         # 신규
    vote.yaml   vote_team_select.yaml   vote_feedback.yaml   # 신규, 화면 단위 분리
    full_test.yaml
  profile/
    home_smoke.yaml
    privacy_policy_web.yaml  create_app.yaml                 # 신규
    full_test.yaml
  onboarding/
    invite_code.yaml                                         # 신규
    full_test.yaml
```

flow 파일은 화면 하나에 하나씩 대응시킨다. 투표처럼 여러 화면을 거치는 흐름도
`vote` / `vote_team_select` / `vote_feedback` 로 나눠 화면별로 단독 수정·실행한다.

### 화면 flow 계약

`_shared/`와 `login_to_home` 이외의 화면 flow는 다음을 지킨다.

1. 진입 시 해당 역할의 홈 화면이 떠 있다고 가정한다.
2. 종료 시 홈 화면으로 복귀한다.
3. `launchApp`, `clearState`를 쓰지 않는다.

이 계약 덕분에 로그인 1회로 여러 화면 flow를 체이닝할 수 있다.
단독 실행이 필요하면 `login_to_home`을 앞에 붙여 `maestro test` 를 두 번 호출한다.

### 스위트 구성

`smoke_test.yaml` — 로그인 2회, 상태 변경 없음:

1. `splash/launch_to_login`
2. `management/login_to_home`
3. 출석 탭 렌더링 assert
4. `_shared/switch_section` → 일정 탭 렌더링 assert
5. `_shared/switch_section` → 투표 탭 렌더링 assert
6. `member/login_to_home`
7. `member/home_smoke`

`full_test.yaml` — 위에 더해 팀 전환, 출석 새로고침, 일정 변경, 투표 진행 화면,
QR 진입, 프로필 웹뷰·만든 사람들 모달, 온보딩 초대 코드 화면.

태그 체계: `smoke` / `full` / `e2e` / 역할(`management`, `member`) / 화면(`vote` 등).
태그는 필터 용도로만 쓰고 실행 순서 보장에는 쓰지 않는다. Maestro가 태그 실행 시
순서를 보장하지 않기 때문이다.

## 3. 검증

1. `mise exec -- tuist generate` 후 빌드. (PATH의 tuist는 버전이 낮아 실패한다)
2. 시뮬레이터 부팅 후 `.maestro/run-studio.sh`로 화면별 계층을 덤프해 ID 노출을 확인한다.
3. Studio가 타임아웃하면 폴백: `maestro test` 실행 + `takeScreenshot`,
   `assertVisible` 실패 로그로 판정한다.
4. 드리프트 가드 `.maestro/bin/verify-ids.sh`: yaml의 `id:` 값을 추출해 Swift ID
   상수 집합과 대조한다. 와일드카드(`*`)와 문자열 보간이 들어간 동적 ID는 prefix로
   매칭한다. 미정의 ID가 있으면 실패한다.
5. 신규 네임스페이스마다 기존 `*AccessibilityIDTests.swift` 패턴의 테스트를 추가한다.

## 4. 작업 순서

| Phase | 내용 |
| --- | --- |
| 1 | ID 네임스페이스 생성·확장, 뷰에 ID 부여, 네임스페이스 테스트 추가 |
| 2 | `tuist generate` + 빌드, Studio로 ID 노출 검증 |
| 3 | yaml 작성: `_shared` → 화면 flow → 모듈별 `full_test` → `smoke_test`/루트 `full_test` |
| 4 | 실행 및 안정화, `verify-ids.sh` 도입 |
