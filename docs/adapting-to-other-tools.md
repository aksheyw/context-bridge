# Adapting the methodology to other tools

context-bridge v0.1 ships as a Claude-Code-native skill. The slash commands (`/cb-init` etc.) only fire inside Claude Code. The **methodology** — the wiki shape, the 11-step save+sync protocol, the handoff prompt template — is tool-agnostic.

This page is for users whose primary loop is Cursor / Aider / Codex / Continue / Copilot CLI / Gemini CLI / something else, and who want the cross-session-amnesia fix without waiting for v0.2.

## What you can use today, in any tool

| Artifact | Tool-agnostic? | How to use it |
|---|---|---|
| The wiki shape (`_hot.md` / `_log.md` / `_findings.md` / `_schema.md` / `decisions/` / `gotchas/`) | ✅ Pure markdown | Create `.claude/wiki/` manually; copy templates from this repo's [`skill/templates/`](../skill/templates/). |
| The 11-step save+sync protocol | ✅ Procedural | See [`skill/references/save-sync-protocol.md`](../skill/references/save-sync-protocol.md). Run it manually at session close — or wire it into your tool of choice. |
| The handoff prompt template | ✅ Markdown prompt | See [`skill/references/handoff-template.md`](../skill/references/handoff-template.md). Paste into any model's input. |
| The honesty rules in CLAUDE.md | ✅ Markdown contract | Copy [`skill/templates/CLAUDE.md.snippet`](../skill/templates/CLAUDE.md.snippet) into whatever instructions file your tool reads (`.cursor/rules`, `.aider.conf.yml` instructions, etc.). |
| Secret-scan + proper-noun pre-commit hook | ✅ Pure bash | [`/.githooks/pre-commit`](../.githooks/pre-commit) runs anywhere `git` does. |

## What's tool-specific

- The `/cb-*` slash commands. These live in `skill/commands/` as markdown prompts that Claude Code's Skill tool executes. Other tools have their own command surfaces.
- The Skill tool integration itself.
- The CLAUDE.md marker convention (`<!-- context-bridge:begin -->`) — works in any tool that reads `CLAUDE.md`, but other tools may use different instruction-file names (`.cursor/rules/`, `AGENTS.md`, `GEMINI.md`, etc.).

## Per-tool sketches

These are sketches, not verified ports. v0.1 doesn't ship installers for them. If you build one and it works, please contribute back — see [`CONTRIBUTING.md`](../CONTRIBUTING.md).

### Cursor

- Wiki structure: identical. `.claude/wiki/` works fine inside a Cursor project (Cursor doesn't read it, but `git` does and you do).
- Honesty snippet: paste the contents of `CLAUDE.md.snippet` into `.cursor/rules/honesty.mdc` (Cursor reads `.cursor/rules/*.mdc`).
- Save+sync: invoke manually. Ask Cursor "run the 11-step save+sync protocol from `~/.../skill/references/save-sync-protocol.md`" and walk it through.
- Handoff: the prompt template works as-is.

### Aider

- Wiki structure: identical.
- Honesty snippet: add to `.aider.conf.yml`'s `read:` list, or paste into the project's `CONVENTIONS.md` which Aider reads on each run.
- Save+sync: Aider doesn't have slash commands in the same shape; run the protocol as a `/run` shell step + manual wiki edits.
- Handoff: the template works as-is.

### Codex CLI / OpenAI Codex

- Wiki structure: identical. Codex reads `AGENTS.md`; treat it as your instruction file.
- Honesty snippet: append the snippet content to `AGENTS.md` (the marker delimiters are safe to keep).
- Save+sync: invoke the protocol manually each session.
- Handoff: template works.

### Gemini CLI

- Wiki structure: identical.
- Honesty snippet: append to `GEMINI.md` (Gemini CLI's equivalent of `CLAUDE.md`).
- Save+sync + handoff: as above.
- Note: Gemini CLI's skills system uses `activate_skill` instead of Claude's `Skill` tool — if you port the slash commands, you'll need to map them. See the [Superpowers](https://github.com/obra/superpowers) repo's `references/codex-tools.md` and similar for inspiration.

### Copilot CLI

- Wiki structure: identical.
- Honesty snippet: Copilot CLI uses `AGENTS.md` similarly to Codex.
- Save+sync + handoff: manual invocation.

### Plain terminal / no AI tool at all

The wiki shape is still useful as a *human* methodology. Drop the AI-specific honesty rules; keep the file layout. `_hot.md` and `_findings.md` are valuable even without a model reading them — they answer "where am I" in your own head when you sit down on Monday.

## When v0.2 will fix this

v0.2 (planned, next month after v0.1 ships) targets cross-tool installer adapters: a way to run something like `cb-install --tool cursor` and get the right files in the right places for that tool. The methodology won't change; only the installation surface.

If you're considering building this for v0.2 — open an issue first, the design needs to support all the tools above without forking the canonical templates.

## What you LOSE by porting manually

Be honest with yourself before you port:

- **The pre-flight collision scan in `/cb-init`** — easy to forget when running manually; you'll accidentally overwrite something.
- **The user-gated wiki edits in `/cb-save-sync`** — without the gate, you'll either skip the discipline or auto-commit junk.
- **The marker-anchored idempotency in `CLAUDE.md`** — manual append can duplicate the block on a re-run.

These are exactly the things the slash commands enforce. Manual ports are MORE error-prone, not less. Use the methodology as a *checklist* you walk through, not a script you execute mentally.

## Want full skill support?

Two paths:

1. Wait for v0.2.
2. Contribute the installer for your tool of choice — see [`CONTRIBUTING.md`](../CONTRIBUTING.md). The bar is "an adopter using only your tool can run one install command and have the protocol working".
