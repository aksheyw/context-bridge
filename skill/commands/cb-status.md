---
description: Read the project's wiki and print a 5-bullet status summary. Fast, read-only, no writes.
---

# /cb-status

You are running the context-bridge `/cb-status` command. Print a tight 5-bullet snapshot of project state from the wiki. Read-only — never write or modify files in this command.

## Step 1 — Locate the wiki

1. Confirm cwd via `pwd`. Look for `.claude/wiki/` relative to the project root.
2. If no `.claude/wiki/` exists, STOP and say:
   > "No `.claude/wiki/` found here. Run `/cb-init` to scaffold one."
3. If `.claude/wiki/` exists but is missing `_hot.md`, treat as partially initialised and warn but continue with whatever files exist.

## Step 2 — Read the three core files

Read these in order. Skip silently if a file is absent (only `_hot.md` is required).

1. `.claude/wiki/_hot.md` — required.
2. `.claude/wiki/_log.md` — read only the most recent session section (between the first `## ` header and the second `## ` header, or end of file).
3. `.claude/wiki/_findings.md` — required if present; capture severity-ordered open items only.

Also opportunistically check for `SESSION_HANDOFF_*.md` at repo root. If present, note the most recent (highest date) but do NOT read its body unless the user asks.

## Step 3 — Print the 5-bullet summary

Print exactly this shape, substituting from what you just read. Be terse — one line per bullet, two max.

```
📍 context-bridge status — <project-name> (<wiki updated date>)

  • Current phase: <pull from _hot.md "Current phase">
  • Top next-tasks: <first 3 items from _hot.md "Top tasks for next session", comma-separated>
  • Open blockers: <count> — <first open blocker text, or "none">
  • Open findings: <count> open (<count> high, <count> medium, <count> low) — top: <highest-severity finding title>
  • Last session: <session N, date> — <one-line summary from _log.md top entry>

Latest handoff: <SESSION_HANDOFF_<date>.md filename, or "none">
```

If any field is missing (e.g. no open blockers), print `none` — never invent.

## Step 4 — Suggest next step (optional, one line)

After the summary, optionally print one line that nudges the user toward a useful action:

- If `_hot.md` "updated" date is >7 days old: `⚠ _hot.md last updated <date> — stale; consider a refresh.`
- If there's an unresolved 🔴 CRITICAL finding: `⚠ Open CRITICAL finding (<id>): <title> — fix before any ship.`
- Otherwise: omit. Don't fill silence.

## Honesty + safety

- **Never fabricate.** If `_hot.md` is empty or unparseable, say so plainly. Do not synthesise plausible-looking bullets.
- **Read-only.** Make zero edits in this command. If you find yourself reaching for Write or Edit, STOP — there is a bug in your interpretation.
- **Keep it short.** This command is meant to fit in a single screen. If the wiki is sprawling, summarise — don't dump.
- **Don't editorialise.** Print what the wiki says, not what you think the project should be focused on.
