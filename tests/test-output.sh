#!/bin/bash
# test-output.sh — Layer 3: Output Quality Validation
# Validates that agent definitions contain required output format sections,
# templates, and rules enforcement markers.
# NOTE: This tests the *definitions* not actual LLM output (which requires running the plugin).
source "$(dirname "$0")/helpers.sh"
cd "$PROJECT_DIR"

echo "  [3.1] Agents define output format sections"

# SOC analyst must have alert analysis template
assert_contains "agents/soc-analyst.md" "Alert Summary|Alert.*Report" \
  "soc-analyst has alert analysis template"
assert_contains "agents/soc-analyst.md" "MITRE ATT&CK" \
  "soc-analyst references MITRE ATT&CK"
assert_contains "agents/soc-analyst.md" "CRITICAL.*HIGH.*MEDIUM.*LOW" \
  "soc-analyst uses severity scale"

# Incident commander must reference incident phases
assert_contains "agents/incident-commander.md" "Contain|Containment" \
  "incident-commander has containment phase"

# Threat analyst must have IOC processing
assert_contains "agents/threat-analyst.md" "IOC Processing|IOC Enrichment" \
  "threat-analyst has IOC processing"
assert_contains "agents/threat-analyst.md" "VirusTotal|AbuseIPDB|Shodan" \
  "threat-analyst has enrichment sources"

# GRC advisor must have policy template
assert_contains "agents/grc-advisor.md" "Policy Template|Document Control" \
  "grc-advisor has policy template"

# CISO fintech must cover NHNN regulations
assert_contains "agents/ciso-fintech.md" "NHNN|Thông tư" \
  "ciso-fintech covers NHNN regulations"
assert_contains "agents/ciso-fintech.md" "PCI DSS" \
  "ciso-fintech covers PCI DSS"
assert_contains "agents/ciso-fintech.md" "board|Board|C-level" \
  "ciso-fintech covers board reporting"

# DevSecOps must cover K8s and CI/CD
assert_contains "agents/devsecops.md" "Kubernetes|K8s|k8s" \
  "devsecops covers Kubernetes"
assert_contains "agents/devsecops.md" "CI/CD|pipeline" \
  "devsecops covers CI/CD pipelines"
assert_contains "agents/devsecops.md" "RBAC" \
  "devsecops covers RBAC"

# Orchestrator must have routing logic
assert_contains "agents/orchestrator.md" "Routing Logic|routing" \
  "orchestrator has routing logic"
assert_contains "agents/orchestrator.md" "workflow" \
  "orchestrator references workflows"

echo "  [3.2] Skills have methodology content"

# Incident response skill
assert_contains "skills/incident-response/SKILL.md" "Preparation|Detection|Containment|Recovery" \
  "incident-response skill has IR phases"

# Compliance frameworks skill
assert_contains "skills/compliance-frameworks/SKILL.md" "ISO.*27001|ISO/IEC 27001" \
  "compliance-frameworks covers ISO 27001"
assert_contains "skills/compliance-frameworks/SKILL.md" "NIST CSF" \
  "compliance-frameworks covers NIST CSF"
assert_contains "skills/compliance-frameworks/SKILL.md" "Nghị định 13" \
  "compliance-frameworks covers NĐ 13/2023"

# Risk assessment skill
assert_contains "skills/risk-assessment/SKILL.md" "risk|Risk" \
  "risk-assessment skill has risk content"

echo "  [3.3] Rules enforce required elements"

# Data handling rules
assert_contains "rules/data-handling.md" "NEVER.*credential|NEVER.*secret" \
  "Rules ban real credentials"
assert_contains "rules/data-handling.md" "NEVER.*PII|NEVER.*CCCD" \
  "Rules ban real PII"
assert_contains "rules/data-handling.md" "Classification.*PUBLIC.*INTERNAL.*CONFIDENTIAL.*RESTRICTED" \
  "Rules require data classification"

# Output standards
assert_contains "rules/output-standards.md" "CRITICAL.*HIGH.*MEDIUM.*LOW" \
  "Rules require severity ratings"
assert_contains "rules/output-standards.md" "action.*owner.*priority.*deadline" \
  "Rules require recommendation fields"

# Incident response rules
assert_contains "rules/incident-response.md" "TLP" \
  "Rules require TLP marking"
assert_contains "rules/incident-response.md" "MITRE ATT&CK" \
  "Rules require MITRE mapping"

# Tool safety
assert_contains "rules/tool-safety.md" "authorization" \
  "Rules require authorization"

echo "  [3.4] Bilingual support"

# Check agents have Vietnamese content
for agent_file in agents/soc-analyst.md agents/grc-advisor.md agents/ciso-fintech.md; do
  if [ -f "$agent_file" ]; then
    assert_contains "$PROJECT_DIR/$agent_file" "tiếng Việt|Vietnamese|Việt Nam|song ngữ" \
      "$(basename $agent_file) has Vietnamese context"
  fi
done

echo "  [3.5] Workflow output sections defined"

for wf_file in $(find workflows -name "*.yaml" 2>/dev/null); do
  [ -f "$wf_file" ] || continue
  local_name="${wf_file#./}"
  if grep -qE "^output:" "$wf_file" && grep -qE "sections:" "$wf_file"; then
    pass "Output sections defined: $local_name"
  else
    fail "Missing output sections: $local_name"
  fi
done

layer_summary
