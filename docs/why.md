# Why context-bridge exists

## The two failure modes

Working with Claude Code (or any agentic coding tool) on a multi-session project has two recurring failure modes:

1. **Mid-session bloat.** The context window fills with stale conversation. The model starts hallucinating because the relevant facts are buried in irrelevant chat.
2. **Cross-session amnesia.** Starting a new session means re-loading 5+ files just to remember WHERE the work was. The same insights get re-derived weekly.

Most workflows solve (1) by hitting `/clear` or `/strategic-compact`, then immediately suffer (2).

context-bridge does NOT try to solve (1). Use `/strategic-compact`, `/aside`, or native compaction for that. context-bridge solves (2).

## The shape of the problem

Cross-session amnesia is really three problems stacked:

- **Where is the work.** What branch? What commit? What was the last conscious decision?
- **Why the work matters.** What's the user trying to ship, by when, with what constraints?
- **What's already a dead end.** What approaches were tried and rejected? What gotchas have we already paid for once?

Loose markdown notes catch the first. They mostly fail at the second and third because:
- They're written for the writer-now, not the reader-later.
- They drift out of sync with the code.
- They have no convention for what to capture vs. skip.

## The inspiration — Karpathy's LLM Wiki

Andrej Karpathy's [LLM Wiki gist](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f) describes a pattern where instead of doing query-time retrieval over a sprawling corpus, you have an LLM **incrementally build and maintain a small, persistent, interlinked markdown wiki**. The human curates sources; the LLM handles the cross-referencing, summarisation, and maintenance work that humans typically abandon.

That's the philosophical core. context-bridge takes Karpathy's pattern and wires it into the Claude Code session lifecycle:

- A small wiki per project (`.claude/wiki/`).
- Slash commands to read it (`/cb-status`), capture into it (`/cb-ingest`), update it (`/cb-save-sync`), and produce a portable handoff prompt (`/cb-handoff`).
- Honesty rules in the project's `CLAUDE.md` so the discipline travels with the wiki.

## What changed in this skill vs. raw Karpathy

The original LLMwiki shape is `_index / _log / _schema / <topic>`. context-bridge adds:

- **`_hot.md`** — always-on-top "current focus + open blockers". Solves the "where is the work" question in <30s.
- **`_findings.md`** — open issues, severity-ordered. Solves the "what's already a dead end" question.
- **`decisions/`** — architectural decisions in dated files. Solves the "why we picked this over that" question.
- **`gotchas/`** — promoted findings with non-obvious fixes. Solves the "we've paid for this once before" question.

The 11-step save+sync protocol and the handoff prompt template are also context-bridge's own. See [`CREDITS.md`](../CREDITS.md) §3 for the full delta.

## Why a skill, not a doc

You could read all of the above and roll your own. Many people will, and that's a good outcome — the methodology is the point.

The skill exists because:
- **Convention has compounding value.** If you wing it for 3 weeks, you'll re-invent half of this and miss the other half. The skill encodes choices already made.
- **The honesty rules matter.** The "never fabricate" and "95% confidence" rules in `CLAUDE.md` are the actual mechanism that keeps the wiki trustworthy across sessions. Skipping them while keeping the wiki shape gets you a beautiful, untrustworthy lie-machine.
- **Safety defaults.** The pre-commit hook + scrubbed templates make it less likely you'll commit a token by accident into a wiki page that grows over months.
- **One install command.** Less friction = higher chance you actually adopt the protocol instead of skipping it.

## What this skill is NOT trying to be

- ❌ A team-knowledge system.
- ❌ A code-aware retrieval layer.
- ❌ An IDE plugin or MCP server.
- ❌ A general-purpose note-taking tool. (Use Obsidian, Notion, Logseq, or your own — though if you already use Obsidian, the wiki opens *as* a vault; see [`obsidian.md`](obsidian.md).)
- ❌ A replacement for `git log`, `git blame`, or your code itself.

If your need is in that list, this is the wrong tool — and that's fine.

## Further reading

- [`docs/getting-started.md`](getting-started.md) — 5-minute quickstart.
- [`docs/what-this-is-not.md`](what-this-is-not.md) — non-goals in detail.
- [`docs/when-not-to-use.md`](when-not-to-use.md) — the short-lifespan filter.
- [`docs/vs-other-skills.md`](vs-other-skills.md) — comparison with related tools.
- [`CREDITS.md`](../CREDITS.md) — full attribution to Karpathy, Vincent, Anthropic.
