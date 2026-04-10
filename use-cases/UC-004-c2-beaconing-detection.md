# UC-004: C2 Beaconing Detection

**TLP: AMBER** | Phân loại: INTERNAL | Ngày tạo: 2026-04-10
**Business Priority: CRITICAL** | **Effort Estimate: M (2-4 tuần)**

---

## Tổng quan

| Trường | Nội dung |
|--------|----------|
| UC-ID | UC-004 |
| Tên Use Case | C2 Beaconing Detection |
| Phân loại | Command & Control Detection |
| Mục tiêu & Mô tả | Phát hiện các kết nối C2 beaconing từ endpoint bị compromise tới infrastructure của threat actor thông qua phân tích hành vi mạng, DNS, TLS fingerprint, và process injection. Dấu hiệu: kết nối định kỳ với jitter thấp, DNS subdomain dài/entropy cao, JA3 fingerprint khớp Cobalt Strike, URI pattern giả mạo CDN, named pipe đặc trưng, và process injection vào tiến trình hệ thống. Phát hiện sớm C2 channel ngăn chặn lateral movement và data exfiltration — đặc biệt quan trọng trong môi trường fintech xử lý dữ liệu thanh toán. |
| Yêu cầu Tuân thủ | PCI DSS v4.0: Req 11.5.1.1 (detect covert malware communication), Req 10.4.1 (audit log review). ISO 27001:2022: A.8.16 (Monitoring activities), A.8.20 (Network security), A.5.7 (Threat intelligence). TT 09/2020/TT-NHNN: Điều 9 (giám sát ATTT), Điều 15 (phòng chống tấn công mạng). NĐ 13/2023/NĐ-CP: Điều 26 (bảo vệ dữ liệu cá nhân). NĐ 85/2016/NĐ-CP: Điều 21 (giám sát theo cấp độ). |
| MITRE ATT&CK | T1071.001 Web Protocols (TA0011 C&C), T1071.004 DNS (TA0011 C&C), T1573 Encrypted Channel (TA0011 C&C), T1095 Non-Application Layer Protocol (TA0011 C&C), T1055 Process Injection (TA0005 Defense Evasion), T1055.001 DLL Injection (TA0005), T1055.012 Process Hollowing (TA0005), T1568 Dynamic Resolution (TA0011 C&C) |
| Threat Actors | APT41, APT32/OceanLotus, Lazarus Group, TA505, Earth Lusca |
| Sub-rules | CS-001 Beacon Interval, CS-002a DNS Long Subdomain, CS-002b DNS TXT Frequency, CS-002c DNS NXDOMAIN Rate, CS-003 JA3 Fingerprint, CS-004 Malleable C2 URI, CS-005 Named Pipe, CS-006 Process Injection + Network Correlation |

---

## CS-001: Beacon Interval Analysis

| Trường | Nội dung |
|--------|----------|
| UC-ID | UC-004-001 |
| Tên Use Case | Beacon Interval Analysis |
| Phân loại | Network Behavior — Periodic Beaconing |
| Mục tiêu & Mô tả | Phát hiện endpoint thực hiện kết nối định kỳ tới một IP đích với jitter thấp — đặc trưng của C2 beacon tự động. Cobalt Strike mặc định beacon mỗi 60 giây với stddev rất thấp. Phát hiện dựa trên phân tích thống kê khoảng thời gian giữa các kết nối từ một src_ip tới một dst_ip duy nhất. |
| Yêu cầu Tuân thủ | PCI DSS v4.0: Req 11.5.1.1. TT 09/2020/TT-NHNN: Điều 15. ISO 27001:2022: A.8.16. |
| MITRE ATT&CK | T1071.001 Web Protocols (TA0011 C&C), T1573 Encrypted Channel (TA0011 C&C) |
| Nguồn dữ liệu | Checkpoint Firewall logs. Index: `fw-logs-*`. Fields: `src_ip`, `dst_ip`, `dst_port`, `timestamp`, `bytes_sent`, `action`. |
| Logic Phát hiện & Query mẫu | Group kết nối theo cặp (src_ip, dst_ip) trong 30 phút; tính stddev interval — nếu count ≥ 10 và stddev < 15s và avg_bytes < 10KB thì alert. |
| Ngưỡng cảnh báo | HIGH: count ≥ 10 AND stddev < 15s AND avg_bytes < 10240 trong 30 phút. CRITICAL: count ≥ 20 AND stddev < 5s AND dst_ip NOT IN whitelist. |
| Mức độ nghiêm trọng | CRITICAL (stddev < 5s, count ≥ 20, dst unknown) / HIGH (stddev < 15s, count ≥ 10) |
| False Positive | Monitoring agents (Zabbix, Nagios) — whitelist dst_ip. NTP polling — exclude dst_port 123. Payment gateway heartbeat — whitelist dst_ip. |

