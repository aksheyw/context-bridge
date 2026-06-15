# context-bridge — Obsidian-vault compatibility (v0.2)

**Status:** v1 design. Brainstormed 2026-06-15; load-bearing Obsidian behaviors verified against [Obsidian Help](https://help.obsidian.md) + forum before scoping.
**Author:** Akshey Walia
**Date:** 2026-06-15
**Repo:** [github.com/aksheyw/context-bridge](https://github.com/aksheyw/context-bridge)
**License:** MIT
**Spec format:** [Superpowers](https://github.com/obra/superpowers) brainstorming-skill convention (Jesse Vincent).
**Ships in:** v0.2 (bundled with the other queued v0.2 work — monorepo support, cross-tool installers, `/cb-find`).

---

## 1. Problem + scope honesty

### 1.1 The latent fact
context-bridge's wiki ([Karpathy LLM Wiki pattern](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f) + the context-bridge schema delta) is, structurally, already an Obsidian vault: a folder of plain-markdown files using `[[wiki-links]]`, with frontmatter that already uses `tags:` / `aliases:` / `related:` — and `tags`/`aliases` are first-class [Obsidian Properties](https://help.obsidian.md/aliases). `scripts/wiki-lint.py` already errors on broken `[[wiki-links]]`, so links stay graph-valid.

Today this compatibility is **accidental and undocumented**. The only Obsidian mentions in the repo ([`docs/why.md`](../../why.md), [`docs/what-this-is-not.md`](../../what-this-is-not.md), [`docs/when-not-to-use.md`](../../when-not-to-use.md)) are "use Obsidian *instead* for general notes" — i.e. a non-goal pointer, not a compatibility claim.

### 1.2 What this feature does
Make the latent compatibility **deliberate, documented, and guard-railed**, so an adopter who already lives in Obsidian can open their project wiki as a vault, browse it, and navigate it by graph — without surprises and without dirtying their repo.

### 1.3 What it does NOT do (non-goals — stated because they are the obvious wrong turns)
- ❌ **Two-way authoring.** This is read + navigate, not "edit the wiki in Obsidian." We do NOT add support for Obsidian-only syntax (callouts `> [!note]`, embeds `![[...]]`, nested tags `#a/b`). Those would need new lint rules and threaten the LLM-parseability that is context-bridge's whole point.
- ❌ **A curated `.obsidian/` config.** No shipped opinionated graph/appearance/hotkey config. That pins context-bridge to Obsidian's config schema across versions for marginal gain.
- ❌ **A schema change.** By the bar in [`karpathy-schema-delta.md`](../../../skill/references/karpathy-schema-delta.md) ("would the skill have *failed* without this?"), Obsidian compat does not earn a wiki-schema addition. This feature touches docs + `.gitignore` + one convention note only.
- ❌ **A plugin, MCP server, or `/cb-obsidian` command.** No new runtime.

### 1.4 Who it's for
Adopters who already use Obsidian as their PKM and want their Claude Code project wiki visible in the same tool. Strictly additive — adopters who don't use Obsidian are unaffected.

---

## 2. Verified behaviors (the homework)

Four behaviors this design depends on, verified 2026-06-15:

| # | Behavior | Verdict | Consequence for this design |
|---|---|---|---|
| 1 | Body `[[basename]]` links resolve across subfolders (default "Shortest path when possible") | ✅ True; context-bridge filenames are unique by convention so they resolve | Body links are the reliable graph mechanism |
| 2 | `.obsidian/` config folder is created in the vault root on open; `workspace.json` churns constantly | ✅ True ([Configuration folder](https://help.obsidian.md/configuration-folder)) | Must be gitignored, or it dirties the adopter's repo |
| 3 | `tags:` / `aliases:` frontmatter are first-class Properties | ✅ True | Works natively; document it, build nothing |
| 4 | `related: [[...]]` frontmatter links render as graph edges | ⚠️ **Finicky** — sometimes shows `?`; version/typing-dependent ([forum](https://forum.obsidian.md/t/wiki-links-in-properties-not-working/89237)) | Do NOT rely on it. Graph value comes from **body** links; `related:` is a bonus |

### 2.1 The load-bearing constraint
Obsidian's file explorer **hides dotfolders by default**, with no reliable built-in toggle ([forum](https://forum.obsidian.md/t/hidden-folders-dotfiles-not-showing-in-file-explorer-despite-detect-all-file-types-being-enabled/106685)). context-bridge's wiki lives inside `.claude/`. Therefore:

- Opening the **project root** as a vault → `.claude/` is hidden → the file explorer shows **nothing useful**. ❌
- Opening **`.claude/wiki/` itself** as the vault root → its contents (`_hot.md`, `decisions/`, …; underscore-prefixed, not dot-prefixed) are visible. ✅ The `.obsidian/` config then lands at `.claude/wiki/.obsidian/`.

**The single rule the docs must teach: open `.claude/wiki/` AS the vault, not the project root.** This is the core deliverable — without it, the default experience is an empty pane.

---

## 3. Scope — concrete deliverables

### D1 — `docs/obsidian.md` (new; the spine)
A focused compatibility guide covering:
1. **"Your wiki is already an Obsidian vault"** — why (markdown + `[[links]]` + Properties), with the [Karpathy gist](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f) link for the wiki concept.
2. **The one rule** — open `.claude/wiki/` as the vault root, not the project root; the dotfolder-hiding reason, with the forum citation.
3. **Graph view** — body `[[links]]` are the edges; `related:` frontmatter links are a bonus that may not render depending on Obsidian version (behavior #4). Set "Shortest path when possible" (default) for link resolution.
4. **Properties** — `tags:` and `aliases:` work natively; no setup.
5. **`.obsidian/` config** — context-bridge gitignores it for you (D2); explanation of why (it churns).
6. **What NOT to do** — don't author Obsidian-only syntax into wiki files; the lint + the LLM expect plain markdown (links to non-goals §1.3).

### D2 — Gitignore guardrail (two places)
- **This repo:** add an `.obsidian/` section to [`.gitignore`](../../../.gitignore) using `**/.obsidian/` so opening either the repo's own wiki or `examples/ExampleApp/.claude/wiki/` in Obsidian never commits config churn.
- **Adopter scaffold:** [`/cb-init`](../../../skill/commands/cb-init.md) Step 3 (greenfield + migrate paths) writes a self-contained `.claude/wiki/.gitignore` containing `.obsidian/`. Skip-if-exists, never overwrite — consistent with the command's existing idempotency contract. This keeps the guardrail local to the wiki dir and never mutates the adopter's root `.gitignore`.

### D3 — Graph-richness convention note
One line in [`skill/references/wiki-structure.md`](../../../skill/references/wiki-structure.md) (frontmatter section): cross-references you want visible in a graph tool belong in **body** `[[links]]`; `related:` frontmatter is metadata and may not render as graph edges in all tools. No schema change — a guidance note only.

### D4 — Reframe the 3 existing mentions
Soften [`docs/why.md`](../../why.md), [`docs/what-this-is-not.md`](../../what-this-is-not.md), [`docs/when-not-to-use.md`](../../when-not-to-use.md) from "use Obsidian *instead*" to "...and if you already use Obsidian, your wiki opens *as* a vault — see [`docs/obsidian.md`](../../obsidian.md)." Honesty preserved: context-bridge is still **not** a general PKM; it is markdown-compatible with one.

### D5 — Discoverability
- Add an FAQ entry to [`docs/faq.md`](../../faq.md): "Can I use this with Obsidian?" → yes, see `docs/obsidian.md`.
- Cross-link from [`docs/adapting-to-other-tools.md`](../../adapting-to-other-tools.md).

### D6 — Launch note (not code)
Flag for the (separate) launch post: "your wiki opens as an Obsidian vault." Recorded here for traceability; no code in this spec.

---

## 4. User journey (data flow)

1. Adopter has run `/cb-init` → `.claude/wiki/` exists with `.claude/wiki/.gitignore` (`.obsidian/`).
2. Adopter reads `docs/obsidian.md`, opens **`.claude/wiki/`** as a new Obsidian vault.
3. Obsidian creates `.claude/wiki/.obsidian/` (gitignored — no repo churn).
4. File explorer shows `_hot.md`, `_log.md`, `_findings.md`, `decisions/`, `gotchas/`, `references/`.
5. Graph view renders edges from body `[[links]]`; `tags`/`aliases` populate the tag pane / alias resolution.
6. Adopter navigates; nothing they do in read/navigate mode changes the markdown in a way that breaks `wiki-lint.py` or the LLM resume path.

---

## 5. Failure modes + edge cases

| Scenario | Behavior |
|---|---|
| Adopter opens project root as vault | Sees empty/irrelevant explorer (dotfolder hidden). `docs/obsidian.md` warns against this up front. |
| Adopter expects `related:` links in graph | Documented as version-dependent; body links are the supported path. |
| `.obsidian/` already committed before guardrail | `.gitignore` stops *future* churn; doc notes `git rm -r --cached .claude/wiki/.obsidian` to untrack existing. |
| Project root `.gitignore` has no `.claude/` entry | Irrelevant — D2 writes `.claude/wiki/.gitignore`, self-contained. |
| Adopter authors Obsidian callouts/embeds into a wiki page | Out of scope; `docs/obsidian.md` explicitly advises against it. Not lint-enforced in v0.2 (possible future). |
| Adopter on a config-folder override (`.obsidian-*`) | `**/.obsidian/` won't match; doc notes the override case and that they own their own gitignore then. |
| `/cb-init` re-run (idempotent) | `.claude/wiki/.gitignore` skip-if-exists; no overwrite. |

---

## 6. Testing + verification

This is a docs + `.gitignore` + one-line convention change. Verification:

- **Automated (must stay green):** `scripts/verify.sh` (all gates) + CI matrix. `wiki-lint.py` already errors on broken `[[links]]`, which is exactly what keeps the Obsidian graph valid — no new lint code required for v0.2.
- **Guardrail check:** confirm `git status` is clean after opening `examples/ExampleApp/.claude/wiki/` in Obsidian (i.e. `.obsidian/` is ignored). This is the one acceptance test that proves D2.
- **Manual (documented, not automatable — Obsidian is a GUI app):** open `examples/ExampleApp/.claude/wiki/` as a vault; confirm (a) the file explorer shows the pages, (b) graph view shows body-link edges. Record the steps in `docs/obsidian.md` so any adopter can self-verify.
- **No fabricated claims:** `docs/obsidian.md` states only behaviors verified in §2 (with citations). Anything version-dependent (behavior #4) is labeled as such.

---

## 7. Attribution + security (hard rules)

- **Attribution:** `docs/obsidian.md` links the [Karpathy gist](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f) wherever it references the wiki concept; this spec credits Jesse Vincent's [Superpowers](https://github.com/obra/superpowers) for the brainstorming→spec convention. No change to `CREDITS.md` is required (no new third-party concept is introduced — Obsidian is a compatibility target, named as such, not a borrowed pattern). If review disagrees, add an Obsidian compatibility-target line to `CREDITS.md` §2.
- **PII scrub:** all examples use `ExampleApp` / `ExampleService` / `ExampleUser` only. No real project names, URLs, or IDs.
- **Secret scan:** this feature ships no code that handles secrets; the repo-wide secret scan must stay clean.
- **Spec self-review:** performed below.

---

## 8. v0.1 → v0.2 placement

This work is additive and schema-neutral. It rolls into the v0.2 tag alongside monorepo support, cross-tool installer adapters, and `/cb-find` (per the design spec §11.2). It does not block, and is not blocked by, those items — it can land in any order on the v0.2 branch.

---

## Spec self-review (2026-06-15)

- **Placeholder scan:** no TBD/TODO/incomplete sections. Open behavior caveats (frontmatter links) are stated explicitly, not deferred.
- **Internal consistency:** scope (§3) matches deliverables referenced in journey (§4), failure modes (§5), and testing (§6). Non-goals (§1.3) are not contradicted by any deliverable.
- **Scope check:** single implementation plan possible — ~5 files touched (1 new doc, `.gitignore`, `cb-init.md`, `wiki-structure.md`, 3 existing docs reframed + FAQ). No decomposition needed.
- **Ambiguity:** "open the vault" is pinned to one meaning — `.claude/wiki/` as vault root, never project root (§2.1).
- **Proper-noun scrub:** no real-project names, service URLs, or IDs. Only `ExampleApp`.

Open for user review before implementation planning.

---

End of spec.
