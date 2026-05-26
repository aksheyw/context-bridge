---
title: Wiki Schema — <project-name>
updated: YYYY-MM-DD
---

# Wiki Schema — <project-name>

This wiki follows the context-bridge convention (which extends Karpathy's [LLM Wiki](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f) pattern). This file documents the shape **for this project**. Adopters can extend the schema; record extensions here so future sessions know what to expect.

---

## Frontmatter

All wiki pages declare YAML frontmatter at the top:

```yaml
---
title: <page title>
updated: YYYY-MM-DD
---
```

Optional fields per page type:
- `session: <N>` (root files — denotes most-recent session number)
- `severity:` / `status:` / `phase:` (findings)
- `confidence:` / `source:` / `tags:` / `aliases:` (heavyweight pages, optional)

If you adopt additional optional fields, list them here so the project lint can recognise them.

---

## Files at root of `.claude/wiki/`

| File | Purpose | Lifecycle |
|---|---|---|
| `_hot.md` | Current focus + open blockers + risks. Cap ~50 lines. | Overwrite each session-close. |
| `_log.md` | Append-only session log. Newest entries at top. | Append-only. |
| `_findings.md` | Open issues, severity-ordered. | Add / update; promote resolved to `gotchas/`. |
| `_schema.md` | This file. | Edit when schema changes. |

## Subdirectories

| Path | Purpose | Filename convention |
|---|---|---|
| `decisions/` | Architectural decisions. One per file. | `d-YYYY-MM-DD-<short-name>.md` |
| `gotchas/` | Promoted findings + surprises. | `gotcha-<topic>.md` |
| `references/` | Durable lookup info (APIs, schemas, external links). | `<topic>.md` |

Subdirectories are created lazily — only when their first file is added.

---

## What goes in (and what doesn't)

**In:** non-obvious, durable knowledge a future session cannot re-derive from code or git log.

**Not in:**
- Anything trivial that `git log` makes clear.
- Conversational notes ("we talked about X").
- Secrets or production IDs (use scrub list + pre-commit hook).
- Personal scratch notes (use `~/.claude/projects/.../memory/` instead).

---

## Project-specific extensions

<add notes here as the project's schema diverges from default>

(None yet.)
