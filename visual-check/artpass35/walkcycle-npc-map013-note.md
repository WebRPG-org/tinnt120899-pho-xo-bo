# Artpass 35 — Walk-cycle NPC Map013 (Nhân Viên Ngân Hàng + Môi Giới Chứng Khoán)

Ngày: 25/11/2026. Quy trình vòng 18/22/25/26/27/28/29/30/31/32/33/34: ảnh đứng →
trắng thành trong suốt (flood fill từ biên qua pixel trắng
min(R,G,B)≥235, feather r=1.5) → resize cao 208px → sheet 6 khung →
kiểm tra bằng mắt → cắt frame bằng script slice (cắt frame ngay trong
vòng này, như vòng 26/27/28/29/30/31/32/33/34).

Vị trí Map013 (Quận Tài Chính): Nhân Viên Ngân Hàng ở ô (3,3); Môi Giới
Chứng Khoán ở ô (8,6). Dữ liệu thật trong `src/godot/data/maps.json` (map
id 13, events kind npc).

## Nhân vật

- **Nhân Viên Ngân Hàng** — nam trẻ người Việt, nhân viên ngân hàng: vest
  xanh navy, ÁO SƠ MI XANH NHẠT (KHÔNG áo trắng — để bước xóa trắng kín
  không thủng áo), cà vạt đỏ đậm, quần âu tối, giày da đen, cầm một xấp
  giấy tờ ngân hàng / tablet nhỏ. Ảnh đứng:
  `src/godot/art/char_nhanviennganhang.png` (93×208, RGBA). ID NPC
  `nhan-vien-ngan-hang` → frame dùng tiền tố `walk_nhanviennganhang_` (bỏ
  dấu gạch nối, theo quy tắc test).
- **Môi Giới Chứng Khoán** — nam người Việt, môi giới chứng khoán: vest xám
  than, áo sơ mi xanh bạc hà nhạt, cà vạt tối, đeo kính, giày da đen, cầm
  điện thoại hiện biểu đồ chứng khoán + một tập hồ sơ. Ảnh đứng:
  `src/godot/art/char_moigioichungkhoan.png` (103×208, RGBA). ID NPC
  `moi-gioi-chung-khoan` → frame dùng tiền tố `walk_moigioichungkhoan_`.

Tham chiếu phong cách: `src/godot/art/char_cotu.png` (112×208, RGBA).

## Prompt đã dùng

Ảnh đứng (mỗi người gen 1 lần, tham chiếu `char_cotu.png`):

> "Use this chibi character style as the exact reference. Create a single
> full-body chibi figure, front view, [mô tả nhân vật], same smiling face,
> same hand-drawn watercolor/gouache chibi style as the reference, full body
> visible head to shoes, no cropping, plain white background, no text, no
> background objects."

- Nhân Viên Ngân Hàng: "a young Vietnamese male bank employee, navy blue
  suit jacket, light blue dress shirt (NOT a white shirt), dark red tie,
  dark dress trousers, black leather shoes, holding a small stack of bank
  documents and a small tablet"
- Môi Giới Chứng Khoán: "a Vietnamese male stock broker, charcoal grey suit
  jacket, light mint green dress shirt, dark tie, wearing glasses, black
  leather shoes, holding a smartphone showing a stock chart and a small
  folder of documents"

Walk-cycle sheet (tham chiếu ảnh đứng vừa tạo; prompt vòng 26/27/28/29/30/31/32/33/34 +
mô tả 6 pha chân khác nhau rõ rệt):

> "Use this chibi character as the exact reference. Create a sprite sheet
> of exactly six full-body figures in a single horizontal row, evenly
> spaced, same character, same [clothes], same [hair/glasses], walking poses
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
> - Nhân Viên Ngân Hàng: "same navy blue suit jacket, same light blue dress
>   shirt, same dark red tie, same dark dress trousers, same black leather
>   shoes, same tablet and stack of bank documents"
> - Môi Giới Chứng Khoán: "same charcoal grey suit jacket, same light mint
>   green dress shirt, same dark tie, same glasses, same black leather
>   shoes, same smartphone showing a stock chart and same folder of
>   documents"

