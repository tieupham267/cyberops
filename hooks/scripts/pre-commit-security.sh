#!/bin/bash
# pre-commit-security.sh — Security checks before git commit
# Hook: PreToolUse (Bash: git commit*)
# Compatible: Linux, macOS, Windows (Git Bash)
# Exit codes: 0 = allow, 2 = deny (reason to stderr)

ISSUES=""

# 1. Check staged files for secrets
STAGED_FILES=$(git diff --cached --name-only 2>/dev/null)
if [ -n "$STAGED_FILES" ]; then
  for file in $STAGED_FILES; do
    if [ -f "$file" ]; then
      # Check for common secret patterns (grep -E compatible)
      if grep -qEi '(password|api_key|secret_key|access_key|private_key)[[:space:]]*[:=][[:space:]]*["\x27][^"\x27]{8,}' "$file" 2>/dev/null; then
        ISSUES="${ISSUES}[SECRET] Potential hardcoded secret in: ${file}\n"
      fi
      # Check for PEM keys
      if grep -q 'BEGIN.*PRIVATE KEY' "$file" 2>/dev/null; then
        ISSUES="${ISSUES}[SECRET] Private key detected in: ${file}\n"
      fi
    fi
  done
fi

# 2. Check for .env files being committed
if echo "$STAGED_FILES" | grep -qE '\.env($|\.)'; then
  ISSUES="${ISSUES}[CONFIG] .env file staged for commit — should be in .gitignore\n"
fi

# 3. Check for overly permissive file permissions
for file in $STAGED_FILES; do
  if [ -f "$file" ]; then
    # Cross-platform: try GNU stat first, then BSD stat
    PERMS=$(stat -c '%a' "$file" 2>/dev/null || stat -f '%Lp' "$file" 2>/dev/null)
    if [ "$PERMS" = "777" ] || [ "$PERMS" = "666" ]; then
      ISSUES="${ISSUES}[PERMS] Overly permissive file: ${file} (${PERMS})\n"
    fi
  fi
done

if [ -n "$ISSUES" ]; then
  echo -e "[PRE-COMMIT SECURITY CHECK FAILED]\n${ISSUES}\nFix these issues before committing." >&2
  exit 2
fi

exit 0
