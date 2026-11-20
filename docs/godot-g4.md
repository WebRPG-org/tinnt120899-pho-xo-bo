# Godot G4 — Online thật + release (20/11/2026)

> **G3 đã được kiểm chứng bằng TRÌNH DUYỆT THẬT (20/11 ~09:50)** — lần đầu tiên
> kể từ G0: game Godot chạy được trên Chromium thật, đi được, chuyển map
> 2 chiều, mở điện thoại, đổi khung, 0 console error. Chi tiết §1.
> Việc tiếp theo: online thật (§2) + release (§3) + scene trận MarketBattle (§4 — XONG 20/11 ~11:00, xem §5 việc tiếp theo).

## 1. Browser-verify G3 — XONG 20/11 ~09:50

### 1.1 Cách kiểm chứng (làm thật, không dùng Muse browser)

- Build kiểm chứng: `src/godot-build/` export 20/11 ~08:45 (G3 đủ 18 khu),
  `index.pck` 1.288.892 byte, `index.wasm` 39.514.754 byte — **không export
  lại**, build này đã chứa đủ 18 khu.
- Serve: `python3 -m http.server 8160 --bind 127.0.0.1` trong
  `src/godot-build/` — `index.html`/`index.wasm`/`index.pck` đều 200.
- Trình duyệt: Playwright Chromium 1255 headless trên VM này
  (`~/.cache/ms-playwright/chromium-1255/chrome-linux64/chrome`),
  cờ `--enable-unsafe-swiftshader --use-angle=swiftshader` (WebGL2 phần mềm),
  viewport 720×1280 đúng khung game.
- Script kiểm chứng (giữ trong goal hidden_files, tái chạy được):
  `~/workspace/goals/ph-x-b-vietnamese-2-5d-social-simulation-game/hidden_files/pxb-browser-verify.py`
  (vòng 1: tải + WASD), `pxb-browser-verify2.py` (vòng 2: mũi tên + P + F),
  `pxb-browser-verify3.py` (vòng 3: chuyển map đúng cửa).
- Ảnh chụp + log console: cùng thư mục trên,
  `pxb-browser-verify-2026-11-20/` (`01–10` PNG + `console*.json`).

### 1.2 Kết quả — đều PASS, có ảnh chụp làm bằng chứng

| Kiểm tra | Kết quả |
|---|---|
| WebGL2 | Có: `WebGL 2.0 (OpenGL ES 3.0 Chromium)` |
| Engine khởi động | Canvas 720×1280 sau ~5s; log `Godot Engine v4.7.2.stable.official`, `single-threaded` |
| Console / pageerror | **0 error, 0 pageerror** trong cả 3 vòng |
| Scene Map001 vẽ được | Có: tile atlas nhà trọ, NPC Bạn Thân (xanh) / Cô Tư (tím), Góc Chế Tạo, cửa, hotspot kim cương vàng, nhãn event — ảnh `02-scene.png` |
| HUD | Có: `Phố Xô Bồ — Xóm Trọ Cũ`, `Ngày 1 • Khung Sáng`, `Túi: trống`, `Ví: 0đ • EXP 0`, `Thể 100 • Trí 100 • Tâm 100`, 3 nút `Đổi khung (F)` / `Việc làm` / `Điện thoại (P)` |
| Di chuyển bằng mũi tên | **Có** (vòng 2): player áo xanh lá đi từ (4,5) → (5,8) sau 4 lần bấm, đúng chiếu iso; ảnh `05-before.png` → `06-transfer.png` |
| Mở điện thoại (phím P) | **Có**: panel 9 tab đúng thứ tự (Danh bạ/Tin nhắn, Ngân hàng, Bản đồ, Việc làm, Chợ, Học tập, Sức khỏe, Xã hội, Cài đặt), nội dung `Bạn thân — BestFriend, thân thiết 20/100 (QuenBiet)`, nút `Trò chuyện: Bạn thân` / `Đóng điện thoại`; bấm P lần 2 đóng lại — ảnh `07-phone.png` |
| Đổi khung (phím F) | **Có**: `Ngày 1 • Khung Sáng` → `Ngày 1 • Khung Chiều` + toast `Ngày 1 • Khung Chiều` — ảnh `08-frame.png` |
| Chuyển map Map001 → Map002 | **Có** (vòng 3): phải 1 + lên 1 bước lên cửa (5,4) `Cửa ra Chợ Đầu Mối` → title `Phố Xô Bồ — Chợ Đầu Mối` + toast `Đã sang Chợ Đầu Mối`; Map002 vẽ khác hẳn Map001 (đường nhựa, NPC Chị Lệ cam / Anh Hải xanh ngọc, cửa (5,8) đi Khu Công Nhân, hotspot 2 ô) — ảnh `09-transfer-map2.png` |
| Chuyển ngược Map002 → Map001 | **Có**: lên 1 + xuống 1 chạm cửa (5,4) → title `Xóm Trọ Cũ` + toast `Đã sang Xóm Trọ Cũ`, player spawn đúng cửa (5,4) — ảnh `10-back-map1.png` |

### 1.3 Hai lỗi SUÝT kết luận sai — ghi để không tái phạm

1. **Vòng 1 bấm D/S không di chuyển — không phải lỗi game.** `player.gd`
   chỉ nghe `ui_up/down/left/right` (mặc định = phím mũi tên), không bind
   WASD. G0 doc ghi "WASD/mũi tên" là sai so với code hiện tại: chỉ mũi tên
   mới đi được. Sửa test (vòng 2 dùng mũi tên) thì đi được ngay.
2. **Vòng 2 đi 4 bước không chuyển map — không phải lỗi game.** Cửa Map001
   → Map002 ở ô **(5,4)**, không phải (5,8) — (5,8) là cửa Map002 → Map003.
   Người kiểm chứng đọc nhầm số ô. Sửa test (vòng 3: phải + lên) thì
   chuyển map ngay, 2 chiều.

### 1.4 Phát hiện khi xem ảnh thật (không chặn release, ghi cho G4 polish)

1. **HUD chìm vào tile:** 5 dòng HUD trái + 3 nút phải nằm đè lên vùng map
   (map vẽ từ y=0), chữ tối trên nền tile sáng/màu — đọc được nhưng rối,
   nhất là dòng `Thể 100 • Trí 100 • Tâm 100` và nhãn event `Bạn Thân` /
   `Cửa ra Chợ Đầu Mối` chồng nhau. Cần nền mờ / bóng chữ cho HUD + nhãn.
2. **Map chỉ chiếm ~35% chiều cao màn hình:** map 12×9 ở tile 64×32 vẽ
   xong ở khoảng y=0–500 trên viewport 720×1280, dưới là nền tối trống.
   Trên điện thoại thật sẽ thấy thưa — cần camera zoom (vd zoom 2× theo
   player) hoặc tile lớn hơn khi trình bày dọc.
3. **Nhãn event chồng lấn:** `Cô Tư` bị cửa che một nửa ở ảnh `10`; các
   nhãn NPC/cửa/hotspot gần nhau đè lên nhau. Cần chống chồng lấn khi vẽ
   nhãn (dịch lên / ẩn bớt).
4. Tile Map003–018 tái dùng tile nhà trọ vẫn là PROVISIONAL (đã biết từ G3).

### 1.5 Verify headless kèm theo đợt này (cây code không đổi từ export 08:45)

| Kiểm tra | Kết quả |
|---|---|
| `--check-only --script main.gd` | exit 0 |
| `--headless --quit-after 120` | exit 0, không ERROR/warning |
| HTTP 200 (cổng 8160) | `index.html` / `index.wasm` / `index.pck` |

## 2. G4 — Online thật

- `PxbOnline` hiện chỉ có health/balance/gift qua endpoint .NET thật;
  trade/đấu giá/công ty vẫn `server-chua-co-endpoint`.
- Server `.NET 8` đã có trong `src/server/` (`EconomyLedger.cs`,
  endpoint `/ledger/balance` + `/ledger/gift`) nhưng **VM này không có
  dotnet SDK nên không build/chạy/verify được server** — viết endpoint
  mới mà không biên dịch được là nợ chưa verify; chỉ viết khi có máy
  dotnet hoặc khi chủ chốt dùng Godot headless dedicated server thay cho
  .NET (quyết sau, xem `docs/opensource-engine.md` §3.4).
- Trước mắt: giữ chơi ngoại tuyến + save local 3 slot (đã có), online
  chỉ báo đúng trạng thái (`_check_online` đã báo offline thật).

## 3. G4 — Release

- Build web mới nhất ở `src/godot-build/` (đã đồng bộ sang `godot-build/`
  ở root repo làm bản chơi local). `gh-pages-staging/` chứa bản split cũ
  (bản MV) — **kiểm tra lại trước khi deploy gh-pages**, không deploy nhầm.
- Repo vẫn private, GitHub Pages chưa bật — **chờ chủ** bật Pages + chọn
  Source `gh-pages` / root thì link `tinnt120899.github.io/pho-xo-bo/`
  mới chạy bản Godot (wasm single-threaded, không cần COOP/COEP).
- Khi deploy: `src/godot-build/` → root `gh-pages` (không phải
  `godot-play-single.html` — đó là bản MV cũ).

## 4. Scene trận MarketBattle (UI) — XONG (G4 bước 1, 20/11 ~11:00)

- Luật ĐÃ CHỐT 20/11 06:06, logic `scripts/pxb_marketbattle.gd` + test
  123/123 đã xong (G2). Scene nay đã có: `scripts/battle_scene.gd`
  (class `BattleScene`, Node2D trên CanvasLayer layer 2 — trên HUD,
  không bị camera zoom 1.6 kéo theo) + 2 test mới.
- Vẽ: lưới 12×9 isometric (cùng công thức `IsoMap`, tâm (360,560)),
  ô di chuyển xanh lá, địch trong tầm viền đỏ, đấu sĩ = vòng tròn
  màu vai + thanh HP + tên (lệch theo chẵn/lẻ x, vẽ 2 lượt để tên
  không bị vòng tròn đè), vòng vàng + mũi tên chỉ lượt đi; HUD trận:
  tỉ số % HP 2 đội, vòng x/12, lượt còn xs (≤3s đỏ), trận còn m:ss;
  panel dưới: lượt ai/vai/vũ khí/tầm, gợi ý chạm, dòng log hành động,
  nút "Kết thúc lượt" + "Đóng (B)"; hết trận hiện panel kết quả
  (thắng/hòa, Danh vọng mỗi đội, giữ sạp đến ngày game mấy).
- Chạm/chuột: ô xanh = di chuyển (1 lần/lượt), địch trong tầm = đánh,
  Vàng chạm đồng đội kề = hỗ trợ +12 HP, chạm đấu sĩ mình = xem;
  đồng hồ lượt 10s tự chuyển lượt, đồng hồ trận 180s kết thúc bằng
  % HP — đều gọi thẳng `PxbMarketBattle`, không sửa luật.