Số lần gen lại: **1 lần duy nhất — ảnh đứng Nhân Viên Ngân Hàng** (xem dưới).
Cả 2 sheet walk-cycle + ảnh đứng Môi Giới đều đạt ngay lần đầu, không cần
resume snapshot.

### Gen lại ảnh đứng Nhân Viên Ngân Hàng (lần đầu HỎNG — sai giới tính)

Lần gen đầu (`rejected-female-char-nhanviennganhang-af4428f2.webp`,
292.932 byte) vẽ ra nhân vật NỮ rõ ràng: tóc dài búi sau, đeo bông tai
vàng, mặt nữ — dù prompt đã ghi "young Vietnamese male". Nguyên nhân:
ảnh tham chiếu `char_cotu.png` là nhân vật nữ, pipeline sao chép luôn
kiểu tóc/mặt nữ sang. Đây là lỗi "mặt sai" theo tiêu chí gen lại của các
vòng trước, nên gen lại 1 lần với prompt siết giới tính:

> "Use this chibi character style as the exact reference for the
> watercolor/gouache style only. Create a single full-body chibi figure,
> front view, a young adult Vietnamese MAN, masculine face, short black
> hair neatly combed to the side, no earrings, no bun, no long hair,
> wearing a navy blue suit jacket, light blue dress shirt (NOT a white
> shirt), dark red tie, dark dress trousers, black leather shoes, holding
> a small stack of bank documents and a small tablet, same smiling face,
> same hand-drawn watercolor/gouache chibi style as the reference, full
> body visible head to shoes, no cropping, plain white background, no
> text, no background objects."

Bản gen lại (`media-generation-char-nhanviennganhang-0-358ac0d3.webp`,
266.030 byte) ĐẠT ngay: nam rõ ràng, tóc ngắn chải lệch, không bông tai,
không búi. Bài học: NPC nam mà tham chiếu `char_cotu.png` (nữ) thì phải
ghi rõ "MAN, masculine face, short hair, no earrings, no bun" trong
prompt ảnh đứng — vòng sau có NPC nam thì dùng luôn câu siết này.

## File

| File | Kích thước |
| --- | --- |
| `src/godot/art/char_nhanviennganhang.png` | 93×208 RGBA, 40.803 byte |
| `src/godot/art/char_moigioichungkhoan.png` | 103×208 RGBA, 44.653 byte |
| `src/godot/art/walk_nhanviennganhang_f0.png` … `walk_nhanviennganhang_f5.png` | 153×208 RGBA (canvas chung), 40.606–52.929 byte |
| `src/godot/art/walk_moigioichungkhoan_f0.png` … `walk_moigioichungkhoan_f5.png` | 131×208 RGBA (canvas chung), 44.298–50.141 byte |
| `visual-check/artpass35/walkcycle-sheet-nhanviennganhang.png` | 2736×912 RGB, 1.999.559 byte |
| `visual-check/artpass35/walkcycle-sheet-moigioichungkhoan.png` | 2736×912 RGB, 2.286.914 byte |

Bản thô gen ra còn lưu trong `visual-check/artpass35/` với tên
`media-generation-char-*.webp` / `media-generation-walkcycle-sheet-*.webp`
(pipeline media vòng này trả về `.webp`, như vòng 29/30/31/32/33/34; sheet
`.webp` đã chuyển sang `.png` cùng tên trước khi cắt frame). Tên file thô
do pipeline trả về có tiền tố dài `media-generation-media-generation-…`
và bị cắt ngắn tên stem — đã đổi tên về dạng chuẩn
`media-generation-char-{name}-0-*.webp` /
`media-generation-walkcycle-sheet-{name}-0-*.webp` để khớp glob của
script. Bản đứng nữ bị loại của Nhân Viên Ngân Hàng giữ lại làm hồ sơ
dưới tên `rejected-female-char-nhanviennganhang-af4428f2.webp` (đã đổi
tên để glob `-0-*` của script chỉ khớp đúng bản đã chọn).
Script xử lý ảnh đứng: `visual-check/artpass35/process_standing_map013.py`.
Script cắt frame: `visual-check/artpass35/slice_walkcycle_npc_map013.py`.
Dải kiểm tra nền magenta: `walkcycle-check-magenta-{nhanviennganhang,moigioichungkhoan}.png`,
`char-{nhanviennganhang,moigioichungkhoan}-magenta.png`.
Debug vùng trắng kín: `debug-white-walk_nhanviennganhang_f{0,4,5}.png`
(vùng trắng kín tô đỏ), `zoom-bank-f0-documents.png`,
`zoom-bank-char-documents.png`, `zoom-broker-f0-phone.png`,
`zoom-broker-char-glasses.png` (phóng to 4× trên nền magenta).

