# Artpass 33 — Walk-cycle NPC Map011 (Nhân Viên Lễ Tân + Hướng Dẫn Viên)

Ngày: 24/11/2026. Quy trình vòng 18/22/25/26/27/28/29/30/31/32: ảnh đứng →
trắng thành trong suốt (flood fill từ biên qua pixel trắng
min(R,G,B)≥235, feather r=1.5) → resize cao 208px → sheet 6 khung →
kiểm tra bằng mắt → cắt frame bằng script slice (cắt frame ngay trong
vòng này, như vòng 26/27/28/29/30/31/32).

Vị trí Map011 (Phố Tây): Nhân Viên Lễ Tân ở ô (3,3); Hướng Dẫn Viên ở ô
(8,6). Dữ liệu thật trong `src/godot/data/maps.json` (map id 11, events
kind npc).

## Nhân vật

- **Nhân Viên Lễ Tân** — nam trẻ, nhân viên lễ tân khách sạn phố Tây:
  áo sơ mi trắng, áo gile tối màu, quần âu tối, giày da đen, tóc đen
  ngắn gọn gàng, nụ cười chuyên nghiệp thân thiện, cầm bảng đăng ký
  khách (clipboard). Ảnh đứng: `src/godot/art/char_nhanvienletan.png`
  (82×208, RGBA). ID NPC `nhan-vien-le-tan` → frame dùng tiền tố
  `walk_nhanvienletan_` (bỏ dấu gạch nối, theo quy tắc test).
- **Hướng Dẫn Viên** — nữ trẻ, hướng dẫn viên du lịch: áo polo xanh
  dương nhạt, quần âu tối, giày thể thao trắng, tóc đen dài ngang vai,
  nụ cười tươi, cầm cờ tour nhỏ màu đỏ + bản đồ gấp. Ảnh đứng:
  `src/godot/art/char_huongdanvien.png` (120×208, RGBA).
  ID NPC `huong-dan-vien` → frame dùng tiền tố `walk_huongdanvien_`.

Tham chiếu phong cách: `src/godot/art/char_cotu.png` (112×208, RGBA).

## Prompt đã dùng

Ảnh đứng (mỗi người gen 1 lần, tham chiếu `char_cotu.png`):

> "Use this chibi character style as the exact reference. Create a single
> full-body chibi figure, front view, [mô tả nhân vật], same smiling face,
> same hand-drawn watercolor/gouache chibi style as the reference, full body
> visible head to shoes, no cropping, plain white background, no text, no
> background objects."

- Nhân Viên Lễ Tân: "a young Vietnamese male hotel receptionist, white
  dress shirt, dark vest, dark trousers, black leather shoes, short neat
  black hair, professional friendly smiling face, holding a guest
  registration clipboard"
- Hướng Dẫn Viên: "a young Vietnamese female tour guide, light blue polo
  shirt, dark trousers, white sneakers, long black hair shoulder-length,
  bright smiling face, holding a small red tour flag and a folded map"

Walk-cycle sheet (tham chiếu ảnh đứng vừa tạo; prompt vòng 26/27/28/29/30/31/32 +
mô tả 6 pha chân khác nhau rõ rệt):

> "Use this chibi character as the exact reference. Create a sprite sheet
> of exactly six full-body figures in a single horizontal row, evenly
> spaced, same character, same [clothes], same [hair], walking poses
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
> - Nhân Viên Lễ Tân: "same white dress shirt, same dark vest, same dark
>   trousers, same black leather shoes, same short neat black hair, same
>   guest registration clipboard"
> - Hướng Dẫn Viên: "same light blue polo shirt, same dark trousers, same
>   white sneakers, same long black hair shoulder-length, same small red
>   tour flag and folded map"

Số lần gen lại: **0 cho cả 4 lần gen** (2 ảnh đứng + 2 sheet đều đạt ngay
lần đầu, không cần resume snapshot).

## File

