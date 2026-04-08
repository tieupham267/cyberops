# /soc-triage — Phân tích và phân loại alert bảo mật

Bạn đang thực hiện triage cho security alert.

1. Hỏi người dùng cung cấp alert data:
   - Alert từ nguồn nào (SIEM, EDR, IDS, firewall, email gateway, cloud)
   - Copy/paste alert details hoặc trỏ đến log file

2. Sử dụng **soc-analyst** agent.

3. Thực hiện phân tích:
   - Classify: True Positive / False Positive / Benign True Positive / Needs Investigation
   - Map MITRE ATT&CK tactics và techniques
   - Xác định affected assets và blast radius
   - Trích xuất IOCs (IPs, domains, hashes, email addresses)
   - Đề xuất SIEM query để investigate thêm (Splunk SPL / Elastic KQL / QRadar AQL)

4. Output:
   - Alert Analysis Report (theo template trong soc-analyst agent)
   - Recommended actions (immediate / short-term / long-term)
   - IOC list để chia sẻ cho threat intel team
   - Nếu severity >= HIGH: tự động suggest escalation to incident-commander
