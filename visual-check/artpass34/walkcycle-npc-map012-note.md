# Artpass 34 — Walk-cycle NPC Map012 (Bảo Vệ Biệt Thự + Người Làm Vườn)

Ngày: 24/11/2026. Quy trình vòng 18/22/25/26/27/28/29/30/31/32/33: ảnh đứng →
trắng thành trong suốt (flood fill từ biên qua pixel trắng
min(R,G,B)≥235, feather r=1.5) → resize cao 208px → sheet 6 khung →
kiểm tra bằng mắt → cắt frame bằng script slice (cắt frame ngay trong
vòng này, như vòng 26/27/28/29/30/31/32/33).

Vị trí Map012 (Khu Biệt Thự Ven Sông): Bảo Vệ Biệt Thự ở ô (3,3); Người Làm
Vườn ở ô (8,6). Dữ liệu thật trong `src/godot/data/maps.json` (map id 12,
events kind npc).

## Nhân vật

- **Bảo Vệ Biệt Thự** — nam trung niên, bảo vệ biệt thự ven sông: áo sơ mi
  xanh đậm đồng phục bảo vệ, quần âu tối, giày da đen, đội mũ bảo vệ, cầm
  đèn pin. Ảnh đứng: `src/godot/art/char_baovebietthu.png` (91×208, RGBA).
  ID NPC `bao-ve-biet-thu` → frame dùng tiền tố `walk_baovebietthu_` (bỏ
  dấu gạch nối, theo quy tắc test).
- **Người Làm Vườn** — nam lớn tuổi, làm vườn biệt thự ven sông: áo thun màu
  be/kaki, quần dài tối, giày vải, đội nón lá, cầm kéo cắt cây + bình tưới
  nhỏ. Ảnh đứng: `src/godot/art/char_nguoilamvuon.png` (133×208, RGBA).
  ID NPC `nguoi-lam-vuon` → frame dùng tiền tố `walk_nguoilamvuon_`.

Tham chiếu phong cách: `src/godot/art/char_cotu.png` (112×208, RGBA).

## Prompt đã dùng

Ảnh đứng (mỗi người gen 1 lần, tham chiếu `char_cotu.png`):

> "Use this chibi character style as the exact reference. Create a single
> full-body chibi figure, front view, [mô tả nhân vật], same smiling face,
> same hand-drawn watercolor/gouache chibi style as the reference, full body
> visible head to shoes, no cropping, plain white background, no text, no
> background objects."

- Bảo Vệ Biệt Thự: "a middle-aged Vietnamese male villa security guard,
  dark blue security uniform shirt, dark trousers, black leather shoes,
  wearing a security guard cap, holding a flashlight"
- Người Làm Vườn: "an elderly Vietnamese male villa gardener, beige/khaki
  t-shirt, dark long trousers, cloth shoes, wearing a conical hat, holding
  pruning shears and a small watering can"

Walk-cycle sheet (tham chiếu ảnh đứng vừa tạo; prompt vòng 26/27/28/29/30/31/32/33 +
mô tả 6 pha chân khác nhau rõ rệt):

> "Use this chibi character as the exact reference. Create a sprite sheet
> of exactly six full-body figures in a single horizontal row, evenly
> spaced, same character, same [clothes], same [hair/hat], walking poses
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
> - Bảo Vệ Biệt Thự: "same dark blue security uniform shirt, same dark
>   trousers, same black leather shoes, same security guard cap, same
>   flashlight"
> - Người Làm Vườn: "same beige/khaki t-shirt, same dark long trousers,
>   same cloth shoes, same conical hat, same pruning shears and small
>   watering can"

Số lần gen lại: **0 cho cả 4 lần gen** (2 ảnh đứng + 2 sheet đều đạt ngay
lần đầu, không cần resume snapshot). Không gen lại ảnh nào; chỉ sửa script
xử lý (xem dưới).

## File

