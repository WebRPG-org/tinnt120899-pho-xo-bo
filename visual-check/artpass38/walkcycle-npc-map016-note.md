# Artpass 38 — Walk-cycle NPC Map016 (Nhân Viên Sân Golf + Quản Lý Resort)

Ngày: 25/11/2026. Quy trình vòng 18/22/25/26/27/28/29/30/31/32/33/34/35/36/37:
ảnh đứng → trắng thành trong suốt (flood fill từ biên qua pixel trắng
min(R,G,B)≥235, feather r=1.5) → resize cao 208px → sheet 6 khung →
kiểm tra bằng mắt → cắt frame bằng script slice (cắt frame ngay trong
vòng này, như vòng 26–37) → cleanup mảnh vụn rời (mới vòng này, xem dưới).

Vị trí Map016 (Khu Sân Golf & Resort): Nhân Viên Sân Golf ở ô (3,3);
Quản Lý Resort ở ô (8,6). Dữ liệu thật trong `src/godot/data/maps.json`
(map id 16, events kind npc).

## Nhân vật

- **Nhân Viên Sân Golf** — nam người Việt, nhân viên sân golf: áo polo
  XANH NHẠT (KHÔNG áo trắng — để bước xóa trắng kín không thủng áo),
  quần kaki be, giày thể thao trắng, đội mũ lưỡi trai xanh navy, cầm
  GẬY GOLF + đeo TÚI GẬY GOLF mini trên vai. Ảnh đứng:
  `src/godot/art/char_nhanviensangolf.png` (97×208, RGBA). ID NPC
  `nhan-vien-san-golf` → frame dùng tiền tố `walk_nhanviensangolf_`
  (bỏ dấu gạch nối, theo quy tắc test).
- **Quản Lý Resort** — nữ người Việt, quản lý resort: blazer XANH MINT
  NHẠT + váy bút chì xanh navy (KHÔNG đồ trắng/kem), giày cao gót đen,
  cầm SỔ ĐẶT PHÒNG bìa da nâu + THẺ PHÒNG VÀNG. Ảnh đứng:
  `src/godot/art/char_quanlyresort.png` (89×208, RGBA). ID NPC
  `quan-ly-resort` → frame dùng tiền tố `walk_quanlyresort_`.

Tham chiếu phong cách: `src/godot/art/char_cotu.png` (112×208, RGBA).

## Prompt đã dùng

Ảnh đứng (mỗi người gen 1 lần, tham chiếu `char_cotu.png`):

> "Use this chibi character style as the exact reference. Create a single
> full-body chibi figure, front view, [mô tả nhân vật], same smiling face,
> same hand-drawn watercolor/gouache chibi style as the reference, full body
> visible head to shoes, no cropping, plain white background, no text, no
> background objects."

- Nhân Viên Sân Golf (SIẾT GIỚI TÍNH NGAY TỪ ĐẦU — bài học vòng 35/36/37,
  vì tham chiếu `char_cotu.png` là nữ): "Use this chibi character style
  as the exact reference for the watercolor/gouache style only. Create a
  single full-body chibi figure, front view, an adult Vietnamese MAN,
  masculine face, short black hair neatly combed to the side, no
  earrings, no bun, no long hair, wearing a light blue polo shirt (NOT a
  white shirt), beige khaki trousers, white sneakers, a navy blue
  baseball cap, holding a golf club in one hand and carrying a small mini
  golf bag on the shoulder, same smiling face, same hand-drawn
  watercolor/gouache chibi style as the reference, full body visible head
  to shoes, no cropping, plain white background, no text, no background
  objects."
- Quản Lý Resort: "an elegant Vietnamese woman, resort manager, black
  hair tied in a neat bun, wearing a light mint green blazer (NOT a white
  or cream outfit), a navy blue pencil skirt, black high heels, holding a
  brown leather reservation book and a golden room keycard"

