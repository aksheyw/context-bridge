# What context-bridge is NOT

This page is stated explicitly because friends will assume otherwise. Mirrors §1.3 of the design spec; expanded with rationale.

---

## ❌ Mid-session context bloat

context-bridge does NOT prune your current session's context. If your conversation has grown to the point where the model is hallucinating, the wiki won't help — you've already lost the thread.

**Use instead:**
- `/strategic-compact` (Claude Code built-in)
- `/aside` for a temporary focused subsession
- Native compaction

context-bridge addresses **cross-session amnesia** (failure mode #2 in [`docs/why.md`](why.md)), not mid-session bloat (failure mode #1). The two problems look similar but the fixes are different.

---

## ❌ Multi-user / team-shared knowledge

The wiki lives in `.claude/wiki/` inside a single project on a single machine. It is committed to git, so a team member who clones the repo *can* read it — but the protocol assumes one author maintaining one mental model.

Specifically NOT supported:
- Concurrent edits to `_hot.md` from two people on the same day.
- Per-author memory or sub-wikis.
- Permission models (who can promote a finding, who can resolve a decision).

**If you need team docs:** Confluence, Notion, or a proper ADR system. context-bridge can coexist with those — you would link from `decisions/` into Confluence pages — but it doesn't replace them.

---

## ❌ Code-aware retrieval

The wiki is plain markdown. `grep` is the search. No embeddings, no vector store, no symbol-aware indexing. If you want "find me all the places that touch the auth flow", use your IDE, `rg`, or a code-aware tool — not context-bridge.

This is a deliberate design choice. Code-aware retrieval is solved by other tools; the wiki's job is to capture decisions and gotchas that DON'T live in the code.

---

## ❌ Auto-summarisation of past sessions

`/cb-save-sync` proposes wiki updates and asks you per item. It does NOT silently summarise your session into the wiki. The bar is "would a future session re-derive this from code or `git log`?" — if yes, **skip**. Only non-obvious, durable knowledge gets in.

The author decides what's durable. The skill is a tool, not a transcript.

---

## ❌ IDE-level context (autocomplete, intellisense, embeddings)

context-bridge does not interact with Cursor, Aider, Codex, Copilot, Continue.dev, or any IDE plugin. The wiki is plain markdown the IDE doesn't know about.

If you primarily use one of those tools, the **methodology** still applies — see [`docs/adapting-to-other-tools.md`](adapting-to-other-tools.md). The **skill** is Claude-Code-specific in v0.1.

---

## ❌ A general-purpose note-taking system

The wiki is shaped specifically for project-state continuity across coding sessions. It's not where your reading notes go, or your meeting minutes, or your personal journal.

If you want a general PKM tool: Obsidian, Logseq, Notion, Bear, Apple Notes — pick one. context-bridge is happy to coexist; the wiki references those if useful, but doesn't try to be them.

---

## ❌ Replacement for `git log` / `git blame` / your code

If a question can be answered by running `git log -p <file>` or reading the code itself, **don't put it in the wiki**. The wiki's job is to capture the things the code doesn't show:

- Why you picked approach A over approach B (`decisions/`).
- What bit you about a third-party tool and how you fixed it (`gotchas/`).
- What's still open and what's blocked on what (`_findings.md`).
- Where you are right now and what's hot (`_hot.md`).

If the wiki page restates what `git log` would tell you, it's wasted lines. Cut it.

---

## ❌ A monorepo coordination layer

v0.1 assumes one project = one wiki at `<project>/.claude/wiki/`. Per-package wikis inside a monorepo are a v0.2 candidate. Adopters with monorepos today: either pick ONE package as the "primary" and put the wiki at the monorepo root, or wait for v0.2.

---

## ❌ A linter for your code

The pre-commit hook scans for **secrets and proper nouns in wiki content**. It does NOT lint your source code, run your tests, format your files, or check your types. Use the right tool for each layer.

---

## ❌ A migration tool from other systems

If you have a Notion knowledge base or a wiki in another format, context-bridge does NOT have an importer. `/cb-init` detects existing `.claude/wiki/` setups ([Karpathy LLMwiki](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f) or your own) and prompts for migration *within* that surface; it does not pull in external systems.

This is intentional: the act of deciding what to carry over is itself useful curation. An automatic import would dump everything, and most of it isn't worth carrying.

---

## If you came here looking for one of these

It's fine. context-bridge is small on purpose, and "not this" is a real answer. The README's "vs other skills" table ([`docs/vs-other-skills.md`](vs-other-skills.md)) may point you at a better fit.
