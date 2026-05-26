---
title: Open Findings — Issues to Rectify
updated: 2026-05-26
---

# Open Findings — ExampleApp

Issues identified during work on this project. Each entry: severity, status, the phase in which to fix.

---

## F1 — Timestamps display in wrong timezone

**Severity:** 🟡 HIGH
**Status:** ✅ RESOLVED 2026-05-25 → promoted to `gotchas/gotcha-timezones-display.md` 2026-05-26
**Phase to fix:** —
**Detail:** Initial schema stored `created_at` as Unix epoch integer; display code used naive `datetime.fromtimestamp()`. Resulted in tasks displaying in wrong timezone.
**Resolution:** Switched to ISO 8601 UTC strings; display via `.astimezone()`. Full lesson captured in `gotchas/gotcha-timezones-display.md`.

---

(No open findings.)

---

## Finding lifecycle

- **OPEN** — needs fix
- **IN PROGRESS** — being worked on
- **RESOLVED** — fix shipped + verified
- **ACCEPTED** — known issue, no fix planned (or deferred to a later version)

On resolution with a non-obvious fix, promote the entry to `gotchas/gotcha-<topic>.md` so it stays discoverable.
