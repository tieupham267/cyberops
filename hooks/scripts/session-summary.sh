#!/bin/bash
# session-summary.sh — Log session summary for audit trail
# Hook: Stop
# Compatible: Linux, macOS, Windows (Git Bash)

LOG_DIR="${HOME}/.cybersec-audit-logs"
mkdir -p "$LOG_DIR"

TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
LOG_FILE="${LOG_DIR}/session_${TIMESTAMP}.log"

cat > "$LOG_FILE" << EOF
=== Cybersec Claude Code Session Log ===
Timestamp: $(date +"%Y-%m-%dT%H:%M:%S%z")
Working Directory: $(pwd)
User: $(whoami)
Git Branch: $(git branch --show-current 2>/dev/null || echo "N/A")
Last Commit: $(git log --oneline -1 2>/dev/null || echo "N/A")
Files Modified This Session: $(git diff --name-only 2>/dev/null | head -20)
===
EOF

exit 0
