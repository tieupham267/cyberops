#!/bin/bash
# run-all.sh — SecOps plugin test runner
# Usage: bash tests/run-all.sh [layer...]
# Examples:
#   bash tests/run-all.sh          # Run all layers
#   bash tests/run-all.sh 1        # Run only layer 1
#   bash tests/run-all.sh 1 2 5    # Run layers 1, 2, and 5
# Compatible: Linux, macOS, Windows (Git Bash)

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$PROJECT_DIR"

# Colors
if [ -t 1 ]; then
  RED='\033[0;31m'
  GREEN='\033[0;32m'
  YELLOW='\033[1;33m'
  BLUE='\033[0;34m'
  BOLD='\033[1m'
  NC='\033[0m'
else
  RED='' GREEN='' YELLOW='' BLUE='' BOLD='' NC=''
fi

# Determine which layers to run
LAYERS_TO_RUN=("$@")
if [ ${#LAYERS_TO_RUN[@]} -eq 0 ]; then
  LAYERS_TO_RUN=(1 2 3 4 5)
fi

should_run() {
  for l in "${LAYERS_TO_RUN[@]}"; do
    [ "$l" = "$1" ] && return 0
  done
  return 1
}

echo ""
echo -e "${BLUE}${BOLD}═══════════════════════════════════════════════${NC}"
echo -e "${BLUE}${BOLD}  SecOps Plugin Test Suite${NC}"
echo -e "${BLUE}${BOLD}═══════════════════════════════════════════════${NC}"
echo ""

TOTAL_EXIT=0

LAYER_NAMES=(
  ""
  "Structural Integrity"
  "Hook Functionality"
  "Output Quality"
  "Orchestration Flow"
  "Plugin Security"
)

LAYER_SCRIPTS=(
  ""
  "test-structure.sh"
  "test-hooks.sh"
  "test-output.sh"
  "test-orchestration.sh"
  "test-security.sh"
)

for i in 1 2 3 4 5; do
  if should_run "$i"; then
    echo -e "${BLUE}${BOLD}Layer $i: ${LAYER_NAMES[$i]}${NC}"
    echo "─────────────────────────────────────────────"
    if bash "$SCRIPT_DIR/${LAYER_SCRIPTS[$i]}"; then
      true
    else
      TOTAL_EXIT=1
    fi
    echo ""
  fi
done

echo -e "${BLUE}${BOLD}═══════════════════════════════════════════════${NC}"
if [ "$TOTAL_EXIT" -eq 0 ]; then
  echo -e "  ${GREEN}${BOLD}All layers passed.${NC}"
else
  echo -e "  ${RED}${BOLD}Some tests failed. Review output above.${NC}"
fi
echo -e "${BLUE}${BOLD}═══════════════════════════════════════════════${NC}"

exit $TOTAL_EXIT
