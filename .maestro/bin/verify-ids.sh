#!/bin/zsh
# Maestro 플로우가 참조하는 접근성 ID 가 Swift 소스의 *AccessibilityID.swift 선언과
# 어긋나지 않는지 검사한다. 선언이 사라진 ID 를 참조하면 실패(exit 1)한다.

set -euo pipefail

readonly SCRIPT_DIRECTORY="${0:A:h}"
readonly PROJECT_ROOT="${SCRIPT_DIRECTORY:h:h}"

cd "$PROJECT_ROOT" || exit 1

exec /usr/bin/python3 - "$@" <<'PY'
import glob
import re
import sys

FLOW_GLOB = ".maestro/flows/**/*.yaml"
SOURCE_GLOB = "Projects/Feature/*/Sources/Accessibility/*AccessibilityID.swift"

# 선언부 수집: "management.staff.root" 같은 고정 ID 와
# "management.schedule.card.\(id)" 같은 보간 ID 의 접두사를 분리한다.
literals: set[str] = set()
prefixes: set[str] = set()

for path in sorted(set(glob.glob(SOURCE_GLOB))):
    with open(path, encoding="utf-8") as file:
        # 주석에 인용부호로 적은 설명 문구가 ID 로 잡히지 않도록 주석 줄은 걸러낸다.
        lines = [line for line in file if not line.lstrip().startswith("//")]
    for raw in re.findall(r'"([^"\n]*)"', "".join(lines)):
        head = raw.split("\\(")[0]
        if not head:
            continue
        if "\\(" in raw:
            prefixes.add(head)
        else:
            literals.add(raw)

# 사용부 수집: env 변수(${...})는 호출 측에서 값을 넘기므로 검사 대상에서 제외한다.
used: dict[str, list[str]] = {}
for path in sorted(set(glob.glob(FLOW_GLOB, recursive=True))):
    with open(path, encoding="utf-8") as file:
        for number, line in enumerate(file, start=1):
            match = re.search(r'^\s*(?:-\s*)?id:\s*"([^"]+)"', line)
            if not match:
                continue
            identifier = match.group(1)
            if "${" in identifier:
                continue
            used.setdefault(identifier, []).append(f"{path}:{number}")


def is_declared(identifier: str) -> bool:
    if identifier in literals:
        return True
    # Maestro 의 id 는 정규식이라 "...card.*" 처럼 뒤가 열려 있을 수 있다.
    # 보간 ID 는 접두사만 일치하면 유효한 것으로 본다.
    if any(identifier.startswith(prefix) for prefix in prefixes):
        return True
    # 고정 ID 를 정규식으로 좁혀 쓴 경우(예: "member.schedule.[0-9]+")를 허용한다.
    return any(re.fullmatch(identifier, literal) for literal in literals)


orphans = {key: value for key, value in used.items() if not is_declared(key)}

print(f"선언 ID: 고정 {len(literals)}개, 보간 {len(prefixes)}개")
print(f"플로우 참조 ID: {len(used)}개")

if orphans:
    print("\n선언되지 않은 ID:")
    for identifier in sorted(orphans):
        for location in orphans[identifier]:
            print(f"  {identifier}  <-  {location}")
    sys.exit(1)

unused = sorted(literals - set(used))
if unused:
    print(f"\n참고: 플로우에서 아직 쓰지 않는 고정 ID {len(unused)}개")
    for identifier in unused:
        print(f"  {identifier}")

print("\n접근성 ID 계약 일치")
PY
