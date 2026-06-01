#!/usr/bin/env python3
"""
context-bridge — wiki lint (the v0.2 lint specced in skill/references/wiki-structure.md).

Flag-only. Reports issues; never edits. Lints a `.claude/wiki/` tree against the
context-bridge conventions:

  ERRORS  (exit 1) — unambiguous breakage:
    1. Missing/malformed required frontmatter (`title:` + ISO `updated:`) on every page.
    2. Broken [[wiki-links]] — a [[target]] with no matching page in the wiki.
    3. Finding IDs in _findings.md not monotonic (duplicate or out-of-order F<n>).

  WARNINGS (exit 0) — advisory, surfaced but non-blocking:
    4. Stale `updated:` (> STALE_DAYS) on root `_*.md` files. (suppressed by --no-stale)
    5. Orphan pages — no inbound reference from any other page.
    6. Gaps in the finding-ID sequence (F1, F3, ...).

Usage:
    wiki-lint.py [WIKI_DIR] [--no-stale] [--stale-days N]

WIKI_DIR defaults to `.claude/wiki` under the current directory.
Exit: 0 = no errors (warnings allowed), 1 = errors found, 2 = usage/IO error.

Stdlib only — no PyYAML — so adopters can run it with a bare python3.
"""

from __future__ import annotations

import argparse
import datetime as dt
import re
import sys
from pathlib import Path

STALE_DAYS = 30
ROOT_PREFIX = "_"  # files like _hot.md / _log.md / _findings.md / _schema.md

FENCE_RE = re.compile(r"```.*?```", re.DOTALL)
INLINE_CODE_RE = re.compile(r"`[^`]*`")
WIKILINK_RE = re.compile(r"\[\[([^\]]+)\]\]")
FINDING_ID_RE = re.compile(r"^##\s+F(\d+)\b", re.MULTILINE)


# --- small helpers -----------------------------------------------------------

def strip_code(text: str) -> str:
    """Remove fenced blocks + inline code so documented [[examples]] don't count."""
    return INLINE_CODE_RE.sub("", FENCE_RE.sub("", text))


def parse_frontmatter(text: str) -> dict[str, str] | None:
    """Return the leading --- ... --- block as a dict, or None if absent."""
    lines = text.splitlines()
    if not lines or lines[0].strip() != "---":
        return None
    fields: dict[str, str] = {}
    for line in lines[1:]:
        if line.strip() == "---":
            return fields
        key, sep, value = line.partition(":")
        if sep and key.strip():
            fields[key.strip()] = value.strip()
    return None  # no closing fence -> treat as no frontmatter


def link_target(raw: str) -> str:
    """Normalise [[target|alias]] / [[target#heading]] to the bare target stem."""
    return raw.split("|", 1)[0].split("#", 1)[0].strip()


# --- the checks --------------------------------------------------------------

def collect_pages(wiki_dir: Path) -> list[Path]:
    return sorted(p for p in wiki_dir.rglob("*.md"))


def check_frontmatter(page: Path, fm: dict[str, str] | None) -> list[str]:
    if fm is None:
        return [f"{page.name}: missing YAML frontmatter (need `title:` + `updated:`)"]
    errors = []
    if not fm.get("title"):
        errors.append(f"{page.name}: frontmatter missing required `title:`")
    updated = fm.get("updated")
    if not updated:
        errors.append(f"{page.name}: frontmatter missing required `updated:`")
    else:
        try:
            dt.date.fromisoformat(updated)
        except ValueError:
            errors.append(f"{page.name}: `updated: {updated}` is not an ISO date (YYYY-MM-DD)")
    return errors


def check_broken_links(page: Path, body: str, stems: set[str]) -> list[str]:
    errors = []
    for raw in WIKILINK_RE.findall(strip_code(body)):
        target = link_target(raw)
        if target and target not in stems:
            errors.append(f"{page.name}: broken [[link]] → [[{target}]] (no such page)")
    return errors


