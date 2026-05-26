---
title: Open Findings — Issues to Rectify
updated: 2026-05-26
---

# Open Findings

Issues identified during context-bridge design + v0.1 build. Each has: severity, status, the phase in which to fix.

---

## F1 — `npx skills add` for community skills ✅ RESOLVED

**Severity:** 🟡 HIGH (was — closed)
**Status:** ✅ RESOLVED 2026-05-26 (session 4)
**Resolution:** User verified that `npx skills add aksheyw/context-bridge` works for community-hosted skills. Documented in `docs/install-verification.md` as the primary, verified path. Fallback manual-clone path also verified and documented. README install section synced to match.

---

## F2 — Pin Karpathy LLM Wiki source URLs ✅ RESOLVED

**Severity:** 🟢 LOW
**Status:** ✅ RESOLVED 2026-05-26 (session 2, mid-evening)
**Resolution:** Canonical gist pinned: https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f. Pinned across CREDITS.md (§1), README.md, spec (§5.2 + §8), and every skill/references/ + docs/ file that mentions Karpathy. Enforced by CONTRIBUTING.md gate 4.

---

## F3 — `.githooks/` opt-in mechanism ✅ ACCEPTED

**Severity:** 🟢 MEDIUM
**Status:** ✅ ACCEPTED 2026-05-26 (session 4 — design decision held)
**Resolution:** Kept opt-in (`git config core.hooksPath .githooks`). Documented in `docs/getting-started.md` "Optional but recommended" section and `CONTRIBUTING.md`. Trade-off was explicit-user-action-safer vs. installer-friction; chose safer. One-line installer scriptable post-v0.1 if adopter friction proves real.

---

## F4 — Migration UX for existing wikis ✅ RESOLVED

**Severity:** 🟢 MEDIUM
**Status:** ✅ RESOLVED 2026-05-26 (session 4)
**Resolution:** `/cb-init` detects pre-existing `.claude/wiki/` and prompts: migrate / adopt as-is / refuse. Full playbook in `skill/references/migration-from-existing.md` (Branches A / B / C). cb-init terminology disambiguated post-deep-review (F-DR8) — uses "existing-wiki path" for the internal step structure, "migrate / adopt / refuse" for the user-facing choice.

---

## F5 — Windows-native path support deferred

**Severity:** 🟢 LOW
**Status:** ACCEPTED (deferred to v0.2)
**Phase to fix:** v0.2
**Detail:** v0.1 assumes Unix-style paths. Windows-native (non-WSL) is unsupported.
**Mitigation:** `docs/compatibility.md` documents the gap + WSL2 + Git Bash workarounds.

---

## F6 — Secret-scan pattern entropy + proper-noun coverage ✅ RESOLVED

**Severity:** 🟢 MEDIUM
**Status:** ✅ RESOLVED 2026-05-26 (session 4)
**Resolution:** `.githooks/pre-commit` uses entropy-required patterns (e.g. `sk-or-v1-[A-Za-z0-9]{20,}`) — bare prefixes don't trip; documentation that lists prefixes still passes. CI workflow mirrors the same patterns. Per-project proper-noun scanning via `.cb-scrub-list` (gitignored both in adopter repos and in THIS repo's `.gitignore` post-F-DR9). Pattern set + rationale documented in `skill/references/secret-scan-guidance.md`.

---

## Deep-review findings (2026-05-26, Session 4, 16 rounds)

All 14 deep-review findings closed in commit `fe07468`. Captured here for traceability:

| # | Title | Severity | Status |
|---|---|---|---|
| F-DR1 | CHANGELOG missing demo-GIF deferral note | LOW | ✅ RESOLVED |
| F-DR2 | SKILL.md said references shipping v0.1.1 (but they shipped) | HIGH | ✅ RESOLVED |
| F-DR3 | SKILL.md had 6 stale "(v0.1 stub)" annotations | HIGH | ✅ RESOLVED |
| F-DR4 | CONTRIBUTING claimed "all gates enforced in CI" (only 3 of 7) | MEDIUM | ✅ RESOLVED |
| F-DR5 | SESSION_HANDOFF_*.md accumulation cleanup policy missing | LOW | ✅ RESOLVED (FAQ entry) |
| F-DR6 | cb-ingest duplicated decision/gotcha templates inline | MEDIUM | ✅ RESOLVED |
| F-DR7 | compatibility.md claimed "Tested on Ubuntu/Debian/Arch" (false) | MEDIUM | ✅ RESOLVED |
| F-DR8 | "branch" overloaded in cb-init vs. migration-from-existing | LOW | ✅ RESOLVED |
| F-DR9 | `.cb-scrub-list` missing from this repo's .gitignore | MEDIUM | ✅ RESOLVED |
| F-DR10 | README:49 advertised non-existent install.sh fallback | MEDIUM-HIGH | ✅ RESOLVED |
| F-DR11 | README install caveat stale | LOW | ✅ RESOLVED |
| F-DR12 | SKILL.md missing links to 2 of 8 references | HIGH | ✅ RESOLVED |
| F-DR13 | cb-save-sync `[STEP N/10]` off-by-one for 11 steps | LOW | ✅ RESOLVED |
| F-DR14 | findings-register.md placeholder rendered as broken link | LOW | ✅ RESOLVED |

---

## Open findings

(No open findings. All 6 original (F1-F6) + 14 deep-review findings closed.)

---

## Finding lifecycle

- OPEN — needs fix
- IN PROGRESS — being worked on
- RESOLVED — fix shipped + verified
- ACCEPTED — known issue, no fix planned (or deliberately deferred to a later version)

Close findings into `gotchas/gotcha-<name>.md` once they're fixed and the resolution is non-obvious.
