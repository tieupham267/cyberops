# SecOps Plugin — Getting Started

Hướng dẫn cài đặt và cấu hình plugin **secops** cho team cybersecurity.

Sau khi hoàn thành, plugin sẽ được tailored cho tổ chức của bạn — tất cả agents sẽ tự động đọc tech stack, org structure, quy trình nội bộ, và quy định applicable để tạo output chính xác.

---

## Tổng quan các bước

| Bước | Nội dung | Thời gian |
| --- | --- | --- |
| 1 | Cài đặt plugin | 5 phút |
| 2 | Khởi tạo data (context, workflows, references) | 5 phút |
| 3 | Setup company profile | 15 phút |
| 4 | Setup org structure & escalation | 10 phút |
| 5 | Setup workflows từ quy trình nội bộ | 10 phút |
| 6 | Thêm tài liệu tham chiếu (regulations, policies) | 10 phút |
| 7 | Cài Office Document Skills *(tùy chọn)* | 10 phút |
| 8 | Verify & test | 5 phút |
| | **Tổng** | **~70 phút** |

---

## Bước 1: Cài đặt plugin

### Yêu cầu hệ thống

- **Claude Code** — VS Code extension (`anthropic.claude-code`) hoặc CLI (`npm install -g @anthropic-ai/claude-code`)
- **Windows**: Git Bash (cài cùng Git for Windows) — cần cho hook scripts
- **Subscription**: Claude Pro hoặc Max

### Cài đặt

**Cách 1 — Cài global** *(recommended cho daily use)*

```text
/plugin marketplace add https://github.com/tieupham267/secops
/plugin install secops@secops
```

Plugin tự load ở mọi project. Data (context, workflows, references) sẽ được khởi tạo ở Bước 2.

**Cách 2 — Clone repo** *(recommended cho dev/contribute)*

```bash
git clone https://github.com/tieupham267/secops.git
cd secops
claude --plugin-dir .
```

Data đã có sẵn trong repo, có thể bỏ qua Bước 2.

### Nâng cấp từ secops-toolkit (v1)

Nếu đã cài phiên bản cũ với tên `secops-toolkit`, cần gỡ và cài lại.

Gỡ phiên bản cũ (chọn đúng scope đã cài):

```text
# Nếu cài ở user scope (global)
/plugin uninstall secops-toolkit@secops --scope user

# Nếu cài ở project scope
/plugin uninstall secops-toolkit@secops --scope project
```

Cài lại với tên mới:

```text
/plugin install secops@secops
```

Data (context, workflows, references) không bị ảnh hưởng — chỉ đổi tên plugin. Commands đổi từ `/secops-toolkit:*` thành `/secops:*`.

### Update plugin

```text
/plugin update secops@secops
```

Plugin sẽ pull phiên bản mới nhất từ GitHub. Data không bị ảnh hưởng.

### Gỡ cài đặt

```text
# Chọn đúng scope đã cài
/plugin uninstall secops@secops --scope user
/plugin uninstall secops@secops --scope project
```

Gỡ plugin khỏi Claude Code. Data tại `context/`, `workflows/`, `references/` vẫn được giữ nguyên — xóa thủ công nếu muốn.

Gỡ marketplace (nếu không dùng nữa):

```text
/plugin marketplace remove secops
```

### Verify cài đặt

```text
/secops:run --list
```

Nếu thấy danh sách workflows → cài đặt thành công.

---

## Bước 2: Khởi tạo data

> **Bỏ qua bước này** nếu đã clone repo (Cách 2 ở Bước 1) — data có sẵn.

Plugin lưu data vào 3 folders: `context/`, `workflows/`, `references/`. Bạn chọn vị trí lưu khi chạy lần đầu:

```text
/secops:setup-profile
```

Plugin sẽ hỏi:

```text
Bạn muốn lưu data ở đâu?

1. Trong project hiện tại (./context, ./workflows, ./references) — mặc định
2. Chỉ định folder riêng (dùng chung cho nhiều projects)

Chọn [1/2]:
```

### Option 1: Trong project hiện tại (default)

Không cần config. Folders được tạo trong working directory:

```text
my-project/
├── context/                    ➕ Tạo mới
│   ├── company-profile.yaml
│   ├── org-docs/
│   └── process-docs/
├── workflows/                  ➕ Tạo mới + copy 10 default workflows
│   ├── defaults/
│   └── ...
├── references/                 ➕ Tạo mới
│   ├── regulations/
│   ├── standards/
│   └── policies/
└── (project files)
```

