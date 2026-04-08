# /secops:run — Unified entry point cho tất cả security workflows

Bạn là orchestrator cho security operations. Sử dụng **orchestrator** agent.

## Cách sử dụng

### Chạy workflow cụ thể
```
/secops:run alert-triage
/secops:run incident-response
/secops:run threat-advisory
```

### Mô tả bằng ngôn ngữ tự nhiên
```
/secops:run Tôi nhận được advisory về CI/CD compromise, cần tạo detection rules
/secops:run Cần đánh giá gap analysis cho ISO 27001
```

### Liệt kê workflows
```
/secops:run --list
/secops:run --category soc
/secops:run --category grc
```

## Quy trình

1. Nếu user chỉ định workflow name → đọc template YAML tương ứng trong `workflows/` → chạy trực tiếp
2. Nếu user mô tả request → orchestrator agent phân tích intent:
   - Match với workflow templates (keywords, triggers)
   - Nếu match → suggest template, confirm với user
   - Nếu không match → ad-hoc routing đến agent(s) phù hợp
3. Nếu `--list` hoặc `--category` → liệt kê workflows có sẵn

## Workflows có sẵn

| Category | Workflows |
| --- | --- |
| `soc` | alert-triage, vuln-report, threat-model, threat-hunt, detection-engineering, security-metrics-report, ioc-management, log-review |
| `ir` | incident-response, risk-assess |
| `grc` | gap-analysis, policy-draft, ciso-consult, itsm-policy-review, software-evaluation, onboarding-offboarding, security-exception, document-review, security-roadmap, regulatory-directive, solution-comparison, audit-preparation, regulatory-inspection, audit-findings-management |
| `devsecops` | pipeline-review, security-architecture-review |
| `advisory` | threat-advisory, supply-chain-advisory |
| `fraud` | promotion-risk-assess |
| `awareness` | phishing-campaign |

## Lưu ý

- Commands cũ (`/incident`, `/soc-triage`, v.v.) vẫn hoạt động bình thường cho backward compatibility
- `/secops:run` là entry point mới ưu tiên, đặc biệt cho workflows phức tạp (multi-agent chains)
- Mọi routing decision được log cho audit trail
