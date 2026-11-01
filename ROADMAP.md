# Learning Roadmap: Blockchain Development with Claude Code

**Goals:** become fluent in Claude Code and refresh blockchain development (Solidity, Go, TypeScript),
building a public portfolio aimed at blockchain engineering roles such as Coinbase's *Senior Software Engineer, Stablecoins*.

**Rhythm:** one project per weekday (about 1–1.5 hours), and a bigger one on weekends. Each project gets **its own GitHub repo** and **its own chat**.

---

## How to start each project (new chat)

1. Open a **new chat** with Claude (in the Claude app, linked to your computer).
2. Paste the **starter message** below, and change the last line to the project you're doing.
3. Claude writes and tests a guide. You do the project in **Claude Code** on your computer, step by step, in **plan mode**.
4. When it's pushed, tell that chat "done". Claude reviews your repo and ticks the box in the progress table below.

### Starter message (copy everything in the box)

```
I'm following my learning roadmap: https://github.com/Syriacode/Mini-Blockchain/blob/main/ROADMAP.md
Please attach the Syriacode/Mini-Blockchain repo and read ROADMAP.md first, then follow its "Rules for Claude" section.

Today's project: <write the project name from the roadmap here, e.g. "Week 1 Mon – ETH Vault">
```

---

## Rules for Claude (read these at the start of every new chat)

- **Who I am:** I teach undergrad computer science and grad-level blockchain classes, and I'm preparing for blockchain engineering
  jobs. I'm a bit rusty on blockchain development and still learning Claude Code. I'll look up anything I don't understand.
- **My setup:** Windows with Git Bash; Claude Code in the terminal; Foundry installed; GitHub user **Syriacode**.
  (From Day 0 on: GitHub CLI `gh` and my `/new-project` skill.)
- **Guide format:** write `GUIDE.md` for the project in the same format as
  [upgradeable-stablecoin/GUIDE.md](https://github.com/Syriacode/upgradeable-stablecoin/blob/main/GUIDE.md):
  every step has **Learn → Prompt (for Claude Code, in plan mode) → You check → Done when → Commit**.
  Very low-level steps: exact commands, exact words to type, and what I should see.
- **Size:** a weekday project must fit in **1–1.5 hours**. Weekend projects can be longer.
- **Verify before handing over:** build and test a reference solution privately so every command in the guide works.
  Don't push the solution. I write the code with Claude Code myself.
- **Every project repo must include:** the code, tests, a CI workflow, `README.md` (with a "How I used Claude Code" section
  that I write myself), and **`INTERVIEW.md` with 5 interview questions and model answers**.
- **One Claude Code technique per project** (listed in the tables below). Teach it inside the guide, and end the guide
  with a **"Level up"** tip for using Claude Code more fluently.
- **Repo:** one new public GitHub repo per project under Syriacode. Before Day 0, I create empty repos on github.com.
  After Day 0, my `/new-project` skill creates them.
- **When I say "done":** review my repo (run its tests), give honest feedback, then update the **Progress** table in this
  file in Mini-Blockchain and push.
- **Job descriptions:** when I paste one, map its requirements to existing or new projects and add them to this roadmap.

---

## Progress

| Status | When | Project | Lang | Blockchain concept | Claude Code technique | Repo |
|---|---|---|---|---|---|---|
| ✅ | — | Simple chain | Python | blocks, hashing, proof-of-work | first prompts, reading code | [Mini-Blockchain/01-simple-chain](01-simple-chain) |
| ✅ | — | Upgradeable stablecoin | Solidity | UUPS proxy, roles, minter allowances, pause, blocklist, fuzz/invariant tests | plan mode, CLAUDE.md, `!` commands, break-it-on-purpose testing | [upgradeable-stablecoin](https://github.com/Syriacode/upgradeable-stablecoin) |
| ⬜ | Day 0 | **Project kit** | — | — | **custom skill** (`/new-project`), GitHub CLI, **permission rules** | |

### Week 1: Refresh the basics

| Status | When | Project | Lang | Blockchain concept | Claude Code technique | Repo |
|---|---|---|---|---|---|---|
| ⬜ | Mon | ETH Vault: deposit, withdraw, events | Solidity | payable, mappings, reentrancy | `@file` mentions; **rewind** (Esc Esc) | |
| ⬜ | Tue | 2-of-3 Multisig wallet | Solidity | multi-party approvals, admin-key protection | **test-driven**: failing tests first | |
| ⬜ | Wed | Chain reader CLI: latest block, balances | Go | RPC, blocks, go-ethereum | learning a new language with Claude | |
| ⬜ | Thu | Timelock: delayed admin actions | Solidity | governance, time-based security | **custom subagent** (security reviewer) | |
| ⬜ | Fri | Token balance script | TypeScript | ERC-20 reads, events, viem | **hooks** (auto-format on edit) | |
| ⬜ | Weekend | Deploy and verify a token on Base Sepolia | Solidity | test wallets, faucets, Basescan verification | secrets safety (deny `.env`), `/code-review` | |

### Week 2: Stablecoin-adjacent building blocks

| Status | When | Project | Lang | Blockchain concept | Claude Code technique | Repo |
|---|---|---|---|---|---|---|
| ⬜ | Mon | Merkle airdrop | Solidity + TS | Merkle proofs (rewards distribution) | Claude-written test-data scripts | |
| ⬜ | Tue | Transfer event indexer into SQLite | Go | event logs, indexing, reorgs | **sessions**: `--continue`, `/resume` | |
| ⬜ | Wed | Yield vault (ERC-4626) | Solidity | share accounting, rounding attacks | **context**: `/context`, `/compact`, `/clear` | |
| ⬜ | Thu | Gasless approvals (EIP-2612 permit) | Solidity | signatures, EIP-712, replay protection | debugging: `-vvvv` traces, screenshots | |
| ⬜ | Fri | Mini dApp front end for the testnet token | TypeScript | wallet connection, sending transactions | testing a web page with Claude in a browser | |
| ⬜ | Weekend | Break it, fix it: 4 vulnerable contracts | Solidity | real attack types and fixes | **parallel sessions** (worktrees), `claude -p` | |

After Week 2: review what clicked, then plan Weeks 3–4 (including the Go reserve service and the multi-brand factory for the stablecoin track).

---

## Level-up tips collected so far

1. **Plan mode first** (Shift+Tab): review what Claude intends before it touches files.
2. **Break it on purpose:** after tests pass, have Claude remove a safety check and confirm a test fails. That's how you know the tests protect something.
3. **`CLAUDE.md` is Claude's memory for a repo.** Keep it accurate, because every session reads it.
4. **When Claude does something you'd want every time, turn it into a skill.** (Day 0)
