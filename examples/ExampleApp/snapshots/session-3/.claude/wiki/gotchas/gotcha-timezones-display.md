---
title: Timezones — store UTC, display local, never store naive
updated: 2026-05-26
status: resolved
---

# Gotcha — Timezones: store UTC, display local, never store naive

**Symptom:** Tasks added at 9pm IST displayed as "9pm" in the local-time column, but the actual UTC time was 3:30pm. Off by hours, not minutes. Looked fine at a glance.

**Root cause:** Naive `datetime` objects (no `tzinfo`). Specifically:
- `time.time()` returns a UTC epoch float.
- `datetime.fromtimestamp(ts)` interprets that as **local time** (no tzinfo set).
- Mixing `time.time()` for storage with `fromtimestamp()` for display produces wrong timestamps whenever the local timezone is not UTC.

**Fix:**
- **Storage:** ISO 8601 strings with explicit `Z` suffix:
  ```python
  from datetime import datetime, timezone
  ts = datetime.now(timezone.utc).isoformat().replace("+00:00", "Z")
  ```
- **Read-back:** `datetime.fromisoformat(ts.replace("Z", "+00:00"))` — produces a tz-aware datetime in UTC.
- **Display:** `.astimezone()` with no arg — converts to the machine's local timezone.

**Why it's non-obvious:** Naive datetimes "look" correct because Python doesn't warn you. The bug only surfaces when the user's local time differs from UTC, which means it's invisible to anyone in a UTC-aligned region (UK in winter, Iceland, etc.) and to anyone whose smoke-tests happen at noon UTC. **The bug class is "appears correct in 1 timezone, wrong in 23 others".**

## Lesson

Three rules for any timestamp work going forward:

1. **Never store a naive datetime.** Always tz-aware, always UTC at the storage boundary.
2. **Always store as ISO 8601 string with explicit `Z`** — readable in `git diff`, sortable as text, locale-independent.
3. **Display with `.astimezone()`** at the very last step before showing the user.

## Related

- `_findings.md` F1 (the original finding; now RESOLVED + promoted here).
- `decisions/d-2026-05-23-storage-sqlite-vs-json.md` (storage decision; mentions deferring timestamp format choice — this gotcha closes that loop).
