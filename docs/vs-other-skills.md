# context-bridge vs. other skills

How context-bridge compares to neighbouring tools. Honest assessment — these aren't competitors, they're often siblings.

## At a glance

| Tool | Solves | Doesn't solve | When to pick it |
|---|---|---|---|
| **context-bridge** | Cross-session amnesia in Claude Code projects | Mid-session bloat, team-shared knowledge, code retrieval | Solo, multi-session, Claude-Code-primary projects |
| `save-session` / `resume-session` (Claude Code skills) | Session-snapshot continuity | Compounding knowledge across sessions, decision/gotcha capture | One-off "I need to pick up where I left off" with no methodology investment |
| Karpathy's [LLM Wiki](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f) (methodology) | The wiki shape + compounding-knowledge framing | Per-session lifecycle, slash commands, install path | You want to roll your own and don't need the per-session integration |
| `llm-wiki` skills (community implementations) | Karpathy's pattern as an installable | Per-session integration, honesty rules, save+sync | You only need the wiki, not the session protocol |
| [Superpowers](https://github.com/obra/superpowers) (Jesse Vincent) | Workflow discipline (brainstorm→spec→plan→TDD), skill ecosystem | Project-state continuity across sessions | You want a complete workflow toolkit; can layer context-bridge on top |
| `/strategic-compact` (Claude Code built-in) | Mid-session bloat → compressed conversation | Cross-session continuity | Long single session running out of context |
| Confluence + ADRs (team) | Team-shared knowledge, decisions, runbooks | Per-session lifecycle for a single dev | Multi-developer projects with formal documentation needs |

## context-bridge vs. `save-session` / `resume-session`

**`save-session`**: snapshots your current session state to a dated file in `~/.claude/session-data/`.

**`resume-session`**: loads the most recent snapshot from that directory.

| | context-bridge | save / resume |
|---|---|---|
| Output | A structured wiki + a handoff prompt in repo | A narrative snapshot file in `~/.claude/` |
| Compounding | Yes — wiki grows over weeks/months | No — each snapshot is independent |
| Captures decisions, gotchas, findings | Yes, dedicated files | No, free-form narrative |
| Honesty rules in CLAUDE.md | Yes, inherited | No |
| Lives in the project repo | Yes (gitted) | No (lives in `~/.claude/`) |
| Survives a machine swap | Yes | Only if you sync `~/.claude/` |

**Pick `save-session`** if you need quick "where was I" with zero methodology overhead.

**Pick context-bridge** if you want the wiki to compound over time and travel with the project.

The two can coexist — `/cb-save-sync` produces a `SESSION_HANDOFF_<date>.md` at repo root, which is essentially a more structured `save-session` snapshot.

## context-bridge vs. Karpathy's LLM Wiki

Karpathy's gist is the philosophical core. context-bridge is one specific implementation of it, tuned for the Claude Code session lifecycle.

| | Karpathy LLM Wiki | context-bridge |
|---|---|---|
| Schema | `_index / _log / _schema / <topic>.md` | + `_hot.md`, `_findings.md`, `decisions/`, `gotchas/` |
| Lifecycle integration | None specified | 11-step save+sync at session close, `/cb-status` at start |
| Honesty enforcement | Implicit | Codified in CLAUDE.md marked section |
| Install path | Roll your own | `npx skills add aksheyw/context-bridge` |
| Tool-specific | Tool-agnostic | Claude Code v0.1; methodology is tool-agnostic |

**Pick Karpathy's pattern** if you want the philosophy without an opinionated implementation, or you're building for a different tool ecosystem.

**Pick context-bridge** if you want the pattern wired into your daily session loop with safety defaults.

context-bridge attributes Karpathy [thoroughly](../CREDITS.md) — this is a derivative work, not a replacement.

## context-bridge vs. Superpowers

[Superpowers](https://github.com/obra/superpowers) (Jesse Vincent) is a much broader workflow toolkit: brainstorming, planning, TDD, code review, git worktrees, etc. The "skill that explains how to use skills" pattern context-bridge follows comes from there.

| | Superpowers | context-bridge |
|---|---|---|
| Scope | Full workflow (design → implement → review) | One thing: cross-session amnesia |
| Number of skills | ~25+ | 1 skill, 5 commands |
| Install | `npx skills add obra/superpowers` | `npx skills add aksheyw/context-bridge` |
| Coexists with | Almost everything | Almost everything, incl. Superpowers itself |

These are **complementary, not competing**. A typical workflow uses Superpowers for the design/build phase and context-bridge for project-state continuity across sessions.

If Superpowers has improved your work, consider [sponsoring Jesse](https://github.com/sponsors/obra).

## context-bridge vs. `/strategic-compact`

This isn't a fair comparison — they solve different problems.

`/strategic-compact` (Claude Code built-in): your CURRENT conversation is too long; compress it.

context-bridge: your CURRENT conversation is fresh, but you've forgotten what last week's session figured out; load it back.

You'll use both. They don't conflict.

## context-bridge vs. team docs (Confluence, Notion, ADR repos)

Different audience. Team docs are for OTHER PEOPLE. context-bridge's wiki is for YOU (or your future self) inside a coding session.

**Don't replace team docs with context-bridge** — the wiki isn't designed for multiple authors or formal review processes.

**Don't replace context-bridge with team docs** — Confluence pages are too far from your session for the protocol to feel frictionless. You'll skip the discipline.

They coexist: `decisions/d-2026-05-26-database-choice.md` can link to the formal Confluence ADR. The wiki entry captures what you (the author) need next session; the Confluence page captures what your team needs.

## Honest tradeoffs

context-bridge's downsides:

- **Opinionated.** If you want different schema, you'll fork or hack. The methodology is tightly coupled to the 4-file root + decisions/gotchas/.
- **Single-tool in v0.1.** No Cursor / Aider / Codex installer until v0.2.
- **Solo-only.** Multi-developer projects on the same wiki = guaranteed merge conflicts on `_hot.md`.
- **Discipline-dependent.** If you don't actually run `/cb-save-sync` at session close, the wiki rots and the skill is wasted.
- **Wiki bloat is possible.** `_log.md` grows append-only; `decisions/` accumulates. There's no built-in archive mechanism yet (v0.2 candidate).

If any of those are deal-breakers, see the other tools above.

## TL;DR

> If you're a solo dev, work on multi-session projects, use Claude Code as your main loop, and find yourself re-loading the same context every Monday → install context-bridge.
>
> If you're outside that envelope → one of the tools above is probably a better fit.
