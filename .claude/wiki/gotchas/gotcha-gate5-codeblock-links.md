---
title: Gate 5 false-positives on markdown links inside code blocks
updated: 2026-06-15
status: resolved
---

# Gotcha — Gate 5 lints markdown links inside fenced code blocks

**Symptom:** `scripts/verify.sh` Gate 5 ("relative cross-links resolve") reported 13 broken links in `docs/superpowers/plans/2026-06-15-obsidian-compat.md` — links such as `[obsidian.md]` → `(obsidian.md)` (markdown-link syntax for a sibling doc) that don't resolve relative to the plan's own directory.

**Root cause:** Gate 5's Python walker scans every `.md` file on disk with the regex `\]\(([^)]+)\)` and does **not** skip fenced code blocks — nor even inline code spans (this very gotcha page tripped Gate 5 by quoting an example `.md` link, until the example was de-linked). Implementation *plans* (and specs) legitimately show example markdown-link syntax inside ```code fences``` to instruct an engineer what to paste. The gate parses those illustrative links as live cross-links and tries to resolve them against the plan file's own directory → false-positive failures.

**Fix:** excluded `docs/superpowers/plans/` from Gate 5's walker skip-list, in BOTH `scripts/verify.sh` and `.github/workflows/pii-scrub-check.yml`. **Parity between the two is mandatory** — see the F7 lesson in `_findings.md` (a local/CI gate drift was red on `main` for a whole release). Specs are still linted (they had no code-block link false-positives this session).

**Why it's non-obvious:** the gate is correct for shipped docs; it only mis-fires on planning artifacts that quote link syntax as examples. It will **recur for any future *spec*** that puts `[x](y)` inside a code fence. When it does, either add that dir to the exclusion too, or implement the more general fix: strip fenced blocks before scanning. The general fix was deferred this session because a fence-stripping regex must handle nested fences (the plan used ```` ```` ```` wrapping ``` ``` ```) and is fragile — the dir-exclusion was the lower-risk choice.
