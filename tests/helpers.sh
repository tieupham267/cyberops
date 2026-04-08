#!/bin/bash
# helpers.sh — Shared test utilities
# Source this file in each test script

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
FIXTURES_DIR="$SCRIPT_DIR/fixtures"

# Colors
if [ -t 1 ]; then
  RED='\033[0;31m'
  GREEN='\033[0;32m'
  YELLOW='\033[1;33m'
  NC='\033[0m'
else
  RED='' GREEN='' YELLOW='' NC=''
fi

# Counters (exported for run-all.sh to aggregate)
_PASS=0
_FAIL=0
_SKIP=0
_FAILURES=""

pass() {
  _PASS=$((_PASS + 1))
  echo -e "  ${GREEN}✓${NC} $1"
}

fail() {
  _FAIL=$((_FAIL + 1))
  echo -e "  ${RED}✗${NC} $1"
  _FAILURES="${_FAILURES}\n  - $1"
}

skip() {
  _SKIP=$((_SKIP + 1))
  echo -e "  ${YELLOW}○${NC} $1 (skipped)"
}

# Print layer summary and export counters to parent
layer_summary() {
  echo "  ── pass: $_PASS | fail: $_FAIL | skip: $_SKIP"
  # Write counters to temp file for aggregation by run-all.sh
  local tmp_file="/tmp/secops-test-$$-$RANDOM"
  echo "$_PASS $_FAIL $_SKIP" > "$tmp_file"
  echo "$tmp_file"
}

# --- Assertions ---

assert_file_exists() {
  [ -f "$1" ] && pass "File exists: ${1#$PROJECT_DIR/}" || fail "File missing: ${1#$PROJECT_DIR/}"
}

assert_dir_exists() {
  [ -d "$1" ] && pass "Dir exists: ${1#$PROJECT_DIR/}" || fail "Dir missing: ${1#$PROJECT_DIR/}"
}

assert_contains() {
  local file="$1" pattern="$2" label="$3"
  grep -qE "$pattern" "$file" 2>/dev/null && pass "$label" || fail "$label"
}

assert_not_contains() {
  local file="$1" pattern="$2" label="$3"
  grep -qE "$pattern" "$file" 2>/dev/null && fail "$label" || pass "$label"
}

assert_valid_json() {
  local file="$1"
  if python3 -c "import json,sys; json.load(open(sys.argv[1]))" "$file" 2>/dev/null || \
     python -c "import json,sys; json.load(open(sys.argv[1]))" "$file" 2>/dev/null; then
    pass "Valid JSON: ${file#$PROJECT_DIR/}"
  else
    fail "Invalid JSON: ${file#$PROJECT_DIR/}"
  fi
}

assert_frontmatter() {
  local file="$1"
  local name="${file#$PROJECT_DIR/}"
  if ! head -1 "$file" | grep -q '^---'; then
    fail "Missing frontmatter: $name"
    return
  fi
  local end_line
  end_line=$(tail -n +2 "$file" | grep -n '^---' | head -1 | cut -d: -f1)
  if [ -z "$end_line" ]; then
    fail "Unclosed frontmatter: $name"
    return
  fi
  pass "Valid frontmatter: $name"
}

assert_frontmatter_field() {
  local file="$1" field="$2"
  local name="${file#$PROJECT_DIR/}"
  # Extract frontmatter block
  local fm
  fm=$(sed -n '2,/^---$/p' "$file" | head -n -1)
  if echo "$fm" | grep -qE "^${field}:"; then
    pass "Has field '$field': $name"
  else
    fail "Missing field '$field': $name"
  fi
}

# Hook test helpers
assert_hook_blocks() {
  local script="$1"
  local label="${!#}"  # last argument
  # args = everything between $1 and last arg
  shift
  local args=""
  while [ $# -gt 1 ]; do
    args="$args $1"
    shift
  done
  local exit_code=0
  bash "$script" $args >/dev/null 2>/dev/null || exit_code=$?
  if [ "$exit_code" -eq 2 ]; then
    pass "$label"
  else
    fail "$label — expected exit 2 (deny), got exit $exit_code"
  fi
}

assert_hook_allows() {
  local script="$1"
  local label="${!#}"  # last argument
  shift
  local args=""
  while [ $# -gt 1 ]; do
    args="$args $1"
    shift
  done
  local exit_code=0
  bash "$script" $args >/dev/null 2>/dev/null || exit_code=$?
  if [ "$exit_code" -eq 0 ]; then
    pass "$label"
  else
    fail "$label — expected exit 0 (allow), got exit $exit_code"
  fi
}

# Temp file management
TEMP_FILES=()
make_temp() {
  local f
  f=$(mktemp /tmp/secops-test-XXXXXX)
  TEMP_FILES+=("$f")
  echo "$f"
}

cleanup_temps() {
  for f in "${TEMP_FILES[@]}"; do
    rm -f "$f" 2>/dev/null
  done
}

trap cleanup_temps EXIT
