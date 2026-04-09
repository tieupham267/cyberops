#!/bin/bash
# test-hooks.sh — Layer 2: Hook Functionality
# Tests each hook script with known inputs
source "$(dirname "$0")/helpers.sh"
cd "$PROJECT_DIR"

# ── check-secrets.sh ──────────────────────────────

echo "  [2.1] check-secrets.sh — detect patterns"

# AWS key (use realistic-looking key, not the AWS doc example which contains "EXAMPLE")
f=$(make_temp)
echo 'aws_key = "AKIAI44QH8DHBG5RVMZQ"' > "$f"
assert_hook_blocks "hooks/scripts/check-secrets.sh" "$f" "Detect AWS access key"

# Hardcoded password
f=$(make_temp)
echo 'password = "SuperSecret123!"' > "$f"
assert_hook_blocks "hooks/scripts/check-secrets.sh" "$f" "Detect hardcoded password"

# PEM private key
f=$(make_temp)
echo '-----BEGIN RSA PRIVATE KEY-----' > "$f"
assert_hook_blocks "hooks/scripts/check-secrets.sh" "$f" "Detect PEM private key"

# Database connection string
f=$(make_temp)
echo 'db_url = "postgres://admin:pass123@localhost/mydb"' > "$f"
assert_hook_blocks "hooks/scripts/check-secrets.sh" "$f" "Detect DB connection string"

# OpenAI/Anthropic key pattern
f=$(make_temp)
echo 'api_key = "sk-abcdefghijklmnopqrstuvwxyz123456"' > "$f"
assert_hook_blocks "hooks/scripts/check-secrets.sh" "$f" "Detect sk- API key"

# GitHub PAT
f=$(make_temp)
echo 'token = "ghp_ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghij"' > "$f"
assert_hook_blocks "hooks/scripts/check-secrets.sh" "$f" "Detect GitHub PAT"

echo "  [2.2] check-secrets.sh — allow clean files"

f=$(make_temp)
echo 'This is a clean file with no secrets.' > "$f"
assert_hook_allows "hooks/scripts/check-secrets.sh" "$f" "Allow clean text file"

f=$(make_temp)
echo 'password = "[REDACTED]"' > "$f"
assert_hook_allows "hooks/scripts/check-secrets.sh" "$f" "Allow redacted placeholder"

# Empty path
assert_hook_allows "hooks/scripts/check-secrets.sh" "" "Allow empty file path"

# Binary file extension
assert_hook_allows "hooks/scripts/check-secrets.sh" "image.png" "Skip binary files (.png)"

# ── block-no-verify.sh ────────────────────────────

echo "  [2.3] block-no-verify.sh — block dangerous flags"

assert_hook_blocks "hooks/scripts/block-no-verify.sh" "git commit --no-verify -m test" \
  "Block --no-verify"

assert_hook_blocks "hooks/scripts/block-no-verify.sh" "git commit --no-gpg-sign -m test" \
  "Block --no-gpg-sign"

assert_hook_blocks "hooks/scripts/block-no-verify.sh" "git push --force origin main" \
  "Block force push to main"

assert_hook_blocks "hooks/scripts/block-no-verify.sh" "git push -f origin master" \
  "Block -f push to master"

echo "  [2.4] block-no-verify.sh — allow normal commands"

assert_hook_allows "hooks/scripts/block-no-verify.sh" "git commit -m normal commit" \
  "Allow normal commit"

assert_hook_allows "hooks/scripts/block-no-verify.sh" "git push origin feature-branch" \
  "Allow push to feature branch"

assert_hook_allows "hooks/scripts/block-no-verify.sh" "git status" \
  "Allow git status"

# ── post-write-classify.sh ────────────────────────

echo "  [2.5] post-write-classify.sh — remind classification"

f=$(make_temp)
echo 'This file contains PII and credential data for processing.' > "$f"
output=$(bash hooks/scripts/post-write-classify.sh "$f" 2>/dev/null) || true
if echo "$output" | grep -qi "CLASSIFICATION REMINDER"; then
  pass "Remind classification for sensitive file"
else
  fail "Should remind classification for sensitive file"
fi

echo "  [2.6] post-write-classify.sh — skip classified files"

f=$(make_temp)
printf 'Classification: CONFIDENTIAL\n\nThis file contains PII data.' > "$f"
output=$(bash hooks/scripts/post-write-classify.sh "$f" 2>/dev/null) || true
if [ -z "$output" ]; then
  pass "Skip already-classified file"
else
  fail "Should skip file with classification header"
fi

# ── profile-gate.sh ───────────────────────────────

echo "  [2.7] profile-gate.sh — profile levels"

# dev profile should set CYBEROPS_GATE_SKIP=1 for standard-level hooks
dev_skip=$(CYBEROPS_PROFILE=dev bash -c 'cd "'"$PROJECT_DIR"'" && source hooks/scripts/profile-gate.sh "test" "standard"; echo $CYBEROPS_GATE_SKIP' 2>/dev/null) || true
if [ "$dev_skip" = "1" ]; then
  pass "Dev profile sets GATE_SKIP=1 for standard-level hook"
else
  fail "Dev profile should set GATE_SKIP=1 for standard-level hook (got: $dev_skip)"
fi

# strict profile should set CYBEROPS_GATE_SKIP=0 for standard-level hooks
strict_skip=$(CYBEROPS_PROFILE=strict bash -c 'cd "'"$PROJECT_DIR"'" && source hooks/scripts/profile-gate.sh "test" "standard"; echo $CYBEROPS_GATE_SKIP' 2>/dev/null) || true
if [ "$strict_skip" = "0" ]; then
  pass "Strict profile sets GATE_SKIP=0 for standard-level hook"
else
  fail "Strict profile should set GATE_SKIP=0 (got: $strict_skip)"
fi

# dev profile should NOT skip dev-level hooks (critical checks)
dev_critical=$(CYBEROPS_PROFILE=dev bash -c 'cd "'"$PROJECT_DIR"'" && source hooks/scripts/profile-gate.sh "test" "dev"; echo $CYBEROPS_GATE_SKIP' 2>/dev/null) || true
if [ "$dev_critical" = "0" ]; then
  pass "Dev profile runs dev-level hooks (critical checks)"
else
  fail "Dev profile should run dev-level hooks (got: $dev_critical)"
fi

layer_summary
