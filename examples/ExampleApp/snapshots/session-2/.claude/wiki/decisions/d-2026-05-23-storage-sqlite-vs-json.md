---
title: Storage backend — SQLite vs. JSON file
updated: 2026-05-23
status: accepted
---

# Decision — Storage backend: SQLite

**Context:** ExampleApp needs persistent storage for todos. The data shape is tiny (a few hundred rows max), single-user, local-only. Options: SQLite file, plain JSON file, plain text (one task per line), per-user `~/.exampleapp/` dir of YAML files.

**Decision:** Use SQLite. Single file at `~/.exampleapp/todos.db`. Schema migrations via a simple `schema_version` table; runner runs all migrations greater than the current version.

**Alternatives rejected:**

- **JSON file** — easiest to read and edit by hand, but corrupts under concurrent writes (even if rare, two terminal windows = real risk). No atomic updates. Listing 10k tasks means rewriting the whole file every time.
- **Plain text (one task per line)** — even simpler. Same concurrency issue. Editing a single task means rewriting the file.
- **Per-task YAML files in `~/.exampleapp/tasks/`** — lovely for `git` introspection. Awful for "list all open tasks sorted by date" — a directory walk + parse on every query.

**Consequences:**

- **Unlocks:** atomic updates, indexed queries, `WHERE done = 0 ORDER BY created_at` is trivial.
- **Locks in:** SQLite-specific schema migrations (not a problem; SQL is portable enough that switching DBs later wouldn't be hard).
- **Implications for testing:** tests need a fresh DB per test; use `:memory:` SQLite + a fixture.
- **Implications for portability:** SQLite is in the Python stdlib (`sqlite3`); zero extra dependencies.

**Reversible?** Yes. The storage layer will be wrapped in a `Storage` interface; swapping SQLite for Postgres later (if the project grows) means writing one new implementation, not rewriting callers.

**Open questions deferred to next session:**

- Timestamp format in the schema (Unix epoch int vs. ISO 8601 string). Will decide on first write.
- Whether to keep deleted tasks (soft-delete) or hard-delete. Lean: hard-delete; this is a personal todo, not an audit log.
