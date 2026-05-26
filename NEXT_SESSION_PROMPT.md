# context-bridge — Next Session Prompt

Paste this into a new Claude Code session. Working directory: `/Users/aksheywa/Documents/Claude Code/context-bridge/`.

---

```
I'm continuing work on context-bridge v0.1. The OSS v0.0 shell is live at github.com/aksheyw/context-bridge with README + LICENSE + CREDITS + design spec + dev wiki. The skill bundle (skill/, examples/, .github/, docs/*) still needs to be written.

Read these in order, fast:
1. /Users/aksheywa/Documents/Claude Code/context-bridge/SESSION_HANDOFF_2026-05-26.md (FULL handoff — primary)
2. /Users/aksheywa/Documents/Claude Code/context-bridge/.claude/wiki/_hot.md (current focus + next tasks)
3. /Users/aksheywa/Documents/Claude Code/context-bridge/.claude/wiki/_findings.md (6 open issues, severity-ordered)
4. /Users/aksheywa/Documents/Claude Code/context-bridge/docs/superpowers/specs/2026-05-26-context-bridge-design.md (full spec, 25 findings closed)
5. /Users/aksheywa/Documents/Claude Code/context-bridge/CREDITS.md (attribution baseline — DO NOT ship anything that breaks this)

Then summarize back to me in 5 bullets:
- What context-bridge is + who it's for + who it's NOT for (be honest about non-goals)
- v0.1 ship checklist (what's left from the SESSION_HANDOFF pending list)
- Top 3 risks for v0.1 (incl. F1 install-command verification)
- Today's first task — a 60-min plan for one concrete deliverable (recommend smallest demoable slice: SKILL.md + cb-init only)
- The handoff prompt that a context-bridge user pastes into their next session (the killer demo)

After your summary, ask me:
1. Did F1 install-command verification check out, or are we falling back to curl install?
2. Should I start with SKILL.md + 1 command (cb-init) as smallest demoable slice, or write all 5 commands first?
3. Co-pilot mode: A (standby) / B (active co-pilot) / C (code reviewer) / D (build the bundle for me)?

Skills I'll need:
- superpowers:using-superpowers (auto)
- superpowers:test-driven-development (skill body + commands; write tests first where applicable)
- deep-review (re-review v0.1 bundle before ship)
- audit (ripple search on v0.1 templates + commands)
- code-reviewer / security-reviewer (for pre-commit hook logic)

Honesty rules: 95% confidence gate. Never fabricate paths or commands. Use Read/Grep/Glob to verify. When unsure, say so.

Build velocity rules:
- SKILL.md body MUST stay <200 lines (per spec §4.2; this is the skill that solves context bloat — it cannot itself bloat).
- All templates MUST be scrubbed (only ExampleApp / ExampleService / ExampleUser; never real project names).
- Attribution MUST stay rigorous — every doc that references the LLM Wiki concept must link the Karpathy gist (https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f) and credit Jesse Vincent for Superpowers ecosystem patterns.

Hard rule: any commit to this public repo passes:
- Repo-wide PII scrub (zero real-project names or IDs)
- Repo-wide secret scan (zero API keys / tokens / JWTs)
- Spec self-review pass

v0.1 target ship: within ~7 days of spec (spec date 2026-05-26). LinkedIn launch post comes AFTER v0.1 ships.
```

---

## Why this prompt format

- **5-bullet summary** forces the new Claude to actually load context before acting
- **Numbered questions** surface the blocking pieces (F1 install verification + scope decision)
- **Skills list** pre-warms the model to know which skills to invoke
- **Honesty + velocity + hard rules** embed the project's guardrails (size budget, scrub, attribution)

## If session dies mid-build

Each work session, before close:
1. Append to `.claude/wiki/_log.md`
2. Update `.claude/wiki/_hot.md`
3. Promote findings to `.claude/wiki/_findings.md` with severity + phase
4. Update `SESSION_HANDOFF_YYYY-MM-DD.md` for the day
5. Run `~/.claude/projects/-Users-aksheywa-Documents-Claude-Code-context-bridge/memory/` updates if learnings surfaced
6. git commit + push (`.md` files only by default)
7. Update this file with the latest prompt + handoff path

This is the dogfooding loop. Every session should be ingestible from cold-start by reading 3-4 markdown files.
