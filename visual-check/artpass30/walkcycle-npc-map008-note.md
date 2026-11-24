# Artpass 30 — Walk-cycle NPC Map008 (Cư Dân Cao Cấp + Bảo Vệ Chung Cư)

Ngày: 24/11/2026. Quy trình vòng 18/22/25/26/27/28/29: ảnh đứng → trắng thành
trong suốt (flood fill từ biên qua pixel trắng min(R,G,B)≥235, feather
r=1.5) → resize cao 208px → sheet 6 khung → kiểm tra bằng mắt → cắt frame
bằng script slice (cắt frame ngay trong vòng này, như vòng 26/27/28/29).

Vị trí Map008 (Khu Chung Cư Cao Cấp): Cư Dân Cao Cấp ở ô (3,3);
Bảo Vệ Chung Cư ở ô (8,6). Dữ liệu thật trong `src/godot/data/maps.json`
(map 8, events kind npc).

## Nhân vật

- **Cư Dân Cao Cấp** — phụ nữ trung niên khá giả, cư dân chung cư cao
  cấp: áo blouse hồng nhạt, quần âu trắng, giày bệt đen, tóc đen búi cao,
  đeo túi xách nhỏ, mặt hiền hay cười. Ảnh đứng:
  `src/godot/art/char_cudancaocap.png` (78×208, RGBA). ID NPC
  `cu-dan-cao-cap` → frame dùng tiền tố `walk_cudancaocap_` (bỏ dấu gạch
  nối, theo quy tắc test).
- **Bảo Vệ Chung Cư** — nam trung niên, bảo vệ chung cư: áo sơ mi xanh
  đậm đồng phục, quần tối, giày đen, mũ lưỡi trai đồng phục, mặt hiền hay
  cười. Ảnh đứng: `src/godot/art/char_baovechungcu.png` (97×208, RGBA).
  ID NPC `bao-ve-chung-cu` → frame dùng tiền tố `walk_baovechungcu_`.

Tham chiếu phong cách: `src/godot/art/char_cotu.png` (112×208, RGBA).

## Prompt đã dùng

Ảnh đứng (mỗi người gen 1 lần, tham chiếu `char_cotu.png`):

> "Use this chibi character style as the exact reference. Create a single
> full-body chibi figure, front view, [mô tả nhân vật], same smiling face,
> same hand-drawn watercolor/gouache chibi style as the reference, full body
> visible head to shoes, no cropping, plain white background, no text, no
> background objects."

- Cư Dân Cao Cấp: "a middle-aged Vietnamese woman, well-off resident of a
  luxury apartment building, light pink blouse, white trousers, black flat
  shoes, black hair in a high bun, carrying a small handbag, kind smiling
  face"
- Bảo Vệ Chung Cư: "a middle-aged Vietnamese male apartment building
  security guard, dark blue uniform shirt, dark trousers, black shoes,
  dark uniform peaked cap, kind smiling face"

