# secops — Claude Code Plugin

Plugin biến Claude Code thành trợ lý cybersecurity toàn diện. 12 agents chuyên biệt, 8 skills, 14 commands, hybrid orchestration với workflow templates, hooks bảo mật, và rules enforce standards.

> **Getting Started**: [GETTING-STARTED.md](GETTING-STARTED.md) — cài đặt, setup, cấu hình chi tiết
>
> **Development**: [DEVELOPMENT.md](DEVELOPMENT.md) — phát triển và contribute plugin

---

## Cài đặt

### Từ GitHub *(recommended)*

```text
/plugin marketplace add https://github.com/tieupham267/secops
/plugin install secops@secops
```

### Từ local (dev/testing)

```bash
git clone https://github.com/tieupham267/secops.git
cd secops
claude --plugin-dir .
```

### Sau khi cài

```text
/secops:setup-profile          # Khởi tạo data cho tổ chức
/secops:run --list             # Xem danh sách workflows
```

### Nâng cấp / Gỡ cài đặt

```text
/plugin update secops@secops                          # Update lên bản mới nhất
/plugin uninstall secops@secops --scope user           # Gỡ (user scope)
/plugin uninstall secops@secops --scope project        # Gỡ (project scope)
```

> Data (`context/`, `workflows/`, `references/`) không bị ảnh hưởng khi update hoặc gỡ plugin.

### Nâng cấp từ secops-toolkit (v1)

```text
/plugin uninstall secops-toolkit@secops --scope user   # Gỡ bản cũ
/plugin install secops@secops                          # Cài bản mới
```

---

## Thành phần

### Agents (12)

| Agent | Chức năng | Model |
| --- | --- | --- |
| `soc-analyst` | SOC L1-L3: triage alerts, log analysis, SIEM queries, detection rules | sonnet |
| `incident-commander` | IR playbooks, forensics, stakeholder communications | opus |
| `threat-analyst` | IOC processing, MITRE ATT&CK, threat briefings | sonnet |
| `threat-modeler` | STRIDE, PASTA, LINDDUN, attack trees, DFD review | opus |
| `risk-assessor` | Risk register, FAIR, BIA, TPRM, risk treatment | opus |
| `vuln-manager` | Scan analysis, SSVC prioritization, CVE assessment | sonnet |
| `grc-advisor` | Policy drafting, gap analysis, audit prep, ITSM review | opus |
| `awareness-designer` | Training content, phishing simulation campaigns | sonnet |
| `ciso-fintech` | CISO-level strategic advisor cho fintech Vietnam | opus |
| `devsecops` | CI/CD security, container/K8s, IaC review, supply chain | sonnet |
| `fraud-analyst` | Payment fraud, promotion abuse, transaction monitoring | opus |
| `orchestrator` | Meta-agent: routes requests tới workflow/agent phù hợp | opus |

### Skills (8)

| Skill | Nội dung |
| --- | --- |
| `incident-response` | Playbooks (ransomware, BEC, data breach), forensic procedures, report templates |
| `risk-assessment` | FAIR methodology, 5x5 matrix, BIA, TPRM questionnaire, treatment framework |
| `compliance-frameworks` | ISO 27001:2022, NIST CSF 2.0, CIS v8, PCI-DSS v4.0, Vietnamese regulations |
| `vietnam-regulations` | Luật ANM 2018, NĐ 13/2023, NĐ 85/2016, NĐ 53/2022, TT 09/2020-NHNN, TT 12/2022-BTTTT |
| `payment-fraud` | Fraud detection rules, promotion abuse, card fraud, ATO, collusion patterns |
| `itsm-reference` | ITIL 4, ISO 20000, service management security review |
| `document-drafting` | Templates cho policies, SOPs, reports, compliance documents |
| `security-maturity` | Security maturity assessment, capability mapping, roadmap planning |

### Commands (14)

| Command | Mô tả |
| --- | --- |
| `/secops:run` | **Unified entry point** — chạy workflow hoặc mô tả tự nhiên |
| `/secops:setup-profile` | Tạo/cập nhật company profile từ org documents |
| `/secops:generate-workflows` | Tạo workflows từ process documents nội bộ |
| `/secops:config` | Xem/sửa config (context_dir, workflows_dir, references_dir) |
| `/secops:incident` | Khởi tạo quy trình ứng phó sự cố |
| `/secops:risk-assess` | Đánh giá rủi ro an ninh mạng |
| `/secops:threat-model` | Phiên threat modeling |
| `/secops:soc-triage` | Triage security alert |
| `/secops:gap-analysis` | Gap analysis compliance framework |
| `/secops:phishing-campaign` | Thiết kế phishing simulation |
| `/secops:vuln-report` | Phân tích vulnerability scan |
| `/secops:policy-draft` | Soạn thảo chính sách bảo mật |
| `/secops:ciso-consult` | Tư vấn bảo mật cấp CISO cho fintech |
| `/secops:devsecops-review` | Review bảo mật CI/CD, K8s, container |

