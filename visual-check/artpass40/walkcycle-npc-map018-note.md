# Artpass 40 — Walk-cycle NPC Map018 (Chủ Sạp Đêm + Người Bán Hàng Rong)

Ngày: 25/11/2026. Quy trình vòng 18/22/25/26/27/28/29/30/31/32/33/34/35/36/37/38/39:
ảnh đứng → trắng thành trong suốt (flood fill từ biên qua pixel trắng
min(R,G,B)≥235, feather r=1.5) → resize cao 208px → sheet 6 khung →
kiểm tra bằng mắt → cắt frame bằng script slice → cleanup mảnh vụn rời
mặc định sau mỗi lần cắt → debug-white đối chiếu zoom.

Vị trí Map018 (Phố Đi Bộ – Chợ Đêm): Chủ Sạp Đêm ở ô (3,3);
Người Bán Hàng Rong ở ô (8,6). Dữ liệu thật trong
`src/godot/data/maps.json` (map id 18, events kind npc).

## Nhân vật

- **Chủ Sạp Đêm** — nữ Việt trung niên, chủ sạp chợ đêm: áo bà ba
  TÍM ĐẬM + tạp dề XANH DƯƠNG (KHÔNG đồ trắng/kem — để bước xóa trắng
  kín không thủng áo), đội nón lá, đi dép, cầm ĐÈN LỒNG ĐỎ nhỏ (tay
  phải) + GIỎ HÀNG đầy đồ đủ màu (tay trái). Ảnh đứng:
  `src/godot/art/char_chusapdem.png` (112×208, RGBA). ID NPC
  `chu-sap-dem` → frame dùng tiền tố `walk_chusapdem_`
  (bỏ dấu gạch nối, theo quy tắc test).
- **Người Bán Hàng Rong** — nam Việt trung niên, bán hàng rong chợ
  đêm: áo thun VÀNG (KHÔNG áo trắng), quần kaki nâu, dép, đội nón lá,
  đeo TÚI HÀNG RONG trước ngực + cầm LOA RAO HÀNG nhỏ màu đỏ (tay
  phải). Ảnh đứng: `src/godot/art/char_nguoibanhangrong.png`
  (122×208, RGBA). ID NPC `nguoi-ban-hang-rong` → frame dùng tiền tố
  `walk_nguoibanhangrong_`.

Tham chiếu phong cách: `src/godot/art/char_cotu.png` (112×208, RGBA).

## Prompt đã dùng

Ảnh đứng (mỗi người gen 1 lần, tham chiếu `char_cotu.png`):

> "Use this chibi character style as the exact reference for the
> watercolor/gouache style only. Create a single full-body chibi
> figure, front view, [mô tả nhân vật], same smiling face, same
> hand-drawn watercolor/gouache chibi style as the reference, full body
> visible head to shoes, no cropping, plain white background, no text,
> no background objects."

- Chủ Sạp Đêm (SIẾT GIỚI TÍNH/TUỔI NGAY TỪ ĐẦU — bài học vòng 35/36/37,
  vì tham chiếu `char_cotu.png` là nữ trẻ): "a middle-aged Vietnamese
  WOMAN, kind smiling face, black hair in a low bun, wearing a
  traditional Vietnamese ao ba ba in dark purple (NOT a white or cream
  outfit), a blue apron over it, a conical hat (non la) on her head,
  sandals on her feet, holding a small red lantern in her right hand
  and carrying a shopping basket full of colorful goods in her left
  hand"
- Người Bán Hàng Rong: "a middle-aged Vietnamese MAN, kind smiling
  face, short black hair, wearing a yellow t-shirt (NOT a white
  shirt), brown khaki trousers, sandals on his feet, a conical hat
  (non la) on his head, wearing a street vendor bag full of goods
  strapped across his chest, holding a small red megaphone in his
  right hand"

Walk-cycle sheet (tham chiếu ảnh đứng vừa tạo; prompt vòng 26–39 +
mô tả 6 pha chân khác nhau rõ rệt + SIẾT MỖI ĐẠO CỤ BẰNG MỘT CÂU
RIÊNG gắn tay/vị trí cố định ngay từ lần gen đầu — bài học vòng 39 +
câu "không vật nào chạm sang hình kế"):

