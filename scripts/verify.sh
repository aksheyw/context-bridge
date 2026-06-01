#!/usr/bin/env bash
#
# context-bridge — local gate runner
# ----------------------------------------------------------------------
# Runs all 8 contributor gates from CONTRIBUTING.md in one go.
# Exit code: 0 if all gates green, 1 if any fail. Mirrors what CI
# enforces (gates 1-8). CI additionally runs shellcheck (gate 9),
# which is CI-only because most macOS dev machines lack it.
#
# Usage:
#   scripts/verify.sh          # all gates
#   scripts/verify.sh --quiet  # only print failures + summary
# ----------------------------------------------------------------------

set -uo pipefail

# Find repo root regardless of where the script is invoked from
REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null)" || {
  echo "error: not inside a git repo" >&2
  exit 2
}
cd "$REPO_ROOT"

# Colours (drop in non-tty)
if [ -t 1 ]; then
  RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; YELLOW=$'\033[0;33m'; BOLD=$'\033[1m'; RESET=$'\033[0m'
else
  RED=""; GREEN=""; YELLOW=""; BOLD=""; RESET=""
fi

QUIET=0
[ "${1:-}" = "--quiet" ] && QUIET=1

PASS=0
FAIL=0

# ----------------------------------------------------------------------
# Helpers
# ----------------------------------------------------------------------
pass()    { PASS=$((PASS+1)); [ "$QUIET" -eq 0 ] && echo "  ${GREEN}✓${RESET} $*"; }
fail()    { FAIL=$((FAIL+1)); echo "  ${RED}✗${RESET} $*"; }
heading() { [ "$QUIET" -eq 0 ] && echo "${BOLD}$*${RESET}"; }

# ----------------------------------------------------------------------
# Gate 1 — No real secrets (entropy-required)
# ----------------------------------------------------------------------
gate_1_secrets() {
  heading "Gate 1 — No real secrets (entropy-required scan)"
  local exclude='--  :!.github/workflows/pii-scrub-check.yml :!.githooks/pre-commit :!skill/references/secret-scan-guidance.md :!skill/commands/cb-ingest.md :!skill/commands/cb-save-sync.md :!scripts/verify.sh'
  local patterns=(
    'sk-or-v1-[A-Za-z0-9]{20,}'
    'sk-[A-Za-z0-9]{30,}'
    'ghp_[A-Za-z0-9]{30,}'
    'gho_[A-Za-z0-9]{30,}'
    'ghs_[A-Za-z0-9]{30,}'
    'eyJ[A-Za-z0-9_=-]{10,}\.[A-Za-z0-9_=-]{10,}\.[A-Za-z0-9_=-]{20,}'
    '[0-9]{8,12}:[A-Za-z0-9_-]{30,50}'
    'AKIA[A-Z0-9]{16}'
    'ASIA[A-Z0-9]{16}'
    'BEGIN [A-Z]+ PRIVATE KEY'
  )
  local hits=0
  for pat in "${patterns[@]}"; do
    local match
    match="$(git grep -nE "$pat" $exclude 2>/dev/null || true)"
    if [ -n "$match" ]; then
      echo "    $YELLOW$pat$RESET:"
      echo "$match" | head -3 | sed 's/^/      /'
      hits=$((hits+1))
    fi
  done
  if [ "$hits" -eq 0 ]; then
    pass "scanned ${#patterns[@]} patterns; clean"
  else
    fail "Gate 1: $hits secret-pattern hit(s)"
  fi
}

# ----------------------------------------------------------------------
# Gate 2 — No private proper nouns
# ----------------------------------------------------------------------
gate_2_pii() {
  heading "Gate 2 — No private proper nouns (PII baseline)"
  local exclude='-- :!.github/workflows/pii-scrub-check.yml :!scripts/verify.sh'
  local patterns=(
    'Plant Sage' 'Kahaani' 'KahaaniBlog' 'Wealth Builder' 'sage-bot' 'sage-hermes'
    'sagebotAI' 'kahaaniblog' 'kahaaniastudio' 'srv1134430' 'aksheyw@gmail'
  )
  local hits=0
  for pat in "${patterns[@]}"; do
    local match
    match="$(git grep -nF "$pat" $exclude 2>/dev/null || true)"
    if [ -n "$match" ]; then
      echo "    $YELLOW$pat$RESET:"
      echo "$match" | head -3 | sed 's/^/      /'
      hits=$((hits+1))
    fi
  done
  if [ "$hits" -eq 0 ]; then
    pass "scanned ${#patterns[@]} patterns; clean"
  else
    fail "Gate 2: $hits PII-pattern hit(s)"
  fi
}

