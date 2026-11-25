# Artpass 37 — Walk-cycle NPC Map015 (Quản Lý Penthouse + Cư Dân Penthouse)

Ngày: 25/11/2026. Quy trình vòng 18/22/25/26/27/28/29/30/31/32/33/34/35/36:
ảnh đứng → trắng thành trong suốt (flood fill từ biên qua pixel trắng
min(R,G,B)≥235, feather r=1.5) → resize cao 208px → sheet 6 khung →
kiểm tra bằng mắt → cắt frame bằng script slice (cắt frame ngay trong
vòng này, như vòng 26–36).

Vị trí Map015 (Khu Penthouse): Quản Lý Penthouse ở ô (3,3); Cư Dân
Penthouse ở ô (8,6). Dữ liệu thật trong `src/godot/data/maps.json`
(map id 15, events kind npc).

## Nhân vật

- **Quản Lý Penthouse** — nam người Việt, quản lý penthouse: vest xám
  than, ÁO SƠ MI XANH NHẠT (KHÔNG áo trắng — để bước xóa trắng kín
  không thủng áo), cà vạt đỏ bordeaux, quần âu tối, giày da đen, cầm
  clipboard + thẻ chìa khóa vàng. Ảnh đứng:
  `src/godot/art/char_quanlypenthouse.png` (102×208, RGBA). ID NPC
  `quan-ly-penthouse` → frame dùng tiền tố `walk_quanlypenthouse_`
  (bỏ dấu gạch nối, theo quy tắc test).
- **Cư Dân Penthouse** — nữ người Việt, cư dân penthouse sang trọng:
  váy dài màu xanh ngọc lục bảo thanh lịch (kiểu áo dài, cổ trụ, khuy
  bấm, thêu hoa vàng), cầm túi mua sắm hàng hiệu + điện thoại thông
  minh. Ảnh đứng: `src/godot/art/char_cudanpenthouse.png` (106×208,
  RGBA). ID NPC `cu-dan-penthouse` → frame dùng tiền tố
  `walk_cudanpenthouse_`.

Tham chiếu phong cách: `src/godot/art/char_cotu.png` (112×208, RGBA).

## Prompt đã dùng

Ảnh đứng (mỗi người gen 1 lần, tham chiếu `char_cotu.png`):

> "Use this chibi character style as the exact reference. Create a single
> full-body chibi figure, front view, [mô tả nhân vật], same smiling face,
> same hand-drawn watercolor/gouache chibi style as the reference, full body
> visible head to shoes, no cropping, plain white background, no text, no
> background objects."

- Quản Lý Penthouse (SIẾT GIỚI TÍNH NGAY TỪ ĐẦU — bài học vòng 35/36,
  vì tham chiếu `char_cotu.png` là nữ): "Use this chibi character style
  as the exact reference for the watercolor/gouache style only. Create a
  single full-body chibi figure, front view, an adult Vietnamese MAN,
  masculine face, short black hair neatly combed to the side, no
  earrings, no bun, no long hair, wearing a dark charcoal grey suit vest
  and trousers, light blue dress shirt (NOT a white shirt), burgundy red
  tie, black leather shoes, holding a clipboard and a golden keycard,
  same smiling face, same hand-drawn watercolor/gouache chibi style as
  the reference, full body visible head to shoes, no cropping, plain
  white background, no text, no background objects."
- Cư Dân Penthouse: "an elegant wealthy Vietnamese woman, resident of a
  luxury penthouse, wearing a long elegant emerald green dress, holding a
  luxury shopping bag and a smartphone"

Walk-cycle sheet (tham chiếu ảnh đứng vừa tạo; prompt vòng 26–36 +
mô tả 6 pha chân khác nhau rõ rệt + SIẾT CẢ 2 ĐẠO CỤ CÙNG LÚC ngay
từ lần gen đầu — bài học vòng 36):

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
> - Quản Lý Penthouse: "same dark charcoal grey suit vest and trousers,
>   same light blue dress shirt, same burgundy red tie, same black leather
>   shoes, same clipboard and same golden keycard" — "the clipboard MUST be
>   clearly visible in ALL six figures AND the golden keycard MUST be
>   clearly visible in ALL six figures"
> - Cư Dân Penthouse: "same long elegant emerald green dress, same luxury
>   shopping bag and same smartphone" — "the shopping bag MUST be clearly
>   visible in ALL six figures AND the smartphone MUST be clearly visible
>   in ALL six figures"

