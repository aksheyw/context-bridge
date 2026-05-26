# ExampleApp — context-bridge worked example

`ExampleApp` is a fictional todo product used to demonstrate how a `.claude/wiki/` evolves across three real-shaped sessions. **No real project names, no real services, no real personal data.**

The premise: a solo developer building a personal CLI todo tool. Three sessions over a long weekend (Sat → Mon → Tue, 2026-05-23 → 2026-05-26):

| Session | Date | Focus | What landed in the wiki |
|---|---|---|---|
| 1 | 2026-05-23 (Sat) | Scope + storage decision | `decisions/d-2026-05-23-storage-sqlite-vs-json.md` |
| 2 | 2026-05-25 (Mon) | Add-task feature; timestamp bug | `_findings.md` F1 (timezone display), then RESOLVED in same session; handoff generated |
| 3 | 2026-05-26 (Tue) | Warm resume; delete-task feature | F1 promoted to `gotchas/gotcha-timezones-display.md` |

## Reading order

1. **`README.md`** (this file) — the meta-explanation.
2. **`CLAUDE.md`** — the marked context-bridge section + ExampleApp's own conventions.
3. **`.claude/wiki/`** — the **final state** of the wiki (i.e. after session 3 closed).
4. **`SESSION_HANDOFF_2026-05-25.md`** — the handoff produced at the end of session 2, used as the warm-resume entry for session 3.
5. **`snapshots/`** — the wiki state captured at each session-close. Diff between snapshots to see the protocol's compound effect.

## What you can demo from this

- **`/cb-init` greenfield setup** — Look at `snapshots/session-1/.claude/wiki/` to see exactly what `/cb-init` scaffolds.
- **A real decision capture** — `decisions/d-2026-05-23-storage-sqlite-vs-json.md` shows the format with rejected alternatives and consequences.
- **A finding lifecycle: OPEN → RESOLVED → promoted to gotcha** — Watch F1 in `snapshots/session-2/.claude/wiki/_findings.md` (OPEN→RESOLVED in the same session), then `gotchas/gotcha-timezones-display.md` in session-3.
- **A warm resume from a handoff** — `SESSION_HANDOFF_2026-05-25.md` is the prompt session 3 starts with.

## Diff a snapshot to see what changed

```bash
diff -ru examples/ExampleApp/snapshots/session-1/.claude/wiki \
         examples/ExampleApp/snapshots/session-2/.claude/wiki

diff -ru examples/ExampleApp/snapshots/session-2/.claude/wiki \
         examples/ExampleApp/snapshots/session-3/.claude/wiki
```

Each diff is the **exact** delta that `/cb-save-sync` step 7 would produce at session close.

## Why ExampleApp and not a real project?

Every concrete project has names, IDs, paths, and stack choices that would either (a) confuse adopters who don't share that context, or (b) leak private project details. ExampleApp is the smallest fictional project that still exercises every wiki file type and the full lifecycle.

If you'd like to see a real production wiki in action, check the dev wiki of context-bridge itself: [`.claude/wiki/`](../../.claude/wiki/) at the repo root. context-bridge dogfoods its own convention.
