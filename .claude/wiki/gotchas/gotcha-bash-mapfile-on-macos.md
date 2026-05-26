---
title: bash mapfile / readarray not available on macOS default shell
updated: 2026-05-26
status: resolved
---

# Gotcha — bash `mapfile` / `readarray` not available on macOS default shell

**Symptom:** `.githooks/pre-commit` failed at line 36 with `mapfile: command not found` when run on macOS during smoke testing. Tests passed for cases where grep happened to match anyway, but a clean file (test 1) and the pattern-doc false-positive case (test 3) silently fell through to exit 0 — masking the failure.

**Root cause:** `mapfile` (alias `readarray`) is a bash 4+ builtin. macOS ships bash 3.2 at `/bin/bash` for licensing reasons (bash 4 is GPLv3). `#!/usr/bin/env bash` on macOS picks up `/bin/bash` 3.2 by default unless the user has installed bash 4+ via Homebrew AND it's earlier in PATH.

**Fix:** replaced both `mapfile` calls with a portable `while IFS= read -r` loop with process substitution:

```bash
# Before (bash 4+ only):
mapfile -t STAGED < <(git diff --cached --name-only --diff-filter=ACM)

# After (bash 3.2 compatible):
STAGED=()
while IFS= read -r line; do
  STAGED+=("$line")
done < <(git diff --cached --name-only --diff-filter=ACM)
```

**Why it's non-obvious:** the hook author was running on a Linux mental model (bash 4+ is standard). macOS bash being stuck at 3.2 for 15+ years is a well-known portability trap, but easy to forget when writing "modern" bash. The failure mode was especially sneaky because `mapfile: command not found` was printed to stderr but `set -euo pipefail` did NOT abort — `mapfile` failure inside a process substitution doesn't propagate the exit code to the parent script.

**How to detect next time:** any time a bash script uses `mapfile`, `readarray`, associative arrays (`declare -A`), `${var^^}` / `${var,,}` case-conversion, or `${var@U}` parameter transformation — assume macOS users will hit a bash-3.2 wall. Test on macOS default bash before shipping shell scripts that adopters will run.

**Related:**
- Originally surfaced as a smoke-test failure in `.githooks/pre-commit` Session 4 (2026-05-26).
- The hook itself is the canonical example — refer back to it for the portable pattern.
- Code touched: `.githooks/pre-commit` lines 36 + 102.
