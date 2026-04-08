---
name: payment-fraud
description: >
  Knowledge base for payment fraud typologies, promotion abuse patterns, transaction
  monitoring, and fraud detection in fintech/payment environments. Reference material
  for fraud-analyst agent. Covers: card fraud, promotion abuse, merchant fraud,
  account takeover, and Vietnamese payment ecosystem specifics.
---

# Payment Fraud — Knowledge Base

## 1. Fraud Typology Reference

### 1.1 Promotion / Campaign Abuse

| Pattern | Mô tả | Indicators | Controls |
| --- | --- | --- | --- |
| **Refund abuse** | Mua → hưởng ưu đãi → refund/void → giữ tiền ưu đãi | High refund rate sau purchase, refund within 24-72h | Clawback policy: thu hồi ưu đãi nếu refund trong N ngày |
| **Multi-card abuse** | 1 người dùng nhiều thẻ bypass per-card limit | Cùng device/IP/phone + nhiều card numbers | Giới hạn per-customer (ID/phone/device) thay vì per-card |
| **Virtual card abuse** | Mở thẻ ảo miễn phí để multiply ưu đãi | Nhiều thẻ cùng BIN range thẻ ảo, new cards | Lọc BIN virtual, giới hạn per-phone/per-email |
| **Split transaction** | Chia nhỏ đơn hàng hoặc gộp để đạt threshold | Nhiều giao dịch liên tiếp cùng thẻ + cùng merchant | Velocity rule: max N giao dịch/thẻ/merchant/ngày |
| **Collusion (employee)** | Nhân viên merchant tạo giao dịch giả | Cùng terminal + nhiều giao dịch đúng threshold + off-hours | Cross-check employee cards, terminal anomaly monitoring |
| **Bot/script abuse** | Tự động chiếm quota ưu đãi online | Burst traffic lúc 0:00, uniform timing, no mouse movement | CAPTCHA, rate limiting, device fingerprint |
| **Promo stacking** | Kết hợp nhiều CTKM trên cùng giao dịch | Giao dịch nhận nhiều discount codes | Mutual exclusion rules giữa các CTKM |
| **Merchant self-dealing** | Merchant tự tạo giao dịch giả để nhận commission/ưu đãi | Low customer diversity, suspicious patterns | Third-party mystery shopping, reconciliation audit |

### 1.2 Card Fraud

| Pattern | Mô tả | Indicators | Controls |
| --- | --- | --- | --- |
| **Stolen card** | Dùng thẻ bị đánh cắp (physical hoặc data) | First-time card tại merchant, different geo từ cardholder | 3D Secure / OTP, AVS, geo-checking |
| **Card testing** | Test thẻ bị cắp bằng giao dịch nhỏ trước khi mua lớn | Multiple small transactions → 1 large, sequential card numbers | Velocity rules, minimum amount, BIN blocking |
| **Counterfeit card** | Thẻ giả với data bị skim | EMV fallback to magstripe, mismatched BIN/issuer | Mandate EMV chip, no magstripe fallback |
| **Card-not-present (CNP)** | Giao dịch online không cần thẻ vật lý | No 3DS, billing ≠ shipping, disposable email | 3D Secure mandatory, email verification |
| **Account takeover** | Chiếm tài khoản payment app → thay đổi thẻ/rút tiền | Password reset, device change, rapid card change | MFA, device binding, cooldown period after changes |

### 1.3 Merchant Fraud

| Pattern | Mô tả | Indicators | Controls |
| --- | --- | --- | --- |
| **Phantom merchant** | Merchant không thật, chỉ để launder | No real goods/services, high volume low diversity | KYC merchant, site inspection, transaction monitoring |
| **Transaction laundering** | Process giao dịch cho business khác qua merchant account hợp lệ | Different product categories, IP mismatch | Merchant monitoring, website crawling |
| **Forced refund** | Merchant cố tình refund → chargeback fraud | Refund rate > industry average | Refund velocity monitoring, refund approval workflow |

## 2. Vietnamese Payment Ecosystem

### Payment Channels

| Channel | Risk Level | Notes |
| --- | --- | --- |
| **POS (Payoo, VNPay, bank POS)** | Medium | Physical presence required, nhưng collusion possible |
| **QR Code (VNPay QR, Momo, ZaloPay)** | Medium-High | Easy to generate fake QR, no card verification |
| **Online payment gateway** | High | CNP fraud, no physical verification |
| **E-wallet (Momo, ZaloPay, ShopeePay)** | Medium | Account takeover risk, promo abuse |
| **Bank transfer (Napas, IBFT)** | Low | Hard to reverse, less promo abuse |

