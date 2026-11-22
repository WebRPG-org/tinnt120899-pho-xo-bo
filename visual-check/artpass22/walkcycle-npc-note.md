# Artpass 22 — Walk cycle 4 NPC (vòng 22)

Ngày: 2026-11-22. Chỉ làm art — không chạy Godot, không sửa code .gd, không push/deploy.
Quy trình y hệt vòng 18 (`visual-check/artpass18/walkcycle-note.md`).

## Nhân vật gốc (src/godot/art/)
| NPC | File gốc | Mô tả |
|-----|----------|-------|
| Cô Tư | `char_cotu.png` (112×208, RGBA) | Phụ nữ lớn tuổi, tóc đen búi, áo bà ba tím cài khuy bấm, quần tối màu, dép quai |
| Bạn Thân | `char_banthan.png` (134×208, RGBA) | Cô gái trẻ, tóc đen dài, áo thun xanh lá, quần jean xanh, giày thể thao trắng |
| Chị Lệ | `char_chile.png` (95×208, RGBA) | Phụ nữ, tóc đen dài buộc nơ cam, áo dài tay cam, tạp dề be có túi rau, váy nâu, dép |
| Anh Hải | `char_anhhai.png` (87×208, RGBA) | Thanh niên, tóc đen ngắn, mũ lưỡi trai xanh ngọc, áo polo teal, quần short tối, giày teal |

## Prompt đã dùng (mỗi NPC gen 1 lần duy nhất — đạt ngay, không cần gen lại)
Ảnh tham chiếu: file `char_*.png` gốc + text theo mẫu vòng 18 (đổi mô tả nhân
vật/quần áo/tóc cho khớp từng người):

> Use this chibi character as the exact reference. Create a sprite sheet of
> exactly six full-body figures in a single horizontal row, evenly spaced, same
> character, same [clothes], same [hair], walking poses progressing through one
> walk cycle, front view, plain white background, no text. The six figures show
> consecutive walking poses of one walk cycle: legs alternating front and back,
> arms swinging naturally, same [smiling face], same hand-drawn watercolor/
> gouache chibi style as the reference, full body visible head to shoes, no
> cropping, no extra figures, no background objects.

Cụ thể từng NPC:
- **Cô Tư:** "same purple traditional Vietnamese shirt with frog buttons, same
  dark pants, same sandals, same black hair in a bun"
- **Bạn Thân:** "same green t-shirt, same blue jeans, same white sneakers,
  same long black hair"
- **Chị Lệ:** "same orange long-sleeve shirt, same beige apron with pockets,
  same brown skirt, same sandals, same long black hair with orange ties"
- **Anh Hải:** "same teal cap, same teal polo shirt, same dark shorts, same
  teal sneakers, same short black hair"

## Sheet thô
- `walkcycle-sheet-cotu.png` / `-banthan` / `-chile` / `-anhhai` (bản copy PNG
  của file gen gốc `media-generation-walkcycle-sheet-*.webp` trong cùng thư mục)
- Kích thước: **2736×912 px** cả 4 sheet, RGB, nền trắng trơn (góc (254–255, 254–255, 254–255)).

## Kiểm tra bằng mắt (sheet gốc)
- ✅ Cả 4 sheet: đúng 6 nhân vật, 1 hàng ngang, cách đều, nền trắng trơn, không chữ.
- ✅ Cùng mặt / tóc / quần áo / giày ở cả 6 hình, phong cách watercolor khớp ảnh gốc.
- ✅ Tư thế chân tiến triển hợp lý, xen kẽ chạm đất ↔ bắt chéo (passing), tay
  đung đưa theo nhịp — không nhảy cóc. Đo khách quan: chênh lệch trung bình vùng
  chân giữa các frame liên tiếp 10–31 (thang 0–255), tức các tư thế thực sự khác nhau.
- ⚠️ Hạn chế nhỏ (chấp nhận được, xem mục Hạn chế): f5 ≈ f0 ở cả 4 NPC — chỉ có
  ~4–5 tư thế phân biệt rõ trong 6 frame; f5 lặp lại f0 nên vòng lặp khép kín
  mượt nhưng tư thế chạm đất bị giữ 2 frame liên tiếp ở điểm nối vòng (giống vòng 18).

## Xử lý (script tái chạy được)
`slice_walkcycle_npc.py` trong cùng thư mục này — cùng phương pháp vòng 18:
1. Chia sheet theo **khe trắng giữa các nhân vật** (column projection — tìm
   cột không có nội dung, cắt ở giữa khe), KHÔNG chia đều 1/6.
2. Mỗi lát crop theo bbox nội dung (+4px padding).
3. Trắng → trong suốt bằng **flood fill từ biên qua pixel trắng** (ngưỡng:
   min(R,G,B) ≥ 235 và max−min ≤ 18) + feather Gaussian blur r=1.5 — nhờ vậy
   phần trắng BÊN TRONG giày (được viền tối bao kín) vẫn giữ nguyên, không
   bị thủng lỗ.
