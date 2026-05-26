---
description: Run the 11-step save+sync protocol at session close. Wiki update + commit + handoff. User-gated at sensitive steps.
---

# /cb-save-sync

You are running the context-bridge `/cb-save-sync` command. The user is closing a session. Execute the 11-step protocol in order. Stop on blockers; never silently skip a step.

Print a one-line header before each step so the user can see progress:

```
[STEP N/11] <action>
```

Steps are numbered 0-10 (11 steps total). N is the step's number; the denominator 11 is the count. So progress reads `[STEP 0/11] ... [STEP 10/11]`.

---

## Step 0 — Secret + PII scan (BLOCK on hit)

1. Identify files touched this session via `git status --porcelain` and any uncommitted changes.
2. For each file about to be staged, scan for:
   - **Secrets:** `sk-`, `sk-or-v1-`, `ghp_`, `gho_`, JWT (`eyJ[A-Za-z0-9_=-]+\.[A-Za-z0-9_=-]+\.`), Telegram bot tokens (`[0-9]{8,12}:[A-Za-z0-9_-]{30,50}`), `BEGIN [A-Z]+ PRIVATE KEY`.
   - **PII / proper nouns:** if the project has `.cb-scrub-list` (gitignored, one pattern per line), grep each file against it.
3. On ANY hit: STOP. Print the file + line + matched pattern. Tell the user to scrub or whitelist before re-running. Do NOT proceed to step 1.

If clean, print `step 0 ✅ clean` and continue.

## Step 1 — Run tests

1. Detect a test command in this order: `package.json` script `test`, `Makefile` target `test`, `pytest.ini` / `pyproject.toml`, `cargo test`, `go test ./...`. If no command detected, skip with `step 1 ⊘ no test command detected`.
2. Run the detected command. Capture pass/fail counts.
3. If failures: flag them, but do NOT block. Ask user: "Tests failing. Continue with save+sync (will record failing state) or abort?"
4. If a CLAUDE.md test count field is present (e.g. `**Tests:** N passing`), update it if the count changed.

## Step 2 — Local commit

1. Show the user `git status` + `git diff --stat`.
2. Ask: "Stage which files? (default: list each modified file you want; never `-A`)"
3. Use `git add <files>` with the specific list. Never `git add -A` or `git add .` — those risk pulling in `.cb-scrub-list`, `.env`, etc.
4. Draft a conventional commit message: `<type>: <description>` where type is `feat / fix / refactor / docs / test / chore / perf / ci`.
5. Show the draft. User approves or edits. Commit with the approved message.

## Step 3 — Push docs (`.md` only) to remote

1. Check current branch + upstream tracking.
2. If the last commit modifies ONLY `.md` files, prompt: "Push docs-only commit to `origin/<branch>`?" — if yes, push.
3. If the last commit touches non-`.md` files, skip and defer to step 4 (feature branch push).

## Step 4 — Push feature branch (if on one)

1. If `git branch --show-current` is NOT `main` / `master`, this is a feature branch. Prompt: "Push `<branch>` as remote backup?" — if yes, push.
2. If on `main` / `master` with non-doc changes, warn: "Pushing non-doc changes directly to main. Confirm?"

## Step 5 — (Optional) Docs lint

If the project declares a docs-lint command (e.g. `make docs-lint`, a `lint:docs` script), run it. Otherwise skip with `step 5 ⊘ no docs lint configured`.

## Step 6 — Wiki sync (USER-GATED, per-item approval)

1. Re-read this session's user messages + your responses (in conversation memory).
2. Scan for candidates:
   - Bugs with non-obvious root causes → propose `gotchas/gotcha-<slug>.md`.
   - Architectural decisions made → propose `decisions/d-YYYY-MM-DD-<slug>.md`.
   - Drift discovered between code and docs → propose updates to the relevant wiki page.
   - New gotchas in external tools → propose `gotchas/`.
3. For EACH candidate, show:
   - Proposed file path
   - Proposed content (full diff if updating, full new file if creating)
   - One-line rationale ("you'll thank yourself next session because…")
4. User approves / edits / skips per item. NEVER auto-commit wiki edits without explicit approval.
5. Approved edits get written. They will be included in step 2's commit — if step 2 already happened, create a follow-up commit.

If no candidates surfaced, print `step 6 ⊘ no wiki-worthy learnings this session`.

## Step 7 — Bump `_hot.md` + append `_log.md`

Always run. Always gated on user confirmation of the proposed content.

### `_hot.md` update

1. Read current `_hot.md`.
2. Increment `session: N` in frontmatter.
3. Update `updated: YYYY-MM-DD`.
4. Rewrite "Current phase" + "Top tasks for next session" + "Open blockers" + "Risks" sections from this session's state.
5. Cap total length at ~50 lines. Archive overflow to `_log.md`.
6. Show diff. User approves. Write.

### `_log.md` append

1. Prepend (newest-at-top) a new session block:

```markdown
## Session <N> — YYYY-MM-DD — <short title>

**Closed:** YYYY-MM-DD
**Duration:** <approx min>
**Focus:** <one line>

**Done:**
- <bullet>
- <bullet>

**Decisions:**
- <bullet, or "none">

**Findings opened:** <id list, or "none">

**Next:** see `_hot.md`.
```

2. Show diff. User approves. Write.

## Step 8 — Promote findings

1. For each new major finding surfaced this session, propose an entry for `_findings.md` (use the format from `cb-ingest.md` step 4 finding format).
2. For each finding resolved with a non-obvious fix, propose promoting it to `gotchas/gotcha-<slug>.md`.
3. User approves per item.

## Step 9 — Update memory (if used)

If the project uses Claude Code auto-memory (`~/.claude/projects/<project-slug>/memory/`):

1. Surface candidates for new memory pages — durable, cross-session learnings about the user / project / feedback / references.
2. Propose. User approves. Write the page + update `MEMORY.md` index.
3. If memory dir doesn't exist, skip with `step 9 ⊘ no project memory dir`.

## Step 10 — Generate handoff + report gate status

1. Invoke `/cb-handoff` (or inline the same logic): generate the handoff prompt and write it to `SESSION_HANDOFF_<today>.md` at repo root.
2. Print the gate status report:

```
context-bridge save+sync — <today>
  step 0 secret/PII scan  : ✅ clean
  step 1 tests            : <pass count> / <fail count>
  step 2 commit           : <sha>
  step 3 push (docs)      : <pushed | skipped>
  step 4 push (branch)    : <pushed | n/a>
  step 5 docs lint        : <ok | skipped>
  step 6 wiki sync        : <N edits | none>
  step 7 _hot / _log      : ✅ updated
  step 8 findings         : <N new | none>
  step 9 memory           : <N pages | n/a>
  step 10 handoff         : ✅ → SESSION_HANDOFF_<today>.md

  Ready for /ship?        : <yes | no — reason>
```

## Honesty + safety

- **Never silently skip.** Print `⊘ skipped — <reason>` for any step that doesn't apply.
- **Never auto-commit wiki edits** without per-item user approval (step 6 + 7 + 8).
- **Never use `git add -A`** — always specific files.
- **Never push to main outside an explicit user opt-in.** This command is "save and sync", not "ship". The dedicated `/ship` command (or equivalent) is what puts code on main.
- If any step errors, STOP, print what happened, leave the project in a recoverable state. Do not attempt rollback.