> "Use this chibi character as the exact reference. Create a sprite
> sheet of exactly six full-body figures in a single horizontal row,
> evenly spaced, same character, same [clothes], walking poses
> progressing through one walk cycle, front view, plain white
> background, no text. The six figures MUST show six clearly different
> walking phases in order: figure 1 legs wide apart mid-stride,
> figure 2 legs passing each other close together, figure 3 legs
> crossed over, figure 4 legs together passing, figure 5 legs wide
> apart opposite stride, figure 6 legs closing back to the start
> pose. Arms swing opposite to the legs in each figure, same smiling
> face, same hand-drawn watercolor/gouache chibi style as the
> reference, full body visible head to shoes, no cropping, no extra
> figures, no background objects. IMPORTANT: [prop A] MUST be clearly
> visible in ALL six figures AND [prop B] MUST be clearly visible in
> ALL six figures — never omit either prop from any figure. [Câu riêng
> prop A: luôn ở tay/vị trí X trong mọi hình.] [Câu riêng prop B: luôn
> ở tay/vị trí Y trong mọi hình.] Each figure is fully separate: clear
> white space between neighbouring figures, no [props] or any object
> touching or crossing into the next figure."
>
> - Chủ Sạp Đêm: "The red lantern ALWAYS stays in her right hand in
>   every single figure" + "The shopping basket full of colorful goods
>   ALWAYS stays in her left hand in every single figure"
> - Người Bán Hàng Rong: "The street vendor bag ALWAYS stays strapped
>   across his chest in every single figure" + "The small red
>   megaphone ALWAYS stays in his right hand in every single figure"

Số lần gen lại: **ảnh đứng 0 lần; sheet Người Bán Hàng Rong 0 lần;
sheet Chủ Sạp Đêm 4 lần (v1 → v2 → v3 → v4 → v5, chỉ v1 được dùng).**
Cả 2 ảnh đứng + sheet Người Bán Hàng Rong đều đạt ngay lần đầu.

## Lỗi sheet Chủ Sạp Đêm v2–v5 (đã loại, giữ bản thô làm hồ sơ)

Dù đã siết mỗi đạo cụ bằng một câu riêng + (từ v4) liệt kê từng hình
("figure 1 holds …; figure 2 holds …" đủ 6 hình) + (v5) đổi giỏ sang
"hangs from her left forearm", generator vẫn làm rơi 1 đạo cụ ở 1–2
hình trong MỖI bản gen lại — bài học vòng 39 chỉ giảm chứ không triệt
được lỗi này:

- **v2** (2736×912): đèn đủ cả 6 hình, giỏ THIẾU ở f0 (tay trái đung
  đưa trống). Đã siết thêm câu "giỏ phải có ở figure 1".
- **v3** (2736×912): đèn đủ cả 6 hình, giỏ THIẾU ở f4.
- **v4** (2736×912): CHỈ CÓ 5 HÌNH (thiếu 1 hình) + giỏ THIẾU ở f0.
- **v5** (2736×912): giỏ đủ cả 6 hình, đèn THIẾU ở f0 và f3.
- Xem `rejected-walkcycle-sheet-chusapdem-v2.png` … `-v5.png` và bản
  thô `rejected-media-generation-walkcycle-sheet-chusapdem-v*.webp`
  (tên pipeline; v2/v3/v4/v5 lần lượt là
  `…-she-0-db2e7810-…`, `…-she-0-b794c89b-…`,
  `…-she-0-01dccf73-…`, `…-she-0-2a57b4ea-…`).

**v1 ĐƯỢC DÙNG** (2240×1120): đèn + giỏ đủ cả 6 hình — bản duy nhất
trong 5 bản đạt cả 2 đạo cụ ở cả 6 hình. Giá phải trả: sheet DÀY
(pitch ~365px, nón lá các hình chạm nhau, giỏ f0 chạm đèn f1) nên cả
6 hình là MỘT component liên thông duy nhất — xem mục watershed.

## File

