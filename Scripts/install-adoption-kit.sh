#!/usr/bin/env bash
# Copies SK1Kit's adoption skill and audit into an app's repository, so any Claude Code session working on the app
# follows the SK-1 recipes (DESIGN.md, "Adopting SK1Kit") and can run the audit:
#
#   Scripts/install-adoption-kit.sh ../MyApp
#
# It writes .claude/skills/adopt-sk1kit/SKILL.md and Scripts/sk1-audit.sh in the app, replacing older copies; run it
# again after updating SK1Kit. Commit both in the app.
set -euo pipefail
if [[ $# -ne 1 || ! -d "$1" ]]; then
  echo "usage: $0 <path to the app's repository>" >&2
  exit 2
fi
kit="$(cd "$(dirname "$0")/.." && pwd)"
app="$(cd "$1" && pwd)"
mkdir -p "$app/.claude/skills/adopt-sk1kit" "$app/Scripts"
cp "$kit/.claude/skills/adopt-sk1kit/SKILL.md" "$app/.claude/skills/adopt-sk1kit/SKILL.md"
cp "$kit/Scripts/sk1-audit.sh" "$app/Scripts/sk1-audit.sh"
chmod +x "$app/Scripts/sk1-audit.sh"
echo "Installed .claude/skills/adopt-sk1kit/SKILL.md and Scripts/sk1-audit.sh in $app"
