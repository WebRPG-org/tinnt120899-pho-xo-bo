# Artpass 18 — Walk cycle nhân vật người chơi (vòng 18)

Ngày: 2026-11-22. Chỉ làm art — không chạy Godot, không sửa code, không push.

## Nhân vật gốc
`src/godot/art/char_player.png` (106×208, RGBA) — chibi thanh niên Việt, tóc đen rối,
áo sơ mi xanh dương cài cúc, quần tối màu, giày thể thao trắng, phong cách vẽ tay
watercolor/gouache. Hiển thị cao 104px trong game.

## Prompt đã dùng (gen 1 lần duy nhất — đạt ngay, không cần gen lại)
Ảnh tham chiếu: `char_player.png` + text:

> Use this chibi character as the exact reference. Create a sprite sheet of
> exactly six full-body figures in a single horizontal row, evenly spaced, same
> character, same blue shirt, same dark pants, same white sneakers, same black
> messy hair, walking poses progressing through one walk cycle, front view,
> plain white background, no text. The six figures show consecutive walking
> poses of one walk cycle: legs alternating front and back, arms swinging
> naturally, same smiling face, same hand-drawn watercolor/gouache chibi style
> as the reference, full body visible head to shoes, no cropping, no extra
> figures, no background objects.

## Sheet thô
- `walkcycle-sheet-v1.png` (bản copy đặt tên gọn của file gen gốc
  `media-generation-walkcycle-sheet-v1-0-7d65c7c7-9b62-495e-b358-2c21e192f645.png`)
- Kích thước: **2736×912 px**, RGB, nền trắng trơn (góc (255,255,255)).

## Kiểm tra bằng mắt (sheet gốc)
- ✅ Đúng 6 nhân vật, 1 hàng ngang, cách đều, nền trắng trơn, không chữ.
- ✅ Cùng mặt / tóc đen rối / áo xanh / quần tối / giày trắng ở cả 6 hình,
  phong cách watercolor khớp ảnh gốc.
- ✅ Tư thế chân tiến triển hợp lý, xen kẽ: chân dạng rộng (chạm đất) ↔ chân
  bắt chéo (passing), tay đung đưa theo nhịp — không nhảy cóc.
- ⚠️ Hạn chế nhỏ (chấp nhận được, xem mục Hạn chế): f5 ≈ f0, f2 ≈ f4 — chỉ có
  ~4 tư thế phân biệt rõ trong 6 frame; f5 lặp lại f0 nên vòng lặp khép kín
  mượt nhưng tư thế chạm đất bên trái bị giữ 2 frame liên tiếp ở điểm nối vòng.

## Xử lý (script tái chạy được)
`slice_walkcycle.py` trong cùng thư mục này. Các bước:
1. Chia sheet theo **khe trắng giữa các nhân vật** (column projection — tìm
   cột không có nội dung, cắt ở giữa khe), KHÔNG chia đều 1/6: chia đều đã
   cắt mất bàn tay f0/f5 và để tóc nhân vật kề bên lọt vào f3/f4 (phát hiện
   nhờ ảnh kiểm tra nền magenta, đã sửa).
2. Mỗi lát crop theo bbox nội dung (+4px padding).
3. Trắng → trong suốt bằng **flood fill từ biên qua pixel trắng** (ngưỡng:
   min(R,G,B) ≥ 235 và max−min ≤ 18) + feather Gaussian blur r=1.5 — nhờ vậy
   phần trắng BÊN TRONG giày (được viền tối bao kín) vẫn giữ nguyên, không
   bị thủng lỗ.
4. Resize giữ tỉ lệ về cao 208px (khớp `char_player.png`).
5. Chuẩn hoá: mọi frame cùng canvas, nhân vật căn giữa ngang theo bbox để
   không bị trượt ngang khi chạy animation trong game.

## Frame đã xuất (src/godot/art/)
| Frame | Kích thước | Tư thế |
|-------|-----------|---------|
| `walk_player_f0.png` | 119×208 | Chạm đất, chân dạng rộng, tay gập đưa trước |
| `walk_player_f1.png` | 119×208 | Passing, chân bắt chéo, tay buông |
| `walk_player_f2.png` | 119×208 | Chạm đất, chân dạng rộng, tay đưa trước |
| `walk_player_f3.png` | 119×208 | Passing, chân bắt chéo, tay buông |
| `walk_player_f4.png` | 119×208 | Chạm đất, chân dạng rộng, tay đưa trước |
| `walk_player_f5.png` | 119×208 | Chạm đất ≈ f0 (khép vòng lặp) |

Tất cả RGBA, alpha 0–255. f0 = tư thế đứng/chân chạm đất đầu chu trình.

## Kiểm tra bằng mắt (frame đã xuất)
- Ảnh kiểm tra `walkcycle-check-magenta.png` (6 frame ghép trên nền magenta):
  ✅ không còn tay/chân bị cắt, không còn mảnh tóc nhân vật kề bên lọt vào,
  ✅ không có quầng trắng quanh nhân vật, ✅ giày trắng không bị thủng lỗ,
  ✅ nhân vật căn giữa nhất quán giữa các frame.
- Đọc riêng `walk_player_f0.png` phóng to: tay, chân, giày đầy đủ, viền sạch,
  khớp phong cách ảnh gốc.

## Hạn chế còn lại
- Chỉ có **mặt trước (front view)** — chưa có mặt sau / mặt nghiêng / đi sang
  trái-phải. Trong game hiện tại nhân vật di chuyển 4 hướng; đi lên/xuống/
  trái/phải vẫn dùng tạm bộ mặt trước này (hoặc flip ngang cho hướng ngược lại).
- Chỉ ~4 tư thế phân biệt rõ trong 6 frame (f5≈f0, f2≈f4); chu trình đi vẫn
  đọc được nhưng chưa mượt bằng chu trình 6 tư thế hoàn toàn khác nhau.
- Chiều rộng frame sau chuẩn hoá là 119px (rộng hơn `char_player.png` 106px)
  do tư thế chân dạng rộng; điểm neo trong game nên dùng tâm đáy (feet center)
  thay vì góc trái-trên.
- Chưa nối vào code Godot (ngoài phạm vi task này): cần `AnimatedSprite2D` /
  `SpriteFrames` với 6 frame trên, tốc độ gợi ý ~8–10 fps khi di chuyển.