| File | Kích thước |
| --- | --- |
| `src/godot/art/char_chusapdem.png` | 112×208 RGBA, 51.528 byte |
| `src/godot/art/char_nguoibanhangrong.png` | 122×208 RGBA, 48.484 byte |
| `src/godot/art/walk_chusapdem_f0.png` … `walk_chusapdem_f5.png` | 116×208 RGBA (canvas chung), 40.672–45.971 byte |
| `src/godot/art/walk_nguoibanhangrong_f0.png` … `walk_nguoibanhangrong_f5.png` | 129×208 RGBA (canvas chung), 45.454–50.949 byte |
| `visual-check/artpass40/walkcycle-sheet-chusapdem.png` | 2240×1120 RGB (v1, dùng) |
| `visual-check/artpass40/walkcycle-sheet-nguoibanhangrong.png` | 2736×912 RGB (v1) |
| `visual-check/artpass40/rejected-walkcycle-sheet-chusapdem-v2.png` … `-v5.png` | 2736×912 RGB (v2–v5 lỗi, giữ làm hồ sơ) |

Bản thô gen ra còn lưu trong `visual-check/artpass40/` với tên
`media-generation-char-*.webp` /
`media-generation-media-generation-walkcycle-she-0-*.webp` (pipeline
media vòng này trả về `.webp`, như vòng 29–39; tên file thô bị
pipeline cắt ngắn stem — `…-char-chusapde-…` thiếu chữ `m` cuối,
`…-walkcycle-she-…` thiếu `et` — đã đổi tên về dạng chuẩn khi chuyển
sang `.png`/`.webp` sạch; bản thô giữ nguyên tên pipeline trả về làm
hồ sơ).
Script xử lý ảnh đứng: `visual-check/artpass40/process_standing_map018.py`
(adapt từ `process_standing_map017.py`, chỉ đổi tên thư mục + tên NPC
+ glob tên file sạch `media-generation-char-{name}.webp`).
Script cắt frame: `visual-check/artpass40/slice_walkcycle_npc_map018.py`
(adapt từ `slice_walkcycle_npc_map017.py`, giữ nguyên `MIN_FIG_W`=100,
`MIN_FIG_H`=100, `MAX_FIG_W`=600 + bước xóa vùng trắng kín ≥100 final
px) — dùng cho Người Bán Hàng Rong; Chủ Sạp Đêm dùng watershed (xem
dưới).
Script watershed: `visual-check/artpass40/slice_walkcycle_chusapdem_ws.py`
(MỚI vòng này — xem mục dưới).
Script kiểm tra debug: `visual-check/artpass40/debug_white_r40.py`
(adapt từ `debug_white_r39.py`; BBOXES đã cập nhật theo kết quả cắt
watershed vòng này; lưu ý: debug_frame dùng `find_figures` (cắt dọc)
để lấy mask, nhưng số vùng trắng kín bị xóa khớp đúng từng frame với
bản watershed nên ảnh debug vẫn đại diện đúng).
Script cleanup: `visual-check/artpass40/cleanup_frames_r40.py`
(adapt từ `cleanup_frames_r39.py`, chỉ đổi tên NPC).
Script erase (REJECTED, KHÔNG CHẠY): `visual-check/artpass40/erase_f1_chunk.py`
(xem mục dưới).
Dải kiểm tra nền magenta: `walkcycle-check-magenta-{chusapdem,nguoibanhangrong}.png`
(tạo lại từ file đích CUỐI sau bước cleanup),
`char-{chusapdem,nguoibanhangrong}-magenta.png` (tạo lại từ file đích
CUỐI sau bước cleanup).
Debug vùng trắng kín: `debug-white-walk_chusapdem_f{0..5}.png`,
`debug-white-walk_nguoibanhangrong_f{0..5}.png`,
`debug-ws-touchzone-f0f1.png` (overlay watershed vùng chạm giỏ/đèn),
`zoom-chusapdem-char-props.png`, `zoom-nguoibanhangrong-char-props.png`,
`zoom-chusapdem-f{0,1,4,5}-*.png`, `zoom-sheet-f1lantern-f0basket.png`,
`zoom-sheet-f4basket-f5lantern.png`.

## Cắt sheet — BÀI HỌC MỚI: watershed thay cắt dọc khi sheet dày

