# SecOps Plugin — Getting Started

Hướng dẫn cài đặt và setup plugin secops cho team cybersecurity.
Sau khi hoàn thành, plugin sẽ được tailored cho tổ chức của bạn.

## Tổng quan

```
Bước 1: Cài đặt plugin                      (5 phút)
Bước 2: Setup company profile               (15 phút)
Bước 3: Setup org structure                  (10 phút)
Bước 4: Setup workflows                      (10 phút)
Bước 5: Cập nhật regulations                 (5 phút)
Bước 6: Cài Office Document Skills (tùy chọn)(10 phút)
Bước 7: Verify & test                        (5 phút)
                                              ─────────
                                      Total:  ~60 phút
```

---

## Folder `context/` nằm ở đâu?

Plugin hỗ trợ 2 cách cài đặt. **Dù cài cách nào, folder `context/` luôn nằm trong project của bạn** (working directory), KHÔNG nằm trong plugin directory.

### Cách 1: Clone repo + `--plugin-dir` (recommended cho dev)

```text
my-project/                     ← working directory (cũng là plugin dir)
├── context/                    ✅ Có sẵn khi clone
│   ├── company-profile.yaml
│   ├── org-docs/
│   └── process-docs/
├── agents/
├── workflows/
└── ...
```

### Cách 2: Cài global (recommended cho daily use)

```text
~/.claude/plugins/cache/.../secops/    ← plugin dir (tự quản lý, KHÔNG sửa)
├── agents/
├── workflows/
└── ...

C:\Projects\my-app\                    ← working directory (project của bạn)
├── context/                           ➕ Tự tạo bởi /secops:setup-profile
│   ├── company-profile.yaml
│   ├── org-docs/
│   │   └── (bạn đặt tài liệu tổ chức vào đây)
│   └── process-docs/
│       └── (bạn đặt SOPs/playbooks vào đây)
├── src/
└── ...
```

Khi cài global, lần đầu chạy `/secops:setup-profile` trong project, plugin sẽ **tự tạo** folder `context/` với cấu trúc đầy đủ. Bạn chỉ cần thêm tài liệu tổ chức vào.

> **Tip**: Thêm `context/` vào `.gitignore` của project vì chứa thông tin nhạy cảm về tổ chức.

---

## Bước 1: Cài đặt plugin

### Yêu cầu

- VS Code với extension **Claude Code** (tìm `anthropic.claude-code` trên marketplace)
- Hoặc Claude Code CLI (`npm install -g @anthropic-ai/claude-code`)
- Windows: Git Bash (cài cùng Git for Windows) — cần cho hook scripts

### Cài đặt

```bash
# Cách 1: Cài global (recommended — dùng được ở mọi project)
/plugin install github:tieupham267/secops

# Cách 2: Clone repo + plugin-dir (recommended cho dev/contribute)
git clone https://github.com/tieupham267/secops.git
cd secops
```

### Khởi động

```bash
# Nếu cài global: mở bất kỳ project nào, plugin tự load
claude

# Nếu dùng --plugin-dir:
claude --plugin-dir .

# Hoặc trong VS Code: mở folder secops → mở Claude Code panel → tự load
```

### Verify cài đặt thành công

Trong Claude Code, gõ:

```
/secops:run --list
```

Nếu thấy danh sách workflows → cài đặt thành công.

---

## Bước 2: Setup Company Profile

Company profile chứa thông tin tech stack, security tools, compliance — tất cả agents sẽ tự động đọc để tailored output.

### Cách 1: Tự động từ org documents (recommended)

1. Đặt các tài liệu tổ chức vào `context/org-docs/`:

```
context/org-docs/
├── tech-stack.md          # Danh sách công nghệ: servers, databases, tools
├── security-tools.md      # SIEM, EDR, firewall, scanner đang dùng
├── org-chart.md (hoặc .png)  # Sơ đồ tổ chức, phòng ban
├── hr-teams.md            # Danh sách team security, headcount
├── compliance-status.md   # Chứng chỉ đã có, audit schedule
├── network-diagram.md     # Sơ đồ mạng (hoặc screenshot)
└── ...                    # Bất kỳ doc nào mô tả tổ chức
```

