# Spec tài sản đồ hoạ 2.5D — 4 khu slice đầu: Xóm Trọ Cũ + Chợ Đầu Mối + Công Viên An Bình + Phố Đi Bộ – Chợ Đêm

> Chuẩn tham khảo: Treasure of Nadia (`docs/nadia-reference.md`) + skill
> `soulful_short_video` — khoá thế giới, khoá diễn viên, khoá giọng trước khi
> sản xuất; hỏng thì vẽ / quay lại, không vá trong edit.
> Chuẩn đồ hoạ chung đã lock: `docs/art-style.md`. File này là spec chi tiết
> cho 4 khu slice đầu (khu 1, 2, 17, 18 trong đúng 18 khu, `docs/districts.md`).
> Mọi mô tả verbatim dưới đây dùng **nguyên văn** trong mọi prompt / brief vẽ —
> đổi chữ là đổi mặt phố. Số cấu hình slice ghi PROVISIONAL, chưa chốt.

## 0. Lock chung cho cả 4 khu (không đổi giữa chừng)

- **Khung hình:** isometric 2.5D, camera orthographic, góc X ~30° / Y 45°,
  tỉ lệ 9:16 (mobile dọc) làm chuẩn, 16:9 cho PC/Web sau. Nhân vật pivot đáy
  (0.5, 0). Isometric Z as Y, Transparency Sort Axis (0, 1, −0.26).
- **Tilemap:** Chunk cho nền tĩnh, Individual chỉ vùng cần sort theo Z; vật
  nhiều ô dùng Sorting Group. Sprite Atlas chia theo khu phố (không 1
  mega-atlas); PPU / cell size / sorting layer khoá trong 1 file hằng số từ
  ngày đầu. Cinemachine + clamp biên.
- **Chi tiết kiểu Nadia:** chi tiết thấy được khi zoom — mỗi vật trên map phải
  "kể" được đời sống Việt, không phải prop rỗng. Không hotspot nhỏ li ti phải
  rà từng pixel: hotspot to, lấp lánh, viền sáng rõ, nhìn là biết chạm được.
  Kích thước chạm tối thiểu trên mobile: hotspot ≥ 44×44 pt (PROVISIONAL —
  chốt sau khi test trên máy thật).
- **Nhân vật (verbatim, dùng nguyên văn mọi lần):** "người Việt trẻ, da vàng
  tự nhiên, tóc đen, mặc đồ thường ngày (áo thun / áo dài / đồ công sở tùy
  tầng), dáng người bình thường, không người mẫu, không mặt Tây".
- **Tay:** đơn giản — vẫy tay, chạm má, cầm túi. Không vẽ tay chơi nhạc cụ,
  gõ máy, cầm vật nhỏ khéo léo (dễ lỗi, theo skill).
- **Biểu cảm:** mỗi nhân vật có 2–3 micro-beat / cảnh, không giữ một biểu cảm
  suốt cảnh. NPC phản ứng **không đồng bộ**: một người phản ứng trước, người
  kia phản ứng theo người đầu tiên — không cười cùng giây.
- **Camera:** có push-in / handheld nhẹ, khung "thở". Không shot nào quá
  4 giây trong 30 giây (theo skill). Shot list mỗi khu ≤ 8 shot.
- **Nhạc / giọng:** chưa có track nào được chọn. Audio gen chỉ là footage câm,
  phải lồng track thật có bản quyền rõ ràng trong edit. Không hứa gen giọng
  sẽ ra giọng thật.

### Palette khóa (lấy từ `docs/art-style.md` §2 — không đổi)

| Vai trò | Màu |
|---------|-----|
| Nền phố / đường | Xám ấm #8A7F70, nhựa đường #5C564E (không xám lạnh xanh) |
| Tường vàng (đặc trưng phố Việt) | #E8C86A, #D9A441 |
| Mái ngói / tôn | Đỏ gạch #B4452F, tôn xanh #3E7A6E |
| Cây / công viên | Xanh lá #4E7A3A |
| Đỏ Thể / Xanh Trí / Vàng Tâm | #C0392B / #2E6FB0 / #E0A800 |
| Tím Kỷ / Cam Dũng / Lục Sáng | #7D5BA6 / #D96C2C / #4E9B5A |
| Trắng An Yên | #F2EFE6 |
| Ánh sáng | Nắng vàng buổi sáng, đèn vàng buổi tối chợ đêm. Không neon cyberpunk làm tông chính. |

### Ranh giới cứng (Nadia — chỉ lấy hệ, không lấy nội dung / asset)

- **Không** nội dung người lớn / harem. **Không** copy asset, nhạc, lời thoại,
  nhân vật, tên địa danh của Nadia. **Không** bê cảnh 2D tĩnh PC của Nadia sang
  nguyên dạng — mọi hệ phải chuyển sang 2.5D isometric mobile, chạm tay.
- **Không** hotspot rà pixel, **không** quest khóa ngày/giờ cứng, **không** để
  NPC dẫn đường biến mất giữa game (xem `docs/nadia-reference.md` §2).
