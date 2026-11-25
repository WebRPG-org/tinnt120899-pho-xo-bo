# Artpass 42 — 3 sprite sạp chợ còn lại (bánh-mì / gia-vị / đồ-khô)

Ngày: 25/11/2026. Quy trình theo artpass41 (gen → tách nền → resize
đúng canvas → kiểm magenta / debug-white / zoom 3× / đo kích thước),
giữ nguyên script tách nền + re-layout 4 band (`process_stalls_r42.py`
= `process_stalls_r41.py` đổi thư mục + tên 3 sạp; không đổi logic).

Với 3 sạp này, cả 8 biển hiệu chợ Map002 đều có sprite (vòng 41: rau /
trái-cây / cá-thịt; vòng này: bánh-mì / gia-vị / đồ-khô).

## Hợp đồng canvas (theo task — không đổi)

Canvas 64×96, y=0 đỉnh, y=96 đáy = đáy quầy:
- y 0–33: HOÀN TOÀN TRONG SUỐT (code vẽ biển + chữ tiếng Việt lên trên).
- y 34–52: mái hiên sọc đỏ/trắng, mép dưới vỏ sò (nửa tròn).
- y 52–76: 2 cột chống gỗ mép trái/phải (x 2–6 và 58–62), giữa để trống;
  hàng hóa quanh y 62–76.
- y 76–96: quầy gỗ (mặt bàn + mặt trước có vân gỗ).
- Tuyệt đối không: chữ, biển hiệu, người, nền.

## Phương pháp (script `process_stalls_r42.py`, kế thừa vòng 41)

1. **Gen nền xanh da trời trơn** — tách nền bằng khoảng cách màu tới màu
   nền góc ảnh, KHÔNG flood-fill trắng (sọc trắng mái hiên phải sống,
   khoảng trống mái–quầy là vùng nền KÍN). Nền gen ra gần như phẳng:
   góc ảnh lệch khỏi màu nền trung vị tối đa 7,7–12,7 (thang Euclid RGB);
   ngưỡng tách 40 + ramp alpha mềm 30→50.
2. **Alpha mềm + nearest-fill RGB** trước khi resize LANCZOS → không
   quầng xanh ở mép (đo: 0 pixel mép bán-trong-suốt nào gần màu xanh
   da trời ở cả 3 file).
3. **Re-layout 4 band**: mái 18px (y34–52), khoảng trống cột 8px
   (y52–60), hàng hóa 16px (y60–76), quầy 20px (y76–96); phát hiện
   band tự động như vòng 41 (khoảng trống dài nhất / hàng rộng >0,20 /
   test nâu-gỗ, fallback đặc-ngang).
4. **Ảnh thô gen ra là .webp** (tool media trả về) — convert sang .png
   không nén mất dữ liệu trước khi chạy script (giữ cả 2 bản trong
   thư mục này).

## Prompt đã dùng (mỗi sạp 1 prompt, flat illustration)

Prompt gốc theo mẫu vòng 41 + câu siết lề của traicay v2 ("ENTIRE stall
fully inside the frame with a clear margin on all four sides, top edge
of awning and bottom edge of counter fully visible, not cropped"):

> "Flat illustration of a Vietnamese market [banh mi / spice / dried
> goods] stall, front view, centered, ENTIRE stall fully inside the
> frame with a clear margin on all four sides, top edge of awning and
> bottom edge of counter fully visible, not cropped. A red and white
> vertically striped awning with a scalloped lower edge at the very top,
> two thin wooden posts at the left and right edges below the awning, a
> wooden counter with visible wood grain at the bottom. On the counter:
> [hàng hóa]. No people, no text, no signboard, no sign, no price tags,
> no background objects, plain solid sky-blue background. Warm
> Vietnamese market palette: warm yellow, red tile red, golden sunlight,
> wood brown. Hand-drawn flat illustration style, clean shapes, no
> photorealism."
>
> - banhmi: "stacks of crispy golden banh mi baguettes with pork
>   sausage slices, pate and fresh herbs"
> - giavi: "neatly arranged glass jars of dried chili, garlic, purple
>   shallots, black pepper and small spice packets"
> - dokho: "dried squid, dried fish and dried shrimp hanging and stacked
>   on the counter, warm brown-gold tones"

Bản gen lại (v2) siết thêm 2 câu theo lỗi của v1:
- giavi v2: "The space between the awning and the counter is EMPTY
  plain solid sky-blue background, only the two wooden posts, no
  backdrop, no wall, no panel, no shelf behind the jars."
