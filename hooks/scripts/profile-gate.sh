#!/bin/bash
# profile-gate.sh — Check CYBEROPS_PROFILE to skip hooks in dev mode
# Usage: source this at the top of any hook script, then check CYBEROPS_GATE_SKIP
#
# Example:
#   source "$(dirname "$0")/profile-gate.sh" "batch-security-check" "standard"
#   [ "$CYBEROPS_GATE_SKIP" = "1" ] && exit 0
#
# Profiles: dev | standard (default) | strict
#   dev:      Only critical checks (secrets detection)
#   standard: All checks (default behavior)
#   strict:   All checks + block on warnings (not just errors)

CYBEROPS_PROFILE="${CYBEROPS_PROFILE:-standard}"
CYBEROPS_GATE_SKIP="0"

HOOK_NAME="${1:-unknown}"
HOOK_LEVEL="${2:-standard}"  # minimum profile level for this hook

# Profile hierarchy: dev < standard < strict
get_level() {
  case "$1" in
    dev)      echo 1 ;;
    standard) echo 2 ;;
    strict)   echo 3 ;;
    *)        echo 2 ;;
  esac
}

CURRENT=$(get_level "$CYBEROPS_PROFILE")
REQUIRED=$(get_level "$HOOK_LEVEL")

if [ "$CURRENT" -lt "$REQUIRED" ]; then
  CYBEROPS_GATE_SKIP="1"
fi
