# SecOps Plugin

Claude Code plugin for cybersecurity teams. 12 agents, 8 skills, hybrid orchestration with workflow templates.
All content should support Vietnamese + English.

---

## Skills Routing Table

Khi làm việc với file trong các thư mục sau, tự động gắn skill/agent tương ứng:

| File Pattern | Agent | Skill(s) |
| --- | --- | --- |
| `*incident*`, `*alert*`, `*soc*` | `soc-analyst`, `incident-commander` | `incident-response` |
| `*compliance*`, `*audit*`, `*policy*`, `*iso*`, `*nist*` | `grc-advisor` | `compliance-frameworks` |
| `*risk*`, `*threat*`, `*vuln*` | `risk-assessor`, `threat-analyst` | `risk-assessment` |
| `*phishing*`, `*awareness*`, `*training*` | `awareness-designer` | — |
| `*threat-model*` | `threat-modeler` | — |
| `*cicd*`, `*pipeline*`, `*k8s*`, `*kubernetes*`, `*container*`, `*docker*` | `devsecops` | — |
| `*fintech*`, `*payment*`, `*banking*`, `*board*`, `*strategy*` | `ciso-fintech` | `compliance-frameworks`, `risk-assessment` |
| `*fraud*`, `*CTKM*`, `*promotion*`, `*chargeback*` | `fraud-analyst` | `payment-fraud` |
| `*ITSM*`, `*ITIL*`, `*service management*` | `grc-advisor` | `itsm-reference` |
| `context/company-profile.yaml` | — | Orchestrator reads automatically |

---

## Architecture

- **`agents/`** — 12 agent personas (Markdown with YAML frontmatter)
- **`skills/`** — 8 knowledge-base skills (each in `<name>/SKILL.md`)
- **`commands/`** — 14 slash commands. Unified entry point: `/secops:run`
- **`workflows/`** — YAML workflow templates. See `workflows/SCHEMA.md`
- **`hooks/`** — Event-driven hooks (PreToolUse, PostToolUse, Stop, UserPromptSubmit)
- **`rules/`** — Modular rule files. Index in `cybersecurity.md`
- **`context/`** — Company context templates

### Key Design Patterns

- **Hybrid Orchestration**: Template path (`/secops:run <workflow-name>`) or ad-hoc path (`/secops:run <natural language>`)
- **Bilingual content**: Vietnamese (primary) + English. Technical terms stay in English.
- **Framework alignment**: ISO 27001:2022, NIST CSF 2.0, CIS Controls v8, MITRE ATT&CK, Vietnamese regulations
- **Local-first regulations**: Reference `skills/vietnam-regulations/` BEFORE web search

### Data Resolution

`context/`, `workflows/`, `references/` read from `~/.claude/secops.yaml` paths or working directory:

```yaml
# ~/.claude/secops.yaml
context_dir: C:\SecOps-Data\context
workflows_dir: C:\SecOps-Data\workflows
references_dir: C:\SecOps-Data\references
```

### Rules Enforced

- Never include real credentials or PII — use placeholders
- Every finding must have severity (CRITICAL/HIGH/MEDIUM/LOW/INFO)
- Every recommendation must include action, owner, priority, deadline
- Map threats to MITRE ATT&CK
- Incident communications must include TLP marking
- Confirm scope and authorization before scanning/testing
