---
title: Session Log
updated: 2026-05-23
---

# Session Log — ExampleApp

Append-only. Newest entries at the top. One section per session.

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