### Logic Phát hiện & Query mẫu

```
INPUT:
  fw-logs-* (Checkpoint Firewall)

FILTER:
  action     == "allow"
  dst_ip     NOT IN internal_subnets
  dst_port   IN [80, 443, 8080, 8443, 4444, 8888]
  timestamp  >= now() - 30 minutes

GROUP BY:
  src_ip,
  dst_ip,
  dst_port

MEASURE:
  conn_count      = COUNT(events)
  intervals       = DIFF(SORT(timestamp))
  avg_interval    = AVG(intervals)
  stddev_interval = STDDEV(intervals)
  avg_bytes       = AVG(bytes_sent)

CONDITION:
  IF conn_count >= 20
     AND stddev_interval < 5
     AND dst_ip NOT IN ip_whitelist
  THEN
      ALERT "CS-001: High-Confidence C2 Beacon Interval"
      SEVERITY = CRITICAL
      OUTPUT:
        - src_ip
        - dst_ip
        - dst_port
        - conn_count
        - avg_interval
        - stddev_interval
        - avg_bytes
  END IF

  IF conn_count >= 10
     AND stddev_interval < 15
     AND avg_bytes < 10240
  THEN
      ALERT "CS-001: Suspected C2 Beacon Interval"
      SEVERITY = HIGH
      OUTPUT:
        - src_ip
        - dst_ip
        - dst_port
        - conn_count
        - avg_interval
        - stddev_interval
        - avg_bytes
  END IF
```

---

## CS-002a: DNS Long Subdomain Beaconing

| Trường | Nội dung |
|--------|----------|
| UC-ID | UC-004-002a |
| Tên Use Case | DNS Long Subdomain Beaconing |
| Phân loại | DNS Beaconing — Subdomain Length |
| Mục tiêu & Mô tả | Phát hiện DNS query có subdomain dài bất thường (> 40 ký tự) với entropy cao — dấu hiệu DNS tunneling hoặc C2 beaconing qua DNS. Cobalt Strike DNS beacon mã hóa dữ liệu vào subdomain label. |
| Yêu cầu Tuân thủ | PCI DSS v4.0: Req 11.5.1.1. ISO 27001:2022: A.8.20, A.5.7. TT 09/2020/TT-NHNN: Điều 9. |
| MITRE ATT&CK | T1071.004 DNS (TA0011 C&C), T1568 Dynamic Resolution (TA0011 C&C) |
| Nguồn dữ liệu | DNS server logs / Checkpoint DNS logs. Index: `dns-logs-*`. Fields: `src_ip`, `query`, `query_type`, `response_code`, `timestamp`. |
| Logic Phát hiện & Query mẫu | Extract subdomain label; tính length và Shannon entropy; alert nếu length > 40 VÀ entropy > 3.5. |
| Ngưỡng cảnh báo | HIGH: ≥ 5 queries tới cùng parent domain trong 10 phút. MEDIUM: 1-4 queries. |
| Mức độ nghiêm trọng | HIGH (≥ 5 queries) / MEDIUM (1-4 queries) |
| False Positive | CDN tracking subdomains (Akamai) — whitelist CDN parent domains. DKIM selectors — exclude `_domainkey` queries. |

### Logic Phát hiện & Query mẫu