- dokho v2: "NOTHING hangs from the awning, nothing hangs in the air:
  the space between the awning and the counter is EMPTY plain solid
  sky-blue background, only the two wooden posts." + hàng đổi thành
  "stacked in woven baskets on the wooden counter".

## Từng sprite

### 1. Sạp bánh-mì — `src/godot/art/stall_banhmi.png` — ĐẠT, gen 0 lần lại

- Nguồn v1 (1920×1280, `media-generation-stall-banhmi-v1-0-1a42d7da-….png`):
  mái sọc đỏ/trắng + mép vỏ sò, 2 cột gỗ, 3 chồng bánh mì vàng giòn
  (chả lụa + pate + rau thơm), quầy gỗ vân rõ, không người/chữ/biển.
  Lề đủ 4 phía (bbox y65–1213, lề trên 65px / dưới 66px). Dùng ngay.
- Band nguồn: mái y65–457, khoảng trống y458–572, hàng y573–1000,
  quầy y1001–1212. Nền góc lệch tối đa 7,7.
- Zoom 3×: 3 chồng bánh mì + rau thơm đọc rõ, mái + cột + quầy đúng vị trí.

### 2. Sạp gia-vị — `src/godot/art/stall_giavi.png` — ĐẠT, gen lại 1 lần

- **v1 LOẠI** (`media-generation-stall-giavi-v1-0-778b9190-….png`,
  1920×1280): đủ 4 lọ (ớt khô, tỏi, hành tím, tiêu) + gói gia vị,
  nhưng có tấm nền VÀNG CAM đặc lấp kín khoảng trống mái–quầy (tường/
  backdrop) — nền không còn là xanh trơn, tách nền sẽ giữ tấm vàng
  lại thành khối đặc giữa sạp, vi phạm hợp đồng (khoảng trống chỉ có
  2 cột). Không sửa được bằng cắt ghép.
- **v2 DÙNG** (`media-generation-stall-giavi-v2-0-dc90f72d-….png`,
  1920×1280): gen lại với câu siết "khoảng trống EMPTY, no backdrop,
  no wall, no panel" — khoảng trống xanh trơn, 4 lọ thủy tinh (ớt đỏ,
  tỏi trắng, hành tím, tiêu đen) + 3 gói gia vị xếp ngay ngắn.
- Band nguồn: mái y0–331, khoảng trống y332–791, hàng y792–1026,
  quầy y1027–1279. Nền góc lệch tối đa 12,7.
- LƯU Ý về lề: v2 chạm mép trên + mép dưới khung (bbox y0–1279).
  Chấp nhận vì phần chạm mép là 2 cạnh THẲNG trùng đúng biên sprite
  (mép trên mái → y=34, đáy quầy → y=96): mép vỏ sò, sọc mái, lọ,
  mặt quầy đều còn nguyên vẹn, không mất nội dung nào. (Khác lỗi
  traicay v1 vòng 41 ở chỗ đó là cắt mất phần mái/quầy có hình.)
- Zoom 3×: 4 lọ phân biệt được màu (đỏ/trắng/tím/đen) + gói gia vị cam;
  mái + cột + quầy đúng vị trí.

### 3. Sạp đồ-khô — `src/godot/art/stall_dokho.png` — ĐẠT, gen lại 1 lần

- **v1 LOẠI** (`media-generation-stall-dokho-v1-0-4369e59c-….png`,
  1920×1280): mực/cá/tôm khô đủ cả nhưng TREO lủng lẳng từ mái hiên
  xuống gần quầy — hàng treo lấp kín khoảng trống mái–quầy, script
  không tìm được chuỗi hàng gần-trống dài (phát hiện band sẽ vỡ).
  Không sửa được bằng cắt ghép (treo dính liền mái).
- **v2 DÙNG** (`media-generation-stall-dokho-v2-0-860a49f5-….png`,
  1920×1280): gen lại với câu siết "NOTHING hangs from the awning" —
  mực/cá/tôm khô xếp trong 3 rổ mây trên quầy, khoảng trống xanh trơn
  chỉ có 2 cột.
- Band nguồn: mái y69–453, khoảng trống y454–939, hàng y940–1181,
  quầy y1182–1279. Nền góc lệch tối đa 8,7.
- LƯU Ý về lề: đáy quầy chạm mép dưới khung (bbox y69–1279, lề dưới
  0) — chấp nhận cùng lý do như giavi v2 (đáy quầy là cạnh thẳng
  trùng biên sprite y=96; mặt trước quầy còn nguyên).
