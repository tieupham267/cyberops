# SecOps Plugin — Development Workflow

Workflow phát triển plugin **secops** với VS Code + Claude Code.

## 1. Setup ban đầu

Giải nén plugin, mở VS Code, và khởi động Claude Code:

```bash
# Giải nén plugin
unzip secops-plugin.zip
cd secops

# Khởi tạo git repo
git init
git add .
git commit -m "feat: secops plugin v1.0.0"

# Mở VS Code
code .
```

Trong VS Code, cài extension **Claude Code** từ marketplace (tìm `anthropic.claude-code`). Click biểu tượng Spark ở sidebar trái để mở Claude Code panel.

## 2. Chạy plugin ở chế độ dev

Dùng flag `--plugin-dir` để load plugin mà không cần cài chính thức — rất tiện cho development.

Trong terminal VS Code:

```bash
claude --plugin-dir .
```

Mỗi khi sửa file, chạy `/reload-plugins` để hot-reload mà không cần restart session.

## 3. Workflow phát triển hàng ngày

Khi đã ở trong Claude Code (trong VS Code), bạn có thể nhờ Claude phát triển chính plugin này. Ví dụ:

**Thêm agent mới:**

```text
Đọc file agents/soc-analyst.md để hiểu cấu trúc,
sau đó tạo agent mới tên "pentest-planner" cho planning penetration test
```

**Cải thiện agent hiện có:**

```text
Đọc agents/threat-modeler.md và bổ sung thêm section về
threat modeling cho cloud-native applications (Kubernetes, serverless)
```

**Thêm skill mới:**

```text
Tạo skill mới trong skills/detection-engineering/SKILL.md
về viết Sigma rules, YARA rules, và Snort rules
```

**Thêm command mới:**

```text
Tạo command /secops:daily-brief trong commands/daily-brief.md
để tạo bản tóm tắt tình hình an ninh mạng hàng ngày
```

**Test hook:**

```text
Tạo file test.md có chứa "password = MySecret123"
rồi xem hook check-secrets.sh có block không
```

## 4. Dùng `@` để reference files

Khi gõ `@` theo sau tên file, Claude Code đọc nội dung file đó và có thể trả lời hoặc chỉnh sửa. Ví dụ:

```text
@agents/soc-analyst.md thêm section về cloud log analysis cho AWS CloudTrail
@hooks/hooks.json thêm hook mới chặn git push lên branch main
@skills/compliance-frameworks/SKILL.md cập nhật thêm PCI-DSS v4.0 controls
```

## 5. Validate plugin

```bash
# Kiểm tra cấu trúc
claude plugin validate .

# Xem tất cả components đã load
/agents         # list agents
/secops:incident   # test command
```

## 6. Push và distribute

```bash
# Commit changes
git add .
git commit -m "feat: add pentest-planner agent"
git push origin main

# Team members install
# /plugin install github:YOUR_USERNAME/secops
```

## Tips thực tế

### Dùng worktree cho parallel development

Flag `-w` khởi động Claude Code trong isolated worktree riêng — mỗi worktree có file và branch độc lập, tránh xung đột khi nhiều instance cùng chạy.

```bash
# Session 1: phát triển agent mới
claude -w --plugin-dir .

# Session 2: sửa hooks (terminal khác)
claude -w --plugin-dir .
```

### Dùng `CLAUDE.md` cho context

File `CLAUDE.md` ở root plugin giúp Claude Code hiểu project structure và conventions. Xem [CLAUDE.md](CLAUDE.md) để biết chi tiết.

### Hook profiles

Dùng biến `SECOPS_PROFILE` để điều chỉnh mức độ nghiêm ngặt của hooks:

```bash
# Dev mode — chỉ check secrets, bỏ qua warnings
SECOPS_PROFILE=dev claude --plugin-dir .

# Standard (mặc định) — tất cả checks
claude --plugin-dir .

# Strict — tất cả checks + block warnings (cho audit/production)
SECOPS_PROFILE=strict claude --plugin-dir .
```

### Custom skills cho team members

Team members có thể thêm skills riêng vào `~/.claude/skills/` mà không cần sửa plugin:

```bash
# Tạo skill cá nhân
mkdir -p ~/.claude/skills/my-custom-detection/
# Viết SKILL.md với YAML frontmatter
```

Skills trong `~/.claude/skills/` sẽ override skills cùng tên trong plugin nếu có xung đột.

### Vòng lặp dev

Mở VS Code → mở folder `secops` → chạy `claude --plugin-dir .` trong terminal → nhờ Claude chỉnh sửa/thêm files → `/reload-plugins` để test → commit + push khi hài lòng.

## 7. Testing

Chạy test suite để validate plugin:

```bash
# Chạy tất cả 5 layers
bash tests/run-all.sh

# Chạy layer cụ thể
bash tests/run-all.sh 1        # Structural integrity
bash tests/run-all.sh 2        # Hook functionality
bash tests/run-all.sh 3        # Output quality
bash tests/run-all.sh 4        # Orchestration flow
bash tests/run-all.sh 5        # Plugin security

# Kết hợp nhiều layers
bash tests/run-all.sh 1 2 5
```

**Luôn chạy tests sau khi:**

- Thêm/sửa agent, workflow, hook, hoặc rule
- Sửa hook scripts
- Thêm workflow mới (kiểm tra references đúng)
- Trước khi commit

## 8. Distribution & Installation

### Lưu ý quan trọng khi distribute

- **Rules** (`rules/`) KHÔNG tự động distribute khi install plugin — cần copy thủ công hoặc dùng `--plugin-dir`.
- **Hook scripts** yêu cầu `bash` + standard Unix tools (`grep`, `stat`, `git`). Trên Windows cần Git Bash hoặc WSL.
- Document biến môi trường cần thiết (`SECOPS_PROFILE`) cho team.

### Cài đặt cho team

```bash
# Cách 1: Clone và dùng --plugin-dir (recommended cho dev)
git clone https://github.com/YOUR_USERNAME/secops.git
claude --plugin-dir ./secops

# Cách 2: Install từ GitHub (khi plugin đã stable)
# /plugin install github:YOUR_USERNAME/secops

# Cách 3: Copy thư mục trực tiếp
cp -r secops/ ~/.claude/plugins/secops/
```
