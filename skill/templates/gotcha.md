---
title: <short title>
updated: YYYY-MM-DD
status: resolved
---

# Gotcha — <short title>

**Symptom:** <what looked wrong; how it manifested. include error messages verbatim if relevant>

**Root cause:** <what was ACTUALLY wrong — often different from the symptom>

**Fix:** <what worked. include the specific change, not just "fixed it">

**Why it's non-obvious:** <one sentence on why a smart engineer would also hit this>

**How to detect next time:** <symptom → likely culprit, in one line. helps future-you skip the debugging>

**Related:**

- Originally tracked as: F<id> in `_findings.md` (if promoted from a finding)
- Decisions affected: [[d-YYYY-MM-DD-related-decision]] (if any)
- Code touched: <files / dirs>

<!--
context-bridge convention:
- Filename: gotchas/gotcha-<short-slug>.md
- Only write a gotcha when:
    1. The fix was non-obvious (a smart engineer would also struggle), AND
    2. This is likely to bite again — same external tool, same pattern, same gap.
- If the bug was a typo or a one-liner that any future engineer would also write,
  skip the gotcha — just fix it and move on.
- Promote from _findings.md when a RESOLVED finding had a non-obvious fix.
-->