```
INPUT:
  dns-logs-* (DNS Server / Checkpoint)

FILTER:
  query_type IN ["A", "AAAA", "TXT", "MX"]
  timestamp  >= now() - 10 minutes

TRANSFORM:
  first_label   = SPLIT(query, ".")[0]
  label_length  = LEN(first_label)
  label_entropy = SHANNON_ENTROPY(first_label)
  parent_domain = JOIN(SPLIT(query, ".")[1:], ".")

FILTER:
  label_length  > 40
  label_entropy > 3.5
  parent_domain NOT IN dns_whitelist

GROUP BY:
  src_ip,
  parent_domain

MEASURE:
  query_count = COUNT(events)

CONDITION:
  IF query_count >= 5 THEN
      ALERT "CS-002a: DNS Long Subdomain Beaconing"
      SEVERITY = HIGH
      OUTPUT:
        - src_ip
        - parent_domain
        - query_count
        - label_length
        - label_entropy
  END IF

  IF query_count >= 1 AND query_count < 5 THEN
      ALERT "CS-002a: DNS Long Subdomain — Suspicious"
      SEVERITY = MEDIUM
      OUTPUT:
        - src_ip
        - query
        - label_length
        - label_entropy
  END IF
```

---

## CS-002b: DNS TXT Query Frequency

| Trường | Nội dung |
|--------|----------|
| UC-ID | UC-004-002b |
| Tên Use Case | DNS TXT Query Frequency |
| Phân loại | DNS Beaconing — TXT Record Abuse |
| Mục tiêu & Mô tả | Phát hiện endpoint thực hiện quá nhiều DNS TXT query trong thời gian ngắn. TXT record thường bị lạm dụng làm kênh C2 vì có thể chứa payload tùy ý. Tần suất cao TXT query từ endpoint (non-mail-server) là bất thường. |
| Yêu cầu Tuân thủ | PCI DSS v4.0: Req 11.5.1.1. ISO 27001:2022: A.8.20, A.5.7. NĐ 85/2016: Điều 21. |
| MITRE ATT&CK | T1071.004 DNS (TA0011 C&C), T1095 Non-Application Layer Protocol (TA0011 C&C) |
| Nguồn dữ liệu | DNS server logs / Checkpoint DNS logs. Index: `dns-logs-*`. Fields: `src_ip`, `query_type`, `query`, `timestamp`. |
| Logic Phát hiện & Query mẫu | Đếm DNS TXT query theo src_ip trong 15 phút; loại trừ mail servers. |
| Ngưỡng cảnh báo | HIGH: ≥ 50 TXT queries trong 15 phút. MEDIUM: 20-49 TXT queries trong 15 phút. |
| Mức độ nghiêm trọng | HIGH (≥ 50 queries) / MEDIUM (20-49 queries) |
| False Positive | Mail server SPF/DKIM lookups — whitelist IP mail servers. DNS health check tools — whitelist monitoring IPs. |

### Logic Phát hiện & Query mẫu

```
INPUT:
  dns-logs-* (DNS Server / Checkpoint)

FILTER:
  query_type == "TXT"
  src_ip     NOT IN mail_server_whitelist
  src_ip     NOT IN monitoring_whitelist
  timestamp  >= now() - 15 minutes

GROUP BY:
  src_ip

MEASURE:
  txt_query_count = COUNT(events)
  unique_domains  = COUNT_DISTINCT(query)

CONDITION:
  IF txt_query_count >= 50 THEN
      ALERT "CS-002b: High-Frequency DNS TXT Query — C2 Suspected"
      SEVERITY = HIGH
      OUTPUT:
        - src_ip
        - txt_query_count
        - unique_domains
  END IF

  IF txt_query_count >= 20 AND txt_query_count < 50 THEN
      ALERT "CS-002b: Elevated DNS TXT Query Frequency"
      SEVERITY = MEDIUM
      OUTPUT:
        - src_ip
        - txt_query_count
        - unique_domains
  END IF
```

---

## CS-002c: DNS NXDOMAIN Rate

