# Artpass 39 — Walk-cycle NPC Map017 (Cô Bán Bánh + Ông Lão Tập Thể Dục)

Ngày: 25/11/2026. Quy trình vòng 18/22/25/26/27/28/29/30/31/32/33/34/35/36/37/38:
ảnh đứng → trắng thành trong suốt (flood fill từ biên qua pixel trắng
min(R,G,B)≥235, feather r=1.5) → resize cao 208px → sheet 6 khung →
kiểm tra bằng mắt → cắt frame bằng script slice (cắt frame ngay trong
vòng này, như vòng 26–38) → cleanup mảnh vụn rời (mới vòng 38, chạy
mặc định sau mỗi lần cắt).

Vị trí Map017 (Công Viên An Bình): Cô Bán Bánh ở ô (3,3);
Ông Lão Tập Thể Dục ở ô (8,6). Dữ liệu thật trong `src/godot/data/maps.json`
(map id 17, events kind npc).

## Nhân vật

- **Cô Bán Bánh** — nữ Việt trung niên, bán bánh ở công viên: áo bà ba
  HỒNG ĐÀO + tạp dề XANH LÁ (KHÔNG đồ trắng/kem — để bước xóa trắng
  kín không thủng áo), đội nón lá, đi dép, cầm GIỎ BÁNH (rổ bánh đủ
  màu) + KHAY BÁNH nhỏ cầm tay. Ảnh đứng:
  `src/godot/art/char_cobanbanh.png` (122×208, RGBA). ID NPC
  `co-ban-banh` → frame dùng tiền tố `walk_cobanbanh_`
  (bỏ dấu gạch nối, theo quy tắc test).
- **Ông Lão Tập Thể Dục** — ông lão Việt tóc bạc, tập thể dục buổi
  sáng: áo thun thể thao XANH NHẠT (KHÔNG áo trắng — đặc biệt KHÔNG
  áo thun trắng), quần thể thao xám, giày thể thao, KHĂN TẬP màu vàng
  cam vắt vai + BÌNH NƯỚC XANH cầm tay. Ảnh đứng:
  `src/godot/art/char_onglaotaptheduc.png` (86×208, RGBA). ID NPC
  `ong-lao-tap-the-duc` → frame dùng tiền tố `walk_onglaotaptheduc_`.

Tham chiếu phong cách: `src/godot/art/char_cotu.png` (112×208, RGBA).

## Prompt đã dùng

Ảnh đứng (mỗi người gen 1 lần, tham chiếu `char_cotu.png`):

> "Use this chibi character style as the exact reference. Create a
> single full-body chibi figure, front view, [mô tả nhân vật], same
> smiling face, same hand-drawn watercolor/gouache chibi style as the
> reference, full body visible head to shoes, no cropping, plain white
> background, no text, no background objects."

- Cô Bán Bánh (SIẾT GIỚI TÍNH/TUỔI NGAY TỪ ĐẦU — bài học vòng 35/36/37,
  vì tham chiếu `char_cotu.png` là nữ trẻ): "Use this chibi character
  style as the exact reference for the watercolor/gouache style only.
  Create a single full-body chibi figure, front view, a middle-aged
  Vietnamese WOMAN, kind smiling face, black hair in a low bun, wearing
  a traditional Vietnamese ao ba ba in peach pink (NOT a white or cream
  outfit), a green apron over it, a conical hat (non la) on her head,
  sandals on her feet, carrying a basket of colorful cakes on one arm
  and holding a small tray of cakes in one hand, same smiling face, same
  hand-drawn watercolor/gouache chibi style as the reference, full body
  visible head to shoes, no cropping, plain white background, no text,
  no background objects."
- Ông Lão Tập Thể Dục: "an elderly Vietnamese MAN, kind smiling face,
  short silver grey hair, wearing a light blue sports t-shirt (NOT a
  white shirt), grey sports trousers, sports shoes, a yellow-orange
  towel draped over one shoulder, holding a blue water bottle in one
  hand"

