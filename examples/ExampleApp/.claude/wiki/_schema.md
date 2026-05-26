---
title: Wiki Schema — ExampleApp
updated: 2026-05-26
---

# Wiki Schema — ExampleApp

This wiki follows the context-bridge convention (which extends Karpathy's [LLM Wiki](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f) pattern).

---

## Frontmatter

All wiki pages declare YAML frontmatter at the top:

```yaml
---
title: <page title>
updated: YYYY-MM-DD
---
```

Optional fields used by ExampleApp:
- `session: <N>` on `_hot.md` (most-recent session number)
- `status:` on decisions (`accepted` / `proposed` / `superseded`)

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

Subdirectories are created lazily — only when their first file is added.

---

## Project-specific extensions

(None yet.)
