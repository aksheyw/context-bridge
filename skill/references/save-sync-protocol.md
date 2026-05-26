# The 11-step save+sync protocol

> Canonical text. The `/cb-save-sync` command executes this. The numbering is 0-10 (eleven steps total). Each step has a purpose, a fail mode, and a user-gating rule.

> **Provenance:** original work by Akshey Walia, generalised from local `~/.claude/rules/workflow.md`. Step 0 (secret + PII scan) was added during the context-bridge design audit. See [CREDITS.md](../../CREDITS.md) §3.1.

---

## Why eleven steps and not "just commit and push"

A naive "save and sync" loses things. Each step here exists because one of them has, at some point, prevented an actual leak / lost insight / silent skip:

- **Step 0** was added the day a real secret almost shipped to a public repo.
- **Step 6** exists because end-of-session learnings are the highest-value content the wiki ever sees and they get forgotten within hours if not captured then.
- **Step 7** (`_hot.md` bump) is what makes the NEXT session warm — skip it and the warm-resume guarantee evaporates.
- **Step 10** (handoff) compounds the prior 9 — without it, the wiki accumulates but no one ever reads it next time.

The protocol is rigid. The command implements the rigidity; the user-gates (steps 6, 7, 8) are where human judgment stays in the loop.

---

## Step-by-step

### Step 0 — Secret + PII scan (BLOCK on hit)

**Action.** Grep every file about-to-be-staged for known secret prefixes (with entropy required — see `secret-scan-guidance.md`) AND for project-specific proper nouns from `.cb-scrub-list` (gitignored).

**Why.** GitHub secret-scanning catches a lot, but it runs AFTER push, and proper-noun leaks (project codenames, internal URLs, real user IDs) it never catches. Local pre-push beats post-push every time.

**Fail mode.** Block. Print the file, line, and matched pattern. Require user to scrub or whitelist before re-running. No "warn but continue" — a leaked secret is unrecoverable.

**Gating.** Hard block. Not user-overridable in this command.

### Step 1 — Run tests

**Action.** Detect a test command (`package.json` script, `Makefile` target, `pytest`, `cargo test`, `go test`). Run. Capture pass/fail.

**Why.** Saving a broken state is fine; saving it AS-IF it's working state is not. Tests pin the snapshot honestly.

**Fail mode.** Failures surface in the gate report. Do NOT block — the user might be mid-refactor and intentionally saving a failing state for handoff. Prompt: "Continue with save+sync (will record failing state) or abort?"

**Gating.** Soft prompt on failure.

### Step 2 — Local commit

**Action.** Show `git status` + `git diff --stat`. Stage specific files (never `-A`). Draft a conventional commit message. User approves.

**Why.** `git add -A` is how `.env` and `.cb-scrub-list` accidentally get committed. Specific files only.

**Fail mode.** If the user tries to stage something matching a secret pattern, abort (this should have been caught at step 0; if it appears here it's a new edit).

**Gating.** User approves the file list AND the commit message before commit happens.

### Step 3 — Push docs (`.md` only) to remote

**Action.** If the last commit modifies ONLY `.md` files, prompt to push to origin. Else skip and defer to step 4.

**Why.** Docs are low-blast-radius. Pushing docs-only mid-session is a safe remote backup. Pushing code mid-session belongs in a feature branch or `/ship`.

**Fail mode.** Network errors surface; no silent fallback.

**Gating.** Always prompt; never push without explicit yes.

### Step 4 — Push feature branch (if on one)

**Action.** If on a non-default branch, prompt to push as remote backup. If on `main`/`master` with non-doc changes, warn loudly.

**Why.** Feature branch pushes are safe; direct-to-main pushes during save+sync are not — those belong in `/ship`.

**Fail mode.** Warn but don't block on direct-to-main push. The user might know what they're doing.

**Gating.** Always prompt.

### Step 5 — (Optional) Docs lint

**Action.** Run the project's docs-lint command if declared. Skip silently if not.

**Why.** Catches broken markdown links + frontmatter drift before they accumulate.

**Fail mode.** Failures surface; do not block.

**Gating.** No prompt — silent run, surfaced results.

### Step 6 — Wiki sync (USER-GATED, per-item approval)

**Action.** Scan this session's conversation for wiki-worthy candidates: non-obvious bug roots, architectural decisions, drift between code and docs, gotchas in external tools. For EACH candidate, propose a specific file + content + one-line rationale.

**Why.** This is the step where compounded knowledge gets captured. Skip it and the wiki rots; auto-it and the wiki bloats with noise.

**Fail mode.** Nothing to surface → print `⊘ no wiki-worthy learnings this session`. Honest.

**Gating.** Per-item user approval. Never auto-commit wiki edits.

### Step 7 — Bump `_hot.md` + append `_log.md`

**Action.** Update `_hot.md` (current phase, top tasks, blockers, risks; cap ~50 lines). Prepend a new entry to `_log.md` (newest at top).

**Why.** `_hot.md` is what the NEXT session reads first. `_log.md` is the audit trail. Both must update every session or the warm-resume guarantee breaks.

**Fail mode.** If `_hot.md` exceeds 50 lines, archive overflow to `_log.md` rather than letting it bloat.

**Gating.** Show the proposed diff; user approves before write.

### Step 8 — Promote findings

**Action.** For each new major finding from this session, propose a `_findings.md` entry. For each RESOLVED finding with a non-obvious fix, propose promoting it to `gotchas/gotcha-<slug>.md`.

**Why.** Findings track open issues; gotchas track resolved-but-non-obvious traps. Both compound.

**Fail mode.** Nothing to surface → skip cleanly.

**Gating.** Per-item user approval.

### Step 9 — Update memory (if used)

**Action.** If the project uses Claude Code auto-memory (`~/.claude/projects/<slug>/memory/`), surface durable cross-session learnings about the user / project / feedback / references. Propose pages; user approves.

**Why.** Memory is for what's TRUE about how you work; the wiki is for what's TRUE about the project. They overlap rarely but both compound.

**Fail mode.** No memory dir → skip cleanly. Don't auto-create.

**Gating.** Per-item user approval.

### Step 10 — Generate handoff + report gate status

**Action.** Invoke `/cb-handoff` (or inline the same logic). Write `SESSION_HANDOFF_<today>.md` at repo root. Print the gate status report.

**Why.** This is the artifact that makes the next session warm. Without it, the wiki is private value; with it, the wiki transitions into a reusable handoff.

**Fail mode.** If a step earlier blocked, the handoff still generates — but the gate report shows what's red.

**Gating.** Always runs. Never silent.

---

## What "save and sync" is NOT

- **Not `/ship`.** Save+sync NEVER pushes to main outside an explicit user opt-in. It produces commits + remote backups + handoffs; `/ship` is what gates a release.
- **Not auto-commit.** Wiki edits (step 6, 7, 8) require per-item user approval. No exception.
- **Not all-or-nothing.** Steps can be skipped (with `⊘ reason`); only step 0 is hard-block.
- **Not silent.** Every step prints its action and outcome. Visibility is the deal.

---

## When to invoke

- **Always at session close.** Even if the work feels trivial.
- **Before any long break** (overnight, weekend, vacation). Future-you is a different person and needs the handoff.
- **Before swapping projects.** Even mid-day.
- **NOT mid-task.** Save+sync is a punctuation mark, not a comma.
