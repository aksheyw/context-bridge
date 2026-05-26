---
title: Hot — Current Focus
updated: 2026-05-26
session: 3
---

# 🔥 Hot — context-bridge

**Session 3 closed 2026-05-26 (Tue late evening IST, project-decoupling pass).**
**Session 2 closed earlier same day (mid-evening IST, attribution patch — Karpathy gist pinned).**
**Session 1 closed earlier same day (afternoon IST, v0.0 shell + spec push).**

## Current phase

**v0.0 shell pushed.** Public repo live at [github.com/aksheyw/context-bridge](https://github.com/aksheyw/context-bridge). README + LICENSE + CREDITS + spec landed. Skill bundle (skill/, examples/, .github/, docs/*) still to write for v0.1.

## Top tasks for next session

1. **Verify install command.** Determine whether `npx skills add aksheyw/context-bridge` works for community skills. If not, fallback to curl-based install becomes primary.
2. **Write skill/SKILL.md (<200 lines body).** Pull deep content into `references/`.
3. **Write 5 slash commands** (`cb-init`, `cb-status`, `cb-ingest`, `cb-save-sync`, `cb-handoff`).
4. **Write templates** (`_hot`, `_log`, `_findings`, `_schema`, `CLAUDE.md.snippet`, `decision.md`, `gotcha.md`).
5. **Build ExampleApp** with 3 session snapshots.
6. **Set up CI** (`.github/workflows/pii-scrub-check.yml`).
7. **Record demo GIFs** (install + save-sync).
8. **Write `.githooks/pre-commit`** for local PII + secret scan.
9. **Draft LinkedIn launch post** (post after v0.1 ships).

Target ship: v0.1 within ~7 days of spec (spec date: 2026-05-26).

## Open blockers / questions

- [ ] Does `npx skills add` work for community skills, or only Anthropic-hosted? (Phase: before publishing install command)
- [ ] Is opt-in `.githooks/` (via `core.hooksPath`) sufficient or do we need a one-line install script? (Phase: before v0.1 ship)
- [ ] Migration UX for users on existing llm-wiki setups — interactive prompt or doc? (Phase: before v0.1 ship)

## Spec status

Spec v3 written + deep-reviewed + audited (Rounds 1+2+3, 25 findings closed) at [docs/superpowers/specs/2026-05-26-context-bridge-design.md](../../docs/superpowers/specs/2026-05-26-context-bridge-design.md).

User explicitly approved design before push. Spec self-review pass complete.

## Risks

- 🟡 HIGH: install verification might invalidate the install command in README — fix before announce.
- 🟡 MEDIUM: writing 5 commands + templates + ExampleApp in one session is tight; cut to 3 commands + 1 example if time slips.
- 🟢 LOW: demo GIFs might be skipped for v0.1 if recording adds friction; v0.1 can ship without and add in v0.1.1.