> Không cần format chuẩn — viết tự nhiên, AI sẽ extract thông tin.
> **Quan trọng**: Redact credentials/secrets trước khi đặt vào.

2. Chạy:

```
/secops:setup-profile
```

3. Review kết quả trong `context/company-profile.yaml` → chỉnh sửa nếu cần.

### Cách 2: Điền trực tiếp

Mở `context/company-profile.yaml` và điền các fields. Ưu tiên điền:

- `company` — tên, ngành, sản phẩm
- `infrastructure` — cloud/on-prem, compute, OS
- `cicd` — platform, source control
- `security` — SIEM, EDR, firewall, identity
- `compliance` — frameworks, certifications, VN regulations

Xem comments trong file để biết giá trị hợp lệ cho mỗi field.

### Cách 3: Nhờ Claude điền

```
Đọc file context/company-profile.yaml, tôi sẽ trả lời câu hỏi để bạn điền giúp.
```

---

## Bước 3: Setup Org Structure

Org mapping giúp workflows gán action items đúng phòng ban + đúng người.

### Điền org_mapping trong company-profile.yaml

Mở `context/company-profile.yaml`, tìm section `org_mapping` và điền:

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
  # ... điền các phòng ban khác
```

### Điền escalation matrix

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
  # ...
```

> Để trống nếu chưa có → workflows sẽ dùng tên generic và flag "(chưa xác định phòng ban)".

---

## Bước 4: Setup Workflows

### Default workflows (sẵn sàng dùng ngay)

Plugin đi kèm 10 default workflows cho các quy trình phổ biến. Dùng ngay mà không cần setup thêm:

| Default Workflow | Dùng khi |
| --- | --- |
| incident-response-default | Ứng phó sự cố (NIST 800-61) |
| data-breach-notification-default | Thông báo vi phạm DLCN (NĐ 13/2023, 72h) |
| vuln-management-default | Xử lý lỗ hổng bảo mật |
| access-review-default | Rà soát quyền truy cập |
| change-management-default | Quản lý thay đổi |
| vendor-risk-default | Đánh giá rủi ro vendor |
| bcdr-drill-default | Diễn tập BCP/DRP |
| security-awareness-default | Đào tạo nhận thức ATTT |
| risk-assessment-default | Đánh giá rủi ro CNTT |
| fraud-investigation-default | Điều tra gian lận |

### Tạo custom workflows từ quy trình nội bộ

Nếu tổ chức đã có SOPs/playbooks/runbooks:

1. Đặt files vào `context/process-docs/`:

```
context/process-docs/
├── incident-response-plan.md
├── change-management-sop.md
├── access-review-process.md
└── ...
```

2. Chạy:

```
/secops:generate-workflows
```

3. Review preview → confirm → custom workflows được tạo trong `workflows/`

> Custom workflows tự động **override** default workflows cùng loại.
> Default workflows vẫn dùng cho quy trình chưa có custom.

---

## Bước 5: Cập nhật regulations

Plugin đi kèm knowledge base quy định Việt Nam trong `skills/vietnam-regulations/`:

| Văn bản | File | Có sẵn |
| --- | --- | --- |
| Luật An ninh mạng 2018 | `luat/anm-2018.md` | ✅ |
| Luật ATTT mạng 2015 | `luat/attt-2015.md` | ✅ |
| NĐ 13/2023 (PDPA) | `nghi-dinh/nd-13-2023.md` | ✅ |
| NĐ 85/2016 (Cấp độ ATTT) | `nghi-dinh/nd-85-2016.md` | ✅ |
| NĐ 53/2022 (Hướng dẫn Luật ANM) | `nghi-dinh/nd-53-2022.md` | ✅ |
| TT 09/2020/TT-NHNN (Ngân hàng) | `thong-tu/tt-09-2020-nhnn.md` | ✅ |
| TT 12/2022/TT-BTTTT (Cấp độ) | `thong-tu/tt-12-2022-btttt.md` | ✅ |

