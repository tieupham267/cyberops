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
