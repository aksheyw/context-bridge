---
description: Generate the next-session handoff prompt and save it to SESSION_HANDOFF_YYYY-MM-DD.md at repo root.
---

# /cb-handoff

You are running the context-bridge `/cb-handoff` command. Produce the paste-and-resume prompt the user will start the next session with. Save it to disk. Print it.

This command is normally invoked by `/cb-save-sync` step 10. It can also run standalone — useful for handing off mid-week without doing the full save+sync.

## Step 1 — Read project state

Read in order. None are strictly required, but the prompt is thin without them.

1. `.claude/wiki/_hot.md`
2. `.claude/wiki/_log.md` (most recent session section only)
3. `.claude/wiki/_findings.md` (open items only, severity-ordered)
4. The current branch + most-recent commit (`git rev-parse --abbrev-ref HEAD`, `git log -1 --format='%h %s'`).
5. The most recent prior `SESSION_HANDOFF_*.md` at repo root (if any) — for continuity, not for content copy-paste.

## Step 2 — Compose the handoff prompt

Generate this exact shape (substituting brackets):

```
I'm continuing the <project-name> work. Last session closed <YYYY-MM-DD>.

Read these in order, fast:
1. .claude/wiki/_hot.md
2. .claude/wiki/_log.md (most recent session entry only)
3. .claude/wiki/_findings.md
4. SESSION_HANDOFF_<YYYY-MM-DD>.md (this file — full handoff context)

Then summarize back to me in 5 bullets:
- What we're building + who it's for + who it's NOT for
- What's pending and priority (top 3-5 items)
- Top 3 risks
- Today's first task — a concrete 60-min plan
- The killer demo or output for the next session

After your summary, ask me:
1. <pull one open question from _hot.md "Open blockers / questions">
2. <pull a second open question if present; otherwise a scope question relevant to the top task>
3. Co-pilot mode: A (standby) / B (active co-pilot) / C (code reviewer) / D (build for me)?

Honesty: 95% confidence gate. Never fabricate paths or commands. Use Read/Grep/Glob to verify.
Velocity: speed + usefulness wins. Cut scope when a gate is at risk.
```

If `_hot.md` has fewer than 2 open questions, leave the second slot to a scope/direction question relevant to the top task — never invent a question that wasn't grounded in the wiki.

## Step 3 — Compose the full handoff document

The prompt above is the FIRST section of `SESSION_HANDOFF_<today>.md`. Below it, add these sections by reading project state:

```markdown
# <project-name> — Session Handoff <YYYY-MM-DD>

> **Closed:** <YYYY-MM-DD, weekday, time-of-day>
> **Phase:** <pull from _hot.md "Current phase">
> **Branch / commit:** `<branch>` at `<sha>` — <commit subject>

---

## Next-session prompt

<the prompt from Step 2, verbatim, inside a fenced block>

---

## TL;DR for future me

<2-3 sentences summarising what this session accomplished and what the next session
should produce. Pulled from _log.md latest entry + _hot.md current phase.>

---

## What was done this session

<bulleted list from _log.md latest entry "Done:" section>

---

## What's pending — prioritized

### P0 — Before any ship announcement
<items from _hot.md "Top tasks" that are blockers>

### P1 — This deliverable
<the rest of "Top tasks">

### P2 — After this deliverable
<anything explicitly tagged post-ship in _hot.md or _findings.md>

---

## Open findings register (severity-ordered)

<table from _findings.md — only OPEN + IN PROGRESS items; collapse RESOLVED + ACCEPTED into a footer count>

| # | Finding | Severity | Phase | Status |
|---|---|---|---|---|
| F<id> | <title> | <severity> | <phase> | <status> |

Full detail: `.claude/wiki/_findings.md`

---

## Skills + agents likely useful next session

<conservative list of 3-5 — pull from _hot.md "Top tasks" context; do NOT enumerate every available skill>

---

## Cross-references

### Repo
- Local: <pwd>
- Remote: <result of `git remote get-url origin`, or "no remote">

### Wiki
- `_hot.md`, `_log.md`, `_findings.md`, `_schema.md` at `.claude/wiki/`

### Prior handoffs
<list the 3 most recent SESSION_HANDOFF_*.md files at repo root>

---

End of handoff.
```

## Step 4 — Write to disk

1. Filename: `SESSION_HANDOFF_<today-ISO-date>.md` at repo root.
2. If that exact filename already exists (multiple handoffs same day), append `-<HHMM>` before the extension: `SESSION_HANDOFF_<date>-<HHMM>.md`.
3. **Never overwrite** an existing handoff.
4. Print path written.

## Step 5 — Echo the prompt block

Print just the Step 2 prompt (not the full handoff doc) to the chat, inside a clearly-marked fence so the user can copy directly:

```
✂---- copy below this line ----✂
<the prompt>
✂---- copy above this line ----✂

Full handoff saved to: SESSION_HANDOFF_<today>.md
```

## Honesty + safety

- **Never fabricate.** Every claim in the handoff doc must be traceable to a wiki file or git command output. If the wiki is empty/thin, the handoff is thin — that's honest.
- **No secrets in handoffs.** Re-run the Step 0 scan from `/cb-save-sync` against the generated doc before writing. If any pattern hits, STOP and surface the offending line.
- **Date format:** always ISO `YYYY-MM-DD`. Never locale-specific.
- **Filename collision:** appending `-<HHMM>` is the only allowed strategy. Never overwrite.
- **Keep handoffs purposeful, not exhaustive.** Target ~150-250 lines for the full doc. If a section would be empty, omit it rather than printing a "(none)" placeholder.
