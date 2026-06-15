# Obsidian-vault Compatibility Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make context-bridge's wiki deliberately, documented-ly compatible with Obsidian (open `.claude/wiki/` as a vault) — without a schema change, two-way-editing support, or shipped Obsidian config.

**Architecture:** Additive only. One new doc (`docs/obsidian.md`) is the spine; a `.gitignore` guardrail (repo-wide + `/cb-init` scaffold) stops `.obsidian/` config churn; a one-line convention note routes graph links through the body; three existing "use Obsidian instead" mentions gain a compat pointer. No wiki-schema change, no new CI gate (the existing `wiki-lint.py` link-integrity check is sufficient).

**Tech Stack:** Markdown, git `.gitignore`, bash (`scripts/verify.sh` gate runner). No new runtime.

**Spec:** [`docs/superpowers/specs/2026-06-15-obsidian-compat-design.md`](../specs/2026-06-15-obsidian-compat-design.md)

**Branch:** `feature/obsidian-compat` (spec already committed there as `f9349be`).

**Gate parity rule (repo-critical):** `scripts/verify.sh` (gates 1–8) and `.github/workflows/pii-scrub-check.yml` (gates 1–9) must stay in sync. This plan adds **no** gate, so neither file's gate logic changes — but every task ends by running `scripts/verify.sh` and requiring all-green before commit. Gate 4 (Karpathy gist linked on every `docs/**` mention) and Gate 5 (relative cross-links resolve) are the two that this feature can trip; each task notes when.

---

### Task 1: `.gitignore` guardrail for `.obsidian/` (this repo)

**Files:**
- Modify: `.gitignore`

- [ ] **Step 1: Write the failing test (RED)**

`git check-ignore` reports whether a path would be ignored. The target path need not exist. Run:

```bash
cd "$(git rev-parse --show-toplevel)"
git check-ignore -v examples/ExampleApp/.claude/wiki/.obsidian/workspace.json; echo "exit=$?"
```

- [ ] **Step 2: Run it to confirm NOT ignored**

Expected (RED): no path printed, `exit=1` (git: "no match → not ignored").

- [ ] **Step 3: Add the `.obsidian/` block to `.gitignore`**

Append this block to `.gitignore` (after the existing "Personal-only wiki notes" block, before "Session handoff artifacts"). The pattern `.obsidian/` (no leading slash) matches a directory named `.obsidian` at **any** depth — so it covers both this repo's own wiki and `examples/ExampleApp/.claude/wiki/`:

```gitignore
# Obsidian vault config — created when a .claude/wiki/ is opened as an Obsidian
# vault (see docs/obsidian.md). Churns constantly (workspace.json); never commit.
.obsidian/
```

- [ ] **Step 4: Run the test to confirm it now passes (GREEN)**

```bash
git check-ignore -v examples/ExampleApp/.claude/wiki/.obsidian/workspace.json; echo "exit=$?"
```

Expected (GREEN): prints `.gitignore:<N>:.obsidian/	examples/ExampleApp/.claude/wiki/.obsidian/workspace.json`, `exit=0`.

- [ ] **Step 5: Commit**

```bash
git add .gitignore
git commit -m "feat: gitignore .obsidian/ so opening the wiki as a vault stays clean"
```

---

### Task 2: `/cb-init` scaffolds the wiki `.gitignore` + ship the ExampleApp demo

**Files:**
- Modify: `skill/commands/cb-init.md` (Step 3 — greenfield + existing-wiki paths)
- Create: `examples/ExampleApp/.claude/wiki/.gitignore`

- [ ] **Step 1: Add the scaffold sub-step to cb-init.md (greenfield path)**

In `skill/commands/cb-init.md`, in "## Step 3 — Scaffold the wiki", the greenfield path currently ends after item 2 (the per-file loop writing `_hot.md`…`_schema.md`). Add a new item 3 immediately after it:

```markdown
3. Write `.claude/wiki/.gitignore` with the single line `.obsidian/` (so that opening the wiki as an Obsidian vault never commits Obsidian's config — see `docs/obsidian.md`). If the file already exists, **skip and report**. Never overwrite.
```

- [ ] **Step 2: Cover the existing-wiki (migrate) path too**

In the same Step 3, "Existing-wiki path" sub-list, append a bullet to the **migrate** branch:

```markdown
- On **migrate**: also write `.claude/wiki/.gitignore` (`.obsidian/`) if absent — same skip-if-exists rule.
```

