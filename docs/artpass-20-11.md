# Art Pass 20/11 — Sửa "xấu điên" (chủ chê link live 09:57)

## 1. Tự xem game thật (trước sửa)

Chụp bằng Chromium Playwright trên VM, bản build local = cùng code link live
(`visual-check/before-01..04.png`, 20/11 ~10:00):

| # | Xấu ở đâu | Bằng chứng ảnh |
|---|---|---|
| 1 | Map chỉ là dải hẹp ~150px trên cùng, ~85% màn hình là nền navy tối trống; nhân vật lơ lửng trong khoảng tối | before-01/02 |
| 2 | Nhân vật = đầu tròn + thân chữ nhật đặc màu, không mặt/tay chân/tóc/bóng, không animation; NPC đứng yên | before-02 |
| 3 | Chữ chồng chữ, tương phản thấp: HUD đè lên tile, nhãn map chữ nâu/đen trên nền navy gần như không đọc được; điện thoại mở ra NPC/dấu "!" xuyên qua lớp phủ | before-02/04 |
| 4 | Không có màn hình tiêu đề / nút Start — vào thẳng map | before-01 (= map luôn) |
| 5 | WASD chỉ nhận 1 lần bấm (`is_action_just_pressed`); giữ phím không đi liên tục | code `player.gd` cũ |

Nguyên nhân gốc: `project.godot` clear color navy `(0.09,0.12,0.16)`;
`IsoMap` chỉ vẽ đúng 12×9 ô, không nền mở rộng; không có Camera2D;
nhân vật/marker vẽ bằng code tối giản; HUD là text trần không nền.

## 2. So sánh với game đang vận hành (bảng rút gọn)

Nguồn: nghiên cứu `browser.search` (screenshot gameplay thật).

| Tiêu chí | Nadia | Gánh Phố | Stardew Valley | Cozy Grove / ACNH | Phố Xô Bồ trước sửa |
|---|---|---|---|---|---|
| Palette | Nhiệt đới bão hòa, cảnh vẽ riêng từng scene | Phố Việt rực rỡ, dù đỏ/biển vàng | Ấm, đất, ≤6–8 màu/sprite | Pastel mềm, highlight ấm / shadow lạnh | 1 tông vàng phẳng + nền navy |
| Nhân vật | Tỉ lệ thật, portrait lớn khi thoại | Chibi ~1:3, đầu to, có bóng | Pixel 16×32, walk cycle 4 frame, bóng ellipse | Chibi 3D đầu to, animation đầy đủ | HCN + đầu tròn, không tay chân |
| Tile/Map | Parallax map vẽ riêng, chi tiết dày | Mặt tiền shop chữ Việt thật, mỗi khu 1 bộ mặt | ~5.000 sprite, decor dày, không ô trống | Decor là gameplay | Kenney CC0, 2 atlas cho 18 map |
| HUD/UI | Menu MV tùy biến, điện thoại trong inventory | Bottom nav icon tròn, top bar tiền/giờ | Hộp gỗ 9-slice bo tròn | Trắng bo tròn lớn, NookPhone trung tâm | Text + nút mặc định Godot |
| Ánh sáng | Theo mood từng scene | Ngày/đêm + thời tiết thật | Golden hour, đèn vàng tối | Đổi từng giờ, 18h golden hour | Không có |
| Hiệu ứng | Hotspot twinkle | Mưa, pháo hoa, khói bếp | Mưa/tuyết, đom đóm | Bướm, sakura, sao băng | Chỉ ellipse mờ |

Kết luận: thua ở **3 thứ thấy trong 3 giây đầu: nhân vật placeholder,
một tông vàng phẳng, HUD mặc định** — sửa 3 thứ đó trước.

## 3. Đã sửa gì (file local, chưa push)

| # | Sửa | File |
|---|---|---|
| 1 | Camera2D follow player, zoom 1.6 (map lấp đầy viewport); nền đất mở rộng 41×37 ô (đất khô ấm 3 tông, có vệt đường mòn); clear color navy → đất ấm `#C7B38C` | `src/godot/main.gd`, `src/godot/scripts/iso_map.gd`, `src/godot/project.godot` |
| 2 | Nhân vật chibi Việt vẽ bằng code: mặt, mắt, miệng, tóc (ngắn/dài/búi/nón lá), tay chân, bóng đổ, animation đi (chân/tay đánh + nhún người), chớp mắt; người chơi có vòng vàng dưới chân; Bạn Thân đổi áo xanh lá để phân biệt áo xanh dương của người chơi | `src/godot/scripts/character_sprite.gd` (mới), `src/godot/player.gd`, `src/godot/scripts/marker.gd` |
| 3 | HUD trong panel giấy vàng ấm có viền; nút vàng bo tròn (1 theme chung); nhãn map có nền sáng + viền, nhãn cửa/góc chế tạo tách cao hơn 56px để không chồng nhãn NPC; điện thoại full màn hình 720×1280, nền đục (map không xuyên qua); toast có viền trắng | `src/godot/main.gd`, `src/godot/scripts/marker.gd` |
| 4 | Màn hình title "PHỐ XÔ BỒ" + nút "Bắt đầu chơi" + hướng dẫn phím; khóa input tới khi bấm Bắt đầu | `src/godot/main.gd` |
| 5 | Giữ phím đi liên tục: `is_action_pressed` thay `just_pressed`; `MOVE_TIME` 0.18 → 0.15s/ô (~6.7 ô/s, qua map 12 ô ~1.8s); click chuột đổi đúng tọa độ thế giới qua camera | `src/godot/player.gd`, `src/godot/main.gd` |