Walk-cycle sheet (tham chiếu ảnh đứng vừa tạo; prompt vòng 26–37 +
mô tả 6 pha chân khác nhau rõ rệt + SIẾT CẢ 2 ĐẠO CỤ CÙNG LÚC ngay
từ lần gen đầu — bài học vòng 36/37):

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
> six figures — never omit either prop from any figure."
>
> - Nhân Viên Sân Golf: "same light blue polo shirt, same beige khaki
>   trousers, same white sneakers, same navy blue baseball cap, same golf
>   club and same mini golf bag on the shoulder" — "the golf club MUST be
>   clearly visible in ALL six figures AND the mini golf bag MUST be
>   clearly visible in ALL six figures"
> - Quản Lý Resort: "same light mint green blazer, same navy blue pencil
>   skirt, same black high heels, same brown leather reservation book and
>   same golden room keycard" — "the brown leather reservation book MUST be
>   clearly visible in ALL six figures AND the golden room keycard MUST be
>   clearly visible in ALL six figures"

Số lần gen lại: **ảnh đứng 0 lần; sheet Quản Lý Resort 0 lần; sheet
Nhân Viên Sân Golf 1 lần (v1 → v2).** Cả 2 ảnh đứng + sheet Quản Lý
Resort đều đạt ngay lần đầu. Sheet golf v1 bị lỗi đạo cụ chéo hình
(xem dưới) nên gen lại v2 với prompt siết thêm — v2 đạt ngay.

## Lỗi sheet golf v1 (đã loại, giữ bản thô làm hồ sơ)

Sheet v1 (2736×912): gậy golf cầm tay phải nhưng chéo sang trái, đầu
gậy của hình sau nằm bên trái đường cắt cột nên bị gán nhầm sang hình
trước; ngoài ra generator vẽ thêm một dải dây đen nối tay trái hình
này sang tay phải hình kế. Kết quả sau khi cắt: f0 nguyên vẹn; f1 có
2 đầu gậy (1 đầu lạ ở góc dưới-phải); f2 gậy đứt (cán cụt ở mép trái +
đầu gậy rời ở góc dưới-phải); f3 gậy mất đầu (chỉ còn cán cụt ở mép
trái); f4/f5 nguyên vẹn. Xem `diag-clubs-f1f2.png`,
`diag-clubs-f3f4.png`, `zoom-nhanviensangolf-f1/f2/f3.png` (bản v1) và
bản thô `rejected-walkcycle-sheet-nhanviensangolf-v1.png` /
`rejected-media-generation-walkcycle-sheet-nhanviensangolf-v1.webp`.

Prompt v2 siết thêm (đã phát huy): "The golf club is held VERTICALLY
close to the body with its head down near the feet, never angled
sideways across the body. Each figure is fully separate: clear white
space between neighbouring figures, no strap, cord, club or any object
touching or crossing into the next figure." — v2 (2240×1120): gậy dựng
đứng sát thân, đầu gậy gần bàn chân, không còn dây nối, không còn đầu
gậy chéo hình. Bài học cho vòng sau: NPC cầm đạo cụ DÀI (gậy, ô, cần
câu...) thì siết ngay từ lần gen đầu là "đạo cụ dựng đứng sát thân,
không chéo sang hình kế" — lỗi chéo hình không sửa được bằng cắt cột.

## File

| File | Kích thước |
| --- | --- |
| `src/godot/art/char_nhanviensangolf.png` | 97×208 RGBA, 44.796 byte |
| `src/godot/art/char_quanlyresort.png` | 89×208 RGBA, 38.527 byte |
| `src/godot/art/walk_nhanviensangolf_f0.png` … `walk_nhanviensangolf_f5.png` | 105×208 RGBA (canvas chung), 40.121–44.205 byte |
| `src/godot/art/walk_quanlyresort_f0.png` … `walk_quanlyresort_f5.png` | 120×208 RGBA (canvas chung), 37.326–42.941 byte |
| `visual-check/artpass38/walkcycle-sheet-nhanviensangolf.png` | 2240×1120 RGB (v2) |
| `visual-check/artpass38/walkcycle-sheet-quanlyresort.png` | 2736×912 RGB |
| `visual-check/artpass38/rejected-walkcycle-sheet-nhanviensangolf-v1.png` | 2736×912 RGB (v1 lỗi, giữ làm hồ sơ) |

