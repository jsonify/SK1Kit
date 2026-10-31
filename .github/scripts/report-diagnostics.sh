#!/usr/bin/env bash
# Turns the compiler's warnings and errors in our own sources (Sources/ and Tests/) in the logs given into annotations
# on the run, and adds a notice with how many there were, so they show on the run's page and through the API without
# reading the logs. It never fails the job itself: the build step's -warnings-as-errors does that.
set -uo pipefail
warnings=0
errors=0
found=$(mktemp)
for log in "$@"; do
  [ -f "$log" ] && grep -E '^/[^:]+/(Sources|Tests)/[^:]+:[0-9]+:[0-9]+: (warning|error): ' "$log"
done | sort -u > "$found"
while IFS= read -r line; do
  file=${line%%:*}; rest=${line#*:}
  number=${rest%%:*}; rest=${rest#*:}
  column=${rest%%:*}; rest=${rest#*: }
  kind=${rest%%:*}; message=${rest#*: }
  if [ "$kind" = warning ]; then warnings=$((warnings + 1)); else errors=$((errors + 1)); fi
  echo "::$kind file=${file#"${GITHUB_WORKSPACE:-}"/},line=$number,col=$column::$message"
done < "$found"
echo "::notice title=Compiler diagnostics::$warnings warnings, $errors errors in Sources/ and Tests/ ($*)"
exit 0
