# Artpass 29 — Walk-cycle NPC Map007 (Nhân Viên Văn Phòng + Thực Tập Sinh)

Ngày: 23/11/2026. Quy trình vòng 18/22/25/26/27/28: ảnh đứng → trắng thành
trong suốt (flood fill từ biên qua pixel trắng min(R,G,B)≥235, feather
r=1.5) → resize cao 208px → sheet 6 khung → kiểm tra bằng mắt → cắt frame
bằng script slice (cắt frame ngay trong vòng này, như vòng 26/27/28).

Vị trí Map007 (Phố Văn Phòng Nhỏ): Nhân Viên Văn Phòng ở ô (3,3);
Thực Tập Sinh ở ô (8,6). Dữ liệu thật trong `src/godot/data/maps.json`
(map 7, events kind npc).

## Nhân vật

- **Nhân Viên Văn Phòng** — nam thanh niên Việt Nam, nhân viên văn
  phòng: áo sơ mi trắng dài tay, quần tây tối màu, giày đen, mặt hiền
  hay cười. Ảnh đứng: `src/godot/art/char_nhanvienvanphong.png`
  (90×208, RGBA). ID NPC `nhan-vien-van-phong` → frame dùng tiền tố
  `walk_nhanvienvanphong_` (bỏ dấu gạch nối, theo quy tắc test).
- **Thực Tập Sinh** — nữ sinh viên trẻ thực tập: áo sơ mi xanh nhạt,
  quần dài tối màu, giày đen, tóc đuôi ngựa, mặt hiền hay cười. Ảnh
  đứng: `src/godot/art/char_thuctapsinh.png` (92×208, RGBA). ID NPC
  `thuc-tap-sinh` → frame dùng tiền tố `walk_thuctapsinh_`.

Tham chiếu phong cách: `src/godot/art/char_cotu.png` (112×208, RGBA).

## Prompt đã dùng

Ảnh đứng (mỗi người gen 1 lần, tham chiếu `char_cotu.png`):

> "Use this chibi character style as the exact reference. Create a single
> full-body chibi figure, front view, [mô tả nhân vật], same smiling face,
> same hand-drawn watercolor/gouache chibi style as the reference, full body
> visible head to shoes, no cropping, plain white background, no text, no
> background objects."

- Nhân Viên Văn Phòng: "a young Vietnamese male office worker, white
  long-sleeve shirt, dark trousers, black shoes, kind smiling face"
- Thực Tập Sinh: "a young Vietnamese female student intern, light blue
  shirt, dark long trousers, black shoes, ponytail hair, kind smiling face"

