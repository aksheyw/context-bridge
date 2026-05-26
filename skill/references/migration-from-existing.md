# Migration from an existing wiki

> What `/cb-init` does when it detects a pre-existing `.claude/wiki/` directory. Three branches: migrate, adopt as-is, refuse.

> **Provenance:** original to context-bridge. Closes finding F4 in the v0.0 design audit.

---

## Detection

When `/cb-init` runs, step 1 (pre-flight scan) inspects `.claude/wiki/` if present:

| What it finds | What it concludes |
|---|---|
| `_hot.md` + `_findings.md` + the `context-bridge:begin` marker in CLAUDE.md | Already initialised by context-bridge. Idempotent re-run — no-op. |
| `_log.md` + `_schema.md` but no `_hot.md` and no `_findings.md` | Karpathy-style LLM Wiki (or similar). Offer **migrate** path. |
| `_hot.md` exists but no context-bridge marker in CLAUDE.md | Partial — wiki present but skill not registered. Offer **adopt** path. |
| Any `.md` files but neither pattern above | Unknown convention. Offer **migrate** or **adopt as-is**, with notes. |
| Directory exists but is empty | Treat as missing — run greenfield scaffold. |

Detection is non-destructive — no files are read into memory beyond filename listings + presence checks. The CLAUDE.md marker check uses the exact string `<!-- context-bridge:begin -->`.

---

## Three branches

### Branch A — migrate

**Choose this when:** your existing wiki has structure but not context-bridge's additions. You want the warm-resume + findings-tracking layer on top of what you've got.

**What happens:**
1. Existing files are PRESERVED as-is. Never overwritten.
2. New files added (only if absent):
   - `_hot.md` (current focus — bootstrapped empty, you fill in)
   - `_findings.md` (open issues register — bootstrapped empty)
3. `_schema.md` updated to note BOTH the prior convention (e.g. "Karpathy LLM Wiki") AND the context-bridge additions.
4. `decisions/` and `gotchas/` directories left absent (created lazily when first file is added).
5. CLAUDE.md marked section appended (or created if no CLAUDE.md).

**What stays the same:**
- Your existing `_log.md` keeps its history.
- Any `references/<topic>.md` pages untouched.
- File naming conventions you already use stay valid.

### Branch B — adopt as-is

**Choose this when:** your existing wiki works well and you only want context-bridge for the commands + handoff prompt, not for the schema additions.

**What happens:**
1. Existing files all preserved.
2. No new wiki files added.
3. `_schema.md` written (only if absent) to document YOUR existing convention as the project's schema. Context-bridge's defaults are noted as deltas you've chosen not to adopt.
4. CLAUDE.md marked section appended (or created).
5. `/cb-status`, `/cb-save-sync`, `/cb-handoff` work against your existing files. They detect what's present and adapt.

**What you lose:**
- `_hot.md` / `_findings.md` features in `/cb-status` (they'll show `n/a`).
- Per-item gating in `/cb-save-sync` for finding-promotion (no `_findings.md` to promote from).

**What you keep:**
- Your entire wiki shape.
- The save+sync 11-step protocol.
- The handoff prompt generator.
- The honesty rules in CLAUDE.md.

### Branch C — refuse

**Choose this when:** you don't want context-bridge to touch this project at all, but `/cb-init` ran by mistake.

**What happens:**
- Nothing. No files written. No CLAUDE.md changes. Print: "Aborted — no files changed."
- The user can uninstall the skill or just not run any `/cb-*` commands.

---

## Karpathy LLM Wiki specifically

Karpathy's [original pattern](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f) uses:

- `_index.md` — topic catalog
- `_log.md` — append-only log
- `_schema.md` — schema page
- `<topic>.md` files at root or in subdirectories

Context-bridge ADDS (per `karpathy-schema-delta.md`):
- `_hot.md` — current focus (always-on-top)
- `_findings.md` — open-issues register
- `decisions/` — decision log directory
- `gotchas/` — promoted findings + observed traps

If your wiki follows Karpathy's shape, the **migrate** branch is the recommended path. The migration adds `_hot.md` and `_findings.md` only; everything else is preserved.

`_index.md` is OPTIONAL in context-bridge but not banned — if you have one, keep it. The skill commands don't read it directly.

---

## Other conventions

### Plain `notes/` directory

If your project uses `.claude/notes/` or similar instead of `.claude/wiki/`, context-bridge does NOT auto-migrate. The detection runs only against `.claude/wiki/`. Two paths:

- Move your existing notes to `.claude/wiki/` first, then run `/cb-init` (it'll detect them).
- Or run `/cb-init` greenfield and migrate manually as time permits.

The skill won't touch directories it doesn't know about.

### `tasks/lessons.md` style

Some projects use a single-file `tasks/lessons.md` for cross-session learnings. This coexists with `.claude/wiki/` cleanly — `/cb-init` doesn't touch it. The user decides whether to consolidate.

If you want to migrate `tasks/lessons.md` into the wiki:
- Recent / actionable entries → `gotchas/gotcha-<topic>.md` (one per lesson with a non-obvious root cause).
- Historical lessons that don't need re-discovery → leave in `tasks/lessons.md` as an archive.
- Categorisation aids → consider `references/<area>.md` pages.

No automation for this migration in v0.1. It's a manual review job.

### Confluence / Notion / external wiki

Out of scope. Context-bridge is local-markdown by design (single-developer, single-machine — see `SKILL.md` "What this skill does NOT do"). If you have an external wiki, treat context-bridge's local `.claude/wiki/` as a session-state cache and your external wiki as the durable team docs. They serve different needs.

---

## Idempotency

After migration, running `/cb-init` again is a no-op. The detection logic looks for `_hot.md` + `_findings.md` + the CLAUDE.md marker — once all three are present, the command exits with `IDEMPOTENT: marker present, skip CLAUDE.md append` + `IDEMPOTENT: wiki already initialised, skip scaffold`.

This means you can safely re-run `/cb-init` after any update to the skill itself.

---

## Open questions on migration UX

(Tracked in `.claude/wiki/_findings.md` F4 of the design audit.)

- Should the migration prompt be interactive (3 options, terminal selector) or doc-driven (skill explains, user runs the right sub-command)?
- For partial wikis (some context-bridge files present, others not), should `/cb-init` fill in only the gaps or prompt before each?

v0.1 default: interactive prompt with 3 explicit options at the top level. Per-file gap-filling is automatic in branch A (migrate) and skipped in branch B (adopt).
