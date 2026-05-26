# Credits

context-bridge synthesizes ideas from several places. This file names them, links them, and clarifies what's original vs. derivative. If something looks like your work and isn't credited, please open an issue — the goal is full provenance.

---

## 1. Conceptual ancestry

### LLMwiki pattern — Andrej Karpathy
The single most important idea in context-bridge is **wiki-as-compounding-knowledge**: instead of re-deriving context from raw session files, maintain a small, structured, human-readable wiki that grows as you work. Karpathy described and popularized this pattern.

- Reference: Karpathy's public posts on X / Twitter about LLM-edited personal wikis.
- What context-bridge inherits: the philosophical core (`_log.md` as audit trail, `_schema.md` as catalog, per-topic markdown pages).
- What context-bridge adds: see §3 below.

### "Context engineering" framing — Andrej Karpathy
The notion of treating context windows as a budget to manage explicitly (rather than something to fill maximally) frames why this skill exists at all.

---

## 2. Codebase + workflow ancestry

### Superpowers ecosystem — Jesse Vincent ([@obra](https://github.com/obra))
**Repo:** [github.com/obra/superpowers](https://github.com/obra/superpowers)
**License:** MIT (Copyright © 2025 Jesse Vincent)

Superpowers is the upstream inspiration for several patterns context-bridge uses:

- The **brainstorming → spec → plan → TDD** workflow that produced THIS very design.
- The **"skill that explains how to use skills"** pattern (`using-superpowers`).
- The structure of `/cb-*` slash commands (modeled on the way Superpowers organizes its command set).
- The discipline of presenting design in approved sections before implementation.

If Superpowers has improved your work, consider [sponsoring Jesse's open-source work](https://github.com/sponsors/obra).

### Claude Code — Anthropic
**Tool:** [claude.ai/code](https://claude.ai/code)

The whole skill format — YAML frontmatter, the Skill tool, the `.claude/` directory convention, slash commands — comes from Claude Code. context-bridge is a Claude-Code-native skill and depends on that runtime.

### Skills format — Anthropic
The skill packaging convention (SKILL.md with frontmatter, `references/` for on-demand loading) is Anthropic's. context-bridge follows it.

### Kent Beck — Test-Driven Development
The principle of disciplined, test-anchored work informs the save+sync protocol's gates (run tests before committing, etc.).

---

## 3. What's NEW in context-bridge

These are the author's (Akshey Walia's) original contributions on top of the ancestry above:

### 3.1 The 11-step save+sync protocol
The save+sync canon in `skill/references/save-sync-protocol.md` is original. It was developed locally and battle-tested across multiple of the author's projects before being generalized into this skill. Step 0 (secret + PII scan) was added during the context-bridge design audit.

The author's local source (cited for provenance, not as a dependency adopters need): `~/.claude/rules/workflow.md`.

### 3.2 Wiki schema additions
Karpathy's original LLMwiki shape is `_index.md / _log.md / _schema.md / <topic>.md`. context-bridge adds:

| Addition | Purpose |
|---|---|
| `_hot.md` | Current focus + open blockers (always-on-top) |
| `_findings.md` | Open issues with severity + phase |
| `decisions/d-YYYY-MM-DD-<name>.md` | Architectural decisions log |
| `gotchas/gotcha-<topic>.md` | Surprises encountered + fixes |

Reasoning for each addition lives in `skill/references/karpathy-schema-delta.md`.

### 3.3 The handoff prompt template
The next-session handoff prompt (5-bullet summary + question gate + honesty/velocity reminders) is original. It evolved across the author's projects through trial and error; the version shipped in v0.1 is the one that consistently produces a useful warm-resume in <30 seconds.

### 3.4 The honesty rules
- **Never fabricate** (no file paths, function names, line numbers, or signatures without Read/Grep/Glob verification).
- **Earned confidence** (95% confident requires full end-to-end homework).

Codified in the author's local `~/.claude/rules/honesty.md`. context-bridge embeds them into adopters' projects via the CLAUDE.md marked section so the discipline travels with the skill.

### 3.5 The findings register lifecycle
States, severity coding, and the "promote to gotchas/ on resolution with non-obvious fix" pattern are the author's convention.

---

## 4. Sibling / superseded works

### `save-session` / `resume-session` skills
Earlier Claude Code skills by the same author. context-bridge supersedes them by providing a more opinionated, more durable, more transferable system (wiki + protocol + handoff + honesty rules) instead of just session snapshots.

### `llm-wiki` skill
A Claude-Code skill by the same author implementing Karpathy's pattern. context-bridge is a superset that wires the wiki into the per-session lifecycle.

### Author's `audit` skill
Used to QA THIS design (Rounds 2-3 of the design review). The 14-lens deep-review + ripple-search methodology there is the same one applied to the context-bridge spec.

---

## 5. Reporting attribution gaps

If you see a pattern in context-bridge that should credit you or someone else and doesn't, please open an issue tagged `attribution`. The goal is full provenance — happy to add to this file.

---

## 6. License-of-credits

This CREDITS.md file itself is part of the context-bridge repo and is licensed under MIT (per `LICENSE`). The content names third parties for attribution; nothing here implies endorsement by them.
