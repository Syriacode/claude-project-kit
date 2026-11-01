# claude-project-kit

My Claude Code kit for starting each project on my learning roadmap. A personal `/new-project` skill turns a
roadmap entry into a new public GitHub repo with a README, INTERVIEW.md, CLAUDE.md, `.gitattributes`,
`.gitignore` and a CI workflow that is green from the first commit. A set of permission rules lets Claude
build, test and commit on its own, but asks before anything is published and refuses anything destructive.

```text
/new-project Week 1 Mon – ETH Vault
```

The skill reads the roadmap from
[`Syriacode/Mini-Blockchain`](https://github.com/Syriacode/Mini-Blockchain/blob/main/ROADMAP.md) with `gh api`,
proposes a repo name, description and language, and waits for my confirmation before creating anything. It
has `disable-model-invocation: true`, so it only runs when I type `/new-project`, never on Claude's own
initiative.

**Prerequisites:** [`gh`](https://cli.github.com/) logged in (`gh auth login`), plus the toolchain for the
project's language: `forge` (Solidity), `go` (Go) or `node`/`npm` (TypeScript).

## Folder layout

```text
.
├── .github/workflows/ci.yml     # CI for this kit: ShellCheck, JSON/YAML checks, tests
├── settings/permissions.json    # permission rules to merge into ~/.claude/settings.json
├── skills/new-project/
│   ├── SKILL.md                 # the /new-project instructions Claude follows
│   ├── scripts/scaffold.sh      # fills the templates into the freshly cloned repo
│   └── templates/
│       ├── common/              # README, INTERVIEW, CLAUDE.md, gitattributes (all languages)
│       ├── go/                  # ci.yml, gitignore, main.go, main_test.go, run.md
│       ├── solidity/            # ci.yml, gitignore, run.md
│       └── typescript/          # ci.yml, gitignore, run.md
├── tests/run.sh                 # plain-bash tests for scaffold.sh and install.sh
├── install.sh                   # copies the skill into ~/.claude/skills/
├── ROADMAP.md                   # the learning roadmap
└── CLAUDE.md                    # instructions for Claude Code in this repo
```

## Install

1. **Install the skill:**

   ```bash
   bash install.sh
   ```

   This copies `skills/new-project/` to `~/.claude/skills/new-project` (or to `$CLAUDE_CONFIG_DIR/skills/`
   if that variable is set). It deletes the old copy first, so files removed from the repo don't linger.
   Run it again after every change to the skill.

2. **Merge the permission rules.** `install.sh` never touches `settings.json`, because it may already hold
   your own settings. Open `~/.claude/settings.json` and add each entry from `settings/permissions.json` to
   the matching `permissions.allow`, `permissions.ask` or `permissions.deny` array. Keep your existing
   entries, and don't replace the file. For example:

   ```jsonc
   // before
   { "theme": "dark", "permissions": { "allow": ["Bash(ls *)"] } }

   // after
   {
     "theme": "dark",
     "permissions": {
       "allow": ["Bash(ls *)", "Bash(forge build *)", "...the other allow rules..."],
       "ask":   ["Bash(git push *)", "Bash(gh repo create *)"],
       "deny":  ["Bash(gh repo delete *)", "Bash(git push --force *)", "Bash(git push -f *)"]
     }
   }
   ```

   When several rules match a command, **deny** wins over **ask**, and **ask** wins over **allow**.

## Permission rules

| Rule | List | Why |
|---|---|---|
| `Bash(forge build *)` | allow | Compiles contracts locally; changes nothing outside the project. |
| `Bash(forge test *)` | allow | Runs the Solidity tests that "Run it" asks for. |
| `Bash(forge fmt *)` | allow | Formats or checks formatting; only touches project files. |
| `Bash(go build *)` | allow | Local compile, no side effects beyond build output. |
| `Bash(go test *)` | allow | Runs the Go tests that "Run it" and CI rely on. |
| `Bash(go vet *)` | allow | Read-only static analysis. |
| `Bash(gofmt -l *)` | allow | Only lists unformatted files, never rewrites them. |
| `Bash(npm test)` | allow | Runs the TypeScript tests. An exact match, so no extra arguments get through. |
| `Bash(python -m pytest *)` | allow | Runs Python tests locally. |
| `Bash(git add *)` | allow | Local staging; easy to undo. |
| `Bash(git commit *)` | allow | Local history only; undone with `git reset` and nothing leaves the machine. |
| `Bash(gh repo view *)` | allow | Read-only look at a repo. |
| `Bash(gh run list *)` | allow | Read-only; finds the CI run ID. |
| `Bash(gh run view *)` | allow | Read-only; shows a CI run's result and logs. |
| `Bash(gh run watch *)` | allow | Read-only; waits for CI to finish. |
| `Bash(git push *)` | ask | Publishes to a public repo, so a human should decide when. |
| `Bash(gh repo create *)` | ask | Creates a public repo on my account. |
| `Bash(gh repo delete *)` | deny | Can't be undone. |
| `Bash(git push --force *)` | deny | Rewrites published history and can destroy others' commits. |
| `Bash(git push -f *)` | deny | Short form of `--force`, same reason. |

These rules are guardrails, not a security boundary. They match the text of a command, so
`git push origin main --force` doesn't match the deny patterns: it only falls under the `git push` ask rule.
An allowed command like `go test` or `npm test` also runs whatever code is in the repo, and that code could
do anything. The real boundaries are a sandbox, narrowly scoped tokens and branch protection (see Q2 in
[INTERVIEW.md](INTERVIEW.md)).

## Running the tests

```bash
bash tests/run.sh
```

The tests need only bash and git. They run `scaffold.sh` for each language in a temporary folder, check the
generated files, check that bad input is rejected without writing anything, and install the skill into a
temporary `CLAUDE_CONFIG_DIR`, so your real `~/.claude` is never touched. The last line reads
`N passed, 0 failed`, and the script exits non-zero if any check fails.

CI (`.github/workflows/ci.yml`) runs on every push and pull request. It runs ShellCheck on the three
scripts, validates `settings/permissions.json`, every workflow file and SKILL.md's frontmatter with jq and
yq, and then runs `tests/run.sh`.

## How I used Claude Code

### What I delegated

### What I reviewed

### A bug I caught

### Something I changed by hand

### What I'd do differently
