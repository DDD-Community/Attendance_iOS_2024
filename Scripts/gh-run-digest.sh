#!/usr/bin/env bash
# GitHub Actions 실행 로그 전체를 받아 읽는 대신, 실패 스텝만 압축 요약해서 본다.
#
# 사용법: Scripts/gh-run-digest.sh [run-id]
#   run-id 를 생략하면 현재 브랜치의 가장 최근 실행을 쓴다.
set -uo pipefail

cd "$(dirname "$0")/.." || exit 1

RUN_ID=${1:-}
if [[ -z "$RUN_ID" ]]; then
  RUN_ID=$(gh run list --branch "$(git branch --show-current)" --limit 1 \
    --json databaseId --jq '.[0].databaseId')
  [[ -n "$RUN_ID" ]] || { echo "현재 브랜치의 실행을 찾지 못했다"; exit 1; }
fi

gh run view "$RUN_ID"
echo

WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT
RAW="$WORK/run.log"

# 실패 스텝만 받고, 아직 실패가 없으면(진행 중/성공) 전체 로그로 넘어간다.
gh run view "$RUN_ID" --log-failed > "$RAW" 2>/dev/null
if [[ ! -s "$RAW" ]]; then
  # 취소/진행 중인 실행은 아카이브가 없어 --log 도 실패한다. 이때는 gh 의 원인을 그대로 보여준다.
  if ! gh run view "$RUN_ID" --log > "$RAW" 2>"$WORK/err.txt"; then
    echo "로그를 받지 못했다:"
    cat "$WORK/err.txt"
    exit 1
  fi
fi

# gh 는 각 줄을 "job\tstep\t타임스탬프 본문" 으로 주므로 앞 세 필드를 걷어낸다.
sed -E 's/^[^\t]*\t[^\t]*\t[0-9T:.Z-]+ ?//' "$RAW" > "$WORK/clean.log"

exec Scripts/ci-log-digest.sh "$WORK/clean.log" "run $RUN_ID"
