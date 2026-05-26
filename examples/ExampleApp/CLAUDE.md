# ExampleApp

A small personal CLI todo tool. Solo project. Built for the maintainer's own use; not distributed.

## Stack

- Language: Python 3.11+
- Storage: SQLite (single file, `~/.exampleapp/todos.db`) — see `.claude/wiki/decisions/d-2026-05-23-storage-sqlite-vs-json.md`
- CLI framework: `click`
- Tests: `pytest`

<!-- context-bridge:begin -->
<!--
  This section was appended by /cb-init from the context-bridge skill.
  Repo: https://github.com/aksheyw/context-bridge
  Safe to edit anything between context-bridge:begin and context-bridge:end.
  /cb-init is idempotent — re-running it will NOT duplicate this block.
-->

## Session protocol (context-bridge)

This project uses a per-session wiki at `.claude/wiki/`. Read these in order at session start:

1. `.claude/wiki/_hot.md` — current focus + open blockers (always-on-top).
2. `.claude/wiki/_log.md` — last session entry (top of file).
3. `.claude/wiki/_findings.md` — open issues, severity-ordered.

For the most recent handoff, also read `SESSION_HANDOFF_<latest-date>.md` at repo root if present.

When the user says "save and sync" at session close, run `/cb-save-sync` — it executes the 11-step protocol and then `/cb-handoff` prints the next-session prompt.

## Honesty (inherited from context-bridge)

Two rules. Both are non-negotiable for this project.

### Never fabricate

No file paths, function names, line numbers, or API signatures stated without verification via Read / Grep / Glob. If you don't have it, say so plainly.

### Earned confidence (95% gate)

"95% confident" requires full end-to-end homework:
- Traced the code path from caller to result.
- Verified data shape at each boundary (DB → API → UI).
- Checked the failure modes.
- Read tests if they exist; ran them if possible.

Default to a verbal hedge. Reserve "95% confident" for AFTER the homework.

<!-- context-bridge:end -->
