#!/usr/bin/env bash
# 긴 CI 로그를 tail 로 잘라서 원인을 놓치는 대신, 실패 라인만 뽑아 압축 요약을 출력한다.
# 전체 로그는 그대로 아티팩트에 남고 여기서는 요약만 stdout + GITHUB_STEP_SUMMARY 에 쓴다.
#
# 사용법: Scripts/ci-log-digest.sh <로그파일> [제목]
# 환경변수: DIGEST_TAIL_LINES(기본 80), DIGEST_MAX_LINES(섹션당 기본 40)
set -uo pipefail

LOG_FILE=${1:?사용법: ci-log-digest.sh <로그파일> [제목]}
TITLE=${2:-$(basename "$LOG_FILE")}
TAIL_LINES=${DIGEST_TAIL_LINES:-80}
MAX_LINES=${DIGEST_MAX_LINES:-40}

if [[ ! -f "$LOG_FILE" ]]; then
  echo "로그 없음: $LOG_FILE"
  exit 0
fi

# xcodebuild / fastlane 이 실패를 알리는 대표 패턴
ERROR_PATTERN='(^|[[:space:]])(error|fatal error):|\[!\]|❌|BUILD FAILED|ARCHIVE FAILED|Testing failed|Undefined symbol|linker command failed|The following build commands failed|Command .* failed with a nonzero exit|ITMS-[0-9]+|Provisioning profile .* (not found|doesn.t)|code signing|No profiles for'

WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT
PLAIN="$WORK/plain.log"
BODY="$WORK/body.txt"

# ANSI 색상/커서 제어 문자를 제거해야 grep 패턴과 요약 길이가 정확해진다.
# BSD sed 는 \x1b 를 해석하지 않으므로 ESC 를 셸에서 직접 만들어 넘긴다.
ESC=$'\033'
# GitHub Actions 아카이브 로그는 ESC 를 "^[" 두 글자로 저장하므로 둘 다 지운다.
LC_ALL=C sed -E "s/(${ESC}|\^\[)\[[0-9;?]*[a-zA-Z]//g; s/\r$//" "$LOG_FILE" > "$PLAIN"

total=$(wc -l < "$PLAIN" | tr -d ' ')
size=$(du -h "$LOG_FILE" | cut -f1 | tr -d ' ')

# 같은 에러가 아키텍처/타깃별로 반복되므로 줄번호를 뺀 본문 기준으로 중복을 제거한다.
grep -nE "$ERROR_PATTERN" "$PLAIN" \
  | awk '{ key = $0; sub(/^[0-9]+:/, "", key); if (!seen[key]++) print }' \
  > "$WORK/errors.txt"
error_total=$(wc -l < "$WORK/errors.txt" | tr -d ' ')

{
  echo "요약: $TITLE — 전체 ${total}줄 / ${size} / 에러 후보 ${error_total}건 (전체 로그는 아티팩트 참고)"
  echo

  if [[ "$error_total" -gt 0 ]]; then
    echo "── 에러 (상위 ${MAX_LINES}건, 앞 숫자는 전체 로그 줄번호) ──"
    head -n "$MAX_LINES" "$WORK/errors.txt"
    if [[ "$error_total" -gt "$MAX_LINES" ]]; then
      echo "... 그 외 $((error_total - MAX_LINES))건 생략"
    fi
    echo
  fi

  if grep -q "The following build commands failed" "$PLAIN"; then
    echo "── 실패한 빌드 커맨드 ──"
    # 실패 목록은 "(N failures)" 줄에서 끝난다. 그 뒤 요약표까지 끌고 오지 않는다.
    sed -n '/The following build commands failed/,$p' "$PLAIN" \
      | awk -v max="$MAX_LINES" 'NR<=max { print } /\([0-9]+ failures?\)/ { exit }'
    echo
  fi

  echo "── 마지막 ${TAIL_LINES}줄 ──"
  tail -n "$TAIL_LINES" "$PLAIN"
} > "$BODY"

# 라이브 로그에서는 접었다 펼 수 있게, 실행 요약 페이지에는 잘리지 않는 형태로 남긴다.
if [[ -n "${GITHUB_ACTIONS:-}" ]]; then
  echo "::group::📋 $TITLE 요약 (${total}줄 → ${error_total} 에러)"
  cat "$BODY"
  echo "::endgroup::"
else
  cat "$BODY"
fi

if [[ -n "${GITHUB_STEP_SUMMARY:-}" ]]; then
  {
    echo "<details><summary>📋 $TITLE — ${total}줄 / ${size} / 에러 ${error_total}건</summary>"
    echo
    echo '```'
    cat "$BODY"
    echo '```'
    echo
    echo "</details>"
  } >> "$GITHUB_STEP_SUMMARY"
fi
