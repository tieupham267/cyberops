# secops — DEPRECATED

> **Plugin này đã được đổi tên thành [cyberops](https://github.com/tieupham267/cyberops).**
>
> Repo này không còn được cập nhật. Vui lòng chuyển sang repo mới.

## Migration

```text
# Gỡ secops
/plugin uninstall secops@secops --scope user
/plugin marketplace remove secops

# Cài cyberops
/plugin marketplace add https://github.com/tieupham267/cyberops
/plugin install cyberops@cyberops
```

### Thay đổi khi migrate

| Trước (secops) | Sau (cyberops) |
| --- | --- |
| `/secops:run` | `/cyberops:run` |
| `/secops:setup-profile` | `/cyberops:setup-profile` |
| `~/.claude/secops.yaml` | `~/.claude/cyberops.yaml` |
| `SECOPS_PROFILE` | `CYBEROPS_PROFILE` |

Data (context, workflows, references) không bị ảnh hưởng — chỉ đổi tên.
