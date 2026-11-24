# Artpass 31 — Walk-cycle NPC Map009 (Chủ Cửa Hàng + Người Bán Hàng)

Ngày: 24/11/2026. Quy trình vòng 18/22/25/26/27/28/29/30: ảnh đứng → trắng thành
trong suốt (flood fill từ biên qua pixel trắng min(R,G,B)≥235, feather
r=1.5) → resize cao 208px → sheet 6 khung → kiểm tra bằng mắt → cắt frame
bằng script slice (cắt frame ngay trong vòng này, như vòng 26/27/28/29/30).

Vị trí Map009 (Phố Thương Mại): Chủ Cửa Hàng ở ô (3,3);
Người Bán Hàng ở ô (8,6). Dữ liệu thật trong `src/godot/data/maps.json`
(map 9, events kind npc).

## Nhân vật

- **Chủ Cửa Hàng** — nam trung niên, chủ cửa hàng phố thương mại: áo sơ mi
  xanh nhạt dài tay, quần tối, giày da đen, tóc đen ngắn điểm bạc hai bên
  thái dương, cầm sổ tay da nâu, mặt hiền hay cười, tự tin. Ảnh đứng:
  `src/godot/art/char_chucuahang.png` (99×208, RGBA). ID NPC
  `chu-cua-hang` → frame dùng tiền tố `walk_chucuahang_` (bỏ dấu gạch
  nối, theo quy tắc test).
- **Người Bán Hàng** — nữ trẻ, nhân viên bán hàng: áo blouse xanh lá nhạt,
  váy dài tối, giày bệt đen, tóc đen đuôi ngựa, cầm túi giấy, mặt hiền hay
  cười. Ảnh đứng: `src/godot/art/char_nguoibanhang.png` (109×208, RGBA).
  ID NPC `nguoi-ban-hang` → frame dùng tiền tố `walk_nguoibanhang_`.

Tham chiếu phong cách: `src/godot/art/char_cotu.png` (112×208, RGBA).

## Prompt đã dùng

Ảnh đứng (mỗi người gen 1 lần, tham chiếu `char_cotu.png`):

> "Use this chibi character style as the exact reference. Create a single
> full-body chibi figure, front view, [mô tả nhân vật], same smiling face,
> same hand-drawn watercolor/gouache chibi style as the reference, full body
> visible head to shoes, no cropping, plain white background, no text, no
> background objects."

- Chủ Cửa Hàng: "a middle-aged Vietnamese male shop owner of a small
  commercial street shop, neat light blue buttoned shirt, dark trousers,
  black leather shoes, short black hair greying at the temples, holding a
  small notebook, kind confident smiling face"
- Người Bán Hàng: "a young Vietnamese female shop assistant, neat light
  green blouse, dark long skirt, black flat shoes, black hair in a
  ponytail, holding a small paper shopping bag, kind friendly smiling face"

