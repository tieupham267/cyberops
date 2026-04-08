# secops — Claude Code Plugin

Plugin toàn diện cho team Cyber Security. Biến Claude Code thành trợ lý bảo mật với 12 agents chuyên biệt, 8 skills chuyên sâu, 14 slash commands, hooks tự động, và rules enforce standards. Hỗ trợ hybrid orchestration với workflow templates.

## Cài đặt

> Hướng dẫn chi tiết từng bước: xem [GETTING-STARTED.md](GETTING-STARTED.md)

### Từ GitHub *(recommended)*

```text
/plugin marketplace add https://github.com/tieupham267/secops
/plugin install secops-toolkit@secops
```

### Từ local (dev/testing)

```bash
git clone https://github.com/tieupham267/secops.git
cd secops
claude --plugin-dir .
```

## Thành phần

### Agents (12)

| Agent | Chức năng | Model |
|-------|-----------|-------|
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
|-------|---------|
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
|---------|-------|
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
|------|-------|----------|
| Secret detection | PreToolUse (Write/Edit) | Block nếu phát hiện credentials |
| Pre-commit security | PreToolUse (git commit) | Scan secrets, private keys, .env trước commit |
| Block --no-verify | PreToolUse (git*) | Chặn --no-verify, force push lên main/master |
| Data classification | PostToolUse (Write/Edit) | Nhắc phân loại dữ liệu khi có từ khóa nhạy cảm |
| Session audit log | Stop | Ghi session summary cho audit trail |
| Batch security check | Stop | Batch scan tất cả files đã thay đổi trong session |

### Rules (5)

| Rule | Áp dụng |
|------|---------|
| `cybersecurity.md` | Index — tham chiếu các rules bên dưới |
| `data-handling.md` | Data classification, PII/credentials handling |
| `output-standards.md` | Severity ratings, TLP marking, bilingual output |
| `incident-response.md` | IR procedures, MITRE ATT&CK mapping, regulatory implications |
| `tool-safety.md` | Scanning authorization, safe command execution |

## Yêu cầu

- Claude Code v2.0.12+
- Gói Claude Pro hoặc Max subscription

## Tùy chỉnh

### Thêm context tổ chức

Tạo file `CLAUDE.md` trong project và thêm thông tin:

```markdown
# Security Context
- Organization: [Tên tổ chức]
- Industry: [Ngành nghề]
- Compliance: [ISO 27001 / PCI-DSS / ...]
- SIEM: [Splunk / Elastic / QRadar / ...]
- EDR: [CrowdStrike / Defender / ...]
```

### Thêm agent mới

Tạo file `.md` trong `agents/` theo format frontmatter YAML.

### Disable hook cụ thể

Trong `.claude/settings.json`:

```json
{
  "hooks": {
    "disabled": ["check-secrets"]
  }
}
```

## Lưu ý bảo mật

- Plugin KHÔNG lưu trữ bất kỳ credentials hay dữ liệu nhạy cảm nào
- Tất cả output cần được review bởi security professional trước khi sử dụng
- Plugin là công cụ hỗ trợ, KHÔNG thay thế expertise con người
- Tuân thủ chính sách ATTT của tổ chức khi sử dụng AI tools

## License

MIT
