# CyberOps Plugin Development

Claude Code plugin for cybersecurity teams. All user-facing content is bilingual (Vietnamese primary, English for technical terms).

Development rules:

- Agents: follow YAML frontmatter format (name, description, tools, model, memory)
- Skills: ensure `SKILL.md` has proper YAML frontmatter (name, description)
- Hooks: test with `claude --plugin-dir .` after changes
- Workflows: follow `workflows/SCHEMA.md` format

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
| `*use-case*`, `*detection*`, `*rule*` | `soc-analyst` | Workflow `use-case-design` |
| `*process risk*`, `*quy trình*`, `*SoD*`, `*segregation*`, `*internal control*` | `risk-assessor`, `fraud-analyst` | Workflow `business-process-risk` |
| `*solution*`, `*compare*`, `*so sánh*`, `*vendor*`, `*evaluation*` | `ciso-fintech` | Workflow `solution-comparison` |
| `context/company-profile.yaml` | — | Đọc tự động bởi orchestrator. Cập nhật khi tech stack thay đổi. |

---

## Detailed Reference

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

### Project Overview

This is **cyberops**, a Claude Code plugin that turns Claude into a cybersecurity team assistant. It is a plugin (not a standalone app) — there is no build system, test suite, or package manager. The codebase is entirely declarative Markdown and shell scripts.

### Architecture

The plugin follows the Claude Code plugin specification (`.claude-plugin/plugin.json`):

- **`agents/`** — 12 agent personas (Markdown with YAML frontmatter): `soc-analyst`, `incident-commander`, `threat-analyst`, `threat-modeler`, `risk-assessor`, `vuln-manager`, `grc-advisor`, `awareness-designer`, `ciso-fintech`, `devsecops`, `fraud-analyst`, `orchestrator`.
- **`workflows/`** — YAML workflow templates organized by category (`ir`, `soc`, `grc`, `fraud`, `devsecops`, `advisory`, `awareness`, `defaults`). **Đọc từ `~/.claude/cyberops.yaml` paths hoặc working directory**. Khi cài global, `/cyberops:setup-profile` copy defaults và tạo folder structure. Orchestrator reads these for deterministic execution. See `workflows/SCHEMA.md` for format.
- **`skills/`** — 9 knowledge-base skills that agents reference for detailed methodology (each in `<name>/SKILL.md`): `incident-response`, `compliance-frameworks`, `risk-assessment`, `vietnam-regulations`, `payment-fraud`, `itsm-reference`, `document-drafting`, `document-organization`, `security-maturity`.
- **`context/`** — Company context. **Đọc từ `~/.claude/cyberops.yaml` paths hoặc working directory**. KHÔNG từ plugin directory. `/cyberops:setup-profile` tự tạo structure.
  - `company-profile.yaml` — tech stack, security tools, org mapping, escalation matrix. All agents read automatically.
  - Tài liệu nguồn (org chart, SOPs, playbooks...) được đọc tại chỗ qua `cyberops.yaml` mapping — KHÔNG copy vào context/.
- **`references/`** — User-managed reference documents. **Đọc từ `~/.claude/cyberops.yaml` paths hoặc working directory**. Bổ sung/override nội dung trong `skills/`. Agents đọc `skills/` trước, rồi `references/` sau.
  - `regulations/` — luật, nghị định, thông tư bổ sung hoặc cập nhật mới hơn bundled skills.
  - `standards/` — ISO, PCI, NIST controls bổ sung.
  - `policies/` — ISMS, chính sách nội bộ công ty (không có trong skills/).

> **Document Mapping**: Plugin KHÔNG bắt buộc cấu trúc folder cứng. `/cyberops:setup-profile` scan folders tài liệu hiện có của user, tự phân loại, và lưu mapping vào `~/.claude/cyberops.yaml`. Agents đọc files theo mapping, không theo folder structure. Xem chi tiết trong [commands/setup-profile.md](commands/setup-profile.md).
- **`commands/`** — Slash commands. Legacy per-workflow commands still work. New unified entry point: `/cyberops:run`.
- **`hooks/`** — `hooks.json` defines event-driven hooks (PreToolUse, PostToolUse, Stop, UserPromptSubmit). Shell scripts in `hooks/scripts/` implement them.
- **`rules/`** — Modular rule files: `data-handling.md`, `output-standards.md`, `incident-response.md`, `tool-safety.md`. Index in `cybersecurity.md`.
- **`.claude-plugin/`** — Marketplace and plugin registry metadata (`plugin.json`, `marketplace.json`).