- [ ] **Step 3: Create the ExampleApp demo of the scaffold output**

Create `examples/ExampleApp/.claude/wiki/.gitignore` with exactly:

```gitignore
.obsidian/
```

This makes ExampleApp a faithful copy of what `/cb-init` produces for an adopter.

- [ ] **Step 4: Run the gate runner**

```bash
scripts/verify.sh
```

Expected: `✓ ALL GATES PASSED`. (No `.md` content with secret/PII/link changes here, so gates are unaffected; this confirms nothing regressed.)

- [ ] **Step 5: Commit**

```bash
git add skill/commands/cb-init.md examples/ExampleApp/.claude/wiki/.gitignore
git commit -m "feat: cb-init scaffolds .claude/wiki/.gitignore for Obsidian compat"
```

---

### Task 3: `docs/obsidian.md` — the compatibility guide (the spine)

**Files:**
- Create: `docs/obsidian.md`

- [ ] **Step 1: Write the doc**

Create `docs/obsidian.md` with exactly this content. (It mentions Karpathy → it MUST link the gist for Gate 4. Its only relative link is `what-this-is-not.md`, same dir → Gate 5 resolves.)

````markdown
# Using your wiki with Obsidian

context-bridge's wiki is plain markdown with `[[wiki-links]]`, so it doubles as an [Obsidian](https://obsidian.md) vault — no conversion, no plugin. This page shows how to open it, what works, and the one setup gotcha.

