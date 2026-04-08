# SecOps Plugin Development

This is a Claude Code plugin for cybersecurity teams.
When editing agents, follow the frontmatter format (name, description, tools, model, memory).
When editing skills, ensure SKILL.md has proper YAML frontmatter.
When editing hooks, test with: `claude --plugin-dir .`
All content should support Vietnamese + English.

---

## Skills Routing Table

Khi làm việc với file trong các thư mục sau, tự động gắn skill/agent tương ứng:

| File Pattern | Agent | Skill(s) |
| --- | --- | --- |
| `agents/*.md` | — | Tuân thủ frontmatter format (name, description, tools, model, memory) |
| `skills/*/SKILL.md` | — | Tuân thủ YAML frontmatter (name, description) |
| `commands/*.md` | — | Trace chain: command → agent → skill(s) |
| `hooks/**` | — | Test với `claude --plugin-dir .` sau khi sửa |
| `*incident*`, `*alert*`, `*soc*` | `soc-analyst`, `incident-commander` | `incident-response` |
| `*compliance*`, `*audit*`, `*policy*`, `*iso*`, `*nist*` | `grc-advisor` | `compliance-frameworks` |
| `*risk*`, `*threat*`, `*vuln*` | `risk-assessor`, `threat-analyst` | `risk-assessment` |
| `*phishing*`, `*awareness*`, `*training*` | `awareness-designer` | — |
| `*threat-model*` | `threat-modeler` | — |
| `*cicd*`, `*pipeline*`, `*k8s*`, `*kubernetes*`, `*container*`, `*docker*` | `devsecops` | — |
| `*fintech*`, `*payment*`, `*banking*`, `*board*`, `*strategy*` | `ciso-fintech` | `compliance-frameworks`, `risk-assessment` |
| `*fraud*`, `*CTKM*`, `*khuyến mãi*`, `*promotion*`, `*chargeback*` | `fraud-analyst` | `payment-fraud` |
| `*ITSM*`, `*ITIL*`, `*service management*`, `*review chính sách*` | `grc-advisor` | `itsm-reference` |
| `context/company-profile.yaml` | — | Đọc tự động bởi orchestrator. Cập nhật khi tech stack thay đổi. |

---

## Detailed Reference

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

### Project Overview

This is **secops**, a Claude Code plugin that turns Claude into a cybersecurity team assistant. It is a plugin (not a standalone app) — there is no build system, test suite, or package manager. The codebase is entirely declarative Markdown and shell scripts.

### Architecture

The plugin follows the Claude Code plugin specification (`plugin.json` at root):

- **`agents/`** — 12 agent personas (Markdown with YAML frontmatter): `soc-analyst`, `incident-commander`, `threat-analyst`, `threat-modeler`, `risk-assessor`, `vuln-manager`, `grc-advisor`, `awareness-designer`, `ciso-fintech`, `devsecops`, `fraud-analyst`, `orchestrator`.
- **`workflows/`** — YAML workflow templates organized by category. **Đọc từ base directory** (`$SECOPS_HOME` hoặc working directory). Khi cài global, `/secops:setup-profile` copy defaults và tạo folder structure. Orchestrator reads these for deterministic execution. See `workflows/SCHEMA.md` for format.
- **`skills/`** — 8 knowledge-base skills that agents reference for detailed methodology (each in `<name>/SKILL.md`): `incident-response`, `compliance-frameworks`, `risk-assessment`, `vietnam-regulations`, `payment-fraud`, `itsm-reference`, `document-drafting`, `security-maturity`.
- **`context/`** — Company context. **Đọc từ base directory** (`$SECOPS_HOME` nếu set, hoặc working directory). KHÔNG từ plugin directory. `/secops:setup-profile` tự tạo structure.
  - `company-profile.yaml` — tech stack, security tools, org mapping, escalation matrix. All agents read automatically.
  - `org-docs/` — raw org documents (org chart, asset lists, team info). `/secops:setup-profile` reads and populates profile.
  - `process-docs/` — SOPs, playbooks, runbooks. `/secops:generate-workflows` reads and creates workflow YAMLs.
- **`commands/`** — Slash commands. Legacy per-workflow commands still work. New unified entry point: `/secops:run`.
- **`hooks/`** — `hooks.json` defines event-driven hooks (PreToolUse, PostToolUse, Stop, UserPromptSubmit). Shell scripts in `hooks/scripts/` implement them.
- **`rules/`** — Modular rule files: `data-handling.md`, `output-standards.md`, `incident-response.md`, `tool-safety.md`. Index in `cybersecurity.md`.
- **`.claude-plugin/`** — Marketplace and plugin registry metadata.

### Key Design Patterns

- **Hybrid Orchestration**: Two execution paths:
  1. **Template path** (deterministic): `/secops:run <workflow-name>` → orchestrator reads YAML template → executes agent(s) with predefined inputs/outputs
  2. **Ad-hoc path** (flexible): `/secops:run <natural language>` → orchestrator matches intent → routes to agent(s) dynamically
- **Workflow Templates**: YAML files in `workflows/` define reusable workflows with `agent`, `chain` (multi-agent), `input`, `output`, `keywords`, and `triggers`. See `workflows/SCHEMA.md`.
- **Agent-Skill-Command chain**: Legacy commands still work. Trace the chain: command → agent → skill(s).
- **Bilingual content**: All user-facing content supports Vietnamese (primary for internal reports) and English. Technical terms (MITRE ATT&CK IDs, CVE IDs, CVSS) stay in English.
- **Framework alignment**: Content aligns to ISO 27001:2022, NIST CSF 2.0, CIS Controls v8, MITRE ATT&CK, and Vietnamese regulations (Luật An ninh mạng 2018, Nghị định 13/2023/NĐ-CP, Nghị định 85/2016/NĐ-CP).
- **Local-first regulations**: Vietnamese regulations are stored in `skills/vietnam-regulations/`. Always reference local files BEFORE web search. Only search web when information is not found locally or needs verification for updates.

