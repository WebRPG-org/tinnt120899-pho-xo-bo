# ground_map001 — artpass17 (22/11/2026)

Mục đích: thay ảnh chụp thật `ground_wide.jpg` (1440x900) bằng ảnh đất vẽ tay,
khớp phong cách mặt tiền nhà ống vàng cũ trong `visual-check/artpass16/r16-01-m1-spawn.png`.

## File cuối
- `/home/hatch/workspace/pho-xo-bo/src/godot/art/ground_map001.png`
- Kích thước: 1440x900 PNG, ~2,4 MB

## Prompt đã dùng (lần gen 1 — ĐẠT, không cần gen lại)
> Hand-painted watercolor and gouache ground texture, wide landscape view,
> slightly from above, of an old Vietnamese alley ground in warm daylight, in
> the same hand-painted style as an old yellow Vietnamese shophouse facade
> painting (soft watercolor washes, visible brush strokes, warm ochre and
> honey tones, gentle shadows). Composition: the top strip, about 15% of the
> height, is an old stone sidewalk made of worn rectangular grey-beige paving
> slabs with moss in the joints and a low step edge; below it, the rest of the
> frame is worn alley earth — warm brown packed dirt and old cracked paving
> stones, scattered fallen yellow leaves, patches of green moss, a few small
> shallow rain puddles reflecting warm sky light, thin cracks, sparse tufts of
> weeds. Flat ground surface only, seen from a slightly elevated angle.
> No people, no buildings, no houses, no shops, no vehicles, no signs, no
> text, no letters, no animals. Warm sunny daytime palette, painterly,
> no photorealism.

- Công cụ: `media.generate_image`, output PNG, snapshot
  `085e74f4-c59d-46a1-9d0d-3803d328867a:q6d362`
- File thô: `visual-check/artpass17/media-generation-ground-map001-0-2b4a1a91-93f1-40f4-9a1d-d25ccddcb93b.png`
  (1920x1280, 4,7 MB)

## Xử lý PIL
- Ảnh gốc 1920x1280 (tỉ lệ 1.5) → crop (0, 40, 1920, 1240) = 1920x1200
  (tỉ lệ 1.6, đúng tỉ lệ 1440x900, không bóp méo) → resize LANCZOS về 1440x900.
- Không sửa code, không chạy Godot, không push git (theo yêu cầu task).

## Tự kiểm (đã đọc lại file PNG cuối)
- [x] Đúng 1440x900
- [x] Mép trên là vỉa hè đá cũ lát tấm, có rêu ở khe + gờ bậc thấp
- [x] Phần dưới là đất hẻm vẽ tay: đất nâu ấm, đá lát nứt, lá vàng rơi,
      rêu, vũng nước nhỏ phản chiếu sáng, cỏ dại lưa thưa
- [x] Không người, không nhà/công trình, không chữ, không biển hiệu, không xe
- [x] Tông nắng ấm ban ngày, nét watercolor/gouache rõ — khớp mặt tiền
      nhà ống vàng cũ trong r16-01

## Lưu ý nhỏ
- Dải vỉa hè thực tế ~18% chiều cao (hơi hơn ~15% yêu cầu) — vẫn đúng bố cục,
  mép trên y=250 của Sprite2D cũ vẫn nằm trong vùng vỉa hè.
- Góc dưới-phải có vệt trắng nhạt kiểu mép giấy watercolor — rất mờ, không ảnh
  hưởng khi phủ dưới chân mặt tiền.
