# Artpass 32 — Walk-cycle NPC Map010 (Lập Trình Viên + Kỹ Sư Phần Mềm)

Ngày: 24/11/2026. Quy trình vòng 18/22/25/26/27/28/29/30/31: ảnh đứng → trắng
thành trong suốt (flood fill từ biên qua pixel trắng min(R,G,B)≥235, feather
r=1.5) → resize cao 208px → sheet 6 khung → kiểm tra bằng mắt → cắt frame
bằng script slice (cắt frame ngay trong vòng này, như vòng 26/27/28/29/30/31).

Vị trí Map010 (Khu Công Nghệ): Lập Trình Viên ở ô (3,3);
Kỹ Sư Phần Mềm ở ô (8,6). Dữ liệu thật trong `src/godot/data/maps.json`
(map id 10, events kind npc).

## Nhân vật

- **Lập Trình Viên** — nam trẻ, lập trình viên công nghệ: áo polo xanh navy,
  quần jeans tối, giày thể thao trắng, tóc đen ngắn, đeo kính, cầm laptop
  mỏng, mặt hiền tập trung hay cười. Ảnh đứng:
  `src/godot/art/char_laptrinhvien.png` (85×208, RGBA). ID NPC
  `lap-trinh-vien` → frame dùng tiền tố `walk_laptrinhvien_` (bỏ dấu gạch
  nối, theo quy tắc test).
- **Kỹ Sư Phần Mềm** — nữ trẻ, kỹ sư phần mềm: áo blouse trắng xám nhạt,
  quần âu tối, giày bệt đen, tóc đen dài ngang vai, cầm máy tính bảng, mặt
  hiền tự tin hay cười. Ảnh đứng:
  `src/godot/art/char_kysuphanmem.png` (99×208, RGBA).
  ID NPC `ky-su-phan-mem` → frame dùng tiền tố `walk_kysuphanmem_`.

Tham chiếu phong cách: `src/godot/art/char_cotu.png` (112×208, RGBA).

## Prompt đã dùng

Ảnh đứng (mỗi người gen 1 lần, tham chiếu `char_cotu.png`):

> "Use this chibi character style as the exact reference. Create a single
> full-body chibi figure, front view, [mô tả nhân vật], same smiling face,
> same hand-drawn watercolor/gouache chibi style as the reference, full body
> visible head to shoes, no cropping, plain white background, no text, no
> background objects."

- Lập Trình Viên: "a young Vietnamese male software programmer, navy blue
  polo shirt, dark jeans, white sneakers, short black hair, wearing
  glasses, holding a slim laptop, kind focused smiling face"
- Kỹ Sư Phần Mềm: "a young Vietnamese female software engineer, light
  grey-white blouse, dark trousers, black flat shoes, long black hair
  shoulder-length, holding a tablet computer, kind confident smiling face"