- Placeholder chỉ dùng CC0 có nguồn rõ ràng (xem §3). Repo hiện tại chưa có
  art nào (`assets/` trống) — đó là trạng thái đúng cho tới khi có art tự vẽ.

## 1. Khu 1 — Xóm Trọ Cũ (Tầng 1 Lao động, khu bắt đầu)

### 1.1 Mô tả verbatim (dùng nguyên văn, từ `docs/art-style.md` §4)

> "hẻm nhỏ Sài Gòn, tường vàng loang lổ, dây điện chằng chịt trên đầu, xe máy
> dựng sát tường, chậu cây trước cửa phòng trọ, nắng xiên buổi sáng"

### 1.2 Bố cục isometric (slice)

- Hẻm chính chạy chéo từ góc dưới-trái lên góc trên-phải (trục isometric),
  rộng đủ 1 xe máy + 2 người đi bộ tránh nhau. Hai dãy phòng trọ 1 tầng sát
  hai bên hẻm, cửa phòng mở ra hẻm, không có mặt tiền đường lớn.
- Điểm neo (anchor) để người chơi nhận ra khu ngay: **cổng hẻm + cây cột
  điện dây chằng chịt + dãy xe máy dựng sát tường vàng**. Đây là ảnh tham
  chiếu (reference still) của khu — mọi take sau đối chiếu với ảnh này, lệch
  là vẽ lại.
- Khu vực chơi được trong slice: hẻm chính, trước cửa 3 phòng trọ (phòng của
  người chơi, phòng cô Tư, phòng bạn thân NPC), Góc Chế Tạo trong phòng người
  chơi (xem §1.6). Ngoài slice (mở sau): cuối hẻm ra đường lớn, sân phơi chung.

### 1.3 Vật liệu + prop (mỗi prop có mô tả verbatim, không để model tự bịa)

| Prop | Mô tả verbatim | Vật liệu / màu |
|------|---------------|----------------|
| Tường vàng loang lổ | "tường vàng loang lổ, vết ẩm chân tường, dây khoan cắt bê tông dán quảng cáo" | Tường #E8C86A / #D9A441, vết loang xám ấm |
| Dây điện chằng chịt | "dây điện đen chằng chịt vắt ngang hẻm, cột điện gỗ cũ" | Đen #2B2B2B, cột gỗ nâu xỉn |
| Xe máy dựng sát tường | "xe máy cũ dựng sát tường, yên bạc màu, gương gập" | Thân xe xám/đỏ bạc màu, không xe sang |
| Chậu cây trước cửa | "chậu cây nhựa trước cửa phòng trọ, lá xanh, đất ẩm" | Chậu nhựa xanh/đỏ, lá #4E7A3A |
| Cửa phòng trọ | "cửa sắt kéo, sơn xanh lá cũ, ổ khóa to" | Sắt xanh #3E7A6E, rỉ nhẹ |
| Ghế nhựa + bàn nhỏ | "ghế nhựa xanh đỏ trước cửa, bàn nhựa thấp, ly cà phê sữa đá" | Nhựa xanh/đỏ, ly thủy tinh |
| Mái tôn | "mái tôn xanh lợp lệch, gỉ sét mép" | Tôn xanh #3E7A6E, gỉ nâu |
| Nắng xiên buổi sáng | "nắng vàng xiên qua dây điện, vệt sáng dài trên nền hẻm" | Ánh sáng vàng, bóng dài |

### 1.4 NPC trong khu (khoá diễn viên)

| NPC | Mô tả verbatim | Biểu cảm (2–3 micro-beat / cảnh) |
|-----|---------------|----------------------------------|
| Cô Tư — chủ trọ, NPC dẫn đường | "phụ nữ trung niên Việt, tóc búi, áo bà ba nâu, dép lê, dáng thấp đậm" | Cười nhẹ → nghiêm khi nhắc tiền trọ → mềm lại khi dặn dò. Gợi ý bằng lời thoại khi người chơi bí (thay Soul Crystal của Nadia, xem `Exploration.cs` `GuideHint`). |
| Bạn thân NPC | "người Việt trẻ, da vàng tự nhiên, tóc đen, mặc áo thun trắng, quần jean, dáng người bình thường" | Hào hứng → mệt sau ca làm → cười khi bán được hàng. Phản ứng lệch nhịp với cô Tư, không cười cùng giây. |
| Người thuê trọ (quần chúng) | "người Việt trẻ, da vàng tự nhiên, tóc đen, mặc đồ thường ngày, dáng người bình thường" | Đi qua hẻm, gật đầu chào, không đứng yên như tượng — có chuyển động (bước đi, tóc bay nhẹ). |

- Mỗi bộ đồ có mô tả verbatim riêng, không đổi giữa các cảnh cùng bộ đồ.
- Tay đơn giản: vẫy tay chào, chạm má suy nghĩ, cầm túi đồ — không cầm vật nhỏ khéo léo.

### 1.5 Hotspot lấp lánh (khớp code `Exploration.cs`)