- Nối vào Main: phím **B** mở/đóng trận demo 3v3 (Đội Bạn: Bạn Tank/
  Chảo, Bạn Thân Chiến thuật/Cá khô, Cô Tư Hỗ trợ/Loa — vs Đội Chợ
  Đầu Mối seed NPC; tranh sạp `sap-cho-dau-moi`, đội chợ đang giữ).
  Khi mở: khóa input map, ẩn HUD (`_ui_layer`); khi đóng: trả lại.
  Gợi ý phím B đã thêm vào màn hình title.
- Verify thật đợt này (20/11 ~10:55–11:00): test scene **43/43
  PASS** (di chuyển 13 ô đúng tầm 3, đánh Tank −9 HP đúng luật,
  hỗ trợ +12 HP, nút, hết 10s tự chuyển lượt, hết 180s hòa khi
  100%–100%, hòa không giữ sạp); test nối Main **15/15 PASS**
  (phím B mở/đóng thật, khóa/mở input, ẩn/hiện HUD, đồng hồ thật
  tự chuyển lượt sau 11s); regression G2 MarketBattle 123/123,
  G1 419/419, G3 95/95, G2 selftest 87/87 (không regression);
  `--check-only` 4 file mới/sửa đều exit 0; scene Main 120 frame
  exit 0; export web exit 0 (wasm SHA không đổi `fc74679e…`,
  pck mới `964beb1a…`, chứa `res://scripts/battle_scene.gd`);
  HTTP 200 đủ 6 file (cổng 8163), `GODOT_THREADS_ENABLED = false`.
- **Browser-verify thật (Chromium 1255 + swiftshader, 720×1280):**
  build mới chạy được, bấm B mở trận, lưới + đấu sĩ + HUD + 2 nút
  vẽ đúng như thiết kế, 0 console error, 0 pageerror — ảnh
  `hidden_files/pxb-browser-verify-2026-11-20/13-battle-open.png`
  (script tái chạy: `hidden_files/pxb-browser-verify-battle.py`).
  2 lỗi vẽ tìm được trên ảnh thật và đã sửa: (1) dòng gợi ý tràn
  khỏi panel → rút ngắn; (2) tên đấu sĩ chéo nhau đè lên nhau →
  lệch theo chẵn/lẻ x + vẽ tên sau vòng tròn (2 lượt vẽ).
- Chưa làm: animation di chuyển/đánh (đấu sĩ nhảy ô tức thì); chọn
  đội/vũ khí trước trận; lưu giữ sạp + Danh vọng vào save (logic
  `PxbMarketBattle.data()` đã có, Main chưa nối vào SaveCloud);
  deploy gh-pages bản mới (wasm không đổi nên chỉ cần push lại pck
  chunk + index.html — LƯU Ý: pck mới 4.204.080 byte, gấp ~3 lần
  bản 11:00 (1.352.664 byte), do export lần này đóng gói cả
  `.godot/imported/*.ctex` + art gốc; deploy sẽ nặng hơn).
  AI lượt địch ĐÃ XONG (G4 bước 2, xem §5.1).

## 5. Việc tiếp theo — G4 bước 2

### 5.1 AI lượt địch — XONG (G4 bước 2, 20/11 ~12:00)

- Logic lõi `PxbMarketBattle.ai_take_turn(battle, fighter_id)` (mới,
  `scripts/pxb_marketbattle.gd`): xác định, không ngẫu nhiên, KHÔNG
  sửa luật — chỉ gọi `move_fighter` / `attack` / `support` /
  `end_turn` có sẵn. Thứ tự: (1) Vàng hỗ trợ đồng đội kề bên thiếu
  HP nhất; (2) đánh địch trong tầm vũ khí, ưu tiên ít HP nhất (hòa
  thì id nhỏ); (3) chưa hành động thì đi tới ô trong tầm di chuyển
  gần địch gần nhất nhất (chỉ đi khi gần hơn vị trí hiện tại; hòa
  thì x nhỏ, rồi y nhỏ); (4) sau khi đi, đánh nếu có địch vào tầm;
  (5) kết thúc lượt. Trả `{ok, actions: [chuỗi mô tả], ended}`.
- Scene `BattleScene` (`scripts/battle_scene.gd`): `ai_enabled`
  (mặc định **tắt** — test cũ không đổi hành vi), `ai_team = "B"`,
  `AI_ACT_DELAY = 1,2s` (đợi đầu lượt địch để người chơi kịp thấy
  lượt chuyển sang ai). Khi tới lượt đội AI: đợi đủ delay rồi chạy
  1 lượt AI, ghi hành động vào dòng log dưới panel; gợi ý dưới
  panel đổi thành "Đội Chợ đang đi…" khi tới lượt AI. `Main`
  (`_start_battle_demo`) bật `ai_enabled = true` khi mở trận demo.
- Test mới `tests/g4_battle_ai_test.gd`: **34/34 PASS** — đánh trong
  tầm (Chảo 12 → Tank −9 HP đúng luật), đi tới (6,4) rồi chưa đánh,
  Vàng hỗ trợ +12 HP, chọn mục tiêu ít HP nhất, chặn khi sai lượt /
  trận đã xong, scene AI tắt thì địch đứng yên, bật thì sau delay
  B1 đi tới (8,3) + sang lượt A2, trận tự chạy hết 180s (log có đòn
  của Tiểu thương, đội A mất HP giữa trận).
- Verify thật đợt này: `--check-only` 4 file đều exit 0; regression
  MarketBattle 123/123, battle scene 43/43, battle main 15/15,
  G2 selftest 87/87, G1 selftest 419/419, G3 playtest 95/95; scene
  Main 120 frame exit 0; export web exit 0 (wasm SHA không đổi
  `fc74679e…`, pck mới `aaba00da…`, 4.204.080 byte — xem lưu ý §4);
  HTTP 200 đủ 4 file (cổng 8163).
- **Browser-verify thật (Chromium 1255 + swiftshader, 720×1280):**
  build mới chạy được, bấm B mở trận, đợi 150s wall, 0 console
  error, 0 pageerror — ảnh `hidden_files/pxb-browser-verify-2026-11-20/17-battle-ai-after.png`
  (script tái chạy: `hidden_files/pxb-browser-verify-ai.py`):
  đồng hồ trận còn 2:27 (đã qua 33s game), tới lượt "Tiểu thương 3
  (Hỗ trợ — Ghế nhựa…)", panel ghi "Đội Chợ đang đi…" +
  "Tiểu thương 2 di chuyển tới (6,4).", 2 đấu sĩ địch đã rời cột
  phải tiến về giữa lưới. Đúng hành vi AI đã test headless.
- Phát hiện về môi trường (ghi để không kết luận sai sau này):
  game trong headless Chromium + swiftshader chạy **~4–5× chậm hơn
  thời gian thật** (25s wall chỉ được ~6s game; 150s wall được ~33s
  game) — chờ theo đồng hồ game trong ảnh, không chờ theo wall.
  Lỗi test ban đầu "đội A không mất HP sau 180s" là do test sai:
  hết trận HP hồi đầy theo luật — đã sửa test đo HP giữa trận.

1. ~~**AI lượt địch** cho trận MarketBattle~~ — **XONG, xem §5.1.**
2. **Deploy gh-pages bản mới** (pck `aaba00da…` đã export 20/11
   ~11:52; wasm không đổi `fc74679e…` nên chỉ push lại pck chunk +
   index.html — xem `docs/artpass-20-11.md` §6 cách deploy chunk;
   pck nay 4.204.080 byte nên số chunk tăng ~3 lần).
3. **G4 online thật**: server `.NET 8` trong `src/server/` vẫn chưa
   build/chạy được trên VM (không có dotnet SDK) — quyết dùng Godot
   headless dedicated server thay .NET hay chờ máy có dotnet
   (xem `docs/opensource-engine.md` §3.4).
4. Polish G4 §1.4 còn lại: camera zoom trận (lưới đang nhỏ giữa màn
   hình), tile riêng Map003–018 (đang PROVISIONAL), hiệu ứng đánh/
   ngã sạp.


## Link chơi thật (LIVE 20/11 09:54)

- Repo đã public + GitHub Pages đã bật (branch gh-pages, root), verify bằng trình duyệt thật: trang tải thành công, tiêu đề "Phố Xô Bồ", màn hình tải game Godot.
- Link: https://tinnt120899.github.io/pho-xo-bo/

## 6. Art pass Nadia — đồ họa giống Treasure of Nadia (20/11, 6 vòng sửa)

Đổi hướng theo lệnh chủ 10:48 20/11: dựng đồ họa CHO GIỐNG Treasure of
Nadia, không chỉ sửa lặt vặt. Đọc `docs/nadia-reference.md` +
`docs/nadia-scene-study.md` rồi áp phong cách Nadia vào Godot.

### 6.1 Cái đã làm (Map001–002)

- **Nền vẽ tay procedural** (`scripts/nadia_scene.gd`, mới, ~900 dòng):
  sky wash 3 dải ấm, mái nhà xa, mặt đất lát gạch có nứt/rêu/vũng
  nước/lá rơi/phấn vẽ, tường 2 bên có poster + cây leo + vết nước,
  mặt tiền nhà theo từng ô: tường vàng cũ + vết bẩn/nứt, mái tôn có
  đường gờ + ống khói, biển hiệu gỗ chữ Việt ngắn (PHỞ BÒ, CÀ PHÊ,
  TẠP HÓA, CHÁO LÒNG…), cửa sổ/cửa ra vào/cổng sắt, mái hiên sọc +
  quầy hàng + giỏ trái cây (chợ), hàng rào thấp + chậu cây + mèo
  ngủ cuộn tròn, cột điện + 3 dây võng + chim đậu, đạo cụ dưới map:
  xe máy, cây chuối, xe đồ ăn có khói bay (vẽ lại ~7 lần/s), ghế
  nhựa + ly cà phê, cột đèn lồng đỏ, xe đẩy hàng rong, xe đạp dựng
  vỉa hè, chồng giỏ hàng.
- **Nhân vật Nadia** (`character_sprite.gd` viết lại): cao ~72px,
  tỉ lệ đầu:thân ~1:5.5, mặt có lông mày/mắt có highlight/má hồng/
  miệng/nháy mắt ~3s, tóc ngắn/dài/búi/nón, áo có cổ/cúc/túi, chân
  dài + giày có viền trắng, tay vung ngược chân, nhún khi đi, bóng
  bầu dục dưới chân, người chơi có vòng vàng.
- **Hotspot lấp lánh Nadia** (`marker.gd`, `pxb_hotspot.gd`):
  sao 4 cánh dài + halo + 3 tia xoay, xanh #2E7FD9 = thường,
  cam #E07800 = thưởng tốt (`hs-cho-chieu` đánh dấu `rarity: hiem`
  trong `data/maps.json` để có 1 sao cam trong slice), không biến
  mất khi chưa nhặt. Bỏ dấu "!" cũ.
