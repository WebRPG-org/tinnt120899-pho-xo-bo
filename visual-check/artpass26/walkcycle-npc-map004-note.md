# Artpass 26 — Walk-cycle NPC Map004 (Bác Tài + Anh Bốc Vác)

Ngày: 23/11/2026. Quy trình vòng 18/22/25: ảnh đứng → trắng thành trong
suốt (flood fill từ biên qua pixel trắng min(R,G,B)≥235, feather r=1.5)
→ resize cao 208px → sheet 6 khung → kiểm tra bằng mắt → cắt frame bằng
script slice (khác vòng 25: cắt frame ngay trong vòng này, theo yêu cầu
task).

## Nhân vật

- **Bác Tài** — đàn ông lớn tuổi, tài xế xe khách Bến Xe Miền Đông: tóc
  đen điểm bạc ngắn, áo sơ mi xanh nhạt ngắn tay (đồng phục tài xế),
  quần dài tối màu, giày đen, mặt hiền. Ảnh đứng:
  `src/godot/art/char_bactai.png` (97×208, RGBA).
- **Anh Bốc Vác** — thanh niên khỏe mạnh, bốc vác ở bến xe: tóc đen ngắn,
  áo thun trắng ngắn tay, quần short tối màu, dép quai, khăn vắt vai,
  mặt hiền. Ảnh đứng: `src/godot/art/char_anhbocvac.png` (90×208,
  RGBA).

Tham chiếu phong cách: `src/godot/art/char_cotu.png` (112×208, RGBA).

## Prompt đã dùng

Ảnh đứng (mỗi người gen 1 lần, tham chiếu `char_cotu.png`):

> "Use this chibi character style as the exact reference. Create a single
> full-body chibi figure, front view, [mô tả nhân vật], same smiling face,
> same hand-drawn watercolor/gouache chibi style as the reference, full body
> visible head to shoes, no cropping, plain white background, no text, no
> background objects."

- Bác Tài: "an elderly Vietnamese man, a long-distance bus driver at a bus
  station, short black hair with grey streaks, light blue short-sleeve
  driver uniform shirt, dark long trousers, black shoes, kind smiling
  face"
- Anh Bốc Vác (lần 1): "a strong young Vietnamese man, a porter carrying
  luggage at a bus station, short black hair, plain white short-sleeve
  t-shirt, dark shorts, strap sandals, a towel draped over one shoulder,
  kind smiling face"
- Anh Bốc Vác (gen lại 1 lần — lần 1 gen thêm vali không có trong mô tả):
  "a strong young Vietnamese man, a porter at a bus station, short black
  hair, plain white short-sleeve t-shirt, dark shorts, strap sandals, a
  towel draped over one shoulder, kind smiling face, empty hands, no
  luggage, no suitcase, no bag" — bản v2 sạch, dùng làm ảnh đứng + tham
  chiếu sheet.

Walk-cycle sheet (tham chiếu ảnh đứng vừa tạo; prompt Vòng 25 + bổ sung
mô tả 6 pha chân khác nhau rõ rệt, vì sheet Bác Tài lần 1 bị 6 tư thế gần
như giống hệt nhau):

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
> - Bác Tài: "same light blue short-sleeve driver uniform shirt, same dark
>   long trousers, same black shoes, same short black hair with grey
>   streaks" — gen 2 lần (lần 1: 6 tư thế gần như giống hệt, không đạt;
>   lần 2: ĐẠT).
> - Anh Bốc Vác: "same plain white short-sleeve t-shirt, same dark shorts,
>   same strap sandals, same short black hair, same towel draped over one
>   shoulder" — gen 1 lần, ĐẠT.

## File

| File | Kích thước |
| --- | --- |
| `src/godot/art/char_bactai.png` | 97×208 RGBA |
| `src/godot/art/char_anhbocvac.png` | 90×208 RGBA |
| `src/godot/art/walk_bactai_f0.png` … `walk_bactai_f5.png` | 115×208 RGBA (canvas chung) |
| `src/godot/art/walk_anhbocvac_f0.png` … `walk_anhbocvac_f5.png` | 123×208 RGBA (canvas chung) |
| `visual-check/artpass26/walkcycle-sheet-bactai.png` | 2736×912 RGB |
| `visual-check/artpass26/walkcycle-sheet-anhbocvac.png` | 2736×912 RGB |

Bản thô gen ra còn lưu trong `visual-check/artpass26/` với tên
`media-generation-char-*.png` / `media-generation-walkcycle-sheet-*.png`
(bản lỗi: `media-generation-char-anhbocvac-0-*.png` lần 1 có vali,
`media-generation-walkcycle-sheet-bactai-0-*.png` lần 1 tư thế trùng nhau).
Script xử lý ảnh đứng: `visual-check/artpass26/process_standing_map004.py`.
Script cắt frame: `visual-check/artpass26/slice_walkcycle_npc_map004.py`.
Dải kiểm tra nền magenta: `walkcycle-check-magenta-{bactai,anhbocvac}.png`,
`char-{bactai,anhbocvac}-magenta.png`.

## Kết quả kiểm tra bằng mắt

- **Sheet Bác Tài (v2) — ĐẠT, gen lại 1 lần.** Đúng 6 nhân vật, 1 hàng
  ngang cách đều, nền trắng trơn, không chữ. Cùng mặt/tóc đen điểm bạc,
  áo sơ mi xanh nhạt, quần tối dài, giày đen ở cả 6 hình. Chân tiến triển
  rõ (dang rộng → bắt chéo → khép → dang rộng ngược → khép về tư thế đầu),
  tay đung đưa ngược pha chân. Toàn thân đủ, không cắt tay/chân. Lần 1
  KHÔNG ĐẠT: 6 tư thế chân gần như giống hệt nhau (đều sải giữa), chu kỳ
  sẽ bị trượt chân khi chạy.
- **Sheet Anh Bốc Vác — ĐẠT, không cần gen lại.** Đúng 6 nhân vật, 1 hàng
  ngang cách đều, nền trắng trơn, không chữ. Cùng mặt, tóc đen ngắn, áo
  thun trắng, quần short tối, dép quai, khăn vắt vai trái ở cả 6 hình.
  Chân tiến triển rõ (sải rộng ↔ bắt chéo ↔ khép), tay đung đưa. Toàn
  thân đủ, không cắt tay/chân.
- Ảnh đứng + frame đã kiểm tra trên nền magenta sau khi xử lý trong suốt:
  không quầng trắng, toàn thân nguyên vẹn, frame không lệch khỏi tâm
  canvas.

## Hạn chế còn lại

- Chỉ mặt trước (front view, thực tế gen ra dạng 3/4) — giống vòng
  18/22/25, chưa có mặt sau/mặt nghiêng.
- f5 của Bác Tài gần như tư thế đứng (chân khép) — chấp nhận được như
  vòng 18/22/25, chu kỳ vẫn lặp mượt; f5 ≈ tư thế khép về đầu chu kỳ.
- Khăn vắt vai của Anh Bốc Vác dao động nhẹ giữa các khung (đặc tính gen)
  — không ảnh hưởng nhận diện nhân vật.
- Kinh nghiệm vòng này: prompt sheet Vòng 25 chưa đủ ép 6 pha khác nhau
  (Bác Tài lần 1 trùng tư thế) — từ nay dùng luôn mô tả 6 pha rõ rệt
  trong prompt sheet.