| Hotspot (id code) | Vị trí trên map | Vật liệu nhặt | Khung tốt | Dấu hiệu nhìn thấy |
|---|---|---|---|---|
| `hs-tro-toi` — "Hẻm trọ buổi tối" | Cuối hẻm, cạnh thùng rác phân loại | Chai nhựa ×2 | Tối | Điểm sáng lấp lánh trên nắp thùng, viền sáng vàng, to ≥ 44×44 pt |
| (mở sau, chưa vẽ slice) | Trước cửa phòng trọ | Vải vụn | Sáng | — |

- Mỗi hotspot chỉ nhặt 1 lần / 1 ngày game; quay lại ngày sau có vật mới
  (đúng kiểu Nadia). Hotspot ẩn chỉ hiện khi có Đèn Soi bậc cao
  (`Crafting.cs` — Đèn Soi đổi hành vi theo bậc).
- **Không** làm hotspot nhỏ li ti phải rà từng pixel.

### 1.6 Góc Chế Tạo (crafting — cổng tiến trình kiểu Nadia)

- Vị trí: trong phòng người chơi, cạnh cửa sổ — **địa điểm trong thế giới,
  không phải menu trừu tượng** (theo `docs/nadia-reference.md` hàng 3).
- Prop: "bàn gỗ cũ, đèn bàn vàng, hộp dụng cụ, ván gỗ dựa tường, khung sắt
  góc phòng". Công thức đầu tiên học ở đây: Xe Đẩy Hàng = Khung Sắt + Bánh
  Xe + Ván Gỗ (tương đương Basic Shovel của Nadia, đổi sang đồ chợ Việt).
- Người dạy: cô Tư dạy sau khi làm xong quest đầu tiên ở Xóm Trọ Cũ.

### 1.7 Day / night — mưa / nắng — Tết

| Trạng thái | Thay đổi hình ảnh (lock) |
|---|---|
| Sáng (khung 1) | Nắng vàng xiên qua dây điện, vệt sáng dài trên nền hẻm; cửa phòng mở, chậu cây rõ lá. |
| Chiều (khung 2) | Nắng dịu, bóng ngắn lại; người thuê trọ đi làm về, xe máy nhiều hơn. |
| Tối (khung 3) | Đèn vàng trước cửa từng phòng, bóng điện dây chằng chịt sáng lờ mờ; hẻm tối dần, hotspot `hs-tro-toi` lấp lánh rõ nhất. |
| Mưa | Nền hẻm ướt bóng nước, mái tôn nhỏ giọt, NPC che áo mưa; Xe Đẩy bậc thấp không đi được đường mưa (theo `Crafting.cs`). |
| Nắng | Nắng gắt hơn, bóng đậm, NPC đội nón lá / che ô. |
| Tết | Dây đèn lồng đỏ treo ngang hẻm, cành đào trước cửa phòng cô Tư, câu đối đỏ dán cửa sắt — chỉ thay prop trang trí, không đổi bố cục khu. |

## 2. Khu 2 — Chợ Đầu Mối (Tầng 1 Lao động, khu bắt đầu thứ hai)

### 2.1 Mô tả verbatim (dùng nguyên văn, từ `docs/art-style.md` §4)

> "chợ đầu mối lúc 5 giờ sáng, sạp rau củ xếp cao, lá chuối, thùng xốp, xe ba
> gác, người gánh hàng, đèn vàng, hơi sương"

### 2.2 Bố cục isometric (slice)

- Sân chợ hình chữ nhật chéo theo trục isometric, sạp xếp thành 2 dãy đối
  diện, lối đi giữa đủ 1 xe ba gác + 2 người gánh hàng tránh nhau.
- Điểm neo: **sạp rau của chị Lệ ở đầu chợ + dãy sạp rau củ xếp cao + xe ba
  gác đậu giữa sân**. Đây là ảnh tham chiếu của khu — mọi take sau đối chiếu
  với ảnh này, lệch là vẽ lại.
- Khu vực chơi được trong slice: sân chợ chính, sạp chị Lệ, góc phế liệu cuối
  chợ, Góc Chế Tạo ở sạp (xem §2.6). Ngoài slice (mở sau): khu cá / thịt,
  kho hàng, bãi xe ba gác.

### 2.3 Vật liệu + prop

