#!/bin/zsh
set -euo pipefail

readonly SCRIPT_DIRECTORY="${0:A:h}"

PATH="$SCRIPT_DIRECTORY/bin:$PATH" exec maestro "$@"
