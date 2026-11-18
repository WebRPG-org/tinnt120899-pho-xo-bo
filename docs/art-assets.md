# Spec tài sản đồ hoạ 2.5D — 2 khu slice đầu: Xóm Trọ Cũ + Chợ Đầu Mối

> Chuẩn tham khảo: Treasure of Nadia (`docs/nadia-reference.md`) + skill
> `soulful_short_video` — khoá thế giới, khoá diễn viên, khoá giọng trước khi
> sản xuất; hỏng thì vẽ / quay lại, không vá trong edit.
> Chuẩn đồ hoạ chung đã lock: `docs/art-style.md`. File này là spec chi tiết
> cho 2 khu slice đầu (khu 1 và khu 2 trong đúng 18 khu, `docs/districts.md`).
> Mọi mô tả verbatim dưới đây dùng **nguyên văn** trong mọi prompt / brief vẽ —
> đổi chữ là đổi mặt phố. Số cấu hình slice ghi PROVISIONAL, chưa chốt.

## 0. Lock chung cho cả 2 khu (không đổi giữa chừng)

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

## 3. Placeholder CC0 — nguồn, quy tắc, bảng theo dõi

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

## 4. Shot list + kiểm tra dailies (theo skill `soulful_short_video`)

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

## 5. Checklist trước khi vẽ / quay khu mới

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

## 6. Liên hệ file khác

- Chuẩn chung: `docs/art-style.md` (§1 lock thế giới, §2 palette, §4 verbatim
  4 khu, §5 placeholder CC0, §6 rubric, §7 kỹ thuật 2.5D).
- Nadia: `docs/nadia-reference.md` (§1 bảng đối chiếu 12 hệ, §2 không lấy,
  §3 checklist bám sát). Code khớp spec này: `Exploration.cs` (hotspot,
  `GuideHint`), `Crafting.cs` (công cụ, công thức), `PhoneHub.cs` (điện thoại
  9 tab), `Inventory.cs` (túi đồ), `Jobs.cs` (3 nghề slice).
- Khu: `docs/districts.md` (đúng 18 khu), GDD Mục 2/9/10/11/12.