| Trường | Nội dung |
|--------|----------|
| UC-ID | UC-004-002c |
| Tên Use Case | DNS NXDOMAIN Rate |
| Phân loại | DNS Beaconing — NXDOMAIN Ratio |
| Mục tiêu & Mô tả | Phát hiện endpoint có tỷ lệ NXDOMAIN bất thường cao — dấu hiệu DGA (Domain Generation Algorithm) hoặc C2 beaconing thử nhiều domain. Tỷ lệ NXDOMAIN > 30% trên tổng DNS query của một endpoint là bất thường. |
| Yêu cầu Tuân thủ | PCI DSS v4.0: Req 11.5.1.1. ISO 27001:2022: A.8.16, A.5.7. TT 09/2020/TT-NHNN: Điều 9, Điều 15. |
| MITRE ATT&CK | T1568 Dynamic Resolution (TA0011 C&C), T1568.002 Domain Generation Algorithms (TA0011 C&C) |
| Nguồn dữ liệu | DNS server logs / Checkpoint DNS logs. Index: `dns-logs-*`. Fields: `src_ip`, `response_code`, `query`, `timestamp`. |
| Logic Phát hiện & Query mẫu | Tính tỷ lệ NXDOMAIN / total_queries theo src_ip trong 30 phút; chỉ alert khi total_queries ≥ 30. |
| Ngưỡng cảnh báo | HIGH: nxdomain_rate > 50% với total ≥ 50 trong 30 phút. MEDIUM: nxdomain_rate > 30% với total ≥ 30. |
| Mức độ nghiêm trọng | HIGH (rate > 50%, volume cao) / MEDIUM (rate 30-50%) |
| False Positive | Misconfigured DNS search suffix — verify DNS config. Browser extensions quét URL ngẫu nhiên — baseline endpoint. |

### Logic Phát hiện & Query mẫu

```
INPUT:
  dns-logs-* (DNS Server / Checkpoint)

FILTER:
  timestamp >= now() - 30 minutes

GROUP BY:
  src_ip

MEASURE:
  total_queries  = COUNT(events)
  nxdomain_count = COUNT(events WHERE response_code == "NXDOMAIN")
  nxdomain_rate  = nxdomain_count / total_queries * 100

CONDITION:
  IF total_queries >= 50
     AND nxdomain_rate > 50
  THEN
      ALERT "CS-002c: High NXDOMAIN Rate — DGA/C2 Suspected"
      SEVERITY = HIGH
      OUTPUT:
        - src_ip
        - total_queries
        - nxdomain_count
        - nxdomain_rate
  END IF

  IF total_queries >= 30
     AND nxdomain_rate > 30
     AND nxdomain_rate <= 50
  THEN
      ALERT "CS-002c: Elevated NXDOMAIN Rate"
      SEVERITY = MEDIUM
      OUTPUT:
        - src_ip
        - total_queries
        - nxdomain_count
        - nxdomain_rate
  END IF
```

---

## CS-003: JA3/JA3S Fingerprint Match

| Trường | Nội dung |
|--------|----------|
| UC-ID | UC-004-003 |
| Tên Use Case | JA3/JA3S Fingerprint Match |
| Phân loại | TLS Fingerprint — Known C2 Signature |
| Mục tiêu & Mô tả | Phát hiện TLS handshake có JA3/JA3S fingerprint khớp với Cobalt Strike và các C2 framework phổ biến. JA3 tính từ TLS ClientHello, JA3S từ ServerHello — C2 frameworks thường dùng TLS stack mặc định tạo fingerprint nhất quán. |
| Yêu cầu Tuân thủ | PCI DSS v4.0: Req 11.5.1.1. ISO 27001:2022: A.8.16, A.5.7. TT 09/2020/TT-NHNN: Điều 15. |
| MITRE ATT&CK | T1573 Encrypted Channel (TA0011 C&C), T1071.001 Web Protocols (TA0011 C&C) |
| Nguồn dữ liệu | CrowdStrike Falcon network telemetry; Checkpoint TLS inspection logs (nếu bật). Index: `edr-network-*`, `fw-tls-*`. Fields: `src_ip`, `dst_ip`, `ja3_hash`, `ja3s_hash`, `dst_port`, `timestamp`. |
| Logic Phát hiện & Query mẫu | So sánh ja3_hash với known-bad JA3 IOCs; match cả ja3 + ja3s = CRITICAL. |
| Ngưỡng cảnh báo | CRITICAL: ja3_hash AND ja3s_hash đều khớp known CS list. HIGH: chỉ ja3_hash khớp. |
| Mức độ nghiêm trọng | CRITICAL (cả hai fingerprint khớp) / HIGH (chỉ JA3 khớp) |
| Prerequisite | Checkpoint HTTPS Inspection hoặc CrowdStrike network telemetry có JA3. |
| False Positive | Pentest tools — whitelist IP pentest team khi có authorized test. Legitimate software dùng cùng TLS library — verify với asset inventory. |

