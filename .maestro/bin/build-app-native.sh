#!/bin/zsh

set -o pipefail

readonly PROJECT_ROOT="/Users/suhwonji/Desktop/SideProject/Attendance/Attendance_iOS"
readonly DERIVED_DATA_PATH="/tmp/attendance-e2e-derived"
readonly BUILD_LOG="/tmp/attendance-e2e-build.log"
readonly BUILD_STATUS="/tmp/attendance-e2e-build.status"
readonly BUILD_ARCH="/tmp/attendance-e2e-build.arch"
readonly DESTINATION_ID="${1:-0005A4D1-05C7-4215-9F9A-E8F77DF665B3}"

cd "$PROJECT_ROOT" || exit 1
/usr/bin/uname -m > "$BUILD_ARCH"

/usr/bin/xcrun xcodebuild \
  -workspace DDDAttendance.xcworkspace \
  -scheme DDDAttendance-Stage \
  -configuration Stage \
  -destination "platform=iOS Simulator,id=${DESTINATION_ID}" \
  -derivedDataPath "$DERIVED_DATA_PATH" \
  -jobs 1 \
  build > "$BUILD_LOG" 2>&1

print $? > "$BUILD_STATUS"
