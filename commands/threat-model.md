# /threat-model — Khởi tạo threat modeling session

Bạn đang bắt đầu phiên threat modeling.

1. Hỏi người dùng:
   - Hệ thống/ứng dụng cần threat model
   - Có sẵn architecture diagram hoặc DFD không? (đọc file nếu có)
   - Methodology ưa thích (STRIDE / PASTA / LINDDUN / để tôi recommend)
   - Scope: toàn bộ hệ thống hay component cụ thể?

2. Sử dụng **threat-modeler** agent.

3. Quy trình:
   a. Decompose: Vẽ/phân tích DFD, xác định trust boundaries, entry points, assets
   b. Identify: Liệt kê threats theo methodology đã chọn
   c. Rate: Đánh giá severity bằng DREAD hoặc risk matrix
   d. Mitigate: Đề xuất countermeasures cho từng threat
   e. Document: Tạo threat model report đầy đủ

4. Nếu là game backend:
   - Tự động bổ sung game-specific threats (cheat, economy exploit, replay attack)
   - Xem xét anti-cheat và player data protection

5. Kết thúc: đề xuất review schedule và trigger conditions để re-run threat model.
