---
title: Hot — Current Focus
updated: 2026-05-26
session: 3
---

# 🔥 Hot — ExampleApp

**Session 3 closed 2026-05-26 (Tue, evening).**

## Current phase

Core CRUD shipped: `add` / `list` / `done` / `delete` all working with pytest coverage. Timezone lesson promoted to `gotchas/gotcha-timezones-display.md`. v1 feature surface complete; next session is polish + packaging.

## Top tasks for next session

1. Package as `pipx`-installable: review `pyproject.toml` entry points.
2. Add `--version` flag + `--help` improvements.
3. Write a `README.md` for the project (currently only `CLAUDE.md`).
4. Decide whether to push to GitHub (private) for backup. Lean: yes.
5. Tag `v1.0.0`.

## Open blockers / questions

- [ ] Do we want a config file (`~/.exampleapprc`) for things like default sort order, or is hard-coded fine for v1? Lean: hard-coded; revisit in v1.1.
- [ ] Should `delete` move to a trash table (soft-delete) or hard-delete with `--confirm`? Decided: hard-delete (decision recorded in session 3 log).

## Risks

- 🟢 LOW: packaging is a small surface (one `pyproject.toml` change).
- 🟢 LOW: README delay won't block use (only the maintainer uses this).