def check_finding_ids(wiki_dir: Path) -> tuple[list[str], list[str]]:
    """Monotonic + unique = error; gaps = warning."""
    findings = wiki_dir / "_findings.md"
    if not findings.exists():
        return [], []
    ids = [int(n) for n in FINDING_ID_RE.findall(findings.read_text(encoding="utf-8"))]
    if not ids:
        return [], []
    errors, warnings = [], []
    seen: set[int] = set()
    prev = None
    for fid in ids:
        if fid in seen:
            errors.append(f"_findings.md: duplicate finding ID F{fid}")
        elif prev is not None and fid < prev:
            errors.append(f"_findings.md: finding ID F{fid} is out of order (after F{prev})")
        seen.add(fid)
        prev = fid
    ordered = sorted(seen)
    expected = set(range(ordered[0], ordered[-1] + 1))
    missing = sorted(expected - seen)
    if missing:
        warnings.append(
            "_findings.md: gap in finding-ID sequence — missing "
            + ", ".join(f"F{m}" for m in missing)
        )
    return errors, warnings


def check_stale(page: Path, fm: dict[str, str], today: dt.date, stale_days: int) -> list[str]:
    if not page.name.startswith(ROOT_PREFIX):
        return []  # spec: staleness applies to root files only
    updated = fm.get("updated", "")
    try:
        age = (today - dt.date.fromisoformat(updated)).days
    except ValueError:
        return []  # malformed date already reported by frontmatter check
    if age > stale_days:
        return [f"{page.name}: `updated: {updated}` is {age} days old (> {stale_days})"]
    return []


def check_orphans(pages: list[Path], bodies: dict[Path, str]) -> list[str]:
    """A page is orphaned if its stem is referenced by no other page (any link style)."""
    warnings = []
    for page in pages:
        if page.name.startswith(ROOT_PREFIX):
            continue  # root files are entry points, never orphans
        stem = page.stem
        referenced = any(stem in body for other, body in bodies.items() if other != page)
        if not referenced:
            warnings.append(f"{page.name}: orphan — no inbound reference from any other page")
    return warnings


# --- orchestration -----------------------------------------------------------

def lint(wiki_dir: Path, *, check_staleness: bool, stale_days: int, today: dt.date):
    pages = collect_pages(wiki_dir)
    if not pages:
        return [f"{wiki_dir}: no markdown pages found"], []
    bodies = {p: p.read_text(encoding="utf-8") for p in pages}
    stems = {p.stem for p in pages}

    errors: list[str] = []
    warnings: list[str] = []

    for page in pages:
        fm = parse_frontmatter(bodies[page])
        fm_errors = check_frontmatter(page, fm)
        errors += fm_errors
        errors += check_broken_links(page, bodies[page], stems)
        if check_staleness and fm and not fm_errors:
            warnings += check_stale(page, fm, today, stale_days)

    id_errors, id_warnings = check_finding_ids(wiki_dir)
    errors += id_errors
    warnings += id_warnings
    warnings += check_orphans(pages, bodies)

    return errors, warnings


def main() -> int:
    parser = argparse.ArgumentParser(description="Lint a context-bridge .claude/wiki/ tree.")
    parser.add_argument("wiki_dir", nargs="?", default=".claude/wiki",
                        help="path to the wiki directory (default: .claude/wiki)")
    parser.add_argument("--no-stale", action="store_true",
                        help="skip the stale-date check (use when linting a frozen fixture)")
    parser.add_argument("--stale-days", type=int, default=STALE_DAYS,
                        help=f"days before a root file is stale (default: {STALE_DAYS})")
    args = parser.parse_args()

    wiki_dir = Path(args.wiki_dir)
    if not wiki_dir.is_dir():
        sys.stderr.write(f"wiki-lint: not a directory: {wiki_dir}\n")
        return 2

    try:
        errors, warnings = lint(
            wiki_dir,
            check_staleness=not args.no_stale,
            stale_days=args.stale_days,
            today=dt.date.today(),
        )
    except OSError as exc:
        sys.stderr.write(f"wiki-lint: {exc}\n")
        return 2

    page_count = len(collect_pages(wiki_dir))
    print(f"wiki-lint — {wiki_dir}  ({page_count} pages)")
    for err in errors:
        print(f"  ERROR  {err}")
    for warn in warnings:
        print(f"  WARN   {warn}")
    if not errors and not warnings:
        print("  OK — no issues")
    print(f"\n{len(errors)} error(s), {len(warnings)} warning(s).")
    return 1 if errors else 0


if __name__ == "__main__":
    sys.exit(main())
