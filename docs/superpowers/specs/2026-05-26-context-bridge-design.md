# context-bridge v0.1 — Design Spec

**Status:** v3 design. Deep-reviewed (Round 1, 14 lenses, 15 findings) + audited (Rounds 2-3, ripple search + iterative depth, 10 more findings). All 25 unique findings closed in this spec.
**Author:** Akshey Walia
**Date:** 2026-05-26
**Repo:** [github.com/aksheyw/context-bridge](https://github.com/aksheyw/context-bridge)
**License:** MIT
**Spec format:** [Superpowers](https://github.com/obra/superpowers) brainstorming-skill convention.

---

## 1. Problem + scope honesty

### 1.1 The pain
Claude Code sessions get expensive fast. Two failure modes recur:

1. **Mid-session bloat.** The context window fills with stale conversation. The model starts hallucinating because the relevant facts are buried in irrelevant chat.
2. **Cross-session amnesia.** Starting a new session means re-loading 5+ files just to remember WHERE the work was. Often the same insights get re-derived weekly.

Most users solve (1) by `/clear`-ing and then immediately suffer (2).

### 1.2 What context-bridge fixes
**Cross-session amnesia (failure mode #2).** It gives every Claude Code project a small, structured wiki (`.claude/wiki/`) plus a generator that turns each session's work into a portable handoff prompt. The next session pastes that prompt, reads three small files, and resumes warm.

### 1.3 What it does NOT fix
Stated explicitly because friends will assume otherwise:

- ❌ **Mid-session bloat.** Use `/strategic-compact`, `/aside`, or Claude Code's native compaction for that.
- ❌ **Multi-agent coordination.** Single-user.
- ❌ **Team-shared knowledge.** Single-machine, single-developer.
- ❌ **IDE-level context** (autocomplete, embeddings). Claude Code only.
- ❌ **Code-aware retrieval.** The wiki is plain markdown; grep is the search.
- ❌ **Auto-summarization of past sessions.** The author decides what's durable.

### 1.4 Who it's for
- ✅ Multi-session projects (lifespan > ~3 days)
- ✅ Solo developers using Claude Code primarily
- ✅ Projects that ship → revisit → ship again

### 1.5 Who it's NOT for
- ❌ Single-session weekend scripts
- ❌ Throwaway prototypes
- ❌ Teams that already have an opinionated docs system (Confluence + ADRs)
- ❌ Workflows where Claude Code is secondary (Cursor/Aider/Codex users — see `docs/adapting-to-other-tools.md`)

---

## 2. Goals + non-goals

### 2.1 v0.1 goals
- **G1. 30-second resume.** Pasting the handoff prompt lets any fresh Claude Code session summarize project state in <30s.
- **G2. Zero new runtime dependencies.** Pure markdown + bash. No Python, Node services, or daemons beyond what Claude Code already provides.
- **G3. Single-install adoption.** One install command (`docs/install-verification.md`) + `/cb-init` in a project = ready.
- **G4. Honest by default.** Honesty + 95%-confidence rules built into the skill body — adopters inherit them.
- **G5. Safe defaults.** Pre-commit secret + PII scan; no surprise leakage.

### 2.2 v0.1 non-goals (deferred to v0.2+)
- **N1.** Cross-tool installer (Cursor/Aider/Codex) — methodology documented; install not provided.
- **N2.** Team-shared wikis.
- **N3.** Wiki search beyond grep.
- **N4.** Auto-summarize past sessions.
- **N5.** MCP server.
- **N6.** Web UI to browse the wiki.

---

## 3. User journey

### 3.1 First-time setup (one-time per machine)
1. Install: `npx skills add aksheyw/context-bridge` (primary path) OR `curl -sSL https://raw.githubusercontent.com/aksheyw/context-bridge/main/install.sh | bash` (fallback). Both verified in `docs/install-verification.md`.
2. `cd <my-project>`
3. `/cb-init` — pre-flight scans for collisions, then scaffolds `.claude/wiki/` and appends a marked section to CLAUDE.md (never overwrites). Prints a 5-line tour.

### 3.2 Per-session loop
- **Session start:** Claude sees the marked section in CLAUDE.md, reads `_hot.md`, knows where to begin.
- **Mid-session:** `/cb-ingest "<learning>"` captures a non-obvious insight as it surfaces (optional).
- **Session close:** user says "save and sync" → skill runs the 11-step protocol → wiki updated → handoff prompt printed.
- **Next session:** paste handoff prompt → Claude reads 3 small files → resumes warm.

### 3.3 Slash commands
| Command | Purpose |
|---|---|
| `/cb-init` | Scaffold `.claude/wiki/` + append CLAUDE.md section |
| `/cb-status` | Read `_hot.md` + print 5-bullet summary |
| `/cb-ingest` | Capture a learning into the wiki |
| `/cb-save-sync` | Run the 11-step save+sync protocol |
| `/cb-handoff` | Generate next-session handoff prompt |

All commands use the `cb-` prefix; pre-flight scan in `/cb-init` detects collisions.

---

## 4. Architecture

### 4.1 Repo layout

```
context-bridge/
├── README.md                          # Pitch + problem + who it's for + vs.-others
├── CREDITS.md                         # Karpathy + Vincent + Anthropic + author's deltas
├── CHANGELOG.md                       # keepachangelog format
├── CONTRIBUTING.md
├── CODE_OF_CONDUCT.md                 # Contributor Covenant v2.1
├── SECURITY.md                        # Vuln disclosure via GitHub Security Advisories
├── LICENSE                            # MIT, holder = Akshey Walia
├── .github/
│   ├── ISSUE_TEMPLATE/{bug_report,feature_request}.md
│   ├── PULL_REQUEST_TEMPLATE.md
│   └── workflows/
│       └── pii-scrub-check.yml        # Repo-wide PII guard
├── .githooks/pre-commit               # Local PII + secret scan; users opt in via core.hooksPath
├── .gitignore                         # Incl. local-only scrub list
│
├── skill/                             # The installable artifact
│   ├── SKILL.md                       # <200-line body; deep content in references/
│   ├── references/
│   │   ├── save-sync-protocol.md      # The 11-step canon (author's original)
│   │   ├── handoff-template.md        # Next-session prompt format
│   │   ├── wiki-structure.md          # Schema + Karpathy delta
│   │   ├── honesty-rules.md           # 95% gate + no-fabrication
│   │   ├── findings-register.md       # Severity / phase / lifecycle
│   │   ├── secret-scan-guidance.md    # Step 0 of protocol
│   │   ├── migration-from-existing.md # If user already has llm-wiki or any .claude/wiki/
│   │   └── karpathy-schema-delta.md   # What we add to original LLMwiki
│   ├── templates/                     # All scrubbed; only ExampleApp; CI-enforced
│   │   ├── _hot.md
│   │   ├── _log.md
│   │   ├── _findings.md
│   │   ├── _schema.md
│   │   ├── CLAUDE.md.snippet          # Appended, not overwritten
│   │   ├── decision.md
│   │   └── gotcha.md
│   └── commands/                      # Slash command bodies
│       ├── cb-init.md
│       ├── cb-status.md
│       ├── cb-ingest.md
│       ├── cb-save-sync.md
│       └── cb-handoff.md
│
├── examples/
│   └── ExampleApp/                    # Fictional, fully anonymized
│       ├── CLAUDE.md
│       ├── .claude/wiki/
│       │   ├── _hot.md
│       │   ├── _log.md                # 3 sessions
│       │   ├── _findings.md
│       │   ├── _schema.md
│       │   └── decisions/d-2026-05-26-example.md
│       ├── snapshots/                 # Wiki state per session
│       │   ├── session-1/
│       │   ├── session-2/
│       │   └── session-3/
│       └── SESSION_HANDOFF_session-3.md
│
├── docs/
│   ├── why.md                         # Karpathy + the context-pain story
│   ├── getting-started.md             # 5-min quickstart
│   ├── what-this-is-not.md            # Non-goals (mirrors §1.3)
│   ├── when-not-to-use.md             # Short-lifespan filter
│   ├── adapting-to-other-tools.md     # Cursor / Aider / Codex notes
│   ├── vs-other-skills.md             # Differentiation table
│   ├── compatibility.md               # macOS / Linux / WSL only (Windows-native unsupported in v0.1)
│   ├── install-verification.md        # Verified install paths
│   ├── faq.md
│   └── demos/
│       ├── install.gif                # 30s: install + bootstrap
│       └── save-sync.gif              # 60s: save-sync + warm resume
│
└── docs/superpowers/specs/
    └── 2026-05-26-context-bridge-design.md  # This spec
```

### 4.2 Skill loading model
The main `skill/SKILL.md` is light (<200 lines body). Per-topic deep content lives in `references/` and is loaded on demand by the Skill tool. This avoids the failure mode the skill is designed to prevent.

---

## 5. Methodology

### 5.1 The 11-step save+sync protocol

> **Authorship:** The 11-step protocol below is original work by Akshey Walia. Karpathy provided the wiki shape; the protocol is from this author's `~/.claude/rules/workflow.md` (local config, cited for provenance). Step 0 (secret + PII scan) was added during the design audit for context-bridge.

| Step | Action | Notes |
|---:|---|---|
| 0 | **Secret + PII scan** | Grep all about-to-commit files for known secret patterns + project-specific proper nouns. Block on hit; require scrub or whitelist before continuing. |
| 1 | Run tests | Flag failures; update test count in CLAUDE.md if changed. |
| 2 | `git commit` locally | All changes; always safe. Specific files preferred over `git add -A`. |
| 3 | Push docs to remote | `.md` files only by default; full push only on explicit opt-in or feature branch. |
| 4 | Push feature branch | If on feature branch, push as remote backup. |
| 5 | (Optional) Docs-health check | Run project's docs lint if any. Skip if none. |
| 6 | Wiki sync | Propose specific wiki page updates from this session. User approves per item. Approved edits land in step 2's commit. |
| 7 | Bump `_hot.md` + append `_log.md` | Current focus + one-line session entry. |
| 8 | Promote findings | Major findings → `_findings.md` with severity + status + resolution path. |
| 9 | Update memory | Record session summary in memory + update `MEMORY.md` if used. |
| 10 | Generate handoff | Print the next-session handoff prompt + save to `SESSION_HANDOFF_<date>.md`. |

Steps 5, 6 (user approval), 7, 9 are project-specific in effect but procedurally identical across projects.

### 5.2 Wiki schema

Inspired by Karpathy's LLM Wiki pattern ([gist](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f), `_index/_log/_schema/<topic>.md`). The following additions are context-bridge's own (per `references/karpathy-schema-delta.md`):

| File | Purpose | New in context-bridge? |
|---|---|---|
| `_hot.md` | Current focus + open blockers (always-on-top) | ✅ NEW |
| `_log.md` | Append-only session log | (Karpathy) |
| `_findings.md` | Open issues with severity + phase | ✅ NEW |
| `_schema.md` | Wiki schema for THIS project | (Karpathy) |
| `_index.md` | Topic catalog (optional) | (Karpathy) |
| `decisions/d-YYYY-MM-DD-<name>.md` | Architectural decisions | ✅ NEW |
| `gotchas/gotcha-<topic>.md` | Surprises + fixes | ✅ NEW |
| `references/<topic>.md` | Durable lookup info | (Karpathy) |

### 5.3 Handoff prompt template

```
I'm continuing the <project> work. Last session closed at <YYYY-MM-DD>.

Read these in order, fast:
1. <project>/.claude/wiki/_hot.md (what's hot)
2. <project>/.claude/wiki/_log.md (last session entry)
3. <project>/.claude/wiki/_findings.md (open issues)
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

### 5.4 Honesty rules

Two core rules, codified in `skill/references/honesty-rules.md`:

- **Never fabricate.** No file paths, function names, line numbers, or signatures without verification via Read/Grep/Glob.
- **Earned confidence.** "95% confident" requires full end-to-end homework (trace code path, verify data shape at each boundary, check failure modes, read tests).

The skill writes these into the project's CLAUDE.md as a marked section.

### 5.5 Findings register

`_findings.md` lifecycle:
- **States:** `OPEN → IN PROGRESS → RESOLVED → ACCEPTED`
- **Severity:** 🔴 CRITICAL / 🟡 HIGH / 🟢 MEDIUM/LOW
- **Each entry:** ID + severity + status + phase to fix + detail + mitigation + owner
- **On resolution:** entries with non-obvious fixes get promoted to `gotchas/`

---

## 6. ExampleApp

`examples/ExampleApp/` is a fictional to-do product, fully scrubbed of any real-world project references. Demonstrates:

- **Initial bootstrap** — `.claude/wiki/` after `/cb-init`
- **Session 1** — a feature was scoped, decision made → `_log.md` entry + `decisions/` page created
- **Session 2** — a bug was investigated → `_findings.md` entry + handoff generated
- **Session 3** — warm resume from handoff → reads wiki, summarizes, acts

Each session's wiki state is a separate snapshot in `examples/ExampleApp/snapshots/session-N/` so adopters see the diff progression.

---

## 7. Distribution + launch

### 7.1 Day 2-3 ship plan
- **Day 2 (Tue 2026-05-26):** Write spec (this file) + push README + LICENSE + CREDITS + spec to GitHub shell.
- **Day 3 (Wed 2026-05-27):** Write skill body, templates, commands. Test on a fresh dummy project. Record both demo GIFs. Push v0.1 release.
- **Day 3 evening:** LinkedIn launch post (after the day's primary commitment ships).

### 7.2 Launch post outline
- **Hook:** the friend-pain — Claude Code context bloat → hallucinations.
- **Insight:** treat sessions as relay batons, not marathons.
- **Asset:** the install + save-sync GIFs.
- **Link:** github.com/aksheyw/context-bridge.
- **Credits inline:** Karpathy LLMwiki + Vincent's Superpowers + Anthropic Claude Code.

### 7.3 Install verification
Two paths, both verified before v0.1 ship and documented in `docs/install-verification.md`:
- **Primary:** `npx skills add aksheyw/context-bridge` (assuming community-skill support; verify before v0.1)
- **Fallback:** `curl -sSL https://raw.githubusercontent.com/aksheyw/context-bridge/main/install.sh | bash` (writes to `~/.claude/skills/context-bridge/`)

If the primary path doesn't work for community skills, fallback becomes primary.

---

## 8. Attribution + credits

Full register lives in `CREDITS.md`. Summary:

| Source | Author / Holder | License | What we draw on |
|---|---|---|---|
| **LLM Wiki pattern** | Andrej Karpathy ([gist](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f)) | (idea / public gist; no formal license attached) | Wiki-as-compounding-knowledge concept; the `_log/_schema/<topic>` shape; LLM-maintained-vs-query-time-retrieval framing |
| **Superpowers ecosystem** | Jesse Vincent ([obra](https://github.com/obra)) | MIT (Copyright 2025) | The brainstorming → spec → plan workflow; the "skill that explains how to use skills" pattern; the `/cb-*` slash-command structure inspiration |
| **Claude Code** | Anthropic | proprietary CLI | The skill format, slash-command format, `.claude/` directory convention |
| **Anthropic Skills format** | Anthropic | (format spec) | YAML frontmatter, references/, the Skill tool |
| **Akshey's `audit` skill** | Akshey Walia | — | The 14-lens deep-review + ripple-search methodology used to QA THIS design |
| **Kent Beck** | — | — | TDD discipline informing save+sync gates |
| **`save-session` / `resume-session` skills** | Akshey Walia (Claude Code skill) | — | Conceptual ancestors of `/cb-save-sync` + `/cb-handoff`; superseded by this skill |

### 8.1 What's NEW in context-bridge (vs. originals)
- The **11-step save+sync protocol** is original work by the author.
- `_hot.md`, `_findings.md`, `decisions/`, `gotchas/` are additions to Karpathy's original wiki shape.
- The **handoff prompt template** (5-bullet summary + question gate + honesty/velocity reminders) is original and battle-tested across multiple of the author's projects.
- The **honesty rules** (95% confidence gate, never-fabricate) are the author's, codified in the local `~/.claude/rules/honesty.md`.

---

## 9. Security model

### 9.1 PII / proper-noun discipline
- All templates use ONLY placeholder names (`ExampleApp`, `ExampleService`, `ExampleUser`).
- Local git pre-commit hook (`.githooks/pre-commit`, opt-in via `git config core.hooksPath .githooks`) scans for proper nouns from a local scrub list (gitignored).
- CI workflow (`.github/workflows/pii-scrub-check.yml`) runs the same scan repo-wide on every PR.
- The author maintains `PROPER_NOUN_SCRUB_LIST.md` locally (gitignored) listing project names, real URLs, real IDs to scrub before any commit.

### 9.2 Secret discipline
- GitHub repo has secret-scanning + push-protection enabled (verified 2026-05-26).
- Local pre-commit hook also scans for common secret patterns (`sk-`, `ghp_`, `eyJ` JWTs, etc.).
- Step 0 of the save+sync protocol runs the same scan inside any adopter project.
- Documentation explicitly warns: wiki content can carry secrets if pasted. Never paste API keys into the wiki.

### 9.3 Push hygiene
- Step 3 of the protocol pushes `.md` files only by default.
- Recommended `.gitignore` patterns include `.claude/wiki/*-private.md` for personal-only notes.
- If a project is going public, `_findings.md` detail fields must be redacted before promote-to-public.

### 9.4 Vulnerability disclosure
Report via GitHub Security Advisories on the repo. SECURITY.md documents the process.

---

## 10. Failure modes + edge cases

| Scenario | Behavior |
|---|---|
| `/cb-init` in dir without existing CLAUDE.md | Creates one with marked context-bridge section. |
| `/cb-init` in dir WITH existing CLAUDE.md | Appends marked section; never overwrites existing content. |
| `/cb-init` in dir WITH existing `.claude/wiki/` | Detects, prompts: migrate / adopt / refuse. |
| `/cb-init` collision with existing `/cb-*` commands | Pre-flight scan detects; warns and aborts. |
| Wiki gets manually corrupted | `/cb-status` detects malformed frontmatter; suggests fixes. |
| `/cb-save-sync` mid-failed-tests | Surfaces failures; warns but does not block save (user choice). |
| Handoff template exceeds 200 lines | `/cb-handoff` truncates oldest entries; warns. |
| User uninstalls the skill | Wiki + scaffolding remain in project; no coupling. |
| User on Windows native (not WSL) | `docs/compatibility.md` documents lack of v0.1 support; v0.2 candidate. |
| User has `tasks/lessons.md` (different convention) | `/cb-init` detects, leaves it untouched, notes both can coexist. |

---

## 11. v0.1 vs. v0.2+ scope split

### 11.1 v0.1 (this week, Day 2-3)
- Skill bundle + 5 slash commands
- Templates (scrubbed) + ExampleApp with 3 sessions
- README, CREDITS, LICENSE, CHANGELOG, CONTRIBUTING, CODE_OF_CONDUCT, SECURITY
- CI: pii-scrub-check
- Local pre-commit hook (opt-in)
- 2 demo GIFs
- Install verification doc

### 11.2 v0.2 (next month)
- Monorepo support (per-package wikis)
- Cross-tool installer adapters (Cursor / Aider / Codex)
- Wiki search beyond grep (simple `/cb-find <term>`)
- Skill linting + automated template-integrity tests
- Windows-native path support

### 11.3 v0.3+ (later)
- Team-shared wikis (probably becomes a separate product)
- MCP server for IDE plugins
- Web UI to browse / edit wiki

---

## 12. Open questions

| Q | Phase to resolve |
|---|---|
| Does `npx skills add` support community skills, or only Anthropic-hosted? | Day 3 (before publishing install command) |
| Is `.githooks/` opt-in (via `core.hooksPath`) sufficient, or do we need a one-line install script? | Day 3 |
| Should `_hot.md` have a max-size cap to prevent it becoming another bloat point? | v0.2 |
| Migration UX for users on existing `llm-wiki` setups — interactive prompt or doc? | Day 3 |

---

## Spec self-review pass (2026-05-26)

Per superpowers brainstorming convention, this spec has been self-reviewed for:
- **Placeholder scan:** No "TBD" / "TODO" / incomplete sections. Open questions captured in §12.
- **Internal consistency:** Step counts, file paths, severity labels, version splits all reconciled.
- **Scope check:** Single implementation plan possible from this spec. No decomposition needed.
- **Ambiguity:** No requirement should be interpretable two ways.
- **Proper-noun scrub:** No real-project names, no real third-party service URLs, no real cloud-project IDs, no real chat/account IDs.

Open for user review before any implementation.

---

End of spec.