| Prop | Mô tả verbatim | Vật liệu / màu |
|------|---------------|----------------|
| Sạp rau củ xếp cao | "sạp gỗ, rau củ xếp cao thành đống, lá chuối lót dưới, giá ghi tay" | Gỗ nâu, rau xanh #4E7A3A, lá chuối xanh đậm |
| Lá chuối | "lá chuối xanh lót sạp, ướt sương sáng" | Xanh lá đậm, bóng nước |
| Thùng xốp | "thùng xốp trắng xếp chồng, đá lạnh tan, cá rau ướp lạnh" | Xốp trắng #F2EFE6, nước đá |
| Xe ba gác | "xe ba gác cũ, thùng sắt gỉ, chở rau đầy" | Sắt gỉ nâu, rau xanh |
| Người gánh hàng | "người gánh hàng, đòn gánh tre, hai thúng rau hai đầu, bước đều" | Tre vàng, thúng nâu |
| Đèn vàng + hơi sương | "đèn vàng treo trên sạp, hơi sương mờ buổi 5 giờ sáng" | Đèn vàng #E0A800, sương trắng mờ |
| Cân đồng hồ | "cân đồng hồ cũ trên sạp, mặt số tròn, kim rung" | Kim loại xám, mặt trắng |
| Mái bạt chợ | "mái bạt xanh che sạp, nước mưa đọng thành vũng" | Bạt xanh #3E7A6E |

### 2.4 NPC trong khu

| NPC | Mô tả verbatim | Biểu cảm (2–3 micro-beat / cảnh) |
|-----|---------------|----------------------------------|
| Chị Lệ — sạp rau, NPC dẫn đường | "phụ nữ Việt, tóc cột gọn, áo thun hoa, tạp dề xanh, tay thoăn thoắt cân rau" | Cười mời khách → nghiêm khi mặc cả → vui khi bán được hàng. Gợi ý bằng lời thoại khi người chơi bí. |
| Anh Hải — chợ đêm / phế liệu | "đàn ông Việt, da ngăm, áo thun đen, quần short, đội nón lá" | Mệt sau ca → tỉnh khi có khách → cười khi dạy chế Đèn Soi. |
| Người bán / mua (quần chúng) | "người Việt, da vàng tự nhiên, tóc đen, mặc đồ thường ngày, dáng người bình thường" | Mặc cả, xách rau, gánh hàng đi qua — phản ứng lệch nhau, không đồng bộ. |

### 2.5 Hotspot lấp lánh (khớp code `Exploration.cs`)

| Hotspot (id code) | Vị trí trên map | Vật liệu nhặt | Khung tốt | Dấu hiệu nhìn thấy |
|---|---|---|---|---|
| `hs-cho-sang` — "Sạp rau buổi sáng" | Sạp chị Lệ, đầu chợ | Lá chuối ×2 | Sáng | Điểm sáng lấp lánh trên đống lá chuối, viền sáng vàng |
| `hs-cho-chieu` — "Góc phế liệu chợ" | Góc phế liệu cuối chợ | Sắt vụn ×1 | Chiều | Điểm sáng lấp lánh trên đống sắt vụn, viền sáng vàng |

- Nhặt 1 lần / 1 ngày game; quay lại ngày sau có vật mới. Hotspot ẩn chỉ
  hiện khi có Đèn Soi bậc cao.

### 2.6 Góc Chế Tạo ở sạp + nghề slice

- Góc Chế Tạo thứ hai đặt ở sạp cuối chợ (cạnh góc phế liệu): "bàn gỗ thấp,
  hộp dụng cụ, khung sắt, bánh xe cũ" — chế Đèn Soi ở đây (anh Hải dạy).
- Nghề slice gắn với khu (xem `Jobs.cs`): bán rong (khung tốt Chiều), shipper
  (khung tốt Tối), nhân viên quán (khung tốt Sáng). Sạp hàng của người chơi
  đặt ở lối đi giữa chợ, nâng cấp theo bậc: Mẹt tre → Gánh hàng → Xe đẩy →
  Sạp có dù → Ki-ốt (tham khảo Gánh Phố, xem `docs/references.md` — chỉ lấy
  ý nâng cấp sạp, không copy asset).

### 2.7 Day / night — mưa / nắng — Tết

| Trạng thái | Thay đổi hình ảnh (lock) |
|---|---|
| Sáng (khung 1, 5 giờ) | Đèn vàng + hơi sương, sạp rau xếp cao nhất, người gánh hàng đông nhất; hotspot `hs-cho-sang` sáng rõ. |
| Chiều (khung 2) | Nắng dịu, sạp vơi dần, góc phế liệu đông người thu gom; hotspot `hs-cho-chieu` sáng rõ. |
| Tối (khung 3) | Chợ vãn, đèn vàng thưa, xe ba gác về bãi; sạp đóng cửa dần, chỉ còn góc phế liệu sáng đèn. |
| Mưa | Mái bạt đọng nước, nền chợ ướt, rau ướt sương; Xe Đẩy bậc thấp không đi được đường mưa. |
| Nắng | Nắng gắt, bạt che căng, người bán đội nón lá. |
| Tết | Sạp hoa quả Tết, quất / đào bày đầu chợ, đèn lồng đỏ treo trên mái bạt — chỉ thay prop trang trí, không đổi bố cục khu. |

## 3. Khu 17 — Công Viên An Bình (Khu chung, luôn mở, chữa lành)

> Khu chung (17, 18) luôn mở cho mọi người chơi, không phân tầng
> (`docs/districts.md`). Công dụng chốt: gặp gỡ, hẹn hò, sự kiện cộng đồng,
> chữa lành. Không phải khu bắt đầu kiếm tiền — là nơi "thở" giữa các ca làm,
> đúng kiểu Nadia cho người chơi quay lại địa điểm yên tĩnh để hồi sức.

