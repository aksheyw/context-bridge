---
name: context-bridge
description: Use when starting, continuing, or closing a Claude Code session on a multi-session project. Scaffolds a small per-project wiki (.claude/wiki/) and runs an 11-step save+sync that produces a paste-and-resume handoff prompt. Solves cross-session amnesia. Does NOT solve mid-session context bloat — use /strategic-compact for that.
---

# context-bridge

A skill that stops cross-session amnesia in Claude Code projects. Each project gets a small `.claude/wiki/` (markdown, append-only) plus a save+sync protocol that produces a paste-and-resume handoff prompt for the next session.

## What this skill does

- **Scaffolds** a `.claude/wiki/` with 4 root files (`_hot`, `_log`, `_findings`, `_schema`) plus `decisions/` and `gotchas/` as they accrue.
- **Captures** non-obvious learnings into the wiki during a session (`/cb-ingest`).
- **Closes** a session via an 11-step save+sync that updates the wiki, commits, and prints a handoff prompt (`/cb-save-sync` → `/cb-handoff`).
- **Embeds** two honesty rules (never-fabricate, 95% confidence) into the project's `CLAUDE.md` so the discipline travels with the wiki.

## What this skill does NOT do

- ❌ **Mid-session bloat.** Use `/strategic-compact`, `/aside`, or native compaction.
- ❌ **Multi-user / team-shared wikis.** Single-developer, single-machine.
- ❌ **Code-aware retrieval / embeddings.** Wiki is plain markdown; grep is the search.
- ❌ **Auto-summarization of past sessions.** The author decides what's durable.
- ❌ **IDE-level context** (Cursor / Aider / Codex). Claude Code only in v0.1.

If your need is in that list, this is the wrong skill — and that's fine. Skill body is intentionally narrow.

## When to use

- Project lifespan > ~3 days, multi-session.
- Solo dev using Claude Code as the primary loop.
- You catch yourself re-deriving the same context every Monday.

## When NOT to use

- Single-session weekend script. Overkill.
- Throwaway prototype.
- Team already on Confluence + ADRs — coexists but adds little.
- Workflow where Claude Code is secondary.

## Commands

| Command | Purpose | Reference |
|---|---|---|
| `/cb-init` | Pre-flight scan + scaffold wiki + append marked section to `CLAUDE.md`. | [commands/cb-init.md](commands/cb-init.md) |
| `/cb-status` | Read `_hot.md` + print 5-bullet summary. Read-only. | [commands/cb-status.md](commands/cb-status.md) |
| `/cb-ingest` | Capture a learning into the wiki. Routes to gotchas/decisions/findings/log. | [commands/cb-ingest.md](commands/cb-ingest.md) |
| `/cb-save-sync` | Run the 11-step save+sync protocol. User-gated at sensitive steps. | [commands/cb-save-sync.md](commands/cb-save-sync.md) |
| `/cb-handoff` | Generate the next-session handoff prompt + save `SESSION_HANDOFF_<date>.md`. | [commands/cb-handoff.md](commands/cb-handoff.md) |

All five commands are implemented in v0.1. Deep references (full protocol text, schema delta, migration guide) land in v0.1.1.

## Wiki shape

Bootstrapped by `/cb-init`. All filenames lowercase, dashes, no spaces.

| File | Purpose |
|---|---|
| `_hot.md` | Current focus + open blockers. Always-on-top. Cap ~50 lines. |
| `_log.md` | Append-only session log. One section per session. |
| `_findings.md` | Open issues. Severity-ordered. Lifecycle: OPEN → IN PROGRESS → RESOLVED / ACCEPTED. |
| `_schema.md` | Wiki schema for THIS project. Adopters can extend. |
| `decisions/d-YYYY-MM-DD-<name>.md` | Architectural decisions. One per file. |
| `gotchas/gotcha-<topic>.md` | Surprises + fixes. Promoted from resolved findings. |

Templates live in [`templates/`](templates/). Schema delta vs. Karpathy's original LLMwiki: see [references/karpathy-schema-delta.md](references/karpathy-schema-delta.md) (v0.1 stub).

## The 11-step save+sync protocol

Full canonical text: [references/save-sync-protocol.md](references/save-sync-protocol.md) (v0.1 stub).

Summary:

