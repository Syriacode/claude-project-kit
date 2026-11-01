#!/usr/bin/env bash
# Fill in the /new-project templates inside a freshly cloned repo.
#
# Usage: scaffold.sh <solidity|go|typescript> <repo-name> "<description>" ["<technique>"]
# Run it from the root of the cloned repo. The folder name must equal <repo-name>.
#
# Exit codes: 0 ok, 1 wrong environment (not a git repo, wrong folder, already
# scaffolded), 2 bad arguments.
set -euo pipefail

# Templates live next to this script, wherever it is called from.
TEMPLATES="$(cd "$(dirname "${BASH_SOURCE[0]}")/../templates" && pwd)"

usage() {
  echo "usage: scaffold.sh <solidity|go|typescript> <repo-name> \"<description>\" [\"<technique>\"]" >&2
  exit 2
}

die() {
  echo "error: $1" >&2
  exit "${2:-1}"
}

# ---- 1. Validate everything before writing any file ----

if [[ $# -lt 3 || $# -gt 4 ]]; then
  usage
fi

lang="$1"
name="$2"
description="$3"
technique="${4:-TODO}"

case "$lang" in
  solidity | go | typescript) ;;
  *) echo "error: unknown language '$lang'" >&2; usage ;;
esac

# Regex kept in a variable: quoting it inside [[ =~ ]] would make it a literal string.
name_re='^[a-z0-9]+(-[a-z0-9]+)*$'
if ! [[ $name =~ $name_re ]]; then
  die "repo name '$name' must be lowercase letters/digits separated by single hyphens" 2
fi

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  die "not inside a git work tree; run this from the cloned repo"
fi

folder="$(basename "$PWD")"
if [[ $folder != "$name" ]]; then
  die "current folder is '$folder' but repo name is '$name'"
fi

if [[ -e INTERVIEW.md ]]; then
  die "INTERVIEW.md already exists; this repo looks already scaffolded"
fi

# ---- 2. Render templates ----

run_text="$(<"$TEMPLATES/$lang/run.md")"

# render <template path under templates/> <destination path>
# The replacements are quoted ("$name"), so bash inserts them literally:
# & \ / $ and quotes in the description come through unchanged.
render() {
  local text
  text="$(<"$TEMPLATES/$1")"
  text="${text//"{{NAME}}"/"$name"}"
  text="${text//"{{DESCRIPTION}}"/"$description"}"
  text="${text//"{{LANG}}"/"$lang"}"
  text="${text//"{{TECHNIQUE}}"/"$technique"}"
  text="${text//"{{RUN}}"/"$run_text"}"
  mkdir -p "$(dirname "$2")"
  printf '%s\n' "$text" >"$2"
  echo "wrote $2"
}

render common/README.md README.md
render common/INTERVIEW.md INTERVIEW.md
render common/CLAUDE.md CLAUDE.md
render common/gitattributes .gitattributes
render "$lang/gitignore" .gitignore
render "$lang/ci.yml" .github/workflows/ci.yml

case "$lang" in
  solidity)
    # forge init creates its own workflow; ours replaces it.
    if [[ -e .github/workflows/test.yml ]]; then
      rm -f .github/workflows/test.yml
      echo "removed .github/workflows/test.yml"
    fi
    ;;
  go)
    render go/main.go main.go
    render go/main_test.go main_test.go
    ;;
esac
