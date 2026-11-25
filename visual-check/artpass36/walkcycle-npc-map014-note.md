# Artpass 36 — Walk-cycle NPC Map014 (Quản Gia Đảo + Chủ Biệt Thự Đảo)

Ngày: 25/11/2026. Quy trình vòng 18/22/25/26/27/28/29/30/31/32/33/34/35: ảnh đứng →
trắng thành trong suốt (flood fill từ biên qua pixel trắng
min(R,G,B)≥235, feather r=1.5) → resize cao 208px → sheet 6 khung →
kiểm tra bằng mắt → cắt frame bằng script slice (cắt frame ngay trong
vòng này, như vòng 26/27/28/29/30/31/32/33/34/35).

Vị trí Map014 (Đảo Thượng Lưu): Quản Gia Đảo ở ô (3,3); Chủ Biệt Thự Đảo
ở ô (8,6). Dữ liệu thật trong `src/godot/data/maps.json` (map id 14,
events kind npc).

## Nhân vật

- **Quản Gia Đảo** — nam người Việt, quản gia đảo: áo đuôi tôm đen, ÁO SƠ
  MI XÁM NHẠT (KHÔNG áo trắng — để bước xóa trắng kín không thủng áo),
  nơ đen, quần âu tối, giày da đen, găng tay tối màu, cầm khay bạc có ấm
  trà + tách. Ảnh đứng: `src/godot/art/char_quangiadao.png` (95×208,
  RGBA). ID NPC `quan-gia-dao` → frame dùng tiền tố `walk_quangiadao_`
  (bỏ dấu gạch nối, theo quy tắc test).
- **Chủ Biệt Thự Đảo** — nữ người Việt, chủ biệt thự đảo giàu có: váy dài
  màu hồng đào nhạt thanh lịch (kiểu áo dài, cổ trụ, khuy bấm, xẻ tà),
  mũ rộng vành, cầm quạt tay + túi xách nhỏ. Ảnh đứng:
  `src/godot/art/char_chubietthudao.png` (113×208, RGBA). ID NPC
  `chu-biet-thu-dao` → frame dùng tiền tố `walk_chubietthudao_`.

Tham chiếu phong cách: `src/godot/art/char_cotu.png` (112×208, RGBA).

## Prompt đã dùng

Ảnh đứng (mỗi người gen 1 lần, tham chiếu `char_cotu.png`):

> "Use this chibi character style as the exact reference. Create a single
> full-body chibi figure, front view, [mô tả nhân vật], same smiling face,
> same hand-drawn watercolor/gouache chibi style as the reference, full body
> visible head to shoes, no cropping, plain white background, no text, no
> background objects."

- Quản Gia Đảo (SIẾT GIỚI TÍNH NGAY TỪ ĐẦU — bài học vòng 35, vì tham
  chiếu `char_cotu.png` là nữ): "Use this chibi character style as the
  exact reference for the watercolor/gouache style only. Create a single
  full-body chibi figure, front view, an adult Vietnamese MAN, masculine
  face, short black hair neatly combed to the side, no earrings, no bun,
  no long hair, wearing a black tailcoat, light grey dress shirt (NOT a
  white shirt), black bow tie, dark dress trousers, black leather shoes,
  dark gloves, holding a silver tray with a teapot and a teacup, same
  smiling face, same hand-drawn watercolor/gouache chibi style as the
  reference, full body visible head to shoes, no cropping, plain white
  background, no text, no background objects."
- Chủ Biệt Thự Đảo: "an elegant wealthy Vietnamese woman, owner of an
  island villa, wearing a long elegant pale peach-pink dress, a
  wide-brimmed hat, holding a hand fan and a small handbag"

Walk-cycle sheet (tham chiếu ảnh đứng vừa tạo; prompt vòng 26/27/28/29/30/31/32/33/34/35 +
mô tả 6 pha chân khác nhau rõ rệt):

