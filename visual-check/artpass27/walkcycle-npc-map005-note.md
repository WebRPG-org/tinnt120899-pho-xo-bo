# Artpass 27 — Walk-cycle NPC Map005 (Thầy Giáo + Sinh Viên Làm Thêm)

Ngày: 23/11/2026. Quy trình vòng 18/22/25/26: ảnh đứng → trắng thành trong
suốt (flood fill từ biên qua pixel trắng min(R,G,B)≥235, feather r=1.5)
→ resize cao 208px → sheet 6 khung → kiểm tra bằng mắt → cắt frame bằng
script slice (cắt frame ngay trong vòng này, như vòng 26).

Vị trí Map005 (Làng Đại Học): Thầy Giáo ở ô (3,3); Sinh Viên Làm Thêm
ở ô (8,6).

## Nhân vật

- **Thầy Giáo** — giáo viên nam trung niên Việt Nam: đeo kính, áo sơ mi
  dài tay màu be/kem, quần dài tối màu, giày đen, mặt hiền. Ảnh đứng:
  `src/godot/art/char_thaygiao.png` (97×208, RGBA).
- **Sinh Viên Làm Thêm** — nữ sinh viên trẻ Việt Nam làm thêm: tóc đen
  ngắn buộc đuôi ngựa, áo thun vàng nhạt, quần jeans, giày thể thao
  trắng, mặt hiền. Ảnh đứng: `src/godot/art/char_sinhvien.png`
  (92×208, RGBA). ID NPC `sinh-vien-lam-them` → frame dùng tiền tố
  `walk_sinhvienlamthem_` (bỏ dấu gạch nối, theo quy tắc test).

Tham chiếu phong cách: `src/godot/art/char_cotu.png` (112×208, RGBA).

## Prompt đã dùng

Ảnh đứng (mỗi người gen 1 lần, tham chiếu `char_cotu.png`):

> "Use this chibi character style as the exact reference. Create a single
> full-body chibi figure, front view, [mô tả nhân vật], same smiling face,
> same hand-drawn watercolor/gouache chibi style as the reference, full body
> visible head to shoes, no cropping, plain white background, no text, no
> background objects."

- Thầy Giáo: "a middle-aged Vietnamese male teacher, wearing glasses,
  long-sleeve beige/cream shirt, dark long trousers, black shoes, kind
  smiling face"
- Sinh Viên Làm Thêm: "a young Vietnamese female university student
  working a part-time job, short black hair tied in a ponytail, pale
  yellow t-shirt, blue jeans, white sneakers, kind smiling face"

Walk-cycle sheet (tham chiếu ảnh đứng vừa tạo; prompt vòng 26 + mô tả 6
pha chân khác nhau rõ rệt):

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
> - Thầy Giáo: "same long-sleeve beige shirt, same dark long trousers,
>   same black shoes, same glasses, same short black hair with grey
>   streaks" — gen 1 lần, ĐẠT.
> - Sinh Viên Làm Thêm: "same pale yellow t-shirt, same blue jeans, same
>   white sneakers, same short black hair tied in a ponytail" — gen 1
>   lần, ĐẠT.

Số lần gen lại: **0 cho cả 4 ảnh** (2 ảnh đứng + 2 sheet đều ĐẠT ngay
lần đầu, không thừa đồ vật, không cắt chân, 6 pha khác nhau rõ).

## File

| File | Kích thước |
| --- | --- |
| `src/godot/art/char_thaygiao.png` | 97×208 RGBA, 44.887 byte |
| `src/godot/art/char_sinhvien.png` | 92×208 RGBA, 41.706 byte |
| `src/godot/art/walk_thaygiao_f0.png` … `walk_thaygiao_f5.png` | 144×208 RGBA (canvas chung), 39.769–49.263 byte |
| `src/godot/art/walk_sinhvienlamthem_f0.png` … `walk_sinhvienlamthem_f5.png` | 120×208 RGBA (canvas chung), 41.393–46.777 byte |
| `visual-check/artpass27/walkcycle-sheet-thaygiao.png` | 2736×912 RGB |
| `visual-check/artpass27/walkcycle-sheet-sinhvienlamthem.png` | 2736×912 RGB |