- **HUD/UI gỗ/giấy** (`main.gd`): panel viền gỗ nâu bo 12 + bóng
  mềm, nút gỗ nâu chữ kem, điện thoại là panel gỗ bo 18.
- **Giữ 4 điểm sửa 10:27–10:30** nhưng làm theo chuẩn Nadia:
  nhãn kẹp dưới HUD + cách mép ~20px, nhãn của điểm ngoài màn hình
  thì ẨN (không trôi vào màn hình không có điểm neo), nửa dưới map
  có đường/vỉa hè/cây/đạo cụ tới đáy, điện thoại gọn 680x900 căn
  giữa dọc + chân trang + gợi ý tiến trình + mẹo xoay theo ngày,
  khung Tối tối hẳn (MUL 0.42,0.52,0.85 + cửa sổ sáng), toast đổi
  khung dưới HUD, desktop có chú thích 2 bên (≥1400px) + ghi rõ
  game dọc.

### 6.2 Các vòng sửa sau khi tự xem ảnh (artpass 35 → 39 checks)

1. Camera lệch lên 100 world units (`CAMERA_LOOK_UP`): người chơi
   ở 2/3 dưới màn hình, mặt tiền thoát khỏi HUD.
2. Nhãn cửa/chế tạo: trên (-120) thì chồng nhãn NPC, dưới (+24)
   thì chế tạo rơi vào chỗ người chơi đứng, cửa thì bị Cô Tư che
   chữ "Đầu" — chốt: chế tạo trên -120, cửa dưới +70, hotspot
   dưới +24.
3. Biển hiệu rút ngắn ≤8 ký tự + cỡ 10 để vừa bảng 58px.
4. Điện thoại: panel 680x1100 → 680x900, scroll 420 → 280, thêm
   `_phone_hint` (chương + ending gợi ý) + `_phone_tip` (mẹo xoay
   theo ngày); ending ID dịch sang tiếng Việt (`ENDING_NAMES`:
   TuDo → Tự do…).
5. Desktop: chú thích 2 bên bị canvas che (z-index 0 → 10) +
   chữ kem + text-shadow cho đọc được trên nền đen.
6. Hạn chế đã đo: canvas WebGL `alpha: false` nên engine tô đen
   letterbox — CSS gradient không hiện qua được; 2 dải đen còn đó
   nhưng có chú thích giải thích. Muốn hết đen hẳn phải đổi
   stretch aspect sang "expand" (chưa làm — cần neo lại HUD).

### 6.3 Verify

- `--check-only` 0 lỗi; artpass 39/39; G1 selftest 419/419;
  G3 playtest 95/95; G1 playtest 14/14; hotspot 37/37;
  MarketBattle 123/123; scene 120 frame 0 ERROR.
- Export web exit 0; Chromium local 720x1280 (map/phone/Chiều/
  Tối) + desktop 1920x1080 đều 0 lỗi, đã xem ảnh thật từng vòng.
- Deploy gh-pages bản mới: xem §6.4 (chunk base64, verify khớp byte).

### 6.4 Deploy gh-pages (tái tạo từ bản 06:12, script nay ở repo)

- Script `tools/godot/build_gh_pages.py` (mới, persistent trong
  repo): chia `index.wasm` (~39,5 MB) + `index.pck` (~1,35 MB)
  thành chunk base64 ≤180 KB, chèn loader fetch vào `index.html`
  (ghi đè fetch để ráp lại trong trình duyệt), verify SHA từng
  chunk decode khớp byte với `src/godot-build/`.
- Staging `gh-pages-staging/` (307 file): `index.html` + `wasm/`
  + `pck/` + `index.png`/`index.icon.png`/`index.apple-touch-icon.png`.
  Push lên branch `gh-pages` bằng snapshot-push theo lô ~20 file,
  sync record riêng (xem `src/nadia/www.muse-github-snapshot-sync.json`).
- Live link vẫn phục vụ bản 06:12 tới khi deploy này xong.

## 7. Art pass 2 — Nadia-style bằng ẢNH VẼ THẬT (20/11 ~12:00, theo 6 điểm live-check 11:40)

Kết luận live-check 11:40: vẽ bằng code KHÔNG BAO GIỜ ra tranh vẽ
tay có shading mềm kiểu Nadia — vòng này đổi hẳn sang ảnh vẽ thật
(tự tạo mới bằng media image generation, KHÔNG lấy từ Nadia/game
khác), nhân vật + nền đều dùng ảnh, code chỉ còn fallback.

### 7.1 Ảnh (src/godot/art/, tự tạo mới 20/11)

- 5 sprite nhân vật tách nền trắng → trong suốt, chuẩn hóa cao
  512px: `char_player.png` (260×512), `char_cotu.png` (275×512),
  `char_banthan.png` (330×512), `char_chile.png` (233×512),
  `char_anhhai.png` (213×512) — mặt chi tiết (mắt/má/tóc mái),
  quần áo có shading. Xử lý bằng PIL (`/tmp/process_art.py`,
  không lưu trong repo): trắng → trong suốt (ngưỡng 235 + feather),
  tách từng nhân vật theo bbox, resize cao 512.
- `bg_map001.png` (1120×630): composite — sky band (mây + nắng +
  chim, 280px) + facade crop (tường vàng cũ, mái tôn, 3 biển
  "PHO BO / CA PHE / TAP HOA" đủ chữ, đèn lồng, cửa sổ/cửa ra vào).
- `sky_band.png` (1120×280): trời riêng cho Map002.
- `title_bg.png` (720×1280): crop giữa facade làm nền title.
- Map001 dùng composite thay toàn bộ trời + mái xa + mặt tiền +
  dây điện code; Map002 dùng sky_band thay trời code, giữ mái xa +
  mặt tiền code (vẽ đè lên ảnh trời).

### 7.2 Code (6 điểm live-check đều sửa)

1. **Nhân vật có mặt** (`character_sprite.gd`): cfg có `texture`
   → Sprite2D ảnh thật cao 104px (nhún + nghiêng nhẹ khi đi,
   flip_h khi quay trái); không có file thì fallback vẽ code.
   `player.gd` + `marker.gd` (NPC_STYLE) gắn texture từng người.
2. **Nhãn luôn trên nhân vật** (`marker.gd`, `main.gd`,
   `iso_map.gd`): nhãn là Label trên CanvasLayer riêng (layer 1,
   tạo trước lớp HUD nên vẽ dưới HUD, trên mọi Node2D thế giới),
   font 32px, tính rect theo `label_screen_rect()` (tọa độ màn
   hình, kẹp y ≥ 276, cách mép 16px); nhãn NPC dời lên -144 (đầu
   nhân vật ảnh cao 104px). Không có lớp thì fallback `_draw_name()`.
3. **Trời có chi tiết**: composite/sky_band có mây + nắng + chim
   (Sáng); overlay Chiều (1.0,0.82,0.55) / Tối (0.42,0.52,0.85)
   giữ nguyên; Tối có trăng + sao + đèn lồng có quầng
   (`night_glow.gd`: trăng ở nửa dưới dải trời, sao rải 80px dưới
   cùng dải trời, màu HDR >1.0 để xuyên qua lớp overlay MUL —
   màu thường bị nhân tối, chìm vào trời đêm); nhà có cửa sổ/cửa
   ra vào trong ảnh; bóng đổ nhà/cây/xe (`nadia_scene.gd`
   `_draw_shadows()`, nắng từ phải-trên → bóng lệch trái-dưới).
   Camera `CAMERA_LOOK_UP` (0,-100) → (0,-230) để biển hiệu xuống
   dưới HUD lúc spawn; trời hiện rõ khi đi lên hàng trên.
4. **Điện thoại** (`main.gd`): bỏ lặp "Bạn thân — Bạn thân"
   (tên trùng loại quan hệ thì in 1 lần); danh bạ liệt kê cả NPC
   chưa quen (toàn bộ 18 khu) lấp khoảng trống; nội dung dài cho
   vào ScrollContainer (không tràn panel — label phải đặt
   `custom_minimum_size.x = 580` nếu không autowrap ép về 1px,
   chữ xếp dọc 1 ký tự/dòng); notch + thanh home (Panel bo tròn
   nâu đậm) hiện/ẩn theo điện thoại; panel giữ đúng 680x900
   (separation VBox 10 → 8, không panel phình lên 907).
5. **Nút "Bắt đầu chơi"**: trong game lớn 620x110 (font 40) +
   nút DOM thật ngoài canvas (`web_shell.html` #start-overlay:
   nút HTML "▶ BẮT ĐẦU CHƠI", enable khi engine tải xong, click
   đặt `window.__pxb_start = true`, Godot poll 4 lần/giây qua
   `JavaScriptBridge.eval` rồi đóng title; overlay ẩn sau 400ms).
6. **Desktop hết dải đen** (`web_shell.html`): `.side-panel`
   (thay `.side-caption`) — JS `layoutSidePanels()` đo vùng
   letterbox thật (scale = min(w/720, h/1280)) rồi đặt panel 2 bên
   đúng bằng phần thừa, nền gradient ấm + họa tiết + chữ nâu đậm,
   `pointer-events: none`, ẩn khi phần thừa < 80px.

### 7.3 Lỗi tìm ra trong vòng này (ghi để không tái phạm)

- **NightGlow bị ảnh nền che**: IsoMap bật y-sort — NightGlow ở
  y=0 xếp trước Sprite2D nền (y=7, đục) nên trăng/sao/đốm sáng bị
  vẽ đè lên, không thấy dù `moon_on = true`. Sửa: `z_index = 10`
  cho NightGlow (ánh sáng chồng lên nhân vật là đúng).
- **Trăng/sao sai tọa độ**: `set_sky(offset + (-560,-330))` là
  đỉnh mặt tiền, không phải đỉnh dải trời — sao rơi lên cửa/nền
  đất. Đúng: `offset + (-560,-610)` (đỉnh composite 630px, tâm ở
  offset+(0,-295)). Trăng/sao phải ở nửa dưới dải trời mới thấy
  dưới HUD khi đi lên hàng trên.
- **Overlay MUL nuốt nguồn sáng**: màu trăng/sao/đèn vẽ thường
  (≤1.0) bị nhân với (0.42,0.52,0.85) thành xanh tối, chìm vào
  trời đêm. Nguồn sáng phải vẽ bằng màu HDR >1.0.
- **Panel điện thoại phình 900 → 907**: ScrollContainer mới làm
  tổng chiều cao tối thiểu VBox vượt 900. Sửa bằng separation
  10 → 8, giữ đúng 680x900.
