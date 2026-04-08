#!/bin/bash
# test-orchestration.sh — Layer 4: Orchestration Flow
# Validates that orchestrator routing logic, workflow templates, and
# the /secops:run command are consistent and complete.
# NOTE: Tests routing *definitions*, not actual LLM routing (which requires running the plugin).
source "$(dirname "$0")/helpers.sh"
cd "$PLUGIN_DIR"

echo "  [4.1] Orchestrator decision matrix covers all agents"

# Every non-orchestrator agent should appear in orchestrator's routing table
for agent_file in agents/*.md; do
  agent_name=$(grep -E "^name:" "$agent_file" | sed 's/^name:\s*//' | tr -d ' ')
  [ "$agent_name" = "orchestrator" ] && continue
  if grep -q "$agent_name" agents/orchestrator.md 2>/dev/null; then
    pass "Orchestrator routes to: $agent_name"
  else
    fail "Orchestrator missing route for: $agent_name"
  fi
done

echo "  [4.2] Workflow categories have at least one template"

for category in soc ir grc devsecops advisory awareness; do
  count=$(find "workflows/$category" -name "*.yaml" 2>/dev/null | wc -l)
  if [ "$count" -gt 0 ]; then
    pass "Category '$category' has $count workflow(s)"
  else
    fail "Category '$category' has no workflows"
  fi
done

echo "  [4.3] Workflow names are unique"

all_names=$(find workflows -name "*.yaml" -exec grep -h "^name:" {} \; 2>/dev/null | sed 's/^name:\s*//' | tr -d ' ' | sort)
unique_names=$(echo "$all_names" | sort -u)
total=$(echo "$all_names" | wc -l)
unique=$(echo "$unique_names" | wc -l)
if [ "$total" -eq "$unique" ]; then
  pass "All workflow names are unique ($total workflows)"
else
  dupes=$(echo "$all_names" | sort | uniq -d)
  fail "Duplicate workflow names found: $dupes"
fi

echo "  [4.4] All workflows have triggers for orchestrator matching"

for wf_file in $(find workflows -name "*.yaml" 2>/dev/null); do
  [ -f "$wf_file" ] || continue
  local_name="${wf_file#./}"
  if grep -qE "^triggers:" "$wf_file" 2>/dev/null; then
    pass "Has triggers: $local_name"
  else
    fail "Missing triggers: $local_name"
  fi
done

echo "  [4.5] Multi-agent chain workflows have output_key"

for wf_file in $(find workflows -name "*.yaml" 2>/dev/null); do
  [ -f "$wf_file" ] || continue
  local_name="${wf_file#./}"
  if grep -qE "^chain:" "$wf_file" 2>/dev/null; then
    chain_agents=$(grep -cE "^\s+- agent:" "$wf_file" 2>/dev/null)
    chain_keys=$(grep -cE "output_key:" "$wf_file" 2>/dev/null)
    if [ "$chain_agents" -eq "$chain_keys" ]; then
      pass "Chain has output_keys: $local_name ($chain_agents agents)"
    else
      fail "Chain missing output_keys: $local_name ($chain_agents agents, $chain_keys keys)"
    fi
  fi
done

echo "  [4.6] /secops:run command references orchestrator"

assert_contains "$PLUGIN_DIR/commands/run.md" "orchestrator" \
  "/secops:run references orchestrator agent"

echo "  [4.7] /secops:run workflow table matches custom workflows"

# Only check custom workflows (not defaults) against run.md
for wf_file in $(find workflows -name "*.yaml" -not -path "*/defaults/*" 2>/dev/null); do
  [ -f "$wf_file" ] || continue
  wf_name=$(grep -E "^name:" "$wf_file" | sed 's/^name:\s*//' | tr -d ' ')
  if grep -q "$wf_name" commands/run.md 2>/dev/null; then
    pass "run.md lists workflow: $wf_name"
  else
    fail "run.md missing workflow: $wf_name"
  fi
done

echo "  [4.8] Default workflows exist and have type: default"

default_count=0
for wf_file in $(find workflows/defaults -name "*.yaml" 2>/dev/null); do
  [ -f "$wf_file" ] || continue
  local_name="${wf_file#./}"
  default_count=$((default_count + 1))
  if grep -qE "^type:\s*default" "$wf_file" 2>/dev/null; then
    pass "Default workflow has type:default: $local_name"
  else
    fail "Default workflow missing type:default: $local_name"
  fi
done
if [ "$default_count" -gt 0 ]; then
  pass "Default workflows directory has $default_count workflows"
else
  fail "No default workflows found in workflows/defaults/"
fi

echo "  [4.9] Default workflow names end with -default"

for wf_file in $(find workflows/defaults -name "*.yaml" 2>/dev/null); do
  [ -f "$wf_file" ] || continue
  wf_name=$(grep -E "^name:" "$wf_file" | sed 's/^name:\s*//' | tr -d ' ')
  if echo "$wf_name" | grep -qE '\-default$'; then
    pass "Default naming convention: $wf_name"
  else
    fail "Default should end with -default: $wf_name"
  fi
done

echo "  [4.10] Default workflows have valid agent references"

for wf_file in $(find workflows/defaults -name "*.yaml" 2>/dev/null); do
  [ -f "$wf_file" ] || continue
  local_name="${wf_file#./}"
  agent_ref=$(grep -E "^agent:" "$wf_file" 2>/dev/null | sed 's/^agent:\s*//' | tr -d ' ')
  if [ -n "$agent_ref" ]; then
    if [ -f "agents/${agent_ref}.md" ]; then
      pass "Default agent ref OK: $local_name → $agent_ref"
    else
      fail "Default agent ref broken: $local_name → $agent_ref"
    fi
  fi
  chain_agents=$(grep -E "^\s+agent:" "$wf_file" 2>/dev/null | sed 's/.*agent:\s*//' | tr -d ' ')
  for ca in $chain_agents; do
    if [ -f "agents/${ca}.md" ]; then
      pass "Default chain ref OK: $local_name → $ca"
    else
      fail "Default chain ref broken: $local_name → $ca"
    fi
  done
done

echo "  [4.11] Legacy commands still exist (backward compatibility)"

for cmd in incident soc-triage threat-model gap-analysis vuln-report phishing-campaign policy-draft; do
  if [ -f "commands/${cmd}.md" ]; then
    pass "Legacy command exists: /secops:${cmd}"
  else
    fail "Legacy command missing: /secops:${cmd}"
  fi
done

layer_summary
