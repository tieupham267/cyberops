# secops — Claude Code Plugin

Plugin toàn diện cho team Cyber Security. Biến Claude Code thành trợ lý bảo mật với 8 agents chuyên biệt, 3 skills chuyên sâu, 8 slash commands, hooks tự động, và rules enforce standards.

## Cài đặt

### Từ GitHub
```bash
/plugin install github:YOUR_USERNAME/secops
```

### Từ local (dev/testing)
```bash
claude --plugin-dir ./secops
```

### Từ marketplace
```bash
/plugin marketplace add YOUR_USERNAME/secops-marketplace
/plugin install secops@secops-marketplace
```

## Thành phần

### Agents (8)

| Agent | Lệnh gọi | Chức năng |
|-------|-----------|-----------|
| `soc-analyst` | Phân tích alert, log, SIEM queries | SOC L1-L3 |
| `incident-commander` | IR playbooks, forensics, communication | Ứng phó sự cố |
| `threat-analyst` | IOC processing, MITRE ATT&CK, threat briefing | Threat Intelligence |
| `threat-modeler` | STRIDE, PASTA, LINDDUN, attack trees | Threat Modeling |
| `risk-assessor` | Risk register, FAIR, BIA, TPRM | Quản lý rủi ro |
| `vuln-manager` | Scan analysis, SSVC prioritization, CVE assessment | Vuln Management |
| `grc-advisor` | Policy drafting, gap analysis, audit prep | GRC & Compliance |
| `awareness-designer` | Training content, phishing campaigns | Security Awareness |

### Skills (3)

| Skill | Nội dung |
|-------|---------|
| `incident-response` | Playbooks (ransomware, BEC, data breach), forensic procedures, report templates |
| `risk-assessment` | FAIR methodology, 5x5 matrix, BIA, TPRM questionnaire, treatment framework |
| `compliance-frameworks` | ISO 27001:2022, NIST CSF 2.0, CIS v8, Vietnamese regulations (NĐ 13/2023, Luật ANM 2018) |

### Commands (8)

| Command | Mô tả |
|---------|-------|
| `/secops:incident` | Khởi tạo quy trình ứng phó sự cố |
| `/secops:risk-assess` | Đánh giá rủi ro an ninh mạng |
| `/secops:threat-model` | Phiên threat modeling |
| `/secops:soc-triage` | Triage security alert |
| `/secops:gap-analysis` | Gap analysis compliance framework |
| `/secops:phishing-campaign` | Thiết kế phishing simulation |
| `/secops:vuln-report` | Phân tích vulnerability scan |
| `/secops:policy-draft` | Soạn thảo chính sách bảo mật |

### Hooks (4)

| Hook | Event | Chức năng |
|------|-------|----------|
| Secret detection | PreToolUse (Write/Edit) | Block nếu phát hiện credentials |
| Pre-commit security | PreToolUse (git commit) | Scan secrets trước commit |
| Data classification | PostToolUse (Write/Edit) | Nhắc phân loại dữ liệu |
| Session audit log | Stop | Ghi log session cho audit trail |

### Rules (1)

| Rule | Áp dụng |
|------|---------|
| `cybersecurity.md` | Data handling, output standards, severity classification, regulatory compliance |

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