### Logic Phát hiện & Query mẫu

```
INPUT:
  edr-network-* (CrowdStrike Falcon Network Telemetry)

FILTER:
  ja3_hash  != null
  dst_ip    NOT IN internal_subnets
  timestamp >= now() - 15 minutes

LOOKUP:
  known_cs_ja3_list  = [<populate từ threat intel feeds>]
  known_cs_ja3s_list = [<populate từ threat intel feeds>]

CONDITION:
  IF ja3_hash IN known_cs_ja3_list
     AND ja3s_hash IN known_cs_ja3s_list
  THEN
      ALERT "CS-003: Cobalt Strike JA3+JA3S Fingerprint Match"
      SEVERITY = CRITICAL
      OUTPUT:
        - src_ip
        - dst_ip
        - dst_port
        - ja3_hash
        - ja3s_hash
        - process_name
        - hostname
  END IF

  IF ja3_hash IN known_cs_ja3_list
     AND ja3s_hash NOT IN known_cs_ja3s_list
  THEN
      ALERT "CS-003: Known C2 JA3 Fingerprint Detected"
      SEVERITY = HIGH
      OUTPUT:
        - src_ip
        - dst_ip
        - dst_port
        - ja3_hash
        - process_name
        - hostname
  END IF
```

---

## CS-004: Malleable C2 URI Pattern

| Trường | Nội dung |
|--------|----------|
| UC-ID | UC-004-004 |
| Tên Use Case | Malleable C2 URI Pattern |
| Phân loại | HTTP/S — C2 URI Signature |
| Mục tiêu & Mô tả | Phát hiện HTTP/S request tới URI pattern đặc trưng của Cobalt Strike Malleable C2 profiles (jquery, amazon, ocsp, office365). Các profile giả mạo traffic hợp pháp nhưng có URI path cố định. Điều kiện: destination IP không thuộc dải CDN/cloud thực sự. |
| Yêu cầu Tuân thủ | PCI DSS v4.0: Req 11.5.1.1. ISO 27001:2022: A.8.16, A.8.20. TT 09/2020/TT-NHNN: Điều 15. |
| MITRE ATT&CK | T1071.001 Web Protocols (TA0011 C&C) |
| Nguồn dữ liệu | Checkpoint HTTP/S logs (cần URL inspection); CrowdStrike network telemetry. Index: `fw-web-*`, `edr-network-*`. Fields: `src_ip`, `dst_ip`, `uri_path`, `user_agent`, `timestamp`. |
| Logic Phát hiện & Query mẫu | Match uri_path với regex known malleable profiles; validate dst_ip NOT IN vendor CDN ranges. |
| Ngưỡng cảnh báo | CRITICAL: ≥ 3 events trong 10 phút cùng src_ip. HIGH: 1 event match. |
| Mức độ nghiêm trọng | CRITICAL (lặp lại ≥ 3 lần) / HIGH (1 lần match) |
| Prerequisite | Checkpoint HTTP URL inspection enabled. |
| False Positive | Proxy/content cache — enrich bằng dst_ip ASN lookup. Dev test environment — whitelist dev network. |

### Logic Phát hiện & Query mẫu