Walk-cycle sheet (tham chiếu ảnh đứng vừa tạo; prompt vòng 26/27/28/29/30 +
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
> - Chủ Cửa Hàng: "same light blue buttoned shirt, same dark trousers,
>   same black leather shoes, same short black hair greying at the
>   temples, same small brown notebook"
> - Người Bán Hàng: "same light green blouse, same dark long skirt, same
>   black flat shoes, same black hair in a ponytail, same small paper
>   shopping bag"

Số lần gen lại: **0 cho cả 4 lần gen** (2 ảnh đứng + 2 sheet đều đạt ngay
lần đầu, không cần resume snapshot).

## File

| File | Kích thước |
| --- | --- |
| `src/godot/art/char_chucuahang.png` | 99×208 RGBA, 46.539 byte |
| `src/godot/art/char_nguoibanhang.png` | 109×208 RGBA, 43.342 byte |
| `src/godot/art/walk_chucuahang_f0.png` … `walk_chucuahang_f5.png` | 140×208 RGBA (canvas chung), 40.677–49.702 byte |
| `src/godot/art/walk_nguoibanhang_f0.png` … `walk_nguoibanhang_f5.png` | 135×208 RGBA (canvas chung), 45.310–52.956 byte |
| `visual-check/artpass31/walkcycle-sheet-chucuahang.png` | 2736×912 RGB, 2.066.400 byte |
| `visual-check/artpass31/walkcycle-sheet-nguoibanhang.png` | 2736×912 RGB, 2.285.531 byte |

Bản thô gen ra còn lưu trong `visual-check/artpass31/` với tên
`media-generation-char-*.webp` / `media-generation-walkcycle-sheet-*.webp`
(pipeline media vòng này trả về `.webp`, như vòng 29/30; sheet `.webp` đã
chuyển sang `.png` cùng tên trước khi cắt frame).
Script xử lý ảnh đứng: `visual-check/artpass31/process_standing_map009.py`.
Script cắt frame: `visual-check/artpass31/slice_walkcycle_npc_map009.py`.
Dải kiểm tra nền magenta: `walkcycle-check-magenta-{chucuahang,nguoibanhang}.png`,
`char-{chucuahang,nguoibanhang}-magenta.png`.

## Sửa script so với vòng 30

- `slice_walkcycle_npc_map009.py` — **giữ nguyên** tách hình bằng connected
  component (`scipy.ndimage.label`) + bộ lọc bỏ component hẹp TRƯỚC khi
  kiểm tra đủ 6 hình (bài học vòng 27/28/29), `MIN_FIG_W` giữ 100. Cả hai
  sheet đều tìm đúng 6 hình ngay lần đầu, không có đốm lọt qua. Sheet Chủ
  Cửa Hàng: f0 và f1 chồng lấn theo trục x (f0 bbox x 83–578, f1 bbox x
  561–913 do tay f0 giơ ngang cầm sổ) nhưng tách bằng connected component
  vẫn đúng — đúng trường hợp bài học vòng 28 (column projection sẽ gộp
  sai). Sheet Người Bán Hàng: f3/f4 chồng nhẹ trục x (f3 x 1391–1783,
  f4 x 1750–2226) cũng tách đúng.
- `process_standing_map009.py` — chỉ đổi tên NPC/đường dẫn so với vòng 30,
  cùng phương pháp flood fill + feather r=1.5, cao 208px; thêm dải kiểm
  tra magenta cho ảnh đứng; đọc file thô `.webp` (glob theo tên).

## Godot import

- Chạy `tools/godot/Godot_v4.7.2-stable_linux.x86_64 --headless --import`
  (binary đúng là `Godot_v4.7.2-stable_linux.x86_64`, không có file
  `tools/godot/godot`), exit 0 — **đủ 14 file `.import`** cho 14 file art
  mới (2 char + 12 walk frame). Vòng 28 từng lỗi vì thiếu bước này.

## Kết quả kiểm tra bằng mắt

- **Ảnh đứng Chủ Cửa Hàng — ĐẠT, không cần gen lại.** Nam trung niên,
  tóc đen ngắn điểm bạc hai bên thái dương, áo sơ mi xanh nhạt cổ trụ có
  cúc + túi, quần tối, giày da đen, sổ tay da nâu cầm tay phải, mặt hiền
  hay cười, toàn thân đủ, nền trắng trơn, không chữ. (Chi tiết nhỏ: có
  khuyên tai vàng — không có trong mô tả, giống khuyên tai của Nhân Viên
  Văn Phòng vòng 29 và Cư Dân Cao Cấp vòng 30, chấp nhận được.)
- **Ảnh đứng Người Bán Hàng — ĐẠT, không cần gen lại.** Nữ trẻ, tóc đen
  đuôi ngựa, áo blouse xanh lá nhạt cổ trụ khuy bấm, váy dài tối, giày
  bệt đen, túi giấy nâu cầm tay phải, mặt hiền hay cười, toàn thân đủ,
  nền trắng trơn, không chữ. (Chi tiết nhỏ: có khuyên tai vàng nhỏ —
  không có trong mô tả, chấp nhận được.)
- **Sheet Chủ Cửa Hàng — ĐẠT, không cần gen lại.** Đúng 6 nhân vật,
  1 hàng ngang cách đều, nền trắng trơn, không chữ. Cùng mặt, tóc điểm
  bạc, áo xanh nhạt, quần tối, giày da đen, sổ tay nâu ở cả 6 hình. Chân
  tiến triển rõ (dang rộng → bắt chéo → khép → dang rộng ngược → khép về
  tư thế đầu), tay đung đưa ngược pha chân, sổ đổi tay theo nhịp đi.
  Toàn thân đủ, không cắt tay/chân.
- **Sheet Người Bán Hàng — ĐẠT, không cần gen lại.** Đúng 6 nhân vật,
  1 hàng ngang cách đều, nền trắng trơn, không chữ. Cùng mặt, đuôi ngựa,
  áo xanh lá nhạt, váy dài tối, giày bệt đen, túi giấy ở cả 6 hình. Chân
  dưới váy tiến triển rõ (dang rộng → bắt chéo → khép → dang rộng ngược
  → khép về tư thế đầu), tay đung đưa ngược pha chân, túi đổi tay theo
  nhịp đi. Toàn thân đủ, không cắt tay/chân.
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
- Áo cả hai gen ra kiểu cổ trụ khuy bấm (gần áo dài cách tân) thay vì sơ
  mi/blouse cổ bẻ thường — giống lệch cổ áo của Thực Tập Sinh vòng 29,
  Cư Dân Cao Cấp vòng 30, vẫn đúng màu + vai trò, nhận diện rõ chủ cửa
  hàng / nhân viên bán hàng, chấp nhận được.
- Chân Người Bán Hàng chỉ lộ từ dưới váy dài trở xuống (cẳng chân + giày)
  nên nhịp chân khi chạy ít rõ bằng NPC quần dài — vẫn phân biệt được 6
  pha nhờ vị trí giày + váy xòe theo bước, chấp nhận được.
- Sổ tay Chủ Cửa Hàng đổi tay (phải → trái → phải) qua các frame theo
  nhịp đung đưa — giống túi xách Cư Dân vòng 30, không phải lỗi, là tay
  đung đưa ngược pha chân.
- Không sửa code, không export, không push trong vòng này (theo task);
  code + test do agent khác làm.
