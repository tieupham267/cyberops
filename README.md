# cyberops

Claude Code plugin biến Claude thành trợ lý cybersecurity cho team SOC, GRC, DevSecOps, và fraud analysis.

## Tính năng

- **12 agent personas** — SOC analyst, incident commander, threat analyst, threat modeler, risk assessor, vulnerability manager, GRC advisor, awareness designer, CISO fintech, DevSecOps, fraud analyst, orchestrator
- **9 knowledge-base skills** — incident response, compliance frameworks, risk assessment, Vietnam regulations, payment fraud, ITSM reference, document drafting, document organization, security maturity
- **Workflow templates** — YAML-based, deterministic hoặc ad-hoc routing qua orchestrator
- **Security hooks** — tự động chặn secrets, kiểm tra pre-commit, audit logging
- **Bilingual** — Vietnamese (primary) + English. Technical terms (MITRE ATT&CK, CVE, CVSS) giữ nguyên English
- **Framework alignment** — ISO 27001:2022, NIST CSF 2.0, CIS Controls v8, MITRE ATT&CK, Luật An ninh mạng 2018, NĐ 13/2023

## Cài đặt

### Yêu cầu

- Claude Code (VS Code extension hoặc CLI)
- Windows: Git Bash (cần cho hook scripts)
- Claude Pro hoặc Max subscription

### Cài global (recommended)

```text
/plugin marketplace add https://github.com/tieupham267/cyberops
/plugin install cyberops@cyberops
```

### Clone repo (dev/contribute)

```bash
git clone https://github.com/tieupham267/cyberops.git
cd cyberops
claude --plugin-dir .
```

### Nâng cấp từ secops

```text
/plugin uninstall secops@secops --scope user
/plugin marketplace remove secops

/plugin marketplace add https://github.com/tieupham267/cyberops
/plugin install cyberops@cyberops
```

Thay đổi khi migrate: `/secops:*` → `/cyberops:*`, `~/.claude/secops.yaml` → `~/.claude/cyberops.yaml`, `SECOPS_PROFILE` → `CYBEROPS_PROFILE`. Data không bị ảnh hưởng.

## Quick Start

```text
# Scan tài liệu & build company profile
/cyberops:setup-profile

# Chạy workflow
/cyberops:run alert-triage
/cyberops:run "đánh giá rủi ro hệ thống thanh toán"

# Liệt kê workflows
/cyberops:run --list
```

## Commands

| Command | Mục đích |
| --- | --- |
| `/cyberops:run <workflow>` | Chạy workflow cụ thể |
| `/cyberops:run <mô tả>` | Mô tả tự nhiên → orchestrator tự chọn |
| `/cyberops:run --list` | Liệt kê tất cả workflows |
| `/cyberops:setup-profile` | Scan tài liệu, build company profile |
| `/cyberops:generate-workflows` | Tạo workflows từ process docs |
| `/cyberops:doc-review` | Review tổ chức tài liệu |
| `/cyberops:config` | Quản lý sources, mapping, output paths |

## Cấu trúc

```text
agents/          12 agent personas (Markdown + YAML frontmatter)
skills/          9 knowledge-base skills
workflows/       YAML workflow templates (ir, soc, grc, fraud, devsecops, advisory, awareness)
commands/        Slash commands
hooks/           Security hooks (secrets detection, pre-commit, audit log)
rules/           Security rules (data handling, output standards, tool safety)
context/         Company profile & org context
references/      User-managed reference documents
```

## Environment

| Biến | Giá trị | Mô tả |
| --- | --- | --- |
| `CYBEROPS_PROFILE` | `dev` | Chỉ check secrets |
| | `standard` *(default)* | Tất cả checks |
| | `strict` | Block cả warnings |

```bash
CYBEROPS_PROFILE=strict claude --plugin-dir .
```

## Testing

```bash
bash tests/run-all.sh          # All 5 layers
bash tests/run-all.sh 1        # Layer 1 only
```

## Tài liệu

| File | Nội dung |
| --- | --- |
| [GETTING-STARTED.md](GETTING-STARTED.md) | Hướng dẫn cài đặt đầy đủ |
| [CLAUDE.md](CLAUDE.md) | Technical reference — architecture, patterns, rules |
| [DEVELOPMENT.md](DEVELOPMENT.md) | Hướng dẫn phát triển và contribute |
| [workflows/SCHEMA.md](workflows/SCHEMA.md) | Format YAML cho workflow templates |