### Thêm quy định ngành

Nếu tổ chức chịu thêm quy định khác (ngân hàng, bảo hiểm, y tế), tạo file mới:

```bash
# Ví dụ: thêm thông tư ngân hàng mới
# Tạo file trong thư mục phù hợp
```

Hoặc nhờ Claude:

```
Thêm Thông tư 20/2018/TT-NHNN vào skills/vietnam-regulations/thong-tu/
```

### Cập nhật khi quy định thay đổi

Agents đọc local files trước, chỉ web search khi không đủ. Khi quy định được sửa đổi:

1. Cập nhật file tương ứng trong `skills/vietnam-regulations/`
2. Hoặc nhờ Claude: "Cập nhật NĐ 13/2023 với nội dung sửa đổi mới nhất"

---

## Bước 6: Cài đặt Office Document Skills (tùy chọn)

Nếu cần xuất tài liệu chuyên nghiệp dạng Word (.docx), PowerPoint (.pptx), hoặc Excel (.xlsx), cài thêm skills từ Anthropic official repo.

### Tại sao cần?

Plugin secops tạo nội dung dạng Markdown — đủ cho internal working docs. Nhưng khi cần:
- Báo cáo đánh giá rủi ro gửi NHNN (.docx format chuẩn)
- Slide trình bày giải pháp bảo mật cho Board (.pptx)
- Bảng theo dõi vulnerabilities, risk register (.xlsx)
- Policy/SOP cần template format chuẩn của công ty (.docx)

→ Cần Office document skills.

### Cài đặt

