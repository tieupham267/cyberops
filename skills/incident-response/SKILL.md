---
name: incident-response
description: >
  Detailed incident response procedures, playbooks, and forensic workflows. 
  Use when handling security incidents, creating IR playbooks, performing forensic 
  analysis, writing incident reports, conducting post-mortems, or any task involving 
  security incident management. Always use this skill when the incident-commander agent 
  is active or when anyone mentions "incident", "breach", "compromise", or "forensics".
---

# Incident Response Skill

## Playbook Library

Khi được yêu cầu tạo playbook, follow cấu trúc sau cho từng loại sự cố.
Mỗi playbook PHẢI có: trigger conditions, severity matrix, step-by-step actions 
với timeline, communication plan, và evidence checklist.

### Ransomware Response

**Trigger**: Ransomware note detected, mass file encryption, unusual file extensions

**DO NOT**:
- Pay ransom without legal/executive approval
- Shut down systems immediately (may lose volatile evidence)
- Communicate over potentially compromised channels

**Immediate (0-15 min)**:
1. Isolate affected systems from network (pull cable, disable WiFi — do NOT power off)
2. Identify patient zero and lateral movement scope
3. Activate IR team, notify CISO/management
4. Preserve volatile evidence (memory dump if possible)

**Short-term (15 min - 4 hours)**:
1. Identify ransomware variant (check ransom note, encrypted file extensions)
2. Check for decryptor availability (NoMoreRansom.org)
3. Assess backup integrity — are backups also compromised?
4. Contain: block C2 domains/IPs at firewall, disable compromised accounts
5. Determine data exfiltration (double extortion check)

**Recovery (4-48 hours)**:
1. Clean/rebuild affected systems from known-good images
2. Restore data from verified clean backups
3. Reset all credentials in affected scope
4. Enhanced monitoring on restored systems
5. Gradual reconnection to network

**Post-Incident**:
1. Root cause analysis
2. Update detection rules
3. Awareness training on initial vector
4. Review backup strategy

### Business Email Compromise (BEC)

**Trigger**: Fraudulent wire transfer request, executive impersonation, vendor email compromise

**Immediate**:
1. If funds transferred: Contact bank IMMEDIATELY to recall/freeze
2. Preserve email headers and full message source
3. Identify scope: which accounts compromised, which emails accessed
4. Reset compromised account credentials + revoke sessions

**Investigation**:
1. Review mail flow rules (check for auto-forwarding rules added by attacker)
2. Check login history: IP addresses, geolocation, device types
3. Search for similar phishing emails to other employees
4. Assess data exposure: what emails/attachments were accessible

### Data Breach

**Trigger**: Confirmed unauthorized access to sensitive data

**Legal/Regulatory Requirements (Vietnam)**:
- Thông báo cho cơ quan chức năng trong 72 giờ (Nghị định 13/2023/NĐ-CP)
- Thông báo cho chủ thể dữ liệu bị ảnh hưởng
- Lưu trữ evidence cho điều tra

**Key Actions**:
1. Determine what data was accessed/exfiltrated
2. Classify data (PII, financial, healthcare, trade secrets)
3. Identify number of affected individuals
4. Engage legal counsel
5. Prepare notification (regulatory + affected individuals)
6. Coordinate with PR for public communication if needed

### Supply Chain Compromise

**Trigger**: Malicious package discovered in dependency tree, compromised maintainer account, trojanized library, dependency confusion attack

**DO NOT**:
- Run `npm install` / `pip install` trên hệ thống chưa isolated (có thể trigger postinstall malware)
- Xóa `node_modules` / artifacts trước khi thu thập evidence
- Giả định scope chỉ giới hạn ở 1 package (check transitive dependencies)

**Immediate (0-30 min)**:
1. Xác nhận affected versions và safe versions từ advisory
2. Block egress traffic tới C2 domains/IPs trên firewall/proxy/DNS
3. Identify blast radius: repos, CI/CD pipelines, build servers, dev machines đã install affected versions
4. Preserve evidence: lock files, `node_modules/`, CI/CD logs, build artifacts (TRƯỚC khi cleanup)