```
INPUT:
  fw-web-* (Checkpoint HTTP Inspection)
  edr-network-* (CrowdStrike Falcon)

FILTER:
  http_method IN ["GET", "POST"]
  dst_ip      NOT IN internal_subnets
  timestamp   >= now() - 10 minutes

LOOKUP:
  malleable_uri_patterns = [
    "/jquery-3.3.1.min.js",
    "/jquery-3.3.1.slim.min.js",
    "/dpixel",
    "/updates.rss",
    "/dot.gif",
    "/ocsp/",
    "/MicrosoftUpdate/",
    "/OfficeActivation/"
  ]
  legitimate_cdn_ranges = [
    "13.32.0.0/15",     // Amazon CloudFront
    "23.0.0.0/12",      // Akamai
    "104.16.0.0/13",    // Cloudflare
    "13.107.0.0/16"     // Microsoft
  ]

FILTER:
  uri_path MATCHES_ANY malleable_uri_patterns
  dst_ip   NOT IN legitimate_cdn_ranges

GROUP BY:
  src_ip,
  dst_ip

MEASURE:
  match_count = COUNT(events)

CONDITION:
  IF match_count >= 3 THEN
      ALERT "CS-004: Repeated Malleable C2 URI Pattern"
      SEVERITY = CRITICAL
      OUTPUT:
        - src_ip
        - dst_ip
        - uri_path
        - match_count
        - user_agent
        - process_name
  END IF

  IF match_count >= 1 AND match_count < 3 THEN
      ALERT "CS-004: Malleable C2 URI Pattern Detected"
      SEVERITY = HIGH
      OUTPUT:
        - src_ip
        - dst_ip
        - uri_path
        - user_agent
        - process_name
  END IF
```

---

## CS-005: Named Pipe Detection

| Trường | Nội dung |
|--------|----------|
| UC-ID | UC-004-005 |
| Tên Use Case | Named Pipe Detection |
| Phân loại | Endpoint — Named Pipe C2 Communication |
| Mục tiêu & Mô tả | Phát hiện named pipe có tên khớp pattern mặc định của Cobalt Strike: `msagent_*`, `MSSE-*-server`, `postex_*`, `status_*`, `halfduplex_*`. CS dùng named pipe cho IPC giữa beacon và spawned jobs, và cho SMB lateral movement. |
| Yêu cầu Tuân thủ | PCI DSS v4.0: Req 11.5.1.1. ISO 27001:2022: A.8.16. TT 09/2020/TT-NHNN: Điều 15. NĐ 85/2016: Điều 21. |
| MITRE ATT&CK | T1071 Application Layer Protocol (TA0011 C&C), T1055 Process Injection (TA0005 Defense Evasion) |
| Nguồn dữ liệu | CrowdStrike Falcon EDR — Pipe Creation events. Index: `edr-events-*`. Fields: `hostname`, `process_name`, `process_id`, `pipe_name`, `event_type`, `user`, `timestamp`. |
| Logic Phát hiện & Query mẫu | Match pipe_name với regex known CS default named pipes. Bất kỳ match nào đều alert — các tên pipe này không có lý do hợp lệ trong production. |
| Ngưỡng cảnh báo | CRITICAL: pipe tạo bởi system process (svchost, explorer, spoolsv). HIGH: pipe tạo bởi process khác. |
| Mức độ nghiêm trọng | CRITICAL (system process tạo pipe) / HIGH (process khác) |
| Prerequisite | CrowdStrike Falcon Data Replicator (FDR) enabled, Pipe Creation events bật. |
| False Positive | Pentest/red team — cross-check lịch pentest. Security products tạo pipe tương tự — whitelist process_name. |

### Logic Phát hiện & Query mẫu

```
INPUT:
  edr-events-* (CrowdStrike Falcon — Pipe Creation)

FILTER:
  event_type IN ["PipeCreated", "PipeConnected"]
  timestamp  >= now() - 5 minutes

LOOKUP:
  cs_pipe_patterns = [
    "^msagent_[a-f0-9]+$",
    "^MSSE-[0-9]+-server$",
    "^postex_[a-f0-9]+$",
    "^status_[a-f0-9]+$",
    "^halfduplex_[a-f0-9]+$"
  ]
  critical_system_processes = [
    "svchost.exe",
    "explorer.exe",
    "spoolsv.exe",
    "lsass.exe",
    "winlogon.exe"
  ]

FILTER:
  pipe_name MATCHES_ANY cs_pipe_patterns

CONDITION:
  IF process_name IN critical_system_processes THEN
      ALERT "CS-005: Cobalt Strike Named Pipe from System Process"
      SEVERITY = CRITICAL
      OUTPUT:
        - hostname
        - process_name
        - process_id
        - pipe_name
        - user
        - parent_process
  END IF

  IF process_name NOT IN critical_system_processes THEN
      ALERT "CS-005: Cobalt Strike Named Pipe Detected"
      SEVERITY = HIGH
      OUTPUT:
        - hostname
        - process_name
        - process_id
        - pipe_name
        - user
        - parent_process
  END IF
```

