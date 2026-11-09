#!/usr/bin/env bash
# Plain-bash tests for skills/new-project/scripts/scaffold.sh.
# Usage: bash tests/run.sh
# No -e: a failing check is counted and reported, not fatal.
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCAFFOLD="$ROOT/skills/new-project/scripts/scaffold.sh"

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
# Stop git from looking above $TMP, so a parent repo can't affect the tests.
export GIT_CEILING_DIRECTORIES="$TMP"

passed=0
failed=0

# check "<label>" cmd...      passes if the command succeeds
check() {
  local label="$1"
  shift
  if "$@" >/dev/null 2>&1; then
    echo "ok   $label"
    passed=$((passed + 1))
  else
    echo "FAIL $label"
    failed=$((failed + 1))
  fi
}

# check_not "<label>" cmd...  passes if the command fails
check_not() {
  local label="$1"
  shift
  if "$@" >/dev/null 2>&1; then
    echo "FAIL $label"
    failed=$((failed + 1))
  else
    echo "ok   $label"
    passed=$((passed + 1))
  fi
}

# fresh <case> [nogit] -> prints the path of a new, empty demo-vault folder
fresh() {
  local dir="$TMP/$1/demo-vault"
  mkdir -p "$dir"
  if [[ ${2:-} != nogit ]]; then
    git -C "$dir" init -q
  fi
  echo "$dir"
}

# run_in <dir> args...  runs scaffold.sh from inside <dir>
run_in() {
  local dir="$1"
  shift
  (cd "$dir" && bash "$SCAFFOLD" "$@")
}

# only_git <dir>  passes if <dir> holds nothing except .git
# shellcheck disable=SC2329  # called by name through check
only_git() {
  [[ -z "$(find "$1" -mindepth 1 -maxdepth 1 ! -name .git)" ]]
}

count_questions() {
  grep -c '^## Q' "$1"
}

FILES=(README.md INTERVIEW.md CLAUDE.md .gitattributes .gitignore .github/workflows/ci.yml)

# ---- Each language ----
for lang in solidity go typescript; do
  echo "== $lang"
  d="$(fresh "$lang")"
  check "$lang: exits 0" run_in "$d" "$lang" demo-vault "A demo vault" "Plan mode"
  for f in "${FILES[@]}"; do
    check "$lang: $f exists and is not empty" test -s "$d/$f"
  done
  check_not "$lang: no {{ left" grep -qF '{{' "${FILES[@]/#/$d/}"
  check_not "$lang: README has no How I used Claude Code section" grep -qF "How I used Claude Code" "$d/README.md"
  check "$lang: README has description" grep -qF "A demo vault" "$d/README.md"
  check "$lang: README has technique" grep -qF "Plan mode" "$d/README.md"
  check "$lang: INTERVIEW.md has 5 questions" test "$(count_questions "$d/INTERVIEW.md")" = 5
  check "$lang: .gitignore has .env" grep -qxF .env "$d/.gitignore"
done

# ---- Language-specific ----
echo "== language-specific"
d="$(fresh go-main)"
run_in "$d" go demo-vault "desc" >/dev/null 2>&1
check "go: main.go contains repo name" grep -qF '"demo-vault"' "$d/main.go"
check "go: main_test.go exists" test -s "$d/main_test.go"
check_not "go: no {{ in Go files" grep -qF '{{' "$d/main.go" "$d/main_test.go"

d="$(fresh sol-testyml)"
mkdir -p "$d/.github/workflows"
echo "name: forge default" >"$d/.github/workflows/test.yml"
run_in "$d" solidity demo-vault "desc" >/dev/null 2>&1
check_not "solidity: removes existing test.yml" test -e "$d/.github/workflows/test.yml"

d="$(fresh default-technique)"
run_in "$d" typescript demo-vault "desc" >/dev/null 2>&1
check "technique defaults to TODO" grep -qF "| TODO |" "$d/README.md"

# ---- Special characters ----
echo "== special characters"
# shellcheck disable=SC2016  # $HOME must stay literal: that's what we test
tricky='R&D on A/B tests \ with $HOME and "quotes"'
d="$(fresh tricky)"
check "tricky description: exits 0" run_in "$d" go demo-vault "$tricky"
check "tricky description appears exactly in README" grep -qxF "$tricky" "$d/README.md"

# ---- Rejections (nothing may be written) ----
echo "== rejections"
reject() {
  local label="$1" case="$2" mode="$3"
  shift 3
  local d
  d="$(fresh "$case" "$mode")"
  check_not "rejects $label" run_in "$d" "$@"
  check "nothing written after: $label" only_git "$d"
}
reject "unknown language"       r-lang   git   rust demo-vault "desc"
reject "missing arguments"      r-args   git   go demo-vault
reject "uppercase name"         r-upper  git   go Demo-Vault "desc"
reject "name with spaces"       r-space  git   go "demo vault" "desc"
reject "double hyphen"          r-dash   git   go demo--vault "desc"
reject "name differs from folder" r-diff git   go other-name "desc"
reject "folder not a git repo"  r-nogit  nogit go demo-vault "desc"

# ---- Running twice ----
echo "== running twice"
d="$(fresh twice)"
check "first run succeeds" run_in "$d" go demo-vault "desc"
check_not "second run fails" run_in "$d" go demo-vault "desc"

# ---- install.sh (into a temp config dir, never the real ~/.claude) ----
echo "== install"
cfg="$TMP/config"
installed="$cfg/skills/new-project"
mkdir -p "$cfg"
printf '{\n  "theme": "dark"\n}\n' >"$cfg/settings.json"
cp "$cfg/settings.json" "$TMP/settings.before"
# shellcheck disable=SC2329  # called by name through check
install_into() { env CLAUDE_CONFIG_DIR="$1" bash "$ROOT/install.sh"; }

check "install: exits 0" install_into "$cfg"
check "install: SKILL.md exists" test -s "$installed/SKILL.md"
check "install: scaffold.sh exists" test -s "$installed/scripts/scaffold.sh"
check "install: templates exist" test -d "$installed/templates/go"
touch "$installed/stale.txt"
check "reinstall: exits 0" install_into "$cfg"
check_not "reinstall removes stale file" test -e "$installed/stale.txt"
check "install leaves settings.json unchanged" cmp -s "$cfg/settings.json" "$TMP/settings.before"

echo
echo "$passed passed, $failed failed"
exit $((failed > 0))