Số lần gen lại: **0 lần.** Cả 2 ảnh đứng + cả 2 sheet đều đạt ngay lần
đầu, không cần resume snapshot. Siết cả 2 đạo cụ cùng lúc ngay từ lần
gen đầu đã phát huy tác dụng: clipboard + thẻ vàng đủ 6/6 hình, túi
mua sắm + điện thoại đủ 6/6 hình — không tái phạm lỗi thiếu đạo cụ
vòng 36. Prompt siết giới tính của Quản Lý Penthouse cũng phát huy:
gen ra nam ngay lần đầu.

## File

| File | Kích thước |
| --- | --- |
| `src/godot/art/char_quanlypenthouse.png` | 102×208 RGBA, 41.269 byte |
| `src/godot/art/char_cudanpenthouse.png` | 106×208 RGBA, 44.288 byte |
| `src/godot/art/walk_quanlypenthouse_f0.png` … `walk_quanlypenthouse_f5.png` | 122×208 RGBA (canvas chung), 39.656–45.101 byte |
| `src/godot/art/walk_cudanpenthouse_f0.png` … `walk_cudanpenthouse_f5.png` | 142×208 RGBA (canvas chung), 45.718–51.500 byte |
| `visual-check/artpass37/walkcycle-sheet-quanlypenthouse.png` | 2736×912 RGB, 2.123.097 byte |
| `visual-check/artpass37/walkcycle-sheet-cudanpenthouse.png` | 2736×912 RGB, 2.514.908 byte |

Bản thô gen ra còn lưu trong `visual-check/artpass37/` với tên
`media-generation-char-*.webp` /
`media-generation-walkcycle-sheet-*.webp` (pipeline media vòng này trả
về `.webp`, như vòng 29–36; sheet `.webp` đã chuyển sang `.png` cùng
tên trước khi cắt frame). Tên file thô của sheet Quản Lý Penthouse bị
pipeline cắt ngắn stem thành
`media-generation-walkcycle-sheet-quanlypenthous-0-6f2d06b0-…webp`
(thiếu chữ `e` cuối) — đã đổi tên về dạng chuẩn khi chuyển sang `.png`
(`walkcycle-sheet-quanlypenthouse.png`) để khớp tên đích; bản thô giữ
nguyên tên pipeline trả về làm hồ sơ. Không có bản `rejected-` nào
vòng này (0 lần gen lại).
Script xử lý ảnh đứng: `visual-check/artpass37/process_standing_map015.py`
(adapt từ `process_standing_map014.py`, chỉ đổi tên thư mục + tên NPC).
Script cắt frame: `visual-check/artpass37/slice_walkcycle_npc_map015.py`
(adapt từ `slice_walkcycle_npc_map014.py`, giữ nguyên `MIN_FIG_W`=100,
`MIN_FIG_H`=100, `MAX_FIG_W`=600 + bước xóa vùng trắng kín ≥100 final
px — không cần sửa gì thêm vòng này).
Script kiểm tra debug: `visual-check/artpass37/debug_white_r37.py`
(tô đỏ vùng trắng kín đã xóa + đo vùng trắng kín còn lại lớn nhất
trong file đích).
Dải kiểm tra nền magenta: `walkcycle-check-magenta-{quanlypenthouse,cudanpenthouse}.png`,
`char-{quanlypenthouse,cudanpenthouse}-magenta.png`.
Debug vùng trắng kín: `debug-white-walk_cudanpenthouse_f{0..5}.png`
(vùng trắng kín đã xóa tô đỏ), `zoom-quanlypenthouse-char-props.png`,
`zoom-cudanpenthouse-char-props.png`, `zoom-cudanpenthouse-f4.png`
(phóng to trên nền magenta / từ dải kiểm tra).