---

## CS-006: Process Injection + Network Correlation

| Trường | Nội dung |
|--------|----------|
| UC-ID | UC-004-006 |
| Tên Use Case | Process Injection + Network Correlation |
| Phân loại | Endpoint + Network — Injection với C2 Callback |
| Mục tiêu & Mô tả | Phát hiện chuỗi tấn công: process injection (CreateRemoteThread, process hollowing, APC injection) vào system process, SAU ĐÓ process đó thực hiện kết nối mạng ra ngoài. Đây là TTP đặc trưng của Cobalt Strike khi inject beacon vào svchost.exe/explorer.exe để ẩn traffic. Correlation giữa injection event và network event trong 5 phút = high confidence. |
| Yêu cầu Tuân thủ | PCI DSS v4.0: Req 11.5.1.1. ISO 27001:2022: A.8.16, A.8.20. TT 09/2020/TT-NHNN: Điều 15. NĐ 13/2023: Điều 26. |
| MITRE ATT&CK | T1055 Process Injection (TA0005), T1055.001 DLL Injection (TA0005), T1055.012 Process Hollowing (TA0005), T1071.001 Web Protocols (TA0011 C&C) |
| Nguồn dữ liệu | CrowdStrike Falcon EDR — Process Injection events + Network Connection events. Index: `edr-events-*`, `edr-network-*`. |
| Logic Phát hiện & Query mẫu | Step 1: detect injection vào system process. Step 2: trong 5 phút sau, cùng host + cùng target process tạo outbound connection. Cả hai thỏa → CRITICAL. |
| Ngưỡng cảnh báo | CRITICAL: injection + outbound connection trong 5 phút. HIGH: chỉ injection (không có network correlation). |
| Mức độ nghiêm trọng | CRITICAL (injection + network callback) / HIGH (injection only) |
| False Positive | AV/EDR tự inject để monitor — whitelist signed security products. Legitimate software dùng CreateRemoteThread cho IPC — whitelist known process pairs. |

### Logic Phát hiện & Query mẫu

```
INPUT:
  edr-events-*  (CrowdStrike Falcon — Process Events)
  edr-network-* (CrowdStrike Falcon — Network Connections)

// --- STEP 1: Detect injection events ---
STREAM_A:
  FILTER edr-events-*:
    event_type IN ["CreateRemoteThread",
                   "ProcessHollowing",
                   "APCInjection",
                   "NtMapViewOfSection"]
    target_process IN ["svchost.exe",
                       "explorer.exe",
                       "spoolsv.exe"]
    injecting_process NOT IN security_product_whitelist
    timestamp >= now() - 10 minutes

  OUTPUT stream_a:
    hostname, target_process, target_pid,
    injecting_process, injection_type, timestamp AS inject_time

// --- STEP 2: Detect outbound network from injected process ---
STREAM_B:
  FILTER edr-network-*:
    process_name IN ["svchost.exe", "explorer.exe", "spoolsv.exe"]
    dst_ip NOT IN internal_subnets
    dst_ip NOT IN ip_whitelist
    timestamp >= now() - 10 minutes

  OUTPUT stream_b:
    hostname, process_name, process_id,
    dst_ip, dst_port, timestamp AS net_time

// --- STEP 3: Correlate ---
JOIN stream_a AND stream_b ON:
  stream_a.hostname       == stream_b.hostname
  stream_a.target_process == stream_b.process_name
  stream_b.net_time BETWEEN stream_a.inject_time
                        AND stream_a.inject_time + 300s

CONDITION:
  IF JOIN produces match THEN
      ALERT "CS-006: Process Injection + C2 Network Callback"
      SEVERITY = CRITICAL
      OUTPUT:
        - hostname
        - injecting_process
        - target_process
        - injection_type
        - dst_ip
        - dst_port
        - inject_time
        - net_time
        - time_delta
  END IF

  IF stream_a has event AND no stream_b match THEN
      ALERT "CS-006: Process Injection into System Process"
      SEVERITY = HIGH
      OUTPUT:
        - hostname
        - injecting_process
        - target_process
        - injection_type
        - inject_time
  END IF
```