> "Use this chibi character as the exact reference. Create a sprite sheet
> of exactly six full-body figures in a single horizontal row, evenly
> spaced, same character, same [clothes], same [hair/hat], walking poses
> progressing through one walk cycle, front view, plain white background,
> no text. The six figures MUST show six clearly different walking phases
> in order: figure 1 legs wide apart mid-stride, figure 2 legs passing
> each other close together, figure 3 legs crossed over, figure 4 legs
> together passing, figure 5 legs wide apart opposite stride, figure 6
> legs closing back to the start pose. Arms swing opposite to the legs in
> each figure, same smiling face, same hand-drawn watercolor/gouache chibi
> style as the reference, full body visible head to shoes, no cropping, no
> extra figures, no background objects."
>
> - Quản Gia Đảo: "same black tailcoat, same light grey dress shirt, same
>   black bow tie, same dark dress trousers, same black leather shoes,
>   same dark gloves, same silver tray with teapot and teacup"
> - Chủ Biệt Thự Đảo: "same long pale peach-pink dress, same wide-brimmed
>   hat, same hand fan and same small handbag"

Số lần gen lại: **1 lần duy nhất — sheet walk-cycle Chủ Biệt Thự Đảo**
(xem dưới). Cả 2 ảnh đứng + sheet Quản Gia Đảo đều đạt ngay lần đầu,
không cần resume snapshot. Prompt siết giới tính của Quản Gia Đảo đã
phát huy tác dụng: gen ra nam ngay lần đầu, không tái phạm lỗi vòng 35.

### Gen lại sheet Chủ Biệt Thự Đảo (lần đầu THIẾU QUẠT ở f5)

Sheet đầu (`rejected-nofan-f5-walkcycle-sheet-chubietthudao-56867cd6.webp`,
603.892 byte, 2240×1120) đúng 6 hình, chân tiến triển rõ, túi xách đủ cả
6 hình — nhưng **f5 (hình khép về tư thế đứng) không có quạt tay**: tay
phải buông trống, trong khi f0–f4 đều cầm quạt. Đây là lỗi đạo cụ thiếu ở
1 frame theo tiêu chí "đạo cụ ở cả 6 hình" của các vòng trước, nên gen
lại 1 lần với prompt siết thêm:

> "…same small handbag in her left hand… IMPORTANT: the hand fan MUST be
> clearly visible in her right hand in ALL six figures, including the
> sixth figure — never omit the fan from any figure. …"

