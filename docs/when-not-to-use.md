# When NOT to use context-bridge

Honest exit ramps. If your situation looks like one of these, this skill is overkill or wrong-fit. Skipping it is the right call.

---

## Single-session work (<1 day total)

A weekend script, a quick PoC, a one-off data munge — the wiki adds overhead with nothing to compound on. By the time you'd save+sync, you'd be done.

**Heuristic:** if you expect to close the project before next Monday, skip.

---

## Throwaway prototypes you'll delete

You're exploring an idea. You'll know in 2-3 sessions whether it has legs. Until then, `git commit -m "wip"` and your conversation history are enough.

**Heuristic:** if you'd be unsurprised to `rm -rf` the project tomorrow, skip.

---

## Hot-fix or incident-response work

When prod is down, you don't want a save+sync gate between you and a deploy. Use whatever speeds you up, including no docs at all. Capture lessons AFTER, in the post-mortem.

**Heuristic:** if "save and sync" feels like friction during the work, skip the protocol; do a single post-incident `/cb-ingest` once you're back from the brink.

---

## You're not the primary maintainer

If the project's primary maintainer is someone else (e.g. you're a contributor doing a PR), don't impose a wiki convention on their repo. Either:

1. Use a personal-notes file you don't commit (`.claude/wiki/_hot.md` is fine if their `.gitignore` excludes `.claude/`), or
2. Ask them whether they want context-bridge — if yes, then `/cb-init` together.

---

## The team already uses a different convention

If your team has ADRs in `docs/adr/`, decisions in Confluence, and a strong shared norm — adding `.claude/wiki/` creates a second source of truth. That's worse than no wiki.

**Two compromises that work:**
- Use context-bridge for YOUR personal session state (`_hot.md` only, gitignored), keep the team's existing ADR/Confluence flow for shared knowledge.
- Don't use context-bridge; lean on the existing system.

---

## You don't use Claude Code primarily

If you use Cursor / Aider / Codex / Copilot as your main loop, context-bridge in v0.1 is awkward. The slash commands don't exist there. The wiki structure still helps (the methodology is tool-agnostic), but you'd be running the save+sync protocol manually.

See [`docs/adapting-to-other-tools.md`](adapting-to-other-tools.md). If you want full skill support, wait for v0.2.

---

## You're not the kind of person who writes things down

Be honest with yourself. The wiki only pays off if you actually invest 5 minutes at session-close to refresh `_hot.md`. If past evidence says you'll skip that step within a week, the wiki will rot and mislead.

**Heuristic:** if you don't already keep some form of project journal (TODO list, weeknotes, anything), the skill won't change that. Try keeping a 5-line `_hot.md` manually for a week first; if it sticks, adopt the full skill.

---

## You're solving the wrong problem

context-bridge addresses *cross-session amnesia*. If your actual pain is one of these, a different tool is right:

| Real pain | Right tool |
|---|---|
| Mid-session context bloat → hallucinations | `/strategic-compact`, `/aside`, native compaction |
| "I can't find that thing I wrote 3 months ago" | Obsidian / Logseq / IDE search |
| "I keep re-reading the same code to understand it" | Code-aware retrieval (Cursor, Aider, IDE) |
| "I can't track tasks across projects" | A proper task tracker (Linear, Things, Todoist) |
| "My team doesn't know what I'm doing" | Standups, Slack, async written updates |

See [`docs/what-this-is-not.md`](what-this-is-not.md) for the full non-goal list.

---

## Final heuristic

If you finish reading this page and still aren't sure — try the skill for **one project, one week**. After a week:

- If `_hot.md` feels useful when you sit down each session → keep going.
- If you keep forgetting to update it, or its content is stale within 3 days → uninstall. The methodology isn't fitting your working style. No shame.

```bash
rm -rf ~/.claude/skills/context-bridge
# Optionally also: rm -rf <project>/.claude/wiki and remove the CLAUDE.md marked block
```

The skill is small on purpose. It's also easy on purpose to walk away from.