# ----------------------------------------------------------------------
# Gate 3 — skill/SKILL.md ≤ 200 lines
# ----------------------------------------------------------------------
gate_3_skill_size() {
  heading "Gate 3 — SKILL.md size budget (≤ 200 lines)"
  if [ ! -f skill/SKILL.md ]; then
    fail "Gate 3: skill/SKILL.md missing"
    return
  fi
  local lines
  lines="$(wc -l < skill/SKILL.md | tr -d ' ')"
  if [ "$lines" -le 200 ]; then
    pass "skill/SKILL.md: $lines / 200 lines"
  else
    fail "Gate 3: skill/SKILL.md is $lines lines (budget: 200). Move deep content into references/."
  fi
}

# ----------------------------------------------------------------------
# Gate 4 — Karpathy gist linked wherever Karpathy is named
# ----------------------------------------------------------------------
gate_4_karpathy_linked() {
  heading "Gate 4 — Karpathy gist linked on every mention"
  local gist='https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f'
  local orphans=0
  while IFS= read -r f; do
    [ -z "$f" ] && continue
    if ! grep -qF "$gist" "$f"; then
      echo "    $YELLOW$f$RESET: mentions Karpathy but doesn't link the gist"
      orphans=$((orphans+1))
    fi
  done < <(git grep -li 'karpathy' -- 'skill/**' 'docs/**' 'examples/**' 'README.md' 'CREDITS.md' 'CHANGELOG.md' 2>/dev/null)
  if [ "$orphans" -eq 0 ]; then
    pass "every Karpathy mention links the canonical gist"
  else
    fail "Gate 4: $orphans file(s) mention Karpathy without linking the gist"
  fi
}

# ----------------------------------------------------------------------
# Gate 5 — All relative cross-links resolve
# ----------------------------------------------------------------------
gate_5_cross_links() {
  heading "Gate 5 — Relative cross-links resolve"
  if ! command -v python3 >/dev/null 2>&1; then
    fail "Gate 5: python3 not available"
    return
  fi
  local result
  result="$(python3 - <<'PY'
import os, re, sys
base = os.getcwd()
broken = []
checked = 0
for root, dirs, files in os.walk(base):
    if '/.git' in root or 'examples/ExampleApp/snapshots' in root or 'node_modules' in root:
        continue
    for f in files:
        if not f.endswith('.md'): continue
        path = os.path.join(root, f)
        try:
            with open(path, 'r', errors='replace') as fh: content = fh.read()
        except Exception:
            continue
        for m in re.finditer(r'\]\(([^)]+)\)', content):
            link = m.group(1).strip()
            if link.startswith(('http://', 'https://', 'mailto:', '#')): continue
            lc = link.split('#')[0].split('?')[0]
            if not lc: continue
            if '/' not in lc and not lc.endswith(('.md', '.yml', '.yaml', '.gif', '.snippet', '.sh', '.png', '.jpg')):
                continue
            checked += 1
            resolved = os.path.normpath(os.path.join(os.path.dirname(path), lc))
            if not os.path.exists(resolved):
                broken.append((os.path.relpath(path, base), link))
print(f"checked:{checked}")
for src, lk in broken[:10]:
    print(f"broken:{src} -> {lk}")
print(f"total_broken:{len(broken)}")
PY
)"
  local checked total_broken
  checked="$(echo "$result" | grep '^checked:' | cut -d: -f2)"
  total_broken="$(echo "$result" | grep '^total_broken:' | cut -d: -f2)"
  if [ "$total_broken" = "0" ]; then
    pass "$checked relative links resolve"
  else
    echo "$result" | grep '^broken:' | sed 's/^broken:/    /'
    fail "Gate 5: $total_broken / $checked links broken"
  fi
}

