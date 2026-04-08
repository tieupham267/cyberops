# /secops:generate-workflows — Tạo workflows từ process documents

Bạn đang tạo hoặc cập nhật workflow templates tự động từ quy trình nội bộ.

## Quy trình

### Step 1: Đọc context

Đọc song song:
- `context/company-profile.yaml` — để biết org mapping, tech stack, agents có sẵn
- `workflows/SCHEMA.md` — để biết YAML schema
- Tất cả workflows hiện có trong `workflows/` — để tránh duplicate

### Step 2: Đọc process documents

Đọc mọi file trong `context/process-docs/` (trừ README.md).

Với mỗi file, extract:

| Extract | Map vào workflow field |
| --- | --- |
| Tên quy trình | `name`, `title` |
| Mục đích, mô tả | `description` |
| Lĩnh vực (IR, GRC, SOC, DevSecOps) | `category` |
| Các bước thực hiện | `chain` (nếu multi-agent) hoặc agent task description |
| Thông tin đầu vào cần thu thập | `input` fields |
| Output mong đợi | `output.sections` |
| Điều kiện kích hoạt | `triggers`, `keywords` |
| Người thực hiện | Map qua `org_mapping` → xác định agent phù hợp |
| Framework/quy định tham chiếu | Skills cần gắn |
| SLA/Timeline | Ghi vào agent task description |

### Step 3: Xác định agent mapping

Với mỗi bước trong quy trình, chọn agent phù hợp:

| Bước trong quy trình | Agent |
| --- | --- |
| Phát hiện, phân tích alert, triage | soc-analyst |
| Coordinate ứng phó, ra quyết định | incident-commander |
| Phân tích threat intel, IOCs | threat-analyst |
| Đánh giá rủi ro | risk-assessor |
| Review code, pipeline, container | devsecops |
| Soạn policy, audit, gap analysis | grc-advisor |
| Đánh giá lỗ hổng, patch management | vuln-manager |
| Threat modeling | threat-modeler |
| Đào tạo, awareness | awareness-designer |
| Tư vấn chiến lược, board reporting | ciso-fintech |

Nếu quy trình có nhiều bước liên quan nhiều agents → tạo `chain` (multi-agent workflow).

### Step 4: Generate YAML

Tạo workflow YAML theo schema trong `workflows/SCHEMA.md`:

```yaml
name: <kebab-case từ tên quy trình>
title: <tên quy trình gốc>
description: >
  <mô tả từ process doc, kèm note "Generated from: <filename>">
category: <soc|ir|grc|devsecops|advisory|awareness>

# Single agent hoặc chain — tùy complexity
agent: <agent-name>          # Nếu đơn giản
chain:                        # Nếu multi-step
  - agent: <agent-name>
    skills: [...]
    task: >
      <mô tả task cụ thể, bao gồm SLA nếu có>
    output_key: <step_name>

input:
  - field: <extracted từ process doc>
    prompt: <câu hỏi tiếng Việt>
    type: <text|choice|file|multiline>
    required: true
    auto_from: context/company-profile.yaml  # nếu applicable

output:
  format: <tên-quy-trình>-output
  sections:
    - <extracted từ output mong đợi trong process doc>
  language: vi

keywords: [<từ khóa từ process doc, cả tiếng Việt và tiếng Anh>]
triggers: [<cụm từ kích hoạt>]
priority: <1-5 dựa vào criticality>

tags: [<tags phù hợp>]
version: "1.0.0"
author: "auto-generated from <filename>"
type: custom
overrides: <default-workflow-name>   # nếu thay thế một default workflow
```

### Step 4b: Detect default overrides

Với mỗi workflow vừa generate, kiểm tra `workflows/defaults/`:
- Nếu custom workflow có cùng `name` (trừ `-default` suffix) hoặc trùng `keywords` ≥ 50% → tự thêm `overrides: <default-name>`
- Ví dụ: custom `incident-response` từ process doc → `overrides: incident-response-default`

### Step 5: Hiển thị preview

Với mỗi workflow sẽ tạo, hiển thị:

```
## Workflows sẽ tạo

### 1. workflows/ir/data-breach-response.yaml
- Source: data-breach-playbook.md
- Category: ir
- Chain: incident-commander → soc-analyst → grc-advisor → ciso-fintech
- Inputs: 5 fields (incident_type, affected_data, discovery_time, ...)
- Status: MỚI
- Overrides: data-breach-notification-default ← default sẽ bị bỏ qua

### 2. workflows/grc/access-review.yaml
- Source: access-review-process.md
- Category: grc
- Agent: grc-advisor (single)
- Inputs: 3 fields
- Status: MỚI
- Overrides: access-review-default ← default sẽ bị bỏ qua

### 3. workflows/ir/incident-response.yaml
- Source: incident-response-plan.md
- Status: ĐÃ CÓ — sẽ MERGE (bổ sung steps từ process doc)

---
Confirm? (Create all / Select / Edit / Cancel)
```

### Step 6: Write workflows

Nếu confirmed:
- **MỚI** → tạo file mới trong `workflows/<category>/`
- **MỚI + OVERRIDES** → tạo file mới + thêm `overrides:` field
- **ĐÃ CÓ** → merge: bổ sung inputs/sections/keywords, KHÔNG ghi đè existing content
- Chạy validation: agent refs exist, skill refs exist, schema valid

### Step 7: Report default status

Sau khi tạo, hiển thị default workflow status:

```
## Default Workflow Status

| Default Workflow | Status | Overridden by |
| --- | --- | --- |
| incident-response-default | ✅ OVERRIDDEN | workflows/ir/incident-response.yaml |
| data-breach-notification-default | ✅ OVERRIDDEN | workflows/ir/data-breach-response.yaml |
| access-review-default | ✅ OVERRIDDEN | workflows/grc/access-review.yaml |
| vuln-management-default | 📌 ACTIVE (chưa có custom) | — |
| change-management-default | 📌 ACTIVE (chưa có custom) | — |
| vendor-risk-default | 📌 ACTIVE (chưa có custom) | — |
| bcdr-drill-default | 📌 ACTIVE (chưa có custom) | — |
| security-awareness-default | 📌 ACTIVE (chưa có custom) | — |

→ 5 defaults vẫn active. Tạo process docs cho các quy trình này để có custom workflows.
```

### Step 8: Suggest missing processes

So sánh với best practices và quy định applicable:

```
## Suggested processes chưa có (cả default lẫn custom)

Dựa trên company profile (fintech, payment) và frameworks:

| Process | Tại sao cần | Framework reference |
| --- | --- | --- |
| Data Classification | Required by NĐ 13/2023, ISO 27001 A.5.12 | Tạo file trong process-docs/ |
| Secure SDLC | Required by TT 09/2020 Điều 22-24 | Tạo file trong process-docs/ |
| Key Management | Required by PCI DSS Req 3.5-3.7 | Tạo file trong process-docs/ |
```

## Quy tắc quan trọng

- **Không bịa thêm steps** — chỉ tạo workflow từ nội dung trong process doc
- **Giữ nguyên intent** — workflow phải phản ánh đúng quy trình gốc, không optimize hay thay đổi
- **Cite source** — mỗi workflow có `author: "auto-generated from <filename>"`
- **Không ghi đè** — workflows đã tồn tại chỉ merge, không replace
- **Auto-override** — tự detect và mark `overrides:` khi custom thay thế default
- **Flag ambiguity** — nếu process doc không rõ → ghi comment `# TODO: clarify from <filename>`