**Short-term (30 min - 4 hours)**:
1. Scan toàn bộ repos cho affected packages:
   ```bash
   # npm
   grep -r "affected-package" package-lock.json yarn.lock
   npm ls affected-package
   # pip
   pip list | grep affected-package
   pip show affected-package  # check dependencies
   # Check vendored dependencies
   find . -path "*/node_modules/affected-package" -type d
   ```
2. Check RAT artifacts theo OS:
   - macOS: `/Library/Caches/com.apple.act.mond`, unexpected LaunchAgents
   - Windows: `%PROGRAMDATA%\wt.exe`, `%PROGRAMDATA%\system.bat`, Registry Run keys
   - Linux: `/tmp/ld.py`, unexpected cron jobs, `/tmp/` executables
3. Audit CI/CD pipeline runs trong thời gian nhiễm:
   - Xác định jobs nào đã install affected version
   - Check CI/CD secrets có bị exfiltrate không
   - Review build artifacts đã publish trong thời gian nhiễm
4. Kiểm tra postinstall scripts trong malicious packages
5. Check DNS logs cho C2 beacon patterns

**Eradication (4-24 hours)**:
1. Downgrade/upgrade tất cả instances về safe version
2. Xóa malicious packages khỏi `node_modules/`, caches, registries
3. Purge CI/CD caches: Docker layer cache, npm cache, pip cache, build artifact cache
4. Regenerate lock files từ trusted sources
5. Xóa RAT artifacts và persistence mechanisms (Registry keys, cron jobs, LaunchAgents)
6. **Rotate ALL credentials** trên hệ thống bị compromise (bắt buộc, không ngoại lệ)

**Recovery & Verification**:
1. Rebuild CI/CD artifacts từ clean state
2. Verify lock files chỉ chứa known-good packages
3. Run dependency audit: `npm audit`, `pip-audit`, `trivy fs .`
4. Kiểm tra không còn postinstall scripts bất thường
5. Enhanced monitoring: SIEM alerts cho C2 patterns, EDR cho RAT indicators
6. Regression testing: verify applications hoạt động đúng sau patch

**Post-Incident**:
1. Root cause: compromised credentials? Dependency confusion? Typosquatting?
2. Update dependency management policy: pinning, lockfile enforcement, install script restrictions
3. Implement SBOM generation và provenance verification
4. Review CI/CD security: short-lived tokens, least-privilege, SLSA compliance

### Supply Chain Evidence Checklist

Khi thu thập evidence cho supply chain incident, collect theo thứ tự:

**Package Manager Evidence**:
```bash
# Lock files (TRƯỚC khi regenerate)
cp package-lock.json /evidence/package-lock.json.bak
cp yarn.lock /evidence/yarn.lock.bak
cp Pipfile.lock /evidence/Pipfile.lock.bak

# Installed packages snapshot
npm ls --all --json > /evidence/npm-dependency-tree.json
pip freeze > /evidence/pip-freeze.txt
pip list --format=json > /evidence/pip-list.json

# Package content (malicious package)
tar czf /evidence/malicious-package.tar.gz node_modules/affected-package/

# Postinstall scripts
cat node_modules/affected-package/package.json | jq '.scripts' > /evidence/package-scripts.json

# npm/pip config (check registry URLs)
npm config list > /evidence/npm-config.txt
cat ~/.npmrc > /evidence/npmrc.txt 2>/dev/null
cat pip.conf > /evidence/pip-conf.txt 2>/dev/null
```