# ----------------------------------------------------------------------
# Gate 6 — Frontmatter on SKILL.md + every command
# ----------------------------------------------------------------------
gate_6_frontmatter() {
  heading "Gate 6 — Frontmatter present on SKILL.md + commands"
  local missing=0
  for f in skill/SKILL.md skill/commands/*.md; do
    [ -f "$f" ] || continue
    if [ "$(head -1 "$f")" != "---" ]; then
      echo "    $YELLOW$f$RESET: missing YAML frontmatter"
      missing=$((missing+1))
    fi
  done
  if [ "$missing" -eq 0 ]; then
    pass "frontmatter present on SKILL.md + 5 commands"
  else
    fail "Gate 6: $missing file(s) missing frontmatter"
  fi
}

# ----------------------------------------------------------------------
# Gate 7 — Hook + workflow syntax
# ----------------------------------------------------------------------
gate_7_hook_yaml_syntax() {
  heading "Gate 7 — Hook + workflow syntax"
  local errors=0
  if [ -f .githooks/pre-commit ]; then
    if ! bash -n .githooks/pre-commit 2>/dev/null; then
      echo "    $YELLOW.githooks/pre-commit$RESET: bash syntax error"
      errors=$((errors+1))
    fi
  fi
  if [ -f .github/workflows/pii-scrub-check.yml ]; then
    if command -v python3 >/dev/null 2>&1; then
      if ! python3 -c "import yaml; yaml.safe_load(open('.github/workflows/pii-scrub-check.yml'))" 2>/dev/null; then
        echo "    $YELLOW.github/workflows/pii-scrub-check.yml$RESET: YAML parse error"
        errors=$((errors+1))
      fi
    fi
  fi
  if [ "$errors" -eq 0 ]; then
    pass "hook + workflow syntax OK"
  else
    fail "Gate 7: $errors syntax error(s)"
  fi
}

# ----------------------------------------------------------------------
# Gate 8 — Wiki lint (the example fixture stays schema-valid)
# ----------------------------------------------------------------------
gate_8_wiki_lint() {
  heading "Gate 8 — Wiki lint (ExampleApp fixture)"
  if ! command -v python3 >/dev/null 2>&1; then
    fail "Gate 8: python3 not available"
    return
  fi
  local wiki="examples/ExampleApp/.claude/wiki"
  if [ ! -d "$wiki" ]; then
    pass "no example wiki to lint (skipped)"
    return
  fi
  local out
  # --no-stale: the fixture is frozen, so its dates legitimately age past 30 days.
  if out="$(python3 scripts/wiki-lint.py "$wiki" --no-stale 2>&1)"; then
    pass "$wiki lints clean"
  else
    echo "$out" | sed 's/^/    /'
    fail "Gate 8: wiki lint reported errors"
  fi
}

# ----------------------------------------------------------------------
# Bonus — Honesty section + zero stale-stub annotations
# (not part of the 8 contributor gates, but cheap to check)
# ----------------------------------------------------------------------
gate_bonus_skill_integrity() {
  heading "Bonus — SKILL.md integrity + Honesty sections"
  local issues=0
  # Stale stubs
  local stubs
  stubs="$(grep -c '(v0.1 stub)' skill/SKILL.md 2>/dev/null || true)"
  stubs="${stubs:-0}"
  if [ "$stubs" -gt 0 ] 2>/dev/null; then
    echo "    $YELLOW$stubs stale '(v0.1 stub)' annotations in SKILL.md$RESET"
    issues=$((issues+1))
  fi
  # Honesty section on every command
  for f in skill/commands/*.md; do
    if ! grep -qE '^## Honesty' "$f" 2>/dev/null; then
      echo "    $YELLOW$f$RESET: missing Honesty section"
      issues=$((issues+1))
    fi
  done
  if [ "$issues" -eq 0 ]; then
    pass "no stale stubs; Honesty section on every command"
  else
    fail "Bonus: $issues SKILL/command integrity issue(s)"
  fi
}

# ----------------------------------------------------------------------
# Run all gates
# ----------------------------------------------------------------------
echo
heading "context-bridge local gate runner"
echo "Repo: $REPO_ROOT"
echo

gate_1_secrets
gate_2_pii
gate_3_skill_size
gate_4_karpathy_linked
gate_5_cross_links
gate_6_frontmatter
gate_7_hook_yaml_syntax
gate_8_wiki_lint
gate_bonus_skill_integrity

echo
TOTAL=$((PASS+FAIL))
if [ "$FAIL" -eq 0 ]; then
  echo "${GREEN}${BOLD}✓ ALL GATES PASSED${RESET}  ($PASS / $TOTAL)"
  exit 0
else
  echo "${RED}${BOLD}✗ $FAIL / $TOTAL GATES FAILED${RESET}"
  exit 1
fi
