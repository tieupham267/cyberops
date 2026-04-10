# Detection Use Case Registry

Master list quản lý tất cả detection use cases. Mỗi UC có file chi tiết riêng trong thư mục này.

## Quy ước

- **UC-ID**: `UC-XXX` (3 chữ số, tăng dần)
- **Sub-rule**: `UC-XXX-YYY` (ví dụ: UC-004-001 là sub-rule 1 của UC-004)
- **File name**: `UC-XXX-ten-use-case.md` (kebab-case)
- **Workflow tạo UC**: `/cyberops:run use-case-design`

## Registry

| UC-ID | Tên Use Case | Phân loại | MITRE ATT&CK | Severity | Status |
|-------|-------------|-----------|--------------|----------|--------|
| UC-001 | Brute Force / Credential Stuffing | Authentication Security | T1110 | CRITICAL | Planned |
| UC-002 | Privileged Account Abuse | Authentication Security | T1078.002 | CRITICAL | Planned |
| UC-003 | Malware / EDR Alert Correlation | Endpoint Security | T1059, T1204 | CRITICAL | Planned |
| UC-004 | [C2 Beaconing Detection](UC-004-c2-beaconing-detection.md) | Command & Control | T1071, T1573, T1055 | CRITICAL | Designed |
| UC-005 | Lateral Movement Detection | Network Security | T1021, T1046 | HIGH | Planned |
| UC-006 | Data Exfiltration Detection | Data Protection | T1048, T1041 | CRITICAL | Planned |
| UC-007 | Firewall Policy Tampering | Network Security | T1562.004 | HIGH | Planned |
| UC-008 | GitLab CI/CD Pipeline Tampering | Supply Chain Security | T1195.002 | HIGH | Planned |
| UC-009 | Impossible Travel / Concurrent Login | Authentication Security | T1078 | HIGH | Planned |
| UC-010 | Log Source Health Monitoring | Operational | — | HIGH | Planned |

## Status Definitions

| Status | Mô tả |
|--------|--------|
| **Planned** | Đã identify, chưa thiết kế |
| **Designed** | Thiết kế hoàn chỉnh (bảng + pseudocode + playbook) |
| **Testing** | Đang dry-run / test trong lab |
| **Deployed** | Đã deploy, đang bake period |
| **Active** | Production, đã qua bake period |
| **Tuning** | Đang điều chỉnh (FP cao, threshold change) |
| **Retired** | Đã decommission |

## Coverage Map — MITRE ATT&CK

```
Initial Access       [UC-001]
Execution            [UC-003]
Credential Access    [UC-001, UC-002]
Discovery            [UC-005]
Lateral Movement     [UC-005, UC-004]
Defense Evasion      [UC-003, UC-007, UC-004]
Command & Control    [UC-004]
Exfiltration         [UC-006]
Impact               [—]
```

## Thống kê

- **Tổng UC**: 10
- **Designed**: 1 (UC-004)
- **Planned**: 9
- **Detection coverage**: 8/14 MITRE Tactics
- **Gaps**: Persistence, Privilege Escalation, Collection, Resource Development, Reconnaissance, Impact
