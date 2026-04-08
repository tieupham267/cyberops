#!/bin/bash
# check-secrets.sh — Block file writes containing potential secrets
# Hook: PreToolUse (Write|Edit)
# Compatible: Linux, macOS, Windows (Git Bash)
# Exit codes: 0 = allow, 2 = deny (reason to stderr)

FILE_PATH="$1"

if [ -z "$FILE_PATH" ]; then
  exit 0
fi

# Skip non-text files
case "$FILE_PATH" in
  *.png|*.jpg|*.gif|*.pdf|*.zip|*.exe|*.bin)
    exit 0
    ;;
esac

# Patterns that indicate hardcoded secrets (grep -E compatible)
PATTERNS=(
  'AKIA[0-9A-Z]{16}'                                  # AWS Access Key
  'password[[:space:]]*[:=][[:space:]]*["\x27][^"\x27]{8,}'  # Hardcoded password
  'api[_-]?key[[:space:]]*[:=][[:space:]]*["\x27][^"\x27]{8,}'  # API key
  'secret[_-]?key[[:space:]]*[:=][[:space:]]*["\x27][^"\x27]+' # Secret key
  'token[[:space:]]*[:=][[:space:]]*["\x27][A-Za-z0-9+/=]{20,}' # Token
  'private[_-]?key[[:space:]]*[:=]'                    # Private key
  'BEGIN (RSA |EC |DSA )?PRIVATE KEY'                  # PEM private key
  'mysql://[^:]+:[^@]+@'                               # DB connection string
  'postgres://[^:]+:[^@]+@'                            # PostgreSQL connection
  'mongodb\+srv://[^:]+:[^@]+@'                        # MongoDB connection
  'sk-[A-Za-z0-9]{20,}'                               # OpenAI/Anthropic API key
  'ghp_[A-Za-z0-9]{36}'                               # GitHub PAT
  'glpat-[A-Za-z0-9-]{20,}'                           # GitLab PAT
)

FOUND=""
for pattern in "${PATTERNS[@]}"; do
  if grep -qEi "$pattern" "$FILE_PATH" 2>/dev/null; then
    # Filter out known placeholders/redacted values
    REAL_MATCHES=$(grep -En "$pattern" "$FILE_PATH" 2>/dev/null | grep -viE '\[REDACTED\]|EXAMPLE|placeholder|fake|<[A-Z_]+>|\$\{[A-Z_]+\}' | head -3)
    if [ -n "$REAL_MATCHES" ]; then
      FOUND="${FOUND}\n  Pattern: ${pattern}\n  Match: ${REAL_MATCHES}\n"
    fi
  fi
done

if [ -n "$FOUND" ]; then
  echo -e "[SECURITY] Potential secrets/credentials detected. Use environment variables or a secrets manager instead.\nFindings:${FOUND}" >&2
  exit 2
fi

exit 0