## Sửa script so với vòng 34

- **Không sửa logic.** Cả hai script chỉ đổi tên NPC/đường dẫn so với vòng
  34 (`artpass34` → `artpass35`, `map012` → `map013`,
  `baovebietthu`/`nguoilamvuon` → `nhanviennganhang`/`moigioichungkhoan`,
  sửa luôn comment docstring cũ còn sót tên NPC vòng 32) — GIỮ NGUYÊN cả
  2 sửa của vòng 34: (1) `split_wide_component` (`MAX_FIG_W` = 600) trong
  script cắt frame; (2) xóa vùng trắng kín ≥100 final px trong cả hai
  script. Vòng này cả hai NPC đều không mặc đồ trắng (sơ mi xanh nhạt /
  xanh bạc hà nhạt) nên bước (2) được phép — và thực tế không có vùng
  trắng kín nào ≥100 final px bị xóa (xem dưới).
- Sheet Nhân Viên Ngân Hàng: component rộng nhất 526px, không cần tách.
  Sheet Môi Giới: các hình kề nhau chạm nhẹ ở tay (bbox f0 x49–522, f1
  x512–918 — chồng 10px) nhưng vẫn là 6 component riêng, không cần tách.

## Godot import

- **Không chạy trong vòng này (theo task: KHÔNG chạy export Godot).**
  File `.import` cho 14 file art mới (2 char + 12 walk frame) do agent
  khác chạy import sau, như vòng 34 đã làm
  (`tools/godot/Godot_v4.7.2-stable_linux.x86_64 --headless --import`).

## Kết quả kiểm tra bằng mắt

- **Ảnh đứng Nhân Viên Ngân Hàng (bản gen lại) — ĐẠT.** Nam trẻ rõ ràng,
  tóc đen ngắn chải lệch sang một bên, mặt nam, nụ cười thân thiện, vest
  navy có túi ngực + cúc, sơ mi xanh nhạt, cà vạt đỏ đậm, quần âu tối,
  giày da đen bóng, tay phải cầm tablet đen, tay trái ôm xấp giấy tờ ngân
  hàng có in dòng chữ + biểu đồ cột mờ, toàn thân đủ, nền trắng trơn,
  không chữ.
- **Ảnh đứng Môi Giới Chứng Khoán — ĐẠT, không cần gen lại.** Nam người
  Việt, tóc đen ngắn, đeo kính gọng đen chữ nhật, vest xám than, sơ mi
  xanh bạc hà nhạt, cà vạt tối, quần âu xám, giày da đen bóng, tay phải
  giơ điện thoại hiện biểu đồ nến xanh/đỏ + cột khối lượng, tay trái kẹp
  tập hồ sơ bìa nâu, nụ cười thân thiện, toàn thân đủ, nền trắng trơn,
  không chữ. (Chi tiết nhỏ: điện thoại có viền tai thỏ + vài ký tự nhỏ
  không đọc được trên màn hình — ở kích thước sprite trong game chỉ còn
  vài pixel, chấp nhận được.)
- **Sheet Nhân Viên Ngân Hàng — ĐẠT, không cần gen lại.** Đúng 6 nhân vật,
  1 hàng ngang cách đều, nền trắng trơn (góc 255,255,255), không chữ. Cùng
  mặt, tóc, vest navy + sơ mi xanh nhạt + cà vạt đỏ + quần âu tối + giày
  da đen, tablet + xấp giấy tờ ở cả 6 hình. Chân tiến triển rõ (dang rộng
  → khép/bắt chéo → bắt chéo → khép → dang rộng ngược → khép về tư thế
  đầu), tay đung đưa ngược pha chân, tablet/giấy tờ đổi tay theo nhịp đi
  (tay phải giơ tablet f0/f4, hai tay ôm trước ngực f1/f2/f3/f5). Toàn
  thân đủ, không cắt tay/chân.