0. Secret + PII scan (block on hit).
1. Run tests; update count if changed.
2. `git commit` locally (specific files, not `-A`).
3. Push `.md` files to remote (docs-only by default).
4. Push feature branch if on one.
5. Optional: project docs lint.
6. Wiki sync — propose updates, user approves per item.
7. Bump `_hot.md` + append `_log.md`.
8. Promote major findings to `_findings.md`.
9. Update memory + `MEMORY.md` (if used).
10. Generate handoff prompt → `SESSION_HANDOFF_<date>.md`.

Steps 5, 6 (user approval), 9 are project-specific in effect but procedurally identical across projects.

## Handoff prompt template

The output of `/cb-handoff`. Pasted into a fresh session = warm resume in <30s.

```
I'm continuing the <project> work. Last session closed <YYYY-MM-DD>.

Read these in order, fast:
1. <project>/.claude/wiki/_hot.md
2. <project>/.claude/wiki/_log.md (last entry only)
3. <project>/.claude/wiki/_findings.md
4. <project>/SESSION_HANDOFF_<date>.md (full handoff)

Then summarize back to me in 5 bullets:
- What we're building
- What's pending and priority
- Top blockers/risks
- Today's first task
- What the next 60 minutes look like

After your summary, ask me:
1. <any open question pulled from _hot.md>

Honesty: 95% confidence gate. Never fabricate paths or commands. Use Read/Grep/Glob to verify.
Velocity: speed + usefulness wins. Cut scope when a gate is at risk.
```

Full template + adaptation guidance: [references/handoff-template.md](references/handoff-template.md) (v0.1 stub).

## Honesty rules (inherited by every adopter project)

The marked section `/cb-init` appends to `CLAUDE.md` codifies two rules:

- **Never fabricate.** No file paths, function names, line numbers, or API signatures without verification via Read / Grep / Glob.
- **Earned confidence.** "95% confident" requires full end-to-end homework — trace the code path, verify data shape at each boundary, check failure modes, read tests.

Full rationale + examples: [references/honesty-rules.md](references/honesty-rules.md) (v0.1 stub).

## Findings register lifecycle

Each `_findings.md` entry: ID + severity + status + phase to fix + detail + mitigation.

- States: OPEN → IN PROGRESS → RESOLVED → ACCEPTED.
- Severity: 🔴 CRITICAL / 🟡 HIGH / 🟢 MEDIUM/LOW.
- On resolution with a non-obvious fix: promote to `gotchas/gotcha-<topic>.md`.

Full schema: [references/findings-register.md](references/findings-register.md) (v0.1 stub).

## Adoption checklist

1. `npx skills add aksheyw/context-bridge` (install once, machine-wide).
2. `cd <project>` and run `/cb-init`. Pre-flight scan flags collisions.
3. Read the 5-line tour printed by `/cb-init`.
4. Work normally. At session close say "save and sync" → skill runs `/cb-save-sync` → `/cb-handoff`.
5. Next session, paste the handoff prompt. Warm resume.

## Migration from an existing `.claude/wiki/`

`/cb-init` detects prior wikis (Karpathy `llm-wiki` or your own) and prompts:

- **Migrate** — add `_hot.md` + `_findings.md`; preserve existing files.
- **Adopt as-is** — record current shape in `_schema.md`; no new files.
- **Refuse** — abort cleanly; no changes made.

Full guidance: [references/migration-from-existing.md](references/migration-from-existing.md) (v0.1 stub).

## Attribution

Full provenance: [CREDITS.md](../CREDITS.md).

- **Wiki-as-compounding-knowledge** pattern: Andrej Karpathy ([LLM Wiki gist](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f)).
- **Brainstorm → spec → plan workflow + "skill that explains skills"** pattern: Jesse Vincent ([Superpowers](https://github.com/obra/superpowers), MIT; [sponsor](https://github.com/sponsors/obra)).
- **Claude Code + skills format**: Anthropic ([claude.ai/code](https://claude.ai/code)).
- **TDD discipline informing save+sync gates**: Kent Beck.

Original to this skill: 11-step save+sync protocol, `_hot.md` + `_findings.md` + `decisions/` + `gotchas/`, handoff prompt template, honesty rules. See `CREDITS.md` §3.

## Safety

- Templates ship scrubbed. Only `ExampleApp` / `ExampleService` / `ExampleUser` appear.
- Adopters should enable a local pre-commit hook (`.githooks/pre-commit`, opt-in via `git config core.hooksPath .githooks`) to scan for project-specific proper nouns + common secret patterns before any commit.
- Never paste API keys, tokens, or production IDs into the wiki. Wiki is plain markdown and travels with git.
- Repo-side: GitHub secret-scanning + push-protection are enabled on the context-bridge repo itself.
