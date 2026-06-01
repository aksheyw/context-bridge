# context-bridge — A Claude Code Skill for Cross-Session Continuity

> **Resume any Claude Code session in 30 seconds, not 30 minutes.**
> Every project gets a tiny structured wiki + a generated handoff prompt that compounds session knowledge instead of losing it.

This is a Claude Code skill that scaffolds a `.claude/wiki/` per project, runs an 11-step protocol at session-close, and prints a paste-and-resume prompt for the next session. Three small files give the next-session model warm context in under 30 seconds, instead of re-loading five files and re-deriving last week's decisions.

It also writes two **honesty rules** into your project's `CLAUDE.md` — never-fabricate, and earned-confidence (95% gate) — that make the wiki *trustworthy* over weeks. Without those, a long-lived wiki becomes a confidently-wrong lie-machine.

## Why I built this

I'd close a Claude Code session on Friday, sit back down Monday, and burn 20-30 minutes re-loading the same five files just to remember where the work was. Sometimes Claude would hallucinate the missing context instead of asking. Either way, real productive time was gone before any actual work happened.

I tried snapshot tools, manual TODO files, and pasting old conversations. None of them compounded — every session started cold, and the same gotchas got re-discovered weekly.

The fix turned out to be two things bolted together:

1. **A small structured wiki** (inspired by [Andrej Karpathy's LLM Wiki gist](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f)) that captures non-obvious decisions + bugs + current focus — not session transcripts.
2. **A handoff prompt** generated at session close that warm-starts the next session by reading just three small files (`_hot.md`, `_log.md`, `_findings.md`).

After 6 months of dogfooding across multiple projects, I packaged the convention as a Claude Code skill so it travels with me — and so other solo devs working on multi-session projects could try it.

## What's in this repo

| Path | Purpose | Lines |
|------|---------|-------|
| `skill/SKILL.md` | The skill body — drop into `~/.claude/skills/context-bridge/` | 169 |
| `skill/commands/` | 5 slash commands: `cb-init`, `cb-status`, `cb-ingest`, `cb-save-sync`, `cb-handoff` | 606 |
| `skill/templates/` | 7 scrubbed templates: `_hot`, `_log`, `_findings`, `_schema`, `decision`, `gotcha`, `CLAUDE.md.snippet` | 293 |
| `skill/references/` | 8 deep references loaded on demand — protocol canon, handoff template, wiki structure, honesty rules, findings register, secret-scan guidance, migration playbook, Karpathy schema delta | 1,176 |
| `.githooks/pre-commit` | Opt-in entropy-required secret + `.cb-scrub-list` proper-noun scan; bash-3.2 portable | 163 |
| `.github/workflows/pii-scrub-check.yml` | CI mirror of the hook + SKILL.md 200-line budget check | 132 |
| `examples/ExampleApp/` | Fictional todo CLI with 3 session snapshots + full finding-lifecycle demo | ~1,100 |
| `docs/` | 9 spillover docs: why, getting-started, install-verification, what-this-is-not, when-not-to-use, adapting-to-other-tools, vs-other-skills, compatibility, faq | ~860 |
| `LICENSE` | MIT | — |

## The standout: handoff prompts + honesty rules

Most "session memory" tools either save transcripts (too noisy) or hand-write summaries (decays in a week). context-bridge does neither — it generates a **structured handoff prompt** at session close that's designed to be pasted verbatim into the next session.

The prompt is short, asks the next session to summarize what it just read, and surfaces 1-3 open questions from `_hot.md`. The result is a warm-resume in under 30 seconds.

What makes it actually work, though, is the **honesty enforcement**. `/cb-init` writes a marked section into your project's `CLAUDE.md`:

```markdown
## Honesty (inherited from context-bridge)

### Never fabricate
No file paths, function names, line numbers, or API signatures stated without
verification via Read / Grep / Glob. If you don't have it, say so plainly.

### Earned confidence (95% gate)
"95% confident" requires full end-to-end homework. Default to a verbal hedge.
```

That section travels with the wiki. Every future session inherits the discipline. Without it, the wiki accumulates confident-sounding wrong claims and you stop trusting it — at which point the whole system is dead weight. With it, the wiki compounds value for months.

## Install

```bash
npx skills add aksheyw/context-bridge
```

That puts the skill at `~/.claude/skills/context-bridge/`. One-time per machine — every project on this machine can now use it.

If `npx skills add` doesn't work for your runtime, see the verified manual-clone fallback in [`docs/install-verification.md`](docs/install-verification.md).

## Use it

```bash
cd ~/path/to/your/project
```

In a Claude Code session:

```
/cb-init
```

That scans for collisions, scaffolds `.claude/wiki/`, and appends a marked section to your `CLAUDE.md`. Never overwrites existing content. Idempotent.

Then work normally. At session close, say **"save and sync"** — the skill runs the 11-step protocol, updates the wiki with your approval per item, and prints a paste-and-resume prompt for the next session.

5-minute quickstart: [`docs/getting-started.md`](docs/getting-started.md).

## Verify install worked

In a fresh Claude Code session:

- Type `/cb-init` — autocomplete should suggest the command.
- Or ask: *"set up context-bridge in this project"* — Claude should pick up the skill by description match.
- All five commands (`cb-init`, `cb-status`, `cb-ingest`, `cb-save-sync`, `cb-handoff`) should show in your slash-command catalog.

After `/cb-init` runs, you should see:

- `.claude/wiki/` directory with `_hot.md`, `_log.md`, `_findings.md`, `_schema.md`.
- A new section in `CLAUDE.md` between `<!-- context-bridge:begin -->` and `<!-- context-bridge:end -->`.
- A 5-line tour printed in the chat telling you where to go next.

If none of that happens, see **Troubleshooting** below.

## Example output

Abbreviated `/cb-handoff` output at the end of a real session (full version at [`examples/ExampleApp/SESSION_HANDOFF_2026-05-25.md`](examples/ExampleApp/SESSION_HANDOFF_2026-05-25.md)):

```
context-bridge /cb-handoff — ExampleApp @ 2026-05-25 evening

Wrote: SESSION_HANDOFF_2026-05-25.md (113 lines)

✂---- copy below this line ----✂

I'm continuing the ExampleApp work. Last session closed 2026-05-25.

Read these in order, fast:
1. .claude/wiki/_hot.md
2. .claude/wiki/_log.md (most recent session entry only)
3. .claude/wiki/_findings.md
4. SESSION_HANDOFF_2026-05-25.md (full handoff)

Then summarize back to me in 5 bullets:
- What we're building + who it's for + who it's NOT for
- What's pending and priority (top 3-5 items)
- Top 3 risks
- Today's first task — a concrete 60-min plan
- The killer demo or output for the next session

After your summary, ask me:
1. Should `list` accept a `--all` flag to also show done tasks?
2. Task IDs: sequential ints or short hashes?
3. Co-pilot mode: A (standby) / B (active co-pilot) / C (code reviewer) / D (build for me)?

Honesty: 95% confidence gate. Never fabricate paths or commands. Use Read/Grep/Glob to verify.
Velocity: speed + usefulness wins. Cut scope when a gate is at risk.

✂---- copy above this line ----✂
```

The pattern: the next session pastes that block, reads three small files, and answers the three open questions before touching any code. End-to-end resume time: under 30 seconds.

`/cb-status` produces the read-only equivalent without writing a handoff doc — useful for a mid-day "where was I" check.

## See it work without installing

The [`examples/ExampleApp/`](examples/ExampleApp/) directory ships a complete worked example — a fictional todo CLI with 3 session snapshots, a real decision capture, a bug-finding lifecycle (`OPEN → RESOLVED → promoted to gotcha`), and the handoff doc that session 3 starts from.

```bash
git clone https://github.com/aksheyw/context-bridge.git
cd context-bridge

# See how the wiki grew over 3 sessions
diff -ru examples/ExampleApp/snapshots/session-1/.claude/wiki \
         examples/ExampleApp/snapshots/session-2/.claude/wiki

# Read the actual handoff that warm-started session 3
cat examples/ExampleApp/SESSION_HANDOFF_2026-05-25.md
```

All content fictional. ExampleApp, ExampleService, ExampleUser — none are real. The example exists so you can evaluate the workflow without installing.

## Troubleshooting

- **`/cb-init` not found in autocomplete.** The skill install didn't register. Restart Claude Code. If still missing, check `~/.claude/skills/context-bridge/` exists and contains `SKILL.md` + `commands/`. Run `npx skills add aksheyw/context-bridge` again or use the [manual-clone fallback](docs/install-verification.md).
- **`/cb-init` says "templates not found".** The skill is installed but templates dir is not at the expected path. Set `CB_TEMPLATES_DIR=~/.claude/skills/context-bridge/templates` and retry.
- **`/cb-init` complains about collisions.** Another tool registered a `/cb-*` command. The command lists the collision and stops — rename the other command or accept the warning to proceed.
- **`_hot.md` keeps growing past 50 lines.** That's the signal to archive older content to `_log.md`. `_hot.md` is "now", not "everything".
- **The pre-commit hook blocks a commit you know is clean.** Either tighten the failing pattern, or `git commit --no-verify` for that single commit. Don't disable the hook globally.

Full FAQ + edge cases: [`docs/faq.md`](docs/faq.md). Compat matrix (OS / tool / git host): [`docs/compatibility.md`](docs/compatibility.md).

## Honest scope — who this is NOT for

- ❌ Single-session weekend scripts
- ❌ Throwaway prototypes
- ❌ Teams already using Confluence + ADRs (coexists but adds little)
- ❌ Workflows where Claude Code is secondary (Cursor / Aider / Codex — see [`docs/adapting-to-other-tools.md`](docs/adapting-to-other-tools.md))
- ❌ Mid-session bloat — that's `/strategic-compact`, not this

Exit ramps + when to skip: [`docs/when-not-to-use.md`](docs/when-not-to-use.md). Full non-goals: [`docs/what-this-is-not.md`](docs/what-this-is-not.md). Comparison vs. neighbouring tools: [`docs/vs-other-skills.md`](docs/vs-other-skills.md).

## Credits

context-bridge stands on shoulders. Full register: [`CREDITS.md`](CREDITS.md).

- **LLM Wiki pattern** — Andrej Karpathy ([gist](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f)) — the wiki-as-compounding-knowledge concept
- **Superpowers ecosystem** — Jesse Vincent ([@obra](https://github.com/obra), [sponsor](https://github.com/sponsors/obra)) — workflow patterns + the "skill that explains how to use skills" idea
- **Claude Code + Skills format** — Anthropic
- **TDD discipline** — Kent Beck
- Original additions by Akshey Walia: the 11-step save+sync protocol, `_hot.md`/`_findings.md`/`decisions/`/`gotchas/` wiki extensions, the handoff prompt template, the honesty rules

## License + security

MIT — see [`LICENSE`](LICENSE). Vulnerability disclosure via GitHub Security Advisories on this repo — see [`SECURITY.md`](SECURITY.md). Code of Conduct: [`CODE_OF_CONDUCT.md`](CODE_OF_CONDUCT.md) (Contributor Covenant 2.1).

## Contributing

See [`CONTRIBUTING.md`](CONTRIBUTING.md) for the contribution flow + the 8 gates every PR must pass. Local gate runner: `scripts/verify.sh` runs all 8 with a single command.