### 3.1 Mô tả verbatim (dùng nguyên văn, từ `docs/art-style.md` §4)

> "công viên buổi chiều, cây xanh, ghế đá, người già tập thể dục, trẻ con chơi,
> ánh nắng vàng dịu, yên tĩnh"

### 3.2 Bố cục isometric (slice)

- Lối đi lát gạch chạy chéo theo trục isometric, hai bên là thảm cỏ + cây xanh
  lớn, ghế đá đặt dọc lối đi, sân chơi trẻ con ở góc xa (mở sau nếu cần —
  trong slice chỉ cần lối đi + 2–3 ghế đá + 1 cây lớn làm điểm neo).
- Điểm neo: **ghế đá dưới cây xanh lớn + người già tập thể dục buổi chiều**.
  Đây là ảnh tham chiếu của khu — mọi take sau đối chiếu với ảnh này, lệch
  là vẽ lại.
- Khu vực chơi được trong slice: lối đi chính, ghế đá hotspot, bãi cỏ gặp gỡ.
  Ngoài slice (mở sau): hồ nước, sân tập dưỡng sinh, khu sự kiện cộng đồng.

### 3.3 Vật liệu + prop (mỗi prop có mô tả verbatim, không để model tự bịa)

| Prop | Mô tả verbatim | Vật liệu / màu |
|------|---------------|----------------|
| Ghế đá công viên | "ghế đá xám, mặt ghế nhẵn bóng vì người ngồi nhiều, kê dưới bóng cây" | Đá xám ấm, không xám lạnh xanh |
| Cây xanh lớn | "cây xanh tán rộng, lá xanh đậm, bóng mát phủ ghế đá" | Lá #4E7A3A, thân nâu |
| Lối đi lát gạch | "lối đi lát gạch đỏ nhạt, lá khô rơi rải rác, sạch sẽ" | Gạch đỏ nhạt, lá khô vàng |
| Đèn công viên | "đèn gang xanh thẫm, chao đèn vàng, chiều tối mới bật" | Gang xanh thẫm, đèn vàng #E0A800 |
| Thảm cỏ | "cỏ xanh, có chỗ cỏ ngả vàng vì nắng, trẻ con ngồi chơi" | Cỏ #4E7A3A, chỗ ngả vàng |
| Thùng rác công viên | "thùng rác xanh lá, nắp đậy, đặt cạnh ghế đá" | Xanh lá #4E7A3A |
| Nắng vàng dịu buổi chiều | "ánh nắng vàng dịu xiên qua tán cây, vệt sáng lốm đốm trên lối đi" | Ánh sáng vàng, bóng lốm đốm |

### 3.4 NPC trong khu (khoá diễn viên)

| NPC | Mô tả verbatim | Biểu cảm (2–3 micro-beat / cảnh) |
|-----|---------------|----------------------------------|
| Ông Ba — NPC dẫn đường | "người già Việt, tóc bạc, áo thun trắng, quần short, dép lê, dáng gầy, ngồi ghế đá" | Hiền → trầm ngâm khi khuyên → cười nhẹ. Gợi ý bằng lời thoại khi người chơi bí (`Exploration.cs` `GuideHint`: "Ngồi ghế đá nghĩ cho kỹ đã"). |
| Người già tập thể dục (quần chúng) | "người già Việt, tóc bạc, đồ thể thao sáng màu, đi bộ chậm quanh công viên" | Thư thái → vẫy tay chào → tập tay chậm. Phản ứng lệch nhịp với ông Ba. |
| Trẻ con chơi (quần chúng) | "trẻ con Việt, áo thun màu sáng, chạy nhảy trên bãi cỏ, cười đùa" | Hào hứng → mệt ngồi nghỉ → cười khi chơi tiếp. Không đứng yên như tượng — có chuyển động. |

- Tay đơn giản: vẫy tay chào, chạm má suy nghĩ, cầm túi đồ — không cầm vật
  nhỏ khéo léo. Trẻ con không vẽ cảnh nguy hiểm (leo cao, chạy ra đường).

### 3.5 Hotspot lấp lánh (khớp code `Exploration.cs`)

| Hotspot (id code) | Vị trí trên map | Vật liệu nhặt | Khung tốt | Dấu hiệu nhìn thấy |
|---|---|---|---|---|
| `hs-cong-vien` — "Ghế đá công viên" | Ghế đá dưới cây xanh lớn, giữa lối đi | Ván gỗ ×1 | Chiều | Điểm sáng lấp lánh trên mặt ghế đá, viền sáng vàng, to ≥ 44×44 pt |

- Nhặt 1 lần / 1 ngày game; quay lại ngày sau có vật mới. Hotspot ẩn chỉ
  hiện khi có Đèn Soi bậc cao.

### 3.6 Day / night — mưa / nắng — Tết

