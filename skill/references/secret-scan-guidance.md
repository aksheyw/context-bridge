# Secret + PII scan guidance

> What step 0 of the save+sync protocol actually scans for. Why entropy matters. How to deploy the local pre-commit hook. What lives in `.cb-scrub-list`.

> **Provenance:** original to context-bridge. Pattern set draws on gitleaks / GitHub secret-scanning conventions. See [CREDITS.md](../../CREDITS.md) §3.1.

---

## Two scans, two purposes

| Scan | What it catches | Where it runs |
|---|---|---|
| **Secret scan** | API keys, tokens, JWTs, private keys | Step 0 of `/cb-save-sync`; local `.githooks/pre-commit`; GitHub push-protection |
| **Proper-noun (PII) scan** | Project codenames, real URLs, real IDs, internal hostnames | Step 0 of `/cb-save-sync`; local `.githooks/pre-commit`; CI `.github/workflows/pii-scrub-check.yml` |

GitHub secret-scanning catches the FIRST class very well. It does NOT catch the second. The local hook + the CI workflow cover both.

---

## Secret scan — patterns

Pattern requirements:
1. **Match real secrets, not just prefixes.** A bare `sk-` is documentation; `sk-` followed by 30+ base62 chars is a real key.
2. **Be specific to known providers.** Better to miss an exotic API key than to false-positive on every README that says "set your API key".
3. **Block on hit, no soft warnings.** A leaked secret is unrecoverable.

### Default pattern set

```
# OpenAI / OpenRouter
sk-[A-Za-z0-9]{30,}
sk-or-v1-[A-Za-z0-9]{20,}

# GitHub
ghp_[A-Za-z0-9]{30,}
gho_[A-Za-z0-9]{30,}
ghs_[A-Za-z0-9]{30,}

# JWT (3-part, eyJ-prefix, with entropy in all 3 parts)
eyJ[A-Za-z0-9_=-]{10,}\.[A-Za-z0-9_=-]{10,}\.[A-Za-z0-9_=-]{20,}

# Telegram bot tokens
[0-9]{8,12}:[A-Za-z0-9_-]{30,50}

# AWS access keys
AKIA[A-Z0-9]{16}
ASIA[A-Z0-9]{16}

# PEM-encoded private keys
BEGIN [A-Z]+ PRIVATE KEY

# Generic key=value secret assignment (high-entropy value)
(secret|api[_-]?key|password|access[_-]?token)\s*[:=]\s*['"`][A-Za-z0-9_+/=-]{20,}
```

The entropy minimums (`{20,}`, `{30,}`) are critical. Without them, the scan flags its own documentation — including this file. With them, the scan flags only strings that look like real secrets.

### Why entropy matters (real example from this repo)

When the secret-scan first ran on context-bridge's own commands, it flagged `sk-or-v1-` in `cb-ingest.md` and `cb-save-sync.md` — those files DOCUMENT the prefix as a pattern to scan for. Bare-prefix match: false positive on the skill's own documentation. Stricter pattern (`sk-or-v1-[A-Za-z0-9]{20,}`): correctly passes — there's no real key in the documentation.

Recorded as a discovery in `.claude/wiki/_findings.md` F6.

---

## Proper-noun (PII) scan — patterns

Driven by `.cb-scrub-list` (gitignored, one pattern per line) in the project root.

### `.cb-scrub-list` example

```
# Project codenames (real names that should not appear in public commits)
InternalCodeName
RedTeamProject

# Real domains
api.acme-internal.example
ops.acme-corp.example

# Real user / org IDs
12345678
acme-prod-cluster

