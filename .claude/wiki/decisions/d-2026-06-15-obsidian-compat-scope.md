---
title: Obsidian-vault compatibility scope — read+graph, additive, no schema change
updated: 2026-06-15
status: accepted
---

# Decision — Obsidian compat = read+graph compatibility, not two-way editing or a schema change

**Context:** context-bridge's wiki is already plain markdown + `[[wiki-links]]`, so it is *latently* openable as an Obsidian vault. Akshey asked whether to make that deliberate (S8, 2026-06-15). The load-bearing behaviors were verified against Obsidian help/forum before scoping (basename link resolution; `.obsidian/` churn; `tags:`/`aliases:` as first-class properties; `related:` frontmatter links rendering only finickily; and — the key constraint — Obsidian hides dot-folders, so `.claude/wiki/` must be opened *as* the vault, not the project root).

**Decision:** ship **Option A — read + navigate compatibility**: a `docs/obsidian.md` guide + a `.obsidian/` gitignore guardrail + a body-links-for-graph convention note. Additive only. Rolls into v0.2 (no separate tag).

**Alternatives rejected:**
- **Two-way editing in Obsidian** — would need new lint rules for Obsidian-only syntax (callouts / embeds / nested tags) and threatens the LLM-parseability that IS the product. High cost; fights the "author curates, LLM maintains" model.
- **Ship a curated `.obsidian/` config** — pins context-bridge to Obsidian's config schema across versions for marginal gain.
- **A wiki-schema addition** — fails the schema-delta bar ("would the skill have *failed* without this?"). Obsidian compat touches docs + `.gitignore` + one convention note, not the schema.

**Consequences:** every adopter who uses Obsidian gets a documented, guard-railed path. No new runtime, no schema change, no CI gate added (the gate-5 walker exclusion was the only gate touch, for a code-block false-positive — see [`../gotchas/gotcha-gate5-codeblock-links.md`](../gotchas/gotcha-gate5-codeblock-links.md)). Full build spec: [`../../../docs/superpowers/specs/2026-06-15-obsidian-compat-design.md`](../../../docs/superpowers/specs/2026-06-15-obsidian-compat-design.md).
