# Changelog

All notable changes to context-bridge are documented here. The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and the project follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

(Nothing pending — see [open issues](https://github.com/aksheyw/context-bridge/issues) for proposals.)

---

## [0.1.2] — 2026-05-26

Polish pass on v0.1.1. No skill behavior changes. Adds OSS hygiene infrastructure + closes two CI parity findings (F7, F8) that surfaced during the polish.

### Added

- **`.github/CODEOWNERS`** — documents review responsibility (`* @aksheyw`). (T1-7)
- **`.github/FUNDING.yml`** — enables the GitHub Sponsor button on the repo. Upstream sponsor links for Jesse Vincent etc. stay in `CREDITS.md` where they belong. (T1-6)
- **GitHub Discussions enabled** on the repo — better forum for "how do I" than issues; keeps the issue tracker for actionable bugs. (T1-4)
- **Branch protection on `main`** — requires both `secret + PII scan (repo-wide) (ubuntu-latest)` and `(macos-latest)` to pass before any PR can merge. Admins (solo maintainer) remain exempt for now via `enforce_admins: false`. (T1-5)
- **CI matrix: `macos-latest`** — proves the pre-commit hook's macOS bash 3.2 portability claim that previously shipped unverified. (T1-2)
- **CI gate 8: `shellcheck .githooks/pre-commit`** — catches semantic bash bugs (unquoted variables, broken array expansions, fragile pipes) that `bash -n` misses. Installed via `brew` on macOS; pre-installed on ubuntu. (T1-1)
- **GitHub Releases** for v0.1.0 and v0.1.1 — both tags existed since the original ship but the Releases page was empty.

### Fixed

- **F7: CI PII-scan drift** — `scripts/verify.sh` was not in the CI workflow's PII-scan exclusion list, so CI had been red on every push to `main` since v0.1.1 (commits `442359d`, `5e9aa88`). The local `verify.sh` excludes itself from its own scans, masking the drift locally. CI exclusions now match `verify.sh`'s self-exclusions exactly, restoring the CI/local parity the v0.1.1 polish claimed.
- **F8: PyYAML missing on macOS runners** — Gate 7 (workflow YAML syntax) failed on `macos-latest` with `ModuleNotFoundError: No module named 'yaml'`. Now installs PyYAML via `actions/setup-python@v5` + `pip install pyyaml` before any gate runs. Surfaced by T1-2 (matrix); this is exactly what the matrix was added to catch.

### Unchanged

- Skill body (`skill/SKILL.md` still 169 / 200 lines).
- All 5 slash commands — no behavior changes.
- All 7 templates and 8 references — no changes.
- Pre-commit hook (`.githooks/pre-commit`) — no changes; shellcheck-clean.
- ExampleApp — no changes.
- `scripts/verify.sh` — no changes; local-only ergonomic gates (shellcheck remains CI-only because most macOS developers don't have it installed).
- Success criteria dates — Day-14 retro (2026-06-09) and Day-30 retro (2026-06-25) unchanged from v0.1.1.

### Known follow-ups (deferred — see [`docs/success-criteria.md`](docs/success-criteria.md) decision points)

- **Node 20 deprecation notice** on `actions/checkout@v4` and `actions/setup-python@v5` — non-blocking warning. Will lift action versions before Sept 16, 2026 when Node 20 is removed from runners.
- **Tier 2 / 3 items** — phased per [`.claude/wiki/v0.1.2-plan.md`](.claude/wiki/v0.1.2-plan.md). Day-30 retro at 2026-06-25 decides which graduate to v0.2.

---

## [0.1.1] — 2026-05-26

Same-day polish pass on v0.1.0. No behavior changes to any slash command; no API or schema changes; no template changes. v0.1.1 fixes adopter-experience and contributor-experience gaps surfaced by a second-pass review of the v0.1.0 surfaces.

### Changed

- **README rewrite** — restructured to match the canonical README pattern used across the author's other public Claude Code repos ([`claude-code-deep-review`](https://github.com/aksheyw/claude-code-deep-review), [`claude-code-rules`](https://github.com/aksheyw/claude-code-rules), [`claude-code-learned-skills`](https://github.com/aksheyw/claude-code-learned-skills), [`career-command-center-template`](https://github.com/aksheyw/career-command-center-template)). New sections:
  - "Why I built this" — personal narrative explaining the cross-session-amnesia problem in concrete terms.
  - "What's in this repo" — file table with line counts so adopters can scan the surface in 10 seconds.
  - "The standout: handoff prompts + honesty rules" — promotes the killer feature (CLAUDE.md honesty section embedding) above the install instructions.
  - "Verify install worked" — explicit verification steps following install, matching the convention from the author's other skill repos.
  - "Example output" — literal rendered `/cb-handoff` output drawn from `examples/ExampleApp/SESSION_HANDOFF_2026-05-25.md`, so adopters can evaluate value-proposition without installing.
  - "Troubleshooting" — 5 common-failure cases with fixes.
- **CONTRIBUTING.md** — gates section now points adopters at `scripts/verify.sh` (one command) instead of listing 7 separate commands. Removed the "gates 4-7 are local-only" caveat now that CI enforces all 7.

### Added

- **`scripts/verify.sh`** — single-command local gate runner. Runs all 7 contributor gates (secrets, PII, SKILL.md size, Karpathy gist linked, cross-links resolve, frontmatter present, hook + workflow syntax) plus a bonus SKILL.md integrity check. Exits 0 on all-green; lists failures with file/line context on red.
- **CI parity** — `.github/workflows/pii-scrub-check.yml` extended from 4 steps to 8. New steps enforce gates 4-7 (Karpathy gist linked, cross-links resolve, frontmatter present, hook + workflow syntax). CI now mirrors what `scripts/verify.sh` runs locally; CONTRIBUTING.md's "all gates enforced in CI" claim is now true.
- **`docs/success-criteria.md`** — explicit v0.1 success criteria with adoption / quality / author-dogfood targets, day-14 and day-30 decision points, and a retrospective template. Without this, "did v0.1 work?" is a vibes question.

### Removed

- **README "Roadmap" section** — premature for v0.1; v0.2 / v0.3 scope lives in [`docs/superpowers/specs/2026-05-26-context-bridge-design.md`](docs/superpowers/specs/2026-05-26-context-bridge-design.md) §11.2-11.3 where it belongs.

### Unchanged

- Skill body (`skill/SKILL.md` is still 169 / 200 lines).
- All 5 slash commands (`cb-init`, `cb-status`, `cb-ingest`, `cb-save-sync`, `cb-handoff`) — no behavior changes.
- All 7 templates and 8 references — no changes.
- Pre-commit hook (`.githooks/pre-commit`) — no changes.
- ExampleApp — no changes; v0.1.1 README references its existing content.
- All v0.1.0 findings status — F1/F2/F4/F6 RESOLVED, F3 ACCEPTED, F5 DEFERRED unchanged.

### Still deferred to a future patch

- **Demo GIFs** — `docs/demos/install.gif` and `docs/demos/save-sync.gif`. v0.1.1 promotes the literal-text example output in the README as a viable interim. Recording GIFs deferred indefinitely; will ship if and when adoption signal warrants it (see `docs/success-criteria.md`).

---

## [0.1.0] — 2026-05-26

First public release. Working skill bundle that can be installed, initialised in a project, and used through a full session loop.

### Added

- **Skill body** — [`skill/SKILL.md`](skill/SKILL.md) (169 lines, under the 200-line budget) covering problem framing, the 5-command surface, wiki shape, the 11-step save+sync protocol summary, the handoff prompt template, and inherited honesty rules.
- **5 slash commands** in [`skill/commands/`](skill/commands/):
  - `/cb-init` — pre-flight collision scan + scaffold `.claude/wiki/` + idempotent `CLAUDE.md` append.
  - `/cb-status` — read-only 5-bullet snapshot from `_hot.md`, latest `_log.md` entry, and open findings.
  - `/cb-ingest` — capture a non-obvious learning; routes to `gotchas/`, `decisions/`, `_findings.md`, or `_log.md`.
  - `/cb-save-sync` — full 11-step end-of-session protocol with user-gated wiki edits.
  - `/cb-handoff` — generate next-session prompt + write `SESSION_HANDOFF_<date>.md`.
- **7 templates** in [`skill/templates/`](skill/templates/): `_hot.md`, `_log.md`, `_findings.md`, `_schema.md`, `decision.md`, `gotcha.md`, `CLAUDE.md.snippet`. All scrubbed — only `<project-name>` / `<topic>` placeholders.
- **8 deep references** in [`skill/references/`](skill/references/): `save-sync-protocol.md`, `handoff-template.md`, `wiki-structure.md`, `honesty-rules.md`, `findings-register.md`, `secret-scan-guidance.md`, `migration-from-existing.md`, `karpathy-schema-delta.md`.
- **Local pre-commit hook** — [`.githooks/pre-commit`](.githooks/pre-commit) (opt-in via `git config core.hooksPath .githooks`). Entropy-required secret scan + `.cb-scrub-list` proper-noun scan. macOS bash 3.2 portable.
- **CI workflow** — [`.github/workflows/pii-scrub-check.yml`](.github/workflows/pii-scrub-check.yml). Mirror of the hook's gates, runs on PRs to `main` and on `main` pushes. Plus a SKILL.md 200-line budget check.
- **GitHub templates** — issue templates (`bug_report.md`, `feature_request.md`) + a PR template with the contributor gate checklist.
- **OSS hygiene files** — `LICENSE` (MIT), `CREDITS.md`, `CONTRIBUTING.md`, `CODE_OF_CONDUCT.md`, `SECURITY.md`, this file.
- **Design spec** — [`docs/superpowers/specs/2026-05-26-context-bridge-design.md`](docs/superpowers/specs/2026-05-26-context-bridge-design.md). v3 — deep-reviewed (14 lenses, 15 findings) + audited (Rounds 2-3, ripple search, 10 more findings). All 25 unique findings closed in spec text.

### Security

- GitHub secret-scanning + push-protection enabled on the public repo.
- All templates ship scrubbed (only `ExampleApp` / `ExampleService` / `ExampleUser` placeholders; no real project names).
- Pre-commit hook + CI both scan staged content with entropy-required secret patterns.
- `secret-scan-guidance.md` reference documents the pattern set and rationale.

### Attribution

- **LLM Wiki pattern** — Andrej Karpathy ([gist](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f)). Wiki-as-compounding-knowledge concept; `_log` / `_schema` / `<topic>` shape.
- **Superpowers ecosystem** — Jesse Vincent ([obra](https://github.com/obra)). Brainstorm → spec → plan workflow; "skill that explains skills" pattern; slash-command structure inspiration. ([sponsor](https://github.com/sponsors/obra))
- **Claude Code + skills format** — Anthropic.
- **TDD discipline informing save+sync gates** — Kent Beck.
- Original to this release: 11-step save+sync protocol, `_hot.md` + `_findings.md` + `decisions/` + `gotchas/` schema additions, handoff prompt template, honesty rules. See [`CREDITS.md`](CREDITS.md) §3.

### Deferred to v0.1.1

- **Demo GIFs** — `docs/demos/install.gif` (30s install + bootstrap) and `docs/demos/save-sync.gif` (60s save-sync + warm resume) were scoped for v0.1 but deferred to v0.1.1. Recording-only, no behavior changes.

### Known issues

- **F1** — install path verification across plugin marketplaces is still in-progress; the `npx skills add aksheyw/context-bridge` path documented in the README and `docs/install-verification.md` reflects the verified surface.
- **F3** — pre-commit hook activation is opt-in (`git config core.hooksPath .githooks`) by design; a one-line installer is deferred to v0.2.
- **F4** — `/cb-init` includes interactive migration for prior `.claude/wiki/` setups; doc-only mode is the v0.2 alternative.
- **F5** — Windows-native (non-WSL) paths are documented as unsupported in [`docs/compatibility.md`](docs/compatibility.md); v0.2 candidate.
- **F6** — proper-noun scanning relies on a local `.cb-scrub-list` (gitignored); per-machine; not portable across adopters by design.

### Out of scope (deferred)

- Multi-user / team-shared wikis.
- Cross-tool installers (Cursor / Aider / Codex). The methodology is documented in `docs/adapting-to-other-tools.md`.
- Code-aware retrieval / embeddings / MCP servers.
- Wiki search beyond `grep`.
- Web UI to browse the wiki.

See [`docs/superpowers/specs/2026-05-26-context-bridge-design.md`](docs/superpowers/specs/2026-05-26-context-bridge-design.md) §11.2-11.3 for v0.2 + v0.3 scope.

---

## [0.0.0] — 2026-05-26 (shell only — pre-skill)

Repo bootstrap. No installable skill yet.

### Added
- Initial `README.md`, `LICENSE` (MIT), `CREDITS.md`, design spec.
- Dev `.claude/wiki/` (dogfooded the convention before shipping it).
- GitHub repo metadata (description, topics, secret-scanning, push-protection).

### Notes
- This release is for record-keeping. The first usable artifact is v0.1.0.

[Unreleased]: https://github.com/aksheyw/context-bridge/compare/v0.1.2...HEAD
[0.1.2]: https://github.com/aksheyw/context-bridge/releases/tag/v0.1.2
[0.1.1]: https://github.com/aksheyw/context-bridge/releases/tag/v0.1.1
[0.1.0]: https://github.com/aksheyw/context-bridge/releases/tag/v0.1.0
[0.0.0]: https://github.com/aksheyw/context-bridge/releases/tag/v0.0.0