### Option 2: Folder riêng (dùng chung nhiều projects)

Paths được lưu vào global config `~/.claude/secops.yaml`. Mọi session sau tự đọc file này:

```yaml
# ~/.claude/secops.yaml
# Windows: C:\Users\<username>\.claude\secops.yaml
context_dir: C:\SecOps-Data\context
workflows_dir: C:\SecOps-Data\workflows
references_dir: C:\SecOps-Data\references
```

```text
C:\SecOps-Data\                     ← folder riêng (dùng chung)
├── context/
│   ├── company-profile.yaml
│   ├── org-docs/
│   └── process-docs/
├── workflows/
│   ├── defaults/
│   └── ...
├── references/
│   ├── regulations/
│   ├── standards/
│   └── policies/

C:\Projects\app-a\                  ← project A  ┐
C:\Projects\app-b\                  ← project B  ├─ dùng chung SecOps-Data
C:\Projects\app-c\                  ← project C  ┘
```

### Thay đổi paths sau này

Dùng `/secops:config` bất kỳ lúc nào:

```text
/secops:config                                          # Xem config hiện tại
/secops:config context_dir C:\new-path\context           # Đổi context
/secops:config workflows_dir C:\new-path\workflows       # Đổi workflows
/secops:config references_dir C:\new-path\references     # Đổi references
/secops:config show-paths                                # Xem resolved paths + file status
/secops:config reset                                     # Xóa config, quay về working dir
```

---

## Bước 3: Setup Company Profile

Company profile chứa thông tin tech stack, security tools, compliance requirements. Tất cả agents tự động đọc để tailored output.

### Cách 1: Tự động từ org documents *(recommended)*

Đặt tài liệu tổ chức vào `context/org-docs/`:

| File ví dụ | Nội dung |
| --- | --- |
| `tech-stack.md` | Danh sách công nghệ: servers, databases, tools |
| `security-tools.md` | SIEM, EDR, firewall, scanner đang dùng |
| `org-chart.md` (hoặc `.png`) | Sơ đồ tổ chức, phòng ban |
| `hr-teams.md` | Danh sách team security, headcount |
| `compliance-status.md` | Chứng chỉ đã có, audit schedule |
| `network-diagram.md` | Sơ đồ mạng (hoặc screenshot) |

> Không cần format chuẩn — viết tự nhiên, AI sẽ extract thông tin.
> **Quan trọng**: Redact credentials/secrets trước khi đặt vào.

Chạy:

```text
/secops:setup-profile
```

Plugin hiển thị **diff** so sánh profile hiện tại vs mới → confirm → lưu vào `context/company-profile.yaml`.

### Cách 2: Điền trực tiếp

Mở `context/company-profile.yaml` và điền các fields. Ưu tiên:

- `company` — tên, ngành, sản phẩm
- `infrastructure` — cloud/on-prem, compute, OS
- `cicd` — platform, source control
- `security` — SIEM, EDR, firewall, identity
- `compliance` — frameworks, certifications

### Cách 3: Nhờ Claude điền qua Q&A

```text
Đọc file context/company-profile.yaml, tôi sẽ trả lời câu hỏi để bạn điền giúp.
```

---

## Bước 4: Setup Org Structure & Escalation

Org mapping giúp workflows gán action items đúng phòng ban + đúng người.

### Điền `org_mapping`

Mở `context/company-profile.yaml`, tìm section `org_mapping`:

```yaml
org_mapping:
  soc:
    department: "Phòng GSANM"          # Tên phòng ban thực tế
    lead: "Nguyễn Văn A"               # Trưởng phòng / contact
  network:
    department: "Phòng Hạ tầng"
    lead: "Trần Văn B"
  devops:
    department: "Phòng DevOps"
    lead: "Lê Văn C"
  # ... thêm các phòng ban khác
```

### Điền `escalation`

```yaml
escalation:
  - severity: CRITICAL
    notify: ["CISO", "CTO", "CEO"]
    channel: "Slack #incident-critical + Phone call"
    sla: "15 phút"
  - severity: HIGH
    notify: ["CISO", "IT Director"]
    channel: "Slack #security-alerts"
    sla: "1 giờ"
  # ... thêm các mức severity khác
```

> Để trống nếu chưa có → workflows dùng tên generic và flag "(chưa xác định phòng ban)".

---

## Bước 5: Setup Workflows

### Default workflows (sẵn sàng dùng ngay)

Plugin đi kèm 10 default workflows:

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

### Tạo custom workflows từ quy trình nội bộ