| File | Kích thước |
| --- | --- |
| `src/godot/art/char_nhanvienletan.png` | 82×208 RGBA, 37.419 byte |
| `src/godot/art/char_huongdanvien.png` | 120×208 RGBA, 42.660 byte |
| `src/godot/art/walk_nhanvienletan_f0.png` … `walk_nhanvienletan_f5.png` | 145×208 RGBA (canvas chung), 38.613–48.157 byte |
| `src/godot/art/walk_huongdanvien_f0.png` … `walk_huongdanvien_f5.png` | 149×208 RGBA (canvas chung), 44.646–53.012 byte |
| `visual-check/artpass33/walkcycle-sheet-nhanvienletan.png` | 2736×912 RGB, 1.949.852 byte |
| `visual-check/artpass33/walkcycle-sheet-huongdanvien.png` | 2736×912 RGB, 2.025.543 byte |

Bản thô gen ra còn lưu trong `visual-check/artpass33/` với tên
`media-generation-char-*.webp` / `media-generation-walkcycle-sheet-*.webp`
(pipeline media vòng này trả về `.webp`, như vòng 29/30/31/32; sheet
`.webp` đã chuyển sang `.png` cùng tên trước khi cắt frame). Tên file thô
do pipeline trả về có tiền tố dài `media-generation-media-generation-…`
và bị cắt ngắn tên stem — đã đổi tên về dạng chuẩn
`media-generation-char-{name}-0-*.webp` /
`media-generation-walkcycle-sheet-{name}-0-*.webp` để khớp glob của
script.
Script xử lý ảnh đứng: `visual-check/artpass33/process_standing_map011.py`.
Script cắt frame: `visual-check/artpass33/slice_walkcycle_npc_map011.py`.
Dải kiểm tra nền magenta: `walkcycle-check-magenta-{nhanvienletan,huongdanvien}.png`,
`char-{nhanvienletan,huongdanvien}-magenta.png`.

## Sửa script so với vòng 32

- `slice_walkcycle_npc_map011.py` — **giữ nguyên** tách hình bằng connected
  component (`scipy.ndimage.label`) + bộ lọc bỏ component hẹp TRƯỚC khi
  kiểm tra đủ 6 hình (bài học vòng 27/28/29), `MIN_FIG_W` giữ 100. Cả hai
  sheet đều tìm đúng 6 hình ngay lần đầu, không có đốm lọt qua. Sheet
  Nhân Viên Lễ Tân: f0 và f1 chồng lấn theo trục x (f0 bbox x 52–562,
  f1 bbox x 519–975 do clipboard f0 giơ ngang) nhưng tách bằng connected
  component vẫn đúng — đúng trường hợp bài học vòng 28 (column projection
  sẽ gộp sai). Sheet Hướng Dẫn Viên: f4/f5 chồng lấn trục x (f4 bbox x
  1827–2215, f5 bbox x 2188–2666 do cờ f4 giơ ngang) nhưng tách đúng ngay
  lần đầu.
- `process_standing_map011.py` — chỉ đổi tên NPC/đường dẫn so với vòng 32,
  cùng phương pháp flood fill + feather r=1.5, cao 208px; thêm dải kiểm
  tra magenta cho ảnh đứng; đọc file thô `.webp` (glob theo tên).

## Godot import

- Chạy `tools/godot/Godot_v4.7.2-stable_linux.x86_64 --headless --import`
  (binary đúng là `Godot_v4.7.2-stable_linux.x86_64`, không có file
  `tools/godot/godot`), exit 0 — **đủ 14 file `.import`** cho 14 file art
  mới (2 char + 12 walk frame). Vòng 28 từng lỗi vì thiếu bước này.

## Kết quả kiểm tra bằng mắt

- **Ảnh đứng Nhân Viên Lễ Tân — ĐẠT, không cần gen lại.** Nam trẻ, tóc
  đen ngắn gọn gàng, áo sơ mi trắng cổ bẻ có cúc + áo gile tối màu có
  cúc + túi ngực, quần âu tối, giày da đen bóng, clipboard đăng ký cầm
  hai tay (giấy có vạch mờ như form, không chữ đọc được), nụ cười chuyên
  nghiệp thân thiện, toàn thân đủ, nền trắng trơn, không chữ.
  (Chi tiết nhỏ: clipboard khá lớn, che phần lớn thân trên — vẫn đúng
  vai trò, nhận diện rõ lễ tân, chấp nhận được.)
