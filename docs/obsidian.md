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