> context-bridge is **not** a note-taking app (see [`what-this-is-not.md`](what-this-is-not.md)). This is compatibility, not a pivot: if Obsidian is already your PKM, your project wiki shows up there too. The wiki concept itself comes from [Karpathy's LLM Wiki pattern](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f).

## The one rule: open `.claude/wiki/` AS the vault

Obsidian's file explorer hides dot-folders by default, with no reliable built-in toggle ([Obsidian forum](https://forum.obsidian.md/t/hidden-folders-dotfiles-not-showing-in-file-explorer-despite-detect-all-file-types-being-enabled/106685)). The wiki lives inside `.claude/`, so:

- ❌ **Don't** open your project root as a vault — `.claude/` is hidden, and the explorer looks empty.
- ✅ **Do** open `.claude/wiki/` *itself* as the vault root. Its files (`_hot.md`, `decisions/`, …) use underscores, not dots, so they show fine.

In Obsidian: **Open folder as vault** → select `<your-project>/.claude/wiki/`.

## What works out of the box

| Feature | Works? | Notes |
|---|---|---|
| Reading pages | ✅ | Plain markdown. |
| `[[wiki-links]]` in the body | ✅ | Resolve by filename; keep the default "Shortest path when possible" ([link settings](https://help.obsidian.md/links)). |
| Graph view | ✅ | Edges come from **body** `[[links]]`. |
| `tags:` frontmatter | ✅ | First-class Obsidian property → tag pane. |
| `aliases:` frontmatter | ✅ | First-class property → `[[alias]]` resolves. |
| `related: [[...]]` frontmatter | ⚠️ | May not render as graph edges depending on your Obsidian version ([forum](https://forum.obsidian.md/t/wiki-links-in-properties-not-working/89237)). Use body links for anything you want in the graph. |

## The `.obsidian/` config folder

When you open the vault, Obsidian writes a `.obsidian/` config folder into it (here: `.claude/wiki/.obsidian/`). It changes constantly (`workspace.json`) and should not be committed. context-bridge gitignores it for you:

- This repo and `/cb-init`-scaffolded projects ship a `.gitignore` rule for `.obsidian/`.
- Committed it by accident already? `git rm -r --cached .claude/wiki/.obsidian` then commit.

## What NOT to do

This is read + navigate, not two-way authoring. Don't write Obsidian-only syntax into wiki pages — callouts (`> [!note]`), embeds (`![[...]]`), or nested tags (`#area/sub`). context-bridge's `wiki-lint.py` and the model that resumes from the wiki expect plain markdown; Obsidian-only syntax can break the lint or confuse the resume. Author in plain markdown; browse in Obsidian.

## Verify it yourself

Open the shipped example — `examples/ExampleApp/.claude/wiki/` — as a vault, and confirm:

1. The file explorer shows `_hot.md`, `_log.md`, `_findings.md`, `decisions/`, `gotchas/`.
2. Graph view shows edges between pages that link each other in the body.
3. `git status` stays clean — the `.obsidian/` folder is ignored.
````

- [ ] **Step 2: Run the gate runner (Gate 4 + Gate 5 are the ones at risk)**

```bash
scripts/verify.sh
```

Expected: `✓ ALL GATES PASSED`. Specifically Gate 4 must say "every Karpathy mention links the canonical gist" and Gate 5 must resolve the new `what-this-is-not.md` link.

- [ ] **Step 3: Commit**

```bash
git add docs/obsidian.md
git commit -m "docs: add Obsidian-vault compatibility guide"
```

---

### Task 4: Graph-richness convention note in `wiki-structure.md`

**Files:**
- Modify: `skill/references/wiki-structure.md`

- [ ] **Step 1: Add the note after the optional-fields paragraph**

In `skill/references/wiki-structure.md`, find this line (end of the "### Optional fields" block):

```
Projects can declare additional optional fields in their `_schema.md`. Anything declared there is treated as expected; anything else triggers a lint warning.
```

Immediately after it (before the following `---`), add:

```markdown

### Links and graph tools

Cross-references you want visible in a graph tool (e.g. [Obsidian](../../docs/obsidian.md)) belong in the page **body** as `[[wiki-links]]`, not only in `related:` frontmatter. Body links render as graph edges everywhere; frontmatter links are metadata and may not render as edges in all tools.
```

(The relative link `../../docs/obsidian.md` resolves from `skill/references/` to `docs/obsidian.md` → Gate 5 passes. No Karpathy mention added → Gate 4 unaffected.)

- [ ] **Step 2: Run the gate runner**

```bash
scripts/verify.sh
```

Expected: `✓ ALL GATES PASSED` (Gate 5 resolves `../../docs/obsidian.md`).

- [ ] **Step 3: Commit**

```bash
git add skill/references/wiki-structure.md
git commit -m "docs: note body-links-for-graph convention in wiki-structure"
```

---

### Task 5: Reframe the 3 existing mentions + FAQ entry + cross-link

**Files:**
- Modify: `docs/why.md` (line 63)
- Modify: `docs/what-this-is-not.md` (line 61)
- Modify: `docs/when-not-to-use.md` (after the redirect table, ~line 78)
- Modify: `docs/faq.md` (new Q&A)
- Modify: `docs/adapting-to-other-tools.md` (cross-link)

- [ ] **Step 1: Reframe `docs/why.md`**

Replace this line:

```
- ❌ A general-purpose note-taking tool. (Use Obsidian, Notion, Logseq, or your own.)
```

with:

```
- ❌ A general-purpose note-taking tool. (Use Obsidian, Notion, Logseq, or your own — though if you already use Obsidian, the wiki opens *as* a vault; see [`obsidian.md`](obsidian.md).)
```

- [ ] **Step 2: Reframe `docs/what-this-is-not.md`**

Replace this line:

```
If you want a general PKM tool: Obsidian, Logseq, Notion, Bear, Apple Notes — pick one. context-bridge is happy to coexist; the wiki references those if useful, but doesn't try to be them.
```

with:

```
If you want a general PKM tool: Obsidian, Logseq, Notion, Bear, Apple Notes — pick one. context-bridge is happy to coexist; the wiki references those if useful, but doesn't try to be them. If Obsidian is your PKM, the wiki opens *as* an Obsidian vault — see [`obsidian.md`](obsidian.md).
```

- [ ] **Step 3: Add a pointer under the `docs/when-not-to-use.md` redirect table**

Find this line (just below the "You're solving the wrong problem" table):

```
See [`docs/what-this-is-not.md`](what-this-is-not.md) for the full non-goal list.
```

Replace it with:

```
See [`docs/what-this-is-not.md`](what-this-is-not.md) for the full non-goal list. (Already use Obsidian for notes? The wiki opens *as* an Obsidian vault — see [`obsidian.md`](obsidian.md). That's compatibility, not a change to any of the non-goals above.)
```

- [ ] **Step 4: Add an FAQ entry to `docs/faq.md`**

After the "Does it work without Claude Code?" Q&A block (ends with the line `See [`docs/adapting-to-other-tools.md`](adapting-to-other-tools.md).` followed by `---`), insert a new Q&A block:

```markdown
### Can I use this with Obsidian?

Yes. The wiki is plain markdown with `[[wiki-links]]`, so `.claude/wiki/` opens directly as an Obsidian vault — read pages, navigate the graph, use tags. One gotcha: open `.claude/wiki/` *itself* as the vault (not the project root, since Obsidian hides dot-folders). Full guide: [`docs/obsidian.md`](obsidian.md).

---
```

- [ ] **Step 5: Add a cross-link in `docs/adapting-to-other-tools.md`**

In the "## What you can use today, in any tool" table, the wiki-shape row currently reads:

```
| The wiki shape (`_hot.md` / `_log.md` / `_findings.md` / `_schema.md` / `decisions/` / `gotchas/`) | ✅ Pure markdown | Create `.claude/wiki/` manually; copy templates from this repo's [`skill/templates/`](../skill/templates/). |
```

Replace it with:

```
| The wiki shape (`_hot.md` / `_log.md` / `_findings.md` / `_schema.md` / `decisions/` / `gotchas/`) | ✅ Pure markdown | Create `.claude/wiki/` manually; copy templates from this repo's [`skill/templates/`](../skill/templates/). Opens as an [Obsidian vault](obsidian.md) too. |
```

- [ ] **Step 6: Run the gate runner (Gate 5 cross-links is the one at risk)**

```bash
scripts/verify.sh
```

Expected: `✓ ALL GATES PASSED`. All new `obsidian.md` links are same-dir (`docs/`) and resolve.

- [ ] **Step 7: Commit**

```bash
git add docs/why.md docs/what-this-is-not.md docs/when-not-to-use.md docs/faq.md docs/adapting-to-other-tools.md
git commit -m "docs: reframe Obsidian mentions as compatibility + add FAQ/cross-links"
```

---

### Task 6: CHANGELOG + full gate sweep + deep-review/audit

**Files:**
- Modify: `CHANGELOG.md`

- [ ] **Step 1: Add the CHANGELOG entry**

In `CHANGELOG.md`, under the `## [Unreleased]` section's `### Added` subsection (create the `### Added` subsection if absent), add:

```markdown
- **Obsidian-vault compatibility** (`docs/obsidian.md`): the wiki opens directly as an Obsidian vault. Documented the "open `.claude/wiki/` as the vault" rule, the body-links-for-graph convention, and a `.gitignore` guardrail for Obsidian's `.obsidian/` config (repo-wide + scaffolded by `/cb-init`). Additive; no wiki-schema change. Spec: `docs/superpowers/specs/2026-06-15-obsidian-compat-design.md`.
```

- [ ] **Step 2: Full local gate sweep**

```bash
scripts/verify.sh
```

Expected: `✓ ALL GATES PASSED` (8/8 + bonus).

- [ ] **Step 3: Deep-review + audit (per repo discipline)**

Run `/deep-review` on the full `feature/obsidian-compat` diff (`git diff main...feature/obsidian-compat`) and `/audit` (ripple search) over the touched templates/docs/command. Continue deep-review rounds until one full round yields zero new findings. Log any findings to `.claude/wiki/_findings.md` and fix before merge.

- [ ] **Step 4: Commit**

```bash
git add CHANGELOG.md
git commit -m "docs: CHANGELOG entry for Obsidian-vault compatibility"
```

---

## Self-Review (plan vs. spec)

**Spec coverage:**
- D1 (`docs/obsidian.md`) → Task 3. ✅
- D2 (gitignore guardrail: repo + cb-init scaffold) → Task 1 (repo) + Task 2 (cb-init + ExampleApp demo). ✅
- D3 (graph-richness note in `wiki-structure.md`) → Task 4. ✅
- D4 (reframe 3 mentions) → Task 5 steps 1–3. ✅
- D5 (FAQ + cross-link) → Task 5 steps 4–5. ✅
- D6 (launch-post note) → traceability only; no code (per spec). Not a task. ✅
- Spec §6 testing (acceptance: `.obsidian/` ignored; manual Obsidian open; verify.sh green) → Task 1 TDD + Task 6 sweep + the "Verify it yourself" section in `docs/obsidian.md`. ✅
- Spec §7 attribution (Karpathy gist in obsidian.md) → enforced by Gate 4 in Task 3. ✅

**Placeholder scan:** No TBD/TODO. Every file edit shows exact before/after text or full content. ✅

**Type/string consistency:** The gitignore pattern is `.obsidian/` in all three places (Task 1 repo `.gitignore`, Task 2 cb-init instruction, Task 2 ExampleApp file). The doc filename `docs/obsidian.md` and its relative links (`obsidian.md` from `docs/`, `../../docs/obsidian.md` from `skill/references/`) are consistent across Tasks 3–5. ✅

**Scope:** Single implementation plan; ~9 files, all additive/doc-level. No decomposition needed. ✅
