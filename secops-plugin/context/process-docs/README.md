# Process Documents

Đặt các file quy trình, SOP, playbook, runbook vào thư mục này.
Command `/secops:generate-workflows` sẽ đọc tất cả và tạo workflow YAML templates.

## File types được hỗ trợ

- `.md`, `.txt` — đọc trực tiếp
- `.pdf` — đọc nội dung text
- `.png`, `.jpg` — đọc visual (screenshots flowcharts, diagrams)
- `.csv`, `.json`, `.yaml` — structured data

## Ví dụ các file nên đặt vào đây

| File | Nội dung | Workflow sẽ tạo |
| --- | --- | --- |
| incident-response-plan.md | Quy trình ứng phó sự cố nội bộ | workflows/ir/ |
| change-management-sop.md | Quy trình quản lý thay đổi | workflows/grc/ |
| vuln-mgmt-process.md | Quy trình xử lý lỗ hổng bảo mật | workflows/soc/ |
| onboarding-offboarding.md | Quy trình cấp/thu hồi quyền truy cập | workflows/grc/ |
| vendor-risk-assessment.md | Quy trình đánh giá rủi ro vendor | workflows/grc/ |
| data-breach-playbook.md | Playbook xử lý rò rỉ dữ liệu | workflows/ir/ |
| phishing-response.md | Quy trình xử lý email phishing | workflows/soc/ |
| backup-recovery-sop.md | Quy trình sao lưu & khôi phục | workflows/ir/ |
| access-review-process.md | Quy trình review quyền truy cập định kỳ | workflows/grc/ |
| pentest-process.md | Quy trình kiểm tra xâm nhập | workflows/devsecops/ |
| security-awareness-plan.md | Kế hoạch đào tạo nhận thức ATTT | workflows/awareness/ |

## Cách viết process docs để agent hiểu tốt nhất

Không bắt buộc format chuẩn — viết tự nhiên cũng được. Nhưng nếu muốn kết quả chính xác hơn, nên có:

1. **Tên quy trình** — rõ ràng ở đầu file
2. **Mục đích** — quy trình này giải quyết vấn đề gì
3. **Phạm vi** — áp dụng cho ai, khi nào
4. **Các bước thực hiện** — numbered steps hoặc flowchart
5. **Người thực hiện** — ai làm bước nào (map với org_mapping)
6. **Input/Output** — cần thông tin gì đầu vào, output là gì
7. **Điều kiện kích hoạt** — khi nào chạy quy trình này (trigger)
8. **SLA/Timeline** — deadline cho từng bước
9. **Tham chiếu** — framework, quy định liên quan

## Lưu ý

- Một file có thể tạo ra nhiều workflows (nếu file mô tả nhiều sub-processes)
- Không đặt file chứa credentials/secrets — redact trước
- Sau khi generate, review workflows trong `workflows/` trước khi sử dụng
- Chạy lại khi quy trình thay đổi — command sẽ update workflows hiện có