4. Resize giữ tỉ lệ về cao 208px (khớp `char_*.png`).
5. Chuẩn hoá: mọi frame cùng canvas, nhân vật căn giữa ngang theo bbox để
   không bị trượt ngang khi chạy animation trong game.

## Frame đã xuất (src/godot/art/)
Tất cả RGBA, cao 208px, alpha 0–255. f0 = tư thế chạm đất đầu chu trình,
f5 ≈ f0 khép vòng lặp.

| Frame | Kích thước | Tư thế |
|-------|-----------|---------|
| `walk_cotu_f0.png` | 119×208 | Chạm đất, chân dạng rộng, tay đưa trước |
| `walk_cotu_f1.png` | 119×208 | Passing, chân bắt chéo, tay buông |
| `walk_cotu_f2.png` | 119×208 | Chạm đất, chân dạng rộng (đổi chân trước) |
| `walk_cotu_f3.png` | 119×208 | Passing, chân bắt chéo, tay đưa trước |
| `walk_cotu_f4.png` | 119×208 | Chạm đất, chân dạng rộng |
| `walk_cotu_f5.png` | 119×208 | Chạm đất ≈ f0 (khép vòng lặp) |
| `walk_banthan_f0.png` | 121×208 | Chạm đất, chân dạng rộng, tay đưa trước |
| `walk_banthan_f1.png` | 121×208 | Passing, chân bắt chéo, tay buông |
| `walk_banthan_f2.png` | 121×208 | Chạm đất, chân dạng rộng (đổi chân trước) |
| `walk_banthan_f3.png` | 121×208 | Passing, chân bắt chéo, tay đưa trước |
| `walk_banthan_f4.png` | 121×208 | Chạm đất, chân dạng rộng |
| `walk_banthan_f5.png` | 121×208 | Chạm đất ≈ f0 (khép vòng lặp) |
| `walk_chile_f0.png` | 123×208 | Chạm đất, chân dạng rộng, tay đưa trước |
| `walk_chile_f1.png` | 123×208 | Passing, chân bắt chéo, tay buông |
| `walk_chile_f2.png` | 123×208 | Chạm đất, chân dạng rộng (đổi chân trước) |
| `walk_chile_f3.png` | 123×208 | Passing, chân bắt chéo, tay đưa trước |
| `walk_chile_f4.png` | 123×208 | Chạm đất, chân dạng rộng |
| `walk_chile_f5.png` | 123×208 | Chạm đất ≈ f0 (khép vòng lặp) |
| `walk_anhhai_f0.png` | 124×208 | Chạm đất, chân dạng rộng, tay đưa trước |
| `walk_anhhai_f1.png` | 124×208 | Passing, chân bắt chéo, tay buông |
| `walk_anhhai_f2.png` | 124×208 | Chạm đất, chân dạng rộng (đổi chân trước) |
| `walk_anhhai_f3.png` | 124×208 | Passing, chân bắt chéo, tay đưa trước |
| `walk_anhhai_f4.png` | 124×208 | Chạm đất, chân dạng rộng |
| `walk_anhhai_f5.png` | 124×208 | Chạm đất ≈ f0 (khép vòng lặp) |

## Kiểm tra bằng mắt (frame đã xuất)
- Ảnh kiểm tra `walkcycle-check-magenta-{cotu,banthan,chile,anhhai}.png`
  (6 frame ghép trên nền magenta):
  ✅ không còn tay/chân bị cắt, không còn mảnh tóc nhân vật kề bên lọt vào,
  ✅ không có quầng trắng quanh nhân vật, ✅ giày trắng không bị thủng lỗ,
  ✅ nhân vật căn giữa nhất quán giữa các frame.
- Đọc riêng `walk_banthan_f0.png` phóng to: tay, chân, giày đầy đủ, viền sạch,
  khớp phong cách ảnh gốc.

## Hạn chế còn lại
- Chỉ có **mặt trước (front view)** — chưa có mặt sau / mặt nghiêng / đi sang
  trái-phải. Trong game hiện tại NPC di chuyển 4 hướng; đi lên/xuống/trái/phải
  vẫn dùng tạm bộ mặt trước này (hoặc flip ngang cho hướng ngược lại).
- Chỉ ~4–5 tư thế phân biệt rõ trong 6 frame (f5≈f0); chu trình đi vẫn đọc
  được nhưng chưa mượt bằng chu trình 6 tư thế hoàn toàn khác nhau.
- Chiều rộng frame sau chuẩn hoá khác nhau theo NPC (119/121/123/124px, rộng
  hơn `char_*.png` gốc do tư thế chân dạng rộng); điểm neo trong game nên dùng
  tâm đáy (feet center) thay vì góc trái-trên.
- Chưa nối vào code Godot (ngoài phạm vi task này): cần `AnimatedSprite2D` /
  `SpriteFrames` với 6 frame trên cho mỗi NPC, tốc độ gợi ý ~8–10 fps khi di chuyển.