Walk-cycle sheet (tham chiếu ảnh đứng vừa tạo; prompt vòng 26/27/28/29/30/31 +
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
> - Lập Trình Viên: "same navy blue polo shirt, same dark jeans, same
>   white sneakers, same short black hair, same glasses, same slim laptop"
> - Kỹ Sư Phần Mềm: "same light grey-white blouse, same dark trousers,
>   same black flat shoes, same long black hair shoulder-length, same
>   tablet computer"

Số lần gen lại: **0 cho cả 4 lần gen** (2 ảnh đứng + 2 sheet đều đạt ngay
lần đầu, không cần resume snapshot).

## File

| File | Kích thước |
| --- | --- |
| `src/godot/art/char_laptrinhvien.png` | 85×208 RGBA, 37.825 byte |
| `src/godot/art/char_kysuphanmem.png` | 99×208 RGBA, 41.755 byte |
| `src/godot/art/walk_laptrinhvien_f0.png` … `walk_laptrinhvien_f5.png` | 153×208 RGBA (canvas chung), 40.049–50.605 byte |
| `src/godot/art/walk_kysuphanmem_f0.png` … `walk_kysuphanmem_f5.png` | 181×208 RGBA (canvas chung), 45.535–61.304 byte |
| `visual-check/artpass32/walkcycle-sheet-laptrinhvien.png` | 2736×912 RGB, 1.910.914 byte |
| `visual-check/artpass32/walkcycle-sheet-kysuphanmem.png` | 3840×640 RGB, 1.766.556 byte |

Bản thô gen ra còn lưu trong `visual-check/artpass32/` với tên
`media-generation-char-*.webp` / `media-generation-walkcycle-sheet-*.webp`
(pipeline media vòng này trả về `.webp`, như vòng 29/30/31; sheet `.webp` đã
chuyển sang `.png` cùng tên trước khi cắt frame). Tên file thô do pipeline
trả về có tiền tố dài `media-generation-media-generation-…` và bị cắt ngắn
tên stem — đã đổi tên về dạng chuẩn `media-generation-char-{name}-0-*.webp` /
`media-generation-walkcycle-sheet-{name}-0-*.webp` để khớp glob của script.
Script xử lý ảnh đứng: `visual-check/artpass32/process_standing_map010.py`.
Script cắt frame: `visual-check/artpass32/slice_walkcycle_npc_map010.py`.
Dải kiểm tra nền magenta: `walkcycle-check-magenta-{laptrinhvien,kysuphanmem}.png`,
`char-{laptrinhvien,kysuphanmem}-magenta.png`.

## Sửa script so với vòng 31

- `slice_walkcycle_npc_map010.py` — **giữ nguyên** tách hình bằng connected
  component (`scipy.ndimage.label`) + bộ lọc bỏ component hẹp TRƯỚC khi
  kiểm tra đủ 6 hình (bài học vòng 27/28/29), `MIN_FIG_W` giữ 100. Cả hai
  sheet đều tìm đúng 6 hình ngay lần đầu, không có đốm lọt qua. Sheet Lập
  Trình Viên: f0 và f1 chồng lấn theo trục x (f0 bbox x 44–552, f1 bbox x
  547–941 do tay f0 giơ ngang cầm laptop) nhưng tách bằng connected
  component vẫn đúng — đúng trường hợp bài học vòng 28 (column projection
  sẽ gộp sai). Sheet Kỹ Sư Phần Mềm: 6 bbox không chồng lấn trục x, tách
  đúng ngay lần đầu.
- `process_standing_map010.py` — chỉ đổi tên NPC/đường dẫn so với vòng 31,
  cùng phương pháp flood fill + feather r=1.5, cao 208px; thêm dải kiểm
  tra magenta cho ảnh đứng; đọc file thô `.webp` (glob theo tên).

## Godot import

- Chạy `tools/godot/Godot_v4.7.2-stable_linux.x86_64 --headless --import`
  (binary đúng là `Godot_v4.7.2-stable_linux.x86_64`, không có file
  `tools/godot/godot`), exit 0 — **đủ 14 file `.import`** cho 14 file art
  mới (2 char + 12 walk frame). Vòng 28 từng lỗi vì thiếu bước này.

## Kết quả kiểm tra bằng mắt

- **Ảnh đứng Lập Trình Viên — ĐẠT, không cần gen lại.** Nam trẻ, tóc đen
  ngắn, đeo kính gọng đen, áo polo xanh navy cổ bẻ có cúc + túi ngực, quần
  jeans tối, giày thể thao trắng, laptop mỏng màu đen cầm hai tay, mặt
  hiền tập trung hay cười, toàn thân đủ, nền trắng trơn, không chữ.
  (Chi tiết nhỏ: có khuyên tai vàng nhỏ bên tai trái — không có trong mô
  tả, giống khuyên tai của Chủ Cửa Hàng vòng 31, chấp nhận được.)
- **Ảnh đứng Kỹ Sư Phần Mềm — ĐẠT, không cần gen lại.** Nữ trẻ, tóc đen
  dài ngang vai rẽ giữa, áo blouse trắng xám nhạt, quần âu tối, giày bệt
  đen, máy tính bảng cầm hai tay (màn hình có vài vạch mờ như giao diện),
  mặt hiền tự tin hay cười, toàn thân đủ, nền trắng trơn, không chữ.
  (Chi tiết nhỏ: có khuyên tai vàng nhỏ — không có trong mô tả, chấp nhận
  được như vòng 31.)
- **Sheet Lập Trình Viên — ĐẠT, không cần gen lại.** Đúng 6 nhân vật,
  1 hàng ngang cách đều, nền trắng trơn, không chữ. Cùng mặt, kính, tóc
  ngắn, polo navy, jeans tối, giày trắng, laptop ở cả 6 hình. Chân tiến
  triển rõ (dang rộng → bắt chéo → khép → dang rộng ngược → khép về tư
  thế đầu), tay đung đưa ngược pha chân, laptop đổi tay theo nhịp đi.
  Toàn thân đủ, không cắt tay/chân.
- **Sheet Kỹ Sư Phần Mềm — ĐẠT, không cần gen lại.** Đúng 6 nhân vật,
  1 hàng ngang cách đều, nền trắng trơn, không chữ. Cùng mặt, tóc dài
  ngang vai, blouse trắng xám nhạt, quần âu tối, giày bệt đen, máy tính
  bảng ở cả 6 hình. Chân tiến triển rõ (dang rộng → bắt chéo → khép →
  dang rộng ngược → khép về tư thế đầu), tay đung đưa ngược pha chân,
  máy tính bảng đổi tay theo nhịp đi. Toàn thân đủ, không cắt tay/chân.
- Ảnh đứng + frame đã kiểm tra trên nền magenta sau khi xử lý trong suốt:
  không quầng trắng, toàn thân nguyên vẹn, frame không lệch khỏi tâm
  canvas. Bóng xám mờ dưới chân ở ảnh thô cả hai đã biến mất sau flood
  fill (nằm trong vùng trắng nối biên).

## Hạn chế còn lại

- Chỉ mặt trước (front view, thực tế gen ra dạng 3/4) — giống các vòng
  trước, chưa có mặt sau/mặt nghiêng.
- f5 của cả hai gần như tư thế đứng (chân khép) — chấp nhận được như các
  vòng trước, chu kỳ vẫn lặp mượt; f5 ≈ tư thế khép về đầu chu kỳ.
- f2/f3/f4 của cả hai là 3 tư thế "chân bắt chéo/khép" khá gần nhau (khác
  nhau ở chân nào trước), không tách bạch bằng f0/f4 dang rộng — vẫn đủ
  phân biệt khi chạy.
- Áo Kỹ Sư Phần Mềm gen ra kiểu cổ trụ khuy bấm (gần áo dài cách tân) thay
  vì blouse cổ bẻ thường — giống lệch cổ áo của Chủ Cửa Hàng / Người Bán
  Hàng vòng 31, vẫn đúng màu + vai trò, nhận diện rõ kỹ sư phần mềm, chấp
  nhận được.
- Laptop / máy tính bảng đổi tay (phải → trái → hai tay) qua các frame theo
  nhịp đung đưa — giống sổ tay Chủ Cửa Hàng vòng 31, không phải lỗi, là tay
  đung đưa ngược pha chân.
- Sheet Kỹ Sư Phần Mềm có tỉ lệ 3840×640 (nền góc (254,254,254), hơi xám
  so với trắng 255) thay vì 2736×912 như vòng 31 — script slice không phụ
  thuộc kích thước sheet, ngưỡng trắng min(R,G,B)≥235 vẫn tách đúng 6 hình;
  canvas frame cuối vẫn chuẩn 181×208.
- Không sửa code, không export, không push trong vòng này (theo task);
  code + test do agent khác làm.
