#!/bin/bash
# batch-security-check.sh — Batch security scan all modified files at session end
# Hook: Stop
# Compatible: Linux, macOS, Windows (Git Bash)

# Respect profile — skip in dev mode
source "$(dirname "$0")/profile-gate.sh" "batch-security-check" "standard" 2>/dev/null
[ "$CYBEROPS_GATE_SKIP" = "1" ] && exit 0

LOG_DIR="${HOME}/.cybersec-audit-logs"
mkdir -p "$LOG_DIR"
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
REPORT_FILE="${LOG_DIR}/batch-check_${TIMESTAMP}.log"

# Get all files modified in this session (unstaged + staged changes)
MODIFIED_FILES=$(git diff --name-only 2>/dev/null; git diff --cached --name-only 2>/dev/null)
MODIFIED_FILES=$(echo "$MODIFIED_FILES" | sort -u)

if [ -z "$MODIFIED_FILES" ]; then
  exit 0
fi

ISSUES=""
FILES_CHECKED=0
FILES_WITH_ISSUES=0

for file in $MODIFIED_FILES; do
  [ ! -f "$file" ] && continue
  FILES_CHECKED=$((FILES_CHECKED + 1))

  FILE_ISSUES=""

  # 1. Check for missing classification header on sensitive files (grep -E)
  if grep -qEi 'password|credential|PII|personal data|CCCD|confidential|restricted|dữ liệu cá nhân|thông tin nhạy cảm' "$file" 2>/dev/null; then
    if ! head -5 "$file" | grep -qi "classification\|phân loại\|TLP:"; then
      FILE_ISSUES="${FILE_ISSUES}  [CLASSIFY] Missing classification header\n"
    fi
  fi

  # 2. Check for secrets patterns (grep -E)
  if grep -qEi 'AKIA[0-9A-Z]{16}|BEGIN.*PRIVATE KEY|sk-[A-Za-z0-9]{20,}|ghp_[A-Za-z0-9]{36}' "$file" 2>/dev/null; then
    FILE_ISSUES="${FILE_ISSUES}  [SECRET] Potential secret/key detected\n"
  fi

  # 3. Check for overly permissive permissions (cross-platform)
  PERMS=$(stat -c '%a' "$file" 2>/dev/null || stat -f '%Lp' "$file" 2>/dev/null)
  if [ "$PERMS" = "777" ] || [ "$PERMS" = "666" ]; then
    FILE_ISSUES="${FILE_ISSUES}  [PERMS] Overly permissive: ${PERMS}\n"
  fi

  if [ -n "$FILE_ISSUES" ]; then
    FILES_WITH_ISSUES=$((FILES_WITH_ISSUES + 1))
    ISSUES="${ISSUES}${file}:\n${FILE_ISSUES}\n"
  fi
done

# Write batch report
cat > "$REPORT_FILE" << EOF
=== Batch Security Check Report ===
Timestamp: $(date +"%Y-%m-%dT%H:%M:%S%z")
Profile: ${CYBEROPS_PROFILE:-standard}
Files checked: ${FILES_CHECKED}
Files with issues: ${FILES_WITH_ISSUES}

$(if [ -n "$ISSUES" ]; then echo -e "Issues found:\n${ISSUES}"; else echo "No issues found."; fi)
===
EOF

# Output summary if issues found
if [ -n "$ISSUES" ]; then
  echo "[BATCH SECURITY CHECK] ${FILES_WITH_ISSUES}/${FILES_CHECKED} files có vấn đề bảo mật. Chi tiết: ${REPORT_FILE}"
fi

exit 0