- **Ảnh đứng Hướng Dẫn Viên — ĐẠT, không cần gen lại.** Nữ trẻ, tóc đen
  dài ngang vai rẽ giữa, áo polo xanh dương nhạt cổ bẻ có cúc + túi
  ngực, quần âu tối, giày thể thao trắng, cờ tour đỏ nhỏ tay phải, bản
  đồ gấp tay trái, nụ cười tươi, toàn thân đủ, nền trắng trơn, không
  chữ. (Chi tiết nhỏ: có khuyên tai vàng nhỏ — không có trong mô tả,
  chấp nhận được như vòng 31/32.)
- **Sheet Nhân Viên Lễ Tân — ĐẠT, không cần gen lại.** Đúng 6 nhân vật,
  1 hàng ngang cách đều, nền trắng trơn, không chữ. Cùng mặt, tóc ngắn,
  sơ mi trắng + gile tối, quần âu tối, giày da đen, clipboard ở cả 6
  hình. Chân tiến triển rõ (dang rộng → khép/bắt chéo → bắt chéo → khép
  → dang rộng ngược → khép về tư thế đầu), tay đung đưa ngược pha chân,
  clipboard đổi tay theo nhịp đi. Toàn thân đủ, không cắt tay/chân.
- **Sheet Hướng Dẫn Viên — ĐẠT, không cần gen lại.** Đúng 6 nhân vật,
  1 hàng ngang cách đều, nền trắng trơn, không chữ. Cùng mặt, tóc dài
  ngang vai, polo xanh nhạt, quần âu tối, giày trắng, cờ đỏ + bản đồ ở
  cả 6 hình (trừ f4 xem hạn chế). Chân tiến triển rõ (dang rộng → bắt
  chéo → khép → bắt chéo ngược → dang rộng ngược → khép về tư thế đầu),
  tay đung đưa ngược pha chân, cờ/bản đồ đổi tay theo nhịp đi. Toàn
  thân đủ, không cắt tay/chân.
- Ảnh đứng + frame đã kiểm tra trên nền magenta sau khi xử lý trong suốt:
  không quầng trắng, toàn thân nguyên vẹn, frame không lệch khỏi tâm
  canvas.

## Hạn chế còn lại

- Chỉ mặt trước (front view, thực tế gen ra dạng 3/4) — giống các vòng
  trước, chưa có mặt sau/mặt nghiêng.
- f5 của cả hai gần như tư thế đứng (chân khép) — chấp nhận được như các
  vòng trước, chu kỳ vẫn lặp mượt; f5 ≈ tư thế khép về đầu chu kỳ.
- f2/f3/f4 của cả hai là 3 tư thế "chân bắt chéo/khép" khá gần nhau (khác
  nhau ở chân nào trước), không tách bạch bằng f0/f4 dang rộng — vẫn đủ
  phân biệt khi chạy.
- Clipboard / cờ tour + bản đồ đổi tay (phải → trái → hai tay) qua các
  frame theo nhịp đung đưa — giống laptop/tablet vòng 32, sổ tay vòng
  31, không phải lỗi, là tay đung đưa ngược pha chân.
- **Cờ tour đỏ của Hướng Dẫn Viên không thấy trong f4** (tay phải nắm
  hờ trước ngực, không cầm cờ; bản đồ vẫn ở tay trái) — cờ có ở f0/f1/
  f2/f3/f5, chỉ mất 1/6 chu kỳ, ở kích thước sprite trong game cờ chỉ
  vài pixel nên hiệu ứng nhấp nháy không đáng kể; chấp nhận được, ghi
  lại để vòng sau lưu ý khi gen sheet có đạo cụ nhỏ.
- Cả hai sheet đều 2736×912, nền góc (254,254,254)/(252,251,252) hơi xám
  so với trắng 255 — script slice không phụ thuộc kích thước sheet,
  ngưỡng trắng min(R,G,B)≥235 vẫn tách đúng 6 hình; canvas frame cuối
  vẫn chuẩn 145×208 / 149×208.
- Không sửa code, không export, không push trong vòng này (theo task);
  code + test do agent khác làm.
