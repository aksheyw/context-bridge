---
title: Open Findings — Issues to Rectify
updated: 2026-05-25
---

# Open Findings — ExampleApp

Issues identified during work on this project. Each entry: severity, status, the phase in which to fix.

---

## F1 — Timestamps display in wrong timezone

**Severity:** 🟡 HIGH (user-facing wrong data)
**Status:** RESOLVED 2026-05-25 (same session as opened)
**Phase to fix:** Before merging `add-task` to main
**Detail:** Initial schema stored `created_at` as Unix epoch integer. Display code did `datetime.fromtimestamp(ts)` which returned a naive datetime in **local time** — but `add-task` was using `time.time()` which returns UTC epoch. Result: a task added at "9pm IST" displayed as "9pm" in the local-time column when in fact UTC was 3:30pm. Looked correct on first glance; off by hours.
**Root cause:** Naive datetimes (no tzinfo). `fromtimestamp(ts)` interprets as local; `utcfromtimestamp(ts)` interprets as UTC; neither sets `tzinfo`. Either way, downstream code can't tell what the datetime "means".
**Fix:** Store timestamps as ISO 8601 strings with explicit `Z` suffix (`datetime.now(UTC).isoformat().replace('+00:00', 'Z')`). Parse with `datetime.fromisoformat()`; display via `.astimezone()` (which respects the local timezone of the machine running the CLI).
**Mitigation:** Resolved before any data was persisted in production-shaped form. To be promoted to `gotchas/gotcha-timezones-display.md` next session.

---

## Finding lifecycle

- **OPEN** — needs fix
- **IN PROGRESS** — being worked on
- **RESOLVED** — fix shipped + verified
- **ACCEPTED** — known issue, no fix planned (or deferred to a later version)

On resolution with a non-obvious fix, promote the entry to `gotchas/gotcha-<topic>.md` so it stays discoverable.
