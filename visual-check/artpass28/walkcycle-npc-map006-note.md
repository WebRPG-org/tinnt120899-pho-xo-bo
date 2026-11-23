# Artpass 28 — Walk-cycle NPC Map006 (Cư Dân Chung Cư + Bác Quản Lý)

Ngày: 23/11/2026. Quy trình vòng 18/22/25/26/27: ảnh đứng → trắng thành
trong suốt (flood fill từ biên qua pixel trắng min(R,G,B)≥235, feather
r=1.5) → resize cao 208px → sheet 6 khung → kiểm tra bằng mắt → cắt frame
bằng script slice (cắt frame ngay trong vòng này, như vòng 26/27).

Vị trí Map006 (Chung Cư Cũ): Cư Dân Chung Cư ở ô (3,6); Bác Quản Lý ở
ô (8,3).

## Nhân vật

- **Cư Dân Chung Cư** — nam trung niên Việt Nam, cư dân chung cư cũ:
  áo thun xám, quần kaki tối màu, dép/sandals, mặt hiền. Ảnh đứng:
  `src/godot/art/char_cudanchungcu.png` (90×208, RGBA). ID NPC
  `cu-dan-chung-cu` → frame dùng tiền tố `walk_cudanchungcu_` (bỏ dấu
  gạch nối, theo quy tắc test).
- **Bác Quản Lý** — ông lớn tuổi Việt Nam: tóc bạc, áo sơ mi ngắn tay
  xanh nhạt, quần dài tối màu, giày đen, mặt hiền. Ảnh đứng:
  `src/godot/art/char_bacquanly.png` (92×208, RGBA). ID NPC
  `bac-quan-ly` → frame dùng tiền tố `walk_bacquanly_`.

Tham chiếu phong cách: `src/godot/art/char_cotu.png` (112×208, RGBA).

## Prompt đã dùng

Ảnh đứng (mỗi người gen 1 lần, tham chiếu `char_cotu.png`):

> "Use this chibi character style as the exact reference. Create a single
> full-body chibi figure, front view, [mô tả nhân vật], same smiling face,
> same hand-drawn watercolor/gouache chibi style as the reference, full body
> visible head to shoes, no cropping, plain white background, no text, no
> background objects."

- Cư Dân Chung Cư: "a middle-aged Vietnamese man living in an old
  apartment building, grey t-shirt, dark khaki trousers, sandals, kind
  smiling face"
- Bác Quản Lý: "an elderly Vietnamese man, grey hair, light blue
  short-sleeve shirt, dark long trousers, black shoes, kind smiling face"

Walk-cycle sheet (tham chiếu ảnh đứng vừa tạo; prompt vòng 26/27 + mô tả
6 pha chân khác nhau rõ rệt):

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
> - Cư Dân Chung Cư: "same grey t-shirt, same dark khaki trousers, same
>   sandals, same short black hair" — gen 1 lần, ĐẠT.
> - Bác Quản Lý: "same light blue short-sleeve shirt, same dark long
>   trousers, same black shoes, same grey hair" — gen 1 lần, ĐẠT.

Số lần gen lại: **0 cho cả 4 ảnh** (2 ảnh đứng + 2 sheet đều ĐẠT ngay
lần đầu, không thừa đồ vật, không cắt chân, 6 pha khác nhau rõ).

## File

| File | Kích thước |
| --- | --- |
| `src/godot/art/char_cudanchungcu.png` | 90×208 RGBA, 43.471 byte |
| `src/godot/art/char_bacquanly.png` | 92×208 RGBA, 43.363 byte |
| `src/godot/art/walk_cudanchungcu_f0.png` … `walk_cudanchungcu_f5.png` | 132×208 RGBA (canvas chung), 40.778–49.808 byte |
| `src/godot/art/walk_bacquanly_f0.png` … `walk_bacquanly_f5.png` | 128×208 RGBA (canvas chung), 40.849–46.508 byte |
| `visual-check/artpass28/walkcycle-sheet-cudanchungcu.png` | 2736×912 RGB, 2.553.735 byte |
| `visual-check/artpass28/walkcycle-sheet-bacquanly.png` | 2736×912 RGB, 2.355.082 byte |

Bản thô gen ra còn lưu trong `visual-check/artpass28/` với tên
`media-generation-char-*.png` / `media-generation-walkcycle-sheet-*.png`
(bản gốc tên dài của pipeline media cũng còn trong cùng thư mục).
Script xử lý ảnh đứng: `visual-check/artpass28/process_standing_map006.py`.
Script cắt frame: `visual-check/artpass28/slice_walkcycle_npc_map006.py`.
Dải kiểm tra nền magenta: `walkcycle-check-magenta-{cudanchungcu,bacquanly}.png`,
`char-{cudanchungcu,bacquanly}-magenta.png`.

