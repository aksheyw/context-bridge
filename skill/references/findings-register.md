# Findings register

> The `_findings.md` lifecycle. Open issues that need tracking but aren't ready for an issue tracker (or that prefer to live with the code, not in Jira).

> **Provenance:** original to context-bridge. See [CREDITS.md](../../CREDITS.md) §3.5.

---

## What goes in `_findings.md`

Issues that:
- ✅ Need tracking across sessions (will outlive the current one).
- ✅ Have a specific phase or condition for fixing.
- ✅ Are real — verified or confidently suspected, not "maybe".

Issues that DON'T:
- ❌ Trivial bugs you can fix in 5 minutes — just fix them.
- ❌ Anything that belongs in the project's real issue tracker (use that).
- ❌ Vague intuitions ("this could be better").
- ❌ Personal preferences.

---

## Entry format

```markdown
## F<id> — <short title>
**Severity:** 🔴 CRITICAL / 🟡 HIGH / 🟢 MEDIUM / 🟢 LOW
**Status:** OPEN / IN PROGRESS / RESOLVED / ACCEPTED
**Phase to fix:** <e.g. before-v0.1-ship, during-cb-init-implementation, v0.2>
**Detail:** <what is wrong, where, what the impact is>
**Mitigation:** <interim mitigation; or, if RESOLVED, the resolution>
```

### Field rules

- **ID** (`F<n>`) is monotonic. Never re-used, never re-numbered. F1 stays F1 forever, even if resolved and removed.
- **Severity** is a fixed enum, with emojis to make scanning trivial. Pick the highest that honestly applies; don't sandbag.
- **Status** is a fixed enum. Transitions are one-directional except RESOLVED → OPEN (re-discovered bugs).
- **Phase to fix** can be a release tag (`v0.2`), an implementation moment (`during-cb-init-implementation`), a condition (`before-public-launch`), or `whenever-time-permits`. Be specific.
- **Detail** is the body. State what's wrong, where, and what the impact is. One paragraph max; if longer, the finding is probably actually two findings.
- **Mitigation** is what to do until the fix lands. If RESOLVED, this becomes the resolution description.

---

## Severity guide

| Severity | When to use | Examples |
|---|---|---|
| 🔴 CRITICAL | Ship-stopper. Security hole, data loss, full feature broken. | Authentication bypass; user data leaked; payments double-charge. |
| 🟡 HIGH | Will block the next milestone if unfixed. User-facing, important workflow broken. | Install command unverified; onboarding broken on Safari. |
| 🟢 MEDIUM | Will bite during normal use; not a blocker. UX friction. | One config flow has poor error message; minor performance issue. |
| 🟢 LOW | Polish, attribution, accessibility, nice-to-have. | Source URL missing from a citation; subtle copy issue. |

If you're unsure between two levels, default to the higher one. Sandbagging severity is a way to hide real risk.

---

## Status lifecycle

```
   ┌──────────┐
   │  OPEN    │ ← default for any new finding
   └────┬─────┘
        │ user starts working on it
        ▼
   ┌──────────┐
   │IN PROGRESS│
   └────┬─────┘
        │ fix shipped + verified
        ▼
   ┌──────────┐         ┌──────────┐
   │ RESOLVED │  OR  →  │ ACCEPTED │ (known issue, won't fix, deferred)
   └────┬─────┘         └──────────┘
        │ regression discovered
        ▼
   ┌──────────┐
   │   OPEN   │ ← re-opened; note the re-open in the Mitigation field
   └──────────┘
```

- **OPEN → IN PROGRESS:** when someone starts working on it.
- **IN PROGRESS → RESOLVED:** when the fix is shipped AND verified.
- **OPEN → ACCEPTED:** when a deliberate decision is made not to fix (deferred to a later version, or a known limitation).
- **RESOLVED → OPEN:** when the bug is re-discovered. Document the re-open in the Mitigation field and consider whether the original fix needs revisiting.

---

## Promotion to `gotchas/`

When a finding is RESOLVED and the resolution was NON-OBVIOUS (i.e. would catch another engineer the next time), promote it to `.claude/wiki/gotchas/gotcha-<slug>.md`.

The finding entry stays in `_findings.md` with status `✅ RESOLVED` and adds a pointer to the gotcha:

```markdown
## F<id> — <title>
**Status:** ✅ RESOLVED <date>
**Resolution:** Fixed in <commit / decision>. Promoted to `gotchas/gotcha-<slug>.md` because the root cause was non-obvious.
```

The gotcha page contains the full "what looked wrong / what was actually wrong / what worked / why non-obvious" detail.

### When NOT to promote
- The fix was a one-liner that any future engineer would also write.
- The cause was a typo / config mistake with no broader lesson.
- The finding was a planning issue (e.g. "decide install command") that resolved into a decision rather than a bug.

Decisions go to `decisions/`, not `gotchas/`. Gotchas are for surprises.

---

## Severity ordering in the file

`_findings.md` lists OPEN + IN PROGRESS items first, severity-descending. RESOLVED + ACCEPTED items live below a `---` divider near the bottom, or are collapsed into a footer count if numerous.

This makes the file readable at a glance — the top is "what's burning", the bottom is "what's behind us".

---

## Lifecycle footer

At the bottom of every `_findings.md`:

```markdown
## Finding lifecycle

- **OPEN** — needs fix
- **IN PROGRESS** — being worked on
- **RESOLVED** — fix shipped + verified
- **ACCEPTED** — known issue, no fix planned (or deliberately deferred)

On resolution with a non-obvious fix, promote the entry to `gotchas/gotcha-<topic>.md` so it stays discoverable.
```

This is included in the template ([`templates/_findings.md`](../templates/_findings.md)) so adopters don't need to remember it.

---

## What `_findings.md` is NOT

- ❌ A replacement for your project's issue tracker. If you use Linear / GitHub Issues / Jira for triage, `_findings.md` is a complement (project-local, in-repo, model-readable), not a replacement.
- ❌ A bug graveyard. Don't dump every minor bug here. The bar is "needs tracking across sessions AND has a specific phase to fix".
- ❌ A planning doc. Decisions go to `decisions/`. Roadmap items go to `_hot.md` or the project's roadmap doc.

The right mental model: `_findings.md` is what you'd hand to the next engineer (or future you) if you had to stop the project today and they had to pick it up tomorrow. The minimum context to not re-discover what you already discovered.
