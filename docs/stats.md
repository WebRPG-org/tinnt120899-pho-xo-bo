# Hệ chỉ số nhân vật

> Bám Mục 4 đã chốt. Không thêm chỉ số gần nghĩa, không trùng lặp.

## 3 chỉ số gốc

| Màu | Tên | Ý nghĩa | Luyện bằng |
|-----|-----|---------|-----------|
| Đỏ | Thể | Sức khoẻ, sức bền, liều lĩnh | Thể thao, lao động tay chân, ngủ đủ |
| Xanh | Trí | Logic, học tập, phân tích | Học, đọc, làm việc trí óc |
| Vàng | Tâm | Giao tiếp, cảm xúc, đồng cảm | Giao tiếp, giúp người, quan hệ xã hội |

## Chỉ số trộn (chỉ xuất hiện khi đủ 2 gốc trở lên)

| Trộn | Tên | Ý nghĩa |
|------|-----|---------|
| Đỏ + Xanh | Tím — Kỷ | Kỷ luật, tập trung, chính xác |
| Đỏ + Vàng | Cam — Dũng | Thúc đẩy, lãnh đạo, dám rủi ro |
| Xanh + Vàng | Lục — Sáng | Sáng tạo, linh hoạt, thẩm mỹ |
| 3 gốc cân bằng | Trắng — An Yên | Bình an, ổn định, chữa lành |

## Quy tắc cân bằng (đã chốt)

- **Có trần tổng:** không ai max hết mọi chỉ số. Tổng điểm có giới hạn; nâng một chỉ số phải đánh đổi chỉ số khác.
- **Thời gian là tài nguyên khan hiếm:** 1 ngày game = 30 phút thật, 3 khung Sáng / Chiều / Tối. Luyện chỉ số này thì mất khung luyện chỉ số khác.
- **Liều mới giàu:** việc thu nhập cao đi kèm rủi ro; tỉ lệ thành công tăng theo Dũng (Cam) nhưng vẫn có thể thất bại và mất tiền / Danh vọng.
- **Người hiền / ít Dũng khó làm việc lớn:** Tâm cao + Dũng thấp hợp làm thầy, bác sĩ, hỗ trợ, An Yên cao — nhưng không lãnh đạo doanh nghiệp lớn hay thuyết phục nhà đầu tư nếu không có đối tác Dũng cao hoặc luyện Dũng qua thất bại.
- **Xuất thân:** gacha Mặc định / Random / Nạp quay thêm. Tổng chỉ số khởi đầu bằng nhau, chỉ khác phân bổ. Nạp chỉ mua thêm lượt quay / cốt truyện xuất thân, **không** mua điểm vượt trần.

## Tài nguyên (KHÔNG phải chỉ số gốc)

- **Tiền trong game, Danh vọng, EXP:** tài nguyên, không phải chỉ số gốc.
- **Sức khoẻ / Năng lượng:** đồng hồ theo ngày (meter), hồi theo khung giờ / nhà ở / nghỉ ngơi.
- Xem bảng số học vấn ở `docs/gdd.md` Mục 5; bảng vật phẩm ở `docs/economy.md`.

## Danh hiệu (gắn Mục 3)

- Không giới hạn số lượng danh hiệu sưu tầm; hiển thị 1 chính + 2–3 phụ.
- Mỗi danh hiệu có phe Chính / Tà / Trung lập, yêu cầu chỉ số, và khoá nghề.
- Cặp xung đột chặn lẫn nhau, ví dụ: Tướng Cướp / Trùm Buôn Lậu chặn Cảnh sát, Thẩm phán, Hải quan, Giáo viên; Tham Quan chặn Thanh Liêm / Người Hùng; Kẻ Lừa Đảo chặn Luật Sư Chính Trực (nhưng không chặn Luật Sư Bào Chữa); Học Giả / Tiến sĩ chặn Kẻ Bỏ Học; Tỷ Phú Từ Thiện chặn Kẻ Keo Kiệt.
- Đổi phe cần quest chuộc lỗi (“Cải tà quy chính”).
- Code mẫu kiểm tra xung đột: `src/client/Assets/Scripts/TitleConflict.cs`.
