#!/usr/bin/env bash

set -euo pipefail

readonly TEST_SCHEME="${TEST_SCHEME:-DDDAttendance-Stage}"
readonly TEST_PLAN="${TEST_PLAN:-DDDAttendance}"
readonly CONFIGURATION="${CONFIGURATION:-Stage}"
readonly SIMULATOR_DESTINATION="${SIMULATOR_DESTINATION:?SIMULATOR_DESTINATION is required}"
readonly CI_DERIVED_DATA="${CI_DERIVED_DATA:?CI_DERIVED_DATA is required}"
readonly RESULT_BUNDLE="${RESULT_BUNDLE:-TestResults.xcresult}"
readonly TEST_RUN_REPORT_PATH="${TEST_RUN_REPORT_PATH:-TestRunReport.json}"
readonly TEST_LOG_PATH="${TEST_LOG_PATH:-TuistTestRun.log}"

compilation_cache_enabled="${XCODE_COMPILATION_CACHE_ENABLED:-NO}"
simulator_udid=""

if [[ "$SIMULATOR_DESTINATION" =~ (^|,)id=([^,]+) ]]; then
  simulator_udid="${BASH_REMATCH[2]}"
fi

shutdown_test_simulator() {
  local exit_code=$?

  if [[ -n "$simulator_udid" ]]; then
    xcrun simctl shutdown "$simulator_udid" >/dev/null 2>&1 || true
    echo "테스트 시뮬레이터를 종료했습니다: $simulator_udid"
  fi

  return "$exit_code"
}

trap shutdown_test_simulator EXIT

rm -rf "$RESULT_BUNDLE" "$TEST_RUN_REPORT_PATH" "$TEST_LOG_PATH"

shard_arguments=()
if [[ -n "${TUIST_SHARD_PLAN_ID:-}" || -n "${TUIST_SHARD_INDEX:-}" ]]; then
  if [[ -z "${TUIST_SHARD_PLAN_ID:-}" || -z "${TUIST_SHARD_INDEX:-}" ]]; then
    echo "TUIST_SHARD_PLAN_ID와 TUIST_SHARD_INDEX는 함께 지정해야 합니다." >&2
    exit 1
  fi
  shard_arguments=(
    --without-building
    --shard-plan-id "$TUIST_SHARD_PLAN_ID"
    --shard-index "$TUIST_SHARD_INDEX"
  )
fi

# 모듈 테스트는 별도 host 없이 로직 테스트로 실행한다.
# 하나의 Stage workspace scheme으로 실행하면 SPM/TCA 그래프를 한 번만 빌드하면서도
# xcresult에 모듈별 테스트 케이스와 커버리지가 함께 기록된다.
#
# PR 리포트가 이전 커밋의 모듈 실행을 섞지 않도록 모든 테스트 타깃을 실행한다.
# run report는 Tuist 서버 업로드 여부와 최신 dashboard URL을 CI에서 검증하는 증거다.
mise exec -- tuist test run "$TEST_SCHEME" \
  --test-plan "$TEST_PLAN" \
  --configuration "$CONFIGURATION" \
  --no-selective-testing \
  "${shard_arguments[@]}" \
  --inspect-mode remote \
  --result-bundle-path "$RESULT_BUNDLE" \
  --run-report-path "$TEST_RUN_REPORT_PATH" \
  --path "$PWD" \
  -- \
  -destination "$SIMULATOR_DESTINATION" \
  -derivedDataPath "$CI_DERIVED_DATA" \
  -enableCodeCoverage YES \
  -retry-tests-on-failure \
  -test-iterations 2 \
  -collect-test-diagnostics never \
  ONLY_ACTIVE_ARCH=YES \
  COMPILATION_CACHE_ENABLE_CACHING="$compilation_cache_enabled" \
  2>&1 | tee "$TEST_LOG_PATH"

if [[ ! -s "$TEST_RUN_REPORT_PATH" ]]; then
  echo "Tuist test run이 서버 dashboard URL을 기록하지 못했습니다: $TEST_RUN_REPORT_PATH" >&2
  exit 1
fi

if [[ ! -d "$RESULT_BUNDLE" ]]; then
  echo "테스트 결과 번들이 생성되지 않았습니다: $RESULT_BUNDLE" >&2
  exit 1
fi

test_count="$({
  xcrun xcresulttool get test-results summary \
    --path "$RESULT_BUNDLE" \
    --format json
} | ruby -rjson -e 'puts(JSON.parse(STDIN.read).fetch("totalTestCount", 0))')"

if [[ ! "$test_count" =~ ^[0-9]+$ ]] || (( test_count == 0 )); then
  echo "실행된 테스트 케이스가 없습니다: $test_count" >&2
  exit 1
fi

echo "전체 모듈 테스트 ${test_count}개를 $TEST_SCHEME 스킴의 $TEST_PLAN 플랜으로 실행했습니다."