Bản thô gen ra còn lưu trong `visual-check/artpass27/` với tên
`media-generation-char-*.png` / `media-generation-walkcycle-sheet-*.png`
(bản gốc .webp của pipeline media cũng còn trong cùng thư mục).
Script xử lý ảnh đứng: `visual-check/artpass27/process_standing_map005.py`.
Script cắt frame: `visual-check/artpass27/slice_walkcycle_npc_map005.py`.
Dải kiểm tra nền magenta: `walkcycle-check-magenta-{thaygiao,sinhvienlamthem}.png`,
`char-{thaygiao,sinhvien}-magenta.png`.

## Sửa script so với vòng 26

- `slice_walkcycle_npc_map005.py` — `find_figure_regions` bỏ qua các
  column-run hẹp <20px TRƯỚC khi kiểm tra đủ 6 hình. Lý do: sheet Sinh
  Viên có 2 đốm xám lẻ trong nền trắng (cột 536: 2px, RGB ~223-230;
  cột 2297-2298: 1-3px, RGB ~193-227) khiến lần cắt đầu báo 8 run thay
  vì 6. Đốm đã kiểm chứng không thuộc nhân vật nào; nhân vật thật rộng
  360-460px. (Lần sửa đầu đặt bộ lọc sau câu raise nên vẫn lỗi — đã sửa
  lại đặt trước, cắt lại thành công.)
- Tên frame Sinh Viên dùng `walk_sinhvienlamthem_` (id bỏ dấu gạch nối),
  ảnh đứng vẫn `char_sinhvien.png`.

## Kết quả kiểm tra bằng mắt

- **Sheet Thầy Giáo — ĐẠT, không cần gen lại.** Đúng 6 nhân vật, 1 hàng
  ngang cách đều, nền trắng trơn, không chữ. Cùng mặt/kính, tóc đen điểm
  bạc, áo sơ mi be dài tay, quần tối dài, giày đen ở cả 6 hình. Chân tiến
  triển rõ (dang rộng → bắt chéo → khép → dang rộng ngược → khép về tư
  thế đầu), tay đung đưa ngược pha chân. Toàn thân đủ, không cắt tay/chân.
- **Sheet Sinh Viên Làm Thêm — ĐẠT, không cần gen lại.** Đúng 6 nhân vật,
  1 hàng ngang cách đều, nền trắng trơn, không chữ. Cùng mặt, tóc đen
  đuôi ngựa, áo thun vàng nhạt, quần jeans, giày thể thao trắng ở cả 6
  hình. Chân tiến triển rõ (sải rộng ↔ bắt chéo ↔ khép), tay đung đưa.
  Toàn thân đủ, không cắt tay/chân.
- Ảnh đứng + frame đã kiểm tra trên nền magenta sau khi xử lý trong suốt:
  không quầng trắng, toàn thân nguyên vẹn, frame không lệch khỏi tâm
  canvas.

## Hạn chế còn lại

- Chỉ mặt trước (front view, thực tế gen ra dạng 3/4) — giống vòng
  18/22/25/26, chưa có mặt sau/mặt nghiêng.
- f5 của cả hai gần như tư thế đứng (chân khép) — chấp nhận được như các
  vòng trước, chu kỳ vẫn lặp mượt; f5 ≈ tư thế khép về đầu chu kỳ.
- f1/f2/f3 của Sinh Viên là 3 tư thế "chân bắt chéo/khép" khá gần nhau
  (khác nhau ở chân nào trước), không tách bạch bằng Thầy Giáo — vẫn đủ
  phân biệt khi chạy, nhưng chu kỳ của Sinh Viên sẽ ít "sải" hơn Thầy Giáo.
- Đuôi ngựa của Sinh Viên hơi lệch sang một bên (đuôi ngựa thấp bên phải)
  thay vì chính giữa sau đầu — không ảnh hưởng nhận diện nhân vật.
- Không sửa code, không export, không push trong vòng này (theo task);
  code + test do agent khác làm.
