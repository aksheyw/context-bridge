# Contributing to context-bridge

Thanks for considering a contribution. context-bridge is small on purpose — fewer parts to maintain, fewer ways to drift. Most contributions land best as small, focused PRs.

If something here doesn't match how the repo behaves, that's a bug — please open an issue.

---

## Quick start

1. Fork the repo + clone your fork.
2. Create a feature branch: `git checkout -b feature/<short-name>`.
3. (Recommended) Enable the local pre-commit hook: `git config core.hooksPath .githooks`.
4. Make your change. Keep diffs focused.
5. Run the gates locally (see below).
6. Open a PR. The PR template's checklist enumerates the gates we expect.

---

## Gates — what every PR must pass

All 8 gates are enforced by CI ([`.github/workflows/pii-scrub-check.yml`](.github/workflows/pii-scrub-check.yml)) — a PR that fails them will block.

Run them locally before opening a PR with one command:

```bash
scripts/verify.sh
```

That runs all 8 gates (plus a bonus SKILL.md integrity check) and prints a summary. Exit code 0 means CI will also pass; exit 1 lists the failures with file/line context.

### 1. No real secrets

Strict, entropy-required scan. The local pre-commit hook handles this; CI mirrors it. If a real key appears in any committed file — even in a comment, even in a test fixture — rotate it AND scrub it BEFORE pushing.

See [`skill/references/secret-scan-guidance.md`](skill/references/secret-scan-guidance.md) for the pattern set and rationale.

### 2. No private proper nouns

The OSS repo must not reference private projects, internal URLs, or personal data. The PII scan in CI covers a baseline list; add to `.cb-scrub-list` locally (it's gitignored) for your own patterns.

### 3. `skill/SKILL.md` ≤ 200 lines

The skill body is intentionally lean. If your change pushes it over 200 lines, move deep content into `skill/references/<topic>.md` and link from SKILL.md.

```bash
wc -l skill/SKILL.md   # must be ≤ 200
```

### 4. Karpathy gist linked, not just named

If a `skill/references/*.md` file mentions Karpathy, it must link the canonical [LLM Wiki gist](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f). Generic mentions without the link are attribution drift.

### 5. All cross-links in SKILL.md resolve

Every `[text](path)` in SKILL.md must point at a real file. Broken links are a CI failure.

### 6. Frontmatter on SKILL.md + every command

YAML frontmatter at the top of SKILL.md and every `skill/commands/*.md`. Required keys: `name:` (SKILL.md only), `description:`.

### 7. Hook + workflow syntax

```bash
bash -n .githooks/pre-commit
python3 -c "import yaml; yaml.safe_load(open('.github/workflows/pii-scrub-check.yml'))"
```

### 8. Wiki lint (example fixture)

The shipped `examples/ExampleApp/.claude/wiki/` must stay valid against the conventions in [`skill/references/wiki-structure.md`](skill/references/wiki-structure.md): required frontmatter (`title:` + ISO `updated:`), no broken `[[wiki-links]]`, monotonic finding IDs.

```bash
python3 scripts/wiki-lint.py examples/ExampleApp/.claude/wiki --no-stale
```

Flag-only — it reports, never edits. CI runs it with `--no-stale` (the frozen fixture's dates age past 30 days by design). shellcheck is a CI-only gate (gate 9) — most macOS dev machines lack it.

---

## What kinds of contributions are welcome

### Always welcome
- **Bug fixes** in the commands, hook, or templates.
- **Doc improvements** — clearer wording, missing edge cases, broken-link fixes.
- **Real adopter feedback** — issues describing what didn't work for you on a real project.
- **Attribution corrections** — if your work is referenced and not credited (or credited wrong), open an `attribution` issue.

### Welcome with caution
- **New slash commands.** The 5 commands are intentionally a complete set; new ones need a strong "this couldn't be a variant of an existing command" argument.
- **New wiki page types.** Same bar as commands. The 7 file types cover almost every multi-session-project need.
- **New optional frontmatter fields.** Add to `skill/references/wiki-structure.md` AND to the relevant template; explain why in the PR.

### Out of scope (please don't PR)
- **Multi-user / team-shared features.** Single-developer is a deliberate v0.1 + v0.2 scope decision.
- **Cross-tool installers** (Cursor / Aider / Codex). The methodology is documented in `docs/adapting-to-other-tools.md`; v0.2+ work, not v0.1.
- **Code-aware retrieval / embeddings / MCP servers.** All out of scope per SKILL.md "What this skill does NOT do".
- **Cosmetic-only changes** (emoji additions, formatting churn) without a functional improvement.

---

## Style notes

### Markdown
- Prefer pipe tables for ≥3 columns; bulleted lists for 1-2.
- Code blocks: triple-backtick with a language tag when applicable.
- Sentence-case headings (`## Quick start`, not `## Quick Start`).

### Slash commands
- Frontmatter `description:` is one sentence, present-tense, ≤120 chars.
- Body: step-numbered, with one-line gate-style "Step N — verb noun" headers.
- Always print what each step does BEFORE the side effect.
- Always include an "Honesty + safety" section at the bottom.

### Templates
- Use ONLY placeholder names: `<project-name>`, `<topic>`, `<slug>`, `ExampleApp`, `ExampleService`, `ExampleUser`. Never real project names — CI will reject.
- Include a `<!-- context-bridge convention -->` comment block explaining how the template is used.

### Commit messages
- Conventional commit format: `<type>: <short description>`.
- Types: `feat`, `fix`, `refactor`, `docs`, `test`, `chore`, `perf`, `ci`.
- Body: explain WHY, not WHAT. The diff already shows WHAT.
- Cite spec sections or finding IDs when relevant (e.g. "Refs spec §4.2", "Closes F6").

---

## Attribution rigor

This is a project value, not just a checkbox. If your contribution draws on someone else's work — a blog post, a paper, another OSS project — credit them in `CREDITS.md` and in the relevant file's header.

If you see a pattern in context-bridge that should credit you or someone else and doesn't, please open an `attribution` issue. The goal is full provenance.

---

## How decisions get made

context-bridge is currently maintained by [@aksheyw](https://github.com/aksheyw). For non-trivial design changes:

1. Open an issue with the proposed change first.
2. Discuss scope, attribution, compatibility, and which version (v0.1.x / v0.2 / later) it targets.
3. Once aligned, open a PR referencing the issue.

For trivial bug fixes and doc improvements, a PR is fine without prior discussion.

---

## License

By contributing, you agree that your contributions will be licensed under the [MIT License](LICENSE), the same license as the rest of the project.

---

## Questions?

Open an issue tagged `question`. The maintainer will respond when possible; this is a side project so response times vary.
