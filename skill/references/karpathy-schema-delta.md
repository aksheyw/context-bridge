# Karpathy schema delta

> Side-by-side: Karpathy's [LLM Wiki pattern](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f) (the canonical reference) vs. what context-bridge adds. Rationale per addition.

> **Provenance:** the wiki shape extends Karpathy's pattern. Karpathy holds the original idea; the additions below are context-bridge's own. See [CREDITS.md](../../CREDITS.md) §1 and §3.2.

---

## Karpathy's original

From the [`llm-wiki.md` gist](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f):

| File | Purpose (Karpathy) |
|---|---|
| `_index.md` | Topic catalog — list of all wiki pages, manually curated. |
| `_log.md` | Append-only log of ingestions / queries / updates. |
| `_schema.md` | The wiki's own schema — what fields each page type uses. |
| `<topic>.md` | Individual topic pages, interlinked. |

The core insight: **wiki-as-compounding-knowledge**. An LLM incrementally builds and maintains a persistent, interlinked markdown wiki. The human curates sources and asks questions; the LLM handles the summarisation, cross-referencing, and maintenance that humans typically abandon.

Two failure modes Karpathy's pattern resists:
1. **Re-deriving context from raw sources each time** — slow, expensive, and inconsistent.
2. **Query-time retrieval** (RAG-style) — better than nothing but doesn't compound; each query is independent.

The wiki is the compounding layer.

---

## What context-bridge adds

Four additions, motivated by the per-session lifecycle of Claude Code work (which differs from Karpathy's more general "build knowledge from sources" framing).

### 1. `_hot.md` — current focus + open blockers

**What:** an always-on-top page summarising the project's current phase, top tasks for next session, open blockers, and risks. Capped at ~50 lines.

**Why it's not in Karpathy's pattern:** Karpathy's wiki is source-driven — you ingest sources, then query. Context-bridge's wiki is session-driven — you close one session, the next session starts cold. The cold start needs a single file that says "here's where we are RIGHT NOW". `_log.md` is append-only history; `_hot.md` is the present state.

**What it costs:** one extra file. Updated every session-close. Cap discipline prevents bloat.

**Failure mode if absent:** the next session reads `_log.md` and tries to reconstruct current state from the last few entries. Slower; often inaccurate (the most recent entry isn't always representative).

### 2. `_findings.md` — open issues register

**What:** severity-ordered list of open issues with status (OPEN / IN PROGRESS / RESOLVED / ACCEPTED) and phase to fix.

**Why it's not in Karpathy's pattern:** Karpathy's wiki is for knowledge, not bug tracking. Context-bridge spans both, because the line between "what we know" and "what we know is broken" is fuzzy mid-project. Putting findings IN the wiki keeps them adjacent to the knowledge that explains them.

**What it costs:** one extra file. Modest discipline to keep it current.

**Failure mode if absent:** open issues live only in human memory or in scattered TODOs across the code. They get re-discovered (expensively) instead of resolved.

### 3. `decisions/d-YYYY-MM-DD-<slug>.md` — architectural decisions log

**What:** one file per architectural decision. Standard fields: Context, Decision, Alternatives rejected, Consequences.

**Why it's not in Karpathy's pattern:** Karpathy's wiki is single-author-friendly. Decisions are auditable — they tell future readers (often future-you) WHY a path was chosen, and what was rejected. Storing them in their own directory makes them browsable + linkable.

**What it costs:** small. One file per decision. Most projects have ~5-20 decisions over their lifetime, not thousands.

**Failure mode if absent:** decisions get re-litigated when someone asks "why didn't we just do X?" and no one remembers the rejection rationale.

### 4. `gotchas/gotcha-<topic>.md` — surprises + fixes

**What:** one file per non-obvious gotcha. Standard fields: Symptom, Root cause, Fix, Why non-obvious.

**Why it's not in Karpathy's pattern:** Karpathy's wiki holds knowledge that you actively built. Gotchas are knowledge that bit you — different curation pressure. Separating them keeps the "this is what we know" library distinct from the "this is what surprised us" cabinet.

**What it costs:** small. Gotchas accrue slowly; one per real bug with a non-obvious root cause.

**Failure mode if absent:** the same gotcha bites twice. Even worse, the second hit feels like a new bug rather than a known trap.

---

## What context-bridge does NOT change

### `_log.md` shape — same as Karpathy
Append-only. Newest at top (context-bridge convention; Karpathy doesn't specify ordering). One section per session.

### `_schema.md` purpose — same as Karpathy
The wiki's own schema documentation. Adopters extend it per project.

### `_index.md` — optional, not banned
Karpathy's pattern includes `_index.md` as a topic catalog. Context-bridge doesn't require it (the filesystem + grep are usually faster than an LLM-maintained index for the small-project scale this skill targets). If your project benefits from one, keep it — the skill commands don't read it but don't avoid it.

### `references/<topic>.md` — same as Karpathy's `<topic>.md`
Free-form topic pages. Context-bridge prefers them in a `references/` subdirectory; Karpathy allows them at root. Both are valid.

---

## Summary table

| File / Dir | Karpathy | context-bridge | Notes |
|---|---|---|---|
| `_index.md` | ✅ | optional | Use if it helps you. |
| `_log.md` | ✅ | ✅ | Same. Newest-at-top convention added. |
| `_schema.md` | ✅ | ✅ | Same. |
| `_hot.md` | — | ✅ NEW | Always-on-top current state. |
| `_findings.md` | — | ✅ NEW | Open-issues register. |
| `decisions/` | — | ✅ NEW | Architectural decisions log. |
| `gotchas/` | — | ✅ NEW | Promoted findings + observed traps. |
| `references/` or `<topic>.md` | ✅ | ✅ | Same content; subdirectory preferred. |

---

## Why we kept it this small

Four additions, not forty. Each addition was motivated by a specific failure mode observed in real multi-session Claude Code work. Resisted additions:

- ❌ Per-user / per-machine sections. Out of scope (single-user assumption — see SKILL.md non-goals).
- ❌ Roadmap pages. Use the project's existing roadmap doc; don't duplicate.
- ❌ "Active vs. archived" status on every page. Adds friction without earning its keep at single-project scale.
- ❌ Auto-generated indexes. Karpathy's manual `_index.md` is enough; an automated one bloats fast and goes stale.
- ❌ Per-page tags / categories beyond what frontmatter supports. Adopters who want richer taxonomy can extend in `_schema.md`; the baseline is intentionally lean.

The bar for ANY future schema addition (v0.2+): "would the skill have failed without this?". If not, don't add it.

---

## Credit + attribution

Karpathy's framing is the load-bearing idea here — a markdown wiki that compounds across sessions, maintained collaboratively with an LLM. The context-bridge additions are tactical, motivated by Claude Code's session model. Karpathy holds the original concept; this delta is the author's response to it for a specific use case.

If you're new to the LLM Wiki idea, read [karpathy/llm-wiki.md](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f) FIRST. Then read this delta. The context-bridge skill makes much more sense in that order.