- **Người Bán Hàng Rong: cắt dọc r39 vẫn đúng.** Sheet tách được 5
  component riêng + 1 component đôi (f0+f1, nón chạm nhau) → chỉ cần
  `split_wide_component` 1 lần tại x=473 (col count 29, khe sạch).
  Bbox các hình 448–468px, không vùng trắng kín nào ≥100 final px bị
  xóa.
- **Chủ Sạp Đêm: cắt dọc r39 HỎNG.** Sheet v1 dày (2240×1120): cả 6
  hình là 1 component duy nhất (2191px). Cắt dọc tại cột mật độ thấp
  nhất đi XUYÊN QUA đạo cụ: đèn f1 bị chẻ đôi tại x=430 (nửa trái rơi
  sang frame f0), giỏ f4 bị chẻ tại x=1800, mảnh nón f2 + mảnh giỏ f0
  rơi vào frame f1, vành nón các hình bị cắt phẳng. Đã kiểm chứng
  bằng mắt trên frame cuối (zoom f0/f1/f4) trước khi đổi phương pháp.
- **Watershed (`slice_walkcycle_chusapdem_ws.py`, MỚI):** BFS đa nguồn
  theo trắc địa (geodesic) trong component đã hợp nhất — 6 seed là
  thân các hình (tâm từ bbox cắt dọc, y=550 vùng tạp dề, đã kiểm tra
  seed nằm trên pixel không trắng). Mỗi pixel về với seed tới nó đầu
  tiên QUA mask, nên đạo cụ giữ nguyên với hình cầm nó: đèn f1 (nối
  qua tay f1) về f1 dù nó treo ở phía trái đường giữa f0/f1; giỏ f0
  (nối qua tay f0) về f0. Pixel mỗi hình 184.835–221.610, cân nhau.
  Kết quả: đèn f0/f5 nguyên vẹn (cắt dọc đã chẻ), giỏ f4 nguyên vẹn,
  đèn f1 nguyên vẹn, không còn mảnh nón/giỏ lạ trong frame. Bbox các
  hình chồng nhau theo x (f0 tới 471, f1 từ 408) — đúng bản chất:
  biên watershed uốn lượn, không phải đường dọc.
- **Cleanup (`cleanup_frames_r40.py`):** frame watershed: chusapdem
  f0 xóa 15px, f3 2px, f5 8px (vết rời); f1/f2/f4 1 component, không
  đổi; vendor 12 frame không đổi; char_chusapdem xóa 27px vết
  watercolor rời (13 component → 1). Không còn mảnh 330px như ở bản
  cắt dọc (mảnh đó là giỏ f0 bị chẻ — watershed đã trả về đúng hình).
- **Vùng trắng kín bị xóa (chusapdem):** f0 731, f1 135, f2 159,
  f3 283, f4 600, f5 0 final px — đã đối chiếu debug-white: vùng đỏ
  NẰM ĐÚNG khe nền giữa hai bàn chân (bóng nước dưới chân khép kín
  thành vòng), KHÔNG phải đèn/giỏ; đèn + giỏ còn nguyên trong ảnh
  debug. Vùng trắng kín còn lại lớn nhất trong file đích: 41px
  (chusapdem f3), 13px (vendor f5) — đều <100 nên giữ đúng thiết kế.
  Ảnh đứng cả hai không có vùng trắng kín ≥100 final px nào bị xóa.

## Hai cách sửa vùng chạm đã thử và LOẠI (ghi để không tái phạm)

Vùng chạm duy nhất: giỏ f0 chạm đèn f1 trong sheet v1 (giỏ che mất
mép trái đèn — xem `zoom-sheet-f1lantern-f0basket.png` và
`debug-ws-touchzone-f0f1.png`): watershed gán cho f1 một mảnh góc
dưới-phải của giỏ f0 (~300 final px) ở góc dưới-trái frame f1.

1. **Sửa touch-zone bằng x (cắt x<480 → f0): LOẠI.** Nó lấy luôn
   quai/tay cầm đèn + đầu ngón tay f1 (nằm ở x 470–480), đèn f1
   tách khỏi tay → cleanup xóa mất → f1 MẤT ĐÈN hoàn toàn.