### Hooks Behavior

Hooks auto-execute during Claude Code sessions (controlled by `SECOPS_PROFILE`):

- **`check-secrets.sh`** (PreToolUse on Write/Edit) — blocks output containing AWS keys, API keys, passwords, private keys, DB connection strings. Skips binary files.
- **`pre-commit-security.sh`** (PreToolUse on git commit) — scans staged files for secrets, private keys, .env files, and overly permissive permissions (777/666).
- **`block-no-verify.sh`** (PreToolUse on git\*) — blocks `--no-verify`, `--no-gpg-sign`, and force push to main/master.
- **`post-write-classify.sh`** (PostToolUse on Write/Edit) — reminds about data classification headers when sensitive keywords are detected.
- **`session-summary.sh`** (Stop) — writes audit log to `~/.cybersec-audit-logs/`.
- **`batch-security-check.sh`** (Stop) — batch scans all modified files for secrets, classification headers, and permissions.
- **`profile-gate.sh`** — shared utility sourced by other hooks to check `SECOPS_PROFILE` level.

### Rules Enforced (Always Active)

From `rules/cybersecurity.md`:
- Never include real credentials or PII — use placeholders (`[REDACTED]`, fake data).
- Every security finding must have a severity rating (CRITICAL/HIGH/MEDIUM/LOW/INFO).
- Every recommendation must include action, owner, priority, and deadline.
- Map threats to MITRE ATT&CK. Check Vietnamese regulatory implications for personal data and cybersecurity incidents.
- Incident communications must include TLP marking (RED/AMBER/GREEN/WHITE).
- Confirm scope and authorization before running any scanning/testing commands.

### Installation & Setup

Xem [GETTING-STARTED.md](GETTING-STARTED.md) cho hướng dẫn đầy đủ (cài đặt → setup profile → setup workflows → verify).

Quick start:

```bash
claude --plugin-dir ./secops
```

### Adding New Components

- **New workflow** (preferred): Create `workflows/<category>/<name>.yaml` following `workflows/SCHEMA.md`. Orchestrator auto-discovers it.
- **New agent**: Create `agents/<name>.md` with YAML frontmatter defining role, capabilities, and output format. Update orchestrator's decision matrix if needed.
- **New command**: Create `commands/<name>.md` — only for direct entry points. For workflows, use YAML templates instead.
- **New skill**: Create `skills/<name>/SKILL.md` with detailed methodology content.
- **New hook**: Add entry to `hooks/hooks.json` with matcher pattern, then implement in `hooks/scripts/`.
- **New rule**: Create `rules/<domain>.md` and add reference in `rules/cybersecurity.md` index.

### Skills: Curated vs Custom

- **Curated skills** (in-repo `skills/`): Shipped with plugin, maintained by team. These are the official methodologies.
- **Custom skills** (user's `~/.claude/skills/`): Team members can add personal/org-specific skills without modifying the plugin. These override curated skills if names conflict.

When adding skills, decide: is this broadly useful (curated) or org-specific (custom)?

### Environment Variables

| Variable | Purpose | Values |
| --- | --- | --- |
| `SECOPS_HOME` | Base directory cho `context/` và `workflows/` | Path (default: working directory) |
| `SECOPS_PROFILE` | Hook strictness level | `dev` / `standard` (default) / `strict` |

**`SECOPS_HOME`** — Cho phép dùng chung 1 bộ context/workflows cho nhiều projects. Khi set, tất cả agents đọc/ghi `context/` và `workflows/` từ `$SECOPS_HOME/` thay vì working directory.

**`SECOPS_PROFILE`** — Control hook strictness:

| Profile | Behavior | Use case |
| --- | --- | --- |
| `dev` | Only critical checks (secrets detection) | Local development, rapid iteration |
| `standard` | All checks (default) | Normal usage |
| `strict` | All checks + block on warnings | Production environments, audits |

```bash
# Example: custom data dir + dev mode
SECOPS_HOME=~/secops-data SECOPS_PROFILE=dev claude

# Example: strict mode for audit preparation
SECOPS_PROFILE=strict claude --plugin-dir .
```

### Testing

Run the test suite to validate plugin integrity:

```bash
bash tests/run-all.sh          # All 5 layers
bash tests/run-all.sh 1        # Layer 1 only (structural)
bash tests/run-all.sh 1 2 5    # Specific layers
```

5 test layers:
1. **Structural Integrity** — plugin structure, frontmatter, YAML schemas, internal references
2. **Hook Functionality** — each hook script with known inputs (block/allow)
3. **Output Quality** — agent definitions contain required sections, rules, bilingual support
4. **Orchestration Flow** — routing coverage, workflow uniqueness, chain consistency, backward compatibility
5. **Plugin Security** — no secrets in codebase, no command injection, profile safety

Always run tests after adding/modifying agents, workflows, hooks, or rules.

### Distribution Notes

- Rules files (`rules/`) are NOT auto-distributed when installing as a plugin — users must copy them manually or install via `--plugin-dir`.
- When distributing, document required environment variables (`SECOPS_PROFILE`) and external dependencies.
- Hook scripts require `bash` and standard Unix tools (`grep`, `stat`, `git`). On Windows, ensure Git Bash or WSL is available.
