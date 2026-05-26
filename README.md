# context-bridge

> **Resume your Claude Code sessions warm.** A small per-project wiki + a generated handoff prompt — designed to stop cross-session amnesia without re-loading 5 files every time.

**Status:** 🚧 v0.1 spec complete. Skill ships within 7 days (target: Wed 2026-05-27).
**Design spec:** [`docs/superpowers/specs/2026-05-26-context-bridge-design.md`](docs/superpowers/specs/2026-05-26-context-bridge-design.md)

---

## The problem

Claude Code sessions fail in two predictable ways:

1. **Mid-session bloat** — context fills with stale chat; hallucinations creep in.
2. **Cross-session amnesia** — every new session re-loads 5 files just to remember WHERE the work is.

Most people fix (1) with `/clear` and then suffer (2) immediately.

## What this fixes

**Cross-session amnesia.** Every project gets a tiny structured wiki at `.claude/wiki/`. Each session-close generates a portable handoff prompt. Next session pastes it, reads three small files, and resumes warm.

## What this does NOT fix

- ❌ Mid-session bloat (use `/strategic-compact` or `/aside`)
- ❌ Multi-agent coordination
- ❌ Team-shared knowledge
- ❌ IDE-level context (autocomplete, embeddings)
- ❌ Code-aware retrieval — the wiki is plain markdown
- ❌ Auto-summarization of past sessions

Full non-goals: [`docs/what-this-is-not.md`](docs/what-this-is-not.md) (coming with v0.1).

## Who it's for

- ✅ Multi-session projects (lifespan > ~3 days)
- ✅ Solo developers using Claude Code primarily
- ✅ Projects that ship → revisit → ship again

Who it's NOT for: single-session scripts, throwaway prototypes, teams with an existing opinionated docs system. See [`docs/when-not-to-use.md`](docs/when-not-to-use.md) when shipped.

## Install (coming with v0.1)

```bash
# Primary (subject to community-skill support verification)
npx skills add aksheyw/context-bridge

# Fallback
curl -sSL https://raw.githubusercontent.com/aksheyw/context-bridge/main/install.sh | bash
```

Then in any project:

```bash
/cb-init      # scaffolds .claude/wiki/ + appends a marked CLAUDE.md section
```

## Usage (preview)

| Command | Purpose |
|---|---|
| `/cb-init` | Scaffold `.claude/wiki/` and append CLAUDE.md section |
| `/cb-status` | Read `_hot.md` and print 5-bullet summary |
| `/cb-ingest` | Capture a learning into the wiki |
| `/cb-save-sync` | Run the 11-step save+sync protocol |
| `/cb-handoff` | Generate next-session handoff prompt |

## How it differs from existing skills

| | `context-bridge` | `save-session` / `resume-session` | `llm-wiki` (based on Karpathy) | Claude Code native memory |
|---|---|---|---|---|
| Scope | per-project bridge | session-blob snapshots | per-project wiki | global per-user |
| Schema | opinionated | none | flexible | flat |
| Handoff prompt | yes | no | no | n/a |
| Save+sync protocol | 11-step | save only | no | n/a |
| Honesty rules built in | yes | no | no | no |
| Findings register | yes | no | no | no |

Full comparison: [`docs/vs-other-skills.md`](docs/vs-other-skills.md) (coming).

## Credits

context-bridge stands on shoulders. Full register: [`CREDITS.md`](CREDITS.md).

- **LLMwiki pattern** — Andrej Karpathy (the wiki-as-compounding-knowledge concept)
- **Superpowers ecosystem** — Jesse Vincent ([@obra](https://github.com/obra)) — workflow patterns + the "skill that explains how to use skills" idea
- **Claude Code + Skills format** — Anthropic
- Original additions by Akshey Walia: the 11-step save+sync protocol, `_hot.md`/`_findings.md`/`decisions/`/`gotchas/` wiki extensions, the handoff prompt template, the honesty rules

## License

MIT. See [`LICENSE`](LICENSE).

## Security

Report vulnerabilities via GitHub Security Advisories on this repo. See [`SECURITY.md`](SECURITY.md) when shipped.

## Roadmap

- **v0.1** (Wed 2026-05-27): the skill bundle described in the spec
- **v0.2** (next month): monorepo support, cross-tool adapters, `/cb-find` search
- **v0.3+**: team-shared wikis, MCP server, web UI

## Contributing

CONTRIBUTING.md ships with v0.1. Until then, open an issue to discuss anything.

---

Built because friends kept asking how my Claude Code sessions stay coherent across days. This is the answer, generalized.