| Trạng thái | Thay đổi hình ảnh (lock) |
|---|---|
| Sáng (khung 1) | Nắng sớm nhẹ, sương mỏng trên cỏ, ít người; ghế đá còn ướt sương. |
| Chiều (khung 2) | Ánh nắng vàng dịu, người già tập thể dục, trẻ con chơi đông nhất; hotspot `hs-cong-vien` sáng rõ. |
| Tối (khung 3) | Đèn công viên vàng bật, công viên vắng dần, ghế đá tối — hotspot mờ đi (khung tốt là Chiều, không phải Tối). |
| Mưa | Lối đi ướt bóng nước, ghế đá ướt, NPC che ô / trú dưới tán cây; Xe Đẩy bậc thấp không đi được đường mưa. |
| Nắng | Nắng gắt hơn, bóng cây đậm, NPC đội nón lá / ngồi dưới bóng mát. |
| Tết | Đèn lồng đỏ treo trên cây dọc lối đi, hoa đào bày gần ghế đá — chỉ thay prop trang trí, không đổi bố cục khu. |

### 3.7 Shot list gợi ý — Công Viên An Bình (PROVISIONAL, chốt khi quay)

1. Toàn công viên buổi chiều, nắng vàng dịu qua tán cây (establishing).
2. Cận ghế đá dưới cây lớn, lá khô trên lối đi.
3. Ông Ba ngồi ghế đá, trầm ngâm → cười nhẹ khuyên người chơi.
4. Người già tập thể dục đi bộ qua, vẫy tay chào.
5. Trẻ con chơi trên bãi cỏ, cười đùa.
6. Hotspot ghế đá lấp lánh buổi chiều.
7. Đèn công viên bật lúc chập tối.
8. Công viên Tết, đèn lồng đỏ trên cây (biến thể).

## 4. Khu 18 — Phố Đi Bộ – Chợ Đêm (Khu chung, luôn mở, sự kiện 20:00 thứ 7)

> Khu chung (17, 18) luôn mở cho mọi người chơi, không phân tầng
> (`docs/districts.md`). Công dụng chốt: sự kiện chung 20:00 thứ 7, buôn bán
> đêm, Bụi Đời Chợ Cá. Đây là khu "đông người" nhất trong 4 khu slice — đối
> lập với sự yên tĩnh của Công Viên An Bình (khu 17).

### 4.1 Mô tả verbatim (dùng nguyên văn, từ `docs/art-style.md` §4)

> "phố đi bộ ban đêm, đèn lồng vàng, sạp ăn vặt khói bay, ghế nhựa, đông người,
> nhạc nhẹ từ loa nhỏ"

### 4.2 Bố cục isometric (slice)

- Phố đi bộ chạy chéo theo trục isometric, hai dãy sạp ăn vặt đối diện, lối
  đi giữa đủ đông người đi bộ tránh nhau, không có xe máy chạy qua.
- Điểm neo: **dãy đèn lồng vàng treo ngang phố + sạp ăn vặt khói bay đầu phố**.
  Đây là ảnh tham chiếu của khu — mọi take sau đối chiếu với ảnh này, lệch
  là vẽ lại.
- Khu vực chơi được trong slice: phố đi bộ chính, sạp đêm cuối phố (hotspot),
  dãy ghế nhựa ven phố. Ngoài slice (mở sau): sân khấu sự kiện 20:00 thứ 7,
  khu Bụi Đời Chợ Cá, bãi giữ xe.

### 4.3 Vật liệu + prop (mỗi prop có mô tả verbatim, không để model tự bịa)

| Prop | Mô tả verbatim | Vật liệu / màu |
|------|---------------|----------------|
| Đèn lồng vàng | "đèn lồng vàng treo ngang phố, sáng ấm, dây đèn căng đều" | Vàng #E0A800, dây đen |
| Sạp ăn vặt khói bay | "sạp ăn vặt, nồi hấp khói bay, mùi thơm, bảng giá ghi tay" | Sạp gỗ nâu, khói trắng mỏng |
| Ghế nhựa | "ghế nhựa xanh đỏ xếp quanh sạp, bàn nhựa thấp, ly nước mía" | Nhựa xanh/đỏ, ly thủy tinh |
| Loa nhỏ | "loa nhỏ đặt trên sạp, phát nhạc nhẹ, dây điện gọn" | Loa đen, dây gọn |
| Biển hiệu sạp | "biển hiệu vải, chữ tay, đèn vàng hắt từ dưới" | Vải trắng, chữ đỏ/đen |
| Đèn đường phố đi bộ | "đèn đường vàng, cột đen, sáng đều cả phố" | Cột đen, đèn vàng |
| Thùng rác phân loại | "thùng rác phân loại cuối phố, nắp đậy, đặt cạnh sạp đêm" | Xanh lá / xám |
| Nền phố lát đá | "nền phố lát đá xám ấm, sạch, phản chiếu đèn vàng" | Đá xám ấm #8A7F70 |

### 4.4 NPC trong khu (khoá diễn viên)

