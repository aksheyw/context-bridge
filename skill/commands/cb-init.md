---
description: Scaffold .claude/wiki/ and append a context-bridge marked section to CLAUDE.md. Idempotent — safe to re-run.
---

# /cb-init

You are running the **context-bridge `/cb-init`** command in the user's current working directory (treat `pwd` at invocation time as the project root). Follow the steps below in order. Do not skip pre-flight. Print exactly what each step finds before acting.

## Step 0 — Verify environment + locate templates

1. Confirm project root via `pwd`. If the user is clearly not in their intended project (e.g., home directory, a system path, no git repo), STOP and ask for confirmation before continuing.
2. Locate the context-bridge templates directory. Try in order:
   - `~/.claude/skills/context-bridge/templates/` (default `npx skills add` install path)
   - `~/.claude/plugins/cache/*/context-bridge/*/skill/templates/` (plugin cache install path)
   - `$CB_TEMPLATES_DIR` if set in the environment
3. If no templates directory is found, STOP and tell the user:
   > "I can't find context-bridge templates. Run `npx skills add aksheyw/context-bridge` or set `CB_TEMPLATES_DIR` to the skill's `templates/` directory."

## Step 1 — Pre-flight collision scan

Check and report ALL of the following before changing anything:

1. **Slash command collisions.** List files in `~/.claude/commands/` and `<project>/.claude/commands/` matching `cb-*.md`. If any exist that are NOT from context-bridge (no `context-bridge` line in frontmatter or body), warn the user and ask whether to continue.
2. **Existing `.claude/wiki/`.** If present, determine its shape:
   - If it contains `_hot.md` AND `_findings.md` AND a `context-bridge` marker line — treat as already initialised; jump to Step 5 (idempotent re-run).
   - If it contains Karpathy-style files (`_log.md` + `_schema.md`) but no `_hot.md` — offer migration (Step 3, branch B).
   - Anything else — offer migration (Step 3, branch B).
3. **Existing `CLAUDE.md`.** Note whether it exists. If yes, search it for the marker `<!-- context-bridge:begin -->`. If marker found — already initialised in CLAUDE.md (Step 4 will skip append).
4. **Git status.** Run `git status --porcelain`. If there are uncommitted changes, mention them. Do NOT abort — adopters may legitimately be mid-work — but flag for awareness.

Print a single summary block:

```
context-bridge /cb-init pre-flight
  project root        : <pwd>
  templates source    : <resolved templates dir>
  /cb-* collisions    : <none | list>
  .claude/wiki/       : <missing | already cb | needs migration | other>
  CLAUDE.md           : <missing | exists, no cb marker | exists, cb marker present>
  uncommitted changes : <count or 'none'>
```

## Step 2 — Confirm with user before any write

Ask the user to confirm proceeding. Phrase based on the pre-flight result:

- **Greenfield (no wiki, no CLAUDE.md marker):** "Scaffold `.claude/wiki/` and append the context-bridge section to CLAUDE.md. Proceed?"
- **Idempotent re-run (cb marker present):** "Wiki is already initialised. Re-running is safe but no-op for existing files. Proceed?"
- **Migration needed:** "Existing wiki found. Choose: (1) **migrate** — add `_hot.md` + `_findings.md`, preserve existing files; (2) **adopt as-is** — record current shape in `_schema.md`, no new files; (3) **refuse** — abort."

Wait for the user's answer. Do not proceed without it.

## Step 3 — Scaffold the wiki

Greenfield path:

1. Create `.claude/wiki/` if missing (`mkdir -p .claude/wiki`).
2. For each of `_hot.md`, `_log.md`, `_findings.md`, `_schema.md`:
   - Read the template from the resolved templates dir.
   - Substitute placeholders:
     - `<project-name>` → repo dirname or the value of the local git config `cb.projectName` if set.
     - `YYYY-MM-DD` → today's date (ISO).
   - Write to `.claude/wiki/<filename>`.
   - If file already exists, **skip and report**. Never overwrite.

Migration branch B (existing wiki):

- Always preserve existing files. Only add what's missing.
- If user chose **migrate**: scaffold `_hot.md` + `_findings.md` only if absent. Update `_schema.md` to note both the prior convention (e.g. Karpathy LLMwiki) and the context-bridge additions.
- If user chose **adopt as-is**: write `_schema.md` only (and only if absent). No other files.
- If user chose **refuse**: stop here. Print "Aborted — no files changed."

## Step 4 — Append CLAUDE.md marked section

Skip if the marker `<!-- context-bridge:begin -->` is already in CLAUDE.md.

1. Read the snippet from the resolved templates dir: `CLAUDE.md.snippet`.
2. If CLAUDE.md does NOT exist, create it with:
   ```
   # <project-name>

   <one-line description; user can edit later>

   ```
   followed by the snippet content.
3. If CLAUDE.md exists, append the snippet content (with one blank line before the marker). Never overwrite existing content.
4. Report the byte count appended.

## Step 5 — Print the 5-line tour

Print exactly this (substituting `<project-name>`):

```
✅ context-bridge initialised in <project-name>.

  • Edit .claude/wiki/_hot.md with your current focus before next session-close.
  • Capture learnings mid-session with /cb-ingest "<one-line learning>".
  • At session close say "save and sync" → /cb-save-sync runs the 11-step protocol.
  • /cb-handoff prints a paste-and-resume prompt for the next session.
  • Read CLAUDE.md → the appended block is your at-a-glance protocol reminder.

Next: open .claude/wiki/_hot.md and replace the placeholders with this project's reality.
```

## Step 6 — Safety reminders (only on first init, not idempotent re-run)

Remind the user:

- The wiki travels with git. Never paste API keys, tokens, or production IDs into wiki files.
- Consider enabling the local pre-commit hook for proper-noun + secret scanning: `git config core.hooksPath .githooks` (after installing the hook — see context-bridge `.githooks/pre-commit`, opt-in).
- This skill solves cross-session amnesia. For mid-session bloat, use `/strategic-compact` or native compaction — see SKILL.md "What this skill does NOT do".

## Honesty rules for this command

- **Never fabricate** template content. If a template can't be read, say so and abort — do not invent content.
- **Never overwrite** existing files. Always read first, skip if present, report skip.
- **Idempotency:** the marker `<!-- context-bridge:begin -->` is the source of truth for "already initialised in CLAUDE.md". The presence of `_hot.md` + `_findings.md` is the source of truth for "wiki already initialised".
- If any step fails partway (e.g. write permission denied), STOP, print what was done, and leave the project in a recoverable state — do not attempt rollback.
