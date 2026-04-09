#!/bin/bash
# test-security.sh — Layer 5: Plugin Security Self-Check
# Ensures the plugin itself doesn't violate its own security rules
source "$(dirname "$0")/helpers.sh"
cd "$PROJECT_DIR"

echo "  [5.1] No real secrets in codebase"

SECRET_PATTERNS=(
  'AKIA[0-9A-Z]{16}'
  'sk-[A-Za-z0-9]{20,}'
  'ghp_[A-Za-z0-9]{36}'
  'glpat-[A-Za-z0-9-]{20,}'
)

for pattern in "${SECRET_PATTERNS[@]}"; do
  matches=$(grep -rlE "$pattern" --include="*.md" --include="*.yaml" --include="*.sh" --include="*.json" . 2>/dev/null | grep -v "tests/" | grep -v "node_modules/" || true)
  if [ -z "$matches" ]; then
    pass "No matches for pattern: ${pattern:0:20}..."
  else
    # Check if matches are in example/documentation context
    real_secret=0
    for match_file in $matches; do
      # Allow patterns in hook scripts (they ARE the detection rules)
      case "$match_file" in
        ./hooks/scripts/*) continue ;;
      esac
      # Check if it's an example/placeholder
      if grep -E "$pattern" "$match_file" 2>/dev/null | grep -qiE 'example|placeholder|fake|test|REDACTED'; then
        continue
      fi
      real_secret=1
      fail "Potential real secret in: $match_file (pattern: ${pattern:0:20}...)"
    done
    if [ "$real_secret" -eq 0 ]; then
      pass "Pattern OK (only in examples/hooks): ${pattern:0:20}..."
    fi
  fi
done

echo "  [5.2] No .env files in codebase"

env_files=$(find . -name ".env" -o -name ".env.*" -o -name "*.env" 2>/dev/null | grep -v node_modules || true)
if [ -z "$env_files" ]; then
  pass "No .env files found"
else
  fail "Found .env files: $env_files"
fi

echo "  [5.3] No private keys in codebase"

key_files=$(find . -name "*.pem" -o -name "*.key" -o -name "*.p12" -o -name "*.pfx" 2>/dev/null | grep -v node_modules || true)
if [ -z "$key_files" ]; then
  pass "No private key files found"
else
  fail "Found key files: $key_files"
fi

pem_content=$(grep -rl "BEGIN.*PRIVATE KEY" --include="*.md" --include="*.yaml" --include="*.sh" . 2>/dev/null | grep -v "tests/" | grep -v "hooks/scripts/" || true)
if [ -z "$pem_content" ]; then
  pass "No PEM private key content in source files"
else
  fail "PEM private key content found in: $pem_content"
fi

echo "  [5.4] Hook scripts have no command injection vulnerabilities"

# Check for unquoted variable usage in dangerous positions
for script in hooks/scripts/*.sh; do
  script_name=$(basename "$script")
  # Check for eval usage (dangerous)
  if grep -qE '^\s*eval\s' "$script" 2>/dev/null; then
    fail "eval usage in $script_name — potential command injection"
  else
    pass "No eval in $script_name"
  fi
  # Check for unquoted $() used directly as a command (not in assignment, heredoc, or echo)
  # Only flag lines that START with $( — meaning the output is executed as a command
  # Exclude lines inside heredocs (between << and EOF) and $(if/echo patterns
  dangerous_lines=$(grep -nE '^\$\(' "$script" 2>/dev/null | grep -vE '\$\(if|\$\(echo|\$\(date|\$\(get_' || true)
  if [ -n "$dangerous_lines" ]; then
    fail "Command substitution executed directly in $script_name"
  else
    pass "Safe command substitution in $script_name"
  fi
done

echo "  [5.5] CYBEROPS_PROFILE=dev does not disable secrets detection"

# check-secrets.sh should NOT source profile-gate (it runs for all profiles)
if grep -q "profile-gate" hooks/scripts/check-secrets.sh 2>/dev/null; then
  fail "check-secrets.sh uses profile-gate — secrets check should ALWAYS run"
else
  pass "check-secrets.sh runs regardless of profile (always-on)"
fi

# block-no-verify.sh should NOT be skippable
if grep -q "profile-gate" hooks/scripts/block-no-verify.sh 2>/dev/null; then
  fail "block-no-verify.sh uses profile-gate — git protection should ALWAYS run"
else
  pass "block-no-verify.sh runs regardless of profile (always-on)"
fi

echo "  [5.6] No overly permissive file permissions"

PERM_ISSUES=0
for f in hooks/scripts/*.sh; do
  perms=$(stat -c '%a' "$f" 2>/dev/null || stat -f '%Lp' "$f" 2>/dev/null || echo "unknown")
  if [ "$perms" = "777" ] || [ "$perms" = "666" ]; then
    fail "Overly permissive: $f ($perms)"
    PERM_ISSUES=1
  fi
done
if [ "$PERM_ISSUES" -eq 0 ]; then
  pass "No overly permissive files in hooks/scripts/"
fi

echo "  [5.7] Rules files are complete"

# Every rules file should have actionable content (not just headers)
for rule_file in rules/data-handling.md rules/output-standards.md rules/incident-response.md rules/tool-safety.md; do
  if [ -f "$rule_file" ]; then
    line_count=$(wc -l < "$rule_file")
    if [ "$line_count" -gt 5 ]; then
      pass "Rules file has content: $(basename $rule_file) ($line_count lines)"
    else
      fail "Rules file too short: $(basename $rule_file) ($line_count lines)"
    fi
  fi
done

echo "  [5.8] CLAUDE.md does not contain secrets"

assert_not_contains "$PROJECT_DIR/CLAUDE.md" "AKIA[0-9A-Z]{16}|sk-[A-Za-z0-9]{20,}" \
  "CLAUDE.md has no API keys"
assert_not_contains "$PROJECT_DIR/CLAUDE.md" "password\s*=" \
  "CLAUDE.md has no passwords"

layer_summary
