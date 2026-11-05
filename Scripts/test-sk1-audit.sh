#!/usr/bin/env bash
# Checks sk1-audit against its fixtures: every rule fires on Native.swift, nothing on Adopted.swift.
set -uo pipefail
cd "$(dirname "$0")/.."
audit=Scripts/sk1-audit.sh
fail=0

out=$("$audit" Tests/AuditFixtures/Adopted.swift 2>&1); code=$?
if [[ $code -ne 0 ]]; then echo "FAIL: Adopted.swift should be clean (exit $code):"; echo "$out"; fail=1; fi

out=$("$audit" Tests/AuditFixtures/Native.swift 2>/dev/null); code=$?
if [[ $code -ne 1 ]]; then echo "FAIL: Native.swift should exit 1, got $code"; fail=1; fi
for rule in form picker segmented stepper slider divider prominent bordered link-button accent material groupbox \
            textfield uppercase progress-ring toggle; do
  if ! grep -q "\[$rule\]" <<<"$out"; then echo "FAIL: rule [$rule] did not fire on Native.swift"; fail=1; fi
done

toggles=$(grep -c "\[toggle\]" <<<"$out")
if [[ $toggles -ne 2 ]]; then echo "FAIL: expected 2 unstyled toggles in Native.swift, found $toggles"; fail=1; fi

"$audit" --warn Tests/AuditFixtures/Native.swift >/dev/null 2>&1 || { echo "FAIL: --warn should exit 0"; fail=1; }

[[ $fail -eq 0 ]] && echo "sk1-audit: all fixture checks passed."
exit $fail
