# Chuẩn đồ hoạ 2.5D — Phố Xô Bồ (vai Đồ hoạ)

> Áp dụng skill `soulful_short_video`: quay như quay thật — khoá thế giới, khoá
> diễn viên, khoá giọng trước khi sản xuất; hỏng thì quay lại, không vá trong edit.
> Chuẩn 2.5D đã chốt ở Mục 10 GDD. File này là lock để mọi art sau này đối chiếu.

## 1. Khóa thế giới trước (lock the world first)

- Tối đa 4 bối cảnh / 1 khu phố trong slice đầu: Xóm Trọ Cũ, Chợ Đầu Mối,
  Công Viên An Bình, Phố Đi Bộ – Chợ Đêm. Mỗi khu có **một mô tả verbatim**
  (xem §4) và dùng nguyên văn trong mọi prompt / brief vẽ — đổi chữ là đổi mặt phố.
- Mỗi khu có 1 ảnh tham chiếu (reference still) trước khi vẽ thêm; mọi take
  sau đối chiếu với ảnh đó, lệch là vẽ lại.
- Khung hình cố định: isometric 2.5D, camera orthographic, góc X ~30° / Y 45°,
  tỉ lệ 9:16 (mobile dọc) làm chuẩn, 16:9 cho PC/Web sau.
- Chi tiết thấy được khi zoom: sạp hàng có nồi niêu / lá chuối / ghế nhựa,
  bệnh viện có giường / máy, nhà có đồ nội thất. Ngày / đêm, mưa / nắng,
  trang trí Tết. NPC và giao thông sống động.

## 2. Palette khóa (không đổi giữa chừng)

| Vai trò | Màu | Ghi chú |
|---------|-----|---------|
| Nền phố / đường | Xám ấm #8A7F70, nhựa đường #5C564E | Không dùng xám lạnh xanh |
| Tường vàng (đặc trưng phố Việt) | #E8C86A, #D9A441 | Tường vàng “khoan cắt bê tông” — nét Việt |
| Mái ngói / tôn | Đỏ gạch #B4452F, tôn xanh #3E7A6E | — |
| Cây / công viên | Xanh lá #4E7A3A | Công Viên An Bình |
| Đỏ Thể | #C0392B | Màu chỉ số gốc |
| Xanh Trí | #2E6FB0 | Màu chỉ số gốc |
| Vàng Tâm | #E0A800 | Màu chỉ số gốc |
| Tím Kỷ / Cam Dũng / Lục Sáng | #7D5BA6 / #D96C2C / #4E9B5A | Màu chỉ số trộn |
| Trắng An Yên | #F2EFE6 | Màu ending chữa lành |

- Ánh sáng: nắng vàng buổi sáng, đèn vàng buổi tối chợ đêm. Không dùng
  neon cyberpunk làm tông chính — phố Việt là nắng, tường vàng, tôn, lá chuối.

## 3. Khóa nhân vật (lock the cast)

- Mô tả nhân vật verbatim (dùng nguyên văn mọi lần): “người Việt trẻ, da vàng
  tự nhiên, tóc đen, mặc đồ thường ngày (áo thun / áo dài / đồ công sở tùy
  tầng), dáng người bình thường, không người mẫu, không mặt Tây”.
- Mỗi bộ đồ có một mô tả verbatim riêng, không đổi giữa các cảnh cùng bộ đồ.
- Biểu cảm: liệt kê trước theo cảnh (cười nhẹ, mệt sau ca làm, vui khi bán
  được hàng, buồn khi thất bại) — mỗi nhân vật có 2–3 micro-beat / cảnh,
  không giữ một biểu cảm suốt cảnh.
- Tay đơn giản: vẫy tay, chạm má, cầm túi — không vẽ tay chơi nhạc cụ,
  gõ máy, cầm vật nhỏ khéo léo (dễ lỗi như skill đã cảnh báo).

## 4. Mô tả verbatim 4 khu slice đầu (dùng nguyên văn)

