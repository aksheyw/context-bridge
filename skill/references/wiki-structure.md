# Wiki structure

> The shape that `/cb-init` scaffolds. Adopters extend; this file documents the baseline.

> **Provenance:** the wiki shape extends Andrej Karpathy's [LLM Wiki pattern](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f). What's new in context-bridge vs. the original: see [karpathy-schema-delta.md](karpathy-schema-delta.md).

---

## Filesystem layout

```
.claude/wiki/
├── _hot.md              # Current focus + open blockers (always-on-top)
├── _log.md              # Append-only session log (newest at top)
├── _findings.md         # Open issues, severity-ordered
├── _schema.md           # Project's wiki schema (this file's per-project mirror)
├── decisions/
│   └── d-YYYY-MM-DD-<slug>.md   # One decision per file
├── gotchas/
│   └── gotcha-<topic>.md        # Promoted from resolved findings + observed traps
└── references/
    └── <topic>.md       # Durable lookup info (APIs, schemas, external links)
```

Subdirectories are created lazily — only when their first file is added.

---

## Filename conventions

| Pattern | Used for | Examples |
|---|---|---|
| `_<name>.md` | Root-level always-on files | `_hot.md`, `_log.md`, `_findings.md`, `_schema.md` |
| `d-YYYY-MM-DD-<slug>.md` | Decisions | `d-2026-05-26-postgres-over-mongo.md` |
| `gotcha-<topic>.md` | Gotchas | `gotcha-aws-sigv4-clock-skew.md` |
| `<topic>.md` | References | `openrouter-models.md`, `webhook-payload-shape.md` |

All filenames: lowercase, dashes, no spaces, no leading numbers (except date prefix on decisions).

---

## Frontmatter

All wiki pages declare YAML frontmatter at the top:

```yaml
---
title: <page title>
updated: YYYY-MM-DD
---
```

### Optional fields

| Field | Used by | Type | Example |
|---|---|---|---|
| `session: <N>` | `_hot.md`, `_log.md` | int | `session: 7` |
| `status:` | `_findings.md` entries, gotchas, decisions | enum | `OPEN`, `RESOLVED`, `accepted` |
| `severity:` | `_findings.md` entries | enum | `🔴 CRITICAL`, `🟡 HIGH`, `🟢 MEDIUM`, `🟢 LOW` |
| `phase:` | `_findings.md` entries | string | `before-v0.1-ship` |
| `confidence:` | reference pages | enum | `high`, `medium`, `low`, `verified` |
| `source:` | reference pages | URL or path | `https://...` or `internal: docs/X.md` |
| `tags:` | any | string list | `[backend, auth, security]` |
| `aliases:` | any | string list | `[old-name, alt-name]` |
| `related:` | any | wiki-link list | `[[d-2026-05-26-postgres-over-mongo]]` |

Projects can declare additional optional fields in their `_schema.md`. Anything declared there is treated as expected; anything else triggers a lint warning.

---

## Page-type contracts

### `_hot.md` (cap ~50 lines)

Required sections:
- `# 🔥 Hot — <project-name>` header
- "Current phase" — one paragraph
- "Top tasks for next session" — numbered list (3-7 items)
- "Open blockers / questions" — bulleted, checkboxes
- "Risks" — bulleted, severity-prefixed

Updated at every session close (step 7 of save+sync). If a section would exceed ~50 lines, archive overflow to `_log.md`.

### `_log.md` (append-only, newest at top)

One section per session:

```markdown
## Session <N> — YYYY-MM-DD — <short title>

**Closed:** YYYY-MM-DD
**Duration:** ~<min>
**Focus:** <one line>

**Done:** <bullets>
**Decisions:** <bullets, or "none">
**Findings opened:** <id list, or "none">
**Next:** see `_hot.md`.
```

Never edit prior entries; only prepend new ones.

### `_findings.md` (severity-ordered)

One section per finding:

```markdown
## F<id> — <short title>
**Severity:** 🔴 CRITICAL / 🟡 HIGH / 🟢 MEDIUM / 🟢 LOW
**Status:** OPEN / IN PROGRESS / RESOLVED / ACCEPTED
**Phase to fix:** <e.g. before-ship>
**Detail:** <what is wrong, where, what the impact is>
**Mitigation:** <interim mitigation; or, if RESOLVED, the resolution>
```

ID is monotonic (`F1`, `F2`, ...). Once assigned, never re-used. Resolved findings with non-obvious fixes get promoted to `gotchas/gotcha-<slug>.md`; the entry in `_findings.md` is updated to `✅ RESOLVED` with a pointer to the gotcha.

### `_schema.md` (the per-project mirror of this file)

Documents the shape THIS project uses, including any extensions to the baseline. Updated when the schema changes. Lints expect this file to exist.

### `decisions/d-YYYY-MM-DD-<slug>.md`

```markdown
---
title: <decision title>
updated: YYYY-MM-DD
status: accepted | proposed | superseded
---

# Decision — <title>

**Context:** <why a choice was needed>
**Decision:** <what was chosen>
**Alternatives rejected:** <list + one-line reason each>
**Consequences:** <what this locks in / unlocks>
```

If superseded, set `status: superseded` and link the replacement decision in the body. Never delete a decision.

### `gotchas/gotcha-<topic>.md`

```markdown
---
title: <short title>
updated: YYYY-MM-DD
status: open | resolved
---

# Gotcha — <short title>

**Symptom:** <what looked wrong>
**Root cause:** <what was actually wrong>
**Fix:** <what worked>
**Why it's non-obvious:** <one sentence on why this would bite again>
```

### `references/<topic>.md`

Free-form. Use frontmatter to mark confidence and source. Good fits:
- External API quirks + payload shapes
- Schema dumps (when the schema isn't auto-derivable)
- Cross-tool integration notes
- Vendor-specific gotchas that don't fit `gotchas/` shape

---

## What goes in (and what doesn't)

### In
Non-obvious, durable knowledge a future session cannot re-derive from code or `git log`.

### Not in
- Anything trivial that `git log` makes clear.
- Conversational notes ("we talked about X").
- Secrets, tokens, real project IDs (use scrub list + pre-commit hook).
- Personal scratch notes (use Claude Code memory at `~/.claude/projects/<slug>/memory/` instead).
- WIP TODOs that belong in an issue tracker.

---

## Schema extensions per project

Add to `_schema.md` under "Project-specific extensions". Examples:

- "All `references/api-*.md` pages must declare `source:` pointing at the upstream docs URL."
- "`decisions/` entries for this project also include a `cost-impact:` field."
- "We use `gotchas/external-<vendor>-<topic>.md` instead of plain `gotcha-<topic>.md`."

Extensions are project-local. They don't change the baseline; they document what THIS project has layered on top.

---

## Linting (deferred — v0.2)

A wiki lint will check: frontmatter presence + required fields, monotonic finding IDs, broken `[[wiki-links]]`, stale `updated:` dates (>30 days on root files), orphan files (no inbound links from any other page).

v0.1 has no automated lint; the conventions in this file are the spec.