| File | Kích thước |
| --- | --- |
| `src/godot/art/char_baovebietthu.png` | 91×208 RGBA, 42.719 byte |
| `src/godot/art/char_nguoilamvuon.png` | 133×208 RGBA, 51.632 byte |
| `src/godot/art/walk_baovebietthu_f0.png` … `walk_baovebietthu_f5.png` | 154×208 RGBA (canvas chung), 43.167–52.160 byte |
| `src/godot/art/walk_nguoilamvuon_f0.png` … `walk_nguoilamvuon_f5.png` | 145×208 RGBA (canvas chung), 49.014–54.412 byte |
| `visual-check/artpass34/walkcycle-sheet-baovebietthu.png` | 2736×912 RGB, 2.116.690 byte |
| `visual-check/artpass34/walkcycle-sheet-nguoilamvuon.png` | 2736×912 RGB, 2.381.173 byte |

Bản thô gen ra còn lưu trong `visual-check/artpass34/` với tên
`media-generation-char-*.webp` / `media-generation-walkcycle-sheet-*.webp`
(pipeline media vòng này trả về `.webp`, như vòng 29/30/31/32/33; sheet
`.webp` đã chuyển sang `.png` cùng tên trước khi cắt frame). Tên file thô
do pipeline trả về có tiền tố dài `media-generation-media-generation-…`
và bị cắt ngắn tên stem — đã đổi tên về dạng chuẩn
`media-generation-char-{name}-0-*.webp` /
`media-generation-walkcycle-sheet-{name}-0-*.webp` để khớp glob của
script.
Script xử lý ảnh đứng: `visual-check/artpass34/process_standing_map012.py`.
Script cắt frame: `visual-check/artpass34/slice_walkcycle_npc_map012.py`.
Dải kiểm tra nền magenta: `walkcycle-check-magenta-{baovebietthu,nguoilamvuon}.png`,
`char-{baovebietthu,nguoilamvuon}-magenta.png`.
Debug vùng trắng kín: `debug-white-walk_{baovebietthu,nguoilamvuon}_f{0,4}.png`
(vùng trắng kín tô đỏ), `zoom-guard-f0-flashlight.png`,
`zoom-guard-char-flashlight.png`, `zoom-gardener-f0-legs.png` (phóng to 4×
trên nền magenta).

## Sửa script so với vòng 33

- `slice_walkcycle_npc_map012.py` — **HAI sửa mới (bài học vòng 34):**
  1. **Tách component quá rộng** (`split_wide_component`, `MAX_FIG_W` =
     600): sheet Người Làm Vườn lần đầu chỉ tìm được 5 hình — f2+f3 gộp
     thành 1 component rộng 913px (bbox x 922–1835) vì vành nón lá rộng
     (~450px/hình, khoảng cách hình ~456px) + tay giơ ngang cầm kéo/bình
     tưới chạm nhau trong không gian 2D. Component rộng hơn 600px được
     tách tại cột có mật độ pixel thấp nhất trong 40% giữa của bbox (lần
     này cắt tại x=1368, mật độ 40 pixel) rồi đệ quy nếu nửa còn quá rộng.
     Hình đơn rộng nhất các vòng trước ≤ ~520px nên ngưỡng 600 an toàn.
     Sau sửa: đúng 6 hình ngay lần đầu, không cần gen lại sheet. Sheet
     Bảo Vệ không có component quá rộng nên không đổi.
  2. **Xóa vùng trắng kín LỚN** (enclosed near-white): flood fill giữ trắng
     kín thành đục theo thiết kế, nhưng vòng này trắng kín là nền lọt qua
     vòng khép kín, không phải trang phục: vòng dây đèn pin Bảo Vệ
     (253–393 final px, f0/f2/f4), tam giác giữa hai chân Người Làm Vườn
     (959–995 final px, f0/f4 — bóng xám dưới chân nối hai giày, khép kín
     tam giác), khe tay–thân Người Làm Vườn (117–369 final px, f0/f4), tam
     giác giữa hai chân ảnh đứng Người Làm Vườn (~135 final px). Cả hai
     NPC đều không mặc đồ trắng nên vùng trắng kín ≥100 final px là nền và
     được xóa (đặt alpha=0 trước feather). Ngưỡng tính theo **final px**
     (số pixel × (208/chiều cao crop)²) — ngưỡng pixel thô sẽ sai vì crop
     sheet (~745px cao) và ảnh đứng (2080px cao) khác tỉ lệ rất nhiều.
     **Bẫy đã gặp:** bản đầu dùng ngưỡng 100 pixel thô đã xóa luôn thấu
     kính đèn pin (chỉ 16–21 final px, ~200–250 pixel thô) — zoom kiểm tra
     thấy lỗ magenta giữa đầu đèn pin, phải sửa lại ngưỡng theo final px.
     Sau sửa, thấu kính còn nguyên (16–21 final px/f0–f3), vòng quai bình
     tưới (≤55 final px) còn nguyên.
