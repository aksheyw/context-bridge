---
title: Open Findings — Issues to Rectify
updated: 2026-05-26
---

# Open Findings

Issues identified during context-bridge design. Each has: severity, status, the phase in which to fix.

---

## F1 — `npx skills add` for community skills UNVERIFIED
**Severity:** 🟡 HIGH (blocks accurate install instructions)
**Status:** OPEN
**Phase to fix:** Before publishing install command publicly
**Detail:** README + spec assume `npx skills add aksheyw/context-bridge` works. Only confirmed for Anthropic-hosted skills. If community-hosted skills aren't supported, fallback curl-based install becomes primary.
**Mitigation:** Verify before announce. If fails, demote primary path in README + update spec §7.3.

---

## F2 — Pin Karpathy LLM Wiki source URLs ✅ RESOLVED
**Severity:** 🟢 LOW (attribution polish)
**Status:** ✅ RESOLVED 2026-05-26 (session 2, mid-evening)
**Resolution:** User shared the canonical gist: https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f (file `llm-wiki.md`). Pinned in CREDITS.md (§1, primary reference), README.md (credits section), and spec (§5.2 + §8 attribution table). Gist verified via WebFetch — content matches the pattern context-bridge derives from.
**Original detail:** CREDITS.md previously linked to Karpathy's X profile generically. Now points to the specific canonical write-up.

---

## F3 — `.githooks/` opt-in mechanism vs. one-line installer
**Severity:** 🟢 MEDIUM (UX friction for adopters)
**Status:** OPEN
**Phase to fix:** During v0.1 skill build
**Detail:** Local pre-commit hook requires `git config core.hooksPath .githooks` from adopter. Alternative: provide a one-line installer script. Trade-off: explicit user action (opt-in) is safer but adds friction.
**Mitigation:** Decision: keep opt-in for safety (matches spec §9.1 design). Document the one-line command clearly.

---

## F4 — Migration UX for existing `llm-wiki` users
**Severity:** 🟢 MEDIUM (affects adopters with prior wiki)
**Status:** OPEN
**Phase to fix:** During `/cb-init` implementation (v0.1)
**Detail:** If a user already has `.claude/wiki/` from `llm-wiki` or their own convention, `/cb-init` needs to detect + offer migration. Question: interactive prompt or doc-only?
**Mitigation:** Spec §10 + §12 already commit to detection; decision is UX format. Default: interactive prompt with 3 options (migrate / adopt as-is / refuse).

---

## F5 — Windows-native path support deferred
**Severity:** 🟢 LOW (v0.2 candidate)
**Status:** ACCEPTED (deferred to v0.2)
**Phase to fix:** v0.2
**Detail:** v0.1 assumes Unix-style paths (`~/.claude/`, forward-slash). Windows-native users (not WSL) will hit issues. `docs/compatibility.md` will document this.
**Mitigation:** Compat doc + badge. Windows path support is a deliberate v0.2 scope.

---

## F6 — Secret-scan pattern coverage gap (proper nouns ≠ secrets)
**Severity:** 🟢 MEDIUM (GitHub secret-scan handles real secrets but not project names)
**Status:** OPEN
**Phase to fix:** During local pre-commit hook implementation (v0.1)
**Detail:** GitHub secret-scanning + push-protection catch API keys / tokens. They do NOT catch arbitrary proper nouns (project names like "MyApp"). Adopters need a separate local scan with a project-specific list.
**Mitigation:** Local `.githooks/pre-commit` script does proper-noun scrub from a project-local list (gitignored).

---

## Finding lifecycle

- OPEN — needs fix
- IN PROGRESS — being worked on
- RESOLVED — fix shipped + verified
- ACCEPTED — known issue, no fix planned (or deliberately deferred to a later version)

Close findings into `gotchas/gotcha-<name>.md` once they're fixed and the resolution is non-obvious.
