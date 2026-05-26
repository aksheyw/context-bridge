# Install verification

This page documents the install paths that have been verified and the ones still in-flight. It closes finding **F1** from [`/.claude/wiki/_findings.md`](../.claude/wiki/_findings.md).

## Primary install — verified

```bash
npx skills add aksheyw/context-bridge
```

**Status:** ✅ Verified for community-hosted skills via the `aksheyw/context-bridge` GitHub repo. Installs to `~/.claude/skills/context-bridge/`.

**What "verified" means here:**

- The command resolves the `aksheyw/context-bridge` GitHub repo.
- It pulls the contents of `skill/` into `~/.claude/skills/context-bridge/`.
- Claude Code surfaces the skill (visible via `/skills` or equivalent listing in your runtime).
- All 5 slash commands (`/cb-init`, `/cb-status`, `/cb-ingest`, `/cb-save-sync`, `/cb-handoff`) appear in the slash-command catalog.

**What's NOT in scope of this verification:**

- Plugin-marketplace compatibility for runtimes other than Claude Code. context-bridge is a Claude-Code-native skill in v0.1; runtimes that load the skill via a different mechanism (Copilot, Codex, Gemini CLI) may need their own packaging — see [`docs/adapting-to-other-tools.md`](adapting-to-other-tools.md).

## Fallback install — manual clone

If `npx skills add` is not available or doesn't work for your setup:

```bash
mkdir -p ~/.claude/skills
git clone https://github.com/aksheyw/context-bridge.git ~/.claude/skills/context-bridge-src
# Link the skill subdir into Claude Code's expected location
ln -s ~/.claude/skills/context-bridge-src/skill ~/.claude/skills/context-bridge
```

**Status:** ✅ Verified. Files end up at the same path as the `npx skills add` flow.

If your Claude Code install expects a non-symlinked directory, replace the `ln -s` with a copy:

```bash
cp -R ~/.claude/skills/context-bridge-src/skill ~/.claude/skills/context-bridge
```

The copy form means updates require a re-pull. The symlink form means `git pull` in the `-src` directory updates the live skill — handy during development.

## Verifying the install worked

After installing, run this in any Claude Code session:

```
/cb-init
```

If the command isn't recognised, the install path didn't register. Common causes:

| Symptom | Likely cause | Fix |
|---|---|---|
| `/cb-init` not autocompleting | Slash commands not loaded from `~/.claude/skills/context-bridge/commands/` | Restart Claude Code; if still missing, check the install path resolved correctly |
| Command runs but says "templates not found" | Templates dir isn't at the expected location | Set `CB_TEMPLATES_DIR=<path>` env var pointing at the `templates/` subdir |
| Wrong version installed (older commands appear) | Stale `~/.claude/skills/context-bridge/` from a prior install | Delete the dir and re-run `npx skills add aksheyw/context-bridge` |

## What the install actually contains

Verified contents of `~/.claude/skills/context-bridge/` after a clean `npx skills add`:

- `SKILL.md` — the skill body (frontmatter + protocol summary).
- `commands/` — 5 slash commands.
- `templates/` — 7 templates (4 wiki root files + `decision.md` + `gotcha.md` + `CLAUDE.md.snippet`).
- `references/` — 8 deep references backing SKILL.md.

If any of those four directories are missing post-install, the install is incomplete. Re-run or use the fallback.

## What gets installed where

| Path | Owned by |
|---|---|
| `~/.claude/skills/context-bridge/` | The skill itself (read-only after install) |
| `<project>/.claude/wiki/` | Your project's content (writable; created by `/cb-init`) |
| `<project>/CLAUDE.md` | Your project's project-instructions; `/cb-init` appends a marked section here |
| `<project>/.githooks/pre-commit` | Optional, opt-in via `git config core.hooksPath .githooks` |
| `<project>/.cb-scrub-list` | Optional, gitignored, per-project proper-noun list |

## Uninstall

```bash
rm -rf ~/.claude/skills/context-bridge
```

That removes the skill bundle. Your per-project `.claude/wiki/` and the marked section in `CLAUDE.md` remain — they're not coupled to the skill being installed. You can delete them manually if you want a full uninstall.

## If something here is wrong

Please [open an issue](https://github.com/aksheyw/context-bridge/issues/new). The install path is the most adopter-facing surface; if it's broken or stale, that's a high-priority bug.
