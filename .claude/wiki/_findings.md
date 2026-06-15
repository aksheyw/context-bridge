---
title: Open Findings — Issues to Rectify
updated: 2026-06-15
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

## F7 — CI PII-scan drift (`scripts/verify.sh` self-exclusion not mirrored in workflow) ✅ RESOLVED

**Severity:** 🔴 HIGH (CI had been red on `main` since v0.1.1 ship; visible to anyone reading the GitHub UI)
**Status:** ✅ RESOLVED 2026-05-26 (Session 6) in commit `8f6f9b0`
**Surfaced by:** Session 6 T1-5 setup. While running `gh run list --workflow=pii-scrub-check.yml` to confirm the actual check-run name for branch protection, noticed every push to `main` since `442359d` (v0.1.1) had been failing.

**Root cause:** `scripts/verify.sh` documents the secret + PII pattern lists literally (lines 49 and 84 are the pattern arrays). It excludes itself from its own scans via `:!scripts/verify.sh` in the `git grep` exclusion args. The CI workflow's exclusion lists were NOT updated to match when `verify.sh` landed in v0.1.1, so the CI scan matched on `verify.sh`'s own pattern strings as if they were live PII.

**Why it was invisible locally:** local `verify.sh` excludes itself → returns 8/8 green. The drift was only visible by reading GitHub Actions UI for past runs on main. The v0.1.1 CHANGELOG legitimately claimed CI parity at the moment of merge, but the new file itself broke parity.

**Resolution:** Added `:!scripts/verify.sh` to both the secret-scan and PII-scan `git grep` exclusion lists in `.github/workflows/pii-scrub-check.yml`. CI exclusions now match `verify.sh`'s self-exclusions exactly. Dispatched workflow on feature branch — green.

**Prevention:** Per Session 6 lessons learned (see `v0.1.2-plan.md` closeout): every save+sync should `gh run list --branch main --workflow=... --limit 1` to confirm latest CI on main is green. NOT just local gates.

---

## F8 — PyYAML not pre-installed on `macos-latest` GH Actions runners ✅ RESOLVED

**Severity:** 🟡 MEDIUM (matrix CI portability; surfaced by T1-2, expected risk)
**Status:** ✅ RESOLVED 2026-05-26 (Session 6) in commit `a4f6c21`
**Surfaced by:** Session 6 T1-2 (adding `macos-latest` to CI matrix). On first run, macOS leg failed Gate 7 with `ModuleNotFoundError: No module named 'yaml'`.

**Root cause:** PyYAML is pre-installed on `ubuntu-latest` runners but not on `macos-latest`. Gate 7 (workflow YAML syntax) imports `yaml`.

**Why it was invisible until T1-2:** local `verify.sh` uses `2>/dev/null` around the python3 yaml import (gate_7_hook_yaml_syntax, line ~232), silently skipping the YAML check when PyYAML is missing. Same "silent skips mask parity drift" pattern as F7. ubuntu-latest masked the difference because PyYAML happened to be there.

**Resolution:** Added `actions/setup-python@v5` (`python-version: '3.x'`) followed by `python3 -m pip install --quiet pyyaml` as a setup step before any gates run. Idempotent on ubuntu (already installed); installs on macOS.

**Prevention:** T2 candidate — make `verify.sh` fail loudly when PyYAML / shellcheck / python3 / etc. are missing instead of silently skipping. Tracked in `v0.1.2-plan.md` Session 6 closeout lessons.

---

## Open findings

(No open findings. All 6 original (F1-F6) + 14 deep-review findings + 2 v0.1.2-flight findings (F7, F8) closed.)

**Session 6 update (2026-05-26):** Two CI parity findings (F7, F8) surfaced during v0.1.2 polish and were closed in-flight. Both pattern: local check silently skipped on missing dep; only visible via cross-machine matrix CI. T2 candidate: make local skips loud.

**Session 8 update (2026-06-15):** The Obsidian-vault compatibility build (v0.2, PR [#2](https://github.com/aksheyw/context-bridge/pull/2)) surfaced ~10 deep-review findings — all MEDIUM/LOW, **0 ship-stoppers** — closed in-flight: cb-init guardrail not backfilled on idempotent re-run; a fix that itself wrote during cb-init's read-only pre-flight; README doc-inventory stale (rippled to a pre-existing `success-criteria.md` omission); gate-5 false-positive on plan code-block links; spec `.obsidian/` drift. None remain open.

**Distinction:** a *finding* is something wrong with the shipped product (correctness, security, attribution, drift). An *improvement* is a best-practice gap where the product is correct but could be more trustworthy / discoverable / contributor-friendly. Tier 1-3 are improvements; F7 and F8 are real findings (the product silently broke something it claimed).

---

## Finding lifecycle

- OPEN — needs fix
- IN PROGRESS — being worked on
- RESOLVED — fix shipped + verified
- ACCEPTED — known issue, no fix planned (or deliberately deferred to a later version)

Close findings into `gotchas/gotcha-<name>.md` once they're fixed and the resolution is non-obvious.