Bản thô gen ra còn lưu trong `visual-check/artpass38/` với tên
`media-generation-char-*.webp` /
`media-generation-walkcycle-sheet-*.webp` (pipeline media vòng này trả
về `.webp`, như vòng 29–37; sheet `.webp` đã chuyển sang `.png` cùng
tên trước khi cắt frame). Tên file thô của sheet Nhân Viên Sân Golf bị
pipeline cắt ngắn stem thành
`media-generation-walkcycle-sheet-nhanviensangol-0-…webp` (thiếu chữ
`f` cuối, giống vòng 37) — đã đổi tên về dạng chuẩn khi chuyển sang
`.png` (`walkcycle-sheet-nhanviensangolf.png`); bản thô giữ nguyên tên
pipeline trả về làm hồ sơ.
Script xử lý ảnh đứng: `visual-check/artpass38/process_standing_map016.py`
(adapt từ `process_standing_map015.py`, chỉ đổi tên thư mục + tên NPC).
Script cắt frame: `visual-check/artpass38/slice_walkcycle_npc_map016.py`
(adapt từ `slice_walkcycle_npc_map015.py`, giữ nguyên `MIN_FIG_W`=100,
`MIN_FIG_H`=100, `MAX_FIG_W`=600 + bước xóa vùng trắng kín ≥100 final
px — không cần sửa gì thêm vòng này).
Script kiểm tra debug: `visual-check/artpass38/debug_white_r38.py`
(tô đỏ vùng trắng kín đã xóa + đo vùng trắng kín còn lại lớn nhất
trong file đích).
Script cleanup mới vòng này: `visual-check/artpass38/cleanup_frames_r38.py`
(xóa mảnh vụn rời ở mép frame sau khi cắt — xem dưới).
Dải kiểm tra nền magenta: `walkcycle-check-magenta-{nhanviensangolf,quanlyresort}.png`
(được tạo lại từ file đích CUỐI sau bước cleanup),
`char-{nhanviensangolf,quanlyresort}-magenta.png`.
Debug vùng trắng kín: `debug-white-walk_nhanviensangolf_f{0..5}.png`
(vùng trắng kín đã xóa tô đỏ), `debug-white-walk_quanlyresort_f{0,5}.png`,
`zoom-nhanviensangolf-char-props.png`,
`zoom-quanlyresort-char-props.png`,
`zoom{2,3,4}-nhanviensangolf-f{0..5}.png` (phóng to 3× trên nền đen
từng frame golf v2 trước/sau cleanup),
`zoom-quanlyresort-f{0,2,5}.png`.

## Sửa script so với vòng 37

- **Slice script: không sửa gì.** Sheet v2 vẫn cần `split_wide_component`:
  f1+f2 dính nhau thành 1 component (436–1152, cắt ở x=801) và f2+f3
  dính nhau (1127–1828, cắt ở x=1471) do túi gậy/mũ/cánh tay chạm nhau
  theo trục x; cột cắt có mật độ cao (235/238 px) nhưng cắt đúng khe
  giữa 2 hình — đã kiểm tra bằng mắt từng frame sau khi cắt, không
  hình nào bị cắt xuyên thân.
- **Cleanup mới (`cleanup_frames_r38.py`):** sau khi cắt, f1–f4 của
  golf còn dính mảnh vụn RỜI của hình kế ở mép canvas (f1: mũi giày
  hình kế ở mép phải 25px; f2: mẩu vành mũ/túi ở mép trái 27px; f3:
  mũi giày hình kế ở mép phải 72px; f4: mẩu vành mũ ở mép trái 29px).
  Nhân vật (thân + gậy + túi) là 1 khối liên thông duy nhất; mảnh vụn
  là component rời nên script giữ component lớn nhất + mọi component
  ≥5% diện tích của nó, xóa phần còn lại + quầng feather (alpha≤128)
  giãn 2px quanh mảnh đã xóa (lần chạy đầu chưa xóa quầng nên f3 còn
  vệt mờ ở góc dưới-phải — đã sửa script, cắt lại từ sheet rồi chạy
  lại cleanup, vệt mờ hết). Resort + ảnh đứng đều 1 component nên
  không đổi gì. LƯU Ý: phải cắt lại từ sheet trước khi chạy cleanup
  bản đã sửa quầng, vì cleanup lần đầu đã xóa mất mảnh gốc nên chạy
  lại không tìm được component để tính quầng.