- **WASD không đi được**: hint ghi "WASD / mũi tên" nhưng code
  chỉ dùng action `ui_up/down/left/right` (mặc định chỉ có phím
  mũi tên, không bind W/A/S/D trong project.godot) — đi lên phải
  dùng ArrowUp. Chưa sửa (việc riêng, ghi cho vòng sau).
- **Nghi lệch tọa độ Map003+** (chưa verify bằng mắt): TileMapLayer
  `map_to_local((5,4)) = (352,80)` vs `tile_center((5,4)) =
  (344,462)` — marker/NPC dùng hệ offset, tile layer dùng hệ thô.
  Map001–002 không ảnh hưởng (layer ẩn, NadiaScene dùng hệ
  offset). Cần screenshot Map003 trước khi kết luận.

### 7.4 Verify (vòng này)

- `--check-only` exit 0; artpass 57/57 (thêm 18 check mới: ảnh
  nhân vật/nền/title đã nạp, nút 620x110, lớp nhãn dưới HUD, notch/
  home bar, danh bạ không lặp + liệt kê NPC, trăng + đèn đường);
  scene 120 frame exit 0; G1 selftest 419/419; G2 selftest 87/87;
  G3 playtest 95/95.
- Export web exit 0; Chromium local (Xvfb + Playwright, 0 console
  error): desktop 1280x720 (title DOM / map spawn / lên hàng trên /
  Chiều / Tối + trăng sao / điện thoại) + portrait 720x1280 — đã
  xem ảnh thật từng vòng (`visual-check/artpass2/`).
- Hạn chế còn lại (đã đo, không giấu): trời + mặt trời chỉ hiện
  rõ khi đi lên hàng trên (lúc spawn HUD chiếm 252px trên cùng +
  camera theo người chơi nên trời nằm ngoài khung); mặt đất vẫn
  là hình thoi vẽ code (be) dưới mặt tiền vẽ ảnh — tương phản
  thấy rõ ở bản portrait; ảnh PNG (1,1–1,3 MB) KHÔNG push được
  lên main qua snapshot-push (giới hạn 188.416 byte/file, chỉ file
  text) — PNG chỉ có ở working copy local + nướng trong file
  `.pck` đã deploy; clone mới sẽ fallback về vẽ code (nhân vật)
  và không có ảnh nền (có guard `ResourceLoader.exists`).
- Deploy gh-pages: xem §6.4 (script `tools/godot/build_gh_pages.py`).
- Live link vẫn phục vụ bản 06:12 tới khi deploy này xong.



## 8. G4 bước 3 — WASD + tọa độ Map003 + artpass3 (20/11 ~13:00–13:20)

> Làm song song 2 luồng: luồng kia sửa code (WASD, DIAMOND_DOWN, art
> mới sky/ground/night, HUD gọn, nhãn chống chồng) 12:36–13:04; luồng
> này verify + export + deploy + browser-verify. Không sửa đè code
> của luồng kia khi thấy file còn đang đổi (kiểm tra mtime trước
> mỗi bước; xem bài học chạy song song ở cuối §8).

### 8.1 WASD + tọa độ Map003 — XONG

- `player.gd` `_held_dir()`: nghe cả `move_*` (W/A/S/D, đã bind sẵn
  trong `project.godot`) lẫn `ui_*` (mũi tên) — trước đây chỉ `ui_*`
  nên W/D không đi được dù hint ghi "WASD / mũi tên" (lỗi 12:20).
- `iso_map.gd`: `tile_set.tile_layout = TILE_LAYOUT_DIAMOND_DOWN`
  (không phải STACKED mặc định) — TileMapLayer trước đây vẽ sai chỗ
  so với marker/người chơi ở Map003+.
- Test mới `tests/g4_coord_wasd_test.gd`: **16/16 PASS** — action
  move_* đủ W+Up/S+Down/A+Left/D+Right; W lên (4,4), D sang (5,4),
  mũi tên trái vẫn đi, giữ W đi liên tục 2 ô; 108 ô Map003 tâm tile
  ground/object trùng `tile_center`, marker đúng tile của mình.
- Test mới `tests/g4_artpass3_test.gd` (vòng sửa 12:30): **21/21
  PASS** — 4 ảnh mới tồn tại, ground sprite mép trên y~280, HUD gọn
  ≤140, panel điện thoại y ≥ 150, skyfx tồn tại, đổi khung Toi đổi
  ảnh nền đêm + tint nhân vật tối + night_glow bật + sky_in_image,
  nhãn Map001 không chồng nhau, về Sáng ảnh nền + tint trở lại.

### 8.2 Hồi quy sau vòng sửa — artpass 57/57 trở lại

- Lúc 12:59 artpass cũ rớt 6/57 + artpass3 rớt 2/21 (HUD 157px,
  nhãn "Hẻm trọ buổi tối" chồng "Cửa ra Chợ Đầu Mối", zoom 1.4 vs
  test cũ đòi 1.6, toast y=200 vs [260,280], màu overlay Toi
  (0.55,0.62,0.9) vs (0.42,0.52,0.85), night spots rỗng ở Map001-002).
  Nguyên nhân: một phần là code chưa sửa xong (HUD, nhãn), một phần
  là test cũ lỗi thời so với thay đổi có chủ ý (zoom 1.4 cho thấy
  trời lúc spawn; overlay Toi nhạt hơn vì ảnh nền đêm đã tối sẵn;
  spots rỗng vì cửa sổ sáng đã có trong ảnh đêm; toast/phone dời
  theo HUD gọn). Luồng kia sửa code + cập nhật test 13:01–13:04.
- Verify lại lúc 13:05: **artpass 57/57**, **artpass3 21/21**;
  G1 selftest 419/419, G3 playtest 95/95, G2 selftest 87/87,
  MarketBattle 123/123, battle scene 43/43, battle main 15/15,
  battle AI 34/34, G1 playtest 14/14, coord+WASD 16/16 — không
  regression.

### 8.3 Bài học chạy Godot headless (ghi để không tái phạm)

1. **Cache class cũ gây lỗi parse ảo:** log 12:50–12:56 báo
   `SkyEffects` không tìm thấy, `kind` không khai báo,
   `skyfx` không resolve — nhưng code đúng. Nguyên nhân:
   `global_script_class_cache.cfg` cũ, trước lần `--import`
   12:54 của luồng kia. Sau import, mọi `--check-only` đều
   exit 0. Gặp lỗi parse lạ: chạy `--headless --import` trước
   rồi mới kết luận code hỏng.
2. **Test lỗi giữa `_init` thì engine treo:** test script lỗi
   runtime trước khi tới `quit()` thì SceneTree chạy idle mãi
   (0% CPU, không thoát) — tiến trình test đầu tiên của luồng
   này treo 7 phút vì vậy. Luôn bọc lệnh test headless bằng
   `timeout 150`.
3. **Hai luồng Godot cùng lúc:** tiến trình import/check-only
   của luồng kia + test của luồng này cùng mở một project gây
   nhiễu (treo, cache cũ). Trước khi chạy Godot, kiểm tra
   `ps` + mtime file; chỉ chạy khi không còn tiến trình Godot
   nào khác.

### 8.4 Deploy gh-pages bản mới — XONG (bản artpass3-fix)

- Luồng này push batch 1/3 (`39276bc6`, index.html + pck 000–018
  bản 053c5401) 13:42 — bị luồng kia ghi đè ngay sau đó vì luồng
  kia deploy bản export mới hơn (7e84335). Batch 2/3 của luồng này
  lỗi `not a fast forward` và đã DỪNG, không push lại (đẩy chunk
  pck cũ lên loader mới sẽ làm hỏng bản build).
- Deploy chính thức (luồng kia, 13:43–13:48): **6/6 batch,
  head `8bed7c2cc0a`** — `f18ba5ef` (1/6: index.html + pck
  000–008), `6eac413f` (2/6: 009–018), `edcdc17a` (3/6: 019–028),
  `8a4b5053` (4/6: 029–038), `05479f43` (5/6: 039–048),
  `8bed7c2cc0a` (6/6: 049–050). pck **6.876.644 byte, SHA
  `7e84335…`**, 51 chunk; wasm không đổi `fc74679e…`.
- HTTP 200 đủ 4 file trên build local (cổng 8164). Live site:
  `https://tinnt120899.github.io/pho-xo-bo/` — kiểm tra ở §8.7.
- Push main: **`36e507c2`** (20 file: WASD + DIAMOND_DOWN +
  artpass3-fix + 3 test mới; artpass3 23/23, artpass 57/57,
  G1 419/419, G3 95/95).
- Verify remote khớp byte: **4/4 mẫu** (index.html, pck
  000/025/050) — blob SHA remote = staging; head gh-pages
  `8bed7c2c` đứng yên sau deploy, không còn lô nào đè sau.

- Export 13:07 exit 0: pck mới **6.859.624 byte, SHA
  `053c5401…`** (từ 4.210.640 — tăng do nướng 4 ảnh JPG mới);
  wasm không đổi `fc74679e…`. pck chứa `move_up` +
  `ground_wide`/`sky_wide`. **Lưu ý: bản export này đã bị thay
  thế trước khi lên live** — luồng kia export lại 13:25 (pck
  **6.876.644 byte, SHA `7e84335…`**, art đêm vẽ lại) và deploy
  bản đó; xem §8.4.
- `--headless --quit-after 120` exit 0, không ERROR.
- Staging rebuild (bản 053c5401): pck **51 chunk** (từ 32), wasm
  293 chunk không đổi; `build_gh_pages.py --verify-only` OK
  (khớp byte).

### 8.5 Browser-verify WASD thật (Chromium 1255 + swiftshader)

- Script mới `hidden_files/pxb-browser-verify-wasd.py`.
- **Lỗi verify lần 1:** click tọa độ (360,665) quá sớm — nút DOM
  `#start-btn` bắt đầu DISABLED ("Đang tải game…"), chỉ enable
  khi engine tải xong; click sớm không có tác dụng, 5 ảnh đều ở
  title (byte-identical). Sửa script: đợi
  `#start-btn:not([disabled])` rồi mới click qua selector, thử
  lại tối đa 3 lần, xác nhận `window.__pxb_start === true` +
  overlay ẩn.
- **Lần 2 — PASS, đã xem ảnh thật:** title biến mất, map Map001
  vẽ đẹp (trời mây + chim, mặt tiền CÀ PHÊ + đèn lồng, sprite
  thật); bấm **W** player lên 1 ô (ảnh 18→19); bấm **D** sang
  cửa (5,4) → title `Chợ Đầu Mối` + toast `Đã sang Chợ Đầu Mối`
  (ảnh 20); 4× **S** xuống cửa (5,8) → title `Khu Công Nhân` +
  toast `Đã sang Khu Công Nhân` (ảnh 22) — **DIAMOND_DOWN đúng
  bằng mắt**: tile/NPC/cửa Map003 thẳng hàng, không lệch. 0 console
  error, 0 pageerror.