Test mới: `src/godot/tests/artpass_test.gd` — 16/16 PASS (title, camera,
giữ phím 3 ô <60 frame, điện thoại full màn hình, NPC có sprite).

## 4. Verify thật (VM, 20/11 ~11:10)

- `--check-only` 6 script sửa/mới: 0 lỗi.
- Scene Main 120 frame headless: exit 0, 0 ERROR.
- Regression: G1 selftest 419/419, G1 playtest 14/14, G3 playtest 95/95,
  toàn bộ G2 (87+56+37+78+92+102+66+155+91+69+123+37+71) PASS, **0 FAIL**.
- Export web: exit 0, pck 1.300.512 byte; http.server 200.
- Screenshot sau sửa bằng Chromium Playwright (bản build local):
  `visual-check/after-01..04.png` (title, map, di chuyển, điện thoại) +
  `visual-check/move-02/03-after-d/down.png` — **đi bằng phím + camera
  follow đã thấy bằng mắt thật trên trình duyệt** (người chơi đi xuống,
  map trượt theo, vòng vàng dưới chân rõ).

## 5. Còn xấu / chưa sửa được (thật lòng)

1. **Tile vẫn là Kenney CC0, 2 atlas cho 18 map** — Map003+ tái dùng tile
   Map001/002 nên các khu trông giống nhau; chưa có bộ decor Việt riêng
   (biển hiệu chữ Việt, dù đỏ, xe máy, dây điện). Cần 1 đợt vẽ atlas riêng
   từng khu — việc lớn, không làm kịp trong đợt này.
2. **Nhân vật vẽ bằng code, chưa phải sprite vẽ tay** — đã có mặt/tay/chân/
   animation nhưng vẫn là hình khối phẳng kiểu chibi đơn giản, chưa đạt độ
   chi tiết của Nadia/Gánh Phố (cần họa sĩ hoặc bộ sprite CC0 vẽ tay).
3. Nền đất mở rộng có vệt sọc chéo (pattern tone tối) — trông như đường mòn,
   chấp nhận được, chưa tinh chỉnh.
4. Hotspot ở rìa map có thể nằm ngoài màn hình, chỉ còn nhãn bị kẹp vào
   trong (camera đi theo người chơi sẽ đưa nó vào khi đi tới gần).

## 6. Buổi 2 (20/11 ~11:20) — overlay ngày/đêm + sửa nhãn chồng/cắt

- Overlay màu theo khung (`main.gd` `_daynight_color`/`_update_daynight`):
  Sáng trong suốt, Chiều vàng cam alpha 0.16, Tối xanh đậm alpha 0.30;
  CanvasLayer riêng layer 0, follow viewport, dưới HUD, không chặn click.
  Đo màu pixel thật trên screenshot: Sáng (189,168,130) → Chiều
  (197,170,124) ấm hơn → Tối (137,125,114) tối rõ. Test mới 7 check.
- Nhãn map: kẹp theo camera thật (`get_camera_2d`, không dùng canvas
  transform — lúc tạo marker transform chưa có camera nên kẹp sai),
  vẽ lại mỗi frame; nhãn NPC lẻ cao hơn 30px theo chẵn/lẻ (tile.x+tile.y);
  nhãn cửa/góc chế tạo lên -170; nhãn hotspot xuống dưới sao (+24).
  Đã sửa lỗi ưu tiên toán tử `%` (phải ngoặc `(x+y) % 2`).
- Verify: `--check-only` 0 lỗi; artpass test **23/23 PASS** (16 cũ + 7 mới);
  G1 selftest 419/419, G3 playtest 95/95, scene 120 frame exit 0, 0 ERROR;
  export web exit 0 (wasm 39.514.754 byte, pck 1.303.104 byte);
  screenshot Chromium local `after-02/03/04/05/06` 0 lỗi console — xem bằng
  mắt: map lấp đầy màn hình, nhãn không chồng/cắt, điện thoại full màn hình
  đục, Chiều/Tối đổi màu rõ.
- Đã push main + deploy lại gh-pages (xem commit/sync trong báo cáo deploy).
  Main `fefd8a27`; gh-pages `4319286e` (chi push lai pck 10 chunk +
  index.html — wasm giong y cu, SHA fc74679e, khong can push lai).
  Verify: giai ma chunk pck khop 100% byte (SHA becb748d); API GitHub
  doc remote index.html + pck/part-009.txt khong byte voi local;
  chay thu dung bo file gh-pages tren Chromium local (loader chunk):
  title + map + dien thoai hien dung, 0 loi console.
  Han che con lai: subagent khong mo duoc browser task nen chua tu mo
  link github.io that — can parent chay browser task kiem lan cuoi.