# Comments allowed; blank lines allowed; one pattern per line
```

### Why gitignored

The scrub list itself contains the patterns it scans for. Committing it would defeat the purpose. `.gitignore` should include:

```
.cb-scrub-list
.cb-scrub-list.local
```

### Why not auto-derived

You could try to auto-derive proper nouns from git history or directory names. But:
- False-positives explode (every git committer's name would flag).
- The scrub list captures intent ("don't leak THIS specifically"), which auto-derivation can't.
- The user maintains the list as their project evolves. Five minutes of maintenance per quarter beats one leaked-and-rotated incident.

---

## Local pre-commit hook deployment

Hook lives in the project at `.githooks/pre-commit`. Adopters opt in via:

```bash
git config core.hooksPath .githooks
```

Not enabled by default because:
- It changes the local git behaviour.
- Adopters should make an explicit choice to gate their commits.
- Some adopters already have hook setups (Husky, lefthook, etc.) and don't want a parallel mechanism.

### Hook responsibilities

1. Get list of staged files: `git diff --cached --name-only --diff-filter=ACM`.
2. For each staged file, run the secret-pattern set against the staged content (not the working-tree content — `git show :path` reads the staged version).
3. For each staged file, grep against patterns in `.cb-scrub-list` if it exists.
4. On ANY hit: print file + line + matched pattern. Exit non-zero. Block the commit.

The hook script ships as part of the context-bridge skill bundle so adopters can copy it directly. See `.githooks/pre-commit` at repo root.

---

## CI scan — repo-wide

The CI workflow `.github/workflows/pii-scrub-check.yml` runs the same scans on every PR. Catches leaks that bypass the local hook (e.g. commit via web UI, or contributor who didn't enable the hook).

CI scan is repo-wide on each PR, not just changed files — because a previously-clean file might have been modified to add a leak.

CI scan is hard-block: if it finds anything, the PR cannot merge.

---

## What the user does on a hit

1. **Don't push.** The hook caught it before commit; the CI caught it before merge. Either way, the secret hasn't leaked YET.
2. **Decide:** is it a real secret or a false positive?
   - Real → remove from the file. If it's a value that was ever committed to git (even locally), ROTATE it. Don't trust that "I'll just remove the commit" works — git history is sticky.
   - False positive (e.g. the pattern matches documentation of the pattern itself, as happened with `sk-or-v1-`) → either tighten the pattern globally, or add a per-file exemption marker.
3. **Don't `--no-verify`.** Bypassing the hook defeats it. If the pattern is wrong, fix the pattern. If the secret is real, rotate it.

---

## What to do BEFORE the first push of a new public repo

For a brand-new public repo, run the full scan against the entire history before pushing:

```bash
git grep -E 'sk-[A-Za-z0-9]{30,}'
git grep -E 'sk-or-v1-[A-Za-z0-9]{20,}'
git grep -E 'ghp_[A-Za-z0-9]{30,}'
git grep -E 'eyJ[A-Za-z0-9_=-]{10,}\.[A-Za-z0-9_=-]{10,}\.[A-Za-z0-9_=-]{20,}'
git grep -E '[0-9]{8,12}:[A-Za-z0-9_-]{30,50}'
git grep -E '(secret|api[_-]?key|password|access[_-]?token)\s*[:=]\s*["'"'"'`][A-Za-z0-9_+/=-]{20,}'
```

If ANY match: STOP. Two options:
- **Few commits, no shared history:** redact in working tree → `rm -rf .git && git init` → single clean initial commit → push.
- **Established history:** redact with `git filter-repo --replace-text <secrets-list>` before push.

NEVER redact in HEAD and push — earlier commits still expose the values. "Private repo" reduces but does not eliminate exposure.

---

## Limits — what this scan does NOT catch

- **Steganographic leaks** (e.g. base64-encoded secret split across multiple lines). Out of scope for v0.1.
- **Image / binary file contents.** The scan is text-only.
- **Secrets in commit messages.** A separate scan would be needed; v0.2 candidate.
- **Secrets that haven't been invented yet.** When a new provider releases a new key format, the pattern set needs updating.

For coverage gaps, defer to GitHub secret-scanning (post-push) and rotate aggressively on any incident.
