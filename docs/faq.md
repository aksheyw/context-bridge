# FAQ

Quick answers to questions that come up often. Long-form versions live in the linked docs.

---

### Do I need to know Karpathy's LLM Wiki pattern to use this?

No. The skill works without you having read the [original gist](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f). But the gist is short and worth reading — see [`docs/why.md`](why.md) for the synthesis.

---

### Will this slow me down?

A bit, at session-close. Realistically: 5-10 minutes for `/cb-save-sync` on most sessions; up to 20 minutes after a heavy session with many wiki-worthy learnings.

The payback is at next-session-start, where you save 15-30 minutes of re-loading context. Net: positive if you have ≥1 session per week on the project.

If you're under 1 session/week, you're probably not the target user — see [`docs/when-not-to-use.md`](when-not-to-use.md).

---

### Does the wiki get checked in to git?

Yes, by default. The wiki lives at `.claude/wiki/` in your project; standard git tracks it.

If you want some pages private:
- Name them `*-private.md` and add `*-private.md` to `.gitignore`.
- Or put the whole `.claude/wiki/` in `.gitignore` if you want a personal-only wiki.

Trade-off: gitignoring the wiki means losing it if you `rm -rf` the project or swap machines without backup.

---

### Can multiple people collaborate on the wiki?

Not gracefully in v0.1. The wiki is designed for a single author. Two people editing `_hot.md` on the same day will produce merge conflicts.

If you need team docs, use Confluence / Notion / a dedicated ADR repo. See [`docs/vs-other-skills.md`](vs-other-skills.md).

---

### Does it work without Claude Code?

The methodology, yes — the wiki shape and protocol are tool-agnostic.

The slash commands, no — v0.1 is Claude-Code-specific. v0.2 plans cross-tool installers.

See [`docs/adapting-to-other-tools.md`](adapting-to-other-tools.md).

---

### What if I already have a `.claude/wiki/` from another setup?

`/cb-init` detects it and asks: **migrate**, **adopt as-is**, or **refuse**. Nothing is touched until you choose.

- **Migrate** — add `_hot.md` + `_findings.md`, preserve everything else.
- **Adopt as-is** — record the current shape in `_schema.md`; no new files.
- **Refuse** — clean abort, no changes.

---

### Is the pre-commit hook required?

No — it's opt-in. Enable it with `git config core.hooksPath .githooks` after copying the hook into your project.

But: the wiki accumulates over weeks. The hook is your line of defense against accidentally pasting a secret or a private project name into a wiki page that later gets pushed. Most adopters should enable it.

---

### Why bash and markdown? Why not a real language?

Two reasons:

1. **Zero new runtime dependencies.** Adopters don't install Python, Node services, or daemons. `git` and `bash` are everywhere; markdown is universal.
2. **Diff-friendly.** Plain markdown reviews well in PRs. `git diff` shows exactly what changed in the wiki.

Trade-off: bash limits the hook's sophistication. v0.2 may add an optional Python or Go variant for richer scanning. The bash version stays as the canonical, dependency-free path.

---

### Why MIT and not Apache 2.0?

MIT for simplicity. The skill is small; the legal surface should be small too. If you have a strong case for Apache 2.0 (e.g. patent-grant requirements at your org), open an issue — the maintainer is open to discussion.

---

### Will you ever add embeddings / vector search?

Probably not, intentionally. The wiki is small by design. If you have so many pages that you can't `grep` them, the wiki has grown beyond its purpose — split the project or archive older sessions.

A simple `/cb-find <term>` (literal grep) is on the v0.2 roadmap. Anything heavier is out of scope.

---

### Why is the SKILL.md body limited to 200 lines?

Because the skill that solves context bloat cannot itself be a context-bloat case. Deep content moves into `references/` and gets loaded on-demand by the Skill tool.

CI enforces this — see [`.github/workflows/pii-scrub-check.yml`](../.github/workflows/pii-scrub-check.yml).

---

### How is this different from `save-session`?

[`docs/vs-other-skills.md`](vs-other-skills.md) has the full table. Short version: `save-session` is a snapshot; context-bridge is a compounding wiki + a protocol.

---

### What happens if I uninstall?

```bash
rm -rf ~/.claude/skills/context-bridge
```

That removes the skill bundle. Your per-project `.claude/wiki/` and the `CLAUDE.md` marked section remain — they're plain files, not coupled to the skill being installed.

If you want a full uninstall:
```bash
cd <your-project>
rm -rf .claude/wiki
# Manually remove the block between <!-- context-bridge:begin --> and <!-- context-bridge:end --> in CLAUDE.md
```

---

### What's "save and sync" mean — like `git push`?

Different. "Save and sync" is the verbal trigger for `/cb-save-sync`. It runs the 11-step protocol: local commit, wiki updates, docs push (default: `.md` files only), generate handoff prompt. **It does not push code to `main`.**

Pushing code to `main` is a separate step (often via a `/ship` command or `git push` to main directly after PR merge). The author's personal convention treats "save and sync" as ALWAYS safe; "ship" as gated.

---

### What's the difference between `_findings.md` and `gotchas/`?

- **`_findings.md`** = OPEN issues — things still wrong, severity-ordered, lifecycle states.
- **`gotchas/`** = RESOLVED issues with non-obvious fixes — promoted from `_findings.md` for future-discoverability.

A finding becomes a gotcha when the fix is interesting enough that a future session would want to know about it. Trivial fixes don't get promoted.

---

### How often should `_hot.md` get updated?

Every session-close. That's what `/cb-save-sync` step 7 does.

If you're not closing a session, you don't need to update it. Mid-session use `/cb-ingest` for one-off learnings.

---

### Why "context-bridge" as a name?

Each session is a context window. The skill is a bridge between consecutive context windows — what you carry from one to the next. Self-explanatory once you've used it; a little opaque before.

---

### How do I contribute / report bugs / request features?

See [`CONTRIBUTING.md`](../CONTRIBUTING.md). TL;DR: small focused PRs welcome; cosmetic-only changes discouraged; security bugs go via private [Security Advisories](https://github.com/aksheyw/context-bridge/security/advisories/new).

---

### My question isn't here.

[Open an issue](https://github.com/aksheyw/context-bridge/issues/new) with the `question` label, or check the existing issues — your question may already have an answer.
