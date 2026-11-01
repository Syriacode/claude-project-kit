# Interview questions: claude-project-kit

## Q1. What does least privilege mean for an AI coding agent, and how do you apply it?

Answer: Least privilege means giving the agent only the access its task needs, and no more. A useful way to
sort actions is by how reversible they are: local, undoable work like building, testing and committing can
run freely, publishing actions need a human's approval, and destructive actions are blocked outright. In this
kit that is exactly the allow, ask and deny split, with `git commit` allowed, `git push` on ask and
`gh repo delete` denied. The same idea applies to the automation around the agent. The CI workflow starts
from `permissions: {}`, grants the job only `contents: read`, and uses `persist-credentials: false` so the
token isn't left behind for later steps. Credentials should also be short-lived and narrowly scoped, so a
mistake or a prompt injection can only do limited damage.

## Q2. Why aren't permission rules a security boundary, and what is?

Answer: Permission rules are patterns matched against command text by the client, so they only stop the
commands you thought to write down. A deny on `git push --force *` doesn't match
`git push origin main --force`, and a command can be wrapped in `bash -c` or a script. More fundamentally,
an allowed `go test` or `npm test` runs whatever code is in the repo, and the agent may have just written
that code. A real boundary is enforced somewhere the agent can't edit or route around. A sandbox, such as
an OS-level sandbox or a container, limits which files and network hosts the process can reach at all.
Token scopes limit what the credentials can do, for example a fine-grained token that can push to one repo
but has no delete or admin rights. Branch protection on GitHub rejects force pushes and unreviewed merges on
the server, no matter who or what sends them.

## Q3. What belongs in a script, and what belongs in an agent's instructions?

Answer: Anything deterministic that must happen the same way every time belongs in a script, because a
script can be tested and doesn't drift. In this kit, `scaffold.sh` validates the repo name, checks it is in
the right folder, fills the templates and refuses to overwrite existing files, and `tests/run.sh` checks all
of that, including special characters in the description. The agent's instructions in `SKILL.md` cover what
needs judgment or conversation: finding the roadmap entry, proposing a name, waiting for confirmation, and
stopping to report when a step fails. The instructions also pin the exact form of the script command, so it
matches the `allowed-tools` entry and runs without a prompt. A good rule of thumb is that if you would write
a test for it, it goes in the script. If it depends on context or needs a human decision, it goes in the
instructions.

## Q4. Why should CI be green from the first commit?

Answer: A build that is already red stops carrying information, because every new failure gets blamed on
the old breakage and ignored. If CI is added later, the first job is paying off the problems that piled up
in the meantime, before CI can protect anything. This kit is a small example: when I added ShellCheck to an
existing repo, the first run failed on warnings in `tests/run.sh` that nobody had noticed. Starting green
means any red build points at the change that just caused it, so it is cheap to find and fix. That is why
`/new-project` scaffolds a passing CI workflow and pushes it in the first commit, before any real code
exists.

## Q5. How do you keep a repo working on both Windows and Linux?

Answer: Line endings are the most common problem: if Git converts a script to CRLF on Windows, bash fails
with errors like `$'\r': command not found`. A `.gitattributes` file with `* text=auto eol=lf` makes Git
keep LF everywhere, and this kit ships one in every generated repo. Bash versions differ too: Git Bash ships
bash 5.2 and Ubuntu a recent bash 5, but macOS still ships bash 3.2. So scripts should use
`#!/usr/bin/env bash` and avoid features newer than the oldest bash they need to support. Tools differ as
well, since Windows has its own `find.exe` and a Git Bash setup may simply lack `shellcheck`, `jq` or `yq`.
Running CI on Linux for every push makes that environment the reference, and running the same
`bash tests/run.sh` locally in Git Bash catches Windows-specific issues early.
