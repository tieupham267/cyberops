# /secops:setup-profile — Tạo/cập nhật company profile từ org documents

Bạn đang thực hiện setup hoặc cập nhật company profile tự động.

## Quy trình

### Step 0: Khởi tạo project structure trong working directory

Kiểm tra và tạo cấu trúc cần thiết trong working directory hiện tại:

```bash
# Context folders
mkdir -p context/org-docs context/process-docs

# Workflow folders
mkdir -p workflows/defaults workflows/soc workflows/ir workflows/grc workflows/devsecops workflows/advisory workflows/awareness
```

**Copy default workflows từ plugin:**

Nếu `workflows/defaults/` trong working directory trống hoặc chưa có files:

1. Tìm plugin directory (nơi chứa file `plugin.json` của secops)
2. Copy tất cả files từ `<plugin-dir>/workflows/defaults/*.yaml` vào `./workflows/defaults/`
3. Nếu không tìm được plugin dir → tạo danh sách 10 default workflows trống với comment `# TODO: copy from plugin`

Nếu `context/company-profile.yaml` chưa có → tạo file template trống với các fields cơ bản.

> **Lưu ý**: Tất cả files luôn nằm trong working directory (project của user), KHÔNG phải trong plugin directory. Default workflows được copy 1 lần, sau đó user quản lý bản copy trong project.

### Step 1: Đọc tất cả org documents

Đọc mọi file trong `context/org-docs/` (từ working directory) — hỗ trợ `.md`, `.txt`, `.csv`, `.json`, `.yaml`, `.pdf`, `.png`, `.jpg`.

```text
Glob: context/org-docs/**/*
```

Với mỗi file:
- Đọc nội dung
- Extract thông tin liên quan đến company profile
- Ghi chú source file cho mỗi data point

### Step 2: Đọc company-profile.yaml hiện tại

Đọc `context/company-profile.yaml` để biết fields nào đã có, fields nào còn trống.

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

Nếu confirmed → ghi vào `context/company-profile.yaml`, giữ nguyên format và comments.

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