- Phát hiện cho vòng polish sau (không chặn deploy):
  1. Map003: nửa trên màn hình (~55%) là nền nâu trơn — Map003
     không có ảnh trời/đất riêng (chỉ Map001-002 có), tile chỉ
     phủ nửa dưới.
  2. HUD tràn chữ: tên map dài ("Khu Công Nhân") bị cắt ở mép
     panel 452px, chữ chui dưới nút phải.
  3. Map002/Map003: nhãn 2 cửa ở đáy màn hình chồng/cắt nhau
     ("Cửa đi Bến Xe Miền Đông" đè "...u Mới") — test chống
     chồng hiện chỉ kiểm tra Map001.

### 8.6 Vòng sửa artpass3-fix — sau khi tự xem ảnh lần 2 (13:20–13:45)

Live-check lần 2 (ảnh thật Chromium, 6 điểm) chưa đạt: trăng
không thấy, mặt trời Sáng/Chiều không thấy, tường bên/hàng rào
code vẫn hiện, nhãn chế tạo đè người chơi, toast đè tiêu đề điện
thoại. Đã sửa + xem lại ảnh, 6 điểm hết:

- **Trăng/mặt trời vô hình — nguyên nhân y-sort:** `IsoMap`
  bật `y_sort_enabled`; `SkyEffects` ở y=0 nên bị sprite nền
  composite (y=23, đục) vẽ đè (cùng họ lỗi NightGlow 12:20).
  Sửa: `skyfx.z_index = 10` (`iso_map.gd`). Mặt trời Sáng/Chiều
  dời xuống world y −140 (màn hình ~245, dưới HUD 173) + mặt
  trời Sáng vàng đậm hơn (trước −195 nằm sau HUD + chìm trong
  mây trắng). Trăng vẽ bằng code ở world (368,−103) = màn hình
  (394,297) lúc spawn; trăng trong ảnh đêm đã XÓA (clone vùng
  trời trái bằng PIL — lần đầu clone nhầm vùng chứa nửa trăng
  nên trăng vẫn còn, phải vá lại lần 2 bằng vùng trời sạch
  x 0..400). `sky_night.jpg` cũng xóa trăng (chỉ còn sao + mây
  đêm) để không có 2 trăng khi đi lên cao. Bài học: ảnh gen
  không đặt trăng đúng tọa độ được — trăng/mặt trời nên vẽ code.
- **Tường bên + hàng rào code:** `_draw_side_walls()` và thanh
  hàng rào `_draw_bottom_fence()` bỏ với Map001 (ảnh composite
  đã vẽ sẵn tường/nhà 2 bên) — chỉ giữ chậu cây + mèo ngủ.
  Map002+ giữ nguyên (mặt tiền vẽ code).
- **Nhãn chế tạo:** +24 → −40 (lên trên icon, như hotspot) —
  +24 cũ đè đúng chỗ người chơi spawn (4,5).
- **Toast:** `_open_phone()` ẩn toast — toast y=200 đè lên
  tiêu đề "Điện thoại" (panel y=190) khi mở điện thoại ngay
  sau đổi khung.
- **Test:** artpass3 thêm check mặt trời (`sun_pos.y` trong
  −160..−100) + trăng (`moon_pos` trong x 100..600, y
  −300..−20) → **23/23 PASS**; artpass 57/57; hồi quy còn lại
  giữ nguyên (G1 419/419, G3 95/95, MarketBattle 123/123…).
- **Staging Map003 — bài học:** map bắt đầu lấy từ
  `data/maps.json` (`start.map`), KHÔNG phải `current_map_id`
  (biến này bị `load_map()` ghi đè lúc `_ready`). Lần stage
  đầu sửa nhầm `current_map_id` nên vẫn hiện Map001; sửa đúng
  `maps.json` → Map003 hiện đúng.

### 8.7 Kiểm tra live site sau deploy — XONG (13:50)

- **Byte-level (curl):** `index.html` live 200, liệt kê đủ 51
  pck part; tải + ráp lại 51 part → **6.876.644 byte, SHA
  `7e843358520402a1` — khớp đúng từng byte với build local
  13:25**. Deploy đúng, không lẫn chunk bản cũ.
- **Trình duyệt thật với đúng bản live:** Chromium không mở được
  URL live trực tiếp (`ERR_TUNNEL_CONNECTION_FAILED` ×2 — proxy
  của VM chặn tunnel HTTPS ra ngoài, không phải lỗi site; curl
  từ shell vẫn tới được). Thay thế bằng cách chạy lại
  `pxb-browser-verify-wasd.py` trên build local 8164 — lúc này
  `src/godot-build/` đã là đúng bản live 7e84335 (SHA khớp):
  start OK, W lên 1 ô, D sang Chợ Đầu Mối, 4×S sang Khu Công
  Nhân, 0 console error, 0 pageerror, đã xem ảnh thật (18–22).
  Mặt trời hiện (fix §8.6 có tác dụng), nhãn "Góc Chế Tạo" đã
  lên trên, không còn đè người chơi lúc spawn.
- Hạn chế chưa kiểm chứng: tải trang live bằng trình duyệt thật
  (bị proxy chặn) — cần chủ hoặc máy khác mở
  `https://tinnt120899.github.io/pho-xo-bo/` kiểm tra 1 lần.
- Polish còn lại (đã ghi §8.5): Map003 nửa trên nâu trơn, HUD
  cắt tên map dài, nhãn 2 cửa Map002/Map003 chồng nhau ở đáy.

## 9. Việc tiếp theo — G4 bước 4 — XONG (20/11 ~14:00–14:30)

### 9.1 Polish §8.5 — XONG

- **Nền trời mặc định cho Map003+** (`scripts/iso_map.gd`): `sky_band.png`
  (trước chỉ Map002) + `sky_wide.jpg` (trước chỉ Map001-002) nay dùng cho
  MỌI map (điều kiện `map_id == 2` → `map_id >= 2`, bỏ điều kiện
  `map_id == 1 or 2` ở sky_wide); vị trí như Map002 (bg offset+(0,-190),
  sky_wide offset+(0,-530)) — đáy trời ở offset.y-50, vừa chân mặt
  tiền/tile hàng trên. Đêm đổi sang `sky_night.jpg` như Map002
  (`has_night_bg = true` → MUL đêm nhẹ 0.55,0.62,0.9).
- **HUD co chữ theo tên map** (`main.gd` `_fit_hud_map()`, gọi trong
  `load_map`): đo bằng `font_bold.get_string_size`, co từ 30 xuống
  tối thiểu 20 tới khi vừa 412px (panel 452 − 2×18 margin). Đo thật:
  HUD cũ tràn ở 17/18 map (kể cả tên ngắn: "Xóm Trọ Cũ" 415px ở cỡ
  30) — chỉ "Phố Tây" vừa cỡ 30; dài nhất "Phố Đi Bộ – Chợ Đêm" về
  cỡ 20, "Khu Chung Cư Cao Cấp"/"Khu Biệt Thự Ven Sông"/"Khu Sân
  Golf & Resort" về cỡ 20.
- **Chống chồng nhãn trên mọi map** (`main.gd` `_deoverlap_labels()`
  + `marker.gd` `label_shift`): mỗi frame (trong `Main._process`,
  trước `_process` của marker con) tính lại rect màn hình mọi nhãn
  hiện, sắp theo y rồi đẩy nhãn chồng xuống dưới (hết chỗ dưới thì
  đẩy lên trên, kẹp 190..1280-16-h), lệch lưu vào
  `marker.label_shift` (px màn hình) để `_update_label` áp dụng.
- **Test mới** `tests/g4_polish_test.gd`: **18/18 PASS** — sky Map003
  (bg sky_band đúng vị trí, sky_wide đúng vị trí, có ảnh đêm, đêm
  đổi sky_night), HUD vừa panel + cỡ lớn nhất có thể (Map001/002/018),
  nhãn Map002 + Map003 không chồng nhau, Map001 giữ composite.
- **Sửa test cũ lỗi thời** (`tests/g2_ui_wiring_test.gd`, 2 check):
  `_update_hud` từ vòng HUD gọn 12:30 đã gộp túi vào dòng ngày
  ("Ngày 1 • Khung Sáng • Túi: trống") và `_hud_bag` ẩn đi không cập
  nhật text nữa, nhưng test vẫn đọc `_hud_bag.text` nên rớt 2/37 từ
  vòng 12:30 mà không ai để ý (vòng hồi quy 13:05 không chạy suite
  này). Nay test đọc `_hud_day.text` ("Túi: trống" / "Túi: 1 loại").
  **37/37 PASS** trở lại.
- Hồi quy: artpass 57/57, artpass3 23/23, G1 selftest 419/419,
  G3 playtest 95/95, G2 selftest 87/87, MarketBattle 123/123,
  battle scene 43/43, battle main 15/15, battle AI 34/34,
  G1 playtest 14/14, coord+WASD 16/16, hotspot 37/37, jobs 56/56,
  inventory+crafting 78/78, economy+education 92/92, phonehub 66/66,
  savecloud 69/69, social+titles+story 102/102, tools 155/155,
  online 91/91, ui_wiring2 71/71; scene 120 frame 0 ERROR.
- Export web exit 0: pck mới **6.872.908 byte, SHA `71c1c358…`**
  (trước `7e84335…`), wasm không đổi `fc74679e…`,
  `GODOT_THREADS_ENABLED = false`; HTTP 200 đủ 4 file (cổng 8165).