- **Sheet Môi Giới Chứng Khoán — ĐẠT, không cần gen lại.** Đúng 6 nhân vật,
  1 hàng ngang cách đều, nền trắng trơn (góc 255,255,255), không chữ. Cùng
  mặt, kính, vest xám than + sơ mi bạc hà + cà vạt tối + giày da đen,
  điện thoại + tập hồ sơ ở cả 6 hình. Chân tiến triển rõ (dang rộng →
  khép/bắt chéo → bắt chéo → khép → dang rộng ngược → khép về tư thế
  đầu), tay đung đưa ngược pha chân, điện thoại đổi tay theo nhịp đi
  (tay phải f0–f3, tay trái f4/f5 — giống laptop/tablet vòng 32, sổ tay
  vòng 31, cờ tour vòng 33, không phải lỗi). Toàn thân đủ, không cắt
  tay/chân.
- Ảnh đứng + frame đã kiểm tra trên nền magenta sau khi xử lý trong suốt:
  không quầng trắng, toàn thân nguyên vẹn, frame không lệch khỏi tâm
  canvas. Đo bằng script: vùng trắng kín còn lại chỉ là giấy trắng của
  xấp tài liệu Nhân Viên Ngân Hàng (f0: 49px + 15px; f4: 61px; f5: 22px —
  đều <100 final px nên được giữ đúng thiết kế; vị trí x125–141, y111–122
  trùng đúng chỗ tay cầm giấy, xem `debug-white-walk_nhanviennganhang_f*.png`).
  Ảnh đứng cả hai + toàn bộ frame Môi Giới: không còn component trắng kín
  nào ≥15px. Zoom 4×: giấy tờ/tablet Nhân Viên Ngân Hàng còn nguyên nét
  (dòng chữ + biểu đồ cột trên giấy), điện thoại Môi Giới hiện rõ nến
  xanh/đỏ + cột khối lượng, kính gọng đen còn nguyên, mắt nhìn xuyên thấu
  kính, không có lỗ magenta nào.

## Hạn chế còn lại

- Chỉ mặt trước (front view, thực tế gen ra dạng 3/4) — giống các vòng
  trước, chưa có mặt sau/mặt nghiêng.
- f5 của cả hai gần như tư thế đứng (chân khép) — chấp nhận được như các
  vòng trước, chu kỳ vẫn lặp mượt; f5 ≈ tư thế khép về đầu chu kỳ.
- f2/f3/f4 của cả hai là 3 tư thế "chân bắt chéo/khép" khá gần nhau (khác
  nhau ở chân nào trước), không tách bạch bằng f0/f4 dang rộng — vẫn đủ
  phân biệt khi chạy.
- Tablet/giấy tờ/điện thoại/hồ sơ đổi tay qua các frame theo nhịp đung đưa
  — giống các vòng trước, không phải lỗi, là tay đung đưa ngược pha chân.
- Ngưỡng xóa trắng kín (100 final px) chỉ đúng khi NPC không mặc đồ trắng
  — NPC nào có áo sơ mi trắng / đồ trắng thì KHÔNG được dùng bước này
  (sẽ thủng áo); ghi lại để vòng sau lưu ý. Vòng này cả hai NPC đều mặc
  sơ mi màu nhạt (xanh nhạt / bạc hà nhạt) nên an toàn — nhưng lưu ý:
  giấy tờ trắng của Nhân Viên Ngân Hàng là vùng trắng kín THẬT (15–61
  final px) và đã được giữ lại nhờ ngưỡng 100; NPC nào cầm giấy trắng mà
  vùng giấy khép kín ≥100 final px thì bước xóa sẽ thủng giấy — kiểm tra
  debug-white sau mỗi vòng.
- Tham chiếu `char_cotu.png` là nhân vật NỮ — NPC nam gen từ tham chiếu
  này dễ bị vẽ thành nữ (vòng này gặp đúng lỗi đó). Vòng sau có NPC nam:
  thêm ngay vào prompt ảnh đứng "MAN, masculine face, short black hair,
  no earrings, no bun, no long hair" (xem mục gen lại ở trên).
- Không sửa code, không export, không push trong vòng này (theo task);
  code + test + import Godot do agent khác làm.
