#!/bin/bash
# block-no-verify.sh — Block git commands that bypass security hooks
# Hook: PreToolUse (Bash: git*)
# Security plugin MUST NOT allow bypassing pre-commit checks
# Compatible: Linux, macOS, Windows (Git Bash)
# Exit codes: 0 = allow, 2 = deny (reason to stderr)

COMMAND="$*"

# Check for --no-verify flag in git commands
if echo "$COMMAND" | grep -qiE '\-\-no-verify'; then
  echo "[SECURITY] Flag --no-verify bị chặn. Security plugin không cho phép bypass pre-commit hooks. Hãy sửa lỗi thay vì bỏ qua kiểm tra bảo mật." >&2
  exit 2
fi

# Check for --no-gpg-sign that might bypass signing requirements
if echo "$COMMAND" | grep -qiE '\-\-no-gpg-sign'; then
  echo "[SECURITY] Flag --no-gpg-sign bị chặn. Commit signing là yêu cầu bảo mật bắt buộc." >&2
  exit 2
fi

# Check for force push to main/master
if echo "$COMMAND" | grep -qiE '(\-\-force|\-f)' && echo "$COMMAND" | grep -qiE '(main|master)'; then
  echo "[SECURITY] Force push lên main/master bị chặn. Đây là hành động nguy hiểm có thể ghi đè lịch sử commit của team." >&2
  exit 2
fi

exit 0