---

## Response Playbook

| Phase | Thời gian | Hành động chính |
|-------|-----------|-----------------|
| **Triage (L1)** | 0–15 phút | Xác nhận alert, kiểm tra src_ip trong asset inventory, verify hostname trên CrowdStrike console, loại trừ FP theo whitelist, escalate nếu CRITICAL. |
| **Investigation (L1/L2)** | 15–60 phút | Pull network history src_ip 24h; process tree trên CrowdStrike; correlate CS-001→CS-006 alerts cùng hostname; threat intel lookup dst_ip/domain; xác định thời điểm compromise đầu tiên. |
| **Containment** | 0–30 phút sau confirmed TP | CrowdStrike Network Contain host; block dst_ip/domain trên Checkpoint; preserve memory dump trước can thiệp; revoke credentials user login tại host. |
| **Eradication** | 2–4 giờ | Full malware scan toàn fleet; remove persistence (scheduled tasks, registry, services); block IOCs trên Checkpoint; kiểm tra lateral movement sang hosts cùng VLAN. |
| **Recovery** | 4–24 giờ | Rebuild/restore từ known-good snapshot; reset credentials liên quan; monitor chặt host 72h sau đưa lại production; verify không còn beaconing. |
| **Escalation** | Ngay khi CRITICAL | CISO + Incident Commander. Data exfiltration → TT 09/2020 Điều 9. PII/payment data → NĐ 13/2023 Điều 26 + PCI DSS breach notification. |

---

## Deployment Plan

| Tuần | Rules | Lý do |
|------|-------|-------|
| Tuần 1 | CS-001, CS-003 | High confidence, low FP. JA3 từ CrowdStrike telemetry có sẵn. |
| Tuần 2 | CS-005, CS-006 | Endpoint-only từ CrowdStrike. CS-006 cần correlation logic nhưng confidence rất cao. |
| Tuần 3 | CS-002a, CS-002b, CS-002c | Cần DNS logging enabled và format đúng. Tuning whitelist CDN/mail trước go-live. |
| Tuần 4 | CS-004 | Cần Checkpoint HTTP URL inspection enabled. Cần CDN IP whitelist đầy đủ. |

---

## Tuning Triggers

| Trigger | Điều kiện | Urgency |
|---------|-----------|---------|
| FP rate > 20% | Trong 7 ngày rolling | HIGH — tune trong 48h |
| Zero alert 14 ngày | CS-001 hoặc CS-003 không fire | HIGH — investigate data pipeline ngay |
| Threat intel update | JA3 hash mới hoặc named pipe pattern mới | HIGH — update lookup trong 24h |
| Alert volume spike | > 3x baseline | HIGH — investigate trong 1h |
| Infra change | Thêm CDN/cloud provider | MEDIUM — update whitelist trước network change |

---

## Blockers

| # | Blocker | Rules bị ảnh hưởng | Action |
|---|---------|---------------------|--------|
| 1 | DNS logging chưa forward về OpenSearch | CS-002a, CS-002b, CS-002c | Enable DNS Debug log → Filebeat → OpenSearch. Effort: 2-3 ngày. |
| 2 | CrowdStrike chưa bật Pipe Creation event | CS-005 | Bật `CreatePipe` event trong Falcon sensor policy. Effort: 1 ngày. |
| 3 | Checkpoint chưa bật HTTP URL inspection | CS-004 | Enable URL filtering. Cần change request. Effort: 1-2 ngày. |
| 4 | Checkpoint chưa bật TLS inspection (JA3) | CS-003 | Dùng CrowdStrike network telemetry thay thế; hoặc enable TLS inspection. |
| 5 | Thiếu CDN IP whitelist chuẩn hóa | CS-001, CS-004 | Build từ ARIN/APNIC lookups. Effort: 3-5 ngày. |
| 6 | Thiếu correlation engine cho multi-source join | CS-006 | Implement correlation rule trong OpenSearch Alerting. Effort: 3-5 ngày. |
