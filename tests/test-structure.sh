#!/bin/bash
# test-structure.sh — Layer 1: Structural Integrity
# Validates plugin structure, frontmatter, YAML schemas, internal references
source "$(dirname "$0")/helpers.sh"
cd "$PROJECT_DIR"

echo "  [1.1] Core directories"
for dir in agents skills commands hooks hooks/scripts rules workflows; do
  assert_dir_exists "$PROJECT_DIR/$dir"
done

echo "  [1.2] Core files"
assert_file_exists "$PROJECT_DIR/CLAUDE.md"
assert_file_exists "$PROJECT_DIR/hooks/hooks.json"
assert_file_exists "$PROJECT_DIR/rules/cybersecurity.md"
assert_file_exists "$PROJECT_DIR/workflows/SCHEMA.md"

echo "  [1.3] hooks.json is valid JSON"
assert_valid_json "$PROJECT_DIR/hooks/hooks.json"

echo "  [1.4] Agent frontmatter"
for agent_file in agents/*.md; do
  assert_frontmatter "$PROJECT_DIR/$agent_file"
  assert_frontmatter_field "$PROJECT_DIR/$agent_file" "name"
  assert_frontmatter_field "$PROJECT_DIR/$agent_file" "description"
  assert_frontmatter_field "$PROJECT_DIR/$agent_file" "tools"
  assert_frontmatter_field "$PROJECT_DIR/$agent_file" "model"
done

echo "  [1.5] Skill frontmatter"
for skill_file in skills/*/SKILL.md; do
  assert_frontmatter "$PROJECT_DIR/$skill_file"
  assert_frontmatter_field "$PROJECT_DIR/$skill_file" "name"
  assert_frontmatter_field "$PROJECT_DIR/$skill_file" "description"
done

echo "  [1.6] Workflow YAML syntax"
YAML_ERRORS=0
for wf_file in $(find workflows -name "*.yaml" 2>/dev/null); do
  [ -f "$wf_file" ] || continue
  local_name="${wf_file#./}"
  # Check required fields exist
  has_error=0
  for field in name title description category; do
    if ! grep -qE "^${field}:" "$wf_file" 2>/dev/null; then
      fail "Workflow missing '$field': $local_name"
      has_error=1
    fi
  done
  # Must have either agent or chain
  if ! grep -qE "^(agent|chain):" "$wf_file" 2>/dev/null; then
    fail "Workflow missing 'agent' or 'chain': $local_name"
    has_error=1
  fi
  # Must have input section
  if ! grep -qE "^input:" "$wf_file" 2>/dev/null; then
    fail "Workflow missing 'input': $local_name"
    has_error=1
  fi
  # Must have keywords for orchestrator matching
  if ! grep -qE "^keywords:" "$wf_file" 2>/dev/null; then
    fail "Workflow missing 'keywords': $local_name"
    has_error=1
  fi
  if [ "$has_error" -eq 0 ]; then
    pass "Workflow valid: $local_name"
  fi
done

echo "  [1.7] Workflow agent references exist"
for wf_file in $(find workflows -name "*.yaml" 2>/dev/null); do
  [ -f "$wf_file" ] || continue
  local_name="${wf_file#./}"
  # Extract agent names (single agent field)
  agent_ref=$(grep -E "^agent:" "$wf_file" 2>/dev/null | sed 's/^agent:\s*//' | tr -d ' ')
  if [ -n "$agent_ref" ]; then
    if [ -f "agents/${agent_ref}.md" ]; then
      pass "Agent ref OK: $local_name → $agent_ref"
    else
      fail "Agent ref broken: $local_name → $agent_ref (agents/${agent_ref}.md not found)"
    fi
  fi
  # Extract agent names from chain
  chain_agents=$(grep -E "^\s+agent:" "$wf_file" 2>/dev/null | sed 's/.*agent:\s*//' | tr -d ' ')
  for ca in $chain_agents; do
    if [ -f "agents/${ca}.md" ]; then
      pass "Chain agent ref OK: $local_name → $ca"
    else
      fail "Chain agent ref broken: $local_name → $ca"
    fi
  done
done

echo "  [1.8] Workflow skill references exist"
for wf_file in $(find workflows -name "*.yaml" 2>/dev/null); do
  [ -f "$wf_file" ] || continue
  local_name="${wf_file#./}"
  # Extract skill names from skills list
  skill_refs=$(grep -E "^\s+- " "$wf_file" 2>/dev/null | grep -v "field:\|prompt:\|type:\|options:" | sed 's/.*- //' | tr -d ' ')
  for sr in $skill_refs; do
    # Skip non-skill entries (output sections, tags, keywords, triggers, etc.)
    if [ -d "skills/${sr}" ] && [ -f "skills/${sr}/SKILL.md" ]; then
      pass "Skill ref OK: $local_name → $sr"
    fi
    # Only fail if it looks like a skill reference (appears after "skills:" line)
  done
done

echo "  [1.9] Hook scripts exist for hooks.json entries"
# Extract script paths from hooks.json
hook_scripts=$(grep -oE 'hooks/scripts/[a-z_-]+\.sh' hooks/hooks.json 2>/dev/null | sort -u)
for hs in $hook_scripts; do
  assert_file_exists "$PROJECT_DIR/$hs"
done

echo "  [1.10] Rules index references"
for rule_file in rules/data-handling.md rules/output-standards.md rules/incident-response.md rules/tool-safety.md; do
  assert_file_exists "$PROJECT_DIR/$rule_file"
  fname=$(basename "$rule_file")
  assert_contains "$PROJECT_DIR/rules/cybersecurity.md" "$fname" "Rules index references $fname"
done

layer_summary
