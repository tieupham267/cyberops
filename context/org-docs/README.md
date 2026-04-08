# Organization Documents

Đặt các file tổ chức vào thư mục này. Command `/secops:setup-profile` sẽ đọc tất cả
và tự động tạo/cập nhật `context/company-profile.yaml`.

## File types được hỗ trợ

- `.md`, `.txt`, `.csv`, `.json`, `.yaml` — đọc trực tiếp
- `.pdf` — đọc nội dung text
- `.png`, `.jpg` — đọc OCR/visual (screenshots org chart, diagrams)

## Ví dụ các file nên đặt vào đây

| File | Nội dung | Profile fields sẽ populate |
| --- | --- | --- |
| org-chart.md/png | Sơ đồ tổ chức, phòng ban, trưởng phòng | org_mapping, escalation |
| it-assets.md/csv | Danh sách hệ thống, servers, tools | infrastructure, security stack |
| network-diagram.md/png | Sơ đồ mạng, firewall, segments | networking |
| tech-stack.md | Danh sách công nghệ đang dùng | infrastructure, cicd, data |
| security-tools.md | Các tool bảo mật đang triển khai | security section |
| compliance-status.md | Chứng chỉ, audit schedule | compliance |
| hr-teams.md/csv | Danh sách team, headcount, roles | security_team |
| incident-process.md | Quy trình escalation, contacts | escalation matrix |
| policies-list.md | Danh sách policies đã có | compliance, grc context |

## Lưu ý

- Không đặt file chứa credentials/secrets thật — redact trước khi đặt vào
- File sẽ được đọc bởi AI agent — không cần format chuẩn, viết tự nhiên cũng được
- Sau khi chạy `/secops:setup-profile`, review kết quả trong `company-profile.yaml`
- Chạy lại command khi có thay đổi tổ chức