### Hooks (6)

| Hook | Event | Chức năng |
| --- | --- | --- |
| Secret detection | PreToolUse (Write/Edit) | Block nếu phát hiện credentials |
| Pre-commit security | PreToolUse (git commit) | Scan secrets, private keys, .env trước commit |
| Block --no-verify | PreToolUse (git*) | Chặn --no-verify, force push lên main/master |
| Data classification | PostToolUse (Write/Edit) | Nhắc phân loại dữ liệu khi có từ khóa nhạy cảm |
| Session audit log | Stop | Ghi session summary cho audit trail |
| Batch security check | Stop | Batch scan tất cả files đã thay đổi trong session |

### Rules (5)

| Rule | Áp dụng |
| --- | --- |
| `cybersecurity.md` | Index — tham chiếu các rules bên dưới |
| `data-handling.md` | Data classification, PII/credentials handling |
| `output-standards.md` | Severity ratings, TLP marking, bilingual output |
| `incident-response.md` | IR procedures, MITRE ATT&CK mapping, regulatory implications |
| `tool-safety.md` | Scanning authorization, safe command execution |

### Workflows (10 defaults)

| Workflow | Mục đích |
| --- | --- |
| `incident-response-default` | Ứng phó sự cố (NIST 800-61) |
| `data-breach-notification-default` | Thông báo vi phạm DLCN (NĐ 13/2023, 72h) |
| `vuln-management-default` | Xử lý lỗ hổng bảo mật |
| `access-review-default` | Rà soát quyền truy cập |
| `change-management-default` | Quản lý thay đổi |
| `vendor-risk-default` | Đánh giá rủi ro vendor |
| `bcdr-drill-default` | Diễn tập BCP/DRP |
| `security-awareness-default` | Đào tạo nhận thức ATTT |
| `risk-assessment-default` | Đánh giá rủi ro CNTT |
| `fraud-investigation-default` | Điều tra gian lận |

Custom workflows được tạo từ SOPs/playbooks nội bộ qua `/secops:generate-workflows`.

---

## Data Architecture

Plugin tách biệt **code** (agents, skills, commands, hooks) và **data** (context, workflows, references):

| Folder | Nội dung | Cách tạo |
| --- | --- | --- |
| `context/company-profile.yaml` | Tech stack, org mapping, escalation matrix | `/secops:setup-profile` |
| `context/org-docs/` | Tài liệu tổ chức (sơ đồ, danh sách tools) | User đặt files |
| `context/process-docs/` | SOPs, playbooks, runbooks | User đặt files |
| `workflows/defaults/` | 10 default workflow templates | `/secops:setup-profile` (copy từ plugin) |
| `workflows/<category>/` | Custom workflows | `/secops:generate-workflows` |
| `references/regulations/` | Luật, NĐ, TT bổ sung/cập nhật | User đặt files |
| `references/standards/` | ISO, PCI, NIST controls bổ sung | User đặt files |
| `references/policies/` | ISMS, chính sách nội bộ công ty | User đặt files |

Data nằm trong **working directory** (default) hoặc **folder riêng** (config qua `/secops:config` hoặc `~/.claude/secops.yaml`).

---

## Tùy chỉnh

### Data paths

```text
/secops:config context_dir C:\SecOps-Data\context
/secops:config workflows_dir C:\SecOps-Data\workflows
/secops:config references_dir C:\SecOps-Data\references
```

### Hook profiles

```bash
SECOPS_PROFILE=dev claude        # Nhẹ — chỉ check secrets
SECOPS_PROFILE=strict claude     # Nghiêm ngặt — block cả warnings
```

### Thêm components

| Component | Tạo file | Tham khảo |
| --- | --- | --- |
| Agent | `agents/<name>.md` | Xem agent hiện có |
| Skill | `skills/<name>/SKILL.md` | YAML frontmatter |
| Workflow | `workflows/<category>/<name>.yaml` | `workflows/SCHEMA.md` |
| Reference | `references/<type>/<name>.md` | Markdown tự do |

---

## Yêu cầu

- Claude Code (VS Code extension hoặc CLI)
- Claude Pro hoặc Max subscription
- Windows: Git Bash (cho hook scripts)

## Lưu ý bảo mật

- Plugin **KHÔNG** lưu trữ credentials hay dữ liệu nhạy cảm
- Tất cả output cần được review bởi security professional trước khi sử dụng
- Plugin là công cụ hỗ trợ, **KHÔNG** thay thế expertise con người
- Tuân thủ chính sách ATTT của tổ chức khi sử dụng AI tools
- Redact credentials/PII trước khi đặt tài liệu vào `context/` hoặc `references/`

## License

MIT
