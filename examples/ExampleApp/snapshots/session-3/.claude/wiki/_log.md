---
title: Session Log
updated: 2026-05-26
---

# Session Log — ExampleApp

Append-only. Newest entries at the top. One section per session.

---

## Session 3 — 2026-05-26 — Warm resume; `list` / `done` / `delete` shipped

**Closed:** 2026-05-26 (Tue, evening)
**Duration:** ~2.5h
**Focus:** Warm-resume from the SESSION_HANDOFF_2026-05-25.md handoff. Implement the remaining CRUD commands. Promote F1 to a gotcha.

**Done:**
- Warm-resume worked: pasted the handoff prompt; Claude summarised the 5 bullets correctly and asked the 3 questions before touching code.
- Implemented `list` command (sequential int IDs, plain text output, open tasks first then done, sorted by created_at desc). `--all` flag accepted.
- Implemented `done <id>` command.
- Implemented `delete <id> --confirm` command. Hard-delete (no soft-delete table).
- Wrote E2E pytest covering add → list → done → delete.
- Promoted F1 timezone-display finding to `gotchas/gotcha-timezones-display.md` with the three-rule lesson.

**Decisions:**
- Task IDs: sequential ints (rejected: short hashes).
- `list --all`: accepted as a flag on `list` (rejected: separate `list-all` command).
- CLI output: plain text for v1 (rejected: `--json` flag — deferred to v1.1).
- Delete: hard-delete with `--confirm` (rejected: soft-delete trash table).

**Findings opened:** none.

**Findings closed:** F1 (RESOLVED + promoted to gotcha).

**Next:** see `_hot.md`. Packaging + tagging v1.0.0.

---

## Session 2 — 2026-05-25 — `add-task` + timezone bug

**Closed:** 2026-05-25 (Mon, evening)
**Duration:** ~2h
**Focus:** Implement `add-task` end-to-end. Got blocked on a timestamp-display issue; resolved in session.

**Done:**
- Scaffolded Python project: `pyproject.toml`, `src/exampleapp/{__init__.py,cli.py,storage.py}`, `tests/`.
- Wrote SQLite schema: `tasks(id INTEGER PRIMARY KEY, text TEXT NOT NULL, created_at TEXT NOT NULL, done INTEGER NOT NULL DEFAULT 0)`. Migration runner reads `schema_version` table; runs all migrations > current.
- Implemented `add-task <text>` via `click`.
- Hit F1 (timezone-display bug). Resolved by storing timestamps as ISO 8601 strings with explicit `Z` UTC suffix, parsing back to `datetime` with `astimezone()` for display in local time.
- Wrote first pytest for `add-task` — passing.

**Decisions:**
- Timestamp format: ISO 8601 UTC strings. Decision recorded inline in F1 resolution; no separate `decisions/` page needed (covered by the gotcha promoted next session).

**Findings opened:**
- **F1** — timezone-display bug. Status: RESOLVED (same session). To be promoted to `gotchas/` next session.

**Next:** see `_hot.md`. `list` / `done` / `delete` commands next.

---

## Session 1 — 2026-05-23 — Scope + storage choice

**Closed:** 2026-05-23 (Sat, evening)
**Duration:** ~90 min
**Focus:** Scope the project. Decide on storage backend. No implementation yet.

**Done:**
- Defined v1 scope: single-list todo CLI; add / list / done / delete; no due-dates / tags / multi-list.
- Decided storage: SQLite single file at `~/.exampleapp/todos.db`. Rejected: JSON file, plaintext lines.
- Bootstrapped `.claude/wiki/` via `/cb-init`.
- Wrote first decision page: `decisions/d-2026-05-23-storage-sqlite-vs-json.md`.

**Decisions:**
- Storage: SQLite. See `decisions/d-2026-05-23-storage-sqlite-vs-json.md`.

**Findings opened:** none.

**Next:** see `_hot.md`. First code session writes the schema + migration runner.