Skills này do Anthropic phát triển và maintain: [github.com/anthropics/skills](https://github.com/anthropics/skills)

### Cách 1: Cài qua Plugin Marketplace (recommended)

```text
# Bước 1: Đăng ký marketplace
/plugin marketplace add anthropics/skills

# Bước 2: Cài document-skills plugin (bao gồm docx, pptx, xlsx, pdf)
/plugin install document-skills@anthropic-agent-skills
```

Hoặc cài qua UI:
1. Gõ `/plugin` → chọn **Browse and install plugins**
2. Chọn **anthropic-agent-skills**
3. Chọn **document-skills**
4. Chọn **Install now**

### Cách 2: Cài trực tiếp (nếu cách 1 không khả dụng)

```bash
claude skills add anthropics/skills/docx
claude skills add anthropics/skills/pptx
claude skills add anthropics/skills/xlsx
```

### Dependencies cần cài

| Skill | Dependencies | Lệnh cài |
| --- | --- | --- |
| **docx** | docx-js (npm), pandoc, LibreOffice | `npm install -g docx` |
| **pptx** | pptxgenjs (npm), markitdown, LibreOffice, Poppler | `npm install -g pptxgenjs` và `pip install "markitdown[pptx]" Pillow` |
| **xlsx** | openpyxl, pandas (Python), LibreOffice | `pip install openpyxl pandas` |

LibreOffice (dùng cho PDF conversion và formula recalculation):

```bash
# Ubuntu/Debian
sudo apt install libreoffice-calc libreoffice-writer libreoffice-impress

# macOS
brew install --cask libreoffice

# Windows — download từ libreoffice.org
```

Poppler (dùng cho PPTX → image conversion để QA):

```bash
# Ubuntu/Debian
sudo apt install poppler-utils

# macOS
brew install poppler

# Windows — download từ github.com/oschwartz10612/poppler-windows
```

### Cách hoạt động

Skills này **không phải convert từ Markdown** — agent soạn thảo trực tiếp:

| Skill | Cách tạo file | Kết quả |
| --- | --- | --- |
| **docx** | Agent viết JavaScript dùng `docx-js` → tạo .docx với headings, tables, TOC, images, headers/footers | File Word chuyên nghiệp, format đẹp |
| **pptx** | Agent viết JavaScript dùng `pptxgenjs` → tạo slides với layout, colors, images, charts | Slide deck có design, không phải bullet text |
| **xlsx** | Agent viết Python dùng `openpyxl` → tạo spreadsheet với formulas, formatting, charts | Excel có công thức, auto-calculate |

### Sử dụng với secops plugin

Sau khi cài, agents secops tự động sử dụng khi cần:

```text
# Ví dụ: Tạo báo cáo đánh giá rủi ro dạng Word
/secops:run risk-assess
→ Agent tạo nội dung → hỏi: "Xuất ra .docx?"
→ Có → Agent dùng docx skill tạo file Word chuyên nghiệp

# Ví dụ: Tạo slide trình bày security roadmap cho Board
/secops:run security-roadmap
→ Audience: Board/C-level
→ Agent dùng pptx skill tạo slide deck

# Ví dụ: Tạo bảng theo dõi action items từ công văn NHNN
/secops:run regulatory-directive
→ Agent dùng xlsx skill tạo tracker spreadsheet
```

### Verify cài đặt thành công

```bash
# Kiểm tra docx
node -e "require('docx'); console.log('docx-js OK')"

# Kiểm tra pptx
node -e "require('pptxgenjs'); console.log('pptxgenjs OK')"

# Kiểm tra xlsx
python -c "import openpyxl; print('openpyxl OK')"

# Kiểm tra LibreOffice
python scripts/office/soffice.py --version 2>/dev/null || soffice --version
```

### Lưu ý

- Skills này là **optional** — plugin hoạt động bình thường với Markdown output mà không cần cài
- Agent tự quyết định khi nào dùng Office format dựa vào context (audience, document type)
- Nếu chưa cài skill mà user yêu cầu .docx → agent sẽ output Markdown + thông báo cài skill

---

## Bước 7: Verify & Test tổng thể

### Chạy test suite

```bash
bash tests/run-all.sh
```

Tất cả 5 layers phải pass:
- Layer 1: Structural Integrity — cấu trúc plugin đúng
- Layer 2: Hook Functionality — hooks chạy đúng
- Layer 3: Output Quality — agents có đúng sections
- Layer 4: Orchestration Flow — routing + workflows consistent
- Layer 5: Plugin Security — không có secrets trong codebase

### Test thử workflow

```
/secops:run alert-triage
```

Nếu orchestrator hỏi input → trả lời → nhận output tailored cho tech stack của bạn → setup thành công.

### Test hook

Tạo file test chứa secret:

```
Tạo file test.txt có nội dung: password = "MySecret123"
```

Hook phải block và hiện thông báo `[SECURITY]`.

---

## Quick Reference — Các commands chính

| Command | Mục đích |
| --- | --- |
| `/secops:run <workflow>` | Chạy workflow cụ thể |
| `/secops:run <mô tả>` | Mô tả bằng ngôn ngữ tự nhiên → orchestrator tự chọn workflow |
| `/secops:run --list` | Liệt kê tất cả workflows |
| `/secops:setup-profile` | Tạo/cập nhật company profile từ org docs |
| `/secops:generate-workflows` | Tạo workflows từ process docs |

## Hook Profiles

```bash
SECOPS_PROFILE=dev claude --plugin-dir .       # Nhẹ — chỉ check secrets
SECOPS_PROFILE=standard claude --plugin-dir .  # Mặc định — tất cả checks
SECOPS_PROFILE=strict claude --plugin-dir .    # Nghiêm ngặt — block cả warnings
```

## Cần hỗ trợ?

- Xem [CLAUDE.md](CLAUDE.md) cho technical reference
- Xem [DEVELOPMENT.md](DEVELOPMENT.md) cho hướng dẫn phát triển plugin
- Xem `workflows/SCHEMA.md` cho format workflow YAML
- Xem `context/org-docs/README.md` và `context/process-docs/README.md` cho hướng dẫn đặt documents
