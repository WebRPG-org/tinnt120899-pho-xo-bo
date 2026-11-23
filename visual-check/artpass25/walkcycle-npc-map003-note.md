# Artpass 25 — Walk-cycle NPC Map003 (Anh Ba + Chị Sáu)

Ngày: 23/11/2026. Quy trình vòng 18/22: ảnh đứng → trắng thành trong suốt
(flood fill từ biên qua pixel trắng min(R,G,B)≥235, feather r=1.5) → resize
cao 208px → sheet 6 khung → kiểm tra bằng mắt (không cắt frame ở bước này).

## Nhân vật

- **Anh Ba** — đàn ông trung niên, công nhân xưởng Khu Công Nhân: tóc đen
  ngắn, áo thun xanh dương đậm ngắn tay, quần dài tối màu, giày thể thao xám,
  mặt hiền. Ảnh đứng: `src/godot/art/char_anhba.png` (90×208, RGBA).
- **Chị Sáu** — phụ nữ trung niên khu công nhân: tóc đen búi thấp, áo bà ba
  xanh lá nhạt hoa nhỏ (cổ tàu, khuy bấm), quần đen, dép quai, mặt hiền.
  Ảnh đứng: `src/godot/art/char_chisau.png` (95×208, RGBA).

Tham chiếu phong cách: `src/godot/art/char_cotu.png` (112×208, RGBA).

## Prompt đã dùng

Ảnh đứng (mỗi người gen 1 lần, tham chiếu `char_cotu.png`):

> "Use this chibi character style as the exact reference. Create a single
> full-body chibi figure, front view, [mô tả nhân vật], same smiling face,
> same hand-drawn watercolor/gouache chibi style as the reference, full body
> visible head to shoes, no cropping, plain white background, no text, no
> background objects."

Walk-cycle sheet (mỗi người gen 1 lần, tham chiếu ảnh đứng vừa tạo):

> "Use this chibi character as the exact reference. Create a sprite sheet of
> exactly six full-body figures in a single horizontal row, evenly spaced,
> same character, same [clothes], same [hair], walking poses progressing
> through one walk cycle, front view, plain white background, no text. The six
> figures show consecutive walking poses of one walk cycle: legs alternating
> front and back, arms swinging naturally, same smiling face, same
> hand-drawn watercolor/gouache chibi style as the reference, full body
> visible head to shoes, no cropping, no extra figures, no background
> objects."
>
> - Anh Ba: "same dark blue worker t-shirt, same dark pants, same grey
>   sneakers, same short black hair"
> - Chị Sáu: "same light green floral ba ba shirt, same black pants, same
>   sandals, same black hair in a low bun"

## File

| File | Kích thước |
| --- | --- |
| `src/godot/art/char_anhba.png` | 90×208 RGBA |
| `src/godot/art/char_chisau.png` | 95×208 RGBA |
| `visual-check/artpass25/walkcycle-sheet-anhba.png` | 2736×912 RGB |
| `visual-check/artpass25/walkcycle-sheet-chisau.png` | 2736×912 RGB |

Bản thô gen ra còn lưu trong `visual-check/artpass25/` với tên
`media-generation-char-*.png` / `media-generation-walkcycle-sheet-*.png`.
Script xử lý ảnh đứng: `visual-check/artpass25/process_standing_map003.py`.
Script cắt frame (run chính dùng): `visual-check/artpass25/slice_walkcycle_npc_map003.py`.

## Kết quả kiểm tra bằng mắt

- **Sheet Anh Ba — ĐẠT, không cần gen lại.** Đúng 6 nhân vật, 1 hàng ngang
  cách đều, nền trắng trơn, không chữ. Cùng mặt/tóc ngắn đen, áo thun xanh
  dương đậm, quần tối, giày thể thao xám ở cả 6 hình. Chân tiến triển hợp lý
  (dang rộng ↔ bắt chéo ↔ khép), tay đung đưa tự nhiên. Toàn thân đủ, không
  cắt tay/chân.
- **Sheet Chị Sáu — ĐẠT, không cần gen lại.** Đúng 6 nhân vật, 1 hàng ngang
  cách đều, nền trắng trơn, không chữ. Cùng mặt, búi thấp, áo bà ba xanh lá
  hoa nhỏ, quần đen, dép quai ở cả 6 hình. Chân tiến triển hợp lý (sải rộng
  ↔ khép qua nhau), tay đung đưa. Toàn thân đủ, không cắt tay/chân.
- Ảnh đứng đã kiểm tra trên nền magenta sau khi xử lý trong suốt: không quầng
  trắng, toàn thân nguyên vẹn.

## Hạn chế còn lại

- Chỉ mặt trước (front view) — giống vòng 18/22, chưa có mặt sau/mặt nghiêng.
- f5 ≈ f0 ở cả 2 sheet (tư thế cuối chu kỳ gần giống tư thế đầu) — chấp nhận
  được như vòng 18/22, chu kỳ vẫn lặp mượt.
- Họa tiết hoa trên áo bà ba của Chị Sáu dao động nhẹ giữa các khung (đặc
  tính gen) — không ảnh hưởng nhận diện nhân vật.
- Chưa cắt frame (walk_anhba_f0..f5, walk_chisau_f0..f5) — run chính làm bằng
  `slice_walkcycle_npc_map003.py`.
