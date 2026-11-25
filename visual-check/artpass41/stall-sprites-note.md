# Artpass 41 — 3 sprite sạp chợ tách riêng (rau / trái cây / cá+thịt)

Ngày: 25/11/2026. Quy trình theo artpass39/40 (gen → tách nền → resize
đúng canvas → kiểm magenta / debug-white / zoom 3× / đo kích thước),
adapt cho sạp: KHÔNG dùng flood-fill trắng như NPC (sọc trắng mái hiên
sẽ bị ăn mất, và khoảng trống giữa mái–quầy là vùng nền KÍN mà flood
từ biên không bao giờ tới được).

## Hợp đồng canvas (theo task — không đổi)

Canvas 64×96, y=0 đỉnh, y=96 đáy = đáy quầy:
- y 0–33: HOÀN TOÀN TRONG SUỐT (code vẽ biển + chữ tiếng Việt lên trên).
- y 34–52: mái hiên sọc đỏ/trắng, mép dưới vỏ sò (nửa tròn).
- y 52–76: 2 cột chống gỗ mép trái/phải (x 2–6 và 58–62), giữa để trống;
  hàng hóa quanh y 62–76.
- y 76–96: quầy gỗ (mặt bàn + mặt trước có vân gỗ).
- Tuyệt đối không: chữ, biển hiệu, người, nền.

## Phương pháp (script `process_stalls_r41.py`)

1. **Gen nền xanh da trời trơn** (thay vì nền trắng như NPC) — để tách nền
   bằng khoảng cách màu tới màu nền góc ảnh mà KHÔNG ăn sọc trắng mái
   hiên. Nền gen ra gần như phẳng: góc ảnh lệch khỏi màu nền trung vị
   tối đa 9,4–12,1 (thang Euclid RGB); nội dung gần nền nhất (cá xám
   xanh, đá lạnh) cách ≥~50 nên ngưỡng tách 40 + ramp alpha mềm 30→50
   tách sạch, không ăn nội dung.
2. **Alpha mềm + nearest-fill RGB**: pixel trong suốt được tô màu từ
   pixel đục gần nhất trước khi resize LANCZOS → không quầng xanh ở mép.
3. **Re-layout 4 band** (vì tỉ lệ sạp gen ra ≠ 64:62, scale đều không
   bao giờ vừa đúng các vùng hợp đồng): cắt sạp thành 4 dải ngang theo
   nguồn rồi resize mỗi dải về đúng chiều cao hợp đồng — mái 18px
   (y34–52), khoảng trống cột 8px (y52–60), hàng hóa 16px (y60–76),
   quầy 20px (y76–96). Mỗi dải resize về rộng 64px nên cột chống
   (gần mép nguồn) rơi đúng x~3–5 và x~58–61.
   - Phát hiện band tự động: mái = hết dải hàng ngang đặc trước chuỗi
     hàng gần trống dài nhất (khoảng trống); hàng hóa = hàng đầu tiên
     sau mái có độ phủ >0,20 chiều rộng (cột đơn chỉ ~0,06); mặt quầy
     = hàng đầu tiên có tỉ lệ pixel nâu-gỗ >0,70 và trung bình phía
     dưới >0,70 (rổ mây chỉ tới ~0,57; mặt quầy 0,76–0,95).
   - Fallback khi không hàng nào đạt test nâu-gỗ: hàng đầu tiên giữ
     >0,90 chiều rộng đặc tới hết (cathit — quầy vàng nắng không đạt
     test nâu-gỗ).
   - Hai lỗi đã sửa trong lúc chạy script (ghi để không tái phạm):
     (a) lần đầu glob sai pattern nên không tìm thấy file thô;
     (b) phát hiện mặt quầy 2 lần thất bại vì hàng mép dưới thưa
     "đầu độc" test "đặc tới đáy" — sửa bằng cách cắt đáy ở hàng đặc
     cuối cùng (>0,85 chiều rộng) thay vì đáy bbox.

## Prompt đã dùng (mỗi sạp 1 prompt, flat illustration)

