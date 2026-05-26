---
title: Wiki Schema
updated: 2026-05-26
status: locked
---

# Wiki Schema — context-bridge project

This is context-bridge's own dev wiki. It dogfoods the conventions the skill ships. Schema = lightweight (per Blog precedent).

## Required frontmatter

```yaml
---
title: <page title>
updated: <YYYY-MM-DD>
---
```

## Optional fields

```yaml
status: <draft|locked|superseded>
tags: [<tag1>, <tag2>]
session: <session number>
```

## Files

- `_hot.md` — current focus + open blockers (always-on-top)
- `_log.md` — session log (append-only, reverse chronological)
- `_findings.md` — open issues with severity + phase
- `_schema.md` — this file
- `decisions/d-YYYY-MM-DD-<name>.md` — architectural decisions
- `gotchas/gotcha-<topic>.md` — surprises + fixes

## Principles

- Capture only non-obvious knowledge
- If future sessions can re-derive from code or git log, skip it
- Update `_hot.md` every session
- Append to `_log.md` every session
- Promote major findings to `_findings.md` with severity + phase

## Lifespan

Active development phase = Day 2-3 of OpenAI hackathon week (parallel work). After v0.1 ships, wiki transitions to maintenance mode.