- Ảnh đứng cả hai không có vùng trắng kín ≥100 final px nào bị xóa
  (không in dòng "removed enclosed white" khi chạy process) — polo
  xanh nhạt + blazer mint đều an toàn.

## Godot import

- **Không chạy trong vòng này (theo task: KHÔNG sửa code/test).**
  File `.import` cho 14 file art mới (2 char + 12 walk frame) do agent
  khác chạy import sau, như vòng 34/35/36/37 đã làm
  (`tools/godot/Godot_v4.7.2-stable_linux.x86_64 --headless --import`).

## Kết quả kiểm tra bằng mắt

- **Ảnh đứng Nhân Viên Sân Golf — ĐẠT, không cần gen lại.** Nam rõ ràng
  ngay lần đầu nhờ prompt siết giới tính: mặt nam (có râu quai nón
  mờ), tóc đen ngắn dưới mũ lưỡi trai xanh navy, không bông tai, không
  búi. Áo polo xanh nhạt có túi + cúc, quần kaki be, giày thể thao
  trắng, tay phải cầm gậy golf (đầu gậy chạm đất), tay trái nắm dây
  đeo túi gậy mini xanh navy trên vai (3 gậy thò ra khỏi túi), nụ cười
  thân thiện, toàn thân đủ, nền trắng trơn, không chữ.
- **Ảnh đứng Quản Lý Resort — ĐẠT, không cần gen lại.** Nữ thanh lịch,
  tóc đen búi gọn, khuyên tai vàng, blazer xanh mint nhạt (cúc vàng,
  túi ngực), áo sơ mi mint cùng tông, váy bút chì xanh navy, giày cao
  gót đen, tay phải cầm sổ đặt phòng bìa da nâu có quai cài, tay trái
  giơ thẻ phòng vàng có hình chìa khóa, nụ cười thân thiện, toàn thân
  đủ, nền trắng trơn, không chữ. (Chi tiết nhỏ: thẻ vàng có chữ nhỏ
  mờ không đọc được — ở kích thước sprite không nhìn thấy, chấp nhận
  được như vòng 37.)
- **Sheet Nhân Viên Sân Golf v2 — ĐẠT, không cần gen lại thêm.** Đúng 6
  nhân vật, 1 hàng ngang cách đều, nền trắng trơn (góc 254,254,254),
  không chữ. Cùng mặt, mũ navy + polo xanh nhạt + quần kaki be +
  giày trắng, gậy golf dựng đứng + túi gậy mini ở cả 6 hình. Chân
  tiến triển rõ (dang rộng → khép/bắt chéo → bắt chéo → khép → dang
  rộng ngược → khép về tư thế đầu), tay đung đưa ngược pha chân, tay
  trái nắm dây túi theo nhịp đi. Toàn thân đủ, không cắt tay/chân.
- **Sheet Quản Lý Resort — ĐẠT, không cần gen lại.** Đúng 6 nhân vật,
  1 hàng ngang cách đều, nền trắng trơn (góc 249,248,255), không chữ.
  Cùng mặt, tóc búi + blazer mint + váy navy + cao gót đen, sổ nâu +
  thẻ vàng ở cả 6 hình (thẻ đổi tay theo nhịp đi ở f0/f2/f5 — giống
  clipboard vòng 37, không phải lỗi). Chân tiến triển rõ (dang rộng →
  khép/bắt chéo → bắt chéo → khép → dang rộng ngược → khép về tư thế
  đầu), tay đung đưa ngược pha chân. Toàn thân đủ, không cắt tay/chân.