| NPC | Mô tả verbatim | Biểu cảm (2–3 micro-beat / cảnh) |
|-----|---------------|----------------------------------|
| Anh Hải — NPC dẫn đường | "đàn ông Việt, da ngăm, áo thun đen, quần short, đội nón lá" | Mệt sau ca → tỉnh khi có khách → cười khi dạy chế Đèn Soi. Gợi ý bằng lời thoại khi người chơi bí (`Exploration.cs` `GuideHint`: "Đêm nay đông khách, vừa bán vừa nhặt được đồ"). Cùng người với anh Hải ở Chợ Đầu Mối (khu 2) — không vẽ thành 2 người khác nhau. |
| Người bán sạp đêm (quần chúng) | "người Việt, da vàng tự nhiên, tóc đen, mặc đồ thường ngày, tạp dề, tay thoăn thoắt bán hàng" | Cười mời khách → nghiêm khi mặc cả → vui khi bán được hàng. Phản ứng lệch nhau, không đồng bộ. |
| Người đi bộ / khách ăn vặt (quần chúng) | "người Việt, da vàng tự nhiên, tóc đen, mặc đồ thường ngày, dáng người bình thường" | Đi dạo, ngồi ghế nhựa ăn vặt, nghe nhạc — có chuyển động, không đứng yên như tượng. |

- Tay đơn giản: vẫy tay chào, cầm túi đồ, bưng khay — không cầm vật nhỏ
  khéo léo. Khói bay vẽ mỏng, không che mặt nhân vật.

### 4.5 Hotspot lấp lánh (khớp code `Exploration.cs`)

| Hotspot (id code) | Vị trí trên map | Vật liệu nhặt | Khung tốt | Dấu hiệu nhìn thấy |
|---|---|---|---|---|
| `hs-cho-dem` — "Sạp đêm cuối phố" | Sạp ăn vặt cuối phố, cạnh thùng rác phân loại | Vải vụn ×2 | Tối | Điểm sáng lấp lánh trên sạp đêm, viền sáng vàng, to ≥ 44×44 pt |

- Nhặt 1 lần / 1 ngày game; quay lại ngày sau có vật mới. Hotspot ẩn chỉ
  hiện khi có Đèn Soi bậc cao.
- Sự kiện chung 20:00 thứ 7 tổ chức ở khu này (xem `docs/districts.md`) —
  spec ánh sáng / sân khấu sự kiện là việc riêng, không vẽ vào slice này.

### 4.6 Day / night — mưa / nắng — Tết

| Trạng thái | Thay đổi hình ảnh (lock) |
|---|---|
| Sáng (khung 1) | Phố vắng, sạp chưa mở, đèn lồng tắt; chỉ có người dọn phố. |
| Chiều (khung 2) | Sạp bắt đầu dọn hàng, đèn lồng chưa bật, người đi bộ thưa dần. |
| Tối (khung 3) | Đèn lồng vàng bật hết, sạp ăn vặt khói bay, đông người nhất; hotspot `hs-cho-dem` sáng rõ. |
| Mưa | Phố ướt bóng nước, sạp căng bạt, khách trú mưa dưới mái hiên; Xe Đẩy bậc thấp không đi được đường mưa. |
| Nắng | Ban ngày nắng gắt, sạp đóng cửa, phố vắng — khu này sống về đêm, không vẽ cảnh nắng gắt đông người. |
| Tết | Đèn lồng đỏ thêm vào dãy đèn vàng, cành đào bày đầu phố, sạp bánh Tết — chỉ thay prop trang trí, không đổi bố cục khu. |

### 4.7 Shot list gợi ý — Phố Đi Bộ – Chợ Đêm (PROVISIONAL, chốt khi quay)

1. Toàn phố ban đêm, đèn lồng vàng + khói sạp ăn vặt (establishing).
2. Sạp ăn vặt đầu phố, nồi hấp khói bay, bảng giá ghi tay.
3. Anh Hải bán hàng, mệt → tỉnh khi có khách → cười.
4. Khách ngồi ghế nhựa ăn vặt, nghe nhạc nhẹ từ loa nhỏ.
5. Hotspot sạp đêm cuối phố lấp lánh.
6. Người đi bộ đông, đèn lồng phản chiếu trên nền đá.
7. Sạp đóng cửa dần cuối đêm, đèn lồng tắt từng dãy.
8. Phố Tết, đèn lồng đỏ + sạp bánh Tết (biến thể).

## 5. Placeholder CC0 — nguồn, quy tắc, bảng theo dõi

- **Chỉ dùng:** Kenney.nl (CC0) và OpenGameArt.org (chỉ mục có tag CC0).
  Unity Top-Down Starter Kit (Unity 6.4) — art CC0 kèm kit, chỉ làm mẫu.
- **Không dùng:** art demo trong kit trả phí / Asset Store để ship thương mại;
  asset tải lậu / rip từ game khác (kể cả Nadia, Gánh Phố, Đế Chế Vỉa Hè).
