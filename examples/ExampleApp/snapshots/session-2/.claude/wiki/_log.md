---
title: Session Log
updated: 2026-05-25
---

# Session Log — ExampleApp

Append-only. Newest entries at the top. One section per session.

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