- **Browser-verify thật (Chromium 1255 + swiftshader, 720×1280):**
  0 console error, 0 pageerror — ảnh
  `hidden_files/pxb-browser-verify-2026-11-20/23-polish-map1.png`,
  `28-polish-map2.png`, `29-polish-map3.png` (script tái chạy:
  `hidden_files/pxb-browser-verify-polish3.py`):
  Map002 toast "Đã sang Chợ Đầu Mối", 2 nhãn cửa đáy map xếp chồng
  dọc không đè nhau ("Cửa về Xóm Trọ Cũ" trên, "Cửa đi Khu Công
  Nhân" dưới, cách nhau ~5px); Map003 toast "Đã sang Khu Công Nhân",
  HUD "Phố Xô Bồ — Khu Công Nhân" vừa panel, **nửa trên là trời
  xanh có mây + chim + mặt trời, hết nền nâu trơn**; 2 nhãn cửa
  Map003 cũng không chồng nhau. Bài học input: `keyboard.press`
  nhanh bị miss giữa các frame (game ~0.22× thời gian thật); giữ
  phím 1500ms thì đi 2-3 ô; **giữ 400ms = đúng 1 ô** (đủ ≥1 frame
  poll thấy phím, thả trước khi bước 0.15s game xong).
- Phát hiện còn lại (không chặn deploy): Map003 tile vẫn là khối
  vàng tái dùng (PROVISIONAL, chờ art riêng); toast "Đã sang…"
  đè lên mặt trời ở góc trái (cosmetic, đã biết từ trước).
- **Va chạm song song (ghi 20/11 ~14:30):** trong lúc vòng này
  chạy, một luồng khác làm artpass4 trên cùng working copy
  (main.gd 07:16, export 07:17:54, pck mới `b6900f13…`). Push
  main `8e590ded…` đã quét cả thay đổi artpass4 của luồng kia
  (main.gd có cả `_deoverlap_labels` + `_resolve_label_overlaps`,
  marker.gd có cả `label_shift` + `label_override`) — commit vẫn
  coherent, đã verify lại trên code gộp: polish 18/18, artpass4
  17/18 (1 FAIL là mục điện thoại của luồng kia, đang làm dở),
  artpass 57/57, artpass3 23/23, G1 419/419, G3 95/95, G2 87/87,
  MarketBattle 123/123, ui_wiring 37/37 + 71/71, battle AI 34/34.
  **Deploy gh-pages CHƯA làm trong vòng này** (staging trên đĩa
  vẫn là bản polish `71c1c358…` đã verify; build hiện tại là
  `b6900f13…` của luồng kia, chưa verify xong) — vòng sau export
  lại từ code gộp, verify rồi deploy 1 lần. Hai hệ nhãn cùng chạy
  (`_resolve_label_overlaps` ghi `label_override`, `_update_label`
  ưu tiên nó; `_deoverlap_labels` tính `label_shift` nhưng bị
  override che) — **ĐÃ GỘP ở §10** (chỉ còn 1 hệ).

## 10. Art pass 4 — XONG (20/11 ~14:00–15:00, live check 13:53–13:56)

5 điểm ưu tiên từ kiểm live 13:53–13:56 trên bản artpass3
(gh-pages `8bed7c2c`), sửa xong, tự xem ảnh thật, deploy lại.

### 10.1 Nhãn chống chồng — viết lại bộ giải (lần 2)

- **Lần 1 (khoảng trống, vật cản toàn thân 90×160, gap nhân đôi
  grow+6px) SAI:** debug cho thấy "Góc Chế Tạo" + "Cửa ra" cùng
  rơi về y=1216 và chồng nhau. Nguyên nhân: grow(4)/grow(6) +
  cộng thêm 6px trong công thức = gap tính 2 lần, ăn hết khe hẹp
  giữa nhãn NPC và đầu NPC; vật cản toàn thân 160px đẩy nhãn
  xuống tận đáy màn hình, rời khỏi điểm neo.
- **Lần 2 (đang chạy):** vật cản chỉ đầu + thân trên
  (`_sprite_obstacle_rect`: 90×100px, đầu ở -150, ngực ở -50 —
  chân/bị che không sao, mặt/ngực mới quan trọng); gap 1 lần
  duy nhất `LABEL_GAP = 4.0` (không grow); chọn khoảng dọc trống
  gần vị trí mong muốn nhất; nếu khoảng dọc gần nhất xa hơn
  60px thì **dịch NGANG giữ nguyên y** (ưu tiên phải rồi trái,
  40/80/120/160px) thay vì đẩy lên/xuống xa khỏi điểm neo.
- Đo thật lúc spawn (debug headless frame 60): Cô Tư giữ
  (438,961); Bạn Thân giữ (229,827); Góc Chế Tạo (293,874) —
  kẹp giữa nhãn Bạn Thân (đáy 865) và đầu Bạn Thân (915), cách
  mỗi bên 4–9px, KHÔNG đè mặt; Hẻm trọ buổi tối (424,1154) —
  dưới thân trên Cô Tư (hết 1150) +4px, chỉ che chân; Cửa ra giữ
  (281,1225) đáy map.
- **Gộp 2 hệ nhãn (§9):** xóa `_deoverlap_labels()` +
  `marker.label_shift` — hệ cũ chạy chồng mỗi frame, `label_shift`
  của nó còn làm nhiễu đầu vào (desired rect) của bộ giải mới
  nhưng kết quả không bao giờ được dùng (override ưu tiên).
  Chỉ còn `_resolve_label_overlaps` + `label_override`.
  Polish test đổi sang kiểm tra vị trí HIỂN THỊ (override nếu
  có, không thì rect cơ bản) — Map002/003 vẫn không chồng nhau
  qua bộ giải chung.

### 10.2 Nhân vật tối theo khung Tối — nguyên nhân gốc

- Tint cũ (0.72,0.78,0.95) quá nhạt. Lấy mẫu pixel chứng minh
  overlay MUL ngày/đêm ĐÃ phủ lên nhân vật (facade Tối/Nền
  = 0.41 khớp ảnh đêm × MUL; đất = 0.62 khớp MUL) — tint chỉ
  yếu chứ không thiếu. Đổi tint Tối → **(0.42,0.48,0.72)**,
  Chiều → (1.0,0.85,0.62) ấm hơn. Đo ảnh Tối: nhân vật
  48.3 vs Sáng 120.8 (tỷ lệ 0.40, gồm cả vòng chọn vàng dưới
  chân) — nhìn thật: nhân vật xanh đậm, hòa vào nền đêm.

### 10.3 Đường nối dọc 2 tấm nền — cân bằng lại ảnh

- `tools/godot/regrade_bg.py`: cân lại `bg_map001.png` +
  `bg_map001_night.jpg` (bản gốc backup `/tmp/artpass4-bak/`):
  gain hằng theo từng phần ba + ramp tuyến tính 160px qua
  biên x≈373/747, gain kẹp [0.92, 1.08], chỉ y≥240 + feather
  dọc 40px. Ngày: độ sáng 3 phần 103.0/104.3/96.2 →
  100.6/101.2/100.1; đêm 51.8/55.9/55.7 → 53.8/54.2/54.0.
  (Bản v1 gain mượt 201px đã bỏ — làm bước nhảy ở khớp tệ hơn.)
  Ảnh TẠP HÓA sau sửa: không còn ranh giới thẳng cắt qua
  cửa/cửa sổ/mặt đất (chênh sáng 3 phần còn lại chủ yếu do
  nội dung cửa tối, không phải nối ảnh).

### 10.4 Toast + sao đêm + điện thoại

- Toast ngày/khung (60,200) → **(60,720)** (giữa-dưới, trên
  vỉa hè, không đè đĩa mặt trời/trăng ở y~200–400).
- Sao đêm: vẽ LUÔN (kể cả khi `sky_in_image`), 64 sao (trước
  36), alpha tới 0.95, bán kính tới 4.5; trăng vẫn bỏ qua khi
  có ảnh trời (tránh 2 mặt trăng); thêm cờ `stars_drawn`.
- Điện thoại: panel (20,190) → **(20,216)** (dưới nút HUD
  "Điện thoại (P)" hết ở y=208 + 8px); notch → (300,209);
  homebar → (290,1104); content scroll min 200 → **224**.
- **Lỗi Chị Lệ lần 2 (14:15):** sau lần 1 vẫn nửa cắt — vì
  danh bạ liệt kê NPC chưa quen cả 18 khu (38 dòng) và mỗi
  bullet dài ~50 ký tự gập 2 dòng; dòng 2 bị cắt ở mép dưới
  viewport. Sửa gốc: bullet "chưa quen" gọn 1 dòng
  (`• <tên> — chưa quen`, tên dài nhất 20 ký tự = 34 ký tự),
  gợi ý nói chuyện chuyển lên dòng tiêu đề. "Chị Lệ — chưa
  quen" nay hiện đủ 1 dòng; dòng nửa cắt ở mép cuộn còn lại
  là mục mới nguyên vẹn (báo hiệu cuộn được), không phải nửa
  sau của 1 mục.

### 10.5 Test + verify vòng này

- **Test mới** `tests/g4_artpass4_test.gd`: **18/18 PASS** —
  toast y 700–740; tint Tối r<0.6, b>r; panel/notch/homebar;
  panel 680×900 sau khi mở; content scroll 224;
  `_social_text()` kết thúc `"\n "` + bullet "chưa quen"
  ≤44 ký tự; `stars_drawn`; nhãn override không chồng nhau,
  không đè đầu/thân trên; về Sáng tint trắng trở lại.
- Hồi quy đầy đủ (sau gộp hệ nhãn): artpass 57/57, artpass3
  23/23, polish 18/18, G1 selftest 419/419, G1 playtest 14/14,
  G2 selftest 87/87, G3 playtest 95/95, MarketBattle 123/123,
  battle scene 43/43, battle main 15/15, battle AI 34/34,
  coord+WASD 16/16, hotspot 37/37, jobs 56/56,
  inventory+crafting 78/78, economy+education 92/92, phonehub
  66/66, savecloud 69/69, social+titles+story 102/102, tools
  155/155, online 91/91, ui_wiring 37/37 + 71/71;
  `--check-only` main.gd + marker.gd exit 0; scene 120 frame
  exit 0.
- Export web exit 0: pck **6.876.920 byte, SHA `101dda2e…`**
  (trước `7e84335…`), wasm không đổi `fc74679e…`.
- **Tự xem ảnh thật** (Chromium 1255 + swiftshader, 720×1280,
  `visual-check/artpass4/ap4-01..06.png`, script
  `visual-check/check_artpass4.py`, 0 console error,
  0 pageerror): Sáng spawn — nhãn tách nhau, không đè mặt,
  mặt trời rõ; TẠP HÓA — không đường nối dọc; Chiều — toast
  không đè mặt trời, ngả cam ấm; Tối — nhân vật xanh đậm,
  trăng rõ, sao dày, toast không đè trăng, đèn lồng/cửa sổ
  sáng; điện thoại — nút HUD đủ, "Chị Lệ — chưa quen" đủ
  1 dòng. **5/5 điểm đã hết.**
- File `tests/debug_labels_test.gd` (debug tạm, in rect nhãn)
  đã xóa trước khi push.
- Giới hạn còn lại: PNG art chỉ có trong bản local + `.pck`
  đã deploy (snapshot-push giới hạn text 188.416 byte/file) —
  clone mới vẫn fallback nhân vật vẽ code; nhãn "Cửa ra" vẫn
  ở sát đáy (6px, đúng vị trí vì cửa ở đáy map); nhãn Hẻm
  che chân Cô Tư (chỉ chân, không che thân).

## 11. Việc tiếp theo — G4 bước 5

1. G4 online thật: quyết Godot headless dedicated server thay .NET
   hay chờ máy có dotnet (xem `docs/opensource-engine.md` §3.4).
2. Lưu giữ sạp + Danh vọng trận MarketBattle vào SaveCloud
   (logic `data()` đã có, Main chưa nối); animation di chuyển/
   đánh; chọn đội/vũ khí trước trận.
3. Tile riêng Map003–018 (đang PROVISIONAL); camera zoom trận
   MarketBattle (lưới đang nhỏ giữa màn hình).

## 12. G4 bước 5 — Lưu giữ sạp + Danh vọng trận vào SaveCloud — XONG (20/11 ~14:50–15:05)

### 12.1 Nối Main ↔ PxbMarketBattle ↔ SaveCloud

- `scripts/battle_scene.gd`: thêm `signal battle_finished(winner)`
  (phát trong `_on_battle_finished`, sau khi `_last_action` cập
  nhật) — Main nghe để ghi kết quả trận, không sửa luật.
- `main.gd`:
  - `battle_state: Dictionary` bền theo phiên + `_battle_saved`
    (chống ghi 2 lần nếu `_finish_battle` bị gọi lại).
  - `_start_battle_demo()`: `expire_holds(battle_state, day)` rồi
    `battle_mb.from_data(battle_state)` — trận demo mới khôi phục
    giữ sạp + lịch sử từ save trước; nối
    `battle_scene.battle_finished → _on_battle_finished`.
  - `_on_battle_finished(winner)`: `battle_state =
    battle_mb.data()`; Danh vọng đội Bạn lấy từ
    `battle.result.rewards.teamA.famePerFighter` (thắng +50 /
    hòa +20 / thua +10, đúng luật) cộng vào `fame` + cập nhật
    HUD + toast ("Trận kết thúc — Danh vọng +50. Giữ sạp
    sap-cho-dau-moi đến ngày 8." khi đội Bạn thắng trận tranh sạp).
  - `_collect_system_data()`: thêm `"pxb_marketbattle": battle_state`
    (JSON-safe: holds + history đã qua `from_data` lọc).
  - `_apply_save_data()`: khôi phục qua `PxbMarketBattle` tạm
    (`from_data` loại hold rác thiếu teamId/ngày + history thiếu
    `result`), rồi `expire_holds(battle_state, day)` theo ngày
    vừa tải.
  - `_advance_frame()`: sang ngày game mới thì
    `expire_holds(battle_state, day)` — sạp hết hạn tự dọn, không
    chờ tới lúc mở trận/load save.
- Chưa làm: quyền lợi giữ sạp chưa áp vào Economy (giá sỉ −10% /
  thuế −20% / Danh vọng +10/ngày — `hold_benefits()` đã có, Main
  chưa gọi khi mua bán/ngày mới); animation di chuyển/đánh; chọn
  đội/vũ khí trước trận; chặn thách đấu khi đã giữ sạp khác
  (`can_challenge` đã có, demo chưa gọi).

### 12.2 Test mới + hồi quy

- `tests/g4_battle_save_test.gd`: **31/31 PASS** — thắng (giữ
  sạp đội Bạn đến ngày+7, fame +50, lịch sử 1), save slot 1 →
  xóa trắng state → load khôi phục đúng giữ sạp + fame 50 +
  lịch sử; hòa (+20, giữ sạp không đổi chủ, lịch sử 2); thua
  (+10, đội Chợ giữ sạp thay, lịch sử 3); `is_holding` đúng
  trước ngày hết / sai đúng ngày hết; `expire_holds` dọn 1 sạp;
  `from_data` loại hold rác + history thiếu `result`.
- Hồi quy đầy đủ trên cây gộp (luồng song song sửa vòng 5 cùng
  lúc — xem §12.4): artpass **60/60** (thêm 2 check mới, xem
  §12.3), artpass3 23/23, polish 18/18, artpass4 18/18, G1
  selftest 419/419, G1 playtest 14/14, G2 selftest 87/87, G3
  playtest 95/95, MarketBattle 123/123, battle scene 43/43,
  battle main 15/15, battle AI 34/34, coord+WASD 16/16, hotspot
  37/37, jobs 56/56, inventory+crafting 78/78,
  economy+education 92/92, phonehub 66/66, savecloud 69/69,
  social+titles+story 102/102, tools 155/155, online 91/91,
  ui_wiring 37/37 + 71/71; scene 120 frame exit 0.
- Export web exit 0: pck **6.846.480 byte, SHA `e05e7ed6…`**
  (wasm không đổi `fc74679e…`, single-threaded); HTTP 200 đủ 6
  file. **Lưu ý:** build này đã bị luồng song song xóa khỏi
  `src/godot-build/` lúc 08:00 (xem §12.4) — bản browser-verify
  là build 08:00 của luồng kia (`45686e4c…`, cùng cây code đã
  verify, chỉ khác pck do export lại sau sửa vòng 5).

### 12.3 Hai expectation artpass stale — sửa test, không sửa code

- **Màu overlay Tối:** test đòi `(0.55,0.62,0.9)` nhưng code
  `_daynight_color(2)` trả `(0.7,0.78,0.95)` khi map có ảnh nền
  đêm riêng — là quyết định có chủ ý từ live-check 14:34 (ảnh
  đêm đã tối sẵn ~0.65, MUL 0.7 giữ nhân vật nhìn rõ). Sửa test:
  đòi `(0.7,0.78,0.95)` + check `has_night_bg` đúng trên Map001.
- **Vị trí toast:** test đòi y 700–740 (vị trí cũ vòng 4) nhưng
  code đã dời toast xuống góc dưới-trái (24,1216) theo live-check
  14:34 (y=720 cũ đè cửa/cửa sổ) — luồng vòng 5 đã sửa test
  thành `y >= 1200.0`. Cả hai đều là test lỗi thời so với code
  đã chốt, không phải game sai.
- Bài học đo được: **chuỗi GDScript trong `.pck` export KHÔNG
  grep được** (Godot 4.7 lưu script dạng binary token — grep
  `Trận kết thúc` / `battle_finished` / `Đã sang` đều 0 hit,
  trong khi chuỗi JSON `Khu Công Nhân` vẫn thấy ×3). Muốn chắc
  code mới có trong build thì kiểm tra bằng hành vi chạy thật
  (test headless + browser-verify), không grep pck. Đừng kết
  luận "code chưa vào build" chỉ vì grep không thấy.

### 12.4 Va chạm luồng song song (ghi 20/11 ~15:00)

- Trong lúc vòng này chạy, một luồng khác làm vòng 5 trên cùng
  working copy: `main.gd` đổi 07:51:50 (+295 byte, overlay
  layer 1 + nhãn) và 07:57:44, `iso_map.gd` đổi 07:51:59, chạy
  `--check-only` toàn project lúc 07:55. Hậu quả đo được:
  artpass rớt 1 mục ở lần chạy đầu (màu Tối — test stale, xem
  §12.3), rồi rớt mục toast ở lần sau (code toast đã dời nhưng
  test chưa sửa — luồng kia sửa sau đó); `src/godot-build/`
  bị xóa lúc ~08:00 (luồng kia export lại, pck mới `45686e4c…`,
  6.843.288 byte) làm http.server 8163 trả 404 giữa chừng.
- Cách xử lý vòng này: KHÔNG sửa đè file luồng kia đang đổi;
  chỉ sửa test của mình (artpass màu Tối); kiểm tra marker của
  mình còn nguyên sau mỗi lần file đổi (`battle_state` ×9,
  `signal battle_finished` còn đủ); chạy lại suite liên quan
  trên cây HIỆN TẠI (artpass 60/60, battle save 31/31, G1
  419/419, battle main 15/15, scene 120 frame exit 0) sau khi
  cây ổn định (không còn Godot nào chạy, mtime đứng yên).
- **Deploy gh-pages CHƯA làm trong vòng này** (tránh đè deploy
  của luồng kia như vụ §8.4): staging trên đĩa vẫn là bản
  artpass4 `101dda2e…`; bản verify trình duyệt là build 08:00
  `45686e4c…` của luồng kia (cùng cây code đã verify). Vòng sau:
  export lại từ cây ổn định, rebuild staging, deploy 1 lần.
- Script `pxb-browser-verify-battle.py` đã sửa theo bài học
  §8.5: chờ `#start-btn:not([disabled])` + click qua selector +
  xác nhận `window.__pxb_start === true` (thử lại 3 lần) thay
  vì click tọa độ (360,665) — lần chạy đầu vòng này click tọa
  độ trượt, 5 ảnh đều ở title dù engine đã chạy.
- **Browser-verify thật build 08:00** (Chromium 1255 +
  swiftshader, 720×1280, `pxb-browser-verify-battle.py` đã sửa):
  engine-start OK, start-clicked OK, **0 console error, 0
  pageerror** — ảnh `hidden_files/pxb-browser-verify-2026-11-20/13-battle-open.png`:
  trận mở đúng (BỤI ĐỜI CHỢ CÁ, Đội Bạn 100% — Đội Chợ Đầu Mối
  100%, Vòng 1/12, lưới + ô xanh + 2 nút). Phát hiện nhỏ (không
  chặn): nhãn tên đấu sĩ còn hơi chồng nhau ("Cô Tư"/"Bạn Thân").

### 12.5 QUYẾT ĐỊNH ONLINE — Godot headless dedicated server (Bậc 1, 20/11 ~15:00)

- Quyết (Center, Bậc 1 — điểm `opensource-engine.md` §3.4 mục 4
  hẹn "quyết sau khi slice Godot chạy", nay slice đã chạy +
  browser-verify): **online dùng Godot headless dedicated
  server + WebSocket**, không giữ server .NET 8 làm đường chính.
- Lý do: (1) Web export bắt buộc WebSocket (trình duyệt không
  mở được UDP thô) — Godot có `WebSocketMultiplayerPeer` sẵn;
  (2) VM này không có dotnet SDK nên server .NET 8 không
  build/chạy/verify được ở đây — viết endpoint mới đều là nợ
  chưa verify; (3) dedicated server chạy + verify được ngay
  trên VM bằng cùng binary 4.7.2, dùng chung luật GDScript
  (PxbMarketBattle, Economy…) thay vì viết lại bằng C#.
- Server .NET trong `src/server/` giữ lại làm tham chiếu, không
  xóa; `PxbOnline` giữ nguyên trạng thái báo offline thật cho
  tới khi server mới có endpoint.
- Bước tiếp theo (G4 bước 6): server skeleton — `src/godot/server/`
  chạy headless (`--headless --dedicated-server` hoặc scene
  server riêng), WebSocket, chat relay + presence 2 người chơi,
  test headless 2 instance (server + client) đổi được 1 tin
  nhắn; rồi nối `PxbOnline` sang endpoint mới thay cho .NET.

## 13. Việc tiếp theo — G4 bước 6

1. **Deploy gh-pages bản đã verify** (build 08:00 `45686e4c…`
   hoặc export lại từ cây ổn định — rebuild staging rồi deploy
   1 lần, kiểm tra head gh-pages trước khi push từng batch để
   không đè luồng khác).
2. **G4 online thật — server skeleton** (xem §12.5): Godot
   headless dedicated server + WebSocket, chat relay + presence.
3. Quyền lợi giữ sạp áp vào Economy (`hold_benefits` đã có,
   Main chưa gọi); animation di chuyển/đánh trận; chọn đội/vũ
   khí trước trận; `can_challenge` ở demo.
4. Tile riêng Map003–018 (đang PROVISIONAL); camera zoom trận
   MarketBattle (lưới đang nhỏ giữa màn hình); nhãn tên đấu sĩ
   trong trận còn hơi chồng nhau (ảnh browser-verify 13).

## 14. Art pass 5 — vòng sửa 5 (20/11 ~15:00–16:30, kiểm live 14:34–14:40)

6 điểm từ kiểm live 14:34–14:40, điểm 1 là LỖI GỐC (chia đôi
sáng/tối ở khu TẠP HÓA). Sửa xong, tự xem ảnh thật cả 3 khung
ở khu TẠP HÓA (portrait + desktop), deploy lại.

### 14.1 Lỗi gốc: chia đôi sáng/tối — NGUYÊN NHÂN THẬT (không phải overlay 1 tấm)

Điều tra bằng đo pixel (script `/tmp/repro5.py`, staging build):
- Ảnh đêm `bg_map001_night.jpg` tự nó đã tối đều cả 3 cửa hàng —
  ảnh đêm không phải nguồn chia đôi.
- Pixel cùng 1 điểm tường Sáng (131,72,46) → Chiều (131,59,25)
  = đúng ×(1.0, 0.82, 0.55) màu overlay Chiều → overlay MUL
  ĐÃ phủ đều cả nền. Không có chuyện overlay chỉ phủ 1 tấm.
- Nguồn chia đôi thật: **`ground_wide.jpg` có gradient sáng
  trái→phải** (cột trái ~119, phải ~174 R) + `sky_wide.jpg`
  gradient xanh→ấm (cố ý, mặt trời) — mắt đọc thành "phải
  sáng hơn" ở mọi khung, mạnh nhất ở Tối (đất phải sáng hơn
  trái ~30 đơn vị). Tối ở spawn đo: đất L=70 R=100.
- **Cách sửa đúng (vẫn là (b) nhưng tận gốc):**
  1. `ground_wide.jpg`: san phẳng gradient ngang bằng PIL
     (gain từng cột, clip [0.85, 1.18]) — cột trái/giữa/phải
     110.6/137.4/141.8 → 129.9/132.2/131.3. Backup gốc
     `/tmp/ground_wide_orig.jpg`.
  2. `bg_map001.png`: xóa mặt trời vẽ sẵn trong ảnh (vùng
     x 855–1045, y 5–175, nội suy ngang + blur 4px) vì mặt
     trời nay neo camera sẽ vẽ chồng lên. Backup
     `/tmp/bg_map001_orig.png`. Biển PHỞ BÒ/CÀ PHÊ/TẠP HÓA
     không động vào.
  3. `main.gd`: overlay lên **layer 1** (trước là 0), tạo
     TRƯỚC `_label_layer`/`_ui_layer` (cùng layer 1) nên
     render trên mọi nội dung canvas mặc định nhưng dưới
     nhãn/HUD/điện thoại — 1 lớp phủ duy nhất, phủ đều nền +
     nhân vật + đất.
- **Kiểm chứng:** đo sáng ở khu TẠP HÓA (click-to-move sang
  phải, Chromium local, portrait 720×1280): Sáng mặt tiền
  L=115 R=114, Chiều 107/106, Tối 41/44 (lệch 1–3, trước đây
  lệch ~30); đất lệch ≤10. Tự xem ảnh: Tối tối đều toàn màn
  hình, không còn đường chia dọc, không cửa sổ cắt đôi.

### 14.2 Nhân vật Tối không còn bóng đen

- Nguyên nhân: overlay 0.55 × tint riêng 0.42 = 0.23 độ sáng
  → bóng đen chỉ còn mắt trắng (ảnh r5-05).
- Sửa: bỏ hẳn `_update_character_tint` (nhân vật luôn trắng,
  chỉ overlay MUL làm nhiệm vụ tối); overlay đêm nới lên
  **(0.7, 0.78, 0.95)** khi có ảnh nền đêm, (0.55, 0.62, 0.9)
  khi không. Ảnh Tối thật: mặt/quần áo đọc được (áo xanh
  nam, áo xanh lá nữ, bà ba tím Cô Tư), hòa vào nền đêm.
- Test `artpass_test.gd` đã chờ sẵn giá trị (0.7,0.78,0.95)
  từ quyết định kiểm live — code nay khớp test.

### 14.3 Nhãn — đường dịch ngang cũng phải giữ khe 12px

- Lỗi test artpass5: "Góc Chế Tạo đè lên đầu/biểu tượng".
  Probe (`/tmp/probe_labels*.gd`, đã xóa sau khi dùng) cho
  thấy ở trạng thái ổn định nhãn sạch — lỗi chỉ xuất hiện khi
  camera đang smoothing: resolver dùng `intersects()` thuần
  ở đường dịch ngang nên chấp nhận vị trí chỉ cách nhãn Cô Tư
  4px (muốn x 293 → dịch +160 → x 453, y giữ 919, khe dọc
  với Cô Tư chỉ 4px).
- Sửa `main.gd` `_resolve_label_overlaps`: đường dịch ngang
  kiểm `cand.grow(LABEL_GAP).intersects(...)` (giữ khe 12px
  cả 2 chiều với vật cản + nhãn đã đặt); không dịch được thì
  rơi về `best_y` (đã giữ gap). `LABEL_GAP` 4 → **12**,
  `LABEL_BOTTOM_MAX` 1200 (trước 1264), vật cản đầu
  (-48,-165, 96×115), thêm vật cản icon 48×48 cho
  hotspot/craft/door để nhãn không che sao xanh/cửa.
- Cột đèn lồng NadiaScene dời tile (10,10) → (2,10)
  (`nadia_scene.gd`, `iso_map.gd` night_glow.lamps) — hết
  cột đen xuyên nhãn "Cửa ra Chợ Đầu Mối".
- Sửa test: kiểm neo camera trước đây set trực tiếp
  `_camera.position` — vô nghĩa vì `Main._process` đặt lại
  camera theo người chơi mỗi frame (nên kiểm mặt trời chỉ
  đi +91 thay vì +200). Nay dịch chuyển NGƯỜI CHƠI
  (`player.place(..., (10,5))` rồi về (4,5)) và so sánh vị
  trí MÀN HÌNH của mặt trời/trăng (bất biến khi camera neo
  đúng), chờ camera smoothing ổn định (frame ≥60/90/150).

### 14.4 Mặt trời/trăng neo camera + toast góc dưới + điện thoại

- `scripts/sky_effects.gd`: mặt trời/trăng neo camera qua
  `_cam_anchor` (màn hình Sáng (170,290), Chiều (330,290),
  trăng (400,300) — dưới HUD ~190, trên mái); `_process`
  redraw lại khi camera dịch >2px (trước chỉ khi người chơi
  di chuyển ở frame 1). Trăng không còn bị cắt nửa ở mép
  trái khi camera ở TẠP HÓA (ảnh v5c-04: trăng tròn đầy đủ,
  sao rõ, đèn lồng đỏ sáng, cửa sổ vàng).
- Toast đổi khung: (24,1216), font 24, 440×40 — góc dưới
  trái, không che mặt trời/trăng/cửa (ảnh v5-portrait-03).
- Điện thoại: content scroll 224 → **238** (7 dòng danh bạ
  × ~34px, "Anh Ba — chưa quen" hiện đủ), actions scroll
  216 → 192 (tổng chiều cao VBox không đổi). Ảnh v5c-06:
  đủ 5 dòng, nút "Trò chuyện" không đè dòng cuối, khối
  "Hôm nay" lấp khoảng trống, panel không còn đè nút HUD.

### 14.5 Kết quả verify vòng 5

- `g4_artpass5_test` **17/17 PASS** (mới: overlay layer/trật
  tự/MUL/full-screen, toast góc dưới, scroll 238/192, mặt
  trời/trăng neo camera, nhãn không chồng/khe ≥10/đáy ≤1200).
- Hồi quy: artpass 60/60, artpass3 24/24, artpass4 19/19,
  G1 419/419, G2 87/87, G3 95/95, MarketBattle 123/123,
  battle scene 43/43, coord/WASD 16/16, battle AI 34/34.
- `--check-only` exit 0; export Web exit 0, pck 6.843.288
  byte SHA `45686e4c195b`, wasm không đổi `fc74679e3b97`.
- Chromium local (Playwright, swiftshader), 0 console error,
  0 page error, 2 viewport: portrait 720×1280 (click-to-move
  sang phải) + desktop 1920×1080. Ảnh
  `visual-check/artpass5/v5c-01..06.png` (portrait, TẠP HÓA
  cả 3 khung + Tối spawn + điện thoại), `v5-*.png` (desktop
  + portrait đợt đầu), `probe-*.png` (điều tra focus).
- **Hạn chế harness (không phải lỗi game):** trong Chromium
  swiftshader của máy ảo, giữ phím WASD không di chuyển
  (đã kiểm: focus canvas vẫn là `activeElement`, input map
  đúng physical_keycode 68; F/P qua `_unhandled_input` vẫn
  chạy, click-to-move chạy). Headless `g4_coord_wasd_test`
  16/16 PASS + kiểm live bằng browser thật 13:53 đã xác nhận
  "W/D/A và mũi tên đều đi được" — vòng 5 không động vào
  `player.gd`/input nên đây là giới hạn của harness đo, không
  phải hồi quy. Đo sáng desktop trả 0 (drawImage canvas
  WebGL trống sau frame) — chỉ là lỗi đo, ảnh desktop vẫn
  hiện game bình thường.

## 15. Việc tiếp theo — G4 bước 6 (sau artpass5)

1. **Deploy gh-pages bản artpass5** (build 08:00 `45686e4c…`,
   wasm `fc74679e…` không đổi — chỉ re-chunk pck).
2. **G4 online thật — server skeleton** (xem §12.5): Godot
   headless dedicated server + WebSocket, chat relay + presence.
3. Quyền lợi giữ sạp áp vào Economy (`hold_benefits` đã có,
   Main chưa gọi); animation di chuyển/đánh trận; chọn đội/vũ
   khí trước trận; `can_challenge` ở demo.
4. Tile riêng Map003–018 (đang PROVISIONAL); camera zoom trận
   MarketBattle (lưới đang nhỏ giữa màn hình); nhãn tên đấu sĩ
   trong trận còn hơi chồng nhau (ảnh browser-verify 13).
5. Nhãn "Cửa ra/Góc Chế Tạo/Bạn Thân" ở TẠP HÓA xếp chồng dọc
   giữa mặt tiền cửa hàng (không chồng nhau, có khe — nhưng
   nhìn như khối nổi trên cửa); cân nhắc neo nhãn gần điểm neo
   hơn thay vì đẩy lên cao khi va đầu nhân vật.