- `process_standing_map012.py` — chỉ đổi tên NPC/đường dẫn so với vòng 33
  + thêm bước xóa vùng trắng kín lớn như trên (ảnh đứng Người Làm Vườn xóa
  tam giác giữa hai chân ~135 final px; ảnh đứng Bảo Vệ không xóa gì).

## Godot import

- Chạy `tools/godot/Godot_v4.7.2-stable_linux.x86_64 --headless --import`
  (binary đúng là `Godot_v4.7.2-stable_linux.x86_64`, không có file
  `tools/godot/godot`), exit 0 — **đủ 14 file `.import`** cho 14 file art
  mới (2 char + 12 walk frame). Vòng 28 từng lỗi vì thiếu bước này.

## Kết quả kiểm tra bằng mắt

- **Ảnh đứng Bảo Vệ Biệt Thự — ĐẠT, không cần gen lại.** Nam trung niên,
  tóc đen điểm bạc hai bên thái dương, ria mép mờ, mũ bảo vệ xanh đậm có
  huy hiệu vàng hình khiên + vành da đen, áo sơ mi xanh đậm ngắn tay có cầu
  vai + huy hiệu ngực + túi ngực có cúc, quần âu tối, giày da đen bóng, đèn
  pin đen cầm tay phải (thấu kính sáng), nụ cười thân thiện, toàn thân đủ,
  nền trắng trơn, không chữ. (Chi tiết nhỏ: áo ngắn tay thay vì dài tay
  như mô tả gốc — vẫn đúng đồng phục bảo vệ, chấp nhận được.)
- **Ảnh đứng Người Làm Vườn — ĐẠT, không cần gen lại.** Nam lớn tuổi, tóc
  bạc + ria mép bạc, nón lá đan rõ vân, áo thun be/kaki cổ trụ 3 cúc, quần
  dài tối, giày vải nâu, kéo cắt cây tay phải, bình tưới xanh lá nhỏ tay
  trái, nụ cười hiền, toàn thân đủ, nền trắng trơn, không chữ. (Chi tiết
  nhỏ: bóng xám mờ dưới chân trong ảnh thô — sau flood fill chỉ còn vệt
  bóng xám nhạt tự nhiên dưới giày, chấp nhận được như vòng 32.)
- **Sheet Bảo Vệ Biệt Thự — ĐẠT, không cần gen lại.** Đúng 6 nhân vật,
  1 hàng ngang cách đều, nền trắng trơn (góc 255,255,255), không chữ. Cùng
  mặt, mũ, sơ mi xanh đậm + quần âu tối + giày da đen, đèn pin ở cả 6 hình.
  Chân tiến triển rõ (dang rộng → khép/bắt chéo → bắt chéo → khép → dang
  rộng ngược → khép về tư thế đầu), tay đung đưa ngược pha chân, đèn pin
  đổi tay theo nhịp đi (tay phải f0/f2/f4, tay trái f1/f3, hai tay f5 gần
  như đứng). Toàn thân đủ, không cắt tay/chân. Dây đèn pin thành vòng chữ
  U mảnh dưới tay — sau xử lý vòng dây trong suốt, nhìn đúng như dây đeo.
