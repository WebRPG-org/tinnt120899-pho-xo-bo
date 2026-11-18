# Phố Xô Bồ — Slice web tĩnh (`src/web/`)

Slice chơi được ngay trên web, theo đúng mô hình đưa link của Treasure of Nadia
trên xenvn.com: **file tĩnh, mở link là chơi, không cài đặt, chơi được trên
Desktop / Android / iPhone bằng trình duyệt**. Xem quyết định đầy đủ ở
`docs/tech-switch-nadia.md` (giữ Unity làm engine game đầy đủ; đây chỉ là
slice web nhẹ, không thay thế Unity).

## Chạy

```bash
cd src/web
python3 -m http.server 8000
# mở http://localhost:8000/
```

Mở trực tiếp file `index.html` cũng chạy (dữ liệu nằm trong `data/maps.js`,
không dùng fetch, tránh lỗi CORS khi mở `file://`).

## Chơi thế nào

- **Đi:** WASD / phím mũi tên, hoặc chạm vào canvas (mobile).
- **Nhặt:** lại gần hotspot vàng lấp lánh rồi nhấn `E` hoặc chạm vào nó.
  Hotspot chỉ có đồ đúng khung (Sáng/Chiều/Tối), nhặt 1 lần/ngày game —
  sang ngày mới có đồ mới (như sparkle của Nadia).
- **Làm ca nghề:** nút "Làm ca nghề" — lương theo chỉ số chính, khung tốt +25%.
- **Chế:** nút "Chế Xe Đẩy" — Xe Đẩy Hàng = Khung Sắt + Bánh Xe + Ván Gỗ
  (tương đương Basic Shovel của Nadia). Chế xong mới mở khu/nghề tiếp theo.
- **Điện thoại:** nút "Điện thoại" hoặc phím `P` — 9 tab như `PhoneHub.cs`.
- **Sang khung sau:** nút "Sang khung sau" — ngày game 3 khung, sang ngày mới
  hotspot reset + lãi tiết kiệm 0,5%.
- **Lưu:** tự động vào localStorage (kiểu xenvn lưu save theo tài khoản —
  ở slice này lưu local, tài khoản làm ở phase online).

## Ranh giới (nói thẳng)

- Vẽ Canvas 2D bằng hình khối/màu — **chưa có art thật**, chưa phải 2.5D
  isometric của bản Unity.
- Chỉ 2 khu slice (Xóm Trọ Cũ, Chợ Đầu Mối), 3 nghề, 2 công thức chế tạo.
- Không có server, không multiplayer, không đấu giá online — các hệ đó ở
  bản Unity + server .NET.
- Mọi hệ mới vẫn viết ở Unity trước; web slice chỉ port lại phần đã chốt.
  Không phát triển `src/web/` thành game thứ hai.