Nếu tổ chức đã có SOPs/playbooks/runbooks:

1. Đặt files vào `context/process-docs/`:

   | File ví dụ | Workflow sẽ tạo |
   | --- | --- |
   | `incident-response-plan.md` | `workflows/ir/` |
   | `change-management-sop.md` | `workflows/grc/` |
   | `access-review-process.md` | `workflows/grc/` |
   | `phishing-response.md` | `workflows/soc/` |

2. Chạy:

   ```text
   /secops:generate-workflows
   ```

3. Plugin hiển thị preview + **diff** cho workflows đã tồn tại → confirm → tạo/cập nhật

> Custom workflows tự động **override** default workflows cùng loại.

### Cập nhật khi quy trình thay đổi

1. Sửa/thêm files trong `context/process-docs/`
2. Chạy lại `/secops:generate-workflows`
3. Review diff → confirm

---

## Bước 6: Thêm tài liệu tham chiếu

Plugin đi kèm knowledge base trong `skills/` (bundled). Folder `references/` cho phép bạn **bổ sung hoặc cập nhật** mà không sửa plugin.

### Cấu trúc `references/`

| Folder | Nội dung | Ví dụ |
| --- | --- | --- |
| `references/regulations/` | Luật, NĐ, TT bổ sung/cập nhật | TT mới NHNN, NĐ sửa đổi |
| `references/standards/` | ISO, PCI, NIST controls bổ sung | PCI-DSS v4.0, ISO 27001:2022 controls |
| `references/policies/` | Chính sách nội bộ công ty | ISMS policy, acceptable use, access control |

### Resolution order

Agents tra cứu theo thứ tự:

1. **`skills/`** (bundled) — knowledge base chuẩn đi kèm plugin
2. **`references/`** (user) — bổ sung hoặc override
3. **Web search** — chỉ khi cả 2 nguồn trên không đủ

Nếu cùng chủ đề có trong cả `skills/` và `references/` → ưu tiên `references/` (mới hơn, cụ thể hơn).

### Knowledge base bundled sẵn

| Văn bản | Vị trí trong `skills/` |
| --- | --- |
| Luật An ninh mạng 2018 | `skills/vietnam-regulations/luat/anm-2018.md` |
| Luật ATTT mạng 2015 | `skills/vietnam-regulations/luat/attt-2015.md` |
| NĐ 13/2023 (PDPA) | `skills/vietnam-regulations/nghi-dinh/nd-13-2023.md` |
| NĐ 85/2016 (Cấp độ ATTT) | `skills/vietnam-regulations/nghi-dinh/nd-85-2016.md` |
| NĐ 53/2022 (Hướng dẫn Luật ANM) | `skills/vietnam-regulations/nghi-dinh/nd-53-2022.md` |
| TT 09/2020/TT-NHNN (Ngân hàng) | `skills/vietnam-regulations/thong-tu/tt-09-2020-nhnn.md` |
| TT 12/2022/TT-BTTTT (Cấp độ) | `skills/vietnam-regulations/thong-tu/tt-12-2022-btttt.md` |
| ISO 27001, NIST CSF, CIS v8 | `skills/compliance-frameworks/SKILL.md` |

### Thêm tài liệu

Đặt file `.md` vào folder phù hợp trong `references/`. Ví dụ:

```text
# Thêm thông tư mới
references/regulations/tt-20-2018-nhnn.md

# Thêm ISMS policy nội bộ
references/policies/isms-access-control.md
references/policies/isms-incident-management.md

# Thêm PCI-DSS controls chi tiết
references/standards/pci-dss-v4-requirements.md
```

Hoặc nhờ Claude:

```text
Thêm Thông tư 20/2018/TT-NHNN vào references/regulations/
```

---

## Bước 7: Cài Office Document Skills *(tùy chọn)*

Cần khi xuất tài liệu dạng Word (.docx), PowerPoint (.pptx), hoặc Excel (.xlsx).

> Bỏ qua nếu chỉ cần output Markdown.

### Khi nào cần?

- Báo cáo đánh giá rủi ro gửi NHNN (.docx)
- Slide trình bày cho Board (.pptx)
- Risk register, vulnerability tracker (.xlsx)
- Policy/SOP theo template công ty (.docx)

### Cài Office Document Skills

```text
# Đăng ký marketplace
/plugin marketplace add anthropics/skills

# Cài document-skills
/plugin install document-skills@anthropic-agent-skills
```

Hoặc qua UI: `/plugin` → **Browse and install plugins** → **anthropic-agent-skills** → **document-skills** → **Install now**

