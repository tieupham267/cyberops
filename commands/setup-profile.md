# /secops:setup-profile — Tạo/cập nhật company profile từ org documents

Bạn đang thực hiện setup hoặc cập nhật company profile tự động.

## Quy trình

### Step 0: Xác định paths và khởi tạo structure

**Xác định context_dir và workflows_dir:**

1. Đọc `~/.claude/secops.yaml` (trên Windows: `C:\Users\<username>\.claude\secops.yaml`)
2. Nếu file tồn tại và có `context_dir` / `workflows_dir` → dùng paths đã khai báo
3. Nếu file không tồn tại → **hỏi user**:

   ```text
   Bạn muốn lưu context và workflows ở đâu?
   
   1. Trong project hiện tại (./context, ./workflows) — mặc định
   2. Chỉ định folder riêng (dùng chung cho nhiều projects)
   
   Chọn [1/2]:
   ```

   - Nếu chọn 1 → `context_dir = ./context`, `workflows_dir = ./workflows` (KHÔNG tạo secops.yaml)
   - Nếu chọn 2 → hỏi paths cụ thể → **lưu vào `~/.claude/secops.yaml`**:

   ```yaml
   # ~/.claude/secops.yaml
   context_dir: C:\SecOps-Data\context
   workflows_dir: C:\SecOps-Data\workflows
   ```

**Tạo cấu trúc:**

```bash
# Context folders
mkdir -p "<context_dir>/org-docs" "<context_dir>/process-docs"

# Workflow folders
mkdir -p "<workflows_dir>/defaults" "<workflows_dir>/soc" "<workflows_dir>/ir" "<workflows_dir>/grc" "<workflows_dir>/devsecops" "<workflows_dir>/advisory" "<workflows_dir>/awareness"
```

**Copy default workflows từ plugin:**

Nếu `<workflows_dir>/defaults/` trống hoặc chưa có files:

1. Tìm plugin directory (nơi chứa file `plugin.json` của secops)
2. Copy tất cả files từ `<plugin-dir>/workflows/defaults/*.yaml` vào `<workflows_dir>/defaults/`
3. Nếu không tìm được plugin dir → tạo danh sách 10 default workflows trống với comment `# TODO: copy from plugin`

Nếu `<context_dir>/company-profile.yaml` chưa có → tạo file template trống với các fields cơ bản.

> **Thông báo cho user** paths đang sử dụng:
> `Context: <context_dir>`
> `Workflows: <workflows_dir>`

### Step 1: Đọc tất cả org documents

Đọc mọi file trong `<context_dir>/org-docs/` — hỗ trợ `.md`, `.txt`, `.csv`, `.json`, `.yaml`, `.pdf`, `.png`, `.jpg`.

```text
Glob: <context_dir>/org-docs/**/*
```

Với mỗi file:
- Đọc nội dung
- Extract thông tin liên quan đến company profile
- Ghi chú source file cho mỗi data point

### Step 2: Đọc company-profile.yaml hiện tại

Đọc `<context_dir>/company-profile.yaml` để biết fields nào đã có, fields nào còn trống.

### Step 3: Extract & Map

Từ nội dung org docs, extract thông tin và map vào profile fields:

| Thông tin tìm được | Map vào field |
| --- | --- |
| Tên công ty, ngành, sản phẩm | company.* |
| Cloud, servers, OS | infrastructure.* |
| CI/CD tools, source control | cicd.* |
| Firewall, WAF, VPN | networking.* |
| Database, message queue | data.* |
| SIEM, EDR, scanner | security.* |
| Frameworks, certifications | compliance.* |
| Team size, roles | security_team.* |
| Phòng ban, trưởng phòng, chức năng | org_mapping.* |
| Quy trình escalation, severity contacts | escalation.* |

### Step 4: Confirm với user

Hiển thị **bảng tóm tắt** những gì sẽ thay đổi trong profile:

```
## Profile Changes Summary

### New fields (sẽ được điền):
- company.name: "ABC Fintech" (from: org-chart.md)
- security.siem: "opensearch" (from: tech-stack.md)
- org_mapping.soc.department: "Phòng GSANM" (from: org-chart.md)
...

### Updated fields (đã có, sẽ cập nhật):
- security_team.size: "3-10" → "10-30" (from: hr-teams.csv)
...

### Unchanged fields:
- infrastructure.cloud_provider: [on-prem] (giữ nguyên)
...

### Still empty (không tìm thấy trong org docs):
- security.pam: "" ← cần bổ sung thủ công hoặc thêm doc
...
```

Hỏi user: **Confirm changes? (Yes / Edit trước / Cancel)**

### Step 5: Write profile

Nếu confirmed → ghi vào `<context_dir>/company-profile.yaml`, giữ nguyên format và comments.

### Step 6: Validate

Chạy validation:
- Tất cả org_mapping có department name?
- Escalation matrix có đủ severity levels?
- Tech stack consistent (ví dụ: có SIEM nhưng không có SOC team → flag)
- Flag gaps: chức năng quan trọng chưa có team phụ trách

## Lưu ý

- **Không bao giờ ghi đè** field đã có bằng giá trị trống — chỉ update khi có data mới
- **Preserve user edits** — nếu user đã sửa trực tiếp trong YAML, ưu tiên giá trị đó trừ khi org doc mới hơn
- **Cite sources** — ghi chú file nào cung cấp thông tin gì để user verify
- **Redact check** — nếu phát hiện credentials/PII thật trong org docs, cảnh báo KHÔNG đưa vào profile
