# Phố Xô Bồ

Game xã hội 2.5D thuần Việt — sống một đời ở phố: học, làm, yêu, lập nghiệp, chữa lành.

- **Thể loại:** Social simulation / Life sim, 2.5D isometric, online
- **Nền tảng:** iOS, Android, PC, Web (Unity, cross-save)
- **Ngôn ngữ:** Tiếng Việt

## 12 mục đã chốt

1. **Tổng quan:** Xuất thân gacha (Mặc định / Random / Nạp quay thêm) — tổng chỉ số bằng nhau, chỉ khác phân bổ, nạp không mua được điểm vượt trần. Thời gian kiểu C: 1 ngày game = 30 phút, 3 khung Sáng / Chiều / Tối, miss không phạt, sự kiện chung 20h thứ 7.
2. **Tham khảo:** Việt hoá sâu kiểu Gánh Phố + đồ hoạ/gameplay kiểu Treasure of Nadia, điện thoại là menu chính.
3. **Thế giới:** 18 khu, 5 tầng lớp, danh hiệu không giới hạn nhưng có xung đột logic (Tướng Cướp không làm được Cảnh sát).
4. **Chỉ số:** 3 gốc Đỏ Thể / Xanh Trí / Vàng Tâm, trộn ra Tím Kỷ / Cam Dũng / Lục Sáng + Trắng An Yên. Có trần, có đánh đổi, liều mới giàu.
5. **Học vấn:** THPT → Tiến sĩ/Học giả + khoá ngắn hạn, gắn EXP/tiền/Danh vọng, cung cầu đổi theo tuần.
6. **Nghề & Công ty:** Nghề có cung cầu theo tuần, công ty như guild — giấy phép, phí thi chứng chỉ, góp phần/chia phần.
7. **Tài chính:** Lời lãi chỉ trong game, trade item-to-item, sàn đấu giá, nhà/xe/điện thoại/quần áo đều có chỉ số liên kết nhân vật–nghề–chức danh. Không đổi tiền thật, không đụng luật VN.
8. **Xã hội:** Ưu tiên vợ-chồng → bạn thân → hội bạn → gia đình → đối tác, nương tựa chỉ số nhau, solo chậm hơn 30–50%.
9. **Cốt truyện:** 5 chương gắn cấp bậc (Chương 3 thử rank có thể tụt, Chương 5 chia 4 nhánh rank).
10. **Đồ hoạ:** 2.5D chi tiết, tuỳ chỉnh nhân vật/nhà/điện thoại như Nadia.
11. **Slice online:** 1 khu, 3 nghề, chat/trade/thăm nhà, NPC lấp chỗ, server chung + mode Bụi Đời Chợ Cá 3v3/5v5 tranh lãnh địa.
12. **Chữa lành:** Không trừng phạt, không FOMO, nhiều ending đẹp đều tính là thắng.

Chi tiết đầy đủ: xem `docs/` và bảng prototype (tên cũ Đời Phố, đã đổi sang Phố Xô Bồ).

## Kiến trúc

- Client: Unity (2.5D isometric)
- Backend: .NET 8 modular monolith, 6 module, PostgreSQL, Redis
- Đồng bộ: offline-first, sổ cái kinh tế server-authoritative
- Chi tiết: xem `docs/architecture.md` (tóm tắt từ bản Kiến trúc Đa nền tảng)

## Ưu tiên open-source

- Code game / tool / docs mở dưới giấy phép MIT (`LICENSE`).
- Asset có bản quyền riêng (nhạc, art thuê ngoài) KHÔNG đưa vào repo công khai — chỉ đưa placeholder / asset CC0.
- Không đưa secret, key, tài khoản, dữ liệu người chơi thật vào repo.

## Bắt đầu

```bash
git clone https://github.com/<owner>/pho-xo-bo.git
cd pho-xo-bo
# Unity project sẽ nằm ở src/client (đang khởi tạo)
# Backend .NET 8 sẽ nằm ở src/server (đang khởi tạo)
```

## Đóng góp

Xem `CONTRIBUTING.md`. Mọi PR cần qua review, không merge trực tiếp vào `main`.