### Dependencies

| Skill | Cài đặt |
| --- | --- |
| **docx** | `npm install -g docx` |
| **pptx** | `npm install -g pptxgenjs` và `pip install "markitdown[pptx]" Pillow` |
| **xlsx** | `pip install openpyxl pandas` |

LibreOffice *(PDF conversion)*:

```bash
# Ubuntu/Debian
sudo apt install libreoffice-calc libreoffice-writer libreoffice-impress

# macOS
brew install --cask libreoffice

# Windows — download từ libreoffice.org
```

### Verify dependencies

```bash
node -e "require('docx'); console.log('docx OK')"
node -e "require('pptxgenjs'); console.log('pptx OK')"
python -c "import openpyxl; print('xlsx OK')"
```

### Cách hoạt động

Agents tự quyết định khi nào dùng Office format dựa vào context. Nếu chưa cài skill mà user yêu cầu → agent output Markdown + thông báo cài skill.

---

## Bước 8: Verify & Test

### Chạy test suite

```bash
bash tests/run-all.sh
```

5 layers phải pass:

| Layer | Kiểm tra |
| --- | --- |
| 1 — Structural Integrity | Cấu trúc plugin, frontmatter, YAML schemas |
| 2 — Hook Functionality | Mỗi hook script block/allow đúng |
| 3 — Output Quality | Agents có đủ sections, bilingual |
| 4 — Orchestration Flow | Routing, workflow uniqueness, chain consistency |
| 5 — Plugin Security | Không secrets, không injection |

### Test thử workflow

```text
/secops:run alert-triage
```

Orchestrator hỏi input → trả lời → nhận output tailored cho tech stack → setup thành công.

### Test hook

```text
Tạo file test.txt có nội dung: password = "MySecret123"
```

Hook phải block và hiện thông báo `[SECURITY]`.

---

## Quick Reference

### Commands

| Command | Mục đích |
| --- | --- |
| `/secops:run <workflow>` | Chạy workflow cụ thể |
| `/secops:run <mô tả>` | Mô tả tự nhiên → orchestrator tự chọn workflow |
| `/secops:run --list` | Liệt kê tất cả workflows |
| `/secops:setup-profile` | Tạo/cập nhật company profile từ org docs |
| `/secops:generate-workflows` | Tạo/cập nhật workflows từ process docs |
| `/secops:config` | Xem/sửa data paths (context, workflows, references) |

### Environment Variable

| Biến | Mục đích | Giá trị |
| --- | --- | --- |
| `SECOPS_PROFILE` | Mức độ nghiêm ngặt của hooks | `dev` / `standard` *(default)* / `strict` |

```bash
SECOPS_PROFILE=dev claude        # Nhẹ — chỉ check secrets
SECOPS_PROFILE=strict claude     # Nghiêm ngặt — block cả warnings
```

### Global Config

File `~/.claude/secops.yaml` — khai báo custom paths cho data folders:

```yaml
context_dir: C:\SecOps-Data\context
workflows_dir: C:\SecOps-Data\workflows
references_dir: C:\SecOps-Data\references
```

Không có file này → dùng working directory mặc định.

### Data Folders

| Folder | Nội dung | Cách tạo |
| --- | --- | --- |
| `context/company-profile.yaml` | Tech stack, org mapping, escalation | `/secops:setup-profile` |
| `context/org-docs/` | Tài liệu tổ chức | User đặt files |
| `context/process-docs/` | SOPs, playbooks, runbooks | User đặt files |
| `workflows/defaults/` | 10 default workflow templates | `/secops:setup-profile` *(copy từ plugin)* |
| `workflows/<category>/` | Custom workflows | `/secops:generate-workflows` |
| `references/regulations/` | Luật, NĐ, TT bổ sung | User đặt files |
| `references/standards/` | ISO, PCI, NIST bổ sung | User đặt files |
| `references/policies/` | ISMS, chính sách nội bộ | User đặt files |

---

## Tài liệu liên quan

| Tài liệu | Nội dung |
| --- | --- |
| [CLAUDE.md](CLAUDE.md) | Technical reference — architecture, design patterns, rules |
| [DEVELOPMENT.md](DEVELOPMENT.md) | Hướng dẫn phát triển và contribute plugin |
| `workflows/SCHEMA.md` | Format YAML cho workflow templates |
| `context/org-docs/README.md` | Hướng dẫn đặt tài liệu tổ chức |
| `context/process-docs/README.md` | Hướng dẫn đặt SOPs/playbooks |