- Zoom 3×: 3 rổ mây (mực trái, cá giữa, tôm phải) đọc rõ, tông nâu
  vàng đúng yêu cầu; mái + cột + quầy đúng vị trí.

## Kết quả kiểm tra (đo trên file đích, script `verify_r42.py` in ra)

| File | Kích thước | Mode | Bytes |
| --- | --- | --- | --- |
| `src/godot/art/stall_banhmi.png` | 64×96 | RGBA | 9.273 |
| `src/godot/art/stall_giavi.png` | 64×96 | RGBA | 7.857 |
| `src/godot/art/stall_dokho.png` | 64×96 | RGBA | 9.058 |

- **y 0–33: 0 pixel đục** ở cả 3 file (vùng biển hiệu sạch hoàn toàn).
- **Cột chống ở y=56:** banhmi x 2–4 / 59–61; giavi x 4–6 / 57–59;
  dokho x 4–5 / 58–59 — đúng hợp đồng x 2–6 / 58–62 (mép mờ
  alpha của giavi chạm x57, nhưng lõi cột alpha>128 là x5 + x58,
  nằm gọn trong hợp đồng).
- **Nền magenta** (`stall-{banhmi,giavi,dokho}-magenta.png`, xem thêm
  `zoom-stall-{...}.png` 3×): không còn nền lạ, không quầng xanh ở
  mép (đo: 0 pixel mép bán-trong-suốt nào gần màu xanh da trời),
  thân sạp nguyên vẹn, không lệch tâm.
- **Debug-white** (`debug-white-stall-{...}.png`, pixel gần-trắng
  min(R,G,B)≥235 tô đỏ): banhmi 268px, giavi 326px, dokho 193px —
  TẤT CẢ đều nằm trong band mái 34–52 (sọc trắng mái hiên); 0px ở
  các band biển/quảng cáo/hàng/quầy. Không có vùng trắng kín lạc
  nào ngoài thân sạp.
- **Mảnh vụn rời:** mỗi sprite đúng **1 component alpha duy nhất**
  (banhmi 3.271px, giavi 2.972px, dokho 3.087px) — không còn mảnh rời.
- **Không chữ / không người / không biển** ở cả 3 file (kiểm bằng mắt
  trên ảnh thô + zoom đích).

## Hạn chế còn lại

- Chỉ mặt trước (front view) — giống các vòng NPC/sạp trước.
- Giavi: lọ nhỏ ở tỉ lệ 1× trong game (đọc rõ ở zoom 3×, ở 1× chỉ còn
  là "4 lọ màu"); chấp nhận vì canvas chỉ 64×96.
- Giavi v2 + dokho v2 chạm mép khung trên/dưới ở ảnh thô (xem mục từng
  sprite) — đã kiểm chứng không mất nội dung, 2 cạnh chạm đều là cạnh
  thẳng trùng biên sprite.
- Không sửa code, không test, không export, không push trong vòng này
  (theo task); import Godot + kiểm tra trong game do agent khác làm.
- LƯU Ý: trong cùng thư mục `visual-check/artpass42/` đã có sẵn file
  `check_r42.py` của một task song song (kiểm tra 3 sạp mới trong game
  trên build local — KHÔNG phải của vòng này, không đụng tới). Script
  kiểm chứng của vòng này là `verify_r42.py`.

## File

| File | Nội dung |
| --- | --- |
| `src/godot/art/stall_banhmi.png` / `stall_giavi.png` / `stall_dokho.png` | 3 sprite đích 64×96 RGBA |
| `visual-check/artpass42/stall_{banhmi,giavi,dokho}.png` | bản copy lưu hồ sơ |
| `visual-check/artpass42/media-generation-stall-{banhmi,giavi,dokho}-v*.png` (+ `.webp` gốc) | ảnh thô gen ra (+ v1 giavi/dokho bị loại) |
| `visual-check/artpass42/process_stalls_r42.py` | script tách nền + re-layout 4 band |
| `visual-check/artpass42/verify_r42.py` | script đo kiểm chứng trên file đích |
| `visual-check/artpass42/stall-{banhmi,giavi,dokho}-magenta.png` | kiểm nền magenta |
| `visual-check/artpass42/zoom-stall-{banhmi,giavi,dokho}.png` | zoom 3× trên nền magenta |
| `visual-check/artpass42/debug-white-stall-{banhmi,giavi,dokho}.png` | pixel gần-trắng tô đỏ |
| `visual-check/artpass42/check_r42.py` | KHÔNG phải của vòng này (task song song kiểm trong game) |