Walk-cycle sheet (tham chiếu ảnh đứng vừa tạo; prompt vòng 26–38 +
mô tả 6 pha chân khác nhau rõ rệt + SIẾT CẢ 2 ĐẠO CỤ CÙNG LÚC ngay
từ lần gen đầu — bài học vòng 36/37/38 + câu "không vật nào chạm sang
hình kế"):

> "Use this chibi character as the exact reference. Create a sprite sheet
> of exactly six full-body figures in a single horizontal row, evenly
> spaced, same character, same [clothes], same [props], walking poses
> progressing through one walk cycle, front view, plain white background,
> no text. The six figures MUST show six clearly different walking phases
> in order: figure 1 legs wide apart mid-stride, figure 2 legs passing
> each other close together, figure 3 legs crossed over, figure 4 legs
> together passing, figure 5 legs wide apart opposite stride, figure 6
> legs closing back to the start pose. Arms swing opposite to the legs in
> each figure, same smiling face, same hand-drawn watercolor/gouache chibi
> style as the reference, full body visible head to shoes, no cropping, no
> extra figures, no background objects. IMPORTANT: [prop A] MUST be clearly
> visible in ALL six figures AND [prop B] MUST be clearly visible in ALL
> six figures — never omit either prop from any figure. Each figure is
> fully separate: clear white space between neighbouring figures, no
> [props] or any object touching or crossing into the next figure."
>
> - Cô Bán Bánh: "same peach pink ao ba ba, same green apron, same
>   conical hat, same sandals, same basket of colorful cakes and same
>   small tray of cakes" — "the basket of colorful cakes MUST be clearly
>   visible in ALL six figures AND the small tray of cakes MUST be clearly
>   visible in ALL six figures"
> - Ông Lão Tập Thể Dục: "same light blue sports t-shirt, same grey
>   sports trousers, same sports shoes, same yellow-orange towel over the
>   shoulder and same blue water bottle" — "the yellow-orange towel MUST
>   be clearly visible in ALL six figures AND the blue water bottle MUST
>   be clearly visible in ALL six figures"

Số lần gen lại: **ảnh đứng 0 lần; sheet Ông Lão 0 lần; sheet Cô Bán
Bánh 2 lần (v1 → v2 → v3).** Cả 2 ảnh đứng + sheet Ông Lão đều đạt
ngay lần đầu. Sheet Cô Bán Bánh v1 thiếu khay ở 2 hình, v2 thiếu giỏ
ở 1 hình (xem dưới) nên gen lại v3 — v3 đạt ngay.

## Lỗi sheet Cô Bán Bánh v1 + v2 (đã loại, giữ bản thô làm hồ sơ)

Sheet v1 (2736×912): giỏ bánh ở cả 6 hình, nhưng KHAY BÁNH thiếu ở
f1 và f3 (tay phải đung đưa trống, không cầm khay). Khay nhấp nháy
mất/hiện khi chạy animation nên không chấp nhận được.

Prompt v2 siết thêm: "Her right hand ALWAYS holds the small tray of
cakes in every single figure — the tray is never put down, never
missing, never replaced by an empty swinging hand; when the arm swings,
the tray stays in her hand and swings with it." — v2 (2736×912): khay
đủ cả 6 hình, nhưng GIỎ BÁNH thiếu ở f5 (tay phải buông trống, không
còn giỏ). Generator sửa được đạo cụ này thì làm mất đạo cụ kia.

Prompt v3 siết thêm cả hai phía: giữ câu siết khay của v2 + "The
basket of colorful cakes ALWAYS hangs from her left arm in every
single figure — the basket is never put down, never missing, never
hidden behind her body; it stays clearly visible at her left side in
all six figures." — v3 (2736×912): khay + giỏ đủ cả 6 hình. Bài học
cho vòng sau: NPC có 2 đạo cụ thì siết MỖI đạo cụ bằng MỘT câu riêng
("luôn ở tay X / luôn ở bên Y trong mọi hình") ngay từ lần gen đầu —
chỉ siết chung "cả 2 đạo cụ phải có ở mọi hình" vẫn để generator bỏ
sót 1 đạo cụ ở 1–2 hình. Xem `rejected-walkcycle-sheet-cobanbanh-v1.png` /
`rejected-walkcycle-sheet-cobanbanh-v2.png` và bản thô
`rejected-media-generation-walkcycle-sheet-cobanbanh-v1.webp` /
`rejected-media-generation-walkcycle-sheet-cobanbanh-v2.webp`.

## File

| File | Kích thước |
| --- | --- |
| `src/godot/art/char_cobanbanh.png` | 122×208 RGBA, 47.374 byte |
| `src/godot/art/char_onglaotaptheduc.png` | 86×208 RGBA, 42.443 byte |
| `src/godot/art/walk_cobanbanh_f0.png` … `walk_cobanbanh_f5.png` | 138×208 RGBA (canvas chung), 44.903–50.382 byte |
| `src/godot/art/walk_onglaotaptheduc_f0.png` … `walk_onglaotaptheduc_f5.png` | 140×208 RGBA (canvas chung), 40.912–51.012 byte |
| `visual-check/artpass39/walkcycle-sheet-cobanbanh.png` | 2736×912 RGB (v3) |
| `visual-check/artpass39/walkcycle-sheet-onglaotaptheduc.png` | 2736×912 RGB (v1) |
| `visual-check/artpass39/rejected-walkcycle-sheet-cobanbanh-v1.png` | 2736×912 RGB (v1 lỗi, giữ làm hồ sơ) |
| `visual-check/artpass39/rejected-walkcycle-sheet-cobanbanh-v2.png` | 2736×912 RGB (v2 lỗi, giữ làm hồ sơ) |

Bản thô gen ra còn lưu trong `visual-check/artpass39/` với tên
`media-generation-char-*.webp` /
`media-generation-walkcycle-sheet-*.webp` (pipeline media vòng này trả
về `.webp`, như vòng 29–38; sheet `.webp` đã chuyển sang `.png` cùng
tên trước khi cắt frame). Tên file thô của sheet Ông Lão bị pipeline
cắt ngắn stem thành
`media-generation-walkcycle-sheet-onglaotapthedu-0-…webp` (thiếu chữ
`c` cuối, giống vòng 37/38) — đã đổi tên về dạng chuẩn khi chuyển sang
`.png` (`walkcycle-sheet-onglaotaptheduc.png`); bản thô giữ nguyên tên
pipeline trả về làm hồ sơ.
Script xử lý ảnh đứng: `visual-check/artpass39/process_standing_map017.py`
(adapt từ `process_standing_map016.py`, chỉ đổi tên thư mục + tên NPC).
Script cắt frame: `visual-check/artpass39/slice_walkcycle_npc_map017.py`
(adapt từ `slice_walkcycle_npc_map016.py`, giữ nguyên `MIN_FIG_W`=100,
`MIN_FIG_H`=100, `MAX_FIG_W`=600 + bước xóa vùng trắng kín ≥100 final
px — không cần sửa gì thêm vòng này).
Script kiểm tra debug: `visual-check/artpass39/debug_white_r39.py`
(tô đỏ vùng trắng kín đã xóa + đo vùng trắng kín còn lại lớn nhất
trong file đích; BBOXES đã cập nhật theo kết quả cắt vòng này, debug
cả 6 frame của cả 2 NPC).
Script cleanup: `visual-check/artpass39/cleanup_frames_r39.py`
(adapt từ `cleanup_frames_r38.py`, chỉ đổi tên NPC).
Dải kiểm tra nền magenta: `walkcycle-check-magenta-{cobanbanh,onglaotaptheduc}.png`
(được tạo từ file đích sau khi cắt; cleanup không đổi frame nào nên
dải vẫn đúng file cuối),
`char-{cobanbanh,onglaotaptheduc}-magenta.png` (tạo lại từ file đích
CUỐI sau bước cleanup).
Debug vùng trắng kín: `debug-white-walk_cobanbanh_f{0..5}.png`,
`debug-white-walk_onglaotaptheduc_f{0..5}.png`,
`zoom-debug-f3-full.png`, `zoom-debug-f3-tray.png`,
`zoom-cobanbanh-char-props.png`, `zoom-onglaotaptheduc-char-props.png`,
`zoom-cobanbanh-f{1,3}.png`, `zoom-onglaotaptheduc-f{0,4}.png`.

## Sửa script so với vòng 38

- **Slice script: không sửa gì.** Cả 2 sheet đều tách được đúng 6
  component riêng, không cần `split_wide_component` lần nào (câu siết
  "clear white space between neighbouring figures" đã phát huy: nón
  lá rộng + giỏ/khay không chạm sang hình kế). Bbox các hình đều
  361–512px, khe giữa 2 hình 5–19px.
- **Cleanup (`cleanup_frames_r39.py`): chạy mặc định sau cắt như vòng
  38, nhưng KHÔNG đổi gì ở 12 frame** (mỗi frame đúng 1 component —
  không còn mảnh vụn mép như vòng 38, nhờ các hình tách rời nhau).
  Chỉ xóa 2px mảnh rời ở `char_onglaotaptheduc.png` (vết chấm rời
  ngoài thân, biggest 12.646px, 3 components → còn 1).
- Ảnh đứng cả hai không có vùng trắng kín ≥100 final px nào bị xóa
  (không in dòng "removed enclosed white" khi chạy process) — áo bà ba
  hồng đào + áo thun xanh nhạt đều an toàn. Bình nước xanh trong của
  Ông Lão được giữ nguyên (không có vùng trắng kín nào trong bình bị
  xóa — nhựa trong vẽ bằng xanh nhạt, không đạt ngưỡng near-white).

## Godot import

- **Không chạy trong vòng này (theo task: KHÔNG sửa code/test).**
  File `.import` cho 14 file art mới (2 char + 12 walk frame) do agent
  khác chạy import sau, như vòng 34/35/36/37/38 đã làm
  (`tools/godot/Godot_v4.7.2-stable_linux.x86_64 --headless --import`).

## Kết quả kiểm tra bằng mắt

- **Ảnh đứng Cô Bán Bánh — ĐẠT, không cần gen lại.** Nữ trung niên rõ
  ràng ngay lần đầu: mặt hiền có nếp nhăn nhẹ, tóc đen búi thấp, nón
  lá rộng, áo bà ba hồng đào có cúc tàu + túi, tạp dề xanh lá có túi,
  quần đen, dép quai, tay phải cầm khay bánh (4 bánh đủ màu hồng/vàng/
  xanh), tay trái xách giỏ bánh đầy (6–7 bánh đủ màu), nụ cười thân
  thiện, toàn thân đủ, nền trắng trơn, không chữ.
- **Ảnh đứng Ông Lão Tập Thể Dục — ĐẠT, không cần gen lại.** Ông lão
  rõ ràng ngay lần đầu: tóc bạc ngắn, mặt già có nếp nhăn, áo thun thể
  thao xanh nhạt (KHÔNG trắng), quần thể thao xám, giày thể thao xám
  đậm, khăn tập vàng cam vắt vai trái, tay phải cầm bình nước xanh
  (nhãn xanh đậm, nắp xanh), nụ cười hiền, toàn thân đủ, nền trắng
  trơn, không chữ.
- **Sheet Cô Bán Bánh v3 — ĐẠT, không cần gen lại thêm.** Đúng 6 nhân
  vật, 1 hàng ngang cách đều, nền trắng trơn (góc 255,255,255), không
  chữ. Cùng mặt, nón lá + áo hồng đào + tạp dề xanh + dép, giỏ bánh +
  khay bánh ở cả 6 hình (giỏ/khay đổi bên theo nhịp đi ở f1/f3/f4 —
  giống thẻ phòng vòng 38, không phải lỗi). Chân tiến triển rõ (dang
  rộng → khép/bắt chéo → bắt chéo → khép → dang rộng ngược → khép về
  tư thế đầu), tay đung đưa ngược pha chân, toàn thân đủ, không cắt
  tay/chân. f5 gần như tư thế đứng (chân khép) — chấp nhận như các
  vòng trước.
- **Sheet Ông Lão Tập Thể Dục — ĐẠT, không cần gen lại.** Đúng 6 nhân
  vật, 1 hàng ngang cách đều, nền trắng trơn (góc 254,254,254), không
  chữ. Cùng mặt, tóc bạc + áo xanh nhạt + quần xám + giày thể thao,
  khăn vàng cam + bình nước xanh ở cả 6 hình (bình đổi tay theo nhịp
  đi ở f0/f1/f2/f3/f4/f5 — giống clipboard vòng 37, không phải lỗi).
  Chân tiến triển rõ (dang rộng → khép/bắt chéo → bắt chéo → khép →
  dang rộng ngược → khép về tư thế đầu), tay đung đưa ngược pha chân,
  toàn thân đủ, không cắt tay/chân.
- Ảnh đứng + frame đã kiểm tra trên nền magenta sau khi xử lý trong
  suốt: không quầng trắng, toàn thân nguyên vẹn, frame không lệch khỏi
  tâm canvas. Đo bằng script trên file đích: vùng trắng kín còn lại
  lớn nhất chỉ 60px (ảnh đứng cobanbanh, chóp bánh kem trên khay),
  70px (frame cobanbanh f1, bánh trong giỏ), 10px (ảnh đứng
  onglaotaptheduc), 15–37px (frame onglaotaptheduc) — đều <100 final px
  nên được giữ đúng thiết kế. Vùng trắng kín ≥100 final px duy nhất bị
  xóa là cobanbanh f3: 123 final px — đã đối chiếu debug-white: vùng
  đỏ nằm đúng trong vòng quai giỏ (nền nhìn xuyên qua quai giỏ, xem
  `debug-white-walk_cobanbanh_f3.png` và `zoom-debug-f3-full.png`),
  KHÔNG phải bánh; zoom frame cuối f3 trên nền đen cho thấy giỏ + khay
  còn nguyên đủ bánh.
- Zoom 3×: giỏ bánh còn nguyên quai + đủ bánh đủ màu, khay còn nguyên
  4 bánh (xem `zoom-cobanbanh-char-props.png`); bình nước xanh còn
  nguyên nắp + nhãn, khăn vàng cam còn nguyên (xem
  `zoom-onglaotaptheduc-char-props.png`); frame cobanbanh f1/f3 và
  onglaotaptheduc f0/f4 không còn mảnh vụn, đạo cụ nguyên vẹn (xem
  `zoom-cobanbanh-f{1,3}.png`, `zoom-onglaotaptheduc-f{0,4}.png`).

## Hạn chế còn lại

- Chỉ mặt trước (front view, thực tế gen ra dạng 3/4) — giống các vòng
  trước, chưa có mặt sau/mặt nghiêng.
- f5 của cả hai gần như tư thế đứng (chân khép) — chấp nhận được như các
  vòng trước, chu kỳ vẫn lặp mượt; f5 ≈ tư thế khép về đầu chu kỳ.
- f2/f3/f4 của cả hai là 3 tư thế "chân bắt chéo/khép" khá gần nhau (khác
  nhau ở chân nào trước), không tách bạch bằng f0/f4 dang rộng — vẫn đủ
  phân biệt khi chạy. Với Cô Bán Bánh, quần đen + áo bà ba dài che chân
  nhiều hơn (chủ yếu thấy dép đổi vị trí) — chấp nhận, vì trang phục là
  đặc tính nhân vật.
- Giỏ/khay của Cô Bán Bánh và bình nước của Ông Lão đổi bên/đổi tay theo
  nhịp đi giữa các frame — giống các vòng trước (clipboard, thẻ phòng),
  không phải lỗi; khi chạy animation, đạo cụ vẫn hiện liên tục ở cả 6
  frame.
- Bánh trên khay/giỏ có chóp màu kem nhạt — vùng trắng kín lớn nhất còn
  lại 60–70 final px (<100) nên được giữ nguyên; nếu vòng sau NPC có
  đạo cụ trắng lớn hơn, ngưỡng 100 final px có thể ăn mất đạo cụ.
- Ngưỡng xóa trắng kín (100 final px) chỉ đúng khi NPC không mặc đồ
  trắng — NPC nào có áo sơ mi trắng / đồ trắng thì KHÔNG được dùng bước
  này (sẽ thủng áo). Vòng này cả hai NPC đều mặc đồ màu (hồng đào /
  xanh nhạt) nên an toàn.
- Sheet vòng sau: NPC có 2 đạo cụ thì siết MỖI đạo cụ bằng MỘT câu riêng
  ("luôn ở tay X / luôn ở bên Y trong mọi hình") ngay từ lần gen đầu
  (xem lỗi v1/v2 ở trên); các hình trong sheet vẫn có thể chạm nhau 2D
  nên bước cleanup mảnh vụn rời (`cleanup_frames_r39.py`) vẫn chạy mặc
  định sau mỗi lần cắt frame.
- Không sửa code, không export, không push trong vòng này (theo task);
  code + test + import Godot do agent khác làm.
