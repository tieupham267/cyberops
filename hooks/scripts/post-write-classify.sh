#!/bin/bash
# post-write-classify.sh — Remind about data classification for sensitive content
# Hook: PostToolUse (Write|Edit)
# Compatible: Linux, macOS, Windows (Git Bash)

FILE_PATH="$1"
[ -z "$FILE_PATH" ] && exit 0

# Check for sensitive keywords (grep -E compatible)
SENSITIVE_KEYWORDS="password|credential|PII|personal data|SSN|CCCD|CMND|credit card|patient|medical|salary|financial|confidential|restricted|internal only|dữ liệu cá nhân|thông tin nhạy cảm|bí mật"

if grep -qEi "$SENSITIVE_KEYWORDS" "$FILE_PATH" 2>/dev/null; then
  # Check if file already has a classification header
  if ! head -5 "$FILE_PATH" | grep -qi "classification\|phân loại\|TLP:"; then
    echo "[DATA CLASSIFICATION REMINDER] File '$FILE_PATH' contains potentially sensitive content but has no classification header. Consider adding: Classification: [PUBLIC | INTERNAL | CONFIDENTIAL | RESTRICTED]"
  fi
fi

exit 0
