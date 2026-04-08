# /risk-assess — Khởi tạo đánh giá rủi ro

Bạn đang bắt đầu quy trình đánh giá rủi ro an ninh mạng.

1. Hỏi người dùng:
   - Đối tượng đánh giá (hệ thống, dự án, vendor, quy trình)
   - Phương pháp mong muốn (Qualitative 5x5 / Quantitative FAIR / cả hai)
   - Scope và boundaries
   - Các framework compliance liên quan (ISO 27001, NIST, PCI-DSS, Vietnam regulations)

2. Sử dụng **risk-assessor** agent với **risk-assessment** skill.

3. Tạo output phù hợp:
   - Risk register entries (có template chuẩn)
   - Risk matrix visualization
   - Risk treatment recommendations
   - Executive summary cho management

4. Nếu là vendor assessment, chuyển sang quy trình Third-Party Risk Management 
   trong risk-assessment skill.
