---
description: Capture a non-obvious learning into the wiki. Routes to gotchas/, _findings.md, or _log.md based on what was learned.
---

# /cb-ingest

You are running the context-bridge `/cb-ingest` command. The user has surfaced a non-obvious insight mid-session and wants it preserved. Decide where it belongs, write it, confirm.

## The bar — what to ingest

Only NON-OBVIOUS, DURABLE knowledge. If a future session can re-derive it from code or `git log`, **skip**. Decline gracefully:

> "That looks re-derivable from <code-file or git history>. Want to skip, or insist on capturing?"

What qualifies:
- A bug with a non-obvious root cause + the fix that worked.
- An architectural decision and why alternatives were rejected.
- A gotcha in an external tool / API / lib that bit us.
- A constraint discovered (rate limit, schema invariant, race condition).
- A finding that needs tracking but isn't fixed yet.

What does NOT qualify:
- Implementation details visible in the code itself.
- "What we did today" (use `/cb-save-sync` → `_log.md` for session summaries).
- Personal preferences (use `~/.claude/projects/.../memory/` instead).
- Secrets, tokens, real project IDs — REFUSE outright.

## Step 1 — Parse the input

The user invoked: `/cb-ingest <free-text>` (single argument, may be multi-sentence).

If the input is empty, ask:
> "What did you learn? One sentence is fine. I'll decide where it lands."

## Step 2 — Refuse if it contains secrets

Scan the input for common secret patterns BEFORE writing anything:
- `sk-` / `sk-or-v1-` / `ghp_` / `gho_` (API keys)
- JWT-shaped strings (`eyJ...`)
- Telegram-bot-token shapes (`<digits>:<base62>`)
- Patterns like `password=`, `secret=`, `token=` with non-trivial values

On hit, STOP and say:
> "That looks like it contains a secret. The wiki is plain markdown and travels with git. Rewrite without the secret value, then re-ingest."

Do NOT write the input anywhere — not even temporarily.

## Step 3 — Classify

Ask the user once (or infer if obvious from the input):

- **gotcha** → external surprise + fix. Write a new file under `.claude/wiki/gotchas/gotcha-<slug>.md`.
- **decision** → architectural choice. Write a new file under `.claude/wiki/decisions/d-YYYY-MM-DD-<slug>.md`.
- **finding** → known issue, not yet resolved. Append to `.claude/wiki/_findings.md`.
- **log-note** → small contextual note. Append to today's session entry in `.claude/wiki/_log.md` under a `**Notes:**` subsection (create the subsection if absent).

If user-typed input clearly fits (e.g. "decision: we picked Postgres over Mongo because…"), use that classification without asking.

## Step 4 — Write

Create or append the appropriate file. **Never overwrite** existing content.

### gotcha format

```markdown
---
title: <short title>
updated: YYYY-MM-DD
status: open | resolved
---

# Gotcha — <short title>

**Symptom:** <what looked wrong>
**Root cause:** <what was actually wrong>
**Fix:** <what worked>
**Why it's non-obvious:** <one sentence on why this would bite again>
```

### decision format

```markdown
---
title: <decision title>
updated: YYYY-MM-DD
status: accepted | proposed | superseded
---

# Decision — <title>

**Context:** <why a choice was needed>
**Decision:** <what was chosen>
**Alternatives rejected:** <list + one-line reason each>
**Consequences:** <what this locks in / unlocks>
```

### finding format (append to `_findings.md`)

Below the last `## F<N>` entry (auto-increment N):

```markdown
---

## F<N+1> — <short title>
**Severity:** 🔴 CRITICAL / 🟡 HIGH / 🟢 MEDIUM / 🟢 LOW
**Status:** OPEN
**Phase to fix:** <e.g. before-v0.1-ship>
**Detail:** <what is wrong, where, what the impact is>
**Mitigation:** <interim mitigation, or "none yet">
```

### log-note format (append under today's session in `_log.md`)

If a session section for today exists, append under it. If not, create a new session header at the top using today's date.

```markdown
**Notes:**
- YYYY-MM-DD HH:MM — <learning text>
```

## Step 5 — Confirm

After writing, print:

```
📝 ingested → <relative path written>
```

Then a one-line recap of what was captured. Do not paste the full content back unless the user asks.

## Honesty + safety

- **Never fabricate** missing fields. If the user didn't specify severity or status, ask — don't guess.
- **Never overwrite** existing files. New gotcha/decision files use unique slugs; if a slug collides, append a `-2` suffix.
- **Never write** secrets even if the user insists they're "fake" or "test" values. Refuse.
- If unsure where it belongs, ask the user before writing — better one extra question than a wrong placement.