Walk-cycle sheet (tham chiếu ảnh đứng vừa tạo; prompt vòng 26/27/28/29 +
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
> - Cư Dân Cao Cấp: "same light pink blouse, same white trousers, same
>   black flat shoes, same black hair in a high bun, same small handbag"
> - Bảo Vệ Chung Cư: "same dark blue uniform shirt, same dark trousers,
>   same black shoes, same dark uniform peaked cap"

Số lần gen lại: **0 cho cả 4 lần gen** (2 ảnh đứng + 2 sheet đều đạt ngay
lần đầu, không cần resume snapshot).

## File

| File | Kích thước |
| --- | --- |
| `src/godot/art/char_cudancaocap.png` | 78×208 RGBA, 34.860 byte |
| `src/godot/art/char_baovechungcu.png` | 97×208 RGBA, 43.449 byte |
| `src/godot/art/walk_cudancaocap_f0.png` … `walk_cudancaocap_f5.png` | 111×208 RGBA (canvas chung), 34.757–39.454 byte |
| `src/godot/art/walk_baovechungcu_f0.png` … `walk_baovechungcu_f5.png` | 139×208 RGBA (canvas chung), 39.332–47.887 byte |
| `visual-check/artpass30/walkcycle-sheet-cudancaocap.png` | 2736×912 RGB, 2.023.085 byte |
| `visual-check/artpass30/walkcycle-sheet-baovechungcu.png` | 2736×912 RGB, 2.084.246 byte |

Bản thô gen ra còn lưu trong `visual-check/artpass30/` với tên
`media-generation-char-*.webp` / `media-generation-walkcycle-sheet-*.webp`
(pipeline media vòng này trả về `.webp`, như vòng 29; sheet `.webp` đã
chuyển sang `.png` cùng tên trước khi cắt frame).
Script xử lý ảnh đứng: `visual-check/artpass30/process_standing_map008.py`.
Script cắt frame: `visual-check/artpass30/slice_walkcycle_npc_map008.py`.
Dải kiểm tra nền magenta: `walkcycle-check-magenta-{cudancaocap,baovechungcu}.png`,
`char-{cudancaocap,baovechungcu}-magenta.png`.

## Sửa script so với vòng 29

- `slice_walkcycle_npc_map008.py` — **giữ nguyên** tách hình bằng connected
  component (`scipy.ndimage.label`) + bộ lọc bỏ component hẹp TRƯỚC khi
  kiểm tra đủ 6 hình (bài học vòng 27/28/29), `MIN_FIG_W` giữ 100. Cả hai
  sheet đều tìm đúng 6 hình ngay lần đầu, không có đốm lọt qua. Sheet Bảo
  Vệ: f0 và f1 chồng lấn theo trục x (f0 bbox x 72–570, f1 bbox x 538–907
  do tay f0 giơ ngang) nhưng tách bằng connected component vẫn đúng —
  đúng trường hợp bài học vòng 28 (column projection sẽ gộp sai).
- `process_standing_map008.py` — chỉ đổi tên NPC/đường dẫn so với vòng 29,
  cùng phương pháp flood fill + feather r=1.5, cao 208px; thêm dải kiểm
  tra magenta cho ảnh đứng; đọc file thô `.webp` (glob theo tên).

## Kết quả kiểm tra bằng mắt

- **Ảnh đứng Cư Dân Cao Cấp — ĐẠT, không cần gen lại.** Nữ trung niên,
  tóc đen búi cao, áo blouse hồng nhạt cổ trụ có cúc + túi, quần âu trắng,
  giày bệt đen có nơ, túi xách đen nhỏ dây xích đeo vai trái, mặt hiền hay
  cười, toàn thân đủ, nền trắng trơn, không chữ. (Chi tiết nhỏ: có khuyên
  tai vàng — không có trong mô tả, chấp nhận được, giống khuyên tai của
  Nhân Viên Văn Phòng vòng 29.)
- **Ảnh đứng Bảo Vệ Chung Cư — ĐẠT, không cần gen lại.** Nam trung niên,
  mũ đồng phục xanh đậm có huy hiệu vàng, áo sơ mi xanh đậm đồng phục có
  cầu vai + huy hiệu ngực + túi, quần tối, giày đen, mặt hiền hay cười,
  toàn thân đủ, nền trắng trơn, không chữ. (Chi tiết nhỏ: có râu quai nón
  lưa thưa — không có trong mô tả, chấp nhận được, tăng vẻ trung niên.)
- **Sheet Cư Dân Cao Cấp — ĐẠT, không cần gen lại.** Đúng 6 nhân vật,
  1 hàng ngang cách đều, nền trắng trơn, không chữ. Cùng mặt, búi cao,
  blouse hồng nhạt, quần trắng, giày bệt đen, túi xách ở cả 6 hình. Chân
  tiến triển rõ (dang rộng → bắt chéo → khép → dang rộng ngược → khép về
  tư thế đầu), tay đung đưa ngược pha chân. Toàn thân đủ, không cắt
  tay/chân.
- **Sheet Bảo Vệ Chung Cư — ĐẠT, không cần gen lại.** Đúng 6 nhân vật,
  1 hàng ngang cách đều, nền trắng trơn, không chữ. Cùng mặt, mũ đồng
  phục, áo xanh đậm, quần tối, giày đen ở cả 6 hình. Chân tiến triển rõ,
  tay đung đưa ngược pha chân. Toàn thân đủ, không cắt tay/chân.
- Ảnh đứng + frame đã kiểm tra trên nền magenta sau khi xử lý trong suốt:
  không quầng trắng, toàn thân nguyên vẹn, frame không lệch khỏi tâm
  canvas. Bóng xám mờ dưới chân ở ảnh thô Cư Dân đã biến mất sau flood
  fill (nằm trong vùng trắng nối biên).

## Hạn chế còn lại

- Chỉ mặt trước (front view, thực tế gen ra dạng 3/4) — giống các vòng
  trước, chưa có mặt sau/mặt nghiêng.
- f5 của cả hai gần như tư thế đứng (chân khép) — chấp nhận được như các
  vòng trước, chu kỳ vẫn lặp mượt; f5 ≈ tư thế khép về đầu chu kỳ.
- f2/f3/f4 của cả hai là 3 tư thế "chân bắt chéo/khép" khá gần nhau (khác
  nhau ở chân nào trước), không tách bạch bằng f0/f4 dang rộng — vẫn đủ
  phân biệt khi chạy.
- Áo Cư Dân gen ra kiểu cổ trụ khuy bấm (gần áo dài cách tân) thay vì
  blouse hồng nhạt cổ bẻ thường — giống lệch cổ áo của Thực Tập Sinh vòng
  29 và Bác Quản Lý vòng 28, vẫn là áo hồng nhạt, nhận diện đúng cư dân
  cao cấp, chấp nhận được.
- Mũ Bảo Vệ gen ra dạng mũ kê-pi (peaked service cap) có huy hiệu thay
  vì mũ lưỡi trai (baseball cap) như mô tả task — vẫn đúng "mũ đồng phục",
  nhận diện rõ bảo vệ, chấp nhận được.
- Tay trái hình f0 của Bảo Vệ giơ ngang vai (nắm đấm) — đung đưa tay mạnh
  hơn các NPC vòng trước; vẫn trong nhịp đi bộ, không lỗi (giống tay f0
  của Nhân Viên Văn Phòng vòng 29 và Cư Dân vòng 28).
- Không sửa code, không export, không push trong vòng này (theo task);
  code + test do agent khác làm. File `.import` cho 14 file art mới chưa
  tạo — Godot sẽ tự sinh khi import, hoặc agent code tạo khi cần.