Bản gen lại (`media-generation-walkcycle-sheet-chubietthudao-0-8cccb6d1.webp`,
563.882 byte, 2736×912) ĐẠT: quạt đủ cả 6 hình. Đánh đổi nhỏ: bản này
lại thiếu túi xách ở f2 (tay trái buông trống, xem mục Hạn chế) — chấp
nhận vì quạt là đạo cụ lớn, cầm cao ngang ngực, thiếu ở f5 (frame khép
về tư thế đứng, giống ảnh đứng nhất) lộ hơn nhiều so với túi xách nhỏ
thiếu ở 1 frame giữa chu kỳ. Bài học: siết 1 đạo cụ có thể làm mất đạo
cụ khác ở 1 frame — vòng sau siết cả 2 đạo cụ cùng lúc ("fan in ALL six
figures AND handbag in ALL six figures").

## File

| File | Kích thước |
| --- | --- |
| `src/godot/art/char_quangiadao.png` | 95×208 RGBA, 38.960 byte |
| `src/godot/art/char_chubietthudao.png` | 113×208 RGBA, 43.164 byte |
| `src/godot/art/walk_quangiadao_f0.png` … `walk_quangiadao_f5.png` | 138×208 RGBA (canvas chung), 38.938–46.106 byte |
| `src/godot/art/walk_chubietthudao_f0.png` … `walk_chubietthudao_f5.png` | 137×208 RGBA (canvas chung), 46.430–53.733 byte |
| `visual-check/artpass36/walkcycle-sheet-quangiadao.png` | 2736×912 RGB, 2.073.042 byte |
| `visual-check/artpass36/walkcycle-sheet-chubietthudao.png` | 2736×912 RGB, 2.418.578 byte |

Bản thô gen ra còn lưu trong `visual-check/artpass36/` với tên
`media-generation-char-*.webp` / `media-generation-walkcycle-sheet-*.webp`
(pipeline media vòng này trả về `.webp`, như vòng 29/30/31/32/33/34/35;
sheet `.webp` đã chuyển sang `.png` cùng tên trước khi cắt frame). Tên
file thô do pipeline trả về có tiền tố dài `media-generation-media-generation-…`
và bị cắt ngắn tên stem — đã đổi tên về dạng chuẩn
`media-generation-char-{name}-0-*.webp` /
`media-generation-walkcycle-sheet-{name}-0-*.webp` để khớp glob của
script. Sheet đầu thiếu quạt của Chủ Biệt Thự Đảo giữ lại làm hồ sơ
dưới tên `rejected-nofan-f5-walkcycle-sheet-chubietthudao-56867cd6.webp`
(đã đổi tên để glob `-0-*` của script chỉ khớp đúng bản đã chọn).
Script xử lý ảnh đứng: `visual-check/artpass36/process_standing_map014.py`.
Script cắt frame: `visual-check/artpass36/slice_walkcycle_npc_map014.py`.
Dải kiểm tra nền magenta: `walkcycle-check-magenta-{quangiadao,chubietthudao}.png`,
`char-{quangiadao,chubietthudao}-magenta.png`.
Debug vùng trắng kín: `debug-white-walk_quangiadao_f{1,2,3}.png`,
`debug-white-walk_chubietthudao_f{0,4}.png` (vùng trắng kín đã xóa tô đỏ),
`zoom-quangiadao-char-tray.png`, `zoom-quangiadao-char-shirt.png`,
`zoom-quangiadao-f0-tray.png`, `zoom-chubietthudao-f5.png`,
`zoom-chubietthudao-regen-f2.png`, `zoom-chubietthudao-regen-f5.png`
(phóng to trên nền magenta / từ sheet gốc).

## Sửa script so với vòng 35

- **Một sửa duy nhất, ở script cắt frame: `MIN_FIG_H` = 100.** Sheet
  Quản Gia Đảo có một bóng đổ mặt đất TÁCH RỜI dưới chân f0 (x297–491,
  y823–843, rộng 195px, cao chỉ 21px) — đủ rộng để qua `MIN_FIG_W`=100
  nên `find_figures` đếm thành 7 hình thay vì 6 và script dừng lỗi.
  Sửa: bỏ các component có bbox cao < 100px (hình thật cao ~750px, bóng
  đổ tách rời cao 21px, các đốm nhỏ ≤7px). Bóng đổ nào DÍNH với chân thì
  vẫn giữ nguyên trong frame như các vòng trước (chỉ bóng tách rời mới
  bị loại) — f0 Quản Gia Đảo mất vệt bóng mờ dưới chân, không ảnh hưởng
  nhân vật. GIỮ NGUYÊN toàn bộ logic còn lại, gồm `split_wide_component`
  (`MAX_FIG_W` = 600) và bước xóa vùng trắng kín ≥100 final px.
- Sheet Quản Gia Đảo: sau sửa, đúng 6 component, không cần tách.
  Sheet Chủ Biệt Thự Đảo (bản gen lại): 4 hình giữa dính nhau thành 1
  component rộng 1771px (mũ rộng vành chạm nhau) — `split_wide_component`
  tách thành công ở x=1361 (col count 67), x=926 (76), x=1799 (223),
  đúng 6 hình, không cắt vào nhân vật.
- Cả hai NPC đều không mặc đồ trắng (sơ mi xám nhạt / váy hồng đào
  nhạt) nên bước xóa trắng kín ≥100 final px được phép — và thực tế
  vùng bị xóa đều là nền nhìn xuyên qua (xem dưới), không phải đồ mặc.

## Godot import

- **Không chạy trong vòng này (theo task: KHÔNG chạy export Godot).**
  File `.import` cho 14 file art mới (2 char + 12 walk frame) do agent
  khác chạy import sau, như vòng 34/35 đã làm
  (`tools/godot/Godot_v4.7.2-stable_linux.x86_64 --headless --import`).

## Kết quả kiểm tra bằng mắt

- **Ảnh đứng Quản Gia Đảo — ĐẠT, không cần gen lại.** Nam rõ ràng ngay
  lần đầu nhờ prompt siết giới tính: mặt nam, râu lún phún nhẹ, tóc đen
  ngắn chải lệch sang một bên, không bông tai, không búi. Áo đuôi tôm
  đen có ve + cúc + đuôi áo, sơ mi xám nhạt, nơ đen, quần âu tối, giày
  da đen bóng, găng tay tối màu, tay trái cầm khay bạc có ấm trà + tách,
  nụ cười thân thiện, toàn thân đủ, nền trắng trơn, không chữ.
- **Ảnh đứng Chủ Biệt Thự Đảo — ĐẠT, không cần gen lại.** Nữ quý phái,
  tóc đen búi gọn, mũ rộng vành có nơ hồng, váy dài hồng đào nhạt kiểu
  áo dài (cổ trụ, khuy bấm, xẻ tà), tay phải cầm quạt xếp hồng/trắng,
  tay trái xách túi nhỏ chần bông, dép quai nâu, nụ cười thân thiện,
  toàn thân đủ, nền trắng trơn, không chữ. (Chi tiết nhỏ: nhân vật đi
  dép quai thay vì giày — task không quy định giày, chấp nhận được.)
- **Sheet Quản Gia Đảo — ĐẠT, không cần gen lại.** Đúng 6 nhân vật, 1
  hàng ngang cách đều, nền trắng trơn (góc 252,251,252), không chữ.
  Cùng mặt, tóc, áo đuôi tôm + sơ mi xám nhạt + nơ đen + quần âu tối +
  giày da đen, khay bạc + ấm trà + tách ở cả 6 hình. Chân tiến triển rõ
  (dang rộng → khép/bắt chéo → bắt chéo → khép → dang rộng ngược → khép
  về tư thế đầu), tay đung đưa ngược pha chân, tay phải đeo găng đung
  đưa, khay giữ ở tay trái cả 6 hình. Toàn thân đủ, không cắt tay/chân.
- **Sheet Chủ Biệt Thự Đảo (bản gen lại) — ĐẠT.** Đúng 6 nhân vật, 1
  hàng ngang cách đều, nền trắng trơn (góc 255,255,255), không chữ.
  Cùng mặt, mũ rộng vành + váy hồng đào nhạt + dép quai, quạt tay ở cả
  6 hình, túi xách ở 5/6 hình (thiếu f2, xem Hạn chế). Chân tiến triển
  rõ (dang rộng → khép/bắt chéo → bắt chéo → khép → dang rộng ngược →
  khép về tư thế đầu), tay đung đưa ngược pha chân, quạt/túi đổi tay
  theo nhịp đi ở f3/f4 (quạt sang tay trái, túi sang tay phải — giống
  laptop/tablet vòng 32, sổ tay vòng 31, không phải lỗi). Toàn thân đủ,
  không cắt tay/chân.
- Ảnh đứng + frame đã kiểm tra trên nền magenta sau khi xử lý trong suốt:
  không quầng trắng, toàn thân nguyên vẹn, frame không lệch khỏi tâm
  canvas. Đo bằng script trên file đích: vùng trắng kín còn lại lớn nhất
  chỉ 69px (frame chubietthudao f0, nếp váy) và 35px (frame quangiadao),
  48px (ảnh đứng chubietthudao), 25px (ảnh đứng quangiadao) — đều
  <100 final px nên được giữ đúng thiết kế. Các vùng trắng kín ≥100
  final px đã xóa đều là NỀN nhìn xuyên qua, đã đối chiếu debug-white:
  Quản Gia Đảo f1/f2/f3 xóa tam giác giữa 2 chân khi chân bắt chéo
  (f1: 485, f2: 300, f3: 475 final px; vị trí x99–238, y656–751 trùng
  đúng khoảng giữa 2 chân); Chủ Biệt Thự Đảo f0/f4 xóa nền nhìn qua khe
  xẻ tà váy (f0: 442, f4: 303 final px; xem
  `debug-white-walk_chubietthudao_f0.png` — vùng đỏ nằm đúng trong khe
  tà, 2 tà váy còn nguyên); ảnh đứng Quản Gia Đảo xóa 177 final px là
  nền nhìn qua quai ấm trà (zoom khay cho thấy quai ấm còn nguyên, lòng
  quai trong suốt đúng). Không có đạo cụ trắng khép kín nào ≥100 final
  px bị xóa mù: highlight ấm trà/tách chỉ 23–35 final px mỗi mảnh và
  được giữ nguyên.
- Zoom 4×: ấm trà bạc còn nguyên vòi + quai + núm nắp, tách trà còn
  nguyên, khay bạc còn nguyên (xem `zoom-quangiadao-f0-tray.png`,
  `zoom-quangiadao-char-tray.png`); sơ mi xám + nơ đen còn nguyên,
  không lỗ magenta (xem `zoom-quangiadao-char-shirt.png`); quạt xếp
  còn nguyên nan + họa tiết hoa ở f2/f5 bản gen lại, túi xách chần bông
  còn nguyên ở f5, mũ rộng vành còn nguyên vành + nơ (xem
  `zoom-chubietthudao-regen-f2.png`, `zoom-chubietthudao-regen-f5.png`).

## Hạn chế còn lại

- Chỉ mặt trước (front view, thực tế gen ra dạng 3/4) — giống các vòng
  trước, chưa có mặt sau/mặt nghiêng.
- f5 của cả hai gần như tư thế đứng (chân khép) — chấp nhận được như các
  vòng trước, chu kỳ vẫn lặp mượt; f5 ≈ tư thế khép về đầu chu kỳ.
- f2/f3/f4 của cả hai là 3 tư thế "chân bắt chéo/khép" khá gần nhau (khác
  nhau ở chân nào trước), không tách bạch bằng f0/f4 dang rộng — vẫn đủ
  phân biệt khi chạy.
- **Bản gen lại Chủ Biệt Thự Đảo thiếu túi xách ở f2** (tay trái buông
  trống, đã zoom xác nhận) — đánh đổi khi siết quạt ở lần gen lại. Túi
  nhỏ, thấp, ở 1 frame giữa chu kỳ nên khi chạy ở kích thước sprite chỉ
  là 1 nhịp chớp nhẹ; chấp nhận, không gen lại lần 3. Vòng sau: siết cả
  2 đạo cụ cùng lúc trong prompt gen lại ("fan in ALL six figures AND
  handbag in ALL six figures").
- Quạt/túi/khay đổi tay qua các frame theo nhịp đung đưa — giống các
  vòng trước, không phải lỗi, là tay đung đưa ngược pha chân.
- f0 Quản Gia Đảo mất vệt bóng đổ mặt đất tách rời (bị loại bởi
  `MIN_FIG_H` mới) trong khi các frame khác vẫn giữ bóng đổ dính chân —
  không nhất quán nhẹ về bóng, ở kích thước sprite không đáng kể.
- Ngưỡng xóa trắng kín (100 final px) chỉ đúng khi NPC không mặc đồ
  trắng — NPC nào có áo sơ mi trắng / đồ trắng thì KHÔNG được dùng bước
  này (sẽ thủng áo); ghi lại để vòng sau lưu ý. Vòng này cả hai NPC đều
  mặc đồ màu nhạt (xám nhạt / hồng đào nhạt) nên an toàn — nhưng lưu ý:
  highlight ấm trà/tách của Quản Gia Đảo là vùng trắng kín THẬT (23–35
  final px mỗi mảnh) và đã được giữ lại nhờ ngưỡng 100; NPC nào cầm đồ
  trắng/bạc mà vùng highlight khép kín ≥100 final px thì bước xóa sẽ
  thủng đồ — kiểm tra debug-white sau mỗi vòng.
- Tham chiếu `char_cotu.png` là nhân vật NỮ — NPC nam gen từ tham chiếu
  này dễ bị vẽ thành nữ (vòng 35 gặp đúng lỗi đó). Vòng này prompt siết
  giới tính ngay từ đầu đã tránh được lỗi — vòng sau có NPC nam: dùng
  luôn câu siết "MAN, masculine face, short black hair, no earrings, no
  bun, no long hair" trong prompt ảnh đứng (xem mục Prompt ở trên).
- Không sửa code, không export, không push trong vòng này (theo task);
  code + test + import Godot do agent khác làm.

> **Đính chính sau art (vòng 36, lúc nối code):** file Quản Gia Đảo lúc gen dùng stem `quanggiadao` (thừa 1 chữ g — "Quản Gia" không dấu là `quan-gia`, khớp NPC id `quan-gia-dao`), đã đổi tên thành `quangiadao` cho khớp quy tắc test (tiền tố frame = NPC id bỏ dấu gạch nối). Nội dung ảnh không đổi; `marker.gd` + note đã cập nhật theo tên mới.
