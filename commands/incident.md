# /incident — Khởi tạo quy trình ứng phó sự cố

Bạn đang bắt đầu quy trình ứng phó sự cố bảo mật.

1. Hỏi người dùng các thông tin cơ bản:
   - Loại sự cố (ransomware, BEC, data breach, malware, DDoS, account compromise, khác)
   - Thời điểm phát hiện
   - Hệ thống/dữ liệu bị ảnh hưởng
   - Mức độ nghiêm trọng ước tính (CRITICAL/HIGH/MEDIUM/LOW)
   - Sự cố đang diễn ra hay đã được ngăn chặn?

2. Sử dụng **incident-commander** agent với **incident-response** skill.

3. Dựa trên loại sự cố, tạo ngay:
   - Checklist hành động tức thì (0-1 giờ)
   - Template thông báo nội bộ
   - Danh sách evidence cần thu thập
   - Timeline tracking template

4. Nhắc nhở về yêu cầu pháp lý:
   - 72 giờ thông báo vi phạm DLCN (Nghị định 13/2023)
   - Báo cáo VNCERT/CC nếu cần
