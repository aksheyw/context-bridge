# context-bridge

> **Resume your Claude Code sessions warm.** A small per-project wiki + a generated handoff prompt — designed to stop cross-session amnesia without re-loading 5 files every time.

**Status:** ✅ v0.1 shipped — skill bundle + 5 slash commands + 7 templates + 8 references + CI + pre-commit hook + worked example. Demo GIFs follow in v0.1.1.
**Design spec:** [`docs/superpowers/specs/2026-05-26-context-bridge-design.md`](docs/superpowers/specs/2026-05-26-context-bridge-design.md) · **Changelog:** [`CHANGELOG.md`](CHANGELOG.md)

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

Full non-goals: [`docs/what-this-is-not.md`](docs/what-this-is-not.md).

## Who it's for

- ✅ Multi-session projects (lifespan > ~3 days)
- ✅ Solo developers using Claude Code primarily
- ✅ Projects that ship → revisit → ship again

Who it's NOT for: single-session scripts, throwaway prototypes, teams with an existing opinionated docs system. See [`docs/when-not-to-use.md`](docs/when-not-to-use.md).

## Install

```bash
# Primary — verified
npx skills add aksheyw/context-bridge
```

Fallback (if the primary path doesn't work for your runtime) — manual clone, verified:

```bash
mkdir -p ~/.claude/skills
git clone https://github.com/aksheyw/context-bridge.git ~/.claude/skills/context-bridge-src
ln -s ~/.claude/skills/context-bridge-src/skill ~/.claude/skills/context-bridge
```

Full install verification (what gets installed where, how to confirm, how to uninstall): [`docs/install-verification.md`](docs/install-verification.md).

Then in any project:

```bash
/cb-init      # scaffolds .claude/wiki/ + appends a marked CLAUDE.md section
```

5-minute quickstart: [`docs/getting-started.md`](docs/getting-started.md).

## Usage

| Command | Purpose |
|---|---|
| `/cb-init` | Scaffold `.claude/wiki/` and append CLAUDE.md section |
| `/cb-status` | Read `_hot.md` and print 5-bullet summary |
| `/cb-ingest` | Capture a learning into the wiki |
| `/cb-save-sync` | Run the 11-step save+sync protocol |
| `/cb-handoff` | Generate next-session handoff prompt |

Worked example with three session snapshots: [`examples/ExampleApp/`](examples/ExampleApp/).

## How it differs from existing skills

| | `context-bridge` | `save-session` / `resume-session` | `llm-wiki` (based on Karpathy) | Claude Code native memory |
|---|---|---|---|---|
| Scope | per-project bridge | session-blob snapshots | per-project wiki | global per-user |
| Schema | opinionated | none | flexible | flat |
| Handoff prompt | yes | no | no | n/a |
| Save+sync protocol | 11-step | save only | no | n/a |
| Honesty rules built in | yes | no | no | no |
| Findings register | yes | no | no | no |

Full comparison: [`docs/vs-other-skills.md`](docs/vs-other-skills.md).

## Credits

context-bridge stands on shoulders. Full register: [`CREDITS.md`](CREDITS.md).

- **LLM Wiki pattern** — Andrej Karpathy ([gist](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f)) — the wiki-as-compounding-knowledge concept
- **Superpowers ecosystem** — Jesse Vincent ([@obra](https://github.com/obra)) — workflow patterns + the "skill that explains how to use skills" idea
- **Claude Code + Skills format** — Anthropic
- Original additions by Akshey Walia: the 11-step save+sync protocol, `_hot.md`/`_findings.md`/`decisions/`/`gotchas/` wiki extensions, the handoff prompt template, the honesty rules

## License

MIT. See [`LICENSE`](LICENSE).

## Security

Report vulnerabilities via GitHub Security Advisories on this repo. See [`SECURITY.md`](SECURITY.md).

## Roadmap

- **v0.1** (✅ shipped): skill bundle, 5 slash commands, templates, references, CI, pre-commit hook, ExampleApp, OSS hygiene
- **v0.1.1**: demo GIFs (install + save-sync) — recording-only, no behavior changes
- **v0.2** (next month): monorepo support, cross-tool adapters, `/cb-find` search, Windows-native paths
- **v0.3+**: team-shared wikis, MCP server, web UI

## Contributing

See [`CONTRIBUTING.md`](CONTRIBUTING.md) for the contribution flow + the 7 gates every PR must pass. Code of Conduct: [`CODE_OF_CONDUCT.md`](CODE_OF_CONDUCT.md) (Contributor Covenant 2.1).

---

Built because friends kept asking how my Claude Code sessions stay coherent across days. This is the answer, generalized.
