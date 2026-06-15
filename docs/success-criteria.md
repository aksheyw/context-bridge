# Success criteria — v0.1

This doc states the explicit targets for evaluating whether v0.1 worked. Without this, "did v0.1 succeed?" is a vibes question and the project drifts.

Written at v0.1.1 ship (the polish pass on v0.1.0). Evaluated at the dates listed.

---

## Honest stance

context-bridge is a side project, not a startup. Success isn't market share or revenue. Success is **does the methodology hold up when a stranger tries it**, and **does the author keep using it for their own work**. Those two questions get most of the way to "is this worth maintaining".

The metrics below are tripwires, not OKRs. If they're missed, that's a signal to investigate the friction, not to optimize the metric.

---

## Targets — first 30 days after v0.1.0 ship

Date of ship: 2026-05-26. Evaluation date: **2026-06-25**.

### Adoption (loose tripwires)

| Metric | Floor | Ceiling | Action if missed |
|---|---|---|---|
| Repo stars | ≥ 5 | (no ceiling) | If <5: README + LinkedIn post failed to communicate; rewrite the hook |
| `npx skills add` install attempts | ≥ 10 | (no ceiling) | Hard to measure — proxy via repo clones / LinkedIn DMs |
| Issues opened (any kind) | ≥ 1 | (no ceiling) | If 0: nobody actually tried it; investigate why |
| Direct adopter feedback (DM / email) | ≥ 1 | (no ceiling) | If 0: same as above |

### Quality (hard gates)

| Metric | Target | Action if missed |
|---|---|---|
| CI failures on `main` after v0.1.0 | 0 | Fix immediately; this is a correctness regression |
| Reported broken-install paths | 0 | Hotfix to v0.1.x; install path is the most adopter-facing surface |
| Reported false-positive secret-scan blocks | < 3 | Tune patterns in v0.1.x |
| Security advisories filed | 0 (target) | If any: triage within 7 days per SECURITY.md |

### Author dogfood (the most honest signal)

| Metric | Target | Action if missed |
|---|---|---|
| Author uses `/cb-save-sync` on this repo's own dev wiki | every session | If skipping: the protocol is too heavy; cut steps |
| Author uses `/cb-status` at session start on ≥2 other projects | yes | If no: the warm-resume value-proposition isn't real |
| Number of `gotchas/` promoted on author's own projects in 30 days | ≥ 2 | If 0: nothing non-obvious is being captured; finding-lifecycle is theater |

---

## Decision points

### At day 14 (2026-06-09)

- **If stars < 2 and 0 issues** → the launch post didn't land. Drop a second LinkedIn post or technical write-up showing the worked example. Don't ship v0.1.2 yet.
- **If 1+ broken-install report** → ship v0.1.1.x hotfix that week.
- **If author dogfood is intact** → keep building toward v0.2 features (cross-tool installers, monorepo support) regardless of external metrics. The methodology works for the author; the rest is distribution.

### At day 30 (2026-06-25)

Two real-world decision branches:

**Branch A — adoption signal present (stars ≥ 5, issues ≥ 1):**
- Ship v0.2 scope as planned: monorepo support + cross-tool installer adapters + `/cb-find` + Windows-native paths.
- Cut a v0.1.x patch release if any open issues remain.

**Branch B — adoption signal absent (stars < 5, 0 substantive issues):**
- Don't ship v0.2 features into a tool nobody's using. Instead:
  1. Investigate WHY. Pick 3 people, ask them to install and report friction.
  2. Rewrite the README hook based on what those 3 say.
  3. Re-evaluate at day 60.
- Author dogfood continues regardless. v0.1 is fine for personal use even if external adoption stalls.

**Branch C — quality problem (broken installs / security report / CI red):**
- Stop all new work. Fix the quality issue. Ship v0.1.x patch.
- Quality regressions on a tiny v0.1 erode trust faster than slow adoption ever will.

---

## Day-14 signal check — 2026-06-09 (logged 2026-06-15, 6 days late)

Snapshot at logging time:

| Signal | Target | Actual |
|---|---|---|
| Stars | ≥ 2 | 0 |
| Issues | ≥ 1 | 0 |
| Broken-install reports | 0 | 0 ✓ |
| CI on `main` | green | green ✓ |
| Author dogfood | intact | intact ✓ (Sessions 7–8 ran `/cb-save-sync` on this repo's own wiki) |

**Reading:** the "stars < 2 and 0 issues" rule would say "the launch post didn't land." But the launch post was **never published** — Path A queued it at Session 6, and Sessions 7 (wiki-lint) and 8 (Obsidian compat) did build work instead. So 0 external signal reflects *0 announcement*, not a failed hook. The day-14 rules (written at v0.1.1) also predate v0.1.2 shipping; treat them as a lightweight tripwire, not the formal retro.

**Decision:** No hotfix — Branch C not triggered (0 broken-install reports, CI green). Author dogfood intact → continue v0.2 per the dogfood rule (Obsidian compat shipped to PR #2). Launch announcement deferred; the custom social-preview image (T2-5) was prepared this session (`docs/assets/og-image.png`) so the repo previews well whenever it is shared. Formal evaluation remains Day-30 (2026-06-25).

---

## What this doc is NOT

- ❌ A growth plan. context-bridge is a methodology, not a product.
- ❌ A KPI dashboard. The numbers above are signals, not goals.
- ❌ A commitment to ship v0.2 on a specific date. v0.2 happens if v0.1 is being used.
- ❌ A reason to game metrics. If you find yourself tweeting "context-bridge has X stars" to hit a floor, you've already failed the honesty rule.

---

## Author dogfood checklist (running)

Updated as the author uses context-bridge on this and other projects:

- [x] 2026-05-26 — dogfooded context-bridge on its own dev wiki (this repo's `.claude/wiki/`)
- [ ] First non-context-bridge project adoption
- [ ] First `/cb-handoff` consumed by a different machine (verify install portability)
- [ ] First gotcha promoted from `_findings.md` on a non-toy project

---

## Retrospective entry point

At 2026-06-25, this file gets a new section:

```markdown
## v0.1 retrospective — 2026-06-25

**Floor metrics:** <which hit, which missed>
**Quality gates:** <pass / fail>
**Author dogfood:** <intact / broken — and why>
**Decision branch chosen:** A / B / C
**Top three learnings:**
1. ...
2. ...
3. ...
**Adjustments to v0.2 scope:** <list>
```

Without that explicit retrospective, the next 6 months drift on intuition. With it, decisions are auditable.