- **Sheet Người Làm Vườn — ĐẠT, không cần gen lại.** Đúng 6 nhân vật,
  1 hàng ngang cách đều, nền trắng trơn (góc 255,255,255), không chữ. Cùng
  mặt, râu bạc, nón lá, áo be/kaki, quần tối, giày vải nâu, kéo + bình
  tưới ở cả 6 hình. Chân tiến triển rõ (dang rộng → bắt chéo → khép → bắt
  chéo ngược → dang rộng ngược → khép về tư thế đầu), tay đung đưa ngược
  pha chân, kéo/bình tưới đổi tay theo nhịp đi. Toàn thân đủ, không cắt
  tay/chân. (Chi tiết nhỏ: f5 gần như tư thế đứng — chấp nhận được như các
  vòng trước.)
- Ảnh đứng + frame đã kiểm tra trên nền magenta sau khi xử lý trong suốt:
  không quầng trắng, toàn thân nguyên vẹn, frame không lệch khỏi tâm
  canvas. Sau bước xóa trắng kín: tam giác giữa chân f0/f4 Người Làm
  Vườn và vòng dây đèn pin f0/f2/f4 Bảo Vệ đều trong suốt đúng (magenta
  xuyên qua), thấu kính đèn pin còn nguyên (kiểm tra bằng zoom 4×).
  Đo bằng script: không còn component trắng kín ≥15 final px nào ngoài
  thấu kính đèn pin (16–21px) và vòng quai bình tưới (≤55px) — đều là chi
  tiết đạo cụ thật, giữ lại đúng.

## Hạn chế còn lại

- Chỉ mặt trước (front view, thực tế gen ra dạng 3/4) — giống các vòng
  trước, chưa có mặt sau/mặt nghiêng.
- f5 của cả hai gần như tư thế đứng (chân khép) — chấp nhận được như các
  vòng trước, chu kỳ vẫn lặp mượt; f5 ≈ tư thế khép về đầu chu kỳ.
- f2/f3/f4 của cả hai là 3 tư thế "chân bắt chéo/khép" khá gần nhau (khác
  nhau ở chân nào trước), không tách bạch bằng f0/f4 dang rộng — vẫn đủ
  phân biệt khi chạy.
- Đèn pin / kéo + bình tưới đổi tay (phải → trái → hai tay) qua các frame
  theo nhịp đung đưa — giống laptop/tablet vòng 32, sổ tay vòng 31, cờ
  tour vòng 33, không phải lỗi, là tay đung đưa ngược pha chân.
- Vòng dây đèn pin ở f0/f2/f4 Bảo Vệ: sau khi xóa trắng kín, dây thành
  vòng mảnh đen treo dưới tay — đọc đúng như dây đeo đèn pin, chấp nhận
  được; ở kích thước sprite trong game vòng dây chỉ vài pixel.
- Bóng xám mờ dưới chân còn lại ở các frame Người Làm Vườn (vệt xám nhạt,
  ~136–336 pixel xám nhạt/frame) — là bóng đổ tự nhiên dưới giày, không
  phải quầng trắng; chấp nhận được.
- Nón lá rộng làm hai hình kề nhau chạm nhau trong sheet (f2/f3) — đã xử
  lý bằng tách component quá rộng ở script (bài học vòng 34); vòng sau có
  NPC đội nón/mũ rộng hoặc giơ đạo cụ ngang thì dùng luôn script vòng 34.
- Ngưỡng xóa trắng kín (100 final px) chỉ đúng khi NPC không mặc đồ trắng
  — NPC nào có áo sơ mi trắng / đồ trắng thì KHÔNG được dùng bước này
  (sẽ thủng áo); ghi lại để vòng sau lưu ý.
- Không sửa code, không export, không push trong vòng này (theo task);
  code + test do agent khác làm.
