# Compatibility

What's supported in v0.1, what isn't, and what to do in each case.

## Supported

| OS | Status | Notes |
|---|---|---|
| macOS (12+) | ✅ Supported | Primary dev environment. `bash 3.2`-portable hook tested. |
| Linux (any modern distro) | ✅ Supported | Tested on Ubuntu, Debian, Arch via WSL adapters. |
| Windows via WSL2 | ✅ Supported | Treat as Linux. Use the Linux path conventions. |
| Windows native (no WSL) | ❌ NOT supported in v0.1 | See [F5](#f5-windows-native). v0.2 candidate. |

| Tool | Status | Notes |
|---|---|---|
| Claude Code (CLI) | ✅ Supported | Primary target. v0.1 slash commands fire here. |
| Claude.ai web/desktop | 🟡 Partial | Wiki structure + methodology work. Slash commands won't fire — no Skill tool surface. |
| Cursor / Aider / Codex / Copilot CLI / Gemini CLI | 🟡 Methodology only | See [`docs/adapting-to-other-tools.md`](adapting-to-other-tools.md). v0.2 installer adapters planned. |

| Git host | Status | Notes |
|---|---|---|
| GitHub | ✅ Supported | Primary; CI workflow targets GitHub Actions. |
| GitLab / Bitbucket / Gitea | 🟡 Wiki + hook work | Local pre-commit hook is git-host-agnostic. CI workflow would need a port. |
| No remote at all (local-only git) | ✅ Supported | The wiki + hook don't require a remote. `/cb-save-sync` step 3 (push) becomes a no-op. |

## Hard requirements

- `git` (any modern version).
- `bash` (the hook is portable to `bash 3.2` — i.e. stock macOS bash without Homebrew).
- One of: `file` command (preferred for binary detection in the hook), OR a text-file extension match (fallback the hook uses if `file` is absent).
- For CI: GitHub Actions Ubuntu runner (or any environment with `bash` + `git grep`).

## Soft requirements

- `python3` with PyYAML — used by CONTRIBUTING.md's local workflow-YAML syntax check. Optional; the CI workflow itself doesn't need Python.
- `curl` — used by the README's install command and by your local pre-commit hook bootstrap step.
- `wc`, `head`, `grep`, `sed` — POSIX. Available on every supported OS.

## F5 — Windows native

**Status:** documented but unsupported in v0.1.

What breaks on Windows-native:
- The `.githooks/pre-commit` script uses bash syntax + POSIX tools.
- Path conventions in `/cb-init` assume `~/`, forward slashes, and case-sensitive filesystems.
- The CLAUDE.md marker block uses Unix line endings.

If you're on Windows-native and want to try it:
1. Use WSL2 — the supported path.
2. Or, install Git Bash + use it as your terminal for context-bridge ops. The hook and commands MOSTLY work but are not tested.

Native Windows support is a deliberate v0.2 scope target. If you can verify Git-Bash-on-Windows works end-to-end, please [open an issue](https://github.com/aksheyw/context-bridge/issues) with your findings — it might lift status from "unsupported" to "best-effort" in a point release.

## Filesystem expectations

- Case-sensitive paths (Linux, modern macOS APFS). On case-insensitive filesystems (older macOS HFS+, default Windows), `_hot.md` and `_Hot.md` collide; `/cb-init` writes lowercase only. Should be fine in practice.
- UTF-8 filenames + content. Non-UTF-8 wiki content (e.g. Latin-1) is not supported.
- Symbolic links are tolerated but not required.

## Network expectations

- The skill itself is offline-only. No telemetry, no analytics, no API calls.
- The install command (`npx skills add ...`) requires npm registry access.
- The CI workflow requires GitHub Actions access (only if you fork the repo).
- The CODE_OF_CONDUCT contact channel and SECURITY disclosure use GitHub Security Advisories (require GitHub login from the reporter).

The wiki content travels with `git`. If your `git remote` is reachable, your wiki backups are too.

## Performance budget

context-bridge is a markdown-and-bash skill. Real-world overhead per session:

- `/cb-init`: ~1-2 seconds (mostly file writes).
- `/cb-status`: ~1 second (3 file reads).
- `/cb-ingest`: ~1-3 seconds (1-2 writes + 1 confirm).
- `/cb-save-sync`: depends entirely on test suite + push speed. Wiki updates themselves are sub-second.
- `/cb-handoff`: ~1-2 seconds (read 3 files + write 1).

If any command takes >10 seconds, something else is wrong (test command running long, network timeout on push, etc.) — the wiki ops themselves are negligible.

## Versioning

- The skill follows [semver](https://semver.org/spec/v2.0.0.html).
- Breaking changes to the wiki schema = major bump (or a documented migration in `/cb-init`).
- New slash commands or wiki file types = minor bump.
- Doc-only changes or pure fixes = patch bump.

v0.x means we reserve the right to break things between minors if a clear improvement is on the table. Once we reach v1.0, semver applies strictly.

## Migration safety

If you're using v0.1 today and v0.2 ships with breaking changes:
- The changelog will spell out what changed.
- `/cb-init` will detect a v0.1-shaped wiki and offer migration (same machinery that already detects [Karpathy LLMwiki](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f)-style wikis today).
- Your existing wiki content is never silently rewritten.

## Reporting compat bugs

If something here is wrong for your setup, please [open an issue](https://github.com/aksheyw/context-bridge/issues) with:
- OS + version (`uname -a`, `sw_vers`).
- Bash version (`bash --version`).
- The command you ran and the exact output.
- Whether you're using WSL, native, or something else.

Compatibility issues are high-priority — broken installs and broken hooks are the most adopter-facing surface.
