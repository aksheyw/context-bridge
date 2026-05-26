# Getting started

5 minutes from zero to a working `/cb-init` in your first project.

## Prerequisites

- macOS or Linux (Windows users: WSL works; native Windows is v0.2 — see [`docs/compatibility.md`](compatibility.md)).
- [Claude Code](https://claude.ai/code) installed and signed in.
- `git` installed (you almost certainly already have it).
- A multi-session project you actually care about (not a throwaway script — see [`docs/when-not-to-use.md`](when-not-to-use.md)).

## Install

```bash
npx skills add aksheyw/context-bridge
```

That puts the skill at `~/.claude/skills/context-bridge/`. It's a one-time install per machine — every project on this machine can now use it.

If `npx skills add` doesn't work for your setup, see [`docs/install-verification.md`](install-verification.md) for the fallback path.

## Initialise a project

```bash
cd ~/path/to/your/project
```

Then in your Claude Code session:

```
/cb-init
```

What happens:

1. **Pre-flight scan.** Checks for collisions with other `/cb-*` commands, any existing `.claude/wiki/`, an existing `CLAUDE.md` marker. Prints a summary block.
2. **User confirmation.** It will NOT touch your project until you say yes.
3. **Scaffold.** Creates `.claude/wiki/` with `_hot.md`, `_log.md`, `_findings.md`, `_schema.md`.
4. **CLAUDE.md append.** Adds a marked section between `<!-- context-bridge:begin -->` and `<!-- context-bridge:end -->`. Never overwrites your existing content. Re-running is a no-op for the marked section.
5. **5-line tour.** Tells you where to go next.

If your project already has a `.claude/wiki/` (e.g. from a prior [Karpathy LLMwiki](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f)-style setup), `/cb-init` will detect it and offer three options: **migrate**, **adopt as-is**, or **refuse**. Nothing is touched until you choose.

## First edit

Open `.claude/wiki/_hot.md`. Replace the placeholders with your project's reality:

- **Current phase** — one paragraph: what you're building, what stage.
- **Top tasks for next session** — 1-5 numbered items.
- **Open blockers / questions** — anything you're stuck on.
- **Risks** — known unknowns, severity-tagged.

This file is the answer to "where is the work" when you sit down next week. Keep it short (~50 lines max — bigger and you're using it wrong).

## Per-session loop

### At session start

In a fresh Claude Code session in this project:

```
/cb-status
```

You get a 5-bullet snapshot pulled from `_hot.md` + last `_log.md` entry + open `_findings.md` items. Read-only — never writes.

### Mid-session

When you discover something non-obvious that a future session would re-derive painfully:

```
/cb-ingest "the foo client retries 5xx silently — passing { retries: 0 } is the only fix"
```

It will ask you to classify (gotcha / decision / finding / log-note) and route the entry to the right wiki file.

### At session close

Say:

```
save and sync
```

Or run `/cb-save-sync` directly. It walks the 11-step protocol with user-gated approval at sensitive steps (commit message, wiki edits, push). At the end it runs `/cb-handoff` which:

- Generates a `SESSION_HANDOFF_<today>.md` at your repo root.
- Prints a paste-and-resume prompt you can copy into the next session.

### Next session

Paste the handoff prompt into a fresh Claude Code session. Claude reads 3 small files and summarises in 5 bullets. Warm resume in <30 seconds.

## What lives where, after `/cb-init`

```
<your-project>/
├── CLAUDE.md                        # ← has the marked context-bridge section appended
├── .claude/
│   └── wiki/
│       ├── _hot.md                  # current focus + blockers + risks
│       ├── _log.md                  # append-only session log
│       ├── _findings.md             # open issues, severity-ordered
│       ├── _schema.md               # the schema for THIS project
│       ├── decisions/               # created lazily, one file per decision
│       └── gotchas/                 # created lazily, promoted from resolved findings
└── SESSION_HANDOFF_<date>.md        # written by /cb-handoff at session close
```

Everything is plain markdown. `git diff` is your audit trail. `grep` is your search.

## Optional but recommended — local pre-commit hook

If you ever commit a wiki page that grew over weeks, you risk pasting in something sensitive without realising. The context-bridge repo ships a hook that scans staged content for common secret patterns and a per-project proper-noun list.

To enable it in YOUR project (one-time):

```bash
# Copy the hook into your project
cp ~/.claude/skills/context-bridge/.githooks/pre-commit .githooks/pre-commit
chmod +x .githooks/pre-commit

# Point git at it
git config core.hooksPath .githooks

# (Optional) create a per-project scrub list
echo "MyInternalProductName" >> .cb-scrub-list
echo ".cb-scrub-list" >> .gitignore
```

The hook blocks commits that hit a pattern. To bypass for one commit (not recommended): `git commit --no-verify`.

## Troubleshooting

- **`/cb-init` says "templates not found".** The skill install didn't put templates where the command expects. Set `CB_TEMPLATES_DIR=~/.claude/skills/context-bridge/templates` in your shell and retry.
- **`/cb-init` complains about collisions.** Some other tool registered a `/cb-*` command. The command lists the collision and stops — rename the other command or accept the warning to proceed.
- **`_hot.md` keeps growing past 50 lines.** That's the signal to archive older content to `_log.md` and refocus. `_hot.md` is "now", not "everything".

## Next reads

- [`docs/why.md`](why.md) — the design reasoning.
- [`docs/install-verification.md`](install-verification.md) — paths and fallbacks.
- [`docs/faq.md`](faq.md) — common questions.
- [`docs/vs-other-skills.md`](vs-other-skills.md) — comparison vs. `save-session`, `llm-wiki`, Superpowers.
