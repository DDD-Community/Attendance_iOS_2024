#!/bin/zsh

set -euo pipefail

readonly SCRIPT_DIRECTORY="${0:A:h}"
readonly STUDIO_APPLICATION="Maestro Studio"
readonly STUDIO_APPLICATION_PATH="/Applications/${STUDIO_APPLICATION}.app"
readonly STUDIO_EXECUTABLE="/Applications/${STUDIO_APPLICATION}.app/Contents/MacOS/${STUDIO_APPLICATION}"
readonly STUDIO_LOG="${TMPDIR:-/tmp}/ddd-maestro-studio.log"

if [[ ! -x "$STUDIO_EXECUTABLE" ]]; then
  print -u2 "Maestro Studio를 /Applications에 먼저 설치해 주세요."
  exit 1
fi

osascript -e 'tell application "Maestro Studio" to quit' >/dev/null 2>&1 || true

for _ in {1..20}; do
  if ! pgrep -f "$STUDIO_EXECUTABLE" >/dev/null; then
    break
  fi
  sleep 0.25
done

# launchctl 환경은 이미 실행 중인 Orca/터미널 환경에 덮일 수 있다.
# open 프로세스에 PATH를 직접 주어 Studio 서버가 전용 xcrun wrapper를 상속하게 한다.
PATH="$SCRIPT_DIRECTORY/bin:$PATH" open -n "$STUDIO_APPLICATION_PATH"

for _ in {1..40}; do
  if pgrep -f 'dist-server/studio-server.jar' >/dev/null; then
    break
  fi
  sleep 0.25
done

print "Maestro Studio 실행 완료: $STUDIO_LOG"
