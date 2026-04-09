# cyberops — Claude Code Plugin

Plugin biến Claude Code thành trợ lý cybersecurity toàn diện. 12 agents chuyên biệt, 8 skills, 14 commands, hybrid orchestration với workflow templates, hooks bảo mật, và rules enforce standards.

> **Getting Started**: [GETTING-STARTED.md](GETTING-STARTED.md) — cài đặt, setup, cấu hình chi tiết
>
> **Development**: [DEVELOPMENT.md](DEVELOPMENT.md) — phát triển và contribute plugin

---

## Cài đặt

### Từ GitHub *(recommended)*

```text
/plugin marketplace add https://github.com/tieupham267/cyberops
/plugin install cyberops@cyberops
```

### Từ local (dev/testing)

```bash
git clone https://github.com/tieupham267/cyberops.git
cd cyberops
claude --plugin-dir .
```

### Sau khi cài

```text
/cyberops:setup-profile          # Khởi tạo data cho tổ chức
/cyberops:run --list             # Xem danh sách workflows
```

### Nâng cấp / Gỡ cài đặt

```text
/plugin update cyberops@cyberops                          # Update lên bản mới nhất
/plugin uninstall cyberops@cyberops --scope user           # Gỡ (user scope)
/plugin uninstall cyberops@cyberops --scope project        # Gỡ (project scope)
```

> Data (`context/`, `workflows/`, `references/`) không bị ảnh hưởng khi update hoặc gỡ plugin.

### Nâng cấp từ secops (v2-v3)

```text
/plugin uninstall secops@secops --scope user               # Gỡ bản cũ
/plugin marketplace remove secops                          # Gỡ marketplace cũ
/plugin marketplace add https://github.com/tieupham267/cyberops
/plugin install cyberops@cyberops                          # Cài bản mới
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

### Skills (9)

| Skill | Nội dung |
| --- | --- |
| `incident-response` | Playbooks (ransomware, BEC, data breach), forensic procedures, report templates |
| `risk-assessment` | FAIR methodology, 5x5 matrix, BIA, TPRM questionnaire, treatment framework |
| `compliance-frameworks` | ISO 27001:2022, NIST CSF 2.0, CIS v8, PCI-DSS v4.0, Vietnamese regulations |
| `vietnam-regulations` | Luật ANM 2018, NĐ 13/2023, NĐ 85/2016, NĐ 53/2022, TT 09/2020-NHNN, TT 12/2022-BTTTT |
| `payment-fraud` | Fraud detection rules, promotion abuse, card fraud, ATO, collusion patterns |
| `itsm-reference` | ITIL 4, ISO 20000, service management security review |
| `document-drafting` | Templates cho policies, SOPs, reports, compliance documents |
| `document-organization` | PARA (Second Brain), ISO 27001 doc hierarchy, lifecycle management, gap analysis |
| `security-maturity` | Security maturity assessment, capability mapping, roadmap planning |

### Commands (14)

| Command | Mô tả |
| --- | --- |
| `/cyberops:run` | **Unified entry point** — chạy workflow hoặc mô tả tự nhiên |
| `/cyberops:setup-profile` | Tạo/cập nhật company profile từ org documents |
| `/cyberops:generate-workflows` | Tạo workflows từ process documents nội bộ |
| `/cyberops:config` | Xem/sửa config (context_dir, workflows_dir, references_dir) |
| `/cyberops:incident` | Khởi tạo quy trình ứng phó sự cố |
| `/cyberops:risk-assess` | Đánh giá rủi ro an ninh mạng |
| `/cyberops:threat-model` | Phiên threat modeling |
| `/cyberops:soc-triage` | Triage security alert |
| `/cyberops:gap-analysis` | Gap analysis compliance framework |
| `/cyberops:phishing-campaign` | Thiết kế phishing simulation |
| `/cyberops:vuln-report` | Phân tích vulnerability scan |
| `/cyberops:policy-draft` | Soạn thảo chính sách bảo mật |
| `/cyberops:ciso-consult` | Tư vấn bảo mật cấp CISO cho fintech |
| `/cyberops:devsecops-review` | Review bảo mật CI/CD, K8s, container |

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

Custom workflows được tạo từ SOPs/playbooks nội bộ qua `/cyberops:generate-workflows`.

---

## Data Architecture

Plugin **không bắt buộc cấu trúc folder cứng**. Thay vào đó, `/cyberops:setup-profile` scan folders tài liệu hiện có của user, tự phân loại, và lưu mapping:

```text
/cyberops:setup-profile
→ Chỉ tôi tới folders tài liệu: D:\Company-Docs
→ Plugin scan 47 files → phân loại → hiển thị mapping → confirm
→ Lưu mapping vào ~/.claude/cyberops.yaml
```

Plugin tự phân loại tài liệu vào các categories:

| Category | Nội dung | Dùng cho |
| --- | --- | --- |
| `org_docs` | Sơ đồ tổ chức, tech stack, asset inventory | Build company profile |
| `process_docs` | SOPs, playbooks, runbooks | Generate custom workflows |
| `regulations` | Luật, NĐ, TT | Tra cứu quy định |
| `standards` | ISO, PCI, NIST controls | Gap analysis, audit |
| `policies` | ISMS, chính sách nội bộ | Policy review, compliance |
| `reports` | Audit reports, assessments | Trend analysis |
| `templates` | Mẫu biểu, forms | Document drafting |

Plugin cũng hỗ trợ review tổ chức tài liệu theo **PARA (Second Brain)**, **ISO 27001 hierarchy**, hoặc **custom framework** qua `/cyberops:doc-review`.

---

## Tùy chỉnh

### Document sources

```text
/cyberops:config add-source D:\New-Docs     # Thêm folder tài liệu
/cyberops:config remove-source D:\Old-Docs  # Xóa folder
/cyberops:config rescan                     # Rescan tất cả sources
/cyberops:config show-mapping               # Xem mapping hiện tại
```

### Hook profiles

```bash
CYBEROPS_PROFILE=dev claude        # Nhẹ — chỉ check secrets
CYBEROPS_PROFILE=strict claude     # Nghiêm ngặt — block cả warnings
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
