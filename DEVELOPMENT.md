# SecOps Plugin — Development Guide

Hướng dẫn phát triển và contribute plugin **secops**.

---

## Setup môi trường dev

### Clone và chạy

```bash
git clone https://github.com/tieupham267/secops.git
cd secops
claude --plugin-dir .
```

### Hot-reload khi phát triển

Mỗi khi sửa file agent, skill, command, hoặc hook → chạy `/reload-plugins` trong Claude Code để load lại mà không cần restart session.

### Dev loop

```text
Sửa file → /reload-plugins → test → sửa tiếp → hài lòng → commit
```

---

## Cấu trúc plugin

```text
secops/
├── plugin.json                 # Plugin manifest
├── agents/                     # 12 agent personas (.md + YAML frontmatter)
├── skills/                     # 8 knowledge-base skills (SKILL.md)
├── commands/                   # Slash commands (.md)
├── workflows/                  # YAML workflow templates
│   ├── defaults/               # 10 default workflows
│   ├── soc/ ir/ grc/           # Category-specific
│   └── SCHEMA.md               # YAML schema reference
├── hooks/
│   ├── hooks.json              # Hook definitions (matchers)
│   └── scripts/                # Hook shell scripts
├── rules/                      # Security rules (.md)
│   └── cybersecurity.md        # Index file
├── context/                    # Company data (gitignored)
│   └── company-profile.yaml
├── references/                 # User reference docs
│   ├── regulations/
│   ├── standards/
│   └── policies/
└── tests/                      # 5-layer test suite
```

---

## Phát triển components

### Thêm agent

Tạo `agents/<name>.md` với YAML frontmatter:

```yaml
---
name: pentest-planner
description: >
  Plans and coordinates penetration testing engagements.
tools: Read Glob Grep Bash Write Edit
model: opus
---

(Agent instructions in Markdown)
```

Cập nhật orchestrator decision matrix nếu cần routing tự động.

### Thêm skill

Tạo `skills/<name>/SKILL.md` với YAML frontmatter:

```yaml
---
name: detection-engineering
description: Sigma rules, YARA rules, Snort rules
---

(Skill content in Markdown)
```

### Thêm workflow

Tạo `workflows/<category>/<name>.yaml` theo `workflows/SCHEMA.md`:

```yaml
name: daily-security-brief
title: Bản tin an ninh mạng hàng ngày
description: >
  Tạo bản tóm tắt tình hình an ninh mạng.
category: soc
agent: soc-analyst
# ... (xem SCHEMA.md cho full format)
```

Orchestrator tự phát hiện workflows mới — không cần đăng ký thêm.

### Thêm command

Tạo `commands/<name>.md`:

```markdown
# /secops:<name> — Mô tả ngắn

(Instructions cho Claude khi user gọi command)
```

### Thêm hook

1. Thêm entry trong `hooks/hooks.json`:

   ```json
   {
     "event": "PreToolUse",
     "matcher": "Write|Edit",
     "command": "bash hooks/scripts/my-hook.sh"
   }
   ```

1. Tạo script trong `hooks/scripts/my-hook.sh`

1. Test: `claude --plugin-dir .` → trigger hook event

### Thêm rule

Tạo `rules/<domain>.md` và thêm reference trong `rules/cybersecurity.md`.

---

## Testing

### Chạy test suite

```bash
bash tests/run-all.sh          # Tất cả 5 layers
bash tests/run-all.sh 1        # Layer cụ thể
bash tests/run-all.sh 1 2 5    # Nhiều layers
```

| Layer | Kiểm tra |
| --- | --- |
| 1 — Structural Integrity | Plugin structure, frontmatter, YAML schemas, internal refs |
| 2 — Hook Functionality | Mỗi hook script với known inputs (block/allow) |
| 3 — Output Quality | Agent definitions có đủ sections, bilingual |
| 4 — Orchestration Flow | Routing coverage, workflow uniqueness, chain consistency |
| 5 — Plugin Security | Không secrets, không command injection, profile safety |

### Khi nào phải chạy tests

- Sau khi thêm/sửa agent, workflow, hook, hoặc rule
- Sau khi sửa hook scripts
- Trước khi commit

### Test thủ công

```text
# Test hook chặn secrets
Tạo file test.txt có nội dung: password = "MySecret123"

# Test workflow routing
/secops:run alert-triage

# Test command
/secops:config show-paths
```

---

## Tips phát triển

### Worktree cho parallel development

Flag `-w` chạy Claude Code trong isolated worktree — mỗi worktree có files và branch riêng:

```bash
# Session 1: phát triển agent mới
claude -w --plugin-dir .

# Session 2: sửa hooks (terminal khác)
claude -w --plugin-dir .
```

### Reference files với `@`

```text
@agents/soc-analyst.md thêm section về cloud log analysis
@hooks/hooks.json thêm hook mới chặn git push lên main
@skills/compliance-frameworks/SKILL.md cập nhật PCI-DSS v4.0
```

### Hook profiles khi dev

```bash
# Dev mode — chỉ check secrets, bỏ qua warnings
SECOPS_PROFILE=dev claude --plugin-dir .

# Strict — test full hook coverage
SECOPS_PROFILE=strict claude --plugin-dir .
```

### Custom skills cho team members

Skills cá nhân đặt trong `~/.claude/skills/` — override skills cùng tên trong plugin:

```bash
mkdir -p ~/.claude/skills/my-custom-detection/
# Viết SKILL.md với YAML frontmatter
```

---

## Distribution

### Cài cho team members

```text
# Cách 1: Từ marketplace (recommended cho end users)
/plugin marketplace add https://github.com/tieupham267/secops
/plugin install secops@secops

# Cách 2: Clone + plugin-dir (recommended cho dev)
git clone https://github.com/tieupham267/secops.git
claude --plugin-dir ./secops
```

### Lưu ý khi distribute

- **Hook scripts** yêu cầu `bash` + standard Unix tools (`grep`, `stat`, `git`). Windows cần Git Bash hoặc WSL.
- Document `SECOPS_PROFILE` env var cho team.
- Sau khi cài, team members chạy `/secops:setup-profile` để khởi tạo data.

---

## Tài liệu liên quan

| Tài liệu | Nội dung |
| --- | --- |
| [GETTING-STARTED.md](GETTING-STARTED.md) | Hướng dẫn cài đặt và setup cho end users |
| [CLAUDE.md](CLAUDE.md) | Technical reference — architecture, design patterns, rules |
| `workflows/SCHEMA.md` | YAML schema cho workflow templates |