- **Không dùng:** nhạc / giọng chưa có bản quyền rõ ràng. Chọn 1 track có
  bản quyền rõ ràng trước khi sản xuất; audio gen chỉ là footage câm.
- Ghi nguồn trong file asset + bảng dưới đây mỗi khi thêm placeholder. File
  chưa có placeholder nào — bảng đang trống là trạng thái đúng.

| Asset placeholder | Nguồn (CC0) | Dùng ở khu | Trạng thái |
|---|---|---|---|
| (chưa có) | — | — | `assets/` đang trống |

## 6. Shot list + kiểm tra dailies (theo skill `soulful_short_video`)

- Mỗi khu ≤ 8 shot cho 30 giây, shot trung bình 3–4 giây, không shot nào
  quá 4 giây. Quay theo thứ tự shot list, kiểm tra mỗi take với lock set /
  lock frame / expression sheet trước khi quay take tiếp.
- Dailies: chụp frame ở 1s / 5s / 9s của mỗi take (`ffmpeg -ss`), đọc frame
  trước khi chấm. Đếm biểu cảm khác nhau trong 1 take — take giữ 1 biểu cảm
  suốt take là hỏng. Kiểm tra NPC không cười cùng giây, tay đúng, có chuyển
  động (tóc bay, bước đi), camera có push-in / handheld nhẹ.
- Rubric 8 chiều, 0–2 mỗi chiều, ship khi tổng ≥ 12/16 và không chiều nào 0
  (xem `docs/art-style.md` §6). Chiều nào 0 thì vẽ / quay lại theo lock,
  không vá bằng blur / cắt nhảy trong edit.

### Shot list gợi ý — Xóm Trọ Cũ (PROVISIONAL, chốt khi quay)

1. Toàn hẻm buổi sáng, nắng xiên qua dây điện (establishing).
2. Cận cửa phòng người chơi, chậu cây + ghế nhựa.
3. Cô Tư đứng cửa, cười nhẹ → nghiêm nhắc tiền trọ.
4. Bạn thân vẫy tay chào, cầm túi đồ đi làm.
5. Hotspot cuối hẻm lấp lánh buổi tối (Đèn Soi).
6. Góc Chế Tạo trong phòng, bàn gỗ + đèn vàng.
7. Xe máy dựng sát tường, nắng xiên.
8. Hẻm Tết (biến thể, quay khi tới mùa Tết trong game).

### Shot list gợi ý — Chợ Đầu Mối (PROVISIONAL, chốt khi quay)

1. Toàn sân chợ 5 giờ sáng, đèn vàng + hơi sương (establishing).
2. Sạp chị Lệ, rau củ xếp cao, lá chuối.
3. Chị Lệ cân rau, cười mời khách → mặc cả.
4. Người gánh hàng đi qua lối giữa, đòn gánh tre.
5. Hotspot sạp rau buổi sáng lấp lánh.
6. Góc phế liệu buổi chiều, anh Hải dạy chế Đèn Soi.
7. Xe ba gác chở rau đầy rời chợ.
8. Sạp Tết, hoa quả + đèn lồng đỏ (biến thể).

## 7. Checklist trước khi vẽ / quay khu mới

- [ ] Mô tả verbatim khu đã viết, dùng nguyên văn trong mọi prompt / brief?
- [ ] Ảnh tham chiếu (reference still) đã có, mọi take đối chiếu với nó?
- [ ] Palette có đúng bảng lock §0, không neon cyberpunk làm tông chính?
- [ ] Hotspot có to, lấp lánh, chạm được — hay phải rà từng pixel? (Phải là vế đầu.)
- [ ] NPC có 2–3 micro-beat, phản ứng không đồng bộ, tay đơn giản?
- [ ] Công cụ nâng cấp có đổi hành vi thật không (theo `Crafting.cs`)?
- [ ] Có NPC dẫn đường bằng lời thoại khi người chơi bí không?
- [ ] Placeholder có nguồn CC0 rõ ràng, không asset Nadia / asset lậu?
- [ ] Số liệu mới có mâu thuẫn `GameBalance.cs` / GDD không? Số chưa chốt ghi PROVISIONAL?
- [ ] Rubric đủ 12/16, không chiều nào 0 — chưa đủ thì vẽ / quay lại, không vá trong edit?

## 8. Liên hệ file khác

- Chuẩn chung: `docs/art-style.md` (§1 lock thế giới, §2 palette, §4 verbatim
  4 khu, §5 placeholder CC0, §6 rubric, §7 kỹ thuật 2.5D).
- Nadia: `docs/nadia-reference.md` (§1 bảng đối chiếu 12 hệ, §2 không lấy,
  §3 checklist bám sát). Code khớp spec này: `Exploration.cs` (hotspot,
  `GuideHint`), `Crafting.cs` (công cụ, công thức), `PhoneHub.cs` (điện thoại
  9 tab), `Inventory.cs` (túi đồ), `Jobs.cs` (3 nghề slice).
- Khu: `docs/districts.md` (đúng 18 khu), GDD Mục 2/9/10/11/12.