**CI/CD Evidence**:
```bash
# GitHub Actions
gh run list --limit 50 --json databaseId,createdAt,status,conclusion > /evidence/gh-runs.json
gh run view <run-id> --log > /evidence/gh-run-<id>.log

# GitLab CI
curl --header "PRIVATE-TOKEN: $TOKEN" "$GITLAB/api/v4/projects/$PID/pipelines?per_page=50" > /evidence/gl-pipelines.json

# Build artifacts list
ls -la dist/ build/ .next/ > /evidence/build-artifacts.txt

# CI/CD secrets audit (list names only, NOT values)
gh secret list > /evidence/gh-secrets-list.txt
```

**Registry Evidence**:
```bash
# npm registry audit log (self-hosted)
# Check package publish history
npm view affected-package time --json > /evidence/package-publish-history.json
npm view affected-package dist.tarball > /evidence/package-tarball-url.txt

# Docker registry
docker image history <image> > /evidence/docker-history.txt
docker inspect <image> > /evidence/docker-inspect.json
```

**Network Evidence (C2 Communication)**:
```bash
# DNS logs for C2 domains
# Firewall/proxy logs for C2 IPs
# NetFlow data for beacon patterns (60s intervals typical)
```

**RAT Artifact Evidence**:
```powershell
# Windows
Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" > evidence\registry-run.txt
Get-ChildItem "$env:PROGRAMDATA" -Filter "*.bat" > evidence\programdata-bat.txt
Get-ChildItem "$env:PROGRAMDATA" -Filter "wt.exe" > evidence\suspicious-exe.txt
Get-Content "$env:PROGRAMDATA\system.bat" > evidence\persistence-script.txt 2>$null

# macOS
ls -la /Library/Caches/com.apple.* > /evidence/mac-caches.txt
launchctl list > /evidence/mac-launchctl.txt

# Linux
ls -la /tmp/*.py > /evidence/tmp-python.txt
crontab -l > /evidence/crontab.txt
```

## Forensic Evidence Collection

### Order of Volatility (collect in this order):
1. CPU registers, cache
2. Memory (RAM)
3. Network connections, ARP cache, routing table
4. Running processes
5. Disk contents
6. Remote logging data
7. Physical configuration
8. Archival media

### Evidence Handling Rules:
- Document EVERYTHING: who, what, when, where, why
- Use write-blockers for disk imaging
- Calculate and record hashes (SHA-256) for all evidence
- Maintain chain of custody log
- Store evidence in secure, access-controlled location
- NEVER work on original evidence — only copies

### Linux Volatile Evidence Commands:
```bash
# Memory and processes
date > /evidence/timestamp.txt
cat /proc/meminfo > /evidence/meminfo.txt
ps auxwww > /evidence/processes.txt
lsof -i > /evidence/open_files_network.txt
netstat -tulnp > /evidence/network_connections.txt
ss -tulnp > /evidence/socket_stats.txt

# Network
arp -a > /evidence/arp_cache.txt
ip route > /evidence/routing_table.txt
iptables -L -n -v > /evidence/firewall_rules.txt
cat /etc/resolv.conf > /evidence/dns_config.txt

# Users and auth
w > /evidence/logged_in_users.txt
last -a > /evidence/login_history.txt
cat /etc/passwd > /evidence/user_accounts.txt
cat /var/log/auth.log > /evidence/auth_log.txt

# System
uname -a > /evidence/system_info.txt
uptime > /evidence/uptime.txt
cat /etc/crontab > /evidence/cron_jobs.txt
systemctl list-units --type=service > /evidence/services.txt
```

### Windows Volatile Evidence (PowerShell):
```powershell
# Processes and network
Get-Process | Export-Csv evidence\processes.csv
Get-NetTCPConnection | Export-Csv evidence\network.csv
Get-NetNeighbor | Export-Csv evidence\arp.csv

# Users
query user > evidence\logged_users.txt
Get-WinEvent -LogName Security -MaxEvents 1000 | Export-Csv evidence\security_log.csv

# Scheduled tasks
Get-ScheduledTask | Export-Csv evidence\scheduled_tasks.csv

# Autoruns
Get-ItemProperty HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run > evidence\autoruns.txt
```