2. **Sửa touch-zone bằng màu (chỉ đổi pixel màu giỏ, giữ đỏ/vàng/
   da): LOẠI.** Ngưỡng màu bắn nhầm trên mép anti-aliased: đèn f1
   chỉ còn một lát mỏng, và nan giỏ sáng bị xếp là "da" nên ở lại
   f1, để lại lỗ trắng trong giỏ f0 (xem `debug-f0-whiteblocks.png`).
3. **Xóa mảnh thừa ở frame cuối (`erase_f1_chunk.py`): LOẠI, KHÔNG
   CHẠY.** Hộp xóa (x≤26, y≥150) ăn luôn mép dưới tối của đèn f1
   (đỏ sẫm, dưới ngưỡng R>150) → đèn chỉ còn lát mỏng. Đã revert
   toàn bộ về trạng thái watershed thuần.
- **Kết luận:** giữ nguyên bản watershed thuần — f1 có đèn + giỏ đầy
  đủ, chỉ kèm mảnh giỏ f0 ở góc dưới-trái (xem hạn chế). Sửa một
  vùng chạm 2D bằng ngưỡng x hay màu đều phá đạo cụ; chỉ chấp nhận
  sửa khi kiểm tra bằng mắt từng frame sau mỗi bước (cả 3 cách trên
  đều bị bắt lỗi ở bước zoom này).

## Godot import

- **Không chạy trong vòng này (theo task: KHÔNG sửa code/test).**
  File `.import` cho 14 file art mới (2 char + 12 walk frame) do agent
  khác chạy import sau, như vòng 34/35/36/37/38/39 đã làm
  (`tools/godot/Godot_v4.7.2-stable_linux.x86_64 --headless --import`).

## Kết quả kiểm tra bằng mắt

- **Ảnh đứng Chủ Sạp Đêm — ĐẠT, không cần gen lại.** Nữ trung niên rõ
  ràng ngay lần đầu: mặt hiền, tóc đen búi thấp, nón lá rộng, áo bà
  ba tím đậm có cúc tàu, tạp dề xanh dương có túi, quần tím, dép
  quai, tay phải cầm đèn lồng đỏ (quai vàng, tua đỏ), tay trái xách
  giỏ đầy thanh long/xoài/hành lá/ớt/quất, nụ cười thân thiện, toàn
  thân đủ, nền trắng trơn, không chữ.
- **Ảnh đứng Người Bán Hàng Rong — ĐẠT, không cần gen lại.** Nam
  trung niên rõ ràng ngay lần đầu: mặt hiền có râu lún phún, tóc đen
  ngắn, áo thun vàng (KHÔNG trắng), quần kaki nâu, dép quai, nón lá,
  túi hàng rong đeo chéo trước ngực đầy bánh mì/nước/chai/rau, tay
  phải cầm loa đỏ, nụ cười hiền, toàn thân đủ, nền trắng trơn, không
  chữ.
- **Sheet Chủ Sạp Đêm v1 — ĐẠT (dùng), không cần gen lại thêm sau v5.**
  Đúng 6 nhân vật, 1 hàng ngang, nền trắng trơn (góc 254–255), không
  chữ. Cùng mặt, nón lá + áo tím đậm + tạp dề xanh + dép, đèn lồng +
  giỏ hàng ở cả 6 hình (đèn ở tay phải mọi hình; giỏ ở tay trái mọi
  hình). Chân tiến triển rõ (dang rộng → khép/bắt chéo → bắt chéo →
  khép → dang rộng ngược → khép về tư thế đầu), tay đung đưa ngược
  pha chân, toàn thân đủ, không cắt tay/chân.
- **Sheet Người Bán Hàng Rong — ĐẠT, không cần gen lại.** Đúng 6 nhân
  vật, 1 hàng ngang cách đều, nền trắng trơn (góc 254–255), không
  chữ. Cùng mặt, tóc đen + áo vàng + quần kaki nâu + dép, túi hàng
  rong + loa đỏ ở cả 6 hình (loa đổi tay theo nhịp đi ở f1/f3/f4 —
  giống clipboard vòng 37, bình nước vòng 39, không phải lỗi). Chân
  tiến triển rõ như trên, tay đung đưa ngược pha chân, toàn thân đủ,
  không cắt tay/chân.