### Card Networks tại VN

| Network | Virtual Card Available | Multi-card Risk |
| --- | --- | --- |
| **Visa** | Có (nhiều NH) | High — easy to open multiple |
| **Mastercard** | Có | High |
| **JCB** | Có (ít hơn) | Medium — fewer issuers in VN |
| **Napas/Domestic** | Ít | Low |

### Ngân hàng phát hành thẻ ảo phổ biến

Tham khảo khi đánh giá virtual card abuse risk:
- TPBank — LiveCard (virtual, free)
- VPBank — thẻ ảo qua app
- Techcombank — thẻ ảo
- VIB — MyCard virtual
- Sacombank — thẻ ảo

## 3. Detection Rule Patterns

### 3.1 Velocity Rules

```
# Card velocity: N giao dịch cùng thẻ trong X giờ
IF card_number = same
AND merchant_category = target_merchant
AND count(transactions) > N within X hours
THEN alert "Velocity: {card_last4} has {count} transactions at {merchant} in {hours}h"

# Terminal velocity: N giao dịch cùng terminal cùng amount
IF terminal_id = same
AND amount BETWEEN (threshold × 0.95) AND (threshold × 1.05)
AND count(transactions) > N within X hours
THEN alert "Terminal anomaly: {terminal_id} has {count} near-threshold transactions"
```

### 3.2 Refund Pattern Rules

```
# Quick refund after promotion purchase
IF transaction_type = "refund"
AND original_transaction.had_promotion = true
AND time_between(purchase, refund) < 72 hours
THEN alert "Promo refund abuse: {card_last4} refund {amount} within {hours}h of promo purchase"

# High refund ratio per merchant during promotion
IF merchant = target_merchant
AND promotion_period = active
AND refund_count / purchase_count > 0.15 (15%)
THEN alert "High refund ratio at {merchant}: {ratio}%"
```

### 3.3 Multi-card / Multi-account Rules

```
# Same device, multiple cards
IF device_fingerprint = same
AND distinct(card_number) > 2
AND merchant = target_merchant
AND time_window = 30 days
THEN alert "Multi-card same device: {device} used {card_count} cards at {merchant}"

# Same phone/email, multiple cards (online)
IF (phone = same OR email = same)
AND distinct(card_number) > 2
AND promotion = active
THEN alert "Multi-card same identity: {phone/email} used {card_count} cards"
```

### 3.4 Collusion Rules

```
# Employee card at own terminal
IF terminal_id = employee_terminal
AND card_holder_name MATCHES employee_list
THEN alert "Possible collusion: employee {name} transacting at own terminal"

# Off-hours transactions at POS
IF terminal_id = target_merchant_terminal
AND transaction_time NOT BETWEEN "09:00" AND "22:00"
AND promotion = active
THEN alert "Off-hours promo transaction at {terminal}: {time}"
```

## 4. Promotion Risk Assessment Checklist

Trước khi approve CTKM, kiểm tra:

### Design Checks

- [ ] Tỷ lệ chiết khấu ≤ 20%? (> 20% = high fraud incentive)
- [ ] Giới hạn per-customer (không chỉ per-card)?
- [ ] Refund clawback policy defined?
- [ ] Mutual exclusion với CTKM khác?
- [ ] Budget cap tổng + cap/ngày?
- [ ] Kênh online có 3D Secure?

### Monitoring Checks

- [ ] Fraud detection rules deployed trước khi launch?
- [ ] Real-time alerting configured?
- [ ] Daily reconciliation process defined?
- [ ] Weekly fraud review scheduled?
- [ ] Escalation process for fraud incidents?

### Regulatory Checks

- [ ] T&C có consent clause cho xử lý dữ liệu giao dịch? (NĐ 13/2023)
- [ ] Card data masked trong reconciliation reports? (PCI DSS)
- [ ] DPA giữa các bên tham gia CTKM?
- [ ] Merchant compliance confirmed? (PCI DSS SAQ/AOC)

## 5. Key Metrics for Fraud Monitoring

| Metric | Formula | Threshold Alert |
| --- | --- | --- |
| **Fraud rate** | Fraud transactions / Total promo transactions | > 1% |
| **Refund rate** | Refund amount / Promo purchase amount | > 10% |
| **Avg transaction amount** | Sum(amount) / Count | Clustering near threshold |
| **Unique cards per device** | Distinct cards / device fingerprint | > 2/month |
| **Promo utilization per card** | Promo uses / limit | Consistently maxing limit |
| **Time to refund** | Median time between purchase and refund | < 24h |
| **Terminal concentration** | % transactions from top 3 terminals | > 50% |