> "Flat illustration of a Vietnamese market [vegetable/fruit/fish and
> meat] stall, front view, centered, full stall visible from awning top
> to counter bottom, no cropping. A red and white vertically striped
> awning with a scalloped lower edge at the very top, two thin wooden
> posts at the left and right edges below the awning, a wooden counter
> with visible wood grain at the bottom. On the counter: [hàng hóa].
> No people, no text, no signboard, no sign, no price tags, no
> background objects, plain solid sky-blue background. Warm Vietnamese
> market palette: warm yellow, red tile red, golden sunlight, wood
> brown. Hand-drawn flat illustration style, clean shapes, no
> photorealism."
>
> - rau: "woven baskets full of fresh green vegetables — cabbage,
>   leafy greens, herbs, water spinach"
> - traicay: "piles of colorful fruit — oranges, bananas, mangoes,
>   dragon fruit"
> - cathit: "fresh whole fish laid on crushed white ice on the left
>   side and red meat cuts on a wooden chopping board on the right side"

## Từng sprite

### 1. Sạp rau — `src/godot/art/stall_rau.png` — ĐẠT, gen 0 lần lại

- Nguồn v1 (1280×1920, `media-generation-stall-rau-v1-0-871b09b3-….png`):
  mái sọc đỏ/trắng + mép vỏ sò, 2 cột gỗ, 4 rổ mây (bắp cải, rau lá,
  rau thơm, rau muống), quầy gỗ vân rõ, không người/chữ/biển. Dùng ngay.
- Band nguồn: mái y183–699, khoảng trống y700–1109, hàng y1110–1451,
  quầy y1452–1766. (Lần chạy script đầu phát hiện sai mặt quầy ở y1233
  vì rổ cũng đặc ngang — đã sửa bằng test nâu-gỗ, xem trên.)
- Zoom 3×: 4 rổ mây nâu thấy rõ, rau xanh 4 loại phân biệt được, dải
  mặt bàn vàng giữa rổ và mặt quầy còn nguyên.

### 2. Sạp trái cây — `src/godot/art/stall_traicay.png` — ĐẠT, gen lại 1 lần

- **v1 LOẠI** (`media-generation-stall-traicay-v1-0-bf5d1f90-….png`,
  1920×1280): nội dung đủ (cam, chuối, xoài, thanh long) nhưng mái
  hiên bị cắt ở mép trên khung hình và mặt quầy bị cắt ở mép dưới —
  vi phạm "full stall visible, no cropping", không sửa được bằng cắt
  ghép (phần bị cắt không tồn tại).
- **v2 DÙNG** (`media-generation-stall-traicay-v2-0-fdc4c66e-….png`,
  1920×1280): gen lại với câu siết "ENTIRE stall fully inside the
  frame with a clear margin on all four sides, top edge of awning and
  bottom edge of counter fully visible, not cropped" — đủ lề 4 phía,
  cam/chuối/xoài/thanh long đủ cả.
- Band nguồn: mái y75–454, khoảng trống y455–662, hàng y663–843,
  quầy y844–1198.
- Zoom 3×: đống cam trái, 2 nải chuối, 3 xoài, 3 thanh long hồng đều
  đọc được; mái + cột + quầy đúng vị trí.

### 3. Sạp cá + thịt — `src/godot/art/stall_cathit.png` — ĐẠT, gen 0 lần lại

- Nguồn v1 (1920×1280, `media-generation-stall-cathit-v1-0-eb510209-….png`):
  6 cá tươi trên đống đá lạnh bên trái, miếng thịt đỏ trên thớt gỗ
  bên phải, mái sọc + cột + quầy vàng nắng, không người/chữ/biển.
  Dùng ngay.
- Band nguồn: mái y84–457, khoảng trống y458–725, hàng y726–930,
  quầy y931–1208 (fallback đặc-ngang, vì quầy vàng nắng không đạt
  test nâu-gỗ — mặt bàn vàng nằm trong band quầy, đúng ý đồ).