Walk-cycle sheet (tham chiếu ảnh đứng vừa tạo; prompt vòng 26/27/28 + mô tả
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
> - Nhân Viên Văn Phòng: "same white long-sleeve shirt, same dark
>   trousers, same black shoes, same short black hair"
> - Thực Tập Sinh: "same light blue shirt, same dark long trousers, same
>   black shoes, same ponytail hair"

Số lần gen lại: **ảnh đứng 0 cho cả 2; sheet Thực Tập Sinh 0; sheet Nhân
Viên Văn Phòng 1 lần** (xem dưới).

## Gen lại sheet Nhân Viên Văn Phòng — hình f5 sai nhân vật

Sheet Nhân Viên gen lần đầu có hình 6 (f5) là **nữ đi giày cao gót**,
không phải nam nhân viên văn phòng — sai hẳn nhân vật, không dùng được.
Sửa bằng resume snapshot của sheet đó, chỉ vẽ lại hình 6: "redraw it as
the SAME young Vietnamese male office worker as the other five figures …
legs closing back to the start pose … Do not draw a woman, do not draw
high heels. Keep the other five figures exactly unchanged". Bản sửa:
f5 đúng nam, áo trắng dài tay, quần tối, giày đen, chân khép — ĐẠT,
5 hình còn lại giữ nguyên. Sheet cuối lưu là
`walkcycle-sheet-nhanvienvanphong.png` (bản lỗi đầu vẫn còn trong thư mục
dưới tên `media-generation-walkcycle-sheet-nhanvienvanpho-0-b783020b-*.webp`).

## File

| File | Kích thước |
| --- | --- |
| `src/godot/art/char_nhanvienvanphong.png` | 90×208 RGBA, 39.771 byte |
| `src/godot/art/char_thuctapsinh.png` | 92×208 RGBA, 43.304 byte |
| `src/godot/art/walk_nhanvienvanphong_f0.png` … `walk_nhanvienvanphong_f5.png` | 137×208 RGBA (canvas chung), 39.168–46.252 byte |
| `src/godot/art/walk_thuctapsinh_f0.png` … `walk_thuctapsinh_f5.png` | 138×208 RGBA (canvas chung), 43.879–52.473 byte |
| `visual-check/artpass29/walkcycle-sheet-nhanvienvanphong.png` | 2640×864 RGB, 1.611.916 byte |
| `visual-check/artpass29/walkcycle-sheet-thuctapsinh.png` | 2736×912 RGB, 2.272.124 byte |

Bản thô gen ra còn lưu trong `visual-check/artpass29/` với tên
`media-generation-char-*.webp` / `media-generation-walkcycle-sheet-*.webp`
(pipeline media vòng này trả về `.webp`, khác vòng 28 trả `.png`).
Script xử lý ảnh đứng: `visual-check/artpass29/process_standing_map007.py`.
Script cắt frame: `visual-check/artpass29/slice_walkcycle_npc_map007.py`.
Dải kiểm tra nền magenta: `walkcycle-check-magenta-{nhanvienvanphong,thuctapsinh}.png`,
`char-{nhanvienvanphong,thuctapsinh}-magenta.png`.

## Sửa script so với vòng 28

- `slice_walkcycle_npc_map007.py` — **giữ nguyên** tách hình bằng connected
  component (`scipy.ndimage.label`) + bộ lọc bỏ component hẹp TRƯỚC khi
  kiểm tra đủ 6 hình (bài học vòng 27/28). Chỉ đổi ngưỡng lọc:
  `MIN_FIG_W` 20 → **100**. Lý do: sheet Nhân Viên có 2 đốm tối 24–26px
  (rộng 24–26px, cao ~16px, nằm giữa các hình ở y≈476–495) lọt qua ngưỡng
  20px nên lần cắt đầu tìm được 8 component thay vì 6; hình thật rộng
  368–421px nên ngưỡng 100 vẫn an toàn. Sheet Thực Tập Sinh không có đốm
  (tìm đúng 6 hình ngay), nhưng vẫn chạy cùng ngưỡng 100.
- `process_standing_map007.py` — chỉ đổi tên NPC/đường dẫn so với vòng 28,
  cùng phương pháp flood fill + feather r=1.5, cao 208px; thêm dải kiểm
  tra magenta cho ảnh đứng; đọc file thô `.webp` (glob theo tên).

## Kết quả kiểm tra bằng mắt

- **Ảnh đứng Nhân Viên Văn Phòng — ĐẠT, không cần gen lại.** Nam thanh
  niên, áo sơ mi trắng dài tay có cổ + cúc + túi ngực, quần tây tối, giày
  đen, mặt hiền hay cười, toàn thân đủ, nền trắng trơn, không chữ.
  (Chi tiết nhỏ: có khuyên tai vàng bên tai trái — không có trong mô tả,
  chấp nhận được.)
- **Ảnh đứng Thực Tập Sinh — ĐẠT, không cần gen lại.** Nữ trẻ, tóc đuôi
  ngựa, áo xanh nhạt, quần dài tối, giày đen, mặt hiền hay cười, toàn thân
  đủ, nền trắng trơn, không chữ.
- **Sheet Nhân Viên Văn Phòng (bản sửa) — ĐẠT.** Đúng 6 nhân vật, 1 hàng
  ngang cách đều, nền trắng trơn, không chữ. Cùng mặt, tóc đen ngắn, áo
  trắng dài tay, quần tối, giày đen ở cả 6 hình. Chân tiến triển rõ (dang
  rộng → bắt chéo → khép → dang rộng ngược → khép về tư thế đầu), tay
  đung đưa ngược pha chân. Toàn thân đủ, không cắt tay/chân.
- **Sheet Thực Tập Sinh — ĐẠT, không cần gen lại.** Đúng 6 nhân vật,
  1 hàng ngang cách đều, nền trắng trơn, không chữ. Cùng mặt, tóc đuôi
  ngựa, áo xanh nhạt, quần tối dài, giày đen ở cả 6 hình. Chân tiến triển
  rõ, tay đung đưa. Toàn thân đủ, không cắt tay/chân.
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
- Áo Thực Tập Sinh gen ra kiểu cổ trụ khuy bấm (gần áo dài cách tân)
  thay vì sơ mi xanh nhạt cổ bẻ thường — giống lệch cổ áo của Bác Quản Lý
  vòng 28, vẫn là áo xanh nhạt dài tay, nhận diện đúng thực tập sinh,
  chấp nhận được.
- Tay trái hình f0 của Nhân Viên giơ cao ngang vai (nắm đấm) — đung đưa
  tay mạnh hơn các NPC vòng trước; vẫn trong nhịp đi bộ, không lỗi
  (giống tay f0 của Cư Dân vòng 28).
- Mặt Nhân Viên trông trẻ hơn "nhân viên văn phòng" kỳ vọng (khoảng
  20 tuổi, giống học sinh) — chấp nhận được, phân biệt rõ với Thực Tập
  Sinh nhờ áo trắng + tóc ngắn.
- Không sửa code, không export, không push trong vòng này (theo task);
  code + test do agent khác làm. File `.import` cho 14 file art mới chưa
  tạo — Godot sẽ tự sinh khi import, hoặc agent code tạo khi cần.
