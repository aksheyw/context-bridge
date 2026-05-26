# Security Policy

## Reporting a vulnerability

Please **do not** open a public GitHub issue for security findings.

Use the private channel instead: open a [Security Advisory](https://github.com/aksheyw/context-bridge/security/advisories/new) on this repo. Only the maintainer sees it; we discuss and patch privately, then disclose publicly once a fix ships.

If you cannot use Security Advisories, see the project README for alternate contact paths.

## What's in scope

- Anything in `skill/` — slash command logic, templates, references.
- The local pre-commit hook ([`.githooks/pre-commit`](.githooks/pre-commit)).
- The CI workflow ([`.github/workflows/pii-scrub-check.yml`](.github/workflows/pii-scrub-check.yml)).
- The install command path documented in the README + [`docs/install-verification.md`](docs/install-verification.md).

Specifically of interest:
- Patterns in the secret-scan rules that fail to catch a real credential class.
- Patterns that produce a high false-positive rate.
- Ways `/cb-init` could overwrite an adopter's existing wiki content (idempotency violations).
- Ways `/cb-save-sync` could push to a remote without explicit user opt-in.
- Bypasses of the pre-commit hook that look like contributor errors but are reproducible.

## What's NOT in scope

- Vulnerabilities in Claude Code itself — report those to Anthropic.
- Vulnerabilities in third-party MCP servers, plugins, or tooling not shipped in this repo.
- Vulnerabilities that require the attacker to already have write access to the adopter's git repo or local filesystem.
- Vulnerabilities in `docs/` content that are content claims (e.g., factual corrections) — open a normal issue with the `docs` label.

## Response targets

This is a side project maintained by [@aksheyw](https://github.com/aksheyw). Response times are best-effort:

- **Acknowledgement** of a report: within 7 days.
- **Triage** and severity assessment: within 14 days.
- **Fix or mitigation** plan: communicated within 30 days of triage.
- **Public disclosure** via the Security Advisory: once a fix has shipped to `main` and a tagged release is out.

If a finding is severe and time-sensitive (e.g., a way for a malicious template to exfiltrate adopter content), expect faster turnaround — flag urgency in the Security Advisory.

## Supported versions

| Version | Status |
|---|---|
| 0.1.x | ✅ Actively supported. Security fixes land here. |
| 0.0.x | ❌ Pre-release shell. No fixes — upgrade to 0.1.x. |

Future v0.2.x will get its own support window once it ships.

## Credit

Reporters of accepted findings are credited in `CHANGELOG.md` under the corresponding release and in the GitHub Security Advisory metadata (if they opt in).
