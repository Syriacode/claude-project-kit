---
name: new-project
description: Create a new public GitHub repo for a project from my learning roadmap, with README, INTERVIEW.md, CLAUDE.md and a green CI workflow.
argument-hint: "[roadmap project, e.g. Week 1 Mon – ETH Vault]"
disable-model-invocation: true
allowed-tools: 'Bash(gh api -H "Accept: application/vnd.github.raw" repos/Syriacode/Mini-Blockchain/contents/ROADMAP.md) Bash(bash ~/.claude/skills/new-project/scripts/scaffold.sh *)'
---

# New project from the roadmap

Create a new public GitHub repo for the roadmap project: $ARGUMENTS

**If any step fails, stop and tell me what failed and the error output. Don't work around it or skip ahead.**

1. **Find the project.** Run exactly:

   ```bash
   gh api -H "Accept: application/vnd.github.raw" repos/Syriacode/Mini-Blockchain/contents/ROADMAP.md
   ```

   Find the row matching `$ARGUMENTS` and note its **Project**, **Lang** and **Claude Code technique**. If `$ARGUMENTS` is empty or no row matches, list the unchecked projects and ask me which one I mean.

2. **Propose and confirm.** Propose:
   - a kebab-case repo name (lowercase letters and digits, single hyphens)
   - a one-sentence description (no double quotes, since it goes inside `"..."` in shell commands)
   - the language: `solidity`, `go` or `typescript` ("Solidity + TS" means `solidity`)
   - the technique, copied as-is from the roadmap

   Check that the current folder is **not** inside a git repo (`git rev-parse --is-inside-work-tree` must fail) and has no folder with that name. Then ask me to confirm, and **wait for my answer** before continuing.

3. **Create and clone the repo.**

   ```bash
   gh repo create Syriacode/<name> --public --description "<description>" --clone
   cd <name>
   git branch -M main
   ```

   Explain to me: the new repo is empty, so `git branch -M main` makes sure the local branch is called `main`, and the first push goes to `main`.

4. **Language setup.**
   - solidity: `forge init --force`
   - go: `go mod init github.com/Syriacode/<name>`
   - typescript: `npm init -y`, then `npm pkg set scripts.test="node --test"`, then `npm install`

5. **Scaffold.** Run exactly this form (it must match the allowed command):

   ```bash
   bash ~/.claude/skills/new-project/scripts/scaffold.sh <language> <name> "<description>" "<technique>"
   ```

6. **Check locally.** Run the commands under "## Run it" in the new `README.md` and show me the output. All of them must pass.

7. **Commit, push and watch CI.**

   ```bash
   git add -A
   git commit -m "Scaffold project with /new-project"
   git push -u origin main
   ```

   Then get the CI run's ID. The run can take a few seconds to appear, so repeat this a few times, a few seconds apart, until it prints an ID:

   ```bash
   gh run list --branch main --limit 1 --json databaseId --jq '.[0].databaseId'
   ```

   Then watch it (a bare `gh run watch` needs an interactive terminal, so always pass the ID):

   ```bash
   gh run watch <id> --exit-status
   ```

   Report whether CI passed.

8. **Finish.** Tell me:
   - the repo URL
   - the CI result
   - the next step: open a new chat in the Claude app with the roadmap starter message for $ARGUMENTS, so it can write `GUIDE.md`