## Sửa script so với vòng 27

- `slice_walkcycle_npc_map006.py` — **tách hình bằng connected component
  (scipy.ndimage.label) thay cho chiếu cột**. Lý do: sheet Cư Dân cắt
  lần đầu chỉ tìm được 5 run cột thay vì 6 — tay trái giơ cao của hình 1
  (nắm đấm ở x≈460–510) chồng lấn theo chiều ngang với tóc hình 2
  (bắt đầu x≈480) nên chiếu cột gộp hình 1 + hình 2 thành một run 897px,
  dù hai hình rời nhau hoàn toàn trong 2D. Tách component tìm đúng 6
  hình (Cư Dân: 6 hình + 6 đốm 1px; Bác Quản Lý: đúng 6 hình, không đốm).
  Mỗi hình được mask riêng (pixel của hình khác đặt thành trắng) rồi mới
  crop/flood-fill/resize như cũ, nên nắm đấm giơ cao vẫn thuộc về hình 1,
  không bị cắt sang hình 2.
- Bộ lọc bỏ component hẹp <20px vẫn đặt TRƯỚC khi kiểm tra đủ 6 hình
  (bài học vòng 27, giữ nguyên): sheet Cư Dân có 6 đốm xám 1px trong nền
  trắng; hình thật rộng 365–491px.
- `process_standing_map006.py` — chỉ đổi tên NPC/đường dẫn so với vòng 27,
  cùng phương pháp flood fill + feather r=1.5, cao 208px.

## Kết quả kiểm tra bằng mắt

- **Sheet Cư Dân Chung Cư — ĐẠT, không cần gen lại.** Đúng 6 nhân vật,
  1 hàng ngang cách đều, nền trắng trơn, không chữ. Cùng mặt, tóc đen
  ngắn, áo thun xám, quần kaki tối, dép sandal ở cả 6 hình. Chân tiến
  triển rõ (dang rộng → bắt chéo → khép → dang rộng ngược → khép về tư
  thế đầu), tay đung đưa ngược pha chân. Toàn thân đủ, không cắt tay/chân.
- **Sheet Bác Quản Lý — ĐẠT, không cần gen lại.** Đúng 6 nhân vật, 1 hàng
  ngang cách đều, nền trắng trơn, không chữ. Cùng mặt, tóc bạc + ria mép
  bạc, áo xanh nhạt ngắn tay, quần tối dài, giày đen ở cả 6 hình. Chân
  tiến triển rõ, tay đung đưa. Toàn thân đủ, không cắt tay/chân.
- Ảnh đứng + frame đã kiểm tra trên nền magenta sau khi xử lý trong suốt:
  không quầng trắng, toàn thân nguyên vẹn, frame không lệch khỏi tâm
  canvas. Bóng mờ nhẹ dưới chân Bác Quản Lý trong ảnh thô đã được
  flood-fill loại bỏ, không còn vệt xám dưới chân trong ảnh đứng cuối.

## Hạn chế còn lại

- Chỉ mặt trước (front view, thực tế gen ra dạng 3/4) — giống các vòng
  trước, chưa có mặt sau/mặt nghiêng.
- f5 của cả hai gần như tư thế đứng (chân khép) — chấp nhận được như các
  vòng trước, chu kỳ vẫn lặp mượt; f5 ≈ tư thế khép về đầu chu kỳ.
- f2/f3/f4 của Bác Quản Lý là 3 tư thế "chân bắt chéo/khép" khá gần nhau
  (khác nhau ở chân nào trước), không tách bạch bằng Cư Dân — vẫn đủ phân
  biệt khi chạy, nhưng chu kỳ của Bác Quản Lý sẽ ít "sải" hơn Cư Dân.
- Tay trái hình f0 của Cư Dân giơ cao (nắm đấm ngang vai) — đung đưa tay
  mạnh hơn các NPC vòng trước; vẫn trong nhịp đi bộ, không lỗi.
- Áo Bác Quản Lý gen ra kiểu cổ trụ có khuy bấm (gần áo dài cách tân)
  thay vì sơ mi ngắn tay cổ bẻ thường — vẫn là áo xanh nhạt ngắn tay,
  nhận diện đúng vai quản lý lớn tuổi, chấp nhận được.
- Mặt Cư Dân trông trẻ hơn "trung niên" (khoảng 30 tuổi, râu lún phún
  nhẹ) — chấp nhận được, phân biệt rõ với Bác Quản Lý tóc bạc.
- Không sửa code, không export, không push trong vòng này (theo task);
  code + test do agent khác làm. File `.import` cho 14 file art mới chưa
  tạo — Godot sẽ tự sinh khi import, hoặc agent code tạo khi cần.