1. **Xóm Trọ Cũ:** “hẻm nhỏ Sài Gòn, tường vàng loang lổ, dây điện chằng chịt
   trên đầu, xe máy dựng sát tường, chậu cây trước cửa phòng trọ, nắng xiên
   buổi sáng”.
2. **Chợ Đầu Mối:** “chợ đầu mối lúc 5 giờ sáng, sạp rau củ xếp cao, lá chuối,
   thùng xốp, xe ba gác, người gánh hàng, đèn vàng, hơi sương”.
3. **Công Viên An Bình:** “công viên buổi chiều, cây xanh, ghế đá, người già
   tập thể dục, trẻ con chơi, ánh nắng vàng dịu, yên tĩnh”.
4. **Phố Đi Bộ – Chợ Đêm:** “phố đi bộ ban đêm, đèn lồng vàng, sạp ăn vặt
   khói bay, ghế nhựa, đông người, nhạc nhẹ từ loa nhỏ”.

## 5. Art placeholder — rõ nguồn CC0, không asset lậu

- Trong repo hiện tại **chưa có art nào** (`assets/` trống) — đây là trạng
  thái đúng cho tới khi có art tự vẽ. Không đưa asset tải lậu / rip từ game
  khác vào repo.
- Placeholder được phép dùng (ghi rõ nguồn trong file asset):
  - Kenney.nl — CC0 (tile, nhân vật, UI).
  - OpenGameArt.org — chỉ mục có tag CC0.
  - Unity Top-Down Starter Kit (Unity 6.4) — art CC0 kèm kit, chỉ làm mẫu.
- Art demo trong các kit trả phí / Asset Store **không** được ship thương mại.
- Nhạc / giọng: chưa có track nào được chọn. Theo skill: chọn 1 track có bản
  quyền rõ ràng trước khi sản xuất; audio gen chỉ là footage câm, phải lồng
  track thật trong edit. Không hứa gen giọng sẽ ra giọng thật.

## 6. Rubric chấm art (áp dụng thang soulful_short_video: 8 chiều, 0–2, đủ 12/16 mới ship)

| Chiều | 0 = lỗi | 2 = đạt |
|-------|---------|---------|
| 1. Cảm xúc | Mặt đơ / sai cảm xúc cảnh | Đúng biểu cảm đã lock |
| 2. Phản ứng không đồng bộ | NPC cùng cười cùng giây | NPC phản ứng lệch nhau như người thật |
| 3. Tay | Tay sai / cầm vật vô lý | Tay đơn giản, đúng |
| 4. Chuyển động | Chỉ 2 tư thế tĩnh | Thấy chuyển động (tóc bay, bước đi) |
| 5. Nhạc / nhịp | Không khớp beat | Cắt theo beat đã map |
| 6. Giữ mặt | Mặt drift khỏi mô tả verbatim | Mặt nhất quán mọi cảnh |
| 7. Camera | Khung chết, không thở | Có push-in / handheld nhẹ |
| 8. Nhịp cắt | 1 shot dài lê thê | Shot 3–4 giây, không shot nào quá 4 giây / 30 giây |

- Ship khi tổng ≥ 12/16 và không chiều nào 0. Chiều nào 0 thì vẽ / quay lại
  theo lock, không vá bằng blur / cắt nhảy trong edit.
- Kiểm tra dailies: chụp frame ở 1s / 5s / 9s của mỗi take, đọc frame trước
  khi chấm — không chấm theo cảm giác.

## 7. Kỹ thuật 2.5D (từ nghiên cứu, xem docs/references.md)

- Isometric Z as Y, Transparency Sort Axis (0, 1, –0.26); tilemap Chunk cho
  nền tĩnh, Individual chỉ vùng cần sort theo Z.
- Cinemachine + clamp biên; nhân vật pivot đáy (0.5, 0); vật nhiều ô dùng
  Sorting Group.
- Sprite Atlas chia theo khu phố (không 1 mega-atlas); PPU / cell size /
  sorting layer khóa trong 1 file hằng số từ ngày đầu.
- Mục tiêu đo trên máy low-end thật bằng Profiler (draw call, RAM, frame
  time) — không tin con số blog.
