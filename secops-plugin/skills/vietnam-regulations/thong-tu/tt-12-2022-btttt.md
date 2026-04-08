# Thông tư 12/2022/TT-BTTTT — Hướng dẫn bảo đảm ATTT hệ thống thông tin theo cấp độ

- **Có hiệu lực**: 01/10/2022
- **Cơ quan ban hành**: Bộ Thông tin và Truyền thông
- **Hướng dẫn chi tiết cho**: NĐ 85/2016/NĐ-CP
- **Nguồn chính thức**: [thuvienphapluat.vn](https://thuvienphapluat.vn/van-ban/Cong-nghe-thong-tin/Thong-tu-12-2022-TT-BTTTT-bao-dam-an-toan-he-thong-thong-tin-theo-cap-do-516924.aspx)

## Phạm vi

Chi tiết hóa yêu cầu kỹ thuật và quản lý cho từng cấp độ bảo vệ ATTT theo NĐ 85/2016.

## Yêu cầu kỹ thuật theo cấp độ

### Cấp 1 — Cơ bản

| Lĩnh vực | Yêu cầu |
| --- | --- |
| Access Control | Quản lý tài khoản, mật khẩu |
| Malware | Phòng chống virus |
| Backup | Sao lưu dữ liệu quan trọng |
| Patch | Cập nhật bản vá |
| Physical | Kiểm soát ra vào phòng máy |

### Cấp 2 — Tiêu chuẩn

Thêm:
| Lĩnh vực | Yêu cầu |
| --- | --- |
| Firewall | Tường lửa mạng |
| Logging | Ghi log hệ thống, lưu trữ tối thiểu 3 tháng |
| Incident Response | Quy trình xử lý sự cố |
| Change Management | Quản lý thay đổi |
| Training | Đào tạo ATTT cho nhân viên |

### Cấp 3 — Nâng cao (thường áp dụng cho fintech)

Thêm:
| Lĩnh vực | Yêu cầu |
| --- | --- |
| SIEM | Hệ thống giám sát ATTT tập trung |
| IDS/IPS | Hệ thống phát hiện/ngăn chặn xâm nhập |
| WAF | Tường lửa ứng dụng web (nếu có web app) |
| Pentest | Kiểm tra xâm nhập ít nhất 1 lần/năm |
| Vuln Scan | Quét lỗ hổng định kỳ (ít nhất hàng quý) |
| DLP | Kiểm soát rò rỉ dữ liệu |
| Encryption | Mã hóa dữ liệu nhạy cảm (at rest + in transit) |
| MFA | Xác thực đa yếu tố cho tài khoản đặc quyền |
| SOC | Đội ngũ/bộ phận chuyên trách giám sát ATTT |
| BCDR | Kế hoạch dự phòng + diễn tập |
| Audit | Đánh giá ATTT bởi đơn vị độc lập hàng năm |
| Log retention | Lưu log tối thiểu 6 tháng |

### Cấp 4-5 — Nghiêm ngặt

Thêm:
| Lĩnh vực | Yêu cầu |
| --- | --- |
| SOC 24/7 | Giám sát liên tục |
| Threat Intel | Tích hợp nguồn threat intelligence |
| NDR | Network detection and response |
| EDR | Endpoint detection and response |
| Red Team | Kiểm tra tấn công nâng cao |
| Zero Trust | Kiến trúc zero trust |
| Log retention | Tối thiểu 12 tháng |

## Quy trình đánh giá ATTT

### Kiểm tra, đánh giá (Điều 9)

- **Đánh giá nội bộ**: tổ chức tự thực hiện hoặc thuê đơn vị
- **Đánh giá bởi cơ quan có thẩm quyền**: Bộ TT&TT hoặc cơ quan chuyên trách

### Nội dung đánh giá

1. Kiểm tra tuân thủ chính sách, quy trình
2. Quét lỗ hổng bảo mật
3. Kiểm tra xâm nhập (pentest)
4. Đánh giá kiến trúc ATTT
5. Kiểm tra log, giám sát
6. Đánh giá năng lực ứng cứu sự cố
7. Kiểm tra backup và khôi phục

### Tần suất đánh giá

| Cấp độ | Tần suất tối thiểu |
| --- | --- |
| Cấp 1 | Khi có thay đổi lớn |
| Cấp 2 | 2 năm/lần |
| Cấp 3 | 1 năm/lần |
| Cấp 4 | 1 năm/lần + đánh giá đột xuất |
| Cấp 5 | 6 tháng/lần |

## Áp dụng cho fintech

Fintech cấp 3 cần:
- SIEM (OpenSearch, Wazuh, Elastic...) ✓
- EDR (CrowdStrike, Defender...) — yêu cầu cấp 4, nhưng recommended cho cấp 3
- Pentest hàng năm
- Vuln scan hàng quý
- MFA cho admin/privileged accounts
- Log lưu 6 tháng trở lên
- BCP/DRP + diễn tập