## Incident Report Template

Khi viết incident report, LUÔN follow cấu trúc này:

```
# Incident Report: [INC-YYYY-NNNN]

## 1. Incident Summary
| Field | Detail |
|-------|--------|
| Incident ID | |
| Date/Time Detected | |
| Date/Time Contained | |
| Date/Time Resolved | |
| Duration | |
| Severity | [Critical/High/Medium/Low] |
| Category | [Ransomware/BEC/Breach/Malware/DDoS/...] |
| Status | [Open/Contained/Eradicated/Recovered/Closed] |

## 2. Executive Summary
[3-5 câu mô tả ngắn gọn: gì xảy ra, impact, status hiện tại]

## 3. Timeline
| Timestamp | Event | Actor | Source |
|-----------|-------|-------|--------|
| | | | |

## 4. Impact Assessment
- Systems affected:
- Data affected:
- Users affected:
- Business impact:
- Financial impact (estimated):

## 5. Root Cause Analysis
[5 Whys hoặc Fishbone analysis]

## 6. Actions Taken
[Chi tiết response actions theo timeline]

## 7. Lessons Learned
[Gì tốt, gì cần cải thiện]

## 8. Recommendations
| # | Recommendation | Owner | Priority | Deadline |
|---|---------------|-------|----------|----------|
| | | | | |

## 9. Appendix
- Evidence inventory
- IOCs extracted
- Communication log
```

## Supply Chain Incident — External Notification Templates

Khi supply chain incident ảnh hưởng đến customers hoặc downstream consumers, sử dụng templates sau.

### Customer/Partner Notification

```
# Security Advisory: [Tên sự cố]
## TLP: [AMBER/GREEN]

Kính gửi [Tên đối tác/khách hàng],

### Tóm tắt sự cố
[Mô tả ngắn gọn: gì xảy ra, khi nào phát hiện, scope ảnh hưởng]

### Ảnh hưởng đến quý đối tác
- Hệ thống/dịch vụ bị ảnh hưởng: [liệt kê]
- Dữ liệu bị ảnh hưởng: [loại dữ liệu, có/không bao gồm PII]
- Thời gian exposure: [từ — đến]

### Hành động chúng tôi đã thực hiện
1. [Containment actions]
2. [Eradication actions]
3. [Recovery status]

### Hành động khuyến nghị cho quý đối tác
1. [Specific actions: rotate credentials, check systems, etc.]
2. [IOCs để tự kiểm tra]
3. [Safe versions để upgrade]

### Thông tin liên hệ
- Security team: [email/phone]
- Escalation: [contact]
- Cập nhật tiếp theo: [thời gian dự kiến]

### Timeline thông báo
| Thời gian | Nội dung |
|-----------|----------|
| [T+0] | Phát hiện sự cố |
| [T+Xh] | Containment hoàn tất |
| [T+Xh] | Thông báo này (initial notification) |
| [T+Xd] | Update tiếp theo (dự kiến) |
```

### Responsible Disclosure (cho upstream maintainers)

```
Subject: [SECURITY] Vulnerability/Compromise Report — [Package Name]

## Summary
- Package: [name@version]
- Registry: [npm/PyPI/Maven/etc.]
- Type: [Compromised maintainer / Malicious dependency / Typosquatting]
- Severity: [Critical/High]
- Discovery date: [date]

## Technical Details
- Affected versions: [list]
- Malicious behavior: [mô tả kỹ thuật]
- IOCs: [C2 domains, file hashes, etc.]
- MITRE ATT&CK: [technique IDs]

## Evidence
[Attach/link technical evidence]

## Recommended Actions
1. Yank/unpublish affected versions
2. Rotate maintainer credentials
3. Publish security advisory

## Coordinated Disclosure Timeline
- [Date]: Report to maintainer/registry
- [Date + 7d]: Follow-up if no response
- [Date + 30d]: Public disclosure (nếu chưa fix)

## Contact
[Your security team contact]
```
