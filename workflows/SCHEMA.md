# Workflow Template Schema

Mỗi workflow template là 1 file YAML trong `workflows/<category>/`. Orchestrator agent đọc các templates này để match với user request hoặc chạy trực tiếp qua `/cyberops:run`.

## Schema Definition

```yaml
# --- Required fields ---
name: string                    # Unique workflow ID (kebab-case)
title: string                   # Display name (Vietnamese)
description: string             # Mô tả ngắn — orchestrator dùng để match intent
category: string                # soc | ir | grc | devsecops | advisory | awareness

# --- Agent & Skills ---
agent: string                   # Primary agent to execute
skills: list[string]            # Skills to attach (optional, default: [])
chain:                          # Multi-agent chain (optional, thay cho agent đơn)
  - agent: string
    skills: list[string]
    task: string                # Mô tả task cho agent này
    output_key: string          # Key để reference output ở steps sau

# --- User Input ---
input:
  - field: string               # Field name (snake_case)
    prompt: string              # Câu hỏi cho user (Vietnamese)
    type: string                # text | choice | file | multiline
    required: boolean           # Default: true
    options: list[string]       # Chỉ dùng khi type=choice
    default: string             # Giá trị mặc định (optional)
    auto_from: string           # Auto-populate từ file (e.g., context/company-profile.yaml). Skip hỏi user nếu data đã có.

# --- Output ---
output:
  format: string                # Tên template output (tham chiếu trong agent)
  sections: list[string]        # Các sections bắt buộc trong output
  language: string              # vi | en | bilingual (default: vi)

# --- Escalation (auto-trigger workflow khác khi đủ tiêu chí) ---
escalate:                         # Optional — escalate sang workflow khác sau khi triage
  target: string                  # Tên workflow đích (e.g., emergency-patch)
  criteria: list[string]          # Điều kiện escalate (agent đánh giá — bất kỳ điều kiện nào match → escalate)
  carry_fields:                   # Map input fields sang target workflow (optional)
    target_field: source_field    # e.g., vuln_source: vuln_source
  prompt_user: boolean            # Hỏi user trước khi escalate? (default: true)

# --- Routing (cho orchestrator matching) ---
keywords: list[string]          # Keywords để orchestrator match intent
triggers: list[string]          # Exact phrases that trigger this workflow
priority: integer               # Khi nhiều workflows match, ưu tiên cao hơn chạy (1=highest)

# --- Metadata ---
tags: list[string]              # Tags cho filtering/search
version: string                 # Semantic version
author: string                  # Người tạo
type: string                    # default | custom (default: custom)
overrides: string               # Tên default workflow mà custom workflow này thay thế (optional)
```

## Rules

1. `name` phải unique across toàn bộ `workflows/` (trừ defaults — có thể trùng tên với custom)
2. Dùng `agent` cho single-agent workflow, `chain` cho multi-agent
3. Nếu có `chain`, field `agent` bị ignore
4. `keywords` nên bao gồm cả tiếng Việt và tiếng Anh
5. Mỗi workflow phải có ít nhất 1 `input` field
6. `output.sections` phải match với sections đã define trong agent tương ứng
7. `escalate.target` phải trỏ đến workflow `name` đã tồn tại
8. Khi `escalate.prompt_user: false`, orchestrator tự động chuyển mà không hỏi — chỉ dùng cho escalation rõ ràng (e.g., CVSS ≥ 9.0 + KEV)
9. `escalate.carry_fields` map field names — nếu target workflow có field cùng tên, tự động điền từ output của workflow hiện tại

## Default vs Custom Workflows

### Thứ tự ưu tiên (orchestrator)

```
1. Custom workflows (workflows/<category>/*.yaml)     ← ưu tiên cao nhất
2. Auto-generated (từ /cyberops:generate-workflows)      ← ưu tiên cao
3. Default workflows (workflows/defaults/*.yaml)       ← fallback
```

### Quy tắc override

- Default workflows nằm trong `workflows/defaults/` — dùng khi chưa có custom workflow cho task đó
- Khi custom workflow có `overrides: <default-name>`, orchestrator bỏ qua default đó
- Khi custom workflow có cùng `keywords`/`triggers` với default, custom luôn thắng
- `/cyberops:run --list` hiển thị cả hai, đánh dấu `[default]` hoặc `[custom]` hoặc `[overridden]`
- `/cyberops:generate-workflows` tự động thêm `overrides:` field khi tạo custom workflow thay thế default