- Ảnh đứng + frame đã kiểm tra trên nền magenta sau khi xử lý trong
  suốt: không quầng trắng, toàn thân nguyên vẹn, frame không lệch khỏi
  tâm canvas. Đo bằng script trên file đích: vùng trắng kín còn lại
  lớn nhất chỉ 36px (ảnh đứng nhanviensangolf, mũi giày trắng), 33px
  (frame golf), 4px (ảnh đứng quanlyresort), 4–7px (frame resort) —
  đều <100 final px nên được giữ đúng thiết kế. Các vùng trắng kín
  ≥100 final px đã xóa đều là NỀN nhìn xuyên qua, đã đối chiếu
  debug-white: golf f0 xóa 228, f1 xóa 506, f3 xóa 484, f4 xóa 227
  final px — vùng đỏ nằm đúng trong tam giác giữa 2 chân khi sải
  rộng / khe tay–thân (xem `debug-white-walk_nhanviensangolf_f1.png`
  và `debug-white-walk_nhanviensangolf_f3.png`); resort không có vùng
  nào bị xóa. Không có đạo cụ trắng khép kín nào ≥100 final px bị xóa
  mù.
- Zoom 4×/3×: túi gậy còn nguyên 3 gậy + quai đeo + túi phụ
  (xem `zoom-nhanviensangolf-char-props.png`); sổ nâu còn nguyên quai
  cài + thẻ vàng còn nguyên hình chìa khóa
  (xem `zoom-quanlyresort-char-props.png`); từng frame golf v2 sau
  cleanup không còn mảnh vụn mép (xem `zoom4-nhanviensangolf-f{1..4}.png`).
- Resort f0/f2/f5 zoom 3×: sổ + thẻ còn nguyên, không mảnh vụn
  (xem `zoom-quanlyresort-f{0,2,5}.png`).

## Hạn chế còn lại

- Chỉ mặt trước (front view, thực tế gen ra dạng 3/4) — giống các vòng
  trước, chưa có mặt sau/mặt nghiêng.
- f5 của cả hai gần như tư thế đứng (chân khép) — chấp nhận được như các
  vòng trước, chu kỳ vẫn lặp mượt; f5 ≈ tư thế khép về đầu chu kỳ.
- f2/f3/f4 của cả hai là 3 tư thế "chân bắt chéo/khép" khá gần nhau (khác
  nhau ở chân nào trước), không tách bạch bằng f0/f4 dang rộng — vẫn đủ
  phân biệt khi chạy. Với Quản Lý Resort, váy bút chì ôm càng che chân
  hơn (chỉ thấy bàn chân/giày đổi vị trí) — chấp nhận, vì váy ôm là
  đặc tính trang phục.
- Thẻ phòng vàng của Quản Lý Resort có chữ nhỏ mờ không đọc được — ở
  kích thước sprite không nhìn thấy, chấp nhận như vòng 37.
- Ngưỡng xóa trắng kín (100 final px) chỉ đúng khi NPC không mặc đồ
  trắng — NPC nào có áo sơ mi trắng / đồ trắng thì KHÔNG được dùng bước
  này (sẽ thủng áo). Vòng này cả hai NPC đều mặc đồ màu (xanh nhạt /
  mint) nên an toàn. Giày thể thao trắng của Nhân Viên Sân Golf chỉ để
  lại vùng trắng kín lớn nhất 36 final px (<100) nên được giữ nguyên.
- Sheet các vòng sau: NPC cầm đạo cụ dài phải siết "dựng đứng sát thân"
  ngay từ lần gen đầu (xem lỗi v1 ở trên); các hình trong sheet vẫn có
  thể chạm nhau 2D qua túi/mũ nên bước cleanup mảnh vụn rời
  (`cleanup_frames_r38.py`) nên chạy mặc định sau mỗi lần cắt frame.
- Không sửa code, không export, không push trong vòng này (theo task);
  code + test + import Godot do agent khác làm.