Lưu ý: `visual-check/artpass37/check_r37.py` là script kiểm tra trong
game (Playwright, Map001→Map015) do agent khác tạo song song trong cùng
thư mục — không thuộc artpass này, không sửa.

## Sửa script so với vòng 36

- **Không sửa gì.** Slice script vòng 36 chạy thẳng: cả 2 sheet đều
  đúng 6 component, không cần `split_wide_component` (bbox các hình
  Cư Dân Penthouse chồng lấn nhau theo trục x do túi mua sắm vươn
  sang — f0 x21–523, f1 x485–924 — nhưng component vẫn tách rời trong
  2D nên `find_figures` đếm đúng 6, không cắt vào nhân vật).
- Ảnh đứng cả hai không có vùng trắng kín ≥100 final px nào bị xóa
  (không in dòng "removed enclosed white" khi chạy process) — sơ mi
  xanh nhạt + váy xanh ngọc đều an toàn.

## Godot import

- **Không chạy trong vòng này (theo task: KHÔNG sửa code/test).**
  File `.import` cho 14 file art mới (2 char + 12 walk frame) do agent
  khác chạy import sau, như vòng 34/35/36 đã làm
  (`tools/godot/Godot_v4.7.2-stable_linux.x86_64 --headless --import`).

## Kết quả kiểm tra bằng mắt

- **Ảnh đứng Quản Lý Penthouse — ĐẠT, không cần gen lại.** Nam rõ ràng
  ngay lần đầu nhờ prompt siết giới tính: mặt nam, tóc đen ngắn chải
  lệch sang một bên, không bông tai, không búi. Vest xám than có cúc +
  túi, sơ mi xanh nhạt, cà vạt đỏ bordeaux, quần âu tối, giày da đen
  bóng, tay phải cầm clipboard nâu có kẹp + giấy, tay trái giơ thẻ
  chìa khóa vàng có chip, nụ cười thân thiện, toàn thân đủ, nền trắng
  trơn, không chữ.
- **Ảnh đứng Cư Dân Penthouse — ĐẠT, không cần gen lại.** Nữ quý phái,
  tóc đen búi gọn, khuyên tai vàng, váy dài xanh ngọc lục bảo kiểu áo
  dài (cổ trụ, khuy bấm, thêu hoa vàng), tay phải xách túi mua sắm
  hàng hiệu màu be/kem có quai vàng, tay trái cầm điện thoại thông
  minh đen, dép quai nâu, nụ cười thân thiện, toàn thân đủ, nền trắng
  trơn. (Chi tiết nhỏ: túi mua sắm có logo mờ + dòng chữ nhỏ không
  đọc được — ở kích thước sprite không nhìn thấy, chấp nhận được;
  nhân vật đi dép quai thay vì giày — task không quy định giày, chấp
  nhận được như vòng 36.)
- **Sheet Quản Lý Penthouse — ĐẠT, không cần gen lại.** Đúng 6 nhân
  vật, 1 hàng ngang cách đều, nền trắng trơn (góc 255,255,255), không
  chữ. Cùng mặt, tóc, vest xám than + sơ mi xanh nhạt + cà vạt đỏ +
  quần âu tối + giày da đen, clipboard + thẻ vàng ở cả 6 hình. Chân
  tiến triển rõ (dang rộng → khép/bắt chéo → bắt chéo → khép → dang
  rộng ngược → khép về tư thế đầu), tay đung đưa ngược pha chân,
  clipboard đổi tay theo nhịp đi ở f3/f4 (sang tay trái — giống laptop/
  tablet vòng 32, sổ tay vòng 31, quạt/túi vòng 36, không phải lỗi).
  Toàn thân đủ, không cắt tay/chân.
- **Sheet Cư Dân Penthouse — ĐẠT, không cần gen lại.** Đúng 6 nhân
  vật, 1 hàng ngang cách đều, nền trắng trơn (góc 253,253,253), không
  chữ. Cùng mặt, tóc búi + váy xanh ngọc + dép quai, túi mua sắm +
  điện thoại ở cả 6 hình. Chân tiến triển rõ (dang rộng → khép/bắt
  chéo → bắt chéo → khép → dang rộng ngược → khép về tư thế đầu), tay
  đung đưa ngược pha chân. Toàn thân đủ, không cắt tay/chân.