- Zoom 3×: 6 cá (thân xám xanh, vây vàng) nằm trên đá trắng đọc được;
  thịt đỏ 7–8 miếng trên thớt nâu đọc rõ; quầy có mặt bàn vàng nắng.

## Kết quả kiểm tra (đo trên file đích, script in ra)

| File | Kích thước | Mode | Bytes |
| --- | --- | --- | --- |
| `src/godot/art/stall_rau.png` | 64×96 | RGBA | 9.068 |
| `src/godot/art/stall_traicay.png` | 64×96 | RGBA | 8.087 |
| `src/godot/art/stall_cathit.png` | 64×96 | RGBA | 9.754 |

- **y 0–33: 0 pixel đục** ở cả 3 file (vùng biển hiệu sạch hoàn toàn).
- **Cột chống ở y=56: x 3–5 và 58–61** (rau/traicay), x 3–4 và 59–61
  (cathit) — đúng hợp đồng x 2–6 / 58–62.
- **Nền magenta** (`stall-{rau,traicay,cathit}-magenta.png`, xem thêm
  `zoom-stall-{...}.png` 3×): không còn nền lạ, không quầng xanh ở
  mép, thân sạp nguyên vẹn, không lệch tâm.
- **Debug-white** (`debug-white-stall-{...}.png`, pixel gần-trắng
  min(R,G,B)≥235 tô đỏ): rau 236px, traicay 256px, cathit 314px —
  TẤT CẢ đều là nội dung hợp lệ (sọc trắng mái hiên; cathit thêm
  35px đá lạnh ở band hàng + vài px mép đá ở band khoảng trống/quầy).
  Không có vùng trắng kín lạc nào ngoài thân sạp.
- **Mảnh vụn rời:** mỗi sprite đúng **1 component alpha duy nhất**
  (rau 3.282px, traicay 3.101px, cathit 3.051px) — không còn mảnh rời.
- **Không chữ / không người / không biển** ở cả 3 file (kiểm bằng mắt
  trên ảnh thô + zoom đích).

## Hạn chế còn lại

- Chỉ mặt trước (front view) — giống các vòng NPC trước.
- Ngọn rau lá / trái cây cao chạm tới y58–60 (đỉnh band hàng): hàng
  y=56 giữa vẫn trống chỉ có 2 cột, nhưng ngọn lá cao vượt lên trên
  y60 khoảng 2px — đó là ngọn hàng hóa thật, không phải nền sót.
- Cá ở cathit nhỏ ở tỉ lệ 1× trong game (đọc rõ ở zoom 3×, ở 1× chỉ
  còn là "cá trên đá"); chấp nhận vì canvas chỉ 64×96.
- Không sửa code, không test, không export, không push trong vòng này
  (theo task); import Godot + kiểm tra trong game do agent khác làm.
- LƯU Ý: trong cùng thư mục `visual-check/artpass41/` đã có sẵn file
  `check_r41.py` của một task song song (kiểm tra hàng sạp Map002
  trong game trên build local — KHÔNG phải của vòng này, không đụng tới).

## File

| File | Nội dung |
| --- | --- |
| `src/godot/art/stall_rau.png` / `stall_traicay.png` / `stall_cathit.png` | 3 sprite đích 64×96 RGBA |
| `visual-check/artpass41/stall_{rau,traicay,cathit}.png` | bản copy lưu hồ sơ |
| `visual-check/artpass41/media-generation-stall-{rau,traicay,cathit}-v*.png` | ảnh thô gen ra (+ v1 traicay bị loại) |
| `visual-check/artpass41/process_stalls_r41.py` | script tách nền + re-layout 4 band |
| `visual-check/artpass41/stall-{rau,traicay,cathit}-magenta.png` | kiểm nền magenta |
| `visual-check/artpass41/zoom-stall-{rau,traicay,cathit}.png` | zoom 3× trên nền magenta |
| `visual-check/artpass41/debug-white-stall-{rau,traicay,cathit}.png` | pixel gần-trắng tô đỏ |
| `visual-check/artpass41/check_r41.py` | KHÔNG phải của vòng này (task song song kiểm Map002) |
