---
title: Hot — Current Focus
updated: 2026-05-23
session: 1
---

# 🔥 Hot — ExampleApp

**Session 1 closed 2026-05-23 (Sat, evening).**

## Current phase

Bootstrap. Project scope set: solo personal todo CLI. Storage decision landed (SQLite). No code yet.

## Top tasks for next session

1. Scaffold the Python project (`pyproject.toml`, `src/exampleapp/`).
2. Write the SQLite schema + migration runner.
3. Implement `add-task` CLI command with `click`.
4. Write the first pytest for `add-task`.

## Open blockers / questions

- [ ] Whether to store timestamps as Unix epoch (int) or ISO 8601 string. **Decide on first DB schema write.**
- [ ] Whether the CLI should support multiple "lists" (work / personal / etc.) in v1 or defer. **Lean: defer.**

## Risks

- 🟢 LOW: SQLite + Python is well-trodden; minimal unknowns.
- 🟢 LOW: scope creep — explicitly resist adding multi-list, tags, due-dates until v1 is shipping.