- Ảnh đứng + frame đã kiểm tra trên nền magenta sau khi xử lý trong
  suốt: không quầng trắng, toàn thân nguyên vẹn, frame không lệch khỏi
  tâm canvas. Đo bằng script trên file đích: vùng trắng kín còn lại
  lớn nhất chỉ 48px (ảnh đứng cudanpenthouse, nếp váy), 31–34px (frame
  cudanpenthouse), 2px (ảnh đứng quanlypenthouse), 4–6px (frame
  quanlypenthouse) — đều <100 final px nên được giữ đúng thiết kế.
  Các vùng trắng kín ≥100 final px đã xóa đều là NỀN nhìn xuyên qua,
  đã đối chiếu debug-white: Cư Dân Penthouse f0–f5 xóa nền nhìn qua
  khe xẻ tà váy / giữa 2 chân dưới váy và khe tay–thân (f0: 335, f1:
  193+232, f2: 241+103, f3: 249+398, f4: 166, f5: 173 final px; xem
  `debug-white-walk_cudanpenthouse_f0.png` và
  `debug-white-walk_cudanpenthouse_f3.png` — vùng đỏ nằm đúng trong
  khe tà / giữa 2 chân, 2 tà váy còn nguyên); Quản Lý Penthouse không
  có vùng nào bị xóa. Không có đạo cụ trắng khép kín nào ≥100 final px
  bị xóa mù.
- Zoom 4×: clipboard còn nguyên kẹp + giấy, thẻ vàng còn nguyên chip
  (xem `zoom-quanlypenthouse-char-props.png`); sơ mi xanh nhạt + cà
  vạt đỏ còn nguyên, không lỗ magenta; túi mua sắm còn nguyên quai +
  thân túi, điện thoại còn nguyên (xem
  `zoom-cudanpenthouse-char-props.png`); f4 Cư Dân Penthouse tay trái
  duỗi cầm điện thoại, túi ở tay phải còn nguyên (xem
  `zoom-cudanpenthouse-f4.png`).

## Hạn chế còn lại

- Chỉ mặt trước (front view, thực tế gen ra dạng 3/4) — giống các vòng
  trước, chưa có mặt sau/mặt nghiêng.
- f5 của cả hai gần như tư thế đứng (chân khép) — chấp nhận được như các
  vòng trước, chu kỳ vẫn lặp mượt; f5 ≈ tư thế khép về đầu chu kỳ.
- f2/f3/f4 của cả hai là 3 tư thế "chân bắt chéo/khép" khá gần nhau (khác
  nhau ở chân nào trước), không tách bạch bằng f0/f4 dang rộng — vẫn đủ
  phân biệt khi chạy. Với Cư Dân Penthouse, chân dưới váy dài càng khó
  phân biệt hơn (chỉ thấy bàn chân/dép đổi vị trí) — chấp nhận, vì váy
  dài che chân là đặc tính trang phục.
- f4 Cư Dân Penthouse tay trái duỗi thẳng về trước cầm điện thoại (tư
  thế hơi cứng so với tay đung đưa tự nhiên) — chấp nhận, 1 frame giữa
  chu kỳ, ở kích thước sprite không đáng kể.
- Túi mua sắm của Cư Dân Penthouse có logo + chữ nhỏ mờ (xem Hạn chế ở
  mục ảnh đứng) — ở kích thước sprite không đọc được, chấp nhận.
- Cư Dân Penthouse đi dép quai thay vì giày — task không quy định giày,
  chấp nhận như vòng 36.
- Ngưỡng xóa trắng kín (100 final px) chỉ đúng khi NPC không mặc đồ
  trắng — NPC nào có áo sơ mi trắng / đồ trắng thì KHÔNG được dùng bước
  này (sẽ thủng áo). Vòng này cả hai NPC đều mặc đồ màu (xanh nhạt /
  xanh ngọc) nên an toàn.
- Không sửa code, không export, không push trong vòng này (theo task);
  code + test + import Godot do agent khác làm.