- Ảnh đứng + frame đã kiểm tra trên nền magenta sau khi xử lý trong
  suốt: không quầng trắng, toàn thân nguyên vẹn, frame không lệch
  khỏi tâm canvas. Zoom 3×: đèn lồng còn nguyên quai vàng + tua đỏ,
  giỏ còn nguyên quai + đủ đồ đủ màu (xem `zoom-chusapdem-char-props.png`);
  túi hàng rong còn nguyên quai đeo + đủ đồ, loa đỏ còn nguyên
  (xem `zoom-nguoibanhangrong-char-props.png`); frame chusapdem f0/f4/f5
  và nguoibanhangrong f0/f4 không còn mảnh vụn, đạo cụ nguyên vẹn.

## Hạn chế còn lại

- Chỉ mặt trước (front view, thực tế gen ra dạng 3/4) — giống các vòng
  trước, chưa có mặt sau/mặt nghiêng.
- f5 của cả hai gần như tư thế đứng (chân khép) — chấp nhận được như các
  vòng trước, chu kỳ vẫn lặp mượt; f5 ≈ tư thế khép về đầu chu kỳ.
- f2/f3/f4 của cả hai là 3 tư thế "chân bắt chéo/khép" khá gần nhau (khác
  nhau ở chân nào trước), không tách bạch bằng f0/f4 dang rộng — vẫn đủ
  phân biệt khi chạy. Với Chủ Sạp Đêm, áo bà ba dài che chân nhiều hơn
  (chủ yếu thấy dép đổi vị trí) — chấp nhận, vì trang phục là đặc tính
  nhân vật.
- **Mảnh giỏ thừa ở frame chusapdem f1 (chấp nhận, đã thử sửa 3 cách
  đều hỏng):** góc dưới-trái frame f1 còn một mảnh giỏ của f0
  (~300 final px, nan giỏ + hành lá/quất) — do trong sheet v1 giỏ f0
  chạm và che mép trái đèn f1, watershed gán phần giỏ chạm đèn cho
  f1. Khi chạy animation, mảnh này hiện 1/6 khung ở mép trái f1;
  đèn + giỏ chính của f1 vẫn đầy đủ nên chu kỳ không bị nhấp nháy
  đạo cụ. Vòng sau: nếu sheet dày mà có đạo cụ chạm nhau, cân nhắc
  gen lại sheet thưa hơn thay vì sửa vùng chạm.
- Loa của Người Bán Hàng Rong đổi tay theo nhịp đi giữa các frame —
  giống các vòng trước (clipboard, bình nước), không phải lỗi; đạo cụ
  vẫn hiện liên tục ở cả 6 frame.
- Đèn f1 bị giỏ f0 che mất mép trái trong sheet (chỉ ~60% thân đèn lộ
  ra ở f1, so với đầy đủ ở các hình khác) — chấp nhận, vì đèn vẫn
  nhận diện rõ là đèn lồng đỏ (thân đỏ + quai vàng + tua đỏ); đây
  cũng là gốc của mảnh giỏ thừa ở trên.
- Ngưỡng xóa trắng kín (100 final px) chỉ đúng khi NPC không mặc đồ
  trắng — NPC nào có áo sơ mi trắng / đồ trắng thì KHÔNG được dùng
  bước này (sẽ thủng áo). Vòng này cả hai NPC đều mặc đồ màu (tím
  đậm / vàng) nên an toàn.
- Sheet vòng sau: NPC có 2 đạo cụ thì siết MỖI đạo cụ bằng MỘT CÂU
  RIÊNG ngay từ lần gen đầu (bài học vòng 39, vòng này xác nhận:
  v2–v5 vẫn rơi đạo cụ dù đã siết + liệt kê từng hình — siết câu
  giảm chứ không triệt lỗi, cần kiểm tra bằng mắt từng hình và gen
  lại tới khi đủ); sheet DÀY (pitch <~400px, các hình chạm nhau)
  thì KHÔNG dùng cắt dọc — dùng watershed
  (`slice_walkcycle_chusapdem_ws.py`); và KHÔNG sửa vùng chạm 2D
  bằng ngưỡng x/màu hay xóa hộp ở frame cuối (cả 3 cách đều phá đạo
  cụ — xem mục trên).
- Không sửa code, không export, không push trong vòng này (theo task);
  code + test + import Godot do agent khác làm.