### Key Design Patterns

- **Hybrid Orchestration**: Two execution paths:
  1. **Template path** (deterministic): `/cyberops:run <workflow-name>` → orchestrator reads YAML template → executes agent(s) with predefined inputs/outputs
  2. **Ad-hoc path** (flexible): `/cyberops:run <natural language>` → orchestrator matches intent → routes to agent(s) dynamically
- **Workflow Templates**: YAML files in `workflows/` define reusable workflows with `agent`, `chain` (multi-agent), `input`, `output`, `keywords`, and `triggers`. See `workflows/SCHEMA.md`.
- **Agent-Skill-Command chain**: Legacy commands still work. Trace the chain: command → agent → skill(s).
- **Bilingual content**: All user-facing content supports Vietnamese (primary for internal reports) and English. Technical terms (MITRE ATT&CK IDs, CVE IDs, CVSS) stay in English.
- **Framework alignment**: Content aligns to ISO 27001:2022, NIST CSF 2.0, CIS Controls v8, MITRE ATT&CK, and Vietnamese regulations (Luật An ninh mạng 2018, Nghị định 13/2023/NĐ-CP, Nghị định 85/2016/NĐ-CP).
- **Local-first regulations**: Vietnamese regulations are stored in `skills/vietnam-regulations/`. Always reference local files BEFORE web search. Only search web when information is not found locally or needs verification for updates.

### Hooks Behavior

Hooks auto-execute during Claude Code sessions (controlled by `CYBEROPS_PROFILE`):

- **`check-secrets.sh`** (PreToolUse on Write/Edit) — blocks output containing AWS keys, API keys, passwords, private keys, DB connection strings. Skips binary files.
- **`pre-commit-security.sh`** (PreToolUse on git commit) — scans staged files for secrets, private keys, .env files, and overly permissive permissions (777/666).
- **`block-no-verify.sh`** (PreToolUse on git\*) — blocks `--no-verify`, `--no-gpg-sign`, and force push to main/master.
- **`post-write-classify.sh`** (PostToolUse on Write/Edit) — reminds about data classification headers when sensitive keywords are detected.
- **`session-summary.sh`** (Stop) — writes audit log to `~/.cybersec-audit-logs/`.
- **`batch-security-check.sh`** (Stop) — batch scans all modified files for secrets, classification headers, and permissions.
- **`profile-gate.sh`** — shared utility sourced by other hooks to check `CYBEROPS_PROFILE` level.

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
claude --plugin-dir .
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

### Global Config & Environment Variables

**`~/.claude/cyberops.yaml`** — Global config chứa document sources, mapping, và output paths. Tạo bởi `/cyberops:setup-profile` khi scan tài liệu:

```yaml
sources:
  - path: "D:\\Company-Docs"
    scanned_at: "2026-04-09T10:30:00"

mapping:
  org_docs: [...]
  process_docs: [...]
  regulations: [...]
  standards: [...]
  policies: [...]

output:
  profile: "./context/company-profile.yaml"
  workflows: "./workflows"
```

Quản lý config: `/cyberops:config`. Xem [commands/config.md](commands/config.md).

Resolution: `~/.claude/cyberops.yaml` mapping → working directory (default nếu không có config).

**Memvid (optional)** — Semantic search cho tài liệu team. Khi working directory có hàng ngàn file đa format (PDF, DOCX, XLSX), memvid index giúp tìm kiếm nhanh và chính xác hơn Grep. Không cài memvid thì plugin dùng Grep/Glob bình thường.

```yaml
# Thêm vào ~/.claude/cyberops.yaml (optional)
memvid:
  enabled: true
  index: "D:\\CyberSec-Team\\memory.mv2e"
```

Xem chi tiết logic search trong [agents/orchestrator.md](agents/orchestrator.md) → section "Document Search".

**`CYBEROPS_PROFILE`** — Control hook strictness:

| Profile | Behavior | Use case |
| --- | --- | --- |
| `dev` | Only critical checks (secrets detection) | Local development, rapid iteration |
| `standard` | All checks (default) | Normal usage |
| `strict` | All checks + block on warnings | Production environments, audits |

```bash
# Example: strict mode for audit preparation
CYBEROPS_PROFILE=strict claude --plugin-dir .
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
- When distributing, document required environment variables (`CYBEROPS_PROFILE`) and external dependencies.
- Hook scripts require `bash` and standard Unix tools (`grep`, `stat`, `git`). On Windows, ensure Git Bash or WSL is available.
