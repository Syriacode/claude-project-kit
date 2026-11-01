#!/usr/bin/env bash
# Install the /new-project skill into Claude Code's personal skills folder.
# Usage: bash install.sh
# Target: ${CLAUDE_CONFIG_DIR:-$HOME/.claude}/skills/new-project
# Never touches settings.json.
set -euo pipefail

src="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/skills/new-project"
config="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
dest="$config/skills/new-project"

if [[ ! -f $src/SKILL.md ]]; then
  echo "error: $src/SKILL.md not found" >&2
  exit 1
fi

mkdir -p "$config/skills"
# Delete the old copy first, so files removed from the repo don't linger.
rm -rf "$dest"
cp -R "$src" "$dest"

echo "installed /new-project to $dest"
