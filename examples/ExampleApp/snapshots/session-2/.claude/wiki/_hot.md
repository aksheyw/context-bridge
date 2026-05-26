---
title: Hot — Current Focus
updated: 2026-05-25
session: 2
---

# 🔥 Hot — ExampleApp

**Session 2 closed 2026-05-25 (Mon, evening).**

## Current phase

`add-task` working end-to-end. Hit a timezone-display bug mid-session and resolved it (see F1 in `_findings.md` — RESOLVED). Schema decided: timestamps stored as ISO 8601 strings with explicit `Z` suffix for UTC.

## Top tasks for next session

1. Implement `list` command (open tasks first, then done; sorted by creation time desc).
2. Implement `done <id>` command (mark a task complete; do not delete).
3. Implement `delete <id>` command (hard-delete, with `--confirm`).
4. First end-to-end pytest covering add → list → done flow.
5. Decide: should `list` accept a `--all` flag to also show done tasks? Lean: yes.

## Open blockers / questions

- [ ] CLI output format: plain text or `--json` flag? Lean: plain text for v1; `--json` deferred.
- [ ] Whether to support task IDs as short-hashes (more typing-friendly) or sequential ints. Lean: sequential ints; simpler.

## Risks

- 🟢 LOW: remaining commands are straightforward variants of `add`.
- 🟢 LOW: timezone bug (F1) was sneaky — re-check that the gotcha promotion (next session) captures the lesson durably.
