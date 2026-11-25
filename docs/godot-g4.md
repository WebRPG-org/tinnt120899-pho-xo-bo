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

1. **Deploy gh-pages bản artpass5 — XONG 20/11 ~16:30** (main
   `a6899a8c`, gh-pages head `59bb6e25`, 3 lô: `6f413d79` +
   `a5277a95` + `59bb6e25`; index.html + pck 000/025/050 +
   wasm 000 khớp byte 5/5 với staging; pck `45686e4c`,
   wasm `fc74679e` không đổi). Link live:
   https://tinnt120899.github.io/pho-xo-bo/ (Pages rebuild
   vài phút sau push).
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

## 16. G4 bước 6 — Server skeleton online thật — XONG (20/11 ~15:45–16:00)

### 16.1 Code mới (chỉ thêm file, không sửa file cũ)

- `src/godot/server/pxb_server.gd` — `class_name PxbServer`
  (Node): dedicated server headless + WebSocket, giao thức JSON
  v1. `start_server(port)` (mặc định 8765), `stop_server()`,
  `poll()` (gọi từ `_process`; test gọi tay cũng được),
  presence (`hello` → `welcome` + broadcast `presence`),
  chat relay (`chat` → broadcast cho mọi client ĐÃ ĐĂNG KÝ),
  `bye` + mất kết nối → xóa presence + broadcast. Gói sai
  JSON / type lạ / chat khi chưa hello / text rỗng hoặc >500
  ký tự / tên >30 ký tự (cắt) / player_id rỗng → bỏ lặng, đếm
  `dropped_packets`, server không crash. CHƯA có auth
  (player_id do client tự khai — chỉ dùng nội bộ); server
  KHÔNG quyết tiền/đồ của ai (chat + presence chỉ là relay).
- `src/godot/server/server_main.gd` (SceneTree): chạy server
  thật — `godot --headless --path src/godot
  -s res://server/server_main.gd -- --port 8765`; log 1 dòng
  khi có người vào/ra/chat.
- `src/godot/tests/g4_online_server_test.gd`: test headless
  socket thật qua loopback (không stub).
- `src/godot/tests/g4_online_server_probe.gd`: probe client 2
  tiến trình (`--port/--player-id/--name/--chat/--listen`).

### 16.2 Verify thật đợt này

- `--check-only` exit 0: `pxb_server.gd`, `server_main.gd`,
  `g4_online_server_test.gd`, `g4_online_server_probe.gd`
  (lần đầu báo `PxbServer` không khai báo — cache class cũ;
  chạy `--headless --import` rồi check lại thì hết, đúng bài
  học §8.3).
- **Test server 37/37 PASS** (socket WebSocket thật
  127.0.0.1:18765): mở cổng, cổng trùng/sai thì lỗi, 0 người
  lúc đầu; A+B nối, welcome peer_id > 0, presence 2 người,
  chat A → B nhận đúng player_id/tên + A nhận echo; B ngắt →
  presence về 1 người; C chat khi chưa hello / gói sai JSON /
  type lạ / chat rỗng đều bị bỏ, không tới A; tên 40 ký tự
  cắt về 30; cuối trận server vẫn chạy, 2 người, 1 tin chat.
- **2 tiến trình thật:** server `server_main.gd` chạy riêng
  cổng 18765 + 2 probe riêng (sender `--chat
  HELLO-TU-2-PROCESS`, listener `--listen 20`): sender
  welcome players=2 + echo chat, listener nhận đúng tin chat
  từ Probe A, server log đủ +vào/ra/chat, cuối 0 người online.
  Cả 3 tiến trình exit 0, đã kill server sau khi xong.
- Hồi quy: G2 online 91/91, battle save 31/31, G1 selftest
  419/419, G2 selftest 87/87, G3 playtest 95/95, MarketBattle
  123/123, artpass 60/60, artpass5 17/17; scene Main 120 frame
  exit 0, không ERROR.
- **2 lỗi log đã sửa trong vòng này:** (1) broadcast target 0
  gửi cả cho socket vừa ngắt → engine báo `ready_state !=
  STATE_OPEN` — nay broadcast chỉ gửi từng peer ĐÃ ĐĂNG KÝ;
  (2) gói sai JSON làm `JSON.parse_string` in ERROR — nay chặn
  trước bằng kiểm tra chuỗi bắt đầu `{` + kết thúc `}`. Sau
  sửa, test 37/37 chạy sạch, 0 ERROR.
- **Quirk check-only (không phải lỗi game):**
  `--check-only --script res://main.gd` báo lỗi suy kiểu ở
  `scripts/sky_effects.gd:105` (`var sc`/`var sr` trong
  `_draw_moon`) rồi kéo theo iso_map/main compile fail — nhưng
  check-only riêng `sky_effects.gd` exit 0 và scene Main chạy
  120 frame exit 0 (compile đủ project vẫn đúng). Đây là lỗi
  suy kiểu giả khi biên dịch main.gd đơn lẻ, KHÔNG sửa code
  artpass5 vì nó. (Ghi để vòng sau không tưởng game hỏng.)

### 16.3 Va chạm luồng song song (ghi 20/11 ~15:50)

- Trong lúc vòng này chạy, một luồng khác (v6 — file
  `visual-check/check_v6d_title.py`, `tests/v6_*`) sửa cùng
  working copy: `main.gd`, `iso_map.gd`, `nadia_scene.gd`,
  `sky_effects.gd`, `project.godot` đổi ~08:51 UTC;
  `src/godot-build/` export lại 08:52 (pck 6.849.684 byte,
  trước đó 6.843.288 byte `45686e4c…`). Vòng này KHÔNG export
  đè lên build đó và KHÔNG deploy gh-pages (tránh đè deploy
  của luồng kia, như vụ §8.4). File server của vòng này tạo
  trước 08:52 nên có thể đã nằm trong pck 08:52 — nhưng chuỗi
  GDScript trong pck không grep được (§12.3), nên vòng sau
  export lại từ cây ổn định rồi mới kết luận. Hồi quy chạy sau
  các sửa của luồng kia vẫn PASS hết.
- **Export web CHƯA làm trong vòng này** (lý do trên) — vòng
  sau export lại từ cây ổn định, verify rồi deploy 1 lần.
- **Deploy gh-pages CHƯA làm** — chờ export vòng sau.

## 17. Việc tiếp theo — G4 bước 7

1. **Export lại từ cây ổn định + deploy gh-pages** (staging
   hiện là bản artpass5 `45686e4c…`; build trên đĩa đã là bản
   08:52 của luồng v6 — kiểm tra pck SHA + head gh-pages trước
   khi push từng batch, không đè luồng khác).
2. **Nối PxbOnline sang server Godot mới** (thay endpoint .NET):
   client WebSocket trong game (`PxbOnline` thêm transport WS
   hoặc client mới dùng chung protocol v1: hello/chat/presence)
   + hiển thị trạng thái online + chat trong điện thoại (tab
   Tin nhắn); giữ endpoint HTTP .NET làm fallback cho tới khi
   WS ổn định.
3. Quyền lợi giữ sạp áp vào Economy (`hold_benefits` đã có,
   Main chưa gọi); animation di chuyển/đánh trận; chọn đội/vũ
   khí trước trận; `can_challenge` ở demo.
4. Tile riêng Map003–018 (đang PROVISIONAL); camera zoom trận
   MarketBattle (lưới đang nhỏ giữa màn hình); nhãn tên đấu sĩ
   trong trận còn hơi chồng nhau (ảnh browser-verify 13).
5. Server: auth player_id (hiện tự khai), giới hạn tốc độ chat
   (chống spam), lưu lịch sử chat cho client mới vào (hiện chỉ
   giữ 100 tin trong RAM).

## 18. Art pass 6 — vòng sửa 6 (20/11 ~16:00–17:30, kiểm live 15:18–15:24)

### 18.1 Lỗi chia đôi sáng/tối — NGUYÊN NHÂN GỐC ĐÃ TÌM RA (không phải ảnh hẹp)

- Live 15:18 báo dải sáng ~10–15% mép phải cuối TẠP HÓA ở Tối/Chiều; vòng 5 đo ở GIỮA khu nên lệch 1–3 là đúng nhưng sai chỗ.
- Tái hiện bằng click-to-move (giữ phím WASD không di chuyển trong Chromium swiftshader trên máy ảo — đã biết, headless 16/16 PASS; F đổi khung vẫn chạy vì `_unhandled_input` là event-driven, còn `_held_dir()` poll `Input.is_action_pressed` nên phím nhấn nhanh lọt giữa 2 frame ở FPS thấp): 5 click (600,1100) đưa người chơi tới ô (10,1) — cuối map phải.
- Đo pixel TẠI DẢI ĐÓ (trước sửa): ground Tối nhảy +26 tại đúng x=527 (99.8 → 125.8), Chiều cũng nhảy tại x=527 (103.0 → 125.8). Ranh giới trùng khớp `(720 − camera_x) × 1.4 + 360 = (720−600)×1.4+360 = 528`.
- **Nguyên nhân gốc: `_overlay_layer.follow_viewport_enabled = true`** (main.gd, thêm ở vòng 5). CanvasLayer follow_viewport bám theo camera nên ColorRect (0,0)–(720,1280) thành hình chữ nhật THẾ GIỚI x 0..720, không phải màn hình. Lúc spawn camera x=280, overlay phủ màn hình −32..976 (đủ) nên không thấy lỗi; camera sang phải cuối map x=600 thì overlay chỉ phủ tới màn hình x=528, phần phải x>528 thoát lớp phủ → sáng như ban ngày. Ảnh nền/đất/overlay đều đủ rộng (geometry probe: mép phải nhìn thấy 857 < mép ảnh 872) — giả thuyết "ảnh đêm hẹp hơn" là SAI.
- **Sửa:** xóa `follow_viewport_enabled = true` (mặc định false = không gian màn hình, ColorRect 720×1280 phủ kín màn hình bất kể camera). **LUẬT: không bao giờ bật follow_viewport cho lớp overlay toàn màn hình.** Lưới an toàn: `default_clear_color` đổi từ be sáng (0.78,0.70,0.55) sang tối (0.10,0.12,0.18) để mọi khoảng hở tương lai đọc tối, không sáng.
- **Verify sau sửa (đo đúng mép phải cuối map):** Tối ground phải 101–103 (trước 129), Chiều 106 (trước 129); lệch so với giữa khung <10 mọi dải (sky/facade/ground, cả 3 khung); không còn bước nhảy tại x=527 (cột 500–560 đều 92–100 Tối, 95–103 Chiều). Test `tests/v6_overlay_test.gd` 16/16 PASS (kiểm tra hành vi: đưa camera ra (600,174), `get_global_rect()` của overlay vẫn (0,0)–(720,1280)).

### 18.2 Các điểm còn lại (theo báo cáo live 15:18)

- **Mặt trời/trăng sticker:** `sky_effects.gd` vẽ lại bằng `_draw_soft_disc` — gradient xuyên tâm 14 vòng alpha tăng dần vào trong (không còn đĩa phẳng + quầng cứng), đĩa có độ đậm nhạt ở rìa, vết lõm trăng vẽ mềm 3 vòng; dời lên y=240 màn hình (giữa dải trời, không đè mái/biển ở cả spawn lẫn cuối map). Test kiểm tra vị trí màn hình (170,240) Sáng / (400,240) Tối.
- **Nền 3 dải cắt thẳng:** feather 50px cuối `bg_map001.png` + `bg_map001_night.jpg` (alpha smoothstep → 0). Ảnh đêm đổi sang PNG (`bg_map001_night.png`, `iso_map.gd` cập nhật đường dẫn, xóa `.jpg` + `.import` cũ + cache `.godot/imported` — `ResourceLoader.exists` vẫn báo có nếu còn `.import`).
- **Nút bắt đầu kẹt 100%:** `onProgress` tới 100% nhưng `.then()` chỉ chạy sau khi wasm compile xong → nút kẹt ở "Đang tải game… 100%" (disabled). Sửa: đạt 100% đổi nhãn "Đang khởi động game…"; watchdog 12s không tiến độ → "Đang tải chậm — mạng yếu, vẫn đang tải…"; `.then()`/lỗi tắt watchdog.
- **Nhãn bị cắt ở mép trái khi camera sang phải:** đã kiểm tra — nhãn đã kẹp đúng (x ≥ 16, y ≥ 190) trong ảnh v6c-08, không còn bị cắt; không sửa thêm.
- **Xe đạp/chậu cây mép dưới cắt nửa:** xe đạp (12,9) + xe đẩy (8,13) nằm ngay mép dưới vùng nhìn thấy lúc spawn (thế giới y 654, mép 631) → dời xuống 2 ô: (12,11) + (8,15) (y 686, nằm hẳn dưới vùng nhìn thấy lúc spawn, hiện đủ khi đi xuống cuối map). Chậu cây (11,12) đã ở y 686 nên giữ nguyên.
- **Desktop + tiêu đề caro be trống:** `web_shell.html` tải tranh vẽ tay `title_bg.jpg` (nén từ `title_bg.png`, 119KB) làm nền overlay tiêu đề (cover) + nền 2 panel desktop (lớp kem mờ 0.88 để chữ đọc được); thẻ tiêu đề thành panel giấy mờ ở dưới màn hình; 2 nhân vật chibi (char_player.png / char_banthan.png) đứng 2 bên nút. Ảnh phục vụ qua fetch: local có file thật cạnh index.html; gh-pages loader ráp từ chunk (xem §18.3).

### 18.3 Deploy: ảnh tiêu đề chunk như wasm/pck

- `tools/godot/build_gh_pages.py` thêm `IMG_PARTS`: chunk base64 `title_bg.jpg` (1 chunk) + `char_player.png` (2) + `char_banthan.png` (2) vào `staging/img/<tên>/`; loader mở rộng fetch-override phục vụ 3 tên file với đúng Content-Type. Verify ráp lại khớp byte.
- Export web vòng này: exit 0, pck 6.849.684 byte SHA `6d668deb…`, wasm không đổi `fc74679e…`.
- Deploy gh-pages: main `7c5bb35f`; gh-pages 3 batch `e1a8db75` (index.html + pck 000–018) → `7324e001` (pck 019–037) → `2288401c` (pck 038–050 + 5 chunk ảnh); wasm 293 chunk không đổi nên không push lại. Verify khớp byte 6/6 mẫu remote-vs-staging (index.html, pck 000/025/050, img title_bg + char_player).

### 18.4 Verify vòng 6 (đầy đủ)

- `--check-only` 5 file sửa/mới exit 0 (main.gd, sky_effects.gd, nadia_scene.gd, iso_map.gd, v6_overlay_test.gd).
- Test: v6 16/16, artpass 60/60, G1 419/419, G2 87/87, G3 95/95, MarketBattle 123/123 — 0 FAIL.
- Chromium local (swiftshader, 0 console error): driver click-to-move tới (10,1), đo pixel mép phải 3 khung (xem §18.1); ảnh tiêu đề desktop 1920×1080 (tranh + 2 nhân vật + nút) + trong game desktop (2 panel tranh mờ); ảnh Tối/Sáng cuối map đã xem trực tiếp.
- Hạn chế harness đã biết (ghi lại, không phải hồi quy): giữ phím WASD không di chuyển trong Chromium swiftshader trên máy ảo; click-to-move + F vẫn chạy; đã dùng click-to-move để lái.

### 18.5 Việc tiếp theo

- Chờ kiểm live trên https://tinnt120899.github.io/pho-xo-bo/ (sau khi Pages rebuild bản deploy vòng 6) rồi mới báo chủ.
- G4 bước 7 (nối PxbOnline sang server Godot mới) theo §17.

## 19. Art pass 7 — vòng sửa 7 (20/11 ~17:30–18:30, kiểm local Chromium 18:0x)

Live 16:01–16:26 (bản artpass6): chia đôi sáng/tối ĐÃ HẾT, tiêu đề đã có tranh — vẫn CHƯA đủ đẹp như Nadia. 6 điểm, làm theo thứ tự.

### 19.1 Điểm 1 — Nhãn kẹt "buổi tối" — NGUYÊN NHÂN GỐC (không phải save/load)

- Nhãn "Hẻm trọ buổi tối" là TÊN TĨNH của hotspot `hs-tro-toi` (best_frame "Tối", port từ `Exploration.cs`): `scripts/pxb_hotspot.gd` HOTSPOTS + `data/maps.json:336`. Nhãn được set 1 lần lúc tạo marker, không cập nhật khi đổi khung.
- **Sửa (`scripts/marker.gd`):** marker giữ `_base_name` (tên gốc) + `_frame_name` (khung hiện tại); `_display_name()` thay từ "buổi …" trong tên bằng khung hiện tại (`.to_lower()` — "buổi sáng", không "buổi Sáng"); `set_frame_name(f)`; `Main._update_daynight()` gọi `set_frame_name(_frame_name())` cho mọi marker mỗi lần đổi khung. `_base_name` lazy-fallback trong `_display_name()` vì `_ready` không chạy với node thêm trong `SceneTree._init` (test headless). Dữ liệu canonical không đổi.
- **Caveat thiết kế (chờ quyết):** nhãn động không còn báo best frame nữa (độ sáng sparkle 1.5× + toast nhặt đồ vẫn báo). Nếu muốn giữ tín hiệu best frame, đổi tên hotspot thành trung tính ("Hẻm trọ") thay vì từ "buổi" động.
- **Verify live local:** Sáng "Hẻm trọ buổi sáng" (a7-02) → Chiều (a7-08) → Tối "Hẻm trọ buổi tối" (a7-09) → Ngày 2 Sáng "Hẻm trọ buổi sáng" (a7-10). Test `tests/g4_artpass7_test.gd` 25/25 (chuỗi Sáng→Chiều→Tối→Sáng + reload, tên NPC/không-khung không đổi).

### 19.2 Điểm 2 — Di chuyển bàn phím không ổn định — NGUYÊN NHÂN GỐC: polling

- `Player._process` poll `Input.is_action_pressed`; ở FPS thấp (swiftshader ~5fps) phím nhấn nhanh lọt giữa 2 frame → mất. F/P chạy vì event-driven trong `_unhandled_input`.
- **Sửa:** `player.gd` thêm `press_dir()`/`release_dir()`/`clear_held_dirs()` + `_held_dirs` (hướng event-held được kiểm tra trước trong `_held_dir()`, poll Input giữ làm fallback); `main.gd` `_key_to_dir(event)` (physical_keycode trước — Shift+D vẫn là KEY_D vật lý — rồi keycode) hook trong `_unhandled_input` (nhấn bước ngay, nhả xóa); `web_shell.html` focus handler (pointerdown/keydown focus canvas, vì nút DOM "Bắt đầu chơi" giữ focus).
- **Verify live local (Chromium, ERRORS: 0):** giữ D (a7-03), giữ W (a7-04), Shift+D (a7-05), ArrowRight (a7-06) — camera/người chơi đều di chuyển. Click-to-move ở a7-07 không kết luận được (script click (1400,700) nằm ngoài canvas, trúng panel phải) — không phải lỗi game.

### 19.3 Điểm 3 — Cửa sổ TẠP HÓA sáng cam ở Sáng — NGUYÊN NHÂN: chính ảnh ngày

- `art/bg_map001.png` (1120×630) được gen với cửa sổ sáng ấm. **Sửa:** PIL làm mát/khử bão hòa có chọn lọc riêng phần kính, trong rect đã đo — cửa sổ TẠP HÓA (955,455)–(1045,558), cửa kính TẠP HÓA (800,462)–(892,508), cửa kính đôi CÀ PHÊ (465,465)–(570,540), mask feathered, chỉ pixel cam mạnh (R−B>50, R>150). Ảnh đêm không đụng. Gốc backup `visual-check/artpass7/bg_map001_orig.png` + `ground_wide_orig.jpg` (PNG chỉ sống local + trong pck, không có trong git).
- **Verify live local:** Sáng cửa TẠP HÓA rèm kem nhạt, không phát sáng cam (a7-07); ảnh đêm vẫn sáng vàng đúng (a7-09).

### 19.4 Điểm 4 — Desktop cắt đáy ~200px + 2 bên be trống

- **Nguyên nhân:** camera zoom 1.4 + look-up −320 chỉ thấy tới world y 599 lúc spawn; xe đạp/hoa ở y 686 nằm dưới mép.
- **Sửa:** `main.gd` `CAMERA_ZOOM := 1.25` + `CAMERA_LOOK_UP := Vector2(0,-265)` — thấy y −315..709 lúc spawn (đỉnh mặt tiền −308 tới đáy đất + xe đạp ~702). `web_shell.html`: panel 2 bên có nội dung thật (`.keys`: WASD/mũi tên di chuyển, F đổi khung, P điện thoại, E tương tác, B trận; panel phải: chạm + màu hotspot) trên nền tranh tiêu đề mờ.
- **Verify live local:** đáy spawn thấy đủ xe đạp/chậu cây/xe đẩy (a7-02); panel 2 bên có tranh + chữ (a7-01/a7-02).

### 19.5 Điểm 5 — Mỹ thuật phẳng, thiếu chiều sâu/bóng

- `character_sprite.gd` `set_frame(f)`: bóng đổ ellipse theo khung — Sáng rx 14, lệch (8,3), alpha 0.30; Chiều rx 26, lệch (−22,3), alpha 0.34, bóng dài sang trái; Tối rx 12, alpha 0.12. Vòng vàng người chơi mỏng lại (width 1.5, alpha 0.6, r 40/36).
- `marker.gd` `set_player_on(b)`: ẩn ellipse sáng mặt đất của hotspot khi người chơi đứng trên ô đó (trước đọc như bóng xanh dưới chân); sao vẫn hiện phía trên.
- `nadia_scene.gd` `_draw_facade_light()` + `set_frame(f)` (iso_map forward): wash sáng/tối nhẹ trên mặt tiền Map001 theo hướng nắng (alpha ≤0.10 Sáng, ≤0.14 Chiều, bỏ qua ở Tối). `ground_wide.jpg`: PIL làm sâu vũng nước (sáng 25% trên +14, tối 25% dưới −12 — hiệu quả nhẹ khi xem). Lưu ý: `nadia_scene._draw_ground()` là DEAD code (đất là ảnh `ground_wide.jpg`), nên vũng phải sửa bằng ảnh.
- **Verify live local:** bóng ellipse dưới chân người chơi thấy rõ (a7-03), vũng nước có phản chiếu (a7-06/07), sao hotspot chỉ ở ô hotspot (a7-06).

### 19.6 Điểm 6 — Tải kẹt 15% + ảnh "loading or decoding failed"

- **Nguyên nhân:** chunk loader fetch mỗi chunk base64 đúng 1 lần, không retry, không kiểm tra `r.ok` — 1 chunk lỗi (404 lúc Pages đang rebuild / mạng chập chờn) là cả wasm/pck/ảnh chết, game kẹt 15%.
- **Sửa (`tools/godot/build_gh_pages.py` LOADER_TEMPLATE):** `fetchChunk(u)` retry 3 lần, backoff 400ms×lần, kiểm tra `r.ok` + non-empty, `console.warn` mỗi lần retry. `web_shell.html` `loadTitleArt` dùng `fetchBlobRetry(url, 3)`, warn thay vì nuốt lỗi im lặng. Watchdog 12s đã có từ vòng 6.
- **Verify:** retry chưa được kích hoạt bằng lỗi mạng thật trong lần kiểm này (tải local nhanh, không kẹt) — chỉ kiểm code + tải thành công; ghi lại để không nói quá.

### 19.7 Verify vòng 7 (đầy đủ)

- `--check-only` exit 0 cả 7 file sửa/mới (main.gd, player.gd, marker.gd, character_sprite.gd, nadia_scene.gd, iso_map.gd, g4_artpass7_test.gd).
- Test mới artpass7 25/25; regression: artpass 60/60, G1 selftest 419/419, G1 playtest 14/14, G2 selftest 87/87, G2 hotspot 37/37, G2 phonehub 66/66, G2 MarketBattle 123/123, G3 playtest 95/95, g4_coord_wasd 16/16, artpass3 24/24, artpass4 19/19, artpass5 17/17, v6_overlay 16/16, battle scene 43/43, battle AI 34/34, battle main 15/15, battle save 31/31, polish 18/18 — 0 FAIL. Smoke `--headless --quit-after 120` exit 0, không lỗi.
- Kỳ vọng test cũ sửa theo tiền lệ §12.3 (sửa test, không sửa code): `tests/artpass_test.gd` zoom 1.4 → 1.25; `tests/g4_artpass3_test.gd` ảnh đêm `.jpg` → `.png` (vòng 6 đổi file) + kiểm nhãn không chồng dùng rect ĐÃ RESOLVE (`label_override` nếu có — ở zoom 1.25 rect gốc "Cô Tư" vs "Góc Chế Tạo" chạm nhau nhưng resolver dời mỗi frame, nên phải assert kết quả trên màn hình).
- Export web exit 0: pck 6.858.400 byte SHA `5e424b74…`; wasm không đổi `fc74679e…` (39.514.754 byte).
- Chromium local (script `visual-check/check_artpass7.py`, desktop 1920×1080, server 127.0.0.1:8161): **ERRORS: 0**. Ảnh `visual-check/artpass7/a7-01…a7-11.png` đã xem trực tiếp: tiêu đề có tranh + 2 nhân vật; nhãn đổi đúng Sáng→Chiều→Tối→Sáng; D/W/Shift+D/ArrowRight đều đi; cửa TẠP HÓA Sáng hết sáng cam; đáy đủ; điện thoại 9 tab đầy nội dung.
- Nit còn lại (nhỏ, không chặn): dải tối ~10px ở mép phải cột game trên desktop (a7-06/07/09/10); toast "Ngày 2 • Khung Sáng" đè nhẹ xe đạp ở đáy (a7-10, tự mờ); nhân vật ở Tối vẫn hơi sáng so với đất (a7-09).

### 19.8 Deploy — XONG (20/11 ~16:50)

- Staging đã rebuild sẵn từ artpass7 (pck `5e424b74…`, wasm không đổi,
  `build_gh_pages.py` verify OK) — vòng này chỉ deploy gh-pages, 3 lô:
  `c1388653` (1/3: index.html + pck 000–018), `73da431e` (2/3: pck
  019–037), `f3d59243` (3/3: pck 038–050). gh-pages head `f3d59243`,
  kiểm tra trước mỗi lô khớp head trước đó, không có writer khác đè.
- Verify khớp byte từ site live: index.html khớp staging; 51 chunk
  pck tải về ráp lại **6.858.400 byte, SHA `5e424b743c17` — khớp đúng
  từng byte với build local**. Lưu ý: lần tải đầu 4 chunk 019–022
  lệch (CDN Pages còn cache bản cũ); tải lại vài phút sau thì khớp
  hết — blob SHA qua API (`70ee1586…` cho part-019) khớp staging
  ngay từ đầu, chứng tỏ repo đúng, chỉ CDN chậm. Đừng kết luận
  deploy sai chỉ vì curl ngay sau push thấy lệch — kiểm tra blob
  qua API rồi tải lại sau vài phút.
- Headless smoke trước deploy: `--headless --quit-after 120` exit 0,
  không ERROR. Browser-verify bản này đã làm ở vòng artpass7
  (a7-01..11, ERRORS: 0) — không chạy lại vì cùng pck đã verify.
- Link live: https://tinnt120899.github.io/pho-xo-bo/ (Pages rebuild
  vài phút sau push).

## 20. Việc tiếp theo — G4 bước 7

1. **Nối PxbOnline sang server Godot mới** (xem §17.2): client
   WebSocket trong game dùng protocol v1 (hello/chat/presence) +
   hiển thị trạng thái online + chat trong điện thoại (tab Tin nhắn);
   giữ endpoint HTTP .NET làm fallback cho tới khi WS ổn định.
   Server skeleton đã xong (§16): `src/godot/server/pxb_server.gd`,
   test 37/37 + probe 2 tiến trình.
2. Quyền lợi giữ sạp áp vào Economy (`hold_benefits` đã có,
   Main chưa gọi); animation di chuyển/đánh trận; chọn đội/vũ
   khí trước trận; `can_challenge` ở demo.
3. Tile riêng Map003–018 (đang PROVISIONAL); camera zoom trận
   MarketBattle (lưới đang nhỏ giữa màn hình); nhãn tên đấu sĩ
   trong trận còn hơi chồng nhau (ảnh browser-verify 13).
4. Nhãn "Cửa ra/Góc Chế Tạo/Bạn Thân" ở TẠP HÓA xếp chồng dọc
   giữa mặt tiền cửa hàng (không chồng nhau, có khe — nhưng
   nhìn như khối nổi trên cửa); cân nhắc neo nhãn gần điểm neo
   hơn thay vì đẩy lên cao khi va đầu nhân vật.

## 21. Art pass 8 — vòng sửa 8 (20/11 ~17:10–18:10, kiểm live artpass7 16:52–17:10)

### 21.1 Kiểm live artpass7 — game đứng hình trên trình duyệt thật

- Live check (browser-task f6bc057d, 16:52–17:11, 1920×1000):
  D (hoa + thường, ~18 lần) + ArrowRight (~16 lần) = nhân vật
  đứng yên tuyệt đối; tap-to-move 3 điểm phải (kể cả giữ 10,7s)
  = không nhúc nhích; E gần Cô Tư không mở hội thoại; NPC/lá
  tĩnh hoàn toàn. F (đổi khung) và P (điện thoại) vẫn chạy.
  Tải kẹt "Đang khởi động game…" >20s lần đầu; 2 ảnh tiêu đề
  "loading or decoding failed"; cửa TẠP HÓA Sáng vẫn sáng cam;
  đáy vẫn cắt ở 1920×1000; văn bản landing vẫn lộ 2 bên khi
  đang chơi; biển TẠP HÓA cắt nửa chữ Á ở spawn.
- Trong khi vòng 7 kiểm local Chromium báo D/W/Shift+D/
  ArrowRight đều đi được — phải tìm ĐIỂM KHÁC BIỆT giữa bản
  local và bản live, không sửa mù.

### 21.2 Tái hiện — phát hiện: vòng 7 kiểm SAI BẢN (raw export, không phải staging)

- Vòng 7 kiểm local phục vụ `src/godot-build/` (export thô,
  KHÔNG có chunk loader) — đường loader của gh-pages chưa bao
  giờ được kiểm local. Script mới
  `visual-check/check_artpass8_repro.py` phục vụ staging
  (port 8162) và raw build (8161) song song;
  `check_artpass8_taps.py` nhấn kiểu tap như kiểm live + tap
  vào TRONG canvas.
- Repro trên staging 1920×1000 (~17:20): nút bật ~10s;
  **di chuyển ĐƯỢC** (giữ D 3s đi phải, 10 tap D tới cuối
  TẠP HÓA, tap-to-move trong canvas chạy); F đổi khung đúng
  nhãn + toast; P mở điện thoại; **đáy KHÔNG cắt**; 0 failed
  request; 1 warning WebGL ReadPixels. Test tap của vòng 7
  KHÔNG HỢP LỆ: click (1400,700) nằm NGOÀI canvas (canvas
  x 679–1241 ở 1920 rộng) — cùng lỗi trong script repro đầu
  tiên, đã sửa thành (1150,750).
- Live files lúc ~17:15 đã byte-identical với staging (index.html
  SHA `fbfa8ac4…`, index.js `33c94cb3…`, ráp lại pck live
  6.858.400 byte SHA `5e424b743c17…` = staging). Lần ráp đầu
  sai vì tên chunk 10–50 không `%03d` (5.509.020 byte) — đã
  làm lại đúng.
- **Chẩn đoán (giả thuyết mạnh, chưa chứng minh bằng live
  re-check): live lỗi = CDN trộn pck cũ/mới.** Deploy xong
  ~16:45–16:52; kiểm live chạy 16:52–17:10, đúng trong cửa
  sổ lan truyền. URL chunk CỐ ĐỊNH (`wasm/part-000.txt`…)
  nên CDN Pages cache từng chunk riêng (max-age 600s) và
  trình duyệt ráp pck từ hỗn hợp chunk cũ + mới (chính cron
  16:45 đã thấy chunk 019–022 lệch ở lần tải đầu). Giải
  thích mọi triệu chứng live cùng lúc: `main.gd` cũ (zoom
  1.4 → đáy cắt), `player.gd` cũ (poll-based, lỡ tap ở FPS
  thấp), `marker.gd` mới (nhãn sửa được — live thấy đúng),
  ảnh nền cũ (cửa Sáng vẫn cam). Cache đã ổn định lúc
  17:15 (live = staging).

### 21.3 Sửa gốc — chunk theo phiên bản (versioned chunks)

- `tools/godot/build_gh_pages.py`: version = 8 hex đầu của
  sha256 nội dung; thư mục chunk `wasm/<sha8>/`,
  `pck/<sha8>/`, `img/<tên>/<sha8>/`; loader dùng URL có
  version; ghi `versions.json` vào staging; `verify()` kiểm
  tra thư mục versioned và assert loader dùng đường dẫn
  versioned. Thứ tự deploy: push hết thư mục chunk version
  mới TRƯỚC, verify, push `index.html` CUỐI CÙNG. Mỗi deploy
  thêm ~7MB thư mục version pck (wasm chỉ khi wasm đổi);
  thư mục version cũ mồ côi trên gh-pages, dọn định kỳ.
  Từ nay lỗi trộn CDN không thể xảy ra nữa (URL đổi theo
  nội dung).

### 21.4 Sửa cửa TẠP HÓA buổi Sáng (2 lớp)

- Lớp ảnh — `tools/godot/fix_taphoa_day_windows.py` (tái
  lập được): đo trước — ô cửa ngày R-B +104..+142, cửa sổ
  +48..+147, so với cửa sổ PHỞ BÒ (rèm xanh, không sáng) và
  cửa CA PHE (rèm trắng, không sáng); ảnh đêm có cửa sáng
  (đúng ở đó). Sửa: ô cửa rect (802,396,878,464), pixel
  R>145 & R-B>55, blend 0.85 về kính lạnh; cửa sổ rect
  (928,402,1052,538), pixel R>150 & R-B>70, blend 0.6.
  Kết quả đo: kính ô cửa R-B 104→26 (RGB 161,118,57 →
  132,119,106); giữa cửa sổ 77→50; trung bình rect ô cửa
  91→29, cửa sổ 71→45; đối chứng PHỞ BÒ không đổi (84).
  Chỉ 8.396 pixel đổi, TẤT CẢ trong 2 rect, 0 ngoài rect.
  Mảng xám-xanh trên cửa là CÓ SẴN (vùng (795,330,885,395)
  byte-identical trước/sau: (100,70,46)) — thạch cao cũ,
  không phải do sửa. Backup ảnh gốc
  `visual-check/artpass8/bg_map001_day_before.png`; so
  sánh trước/sau
  `visual-check/artpass8/taphoa-before-after.png`. Ảnh đêm
  không chạm. File sửa: `src/godot/art/bg_map001.png`
  (1120×630) — binary, KHÔNG push được qua snapshot-push,
  chỉ sống trong pck đã deploy.
- Lớp code — `src/godot/scripts/nadia_scene.gd`: hàm tĩnh
  mới `window_glass_color(f)`: Sáng (0.78,0.84,0.88) kính
  lạnh ban ngày; Chiều (1.0,0.84,0.52) ấm; Tối
  (1.0,0.78,0.38) hổ phách sáng đèn. `_draw_window` dùng
  nó. Lưu ý: Map001 KHÔNG dùng `_draw_window` (mặt tiền là
  ảnh composite — sửa bằng lớp ảnh); Map002+ dùng mặt tiền
  code. `set_frame` đã gọi `queue_redraw()` khi đổi khung;
  `_process` redraw mỗi 0.15s.

### 21.5 Sửa còn lại

- **Panel 2 bên ẩn chữ landing khi vào game**
  (`src/godot/web_shell.html`): tiêu đề/phụ panel bọc
  `.panel-title` / `.panel-sub`; CSS
  `body.in-game .side-panel .panel-title,.panel-sub
  { display: none; }` (hộp phím giữ lại làm trợ giúp;
  nền art mờ giữ lại); nút bắt đầu thêm
  `document.body.classList.add('in-game')`.
- **Watchdog phân biệt kẹt biên dịch vs kẹt mạng**
  (`web_shell.html`): theo dõi `lastProgress` trong
  `onProgress`; kẹt >12s hiển thị "Đang khởi động
  game… (lần đầu biên dịch hơi lâu, chờ chút)" nếu tiến
  độ đã tới 100% (biên dịch wasm 39MB, 10–30s trên máy
  chậm), ngược lại "Đang tải chậm — mạng yếu, vẫn đang
  tải…".

### 21.6 Verify vòng 8 (đầy đủ)

- **Quirk môi trường mới (20/11 ~17:35): `--check-only`
  TREO** — chạy 10+ phút, main thread ngủ trong
  `hrtimer_nanosleep`, ~3% CPU, không ghi import mới;
  kill bằng SIGTERM. (Import vẫn hoàn thành trong lần
  chạy đó — export sau chỉ mất 20s.) **Từ nay dùng đường
  test `-s` thay vì `--check-only`.**
- Test mới `src/godot/tests/g4_artpass8_test.gd` 18/18 PASS
  (~17:40, 4s): độ ấm pixel ảnh nền incl. đối chứng đêm,
  màu kính cửa sổ theo khung, `Main._key_to_dir`
  physical/keycode incl. Shift+D, F không phải di chuyển,
  toán fit desktop 1920×1000. 2 WARNING chỉ từ
  `Image.load_from_file` trong chính test — test-only,
  không phải code game.
- Regression đầy đủ, 0 FAIL (~17:40): artpass 60/60, G1
  selftest 419/419, G1 playtest 14/14, G2 selftest 87/87,
  hotspot 37/37, phonehub 66/66, jobs 56/56,
  economy+education 92/92, inventory+crafting 78/78,
  social+titles+story 102/102, tools 155/155, online
  91/91, savecloud 69/69, UI wiring 37/37, UI wiring2
  71/71, MarketBattle 123/123, G3 playtest 95/95,
  artpass3 24/24, artpass4 19/19, artpass5 17/17,
  artpass7 25/25, battle scene 43/43, battle AI 34/34,
  battle main 15/15, battle save 31/31, coord WASD
  16/16, polish 18/18, online server 37/37.
- Headless smoke `--headless --quit-after 120` exit 0,
  không lỗi. Export exit 0: pck mới 6.863.932 byte SHA
  `73ae78df…`, wasm không đổi 39.514.754 byte
  (`fc74679e…`).
- Staging build `build_gh_pages.py` VERIFY OK (~17:42):
  wasm version `fc74679e` (293 chunk, không đổi), pck
  version `73ae78df` (51 chunk), img title_bg `260962c1`
  (1 chunk), char_player `9639c122` (2), char_banthan
  `4750238d` (2); fileSizes khớp build; loader dùng
  đường dẫn versioned. Chunk cũ không version đã xóa
  khỏi staging. Staging: `wasm/fc74679e/`,
  `pck/73ae78df/`, `img/<tên>/<ver>/`, `versions.json`,
  `index.html`, `index.js`, worklets, icons.
- **Browser-verify staging mới**
  (`visual-check/check_artpass8_verify.py`, 1920×1000,
  ~17:50, exit 0, ~149s): **ERRORS: 0, FAILED REQUESTS:
  0**; canvas box 1920×1000; `body.in-game` set + tiêu
  đề panel ẩn = True. Ảnh `visual-check/artpass8/a8-01`
  …`a8-07` đã xem trực tiếp:
  - Di chuyển ĐƯỢC: giữ D 3s + 10 tap D đi tới cuối
    TẠP HÓA, tap-to-move trong canvas chạy, biển "TẠP
    HÓA" hiện trọn, không cắt.
  - Cửa TẠP HÓA Sáng hết sáng cam: đo đúng vị trí ô cửa
    (cùng bước giữ D 3s) R-B 80 (vòng 7) → 57 (vòng 8);
    ảnh gốc 104→26; `.ctex` re-import 10:39:54
    (842.838 byte, từ 841.156), pck ghi 10:39:56 — ảnh
    mới CHẮC CHẮN trong pck. (2 lần đo trước sai hộp đo:
    đo tường thay vì cửa — đo pixel phải đo ĐÚNG VỊ TRÍ.)
  - Khung Tối đúng: trời xanh đậm, trăng + sao, cửa sổ
    TẠP HÓA sáng đèn (ảnh đêm không chạm — đúng), nhãn
    "Hẻm trọ buổi tối", toast "Ngày 1 • Khung Tối" ở đáy.
  - Đáy đủ ở 1920×1000 (xe đạp + chậu hoa thấy trọn);
    panel 2 bên chỉ còn hộp phím, không còn chữ landing.
  - So sánh trước/sau trong game:
    `visual-check/artpass8/taphoa-game-before-after.png`
    (trên = vòng 7, dưới = vòng 8).

### 21.7 Deploy — XONG (20/11 ~18:00–18:10)

- Main `81bb16d3` (9 file: web_shell, nadia_scene,
  g4_artpass8_test mới, build_gh_pages versioned,
  fix_taphoa_day_windows mới, docs §21, 3 script
  visual-check artpass8). Kiểm tra trước push: head main
  vẫn `0662f332` (cron 17:45 chưa push); remote-vs-local
  7 file: 4 file đổi đúng như kỳ vọng, main/player/marker
  identical nên không push; 5 file mới xác nhận ABSENT
  (lưu ý: `get_file_contents` trả `ok:true` cả khi file
  không tồn tại — phải xem `result.isError`).
- gh-pages head `81d88ba0`, 5 lô (thứ tự: chunk version
  mới trước, `index.html` CUỐI): `b67eea16` (pck
  000–016), `855c7e8c` (017–033), `009b536c` (034–050),
  `c2d635d1` (img versioned 5 file + versions.json),
  `81d88ba0` (index.html). **Lỗi mới: push 51 chunk pck
  1 lô 8.8MB bị HTTP 413** (transport MCP nhỏ hơn giới
  hạn 16MiB của CLI) — chia 3 lô ~17 file/lô như vòng 7.
  wasm `fc74679e` KHÔNG push lại (đã có trên gh-pages).
  Trước lô index.html đã verify qua API: 4 mẫu chunk +
  versions.json khớp staging 4/4.
- **Verify khớp byte từ site live — ĐÚNG NGAY LẦN ĐẦU,
  không cần chờ CDN:** index.html live SHA `7facd2b1`
  = staging; versions.json live khớp; ráp 51 chunk pck
  live → **6.863.932 byte, SHA `73ae78dff7e2` = build
  mới**. URL versioned khiến trộn CDN không thể xảy ra
  (chunk mới có URL mới hoàn toàn) — khác vòng 7 phải
  tải lại sau vài phút.
- Link live: https://tinnt120899.github.io/pho-xo-bo/
  (Pages rebuild vài phút sau push; verify trên đã
  thấy bản mới ngay).

### 22. G4 bước 7 — Nối PxbOnline sang server Godot — XONG (20/11 ~17:45–18:30)

### 22.1 Code mới

- `scripts/pxb_online.gd` (G4 bước 7): client WebSocket protocol
  v1 dùng `WebSocketMultiplayerPeer` (đã chứng minh nối được
  PxbServer trong test server). `connect_ws(url, player_id,
  name)` (mặc định `ws://localhost:8765`, id tự sinh
  `pxb-<ms>-<rand>`, tên "Người chơi"), `disconnect_ws()` (gửi
  bye), `poll_ws()` (gọi từ `_process` khi vào cây + gọi tay
  trong test), `send_ws_chat(text)` (chặn ở client: chưa nối /
  rỗng / >500 ký tự), signal `ws_status_changed` /
  `ws_presence_changed` / `ws_chat_received`. Nhắn khi socket
  CONNECTED mới gửi hello; welcome → `ws_connected=true` +
  presence; error server → ngắt. Gói rác không phải JSON object
  chặn trước khi parse (tránh log ERROR như server). KHÔNG tự
  reconnect — bấm nối lại. `data()`/`from_data()` thêm `ws_url`
  / `ws_player_id` / `ws_display_name` / `ws_chat_log` (lọc bẩn:
  tên cắt 30, tin quá dài/thiếu tên thì bỏ, log tối đa 100).
  Đường HTTP .NET giữ nguyên làm fallback — WS chỉ chat +
  presence, KHÔNG quyết tiền/đồ.
- `main.gd`: nối 3 signal WS lúc `_ready`; `_online_text()`
  thêm "• Chat: …"; tab Tin nhắn thêm khối `ws_phone_text()`
  (trạng thái + người online + 8 tin gần nhất) vào cuối
  `_social_text()` + nút "Kết nối chat online (server local)"
  / khi đã nối: ô nhập `LineEdit` (placeholder "Nhắn chat
  online…", tối đa 500) + "Gửi chat" + "Ngắt kết nối chat";
  tin/presence mới → làm tươi tab nếu đang mở, không thì báo
  số chưa đọc; nối xong toast "Đã nối chat online (N người)".
- `tests/g2_online_test.gd`: cập nhật check
  `default_data()` (thêm 4 key WS mới).

### 22.2 Test mới + hồi quy

- `tests/g4_online_ws_client_test.gd`: **49/49 PASS** — socket
  thật qua loopback cổng 18767: A+B hello + welcome +
  presence 2 người, chat A → B nhận đúng player_id/tên + A
  nhận echo, B ngắt → presence về 1, gửi khi chưa nối / chat
  rỗng / chat 501 ký tự bị chặn ở client (server không nhận
  thêm tin), chat đúng 500 ký tự gửi được + echo về, nối cổng
  đóng thì không kết nối, `data()`/`from_data()` giữ ws_url +
  id + tên + log chat (tên dài cắt 30, tin bẩn bỏ), reset_state
  ngắt WS + xóa log + server về 0 người.
- Hồi quy đầy đủ, 0 FAIL: G2 online 91/91, server 37/37, G1
  selftest 419/419, G2 selftest 87/87, G3 playtest 95/95,
  artpass 60/60, artpass3 24/24, artpass4 19/19, artpass5
  17/17, artpass7 25/25, artpass8 18/18, polish 18/18,
  v6_overlay 16/16, coord+WASD 16/16, ui_wiring 37/37 +
  71/71, MarketBattle 123/123, battle scene 43/43, battle AI
  34/34, battle main 15/15, battle save 31/31, G1 playtest
  14/14, hotspot 37/37, phonehub 66/66, jobs 56/56,
  economy+education 92/92, inventory+crafting 78/78,
  social+titles+story 102/102, tools 155/155, savecloud
  69/69. Smoke `--headless --quit-after 120` exit 0.
- Export web exit 0: pck **6.880.296 byte, SHA `d9e5dc31…`**
  (trước `73ae78df…`), wasm không đổi `fc74679e…`,
  `GODOT_THREADS_ENABLED = false`; HTTP 200 đủ 3 file
  (cổng 8166).

### 22.3 Browser-verify chat WS thật (Chromium 1255 + swiftshader, 720×1280)

- Server thật `server_main.gd` cổng 8765 + game `src/godot-build/`
  cổng 8166, script `hidden_files/pxb-browser-verify-ws.py` +
  `pxb-browser-verify-ws-send.py`, ảnh
  `hidden_files/pxb-browser-verify-2026-11-20/30–34`:
  engine-start OK, start-clicked OK, P mở điện thoại OK,
  **0 console error, 0 pageerror**.
- Bấm "Kết nối chat online (server local)": server log ghi
  `+ peer … (pxb-1795172114960-…)`, toast game "Đã nối chat
  online (1 người).", ô nhập + nút "Gửi chat" / "Ngắt kết
  nối chat" hiện đúng.
- Gõ "Xin chao Cho Dau Moi!" + bấm "Gửi chat": server log
  ghi `chat [Người chơi] Xin chao Cho Dau Moi!` — tin nhắn
  gõ trong game tới server thật; ô nhập xóa sau khi gửi.
  (Echo về `ws_chat_log` đã chứng minh bằng headless 49/49;
  trên ảnh trình duyệt tin nằm cuối vùng nội dung cần cuộn
  nên chưa thấy trực tiếp — xem hạn chế dưới.)

### 22.5 KIỂM LIVE THẤT BẠI — nguyên nhân gốc: thiếu thư mục wasm versioned (20/11 ~18:05–18:20)

- Kiểm live bằng cloud browser (18:05–18:12, 3 lần tải, ~7
  phút): trang chào hiện đúng, nhưng nút "BẮT ĐẦU CHƠI" không
  bao giờ bật — kẹt "Đang tải chậm — mạng yếu…" , thanh tiến
  trình thoáng qua 15% rồi mất, 0 console/pageerror quan sát
  được. Không vào được game nên chưa kiểm được điện thoại/nút
  chat/F — đúng lỗi live 17:55 đã ghi ở AGENTS.md.
- **Nguyên nhân gốc (đo được, không phải đoán):** loader
  versioned (§21.3) tải `wasm/fc74679e/part-*.txt`, nhưng trên
  gh-pages KHÔNG HỀ CÓ thư mục này — 293 chunk wasm chỉ nằm ở
  đường dẫn cũ KHÔNG version `wasm/part-*.txt`. Bằng chứng:
  curl live `wasm/fc74679e/part-050/100/150/200/292` → 404,
  part-000 → 503; API `get_file_contents` ref gh-pages
  `wasm/fc74679e/part-050.txt` → isError "file does not
  exist"; cây gh-pages head `a0ce1a35` (API, 710 entry):
  wasm chỉ có thư mục `wasm/` (293 file cũ), pck có cả `pck/`
  cũ + `pck/73ae78df` + `pck/d9e5dc31`, img versioned đủ.
  Vòng 8 đã SAI khi ghi "wasm KHÔNG push lại (đã có trên
  gh-pages)" — chỉ đúng với img (img versioned đã push đủ),
  sai với wasm. Kiểm local staging không phát hiện vì staging
  trên đĩa CÓ `wasm/fc74679e/` đầy đủ. Bài học: sau mỗi deploy
  versioned, kiểm tra SỰ TỒN TẠI của từng thư mục version trên
  remote (qua API tree), không suy từ "đã có từ trước".
- **Sửa:** đẩy đủ `wasm/fc74679e/` (293 chunk) lên gh-pages,
  13 lô × 24 file (tránh 413 như §21.7), head cuối
  `33353ad4…` (lô 1 `f21bb195…` … lô 13 `33353ad4…`).
  Sync record đã ghi đủ 13 lô.
- **Verify byte từ live (sau sửa):** ráp 293 chunk wasm live
  → 39.514.754 byte, SHA `fc74679e…` = build local (xem
  §22.6); pck + index.html + versions.json đã khớp từ trước.
- Kiểm live lại bằng cloud browser sau khi sửa — xem §22.6.

- Khối chat online nằm CUỐI nội dung tab Tin nhắn (sau danh
  bạ ~38 dòng) — muốn xem tin phải cuộn vùng nội dung; cân
  nhắc đưa khối chat lên trên danh bạ hoặc tự cuộn tới cuối
  khi có tin mới (vòng polish sau).
- Server WS hiện chỉ chạy local (localhost:8765, chưa có địa
  chỉ công khai) — người chơi khác máy chưa nối được; cần
  deploy server + cấu hình `ws_url` khi có máy chủ.
- Chưa có auth (player_id tự khai) + chưa giới hạn tốc độ
  chat + chưa lưu lịch sử cho client mới vào (ghi từ §17.5).

### 22.6 Verify byte từ live sau bản sửa wasm — ĐÚNG HẾT (20/11 ~18:30)

- Ráp 293 chunk `wasm/fc74679e/` từ site live (lần 1 thiếu
  46 chunk do 503 thoáng qua ngay sau 13 lần push liên tiếp
  — Pages đang rebuild; kiểm lại có retry thì 0 chunk lỗi):
  **39.514.754 byte, SHA `fc74679e3b97f768` = build local**.
  (Lần ráp tuần tự bị SIGTERM giữa chừng khi chưa in kết
  quả — không phải lỗi dữ liệu, đã chạy lại song song 16
  luồng, 293/293 trong ~30s, khớp SHA.)
- pck live đã khớp từ trước: 6.880.296 byte, SHA
  `d9e5dc31…`; `index.html` live SHA `1a63018a…` = staging
  loader mới vòng 9 (có `pxbShowLoadError`); `versions.json`
  live: pck `d9e5dc31`, wasm `fc74679e`.
- **Còn lại — kiểm live bằng cloud browser trên URL thật
  vẫn CHƯA chạy lại sau bản sửa** (parent làm cửa cuối theo
  §24.5 + luật AGENTS.md 17:55): tải + nút Bắt đầu bật +
  vào game + điện thoại + nút chat. Byte đã đúng hết nên lỗi
  kẹt 15% không còn nguyên nhân ở deploy nữa; nếu cloud
  browser vẫn kẹt thì nguyên nhân nằm ở mạng/proxy của
  trình duyệt đó, không phải ở file trên Pages.

## 23. Việc tiếp theo — G4 bước 8

1. ~~**Deploy gh-pages bản bước 7**~~ — ĐÃ XONG (cron 18:01–18:03
   20/11, gh-pages `a0ce1a35`, pck `d9e5dc31…`). NHƯNG deploy
   này lặp lại đúng lỗi vòng 9 (§24): không push chunk wasm
   versioned nên live vẫn kẹt tải cho tới khi vòng 9 deploy bù.
2. Quyền lợi giữ sạp áp vào Economy (`hold_benefits` đã có,
   Main chưa gọi); animation di chuyển/đánh trận; chọn đội/vũ
   khí trước trận; `can_challenge` ở demo.
3. Tile riêng Map003–018 (đang PROVISIONAL); camera zoom trận
   MarketBattle (lưới đang nhỏ giữa màn hình); nhãn tên đấu sĩ
   trong trận còn hơi chồng nhau (ảnh browser-verify 13).
4. Khối chat online trong tab Tin nhắn: đưa lên trên / tự
   cuộn tới tin mới (xem §22.4); server WS: auth player_id,
   giới hạn tốc độ chat, lịch sử cho client mới vào.
5. Dọn thư mục version pck/wasm cũ trên gh-pages định kỳ
   (mỗi deploy thêm ~7MB).

## 24. Vòng sửa 9 — kẹt tải 15% trên live, gốc ở deploy (20/11 ~18:10–19:30)

### 24.1 Kiểm live — game không vào được

- Live check (browser-task c5ef5035, 17:55–18:02, 1920×999):
  3 lần thử đều kẹt ở 15% rồi treo ở "Đang tải chậm — mạng
  yếu, vẫn đang tải…", nút Bắt đầu không bao giờ bật, chờ
  >3 phút/lần. Điểm kẹt lặp lại giống hệt ở 15% cả 3 lần
  (kể cả tab mới `?v=8`) — giống một chunk cụ thể bị treo/
  lỗi tải, không phải mạng chậm ngẫu nhiên. Các bước sau
  (di chuyển, cửa Sáng/Chiều/Tối, desktop) không kiểm được.
- Lưu ý: kiểm live vòng 7 (16:52) game VẪN VÀO ĐƯỢC — lỗi
  xuất hiện sau deploy art pass 8 (chunk versioned +
  index.html mới).

### 24.2 Tái hiện + tìm gốc — thư mục wasm versioned chưa từng tồn tại

- curl từ VM: `index.html` live 200 (31.021 byte, SHA
  `7facd2b1…` = staging artpass8 lúc đó);
  `wasm/fc74679e/part-000.txt` → **404** (lần đầu 503 thoáng
  qua, thử lại 404), `part-100/292.txt` → 404; trong khi
  `pck/73ae78df/part-000/050.txt` → 200,
  `img/title_bg.jpg/260962c1/part-000.txt` → 200.
  Chunk wasm KHÔNG version cũ (`wasm/part-000/292.txt`) vẫn
  200 — chỉ thiếu đúng thư mục versioned mới.
- **Gốc:** vòng 8 đổi sang chunk versioned nhưng chỉ push
  pck + img + index.html — "wasm `fc74679e` KHÔNG push lại
  (đã có trên gh-pages)" là SAI: trên gh-pages chỉ có chunk
  wasm KHÔNG version (`wasm/part-*.txt`), chưa từng có
  `wasm/fc74679e/`. Docstring của `build_gh_pages.py` đã ghi
  "wasm chỉ thêm khi wasm đổi" nhưng khi SCHEME đổi thì thư
  mục version mới vẫn phải push dù nội dung không đổi.
  Deploy G4 bước 7 (cron, 18:01–18:03, gh-pages `a0ce1a35`,
  pck `d9e5dc31…`) lặp lại đúng lỗi này — `wasm/fc74679e/`
  vẫn 404 sau deploy đó.
- **Cơ chế kẹt 15% (đã chứng minh bằng repro, xem §24.3):**
  `engine.startGame` = `Promise.all([init(wasm),
  preloadFile(pck)])`; pck tải có báo tiến độ → 6,86MB /
  46,4MB = 14,8% ≈ 15%; wasm fetch qua loader → 404 sau
  3 lần retry → `assemble` reject → engine nuốt rejection
  (Godot `instantiateWasm` dùng `WebAssembly.
  instantiateStreaming(Promise.resolve(r))` không có catch
  nên promise init không bao giờ settle) → `startGame`
  không resolve/reject → `displayFailureNotice` không chạy,
  tiến độ đứng yên, watchdog chỉ đổi nhãn thành "Đang tải
  chậm". Đây là lỗi TREO IM, không phải lỗi mạng.
- Chromium local KHÔNG mở được URL live thật
  (`ERR_TUNNEL_CONNECTION_FAILED` — proxy VM chặn github.io
  với Chromium, kể cả khi truyền proxy có auth; curl thì
  được 200). Từ nay verify live-URL bằng Chromium local là
  KHÔNG KHẢ THI trên VM này — dùng curl byte-verify +
  Chromium trên bản sao byte-identical + kiểm live bằng
  cloud browser của parent làm cửa cuối.

### 24.3 Repro — mô phỏng đúng trạng thái live, trước và sau sửa

- Script `visual-check/artpass9/check_live_load.py` (poll
  nút + tiến độ 5s/lần, ghi console/network) và
  `check_artpass9_verify.py` (verify đầy đủ: nút bật, giữ
  D, tap D, tap-to-move, F, P).
- Mô phỏng live: copy staging sang `/tmp/live-sim`, xóa
  `wasm/fc74679e/`, phục vụ cổng 8163. **Trước sửa:**
  879 failed request (293 chunk × 3 lần retry, toàn 404),
  nút kẹt "Đang tải chậm — mạng yếu, vẫn đang tải…" sau
  45s, không có báo lỗi nào (ảnh `live-title.png` lúc đầu
  — chụp lại sau sửa, xem dưới). **Sau sửa (loader cứng):**
  chỉ 48 failed request (16 worker × 3 lần), ngay t+15s
  nút đã bật với nhãn "⚠ Không tải được game — bấm để tải
  lại", notice ghi đúng "Không tải được index.wasm: HTTP
  404 wasm/fc74679e/part-002.txt — hãy kiểm tra mạng rồi
  bấm để tải lại trang."; tiến độ dừng ở 6880296/46395050
  (= 14,8%, pck đã tải xong) — cùng điểm 15% nhưng giờ có
  lỗi thật + nút thử lại thay vì treo im.

### 24.4 Sửa gốc — loader cứng + deploy bù chunk wasm

- `tools/godot/build_gh_pages.py` — loader mới (vòng 9):
  - `fetchChunk`: timeout thật mỗi lần thử
    (AbortController 30s) — fetch treo vĩnh viễn trước đây
    không bao giờ reject nên retry không chạy.
  - `assemble`: tải giới hạn song song 16 chunk/lần thay
    vì `Promise.all` 293 fetch cùng lúc (tránh nghẹt kết
    nối qua proxy/CDN; A/B trên cùng server local: loader
    cũ 24,8s vs loader mới 27,0s tới lúc nút bật — chênh
    ~2s trong nhiễu, nút thắt là biên dịch wasm trên CPU
    VM yếu, không phải giới hạn song song).
  - `pxbShowLoadError(msg)`: loader TỰ hiện lỗi (không đợi
    engine) — notice ghi tên file lỗi + nút Bắt đầu bật lại
    với nhãn "⚠ Không tải được game — bấm để tải lại",
    bấm thì tải lại trang; áp lại sau 500ms để không bị
    handler lỗi riêng của engine đè mất.
  - Watchdog tổng 120s: sau 120s mà nút vẫn chưa bật và
    chưa có lỗi nào hiện thì báo lỗi thật thay vì treo mãi
    ở "đang tải chậm". Ảnh lỗi không chặn game (chỉ warn,
    DOM dùng fallback gradient).
  - `verify()` assert thêm 5 marker cứng vòng 9
    (`pxbShowLoadError`, `AbortController`,
    `CHUNK_TIMEOUT_MS`, `CHUNK_CONCURRENCY`, `120000`).
  - Thêm `--check-live`: GET `versions.json` + part-000
    của wasm/pck/từng ảnh trên site live + so index.html
    live với staging — chạy trước khi tuyên bố deploy xong.
  - Docstring: ghi bài học vòng 9 + checklist deploy —
    khi index.html đổi sang đường dẫn version MỚI thì thư
    mục version đó PHẢI ĐƯỢC PUSH dù nội dung không đổi.
- Staging build lại: `build_gh_pages.py` VERIFY OK —
  wasm `fc74679e` (293 chunk), pck `d9e5dc31` (51 chunk),
  img đủ 3 ảnh, fileSizes khớp, loader có đủ marker cứng.
- Deploy gh-pages (thứ tự: chunk wasm versioned trước,
  `index.html` cuối):
  - **Song song ngoài ý muốn:** trong lúc vòng 9 đang làm,
    một worker khác (nhiều khả năng cron 24/24) cũng deploy
    cùng bản sửa — 13 commit 18:14:29–18:16:36
    ("Deploy fix live ket tai 15%: wasm fc74679e chunk
    versioned (01/13)…(13/13)", gh-pages `f21bb195` →
    `33353ad4`). Lô chunk wasm của vòng 9 (8 lô × 37 file)
    đều **HTTP 413** (transport MCP nhỏ hơn giới hạn 16MiB
    của CLI — 37 file × 180KB ≈ 6,7MB vẫn quá lớn; vòng 8
    dùng 17 file/lô ≈ 3,1MB thì được; worker kia dùng ~23
    file/lô thì được). **LUẬT MỚI: mỗi lô push ≤ 23 file
    chunk (~4MB), không bao giờ đẩy 37 file/lô nữa.**
  - `index.html` (loader cứng) của vòng 9 push thành công
    sau đó — gh-pages head `8091400c` (18:21:38).
    Trước mỗi lô đều kiểm tra head gh-pages; không đè commit
    của writer kia (chunk wasm của họ ráp lại đúng SHA
    `fc74679e…`, xem §24.5 — cùng nội dung, không xung đột).
  - Main push trước đó: `60fc7712` (build_gh_pages.py +
    docs §24 + 2 script artpass9).
- **PHỐI HỢP VỚI LUỒNG G4 BƯỚC 7 (cron 17:45, ghi 18:20):
  chunk wasm versioned ĐÃ ĐẨY XONG, KHÔNG CẦN ĐẨY LẠI** —
  13 lô × 24 file, head gh-pages `33353ad4…` (lô 1
  `f21bb195…`, lô 13 `33353ad4…`), sync record đã ghi đủ 13
  lô; byte-verify live đang chạy (ráp 293 chunk → SHA
  `fc74679e…`, xem §22.6). Vòng 9 chỉ cần đẩy `index.html`
  loader mới (staging đã build lại, VERIFY OK) — đừng đẩy
  lại 293 chunk wasm, đừng rebuild staging đè lên nhau.

### 24.5 Verify vòng 9

- Regression Godot (đường `-s`, `--check-only` treo theo
  §21.6), 0 FAIL: G1 selftest 419/419, G1 playtest 14/14,
  G2 selftest 87/87, hotspot 37/37, phonehub 66/66, jobs
  56/56, economy+education 92/92, inventory+crafting
  78/78, social+titles+story 102/102, tools 155/155,
  online 91/91, savecloud 69/69, UI wiring 37/37, UI
  wiring2 71/71, MarketBattle 123/123, G3 playtest 95/95,
  artpass 60/60, artpass3 24/24, artpass4 19/19, artpass5
  17/17, artpass7 25/25, artpass8 18/18, battle scene
  43/43, battle AI 34/34, battle main 15/15, battle save
  31/31, coord WASD 16/16, polish 18/18, online server
  37/37, online WS client 49/49, v6 overlay 16/16.
  (Không đổi code GDScript — chỉ đổi loader JS + docs —
  nhưng vẫn chạy đủ regression theo luật vòng sửa.)
- Browser-verify staging mới (Chromium local, 1920×1000,
  cổng 8164): nút BẮT ĐẦU bật sau 29,4s (lần đầu, gồm biên
  dịch wasm trên CPU VM), **ERRORS: 0, FAILED REQUESTS: 0**;
  giữ D 3s + 10 tap D đi được tới cuối TẠP HÓA (ảnh
  `a9-03`, `a9-04`), tap-to-move, F đổi khung, P điện
  thoại (ảnh `a9-05…a9-07`). Thời gian bật nút trên máy
  người chơi sẽ nhanh hơn (biên dịch wasm trên CPU VM yếu
  là nút thắt; loader cũ đo cùng setup là 24,8s; lần đo
  lại với bản icon-inline là 11,5s).
- Browser-verify trên file tải TRỰC TIẾP TỪ LIVE
  (354 file, index.html SHA `1a63018a…` = staging, cổng
  8167): nút bật sau 15,4s; giữ D + 10 tap D đi được tới
  cuối TẠP HÓA, biển "TẠP HÓA" hiện trọn không cắt; F đổi
  khung, P mở điện thoại (ảnh `a9-01…a9-07` ghi đè từ lần
  chạy này); **ERRORS: 1, FAILED REQUESTS: 1 — đều là
  `index.png` 404** (icon chưa từng được deploy, xem mục
  icon bên dưới — đã sửa bằng inline data URI sau đó).
  Lần chạy verify này bị ngắt giữa chừng do service
  restart (mất /tmp + module playwright — cài lại bằng
  `pip install --break-system-packages playwright`,
  browser chromium-1255 trong cache vẫn còn); chạy lại
  đầy đủ sau đó và PASS.
- Verify từ site live (curl): `--check-live` OK sau khi CDN
  hết cache (lần đầu FAIL chỉ vì index.html live còn bản
  cũ trong cache 10 phút — sau đó khớp staging); ráp lại
  toàn bộ chunk từ live: wasm 39.514.754 byte SHA
  `fc74679e3b97f768…` ✓, pck 6.880.296 byte SHA
  `d9e5dc318664f96a…` ✓; `versions.json` live khớp staging.
- **Icon 404 (phát hiện thêm lúc verify):** 3 file icon/
  splash (`index.png` 21KB, `index.icon.png` 5,7KB,
  `index.apple-touch-icon.png` 11,9KB) chưa bao giờ có trên
  gh-pages vì snapshot-push không đẩy được file nhị phân —
  là console error duy nhất còn lại sau khi sửa kẹt tải.
  Sửa: `build_gh_pages.py` inline cả 3 dạng data URI vào
  index.html (86.987 byte, vẫn dưới giới hạn 188.416);
  `verify()` assert đủ 3 data URI + không còn trỏ file
  riêng. Sau sửa: tải staging mới nút bật sau 11,5s,
  **FAILED REQUESTS: 0**; 1 console warning còn lại là
  "GPU stall due to ReadPixels" của swiftshader (đã biết
  từ vòng 8, chỉ là cảnh báo hiệu năng, không phải lỗi).
  Deploy icon-inline: index.html mới (main `f5b2fdd8`,
  gh-pages `462a5eac`, index.html staging SHA
  `c82cf663…`, 86.987 byte), `--check-live` OK sau đó
  (live index.html SHA `c82cf663…` = staging, 3 data URI,
  pxbShowLoadError ×4; CDN mất ~7 phút mới đổi bản).
  **Verify cuối trên file tải TRỰC TIẾP TỪ LIVE bản mới**
  (354 file, cổng 8167, 22:10 +07): nút bật sau 24,0s,
  **ERRORS: 0, FAILED REQUESTS: 0**; giữ D + 10 tap D đi
  được tới cuối TẠP HÓA, F đổi khung, P mở điện thoại
  (ảnh `a9-01…a9-07` ghi đè từ lần chạy này). 24,0s là
  lần tải đầu trên CPU VM yếu (biên dịch wasm); các lần
  đo trước: 11,5s / 15,4s / 29,4s — dao động theo tải CPU,
  đều dưới watchdog 120s.
- Lưu ý hạ tầng: service restart 2 lần trong buổi đã xóa
  sạch /tmp (mất file tải live + server http) và gỡ
  module playwright (cài lại bằng `pip install
  --break-system-packages playwright`; browser
  chromium-1255 trong cache vẫn còn). File tải live cuối
  để ở `~/workspace/live-final-verify/` (ngoài repo,
  bền qua restart) thay vì /tmp.
- Ảnh kiểm chứng: `visual-check/artpass9/` (`a9-01…a9-07`,
  `live-title.png` + script `check_live_load.py`,
  `check_artpass9_verify.py`).
- Caveat cho parent: **chưa kiểm live bằng cloud browser
  trên URL thật** (Chromium local không mở được github.io)
  — parent cần chạy kiểm live cuối trước khi báo user.

## 25. Vòng sửa 9+ — di chuyển hỏng trên live (20/11 ~22:05–23:30)

### 25.1 Kiểm live — tải xong, di chuyển vẫn hỏng

- Kiểm live cloud browser 22:05–22:13 (bản gh-pages sau khi
  cron bổ sung 293 chunk wasm): **tải ĐÃ SỬA XONG** — nút
  "Bắt đầu chơi" bật sau ~20 giây, vào game được ngay,
  điện thoại/chat (P), đổi khung F, nhãn Sáng/Chiều/Tối
  đều đúng. Nhưng **di chuyển VẪN HỎNG**: nhấn D/d/mũi
  tên phải nhiều lần + tap vào đất trống phía phải đều
  không nhúc nhích, nhân vật đứng yên tuyệt đối. P và F
  vẫn nhận nên kết luận ban đầu là "không phải focus/
  bàn phím — lỗi logic di chuyển".
- **Đính chính §24.5:** câu "giữ D + 10 tap D đi được tới
  cuối TẠP HÓA" là SAI — so ảnh a9-03 (sau giữ D) với
  a9-04 (sau 10 tap D) thì nhân vật ở YÊN MỘT CHỖ; toàn
  bộ di chuyển đến từ 3 giây GIỮ D, 10 tap không thêm ô
  nào. a9-05 (sau tap-to-move) cũng y nguyên. Verify cũ
  không so từng ảnh nên đã kết luận sai.

### 25.2 Tái hiện + tìm gốc — 2 lỗi thật, 1 hiểu lầm

- Đối chiếu bản live (22:15): `versions.json` live vẫn
  wasm `fc74679e` / pck `d9e5dc31`; live `index.html` SHA
  `c82cf663…` = staging; pck local SHA `d9e5dc31…` = live.
  **Bản live ĐANG CHẠY code di chuyển mới nhất — không
  phải pck cũ.** Gốc không ở deploy.
- Test headless mới `tests/g4_move_input_test.gd` (đi qua
  pipeline input thật `Input.parse_input_event`, khác test
  cũ chỉ gọi `_try_step`/`action_press` trực tiếp):
  keydown D 1 lần → (5,5) ✓; nhấn-nhả nhanh D → (6,5) ✓;
  mũi tên phải → (7,5) ✓; F/P ✓. **Nhấn 1 lần = 1 ô
  ĐÃ CHẠY ở tầng logic.**
- **Lỗi 1 — tap-to-move chết khi chạm ô bị chặn:** tap
  vào ô không đi được (tường biên/mặt tiền) thì code cũ
  (`elif iso_map.is_walkable(tile)`) im lặng bỏ qua,
  không đi đâu cả. Tap (1150,750) của verify cũ ánh xạ
  tới ô (11,2) — cột biên bị chặn. Người chơi tap "đất
  trống phía phải" rất dễ rơi vào ô biên/mặt tiền vì
  nền vẽ tay không khớp lưới tile.
- **Lỗi 2 — nhấn nhanh trong lúc đang tween bị mất:**
  `press_dir` cũ chỉ bước ngay khi `not _moving`; phím
  nhấn trong 0,15s tween (keyup đến trước khi tween
  xong) thì held bị xóa, bước đó mất hẳn. Nhấn dồn dập
  kiểu trình duyệt cloud (nhấn-nhả nhanh liên tiếp)
  sẽ mất bước.
- **Hiểu lầm — tọa độ chuột headless:** `parse_input_event`
  ở headless NHÂN ~20x tọa độ chuột (probe: gửi
  (462,1022) → tới `_unhandled_input` thành
  (8959,20440)) — do stretch headless, KHÔNG phải lỗi
  game. Nên tap-to-move headless phải gọi thẳng
  `_unhandled_input`; đường GUI thật kiểm bằng trình
  duyệt. Probe GUI cũng cho thấy KHÔNG Control nào
  nuốt click tại điểm tap (`_daynight` đã
  `MOUSE_FILTER_IGNORE` từ trước; `gui_get_hovered_control`
  null).
- Focus đã loại trừ: `web_shell.html` vòng 7 đã focus
  canvas khi bấm Bắt đầu + mọi `pointerdown`
  (dòng 389–398, 430); thí nghiệm local đo
  `activeElement = canvas` trước và sau khi bấm start.
  Camera smoothing (`position_smoothing_enabled`, tốc độ
  10) làm nền trôi chậm sau mỗi bước — đo độ dịch nền
  ngay sau bước sẽ ĐÁNH GIÁ THẤP số ô đã đi; phải so
  vị trí nhân vật/NPC, không so nền.

### 25.3 Sửa gốc — queue bước + tap tới ô gần nhất

- `player.gd` — hàng `_queued_dirs: Array[Vector2i]`
  (tối đa 8): `press_dir` khi đang tween thì append
  hướng vào hàng thay vì bỏ; `_process` khi tween xong
  thì `pop_front` và bước ngay. `release_dir` cố tình
  KHÔNG xóa hàng (nhấn-nhả nhanh vẫn đủ 1 ô). `place()`
  xóa hàng. Giữ phím vẫn đi liên tục như cũ (poll
  `_held_dir`); nhấn 1 lần = đi đúng 1 ô, nhấn dồn
  3 lần trong 1 tween = đủ 3 ô.
- `main.gd` — `_nearest_walkable(t)` (BFS trên lưới
  12x9): tap vào ô không đi được thì đi tới ô đi được
  GẦN NHẤT thay vì đứng yên. Nhánh tap trong
  `_unhandled_input` đổi từ `elif is_walkable` thành
  `else` + fallback này (tương tác NPC/hotspot/cửa
  khi đứng kề vẫn như cũ).
- Test mới `tests/g4_move_input_test.gd` (9 checks):
  spawn; 3 phím D nhấn nhanh → (7,5) [queue]; nhấn D
  1 lần → (8,5); mũi tên phải → (9,5); tap (9,7);
  tap ô biên (11,2) → (10,2) gần nhất; F → Chiều;
  P → mở điện thoại. **9/9 PASS** (lần chạy đầu 7/9
  do kỳ vọng test sai: giữ phím 25 frame đi 2 ô là
  đúng thiết kế đi liên tục — đã sửa test thành
  nhấn-nhả nhanh).
- Thí nghiệm trình duyệt `check_move_single.py`
  (staging = bản live, viewport 1920×1000, ảnh
  `m1-01…m1-08`): nút bật sau 24,0s; `activeElement`
  = canvas trước/sau start; **ERRORS: 0, FAILED: 0**;
  3 lần nhấn D riêng lẻ → nhân vật từ spawn (4,5)
  tới khu Cô Tư (~(7,5)); mũi tên phải +1 ô; **tap
  (1050,700) ĐI ĐƯỢC** (~2,5 ô lên phải); tap
  (1150,750) KHÔNG đi (ô biên (11,2) — chính lỗi
  đã sửa bằng fallback); phím F đổi khung Chiều.

### 25.4 Export + deploy — XONG (20/11 ~22:55–23:06)

- Export Godot (exit 0): pck mới 6.891.804 byte SHA
  `7f8ef9bbdfe0225a…` (52 chunk versioned), wasm không đổi
  `fc74679e…`. Staging rebuild bằng `build_gh_pages.py`:
  VERIFY OK (pck/wasm/img khớp byte, loader cứng đủ
  marker, icon inline đủ 3 data URI).
- **Writer song song:** lượt cron hourly 23:00 đã đẩy
  main trước — commit `08a0de9c` (23:01:34 +07, 5 paths:
  `player.gd`, `main.gd`, `pxb_economy.gd` [G4 bước 8],
  `g4_move_input_test.gd`, `g4_battle_hold_benefits_test.gd`;
  message ghi rõ "2053 PASS 0 FAIL; export web pck
  7f8ef9bb") — rồi deploy gh-pages trong 4 lô
  (`e5cda33b` 23 chunk pck 000–022, `bc4d25f6` 23 chunk
  023–045, `722c8e14` 6 chunk 046–051, `1ed8f9f8`
  `index.html` + `versions.json`), ghi đủ vào sync record
  (133 entries). Cùng lượt cron đã làm G4 bước 8 trước
  đó (~22:34 +07: áp quyền lợi giữ sạp vào Economy —
  `pxb_economy.gd` 15:34 UTC, test hold_benefits 30/30)
  nên pck `7f8ef9bb` chứa CẢ sửa di chuyển VÀ G4-8.
- Docs §25 KHÔNG nằm trong commit `08a0de9c` của cron —
  bản docs này là follow-up riêng sau deploy.
- CDN mất vài phút mới đổi bản: lúc 23:03 live vẫn
  `d9e5dc31`, tới ~23:06 đã là `7f8ef9bb`.

### 25.5 Verify vòng 9+ — XONG

- Regression Godot (35 suite, `-s`): **2053 PASS / 0 FAIL**.
  Lần chạy đầu 34 OK + 1 FAIL `g4_online_server_probe`
  (timeout phase=0) — là artifact của harness: probe cần
  server riêng đang chạy; chạy lại với server thật trên
  18765 thì "PROBE OK: echo chat". Tổng 2053 tính cả
  probe chạy lại (37/37 server test + 49/49 WS client).
  Ghi chú: lần chạy đầu của `g4_move_input_test` là 7/9
  do kỳ vọng test sai (giữ phím 25 frame đi 2 ô là đúng
  thiết kế đi liên tục) — đã sửa test, 9/9.
- Browser-verify staging mới (Chromium local, 1920×1000,
  cổng 8168, script `check_move_v2.py`, ảnh `m2-01…m2-08`):
  nút bật sau 24,7s, `activeElement` = canvas trước/sau
  start, **ERRORS: 0, FAILED REQUESTS: 0**; 3 lần nhấn D
  riêng lẻ → đi ~3 ô sang phải (camera pan, TẠP HÓA lộ
  ra); mũi tên phải +1 ô; **tap (1150,750) — điểm chết
  cũ — NAY ĐI ĐƯỢC** (đi tới cuối TẠP HÓA, fallback ô
  gần nhất hoạt động); tap (1050,700) không đổi (đã đứng
  sát đích); phím F → Khung Chiều (mặt trời cam +
  toast "Ngày 1 • Khung Chiều").
- Verify từ site live (curl): `--check-live` OK (live
  `versions.json` pck `7f8ef9bb`, mọi part-000 200, live
  `index.html` SHA `6282a11b…` = staging); **ráp lại
  toàn bộ 52 chunk pck từ live: 6.891.804 byte, SHA
  `7f8ef9bbdfe0225a…` = build ✓** (file ở
  `~/workspace/live-move-verify/`).
- Caveat cho parent: **chưa kiểm live bằng cloud browser
  trên URL thật** — parent cần chạy kiểm live cuối
  (nhấn D 1 lần / tap điểm cũ) trước khi báo user.

### 25.6 Kiểm live bản 7f8ef9bb — RỚT Ở BƯỚC TẢI (23:10–23:13 +07)

- Browser-task `be62ff52` (cloud browser, 23:10–23:13):
  `versions.json` live ĐÚNG bản mới (pck `7f8ef9bb`,
  wasm `fc74679e`) — nhưng mở game thì kẹt ở nút
  "Đang khởi động game…" **>120 giây**, không chuyển
  sang "BẮT ĐẦU CHƠI", không hiện thông báo lỗi tải.
  Dừng ở bước 1 theo luật (kẹt >120s); di chuyển /
  đổi khung / điện thoại CHƯA kiểm được trên bản này.
  Không quan sát được console error qua giao diện
  thường (lỗi nếu có nằm ở quá trình khởi động WASM).
- Nghịch lý: cùng bản này chạy local staging thì nút
  bật sau 19,8s (script `check_move_single.py`, ảnh
  `move-v10/m1-*`, ERRORS 0); `--check-live` OK; 52
  chunk pck ráp lại từ live khớp SHA từng byte.
  Chưa rõ gốc kẹt là CDN/proxy chậm thoáng qua lúc
  23:10 hay môi trường cloud browser — cần kiểm lại,
  không kết luận "bản mới hỏng tải" từ 1 lần kẹt.
- Giới hạn chẩn đoán từ VM: probe Playwright local mở
  thẳng URL live bị `net::ERR_TUNNEL_CONNECTION_FAILED`
  (egress proxy của VM chặn tunnel của Chromium; curl
  thì vẫn 200) — **không tự chẩn đoán được lỗi tải
  live bằng trình duyệt local**; chỉ curl/byte-verify
  được. Script probe: `visual-check/artpass9/
  probe_live_load_v10.py`.
- Chat chính đã tự mở kiểm live mới
  (browser-task `25039c4d`, lúc ~23:15) — kết quả của
  lần đó sẽ quyết định: nếu vẫn kẹt tải thì phải chẩn
  đoán sâu (DevTools network xem chunk/request nào
  treo); nếu tải được thì kiểm tiếp di chuyển.

## 25. Vòng 10 — kiểm live 22:09 + quyền lợi giữ sạp G4 bước 8 (20/11 ~22:05–22:47)

### 25.1 Kiểm live bằng cloud browser trên URL thật — ĐẠT trừ di chuyển

- Browser-task 708b5a8b (22:08–22:24 +07, chẩn đoán tiếp 22:30–22:39):
  tải nhanh, nút BẮT ĐẦU bật sau vài giây, vào game Map001, F đổi
  khung (Sáng→Chiều→Tối, trăng/sao, nhân vật tối đi), P mở điện thoại
  đủ 9 tab + khối chat online cuối tab Tin nhắn, **0 console/pageerror/
  failed request**.
- Di chuyển KHÔNG ĐẠT trong môi trường đó: ~70 lần bấm D/W/A/S/mũi
  tên + chạm chuột 3 điểm + giữ chuột/drag đều không nhúc nhích;
  chẩn đoán lại (viewport 1920×999, canvas x 678–1240, tâm (959,504)):
  40 lần bấm D + 30 ArrowRight + tap (1110,700) và (1050,800) trong
  canvas đều không đi; nút Điện thoại trong game bấm chuột thì mở
  ngay → input tới được game, nhưng tap/phím di chuyển không đi.
  Kết luận của browser: nghiêng về lỗi di chuyển thật (ít nhất đường
  chạm-chuột); đường phím chưa kết luận tuyệt đối vì môi trường đó
  không giữ phím thật được (không có keyboard.down/keyUp, không có
  eval/CDP để đo activeElement).
- E gần Cô Tư không mở hội thoại (ghi nhận thêm): người chơi chưa di
  chuyển tới kề Cô Tư nên `_try_interact` không có event trong tầm —
  chưa phải bug riêng, kiểm lại sau khi di chuyển được.

### 25.2 Tái hiện local — di chuyển ĐƯỢC trên đúng bản live

- Script mới của luồng song song
  `visual-check/artpass9/check_move_single.py` (staging = bản live,
  pck d9e5dc31, cổng 8164, Chromium 1255 + swiftshader, 1920×1000):
  nút bật sau 24,0s; activeElement trước/sau start đều là canvas;
  0 ERROR, 0 failed request.
- Ảnh m1-01…m1-08 (vòng này đã xem trực tiếp): 3 lần giữ D 400ms →
  người chơi đi phải, camera theo, biển TẠP HÓA hiện trọn (m1-04);
  tap (1050,700) đi tới ô (m1-06); F → Khung Chiều + toast (m1-08).
  Vậy code di chuyển của bản deploy CHẠY ĐƯỢC với input thật trên
  Chromium local.
- Chênh lệch còn lại: cloud browser không giữ phím thật + tap trúng ô
  bị chặn (xem §25.3) — cần kiểm lại bằng bàn phím vật lý giữ D 3s
  trên URL live để khép.

### 25.3 Chẩn đoán + sửa của luồng song song (đang làm, chưa verify xong)

- Test mới `tests/g4_move_input_test.gd` (8/9 PASS): keydown D/mũi
  tên qua `Input.parse_input_event` đi được 1 ô/lần; tap-to-move qua
  parse_input_event FAIL (đứng ở (7,5), auto_target (-1,-1)) nhưng gọi
  thẳng `Main._unhandled_input` thì PASS → kết luận ban đầu "click bị
  GUI nuốt".
- Probe của luồng đó do vòng này chạy lại: `g4_gui_probe` — KHÔNG
  Control visible nào chứa điểm (462,1022),
  `gui_get_hovered_control` = null (không có Control nào ăn click ở
  điểm đó); `g4_mouse_probe` — click qua parse_input_event VẪN tới
  được `_unhandled_input` của probe, nhưng position bị biến thành
  (8959.999, 20440.0) — artefact của đường parse_input_event headless,
  không phải của trình duyệt thật. Kết luận "GUI nuốt click" vì vậy
  CHƯA chắc; đừng sửa theo nó.
- Sửa thật của luồng song song (main.gd + player.gd, 15:38–15:44 UTC,
  đang tiếp tục sửa lúc 15:46):
  1. `player.gd` `_queued_dirs` (tối đa 8): press_dir trong lúc tween
     thì QUEUE bước lại, bước ngay khi tween xong; release_dir cố
     tình KHÔNG xóa queue — phím nhấn-nhả nhanh không bị mất bước
     (cơ chế mất bước: press trong lúc `_moving` thì code cũ chỉ ghi
     `_held_dirs`, keyup xóa ngay → mất hẳn; ở FPS thấp + bấm dồn
     dập thì hầu hết các lần bấm rơi vào lúc tween).
  2. `main.gd` `_nearest_walkable(t)` (BFS 12×9): tap vào ô không đi
     được (tường biên/mặt tiền) thì đi tới ô đi được GẦN NHẤT thay vì
     đứng yên — đúng điểm tap (1110,700)/(1050,800) trên live ánh xạ
     tới ô biên bị chặn.
- Va chạm: luồng song song sửa cùng main.gd/player.gd trong lúc vòng
  này làm G4 bước 8 — code bước 8 còn nguyên (đã kiểm grep sau mỗi
  lần file đổi), nhưng KHÔNG push/deploy trong vòng này để khỏi đè/
  chẻ fix của luồng kia (xem §25.5).

### 25.4 G4 bước 8 — quyền lợi giữ sạp áp vào Economy — XONG CODE + TEST, CHƯA PUSH

- `pxb_economy.gd`: `buy(item_id, discount_percent := 0)` — giá hiệu
  dụng = price × (100−disc)/100 (chia nguyên); tiền thuê phòng trọ
  KHÔNG giảm (không phải giá sỉ); trả thêm `"price_paid"`.
  `auction_seller_receives(hammer, tax_cut_percent := 0)` — phí 5% ×
  (100−cut)/100 (giữ sạp cut 20 → phí 4%, nhận 96%).
- `main.gd`: `_hold_benefits_now()` =
  `hold_benefits(battle_state, "doi-ban", day)`; `buy_item` truyền
  wholesaleDiscountPercent (trừ phong-tro), toast "Đã mua X
  (giá sỉ −10%.)" khi có giảm; `_advance_frame`: sang ngày mới (sau
  expire_holds) mà còn giữ sạp thì fame += famePerDay (10), toast
  ngày thêm "• Giữ sạp +10 Danh vọng".
- Test mới `tests/g4_battle_hold_benefits_test.gd`: **30/30 PASS** —
  hold_benefits đúng 10/20/10, hết hạn ngày 8 thì {}, đội khác {},
  economy mua giảm (4.600.000 mua được điện thoại cũ, còn 100.000,
  price_paid 4.500.000), không giảm thì không đủ tiền, thuê trọ không
  giảm, đấu giá 1.000.000 → 950.000 / giữ sạp → 960.000; Main: thắng
  trận giữ sạp → mua giá sỉ được, sang ngày +10 Danh vọng, xóa giữ
  sạp → mua giá đầy + không +fame.
- Hồi quy đầy đủ trên cây TRƯỚC sửa di chuyển của luồng song song
  (chạy 15:35–15:39 UTC): economy 92/92, battle save 31/31, battle
  main 15/15, MarketBattle 123/123, battle AI 34/34, online 91/91,
  savecloud 69/69, G1 selftest 419/419, G2 selftest 87/87, G3 playtest
  95/95, G1 playtest 14/14, artpass 60/60, artpass3 24/24, artpass4
  19/19, artpass5 17/17, artpass7 25/25, artpass8 18/18, battle scene
  43/43, coord+WASD 16/16, polish 18/18, v6_overlay 16/16, online
  server 37/37, WS client 49/49, hotspot 37/37, inventory+crafting
  78/78, jobs 56/56, phonehub 66/66, social+titles+story 102/102,
  tools 155/155, ui_wiring 37/37 + 71/71 — **0 FAIL**. (4 suite in
  tổng kết dạng khác nên grep lần đầu trượt: artpass 60, artpass7 25,
  artpass8 18, v6 16 — đã chạy lại riêng, đều PASS.)
- Lưu ý test: g4_move_input_test 8/9 (1 FAIL tap-to-move qua
  parse_input_event — artefact vị trí ×20 của đường test headless,
  xem §25.3; không phải hồi quy của bước 8).

### 25.5 CHƯA PUSH / CHƯA EXPORT / CHƯA DEPLOY trong vòng này — lý do

- Luồng song song đang sửa main.gd/player.gd (sửa lần cuối 15:44:52
  UTC, đang chạy probe/test lúc 15:46) — cây chưa ổn định. Push
  main.gd lúc này sẽ quét cả fix di chuyển chưa verify xong của luồng
  kia; push lẻ economy+test sẽ chẻ tính năng. Đợi cây ổn định → chạy
  lại hồi quy trên cây gộp (đặc biệt g4_move_input +
  g4_battle_hold_benefits + artpass) → export → deploy 1 lần.
- Việc tiếp theo: (1) luồng song song verify fix di chuyển (hồi quy +
  local browser + kiểm live lại bằng bàn phím vật lý giữ D); (2) push
  main (bước 8 + fix di chuyển) + export + deploy gh-pages bản mới;
  (3) kiểm live cuối trên URL thật.

## 26. G4 bước 9 — Nhãn tên đấu sĩ chống chồng — XONG (20/11 ~23:50–00:10)

### 26.1 Lỗi

- Nhãn tên đấu sĩ trong trận MarketBattle còn hơi chồng nhau (ghi từ
  §13/§20, thấy trên ảnh browser-verify 13: "Cô Tư"/"Bạn Thân").
  Nguyên nhân: tên rộng tới 120px, 2 đấu sĩ kề nhau chỉ cách 32px
  ngang (TILE_W 64, iso) — lệch theo chẵn/lẻ x (44 vs 64) chỉ tách
  được 20px dọc, không đủ cho chữ cao ~22px.

### 26.2 Sửa (`scripts/battle_scene.gd`)

- `fighter_name_rects() -> Array` (mới): tính rect từng tên theo độ
  rộng chữ thật (`font.get_string_size`, cap 120px) + dy chẵn/lẻ x
  như cũ; sắp theo y rồi x, đẩy rect chồng xuống dưới rect đã đặt
  (khe 4px); kẹp đáy ≤ 980 (trên panel hành động y=1000), hết chỗ
  dưới thì đặt lên trên rect đang chặn. Trả về `{id, name, rect}`.
- `_draw_fighters` lượt 2: tên vẽ theo rect đã resolve (baseline =
  rect.y + 20, căn giữa theo `rect.size.x`); fallback giữ hành vi cũ
  nếu thiếu id. Không sửa luật, không sửa vị trí vòng tròn/HP bar.
- Test mới `tests/g4_battle_names_test.gd`: **12/12 PASS** — đủ 6
  nhãn lúc spawn, không chồng; cặp kề (5,4)-(6,4) đúng điểm lỗi cũ;
  cụm 6 ô kề; tên dài ("Tiểu thương 12") cap 120px; nhãn giữ gần
  đấu sĩ (≤110px) + trong màn hình + trên panel.

### 26.3 Verify vòng này

- Hồi quy đầy đủ (script 22:45): **1978 PASS / 0 FAIL** (1966 cũ +
  12 mới); battle scene 43/43, battle AI 34/34, battle main 15/15,
  battle save 31/31, MarketBattle 123/123 — không regression.
- Smoke `--headless --quit-after 120` exit 0, 0 error — lưu ý: lần
  chạy đầu báo parse error ảo `main.gd:2038 _update_dbg() not found`
  dù hàm CÓ định nghĩa ở dòng 2173; chạy `--headless --import` rồi
  chạy lại thì hết (đúng bài học cache cũ §8.3 — không sửa code vì nó).
- Export web vòng này exit 0: pck `bea7de95…` (6.903.908 byte),
  wasm không đổi `fc74679e…`; HTTP 200 đủ 4 file (cổng 8170),
  `GODOT_THREADS_ENABLED = false`.
- **Va chạm song song — export bị ghi đè (ghi 00:05 21/11):** một
  worker khác (Vòng 10 — D-pad + nhãn debug, xem dưới) sửa
  `main.gd` 16:58:40, `web_shell.html` 16:57:10, thêm
  `tests/g4_dpad_test.gd` 16:58:12 rồi export lại lúc 17:00:36 —
  pck trên đĩa nay là **`bc296e9e…` (6.903.924 byte)**, KHÔNG còn
  là `bea7de95…` của vòng này. Build hiện tại là cây GỘP (fix
  nhãn trận vòng này + D-pad Vòng 10); `g4_battle_names_test` có
  trong pck (grep thấy tên file) nên code vòng này vẫn nằm trong
  build. Staging rebuild sau đó (VERIFY OK) đã dùng đúng pck
  `bc296e9e…` hiện tại, khớp byte với build trên đĩa.
- **Vòng 10 — D-pad + nhãn debug (worker song song, code chưa
  push trong vòng này):** sau kiểm live 23:14 (nhân vật đứng yên
  dù phím/tap chạy tốt trên Chromium local — không tái hiện được
  lỗi live), worker đó thêm ĐƯỜNG INPUT THỨ 2 không phụ thuộc bàn
  phím: 4 nút mũi tên trên màn hình (`button_down` → `press_dir`,
  `button_up` → `release_dir`) + nhãn debug hiện ô hiện tại +
  input cuối, để lần kiểm live sau đọc được ngay input có tới game
  không. File của họ: `main.gd`, `web_shell.html`,
  `tests/g4_dpad_test.gd` — vòng này KHÔNG push các file đó (để
  worker đó tự push), chỉ push 3 file của vòng này.
- Hồi quy đầy đủ trên cây GỘP (chạy lại sau khi cây ổn định, gồm
  cả `g4_dpad_test.gd` của Vòng 10): **1990 PASS / 0 FAIL**
  (1978 cũ + 12 D-pad mới); battle names 12/12, battle scene 43/43,
  battle AI 34/34, battle main 15/15, battle save 31/31,
  MarketBattle 123/123, move-input 9/9 — không regression.
  (Lần chạy 23:5x trước khi gộp là 1978/0 trên cây chưa gộp,
  không tính cho cây này.)
- Kiểm tra đường tải live trước deploy: `versions.json` live vẫn
  pck `7f8ef9bb`; 6 chunk mẫu live (wasm 000/150/292, pck 000/051,
  img title_bg) đều **200 trong 0,9–1,7s** — đường tải live khỏe
  lúc 23:47. Vụ kẹt tải >120s ở kiểm live 23:10 (browser-task
  be62ff52) nhiều khả năng là kẹt thoáng qua ở CDN/proxy hoặc môi
  trường cloud browser, không phải file trên Pages (byte đã khớp
  SHA từ trước) — không kết luận "bản mới hỏng tải" từ 1 lần kẹt.
  Kết quả kiểm live lại (browser-task 25039c4d, mở ~23:15) vẫn CHƯA
  có trong phiên này — parent/chủ xem kết quả đó để chốt di chuyển
  trên bản `7f8ef9bb`.
- **Push main CHƯA xong — service restart 3 lần (00:0x–00:15 21/11):**
  `github push-files` bị gián đoạn cả 3 lần thử (service restart
  ngay trong lúc push, đúng kiểu §24.5); đã đối chiếu head remote
  sau mỗi lần: vẫn `c1f86361…`, không có commit mới nào được tạo,
  sync record KHÔNG ghi thêm (đúng luật — chưa xác nhận thì không
  advance). Không retry lần 4 trong vòng này (3 lần cùng lỗi là
  đủ; retry mù có nguy cơ tạo commit trùng nếu 1 lần thực ra đã
  lọt). Paths file giữ lại ở
  `hidden_files/pxb-push-paths-2026-11-21-0010` để vòng sau push
  lại 1 lệnh. Deploy gh-pages cũng dùng cùng cơ chế push nên
  cũng CHƯA làm được trong vòng này.

### 26.4 Việc tiếp theo

1. **Push main lại** (paths file đã sẵn ở
   `hidden_files/pxb-push-paths-2026-11-21-0010` — 4 file vòng
   này; kiểm tra head vẫn `c1f86361…` trước khi push) **+ deploy
   gh-pages bản `bc296e9e…`** (staging đã rebuild + VERIFY OK:
   pck `bc296e9e`, wasm `fc74679e` không đổi, img đủ 3 ảnh, loader
   cứng đủ marker, icon inline đủ 3 data URI; push pck versioned
   + index.html cuối, kiểm tra head trước mỗi lô ≤23 file).
   Lưu ý: deploy này sẽ đưa cả D-pad Vòng 10 lên live (cùng pck
   gộp) — đúng ý đồ (D-pad là đường input thứ 2 cho kiểm live
   sau), nhưng worker Vòng 10 vẫn cần push riêng `main.gd` +
   `web_shell.html` + `g4_dpad_test.gd` lên main trước/sau đó để
   code trên GitHub khớp build đã deploy.
2. Animation di chuyển/đánh trận; chọn đội/vũ khí trước trận;
   `can_challenge` ở demo (xem §20.2).
3. Tile riêng Map003–018 (đang PROVISIONAL); camera zoom trận
   MarketBattle (lưới đang nhỏ giữa màn hình).
4. Khối chat online trong tab Tin nhắn: đưa lên trên / tự cuộn tới
   tin mới; server WS: auth player_id, giới hạn tốc độ chat, lịch
   sử cho client mới vào.
5. Dọn thư mục version pck/wasm cũ trên gh-pages định kỳ.

## 27. Cron 03:45 21/11 — hồi quy + staging OK, push main + deploy CHƯA XONG (3 lần service restart)

### 27.1 Hồi quy cây hiện tại — 37/37 suite, 0 FAIL

- Subagent chạy `bash tools/godot/run_regression.sh` (~04:38 +07,
  log `~/workspace/regression-move.log`): **37/37 suite OK,
  0 FAIL — 2079 assert PASS** (tính từ log; v6_geometry_probe
  không in số đếm, probe server PROBE OK). Mới so với vòng §26:
  `g4_dpad_test` nay 14/14 (trước 12/12), `g4_battle_names_test`
  12/12 giữ nguyên.
- Smoke `--headless --quit-after 120` exit 0, không ERROR.
- Không sửa code trong vòng này (chỉ chạy test + verify staging).

### 27.2 Staging verify — OK (build `ba8e4a99…`, không phải `bc296e9e…` của §26)

- `build_gh_pages.py --verify-only` exit 0: pck `ba8e4a99`
  (6.904.868 byte, 52 chunk, khớp byte với `src/godot-build/`),
  wasm `fc74679e` (293 chunk, 39.514.754 byte, khớp byte),
  img đủ 3 ảnh khớp byte, loader dùng chunk versioned + đủ 5
  marker cứng vòng 9, icon inline đủ 3 data URI.
- Build trên đĩa là bản export 01:04 +07 (sau export 00:00 +07
  của Vòng 10); không có file code `src/godot/` nào mới hơn
  export này — pck chứa đúng cây hiện tại (battle names +
  D-pad Vòng 10).
- Live lúc này vẫn pck `7f8ef9bb` (curl `versions.json` 10:26
  +07); wasm `fc74679e` đã có đủ trên gh-pages (curl
  `wasm/fc74679e/part-000` + `part-292` đều 200) — deploy sau
  KHÔNG push lại wasm.

### 27.3 Push main — THỬ 3 LẦN, cả 3 đều restart, KHÔNG commit mới

- Push 4 file (paths file
  `hidden_files/pxb-push-main-2026-11-21-0345`):
  `src/godot/scripts/battle_scene.gd`,
  `src/godot/tests/g4_battle_names_test.gd` (+ `.uid`, mới),
  `docs/godot-g4.md`. Trước mỗi lần đều đối chiếu head main
  vẫn `c1f86361…`; đối chiếu remote-vs-local: `battle_scene.gd`
  remote blob `2b0680a1…` ≠ local (đúng — local có fix tên trận),
  2 file test mới xác nhận ABSENT trên remote (`isError`), docs
  sync base chính là head nên không lệch được.
- Cả 3 lần `github push-files` đều bị **service restart giữa
  chừng** (lần 1 ~21:48 UTC, lần 2 ~23:xx UTC, lần 3 ~01:28
  UTC); đối chiếu head sau mỗi lần vẫn `c1f86361…`, sync record
  KHÔNG ghi thêm — đúng luật (chưa xác nhận thì không advance).
  DỪNG ở 3 lần theo tiền lệ §26.3, không retry lần 4 trong
  vòng này.
- **Deploy gh-pages CHƯA làm** (cùng cơ chế push-files, sẽ gặp
  cùng lỗi restart) — lượt sau làm 1 lần: pck `ba8e4a99` 52
  chunk chia 3 lô ≤23 file + `index.html` + `versions.json`
  cuối; kiểm tra head gh-pages (`1ed8f9f8…`) trước mỗi lô.
- Lưu ý cho lượt sau: build `ba8e4a99` chứa cả code D-pad Vòng
  10 (`main.gd`/`web_shell.html`/`g4_dpad_test.gd` — worker
  Vòng 10 tự push theo §26.4, chưa thấy push). Deploy sẽ đưa
  D-pad lên live trước khi code lên main — sau deploy nhớ đẩy
  nốt 3 file D-pad lên main để code GitHub khớp build đã
  deploy, tránh lệch như vụ wasm §22.5.
- Vòng 10 agent (`3d626c35`) vẫn listed running lúc 21:32 UTC,
  hoạt động cuối ~21:24 UTC; sau 3 restart không rõ trạng thái
  — không can thiệp (thuộc chat khác). Staging có thư mục pck
  lạ `64880480` (17:06 UTC) — dọn sau, không ảnh hưởng deploy.

### 27.4 Việc tiếp theo

1. **Push main lại** (paths file đã sẵn — kiểm tra head vẫn
   `c1f86361…` trước khi push) **+ deploy gh-pages `ba8e4a99`**
   (xem §27.3).
2. **Kiểm live bằng cloud browser trên URL thật sau deploy**
   (D-pad 4 nút + phím D + tap, đọc nhãn debug ô hiện tại/input
   cuối) — cửa cuối theo luật AGENTS.md 20/11 23:21; live hiện
   vẫn bản `7f8ef9bb` nên kiểm lúc này chỉ lặp lại kết quả cũ.
3. Animation di chuyển/đánh trận; chọn đội/vũ khí trước trận;
   `can_challenge` ở demo; tile riêng Map003–018; camera zoom
   trận; khối chat online đưa lên trên tab Tin nhắn; server WS:
   auth player_id, giới hạn tốc độ chat, lịch sử cho client mới.

## 28. Vòng 10b — "1 click D-pad đi tới Map002" HÓA RA LÀ CỬA (5,4) + đọc nhầm ô — XONG, đã deploy (21/11 ~01:00–04:30 +07)

### 28.1 "Bug" còn lại sau tap-per-tile — đọc nhầm số ô ở cỡ chữ nhỏ

- Sau khi đổi D-pad sang tap-per-tile (`step_dir`, §26), chạy
  lại `check_dpad2.py` (UP → RIGHT → LEFT → DOWN): RIGHT vẫn
  "đi tới Map002 (8,4)", LEFT "về (4,4)". Tưởng còn driver lạ.
- Thêm bộ đếm `_dpad_press_count` (hiện `P:N` ở dòng 2 nhãn
  debug) + chạy `check_diag.py` (chỉ 1 click RIGHT): **P:1,
  dừng đúng (5,5)** — 1 click = đúng 1 lần `button_down` = 1 ô.
  Tap-per-tile HOẠT ĐỘNG.
- Chạy lại đúng chuỗi e-run (`check_up_then_right.py`, UP rồi
  RIGHT, chụp mỗi 500ms): i-01 sau UP: `(4,5)`... — SAI. Phóng
  to nhãn debug 3× mới đọc đúng: **i-01 = `Ô (4,4) • ▲`**
  (UP ĐÃ đi được, (4,4) đi được — trước đó đọc nhầm thành
  (4,5) vì chữ nhỏ bị xe đẩy che một phần).
- Gốc thật: cửa Map001→Map002 ở ô **(5,4)**
  (`data/maps.json`: `{"kind":"door","tile":[5,4],"to_map":2}`).
  Từ (4,4), 1 click RIGHT → (5,4) = đúng ô cửa → `_transfer(2)`
  → spawn Map002 (8,4). HOÀN TOÀN ĐÚNG LUẬT GAME — không có
  driver lạ nào: mọi ảnh chụp đều `H:[] Q:0 A:(-1,-1) MR:0`,
  P tăng đúng 1/click. Chuỗi LEFT sau đó (8,4)→(4,4) trên
  Map002 cũng đọc nhầm tương tự (thực tế là 1 ô, sẽ verify lại
  bằng zoom trong j-run).
- Bài học: **không bao giờ đọc ô từ ảnh thu nhỏ** — nhãn debug
  font 20 ở (24,1172) phải phóng to 3× mới đọc chắc; các kết
  luận "đi 4–7 ô" ở vòng 10/10b trước khi có zoom đều không
  đáng tin.

### 28.2 Verify cuối trên staging (build `ba8e4a99`, `check_final.py`)

- D-pad 4 hướng, tránh ô cửa (5,4): DOWN (4,5)→**(4,6)** ▼
  P:1; LEFT (4,6)→**(3,6)** ◀ P:2; RIGHT (3,6)→**(4,6)** ▶ P:3;
  UP (4,6)→**(4,5)** ▲ P:4 — đúng 1 ô/click, về đúng spawn.
- Phím D: (4,5)→**(5,5)** • D (P vẫn 4 — phím không tính vào
  bộ đếm D-pad). Tap (1000,850): đang đi tới `(9,7)` — nhãn
  hiện `chạm (9,7)` + `A:(9,7)` giữa đường (auto-target hiện
  sống trong dòng chẩn đoán). ERRORS: [].
- Hồi quy đầy đủ (36 suite, `tools/godot/run_regression.sh`):
  **36 OK, 1 FAIL: `g4_polish_test`** — chạy lẻ 3 lần liên tiếp
  đều 18/18 PASS → kết luận flake (hết `timeout 120` hoặc
  tranh tài nguyên trong chuỗi dài), không phải hồi quy do
  thay đổi vòng 10b. `g4_dpad_test` 14/14 PASS.
  (Lưu ý: lần chạy hồi quy đầu tiên trong vòng này 0/37 do chạy
  bản copy `/tmp/run_regression.sh` — `cd ../..` từ /tmp sai
  đường dẫn Godot; phải chạy từ repo
  `bash tools/godot/run_regression.sh`.)

### 28.3 Deploy gh-pages — XONG, verify khớp byte từ live

- Push-files 5 lô (paths file `~/workspace/deploy10b-batch*.txt`):
  (1) pck `ba8e4a99` part 000–016 + `versions.json` →
  `6eddda03`; (2) part 017–033 → `1795ec8f`; (3) part 034–050
  → `a5126dd4`; (4) part 051 → `06b2dcc5`; (5) `index.html`
  CUỐI → `d4b90cdb`. Sync record đã ghi đủ 5 commit.
- **Lỗi restart ở đường ghi:** 2 lần `push-files` đầu + 3 lần
  `call-tool list_commits` trước đó đều "service restarted" và
  KHÔNG có hiệu lực (đối chiếu `versions.json` live vẫn
  `7f8ef9bb` ở `1ed8f9f8`); lần thử lại sau khi chờ 45s thì
  thành công (approval `userConfirmationStatus: approved`).
  `call-read-tool` (đọc) luôn chạy ổn — chỉ đường ghi
  (`call-tool`/`push-files`) mới restart. Không retry dồn dập;
  sau mỗi lần restart phải đối chiếu lại live trước khi thử lại.
  (Cùng lỗi cron 03:45 gặp ở §27.3 khi push main.)
- Verify từ live (raw.githubusercontent.com): `versions.json`
  live pin pck **`ba8e4a99`**; `index.html` live trỏ
  `pck/ba8e4a99`; ráp lại 52 chunk pck từ live = 6.904.868
  byte, SHA **`ba8e4a99f3bc…`** = đúng SHA build local.
  wasm không đổi (`fc74679e`).
- **Live hiện là bản D-pad + nhãn debug 2 dòng**
  (`Ô (x,y) • <input>` + `H:[...] Q:n A:(x,y) MR:0/1 P:n`).
  Nhãn debug là tính năng chẩn đoán TẠM — giữ lại cho cửa kiểm
  live bằng cloud browser, sẽ ẩn sau khi cửa đó qua.

### 28.4 Việc tiếp theo

1. **Kiểm live bằng cloud browser trên URL thật** (cửa cuối theo
   luật AGENTS.md 20/11 23:21): D-pad 4 nút (mỗi nút 1 ô, đọc
   nhãn debug phóng to), phím D, tap đất trống; lưu ý cửa (5,4)
   ngay cạnh spawn — từ (4,4) bấm RIGHT là sang Map002 theo
   đúng luật, KHÔNG phải lỗi. Chỉ báo chủ khi cửa này qua.
2. **Push main** các file vòng 10/10b (xem §27.3 + §28.5) để
   code GitHub khớp build đã deploy.
3. Ẩn nhãn debug (thêm toggle) sau khi kiểm live qua; rồi tiếp
   G4: animation di chuyển/đánh trận, chọn đội/vũ khí, `can_challenge`,
   tile riêng Map003–018, camera trận.

### 28.5 Push main — file vòng 10/10b (ghi để lượt sau đẩy)

- `src/godot/main.gd` (D-pad + nhãn debug 2 dòng + `P` counter),
  `src/godot/player.gd` (`step_dir`), `src/godot/web_shell.html`
  (focus recovery thêm F/P/E/B), `src/godot/tests/g4_dpad_test.gd`
  (mới, 14/14), `tools/godot/run_regression.sh` (mới, 36 suite),
  `docs/godot-g4.md` (§28) — cộng 3 file cron §27.3 chưa đẩy:
  `src/godot/scripts/battle_scene.gd`,
  `src/godot/tests/g4_battle_names_test.gd` (+ `.uid`).

## 29. Kiểm live bản ba8e4a99 — ĐẠT, di chuyển ĐÃ SỬA XONG (21/11 ~11:32–11:38 +07)

### 29.1 Kết quả kiểm live (cloud browser, browser-task 416fb4f8)

- `versions.json` live: pck `ba8e4a99`, wasm `fc74679e` — đúng bản
  deploy, không phải `7f8ef9bb`. Lưu ý: báo cáo browser ghi thêm
  field `build: "1759218600"` + `map: "ba8e4a99"` trong
  `versions.json` — curl trực tiếp từ VM trước và sau kiểm đều
  KHÔNG thấy 2 field này (chỉ wasm/pck/img), pck vẫn `ba8e4a99`
  cả 2 cách đo nên không ảnh hưởng kết luận; ghi lại để không ai
  tưởng `versions.json` đã đổi.
- Tải vào game: nút BẮT ĐẦU CHƠI bật sau <1 phút (< ngưỡng 120s),
  vào ngay Map001 Xóm Trọ Cũ, Ngày 1, Khung Sáng. 0 console error /
  pageerror / failed request.
- Di chuyển — cả 4 cách đều ĐI ĐƯỢC, xác nhận bằng nhãn debug so
  ô trước/sau (không chỉ nhìn camera):
  - D-pad phải: (4,5) → (5,5), đúng 1 ô.
  - Phím D 1 lần: (5,5) → (6,5), debug hiện input cuối "D".
  - Mũi tên phải 1 lần: (6,5) → (7,5), debug hiện "→".
  - Tap đất trống phía phải: (7,5) → (10,2), debug
    "Ô (10,2) • chạm (10,2)".
  - 4 nút D-pad hiện đủ ở góc dưới trái canvas.
- F: Sáng → Chiều (nhãn "Ngày 1 • Khung Chiều", cảnh hoàng hôn,
  "Hẻm trọ buổi chiều"), nhân vật ở yên (10,2). P: điện thoại mở,
  đủ 9 tab.
- 2 lần "site_in_use" thoáng qua (1 khi bấm D-pad, 1 khi nhấn D)
  — thử lại ngay thì chạy bình thường, không ảnh hưởng kết quả.
- Trạng thái cuối: ô (10,2), khung Chiều, điện thoại đang mở.
- **ĐÍNH CHÍNH kết luận 23:14** (3 vòng live báo không đi được):
  trên bản `ba8e4a99` này di chuyển ĐÃ ĐI ĐƯỢC bằng cả 4 cách.
  Các vòng sửa 9+/10/10b (queue bước + tap tới ô gần nhất +
  D-pad + nhãn debug) đã khép lỗi live.

### 29.2 Push + deploy vòng này (cron 09:45) — đã xong trước kiểm live

- Push main `8f477519` (G4 bước 9 + docs §26–27). Deploy
  gh-pages pck `ba8e4a99` (3 lô của run này: `f375f151` /
  `5f5e59d9` / `0177ff01`; writer song song đẩy cùng pck 5 lô
  `6eddda03` / `1795ec8f` / `a5126dd4` / `06b2dcc5` / `d4b90cdb`
  gồm cả index.html + versions.json nên lô 4 của run này không
  cần đẩy). Verify byte từ live: ráp 52 chunk pck = 6.904.868
  byte, SHA `ba8e4a99f3bc…` = build local; index.html live
  byte-identical staging.
- Main nay: `8aee35f9` (worker Vòng 10b tự đẩy D-pad +
  `run_regression.sh` + docs §28) — code GitHub KHỚP build đã
  deploy, hết lệch §27.3. File ráp pck từ live ở
  `~/workspace/live-move-verify/pck-ba8e4a99/`.

### 29.3 Việc tiếp theo

1. **Ẩn nhãn debug** (toggle, mặc định ẩn) — nhãn là tính năng
   chẩn đoán TẠM (§28.3); cửa live đã qua nên ẩn đi trước khi
   báo chủ. Chu trình: code + test + export + deploy + kiểm
   live lại.
2. G4 tiếp: animation di chuyển/đánh trận; chọn đội/vũ khí trước
   trận; `can_challenge` ở demo; tile riêng Map003–018; camera
   zoom trận; khối chat online đưa lên trên tab Tin nhắn; server
   WS auth + giới hạn tốc độ + lịch sử.
3. Chỉ báo chủ khi nhãn debug đã ẩn + kiểm live lại vẫn đi được
   (cửa §28.4 mục 1 đã qua — báo chủ ở bước này).

## 30. Ẩn nhãn debug mặc định + F9 toggle — XONG CODE + DEPLOY, chờ kiểm live lại (21/11 ~11:45–12:30 +07)

### 30.1 Sửa (`src/godot/main.gd`)

- `_debug_labels_visible := false` (mới, mặc định ẩn); `_dbg_label.visible = not title_open and _debug_labels_visible` trong `_process` (trước chỉ `not title_open`).
- `set_debug_labels_visible(v)` (mới): đổi cờ + áp visibility ngay (`v and not title_open`).
- Phím **F9** trong `_unhandled_input` (sau nhánh E): `set_debug_labels_visible(not _debug_labels_visible)`. F9 không đi qua `_key_to_dir` (không phải phím di chuyển), không mở trận/điện thoại.
- `_update_dbg()` không đổi: text vẫn cập nhật kể cả khi nhãn ẩn, nên bật F9 lên là thấy ngay ô hiện tại + input cuối, không cần đi thêm bước nào. D-pad không bị ảnh hưởng (riêng `_dpad.visible`).

### 30.2 Test + verify headless

- Test mới `tests/g4_debug_toggle_test.gd`: **15/15 PASS** — trước/sau start đều ẩn; F9 bật → hiện (text "(4,5)"), F9 lần 2 → ẩn lại; D-pad phải khi nhãn ẩn vẫn đi (5,5), text cập nhật "(5,5)" dù đang ẩn, P:1; `set_debug_labels_visible(true/false)` trực tiếp đúng.
- `tests/g4_dpad_test.gd` cập nhật theo mặc định mới: sau start kiểm tra nhãn AN, bấm F9 rồi mới đo D-pad — **15/15 PASS** (trước 14/14).
- `tools/godot/run_regression.sh`: thêm `g4_debug_toggle_test` → **37 suite + probe = 38 OK, 0 FAIL** (artpass 60/60, G1 selftest 419/419, G3 playtest 95/95, G2 selftest 87/87, MarketBattle 123/123, battle AI 34/34, battle scene 43/43, coord+WASD 16/16, dpad 15/15, debug toggle 15/15, online server 37/37 + probe OK…).
- `--check-only` main.gd + 2 test đều exit 0; scene Main 120 frame exit 0, không ERROR.
- Export web exit 0: pck mới **6.908.568 byte, SHA `84b8649dbe547e98…`** (trước `ba8e4a99`), wasm không đổi `fc74679e…`, `GODOT_THREADS_ENABLED = false`; HTTP 200 đủ 4 file (cổng 8171).
- Lỗi gặp khi export (ghi để không tái phạm): chạy export từ repo root với đường dẫn `src/godot-build/index.html` thì Godot hiểu tương đối theo `--path src/godot` nên báo "Target folder does not exist" — phải `cd src/godot` rồi export `../godot-build/index.html` như docs G0 §3.

### 30.3 Deploy gh-pages — XONG, verify khớp byte từ live

- Staging `build_gh_pages.py` VERIFY OK (pck 52 chunk, wasm 293 chunk không đổi, img không đổi).
- Push-files 5 lô (source-dir `gh-pages-staging`, head gh-pages trước deploy `0177ff01` đã đối chiếu + remote `versions.json` = pck `ba8e4a99`, không lệch): (1) pck 000–016 → `3cd95d48`; (2) 017–033 → `1fc02d5b`; (3) 034–051 → `165590a5`; (4) `versions.json` → `2575efa3`; (5) `index.html` CUỐI → `0e0b90e0`. Sync record đã ghi đủ 5 commit (150 entries).
- Verify từ live: `--check-live` **OK** (versions.json pin pck `84b8649d`, wasm/img part-000 đều 200, index.html live khớp staging từng byte); ráp lại 52 chunk pck từ live = 6.908.568 byte, SHA **`84b8649d`** = đúng SHA build local (`~/workspace/live-dbg-verify/pck-84b8649d/`).

### 30.4 Kiểm live lại bản 84b8649d — ĐẠT (cloud browser + Playwright F9, 21/11 ~11:59–12:17)

- **Cloud browser trên URL thật** (browser-task cd43c26a, 11:59–12:12, viewport ngang 1920×999 — cột game ~560px, đáy canvas sát mép viewport): nhãn debug mặc định **ẨN** (ảnh phóng to dải đáy ở cả Map001 Khung Sáng và Map002 Khung Chiều: không còn 2 dòng "Ô (x,y)" / "H:[...] Q:.."); di chuyển **ĐẠT** — D-pad ▶ 1 ô, mũi tên/WASD đúng từng ô, ▶+▲ vào cửa (5,4) → Map002 + toast "Đã sang Chợ Đầu Mối" (lần thử đầu phím phải gửi đúng lúc game vừa vào nên không nhận — không phải lỗi game; thử lại từng bước thì chuyển ngay); tap đất trống gần nhân vật đi được; F Sáng→Chiều, P mở điện thoại đủ 9 tab + đóng được; **0 console error / pageerror / failed request**; nút BẮT ĐẦU CHƠI bật sau vài giây.
- **Toggle F9 — cloud browser KHÔNG gửi được** (công cụ bàn phím từ chối phím chức năng; Ctrl+Shift+I/J mở DevTools không hiện; không có evaluate/console để dispatch KeyboardEvent) — không phải lỗi game, mà là giới hạn công cụ. Đã khép bằng **Playwright Chromium 1255 local trên staging** (byte-identical live: index.html khớp từng byte, pck SHA `84b8649d` đã verify từ live): script `hidden_files/pxb-browser-verify-f9.py`, bằng chứng `hidden_files/pxb-browser-verify-2026-11-21/` (ảnh 30–33 + strip + `console-f9.json`) — F9 lần 1: dải đáy đổi **3.787 px**, ảnh 31b đọc rõ nhãn **"Ô (4,5)" + "H:[] Q:0 A:(-1, -1) MR:0 P:0"**; F9 lần 2: dải đáy về baseline **0 px khác**; phím D sau toggle vẫn đi được; 0 console error / pageerror.
- Quan sát mở (không chặn): tap xa phía phải gần vũng nước trên Map002 không di chuyển sau 5s — có thể ô đó bị chặn/ngoài vùng đi được, chưa kết luận tap-to-move hỏng (tap gần đi được; tap live §29.1 (7,5)→(10,2) đã đi được; headless move-input 9/9 gồm tap tới ô gần nhất). Ghi để vòng polish sau xem lại, không coi là bug.
- **Cửa §29.3 mục 3 đã qua: nhãn debug đã ẩn + kiểm live lại vẫn đi được → báo chủ được.**

### 30.5 Việc tiếp theo

1. Điền kết quả kiểm live §30.4; push main (code vòng này + docs §30).
2. G4 tiếp theo (§29.3 mục 2): animation di chuyển/đánh trận; chọn đội/vũ khí trước trận; `can_challenge` ở demo; tile riêng Map003–018; camera zoom trận; khối chat online đưa lên tab Tin nhắn; server WS auth + giới hạn tốc độ + lịch sử.

## 31. G4 bước 10 — Animation di chuyển/đánh trận MarketBattle — XONG (21/11 ~12:20–13:00 +07)

### 31.1 Sửa (`src/godot/scripts/battle_scene.gd` — chỉ lớp vẽ, KHÔNG sửa luật)

- **Trượt khi di chuyển:** vị trí VẼ `_visual_pos` (mới, theo id đấu sĩ)
  trượt về ô logic với tốc độ 420 px/s thay vì nhảy tức thì; `_update_visual_pos`
  gọi mỗi frame (`_process`) + trong `simulate_seconds` (test headless);
  `snap_visual_pos()` đặt ngay về ô logic (dùng sau khi dời tay trong test).
  `setup()` khởi tạo vị trí vẽ đúng ô spawn.
- **Đánh:** `click_tile` "attacked" → `_start_attack_fx` (người đánh, mục tiêu,
  damage/dodged/ko từ `res` của `mb.attack`); `_fighter_draw_pos` lao người
  đánh tới 45% khoảng cách (tối đa 28px, theo sin, 0.45s) + rung mục tiêu
  ±3px; vòng chớp trắng trên mục tiêu (đỏ khi KO), mờ dần.
- **Hỗ trợ:** `_start_support_fx` → vòng xanh lan ra (22→40px) + chữ "+N HP"
  bay lên, mờ dần trong 0.6s.
- **Lượt AI:** `_run_ai_turn` chụp HP trước/sau `ai_take_turn`, suy fx từ
  chênh lệch (HP giảm = bị đánh, HP tăng = được hỗ trợ) — vì `ai_take_turn`
  chỉ trả chuỗi mô tả, không trả id mục tiêu.
- Test mới `tests/g4_battle_anim_test.gd`: **24/24 PASS** — vị trí vẽ còn ở ô
  cũ ngay sau click, sau 0.1s đã rời ô cũ, sau 0.6s về đúng ô mới; đánh
  đúng 9 HP (Tank giảm thương, luật không đổi), lao tới >8px giữa animation,
  fx hết sau 0.45s; hỗ trợ +12 HP, fx hết sau 0.6s; lượt AI đánh trúng A1
  + thấy fx. (Lỗi test ban đầu: đặt A1 chồng ô (1,4) của A2 nên AI đánh A2
  thay vì A1 — đã dời A2/A3 ra xa; bài học: đừng để 2 đấu sĩ cùng ô trong
  setup test.)
- `tools/godot/run_regression.sh`: thêm `g4_battle_anim_test` → 38 suite + probe.

### 31.2 Verify vòng này

- Hồi quy đầy đủ: **39 OK, 0 FAIL** (38 suite + probe server); battle anim
  24/24, battle scene 43/43, battle AI 34/34, battle main 15/15, battle save
  31/31, MarketBattle 123/123, artpass 60/60, G1 419/419, G3 95/95.
- Smoke `--headless --quit-after 120` exit 0, không ERROR.
- Export web exit 0: pck **6.918.732 byte, SHA `7dec3410…`**, wasm không đổi
  `fc74679e…`; HTTP 200 đủ 3 file (cổng 8172).
- **Browser-verify thật (Chromium 1255 + swiftshader, 720×1280, script
  `hidden_files/pxb-browser-verify-battle-anim.py`, ảnh
  `hidden_files/pxb-browser-verify-2026-11-21/34–35`):** engine-start OK,
  start-clicked OK, B mở trận đúng (BỤI ĐỜI CHỢ CÁ, 100%–100%, Vòng 1/12),
  click ô xanh (2,3) → log "Bạn di chuyển tới (2,3).", vòng đỏ Bạn sang
  đúng ô (2,3), ô xanh hết sau khi đi; **0 console error, 0 pageerror**.
  Lưu ý đo: game chạy ~0.43× thời gian thật trên swiftshader nên ảnh
  +300ms đã gần tới đích (trượt 2 ô chỉ ~0.17s game) — trượt giữa đường
  chứng minh bằng headless 24/24 (vị trí vẽ còn ở ô cũ ngay sau click),
  không bắt được khoảnh khắc giữa đường trên ảnh tĩnh ở tốc độ này.
  Fx đánh/hỗ trợ chỉ verify headless (địch ở xa, không kịp đưa vào tầm
  trong 1 lượt kiểm nhanh) — ghi rõ, không nói quá.

### 31.3 Deploy gh-pages — XONG

- Staging `build_gh_pages.py` VERIFY OK (pck `7dec3410` 52 chunk, wasm
  `fc74679e` không đổi, img đủ 3 ảnh, loader cứng đủ marker, icon inline
  đủ 3 data URI).
- Push-files 5 lô (head gh-pages trước deploy `0e0b90e0` theo sync record;
  live `versions.json` lúc đó vẫn pck `84b8649d`, không lệch): (1) pck
  000–016 → `cb147518`; (2) 017–033 → `990661d2`; (3) 034–051 →
  `975fe3b8`; (4) `versions.json` → `6a34974f`; (5) `index.html` CUỐI →
  `52f246eb`. Sync record đã ghi đủ 5 commit (156 entries). Trước lô 4 đã
  verify qua API: blob SHA 2 mẫu chunk (part-000 `1680b32d…`, part-051
  `5dd00342…`) khớp staging (tính theo git blob SHA-1, không phải sha256
  file — bài học: đừng so sha256 với blob SHA).
- Verify từ remote (raw.githubusercontent.com, tránh CDN Pages còn cache
  bản cũ): ráp lại 52 chunk pck = 6.918.732 byte, SHA **`7dec3410b9204115`**
  = build local; `index.html` SHA `52053681a2e9` = staging;
  `versions.json` trên branch = pck `7dec3410`. Lưu ý: `versions.json` qua
  domain Pages vẫn hiện `84b8649d` ngay sau deploy (CDN chậm vài phút như
  §19.8) — repo đã đúng, không kết luận deploy sai vì CDN.

### 31.4 Push main — XONG (riêng vòng này, không chung vòng 11)

- Push main `de283d81` (5 file: `battle_scene.gd`, `g4_battle_anim_test.gd` +
  `.uid`, `run_regression.sh`, `docs/godot-g4.md` §31). Trước push đã đối
  chiếu: head main vẫn `da241a4d`, remote `battle_scene.gd` là bản trước
  animation (không có `_visual_pos`), file test mới xác nhận ABSENT.
  Code GitHub khớp build live `7dec3410` tại thời điểm push. (Vòng 11 sau
  đó export pck mới `a87a871d` trên cây gộp — deploy bản đó sẽ thay live;
  xem §32.4.)

### 31.5 Việc tiếp theo

1. G4 tiếp: chọn đội/vũ khí trước trận; `can_challenge` ở demo; tile riêng
   Map003–018; camera zoom trận; khối chat online đưa lên tab Tin nhắn;
   server WS auth + giới hạn tốc độ + lịch sử.
2. Kiểm live bằng cloud browser trên URL thật sau deploy (cửa cuối theo
   luật AGENTS.md): mở trận bằng B, click ô xanh xem trượt, chờ lượt AI
   xem địch di chuyển/đánh có animation.

## 32. Vòng 11 — Tap-to-move + lỗi biên Map002 + nhãn debug stale (21/11 ~12:00–14:00 +07)

### 32.1 Kiểm live 11:33–11:57 báo 2 lỗi — probe KHÔNG tái hiện được lỗi nào

- Kiểm live (browser task `9b4d13eb`): D-pad/WASD đi đúng 1 ô/lần, F/P OK,
  0 lỗi console. Nhưng báo: (1) tap đất trống → nhãn nhảy tới ô đã chạm
  (vd "Ô (9,4) • chạm (9,4)") nhưng sprite KHÔNG đi tới đó sau 4s
  (tọa độ sprite ~(930,760) trước/sau sai số ~2px); (2) bấm phải tại
  (9,4) Map002 → về (7,4) thay vì (10,4), chu trình 8→9→7 (tái hiện 2×);
  (3) nhãn debug bị nhãn cửa Map002 che.
- Probe Chromium local trên ĐÚNG bản live `ba8e4a99` (staging `/tmp/r11-live`,
  `versions.json` pin pck live; script `visual-check/artpass11/probe_live.py`,
  `probe2.py`, `probe3.py`, `probe4.py`):
  - (9,4)→(10,4) đúng cả 3 lần probe (D-pad, tap xen kẽ, burst); bấm phải
    tại (10,4) → vẫn (10,4) đúng [(11,4) là biên, `layers[1]` chặn].
    Data Map002 đúng: chỉ biên bị chặn, (10,4) đi được, cửa (5,4)→Map001.
  - Tap hợp lệ (900,806)→(10,6): nhãn tới (10,6), diff ảnh trước/sau
    13,2% = camera cuộn theo (sprite ĐI THẬT). Tap (1000,850) đầu tiên
    không làm gì vì map ra ô (14,6) ngoài biên — điểm tap xấu, không phải bug.
  - Phép đổi chạm→ô ĐÚNG toán iso (phải = +x/−y): tap ngang hàng nhân vật
    mà nhãn nhảy lên 2 hàng là đúng (vd (7,4)→(9,2)).
  - **Bằng chứng "sprite không đi" của checker là SAI PHƯƠNG PHÁP:**
    camera bám theo người chơi nên sprite gần như đứng yên TRÊN MÀN HÌNH
    (tọa độ màn hình ~không đổi) trong khi đi thật — phải so landmark
    (biển hiệu/cửa) trước/sau, không đo tọa độ sprite trên màn hình.
  - rAF chỉ **3,0 fps** trên swiftshader (không phải lỗi game): mỗi bước
    cần ~2 frame (~0,66s) nên đi chậm trên máy kiểm local, nhưng tween
    0,15s vẫn xong trong 1 frame.

### 32.2 Gốc thật tìm ra: NHÃN DEBUG STALE (không phải tap hỏng)

- Sau tap, nhãn hiện `A:(10,6)` MÃI dù người chơi đã tới (10,6):
  `_update_dbg()` trước đây chỉ gọi từ `moved_to` — mà `moved_to` chạy
  TRƯỚC khi queue pop / auto-target clear trong `player._process`
  (xem `player.gd`: `moved_to.emit` rồi mới pop queue; `_step_toward_auto`
  clear `A` im lặng, không refresh nhãn). Tương tự `Q:1` kẹt sau khi
  queued step bị chặn (không có `moved_to` mới để refresh).
- Chính nhãn stale này làm checker (và vòng 11 lúc đầu) tưởng tap "chỉ
  cập nhật ô logic, không kéo sprite". Chu trình (9,4)→(7,4) nhiều khả
  năng cũng là đọc nhãn giữa lúc auto-walk/stale (không tái hiện được
  bằng D-pad, tap, hay xen kẽ tap+D-pad).

### 32.3 Sửa (`src/godot/main.gd` — vòng 11)

- **Nhãn luôn tươi:** `Main._process` gọi `_update_dbg()` MỖI FRAME
  (kể cả khi ẩn) — A:/Q: không bao giờ stale nữa.
- **Dời nhãn:** (24,1172) cuối canvas → **(24,200) góc trên-trái, dưới
  panel HUD**; nền tối mờ 72% + chữ kem, size (440,64) cho đủ 2 dòng —
  không còn bị nhãn cửa Map002 (kẹp y≤1200) che.
- **Mặc định ẩn KHÔNG ĐỔI** (`_debug_labels_visible=false`, F9 toggle) —
  bản live `ba8e4a99` đã ẩn sẵn (probe 1 không F9 thì không thấy nhãn).
- Test mới `tests/g4_r11_dbg_test.gd`: **11/11 PASS** — nhãn mặc định ẩn
  + ở (24,200); Map002 (10,4) đi được / (11,4) chặn; D-pad phải
  (9,4)→(10,4), phải nữa vẫn (10,4); tap tới (10,6) + nhãn tươi
  `A:(-1,-1)`. (Bài học test: `process_frame` chạy TRƯỚC `Main._process`
  nên phải đợi thêm 3 frame sau khi A clear mới đọc nhãn.)
- `run_regression.sh`: thêm `g4_r11_dbg_test` → 39 suite + probe.

### 32.4 Verify + push + deploy — (điền sau khi xong)

- Hồi quy đầy đủ: **40 OK, 0 FAIL** (39 suite + probe — đã gồm
  `g4_r11_dbg_test` 11/11 và `g4_battle_anim_test` 24/24).
- `--check-only` main.gd OK; export web exit 0: pck **6.922.136 byte,
  SHA `a87a871d…`**, wasm không đổi `fc74679e…`.
- Browser-verify bản mới `a87a871d` (staging `gh-pages-staging`,
  `probe4_verify.py`, Chromium 1255 + swiftshader): nhãn mới góc trên-trái
  nền tối đọc rõ; (9,4)→(10,4) đúng, phải nữa vẫn (10,4); tap → (10,6)
  + nhãn tươi `A:(-1,-1)`; diff ảnh sau tap 11,6% (camera cuộn);
  0 console error.
- Push main — **XONG, commit `aaf2b5c5`** (5 file: `main.gd`, test r11 +
  `.uid`, `run_regression.sh`, docs §32). Lưu ý: lần push đầu bị từ chối
  "not a fast forward" vì agent §31 push xen vào (`de283d81`, battle anim)
  — đã đối chiếu lại: `battle_scene.gd` IDENTICAL, `main.gd`/`run_regression.sh`/
  docs chỉ khác đúng phần r11, rồi push lại từ head mới. Bài học: `list_commits`
  muốn xem branch khác phải dùng tham số `sha`, không phải `branch`.
- Deploy gh-pages — **XONG, 5 lô**: (1) pck 000–016 → `dcb80bbc`;
  (2) 017–033 → `009d5145`; (3) 034–051 → `29e1fdde`;
  (4) `versions.json` → `e6134e80`; (5) `index.html` CUỐI → `91dfacf4`.
  Sync record 163 entries.
- Verify từ remote: ráp lại 52 chunk pck = 6.922.136 byte, SHA
  **`a87a871dc2f9d2ce`** = build local; `index.html` SHA `4fa85edcea5fc7af`
  = staging; `versions.json` qua API blob SHA `7882a5da` = staging, pck
  `a87a871d` (raw.githubusercontent.com vẫn hiện `7dec3410` ngay sau deploy
  do CDN cache — đã biết từ §31, không phải deploy sai).
- **Kiểm độc lập lại (cron 12:45, 21/11 ~12:55):** ráp lại 52 chunk pck
  từ live = 6.922.136 byte, SHA `a87a871dc2f9d2ce…` = build local;
  `index.html` live (Pages) SHA `4fa85edc…` = staging; `versions.json`
  live (Pages) pin pck `a87a871d` — khớp hết, không cần deploy lại.
  File ráp ở `~/workspace/live-r11-verify/pck-a87a871d/pck.bin`.

### 32.5 Việc tiếp theo

1. Kiểm live bằng cloud browser trên URL thật sau deploy (cửa cuối):
   tap + D-pad ở Map002 hàng 4, đọc nhãn mới góc trên-trái.
2. G4 tiếp: chọn đội/vũ khí trước trận; `can_challenge` ở demo; tile riêng
   Map003–018; camera zoom trận; khối chat online đưa lên tab Tin nhắn;
   server WS auth + giới hạn tốc độ + lịch sử.

## 33. Vòng 12 — Hồi quy D-pad + Map002 vỡ hình + nhãn debug ẩn (21/11 ~13:15–15:30 +07)

### 33.1 Kiểm live 12:56–13:14 báo hồi quy so với kiểm 11:33 (pck `a87a871d`)

1. D-pad/phím hỏng lại ở Xóm Trọ Cũ (Lên/Xuống không đi; Phải/Trái
   thất thường; D/ArrowRight ×3 không đi; F/P vẫn nhận).
2. Map002 vỡ hình + kẹt nhân vật: nhãn "Cửa đi Khu Công Nhân",
   "Sạp rau buổi sáng", "Chị Lệ", "Anh Hải" dồn thành cột ở vùng
   trời; sạp nén thành dải hẹp; dải tối ngang; nhân vật kẹt ở điểm vào.
3. Nhãn debug không thấy (vòng 11 để mặc định ẩn, checker không biết F9).
4. Tap ở Xóm Trọ Cũ vẫn đi được — giữ nguyên.
5. Phụ: NPC Cô Tư / nhãn cửa đè lên vùng D-pad.

### 33.2 Tái hiện (probe Chromium local, đúng bản live `a87a871d`)

- **Lỗi 1 KHÔNG tái hiện:** Map001 D-pad 4 hướng + phím D +
  ArrowRight + tap đều đi đúng 1 ô, Q:0, 0 lỗi console. Kết luận:
  triệu chứng live của checker nhiều khả năng là artifact của
  harness (tọa độ click/viewport) hoặc bản lai CDN, không phải lỗi
  code — không bịa fix cho lỗi 1, chỉ giữ nguyên + kiểm lại sau deploy.
- **Lỗi 2 tái hiện ngay khi vào Map002:** 4 nhãn dồn cột ở trời,
  sạp nén dải hẹp, dải tối ngang. Nhưng D-pad Trái vẫn đi được
  (5,4)→(4,4) — nhân vật KHÔNG kẹt trên staging; tap Map002 chưa
  được thử (probe quay về Map001 trước).
- Dị thường chẩn đoán: bản deploy `a87a871d` hiện nhãn debug mà
  KHÔNG cần F9, và P đọc 1 sau 1 lần bấm phím — ngược với source
  lúc đó (mặc định ẩn). Nghĩa là pck deploy được build từ working
  copy khác source hiện tại ở ít nhất default nhãn debug. P:0 sạch
  ở probe vòng 12b (bấm nút start bằng selector thay vì tọa độ
  hardcode) — P:1 trước đó là click lạc vào vùng D-pad, không phải
  lỗi đếm phím.

### 33.3 Gốc thật (probe headless engine)

- **Nhãn bay lên trời:** `_resolve_label_overlaps` + `_nearest_free_y`
  khắc khoảng trống dọc bằng vật cản (mỗi cái phồng LABEL_GAP 12);
  ở Map002 các marker cụm giữa màn hình nên mọi khoảng trống gần y
  muốn đều bị khắc hết, fallback cũ áp `best_y` dù cách 200–600px
  ("Sạp rau" want 818 → 606; "Cửa đi" want 1162 → 556). Kèm bug
  khoảng đảo (`[lo,hi]` với lo > hi) làm `clampf` trả giá trị rác.
- **Dải tối:** `sky_band.png` (1120×280) ở offset+(0,-190) = y −28..252;
  ảnh đất ở (360,730) = y 280..1180 → khe 28px (252..280) lộ màu
  clear tối.
- **Sạp nén:** `NadiaScene._draw_facades` vẽ 12 mặt tiền 64px tại
  tâm iso cách nhau 32px → chồng ngang 50% (biển 58px, mái 60px bị
  hàng xóm che nửa).
- Map001 không dính vì marker thưa + nền composite vẽ sẵn phủ kín
  đầu màn hình. NPC không đi lang thang (tĩnh) — chồng D-pad là do
  camera di chuyển, không phải NPC đi lại.

### 33.4 Sửa

`src/godot/main.gd`:
- Nhãn debug **hiện mặc định** trở lại (`_debug_labels_visible=true`),
  F9 vẫn toggle, vị trí (24,200) giữ nguyên.
- `_resolve_label_overlaps`: thêm rect D-pad `DPAD_RECT (48,880,160,160)`
  làm vật cản khi D-pad hiện; fallback **giữ nguyên y muốn** khi
  `best_y` xa (thay vì áp best_y 200–600px) — nhãn có thể chạm sprite
  1 chút nhưng vẫn neo đúng marker.
- `_nearest_free_y`: chỉ thêm khoảng còn lại hợp lệ (`up > lo`,
  `dn < hi`) — không còn khoảng đảo.
- `LABEL_MAX_DRIFT` 60 → **120.0** (3 chiều cao nhãn, vẫn neo rõ).
- Ảnh đất (360,730) → **(360,700)**: mép trên 250 chồng lên đáy
  ảnh trời 252 — hết dải tối. An toàn cho Map001 (nền composite
  vẫn phủ y −308..322) và Map003+ (cùng sky_band).
- **Vòng 12b** (sau khi test mới lộ 3 lỗi hồi quy, xem §33.5):
  - `LABEL_ESCAPE_MAX_DRIFT = 200.0`: nhãn ở y muốn mà đè lên
    nhân vật chính / nút D-pad đáng kể (giao nhau ≥10px cả 2 chiều)
    thì được nhảy xa tới 200px (D-pad 121px, "Góc Chế Tạo" Map001
    165px, "Hẻm trọ" (11,8) 135px); xa hơn thì giữ neo ("Sạp rau"
    Map002 spawn 249px — nhảy thì mất neo, đứng yên thì chỉ che
    nhân vật tạm thời ở điểm spawn). Đè lên NPC/icon thì không tính.
  - Lượt tách nhãn chồng nhau sau vòng chính: đẩy nhãn TRÊN lên
    (chồng + LABEL_GAP), kèm **cascade 1 cấp** (nhãn chặn cũng được
    đẩy lên 1 nấc — vd "Cửa về" muốn lên 1112 bị "Góc Chế Tạo" ở
    1081 chặn thì đẩy "Góc Chế Tạo" lên 1062 trước); không lên
    được thì đẩy nhãn dưới xuống. Vật cản lượt tách chỉ tính
    "cứng" (nhân vật + D-pad + sprite NPC, không tính icon 48px).
    Sửa 2 nhan cửa Map002: spawn tách ra 12px (1112/1162); ở (4,4)
    sau Trái cũng tách (cascade).
  - Thứ tự xử lý giữ y tăng dần (thử y giảm dần ở vòng 12b làm
    "Góc Chế Tạo" Map002 bay xuống 556px vì vật cản của cửa che
    mất khoảng trống gần 978 — đã hoàn lại).

`src/godot/scripts/nadia_scene.gd`:
- `_draw_facades` rẽ sang `_draw_market_row()` riêng cho `map_id == 2`:
  đoạn tường/mái 34px mỗi ô (chồng 2px giấu khe cầu thang iso), shop
  chỉ ở ô CHẴN (biển 58px + mái 60px vừa khoảng 64px, không chồng),
  cửa sổ + chậu hoa ở ô LẺ. Map003+ giữ vẽ cũ (tạm, ngoài phạm vi).

Test:
- Mới `tests/artpass12_test.gd` (14 kiểm): nhãn debug mặc định hiện;
  Map002 nhãn neo ≤120px (ngoại lệ thoát ≤200px khi y muốn đè lên
  nhân vật/D-pad), trong màn hình, không đè D-pad, không cặp nào
  chồng nhau ≥1px (ngưỡng 1px bỏ qua sai số float 0,5px); không dải
  tối; D-pad Trái Map002; tap tới (8,6) Map002; Map002 (4,4) sau
  Trái (đúng repro); Map001 (11,8); D-pad Phải nhanh ×3; bộ đếm P:5.
  Thứ tự test: tap TRƯỚC, bấm Trái SAU — tap từ (4,4) tới (8,6) đi
  ngang qua cửa (5,4) sẽ transfer về Map001 (không phải tap hỏng).
- `tests/g4_debug_toggle_test.gd`, `tests/g4_r11_dbg_test.gd`,
  `tests/g4_dpad_test.gd` cập nhật theo default mới (hiện; F9 2 chiều).
- `tools/godot/run_regression.sh`: thêm `artpass12_test` → 41 mục.

### 33.5 Verify vòng này

- `--check-only --script` cho `main.gd`, `nadia_scene.gd`,
  `artpass12_test.gd`: exit 0. Lưu ý: `--check-only` toàn project
  (không `--script`) treo >45 phút (tiến trình Godot vẫn chạy 5% CPU,
  không kết thúc) — đã kill và dùng `--script` từng file thay thế;
  test headless chạy được chứng tỏ code parse tốt. (Cần xem lại sau:
  có thể do import toàn project.)
- Hồi quy đầy đủ: **41 OK, 0 FAIL**.
- Export web exit 0: pck **6.941.688 byte, SHA `80da1a51…`**, wasm
  không đổi `fc74679e…`.
- Browser-verify bản mới `80da1a51` (staging `gh-pages-staging`,
  `verify_fix.py` + `verify_tap_map002.py`, Chromium + swiftshader):
  0 console error, 0 request fail cả 2 phiên. Map001: nhãn debug
  hiện mặc định `Ô (4,5)` P:0 (không F9); D-pad Lên (4,4) / Xuống
  (4,5) / Trái (chặn bởi Bạn Thân, P:3) / Phải (5,5) / phím D (6,5)
  / ArrowRight (7,5) đều đúng 1 ô; tap → (8,1) `chạm (8,1)`.
  Map002: vào bằng cửa (5,4) P:2; Trái → (4,4) P:3 (không kẹt);
  tap → (8,6) `chạm (8,6)` rồi (8,7) — tap trong Chợ đi được;
  2 nhãn cửa tách nhau (1112/1162, khe 12px) cả ở spawn lẫn sau
  Trái (cascade vòng 12b); nhãn neo gần marker, sạp đọc được từng
  biển (RAU CỦ / HOA QUẢ / BÁNH MÌ), không dải tối, không cột
  nhãn ở trời. Lưu ý probe: tap ở (620,900) trong Map002 ánh xạ
  ra ngoài map (6,-1) nên không đi — lỗi điểm chạm của probe,
  không phải lỗi game; đã thử lại đúng điểm (8,6) thì đi được.
  Phải ở (5,4) Map002 là cửa về Map001 (transfer đúng luật) nên
  các bước sau đó của probe chạy ở Map001 — không phải lỗi.
- Push main — **XONG, commit `31f82a77`** (9 file: `main.gd`,
  `nadia_scene.gd`, test artpass12 + `.uid`, 3 test cập nhật,
  `run_regression.sh`, docs §33). Đối chiếu trước push: 6 file cũ
  remote-at-head blob SHA = blob SHA tại sync base (không divergence);
  2 file mới chưa có trên remote. Sync record 171 entries.
- Deploy gh-pages — **XONG, 5 lô**: (1) pck 000–016 → `87839c18`;
  (2) 017–033 → `3770e7af`; (3) 034–051 → `564d39cc`;
  (4) `versions.json` → `d06d49e2`; (5) `index.html` CUỐI →
  `6e7c4af7`. Gh-pages head trước deploy `91dfacf4` khớp record.
- Verify từ live (raw.githubusercontent.com, VM không tới được
  github.io): ráp lại 52 chunk pck = 6.941.688 byte, SHA
  **`80da1a51d0c6459b`** = build local; `index.html` live SHA
  `4e88b570…` = staging; `versions.json` live pin pck `80da1a51`,
  wasm `fc74679e`. File ráp ở `/tmp/live-r12-verify/pck-80da1a51/`.

### 33.6 Việc tiếp theo

1. Kiểm live bằng cloud browser trên URL thật sau deploy (cửa cuối):
   D-pad 4 hướng + phím D + tap ở cả 2 map, vào Chợ bằng cửa rồi bấm
   Trái xem còn vỡ hình không, đọc nhãn debug góc trên-trái.
2. Nếu live tái hiện lỗi 1 (D-pad chết ở Map001): đối chiếu
   `versions.json` + SHA pck trước (nghi bản lai CDN), rồi mới nghi
   code.
3. Map003+ vẫn dùng vẽ facade cũ chồng 50% (tạm) — sửa khi tới lượt.
4. Map002 vẫn dùng lại ảnh đất của Map001 (lá/xe đạp/xe đẩy) — cần
   ảnh đất riêng cho chợ khi làm art Map002.

## 34. Vòng 13 — FOCUS_NONE cho mọi nút (21/11 ~14:50–15:30 +07)

### 34.1 Gốc (lỗi thật, tìm được trong báo cáo tái hiện r12)

Báo cáo tái hiện r12 (~14:00) chỉ ra: chỉ nút D-pad có
`focus_mode = FOCUS_NONE` (`main.gd:2375`); 7 chỗ `Button.new()`
còn lại — "Bắt đầu chơi", "Đổi khung (F)", "Việc làm",
"Điện thoại (P)", 9 tab điện thoại, nút hành động điện thoại, nút
lựa chọn hội thoại — đều giữ `FOCUS_ALL` mặc định. Sau khi bấm
bằng chuột, nút giữ focus bàn phím và phím mũi tên (`ui_*`) bị hệ
focus navigation của Godot ăn mất trước khi tới
`Main._unhandled_input` → mũi tên không đi. F/P vẫn chạy vì không
phải `ui_*` — đúng triệu chứng live 12:56 (D-pad lên/xuống không
đi, F/P vẫn nhận). WASD (`KEY_D`...) không phải `ui_*` nên lý
thuyết vẫn tới được — việc phím D cũng chết trên live chưa giải
thích hết (nghi bản lai CDN / môi trường checker), nhưng sửa focus
vẫn bắt buộc. Vòng 12 chưa sửa vì lúc đó đang sửa cùng file.

### 34.2 Sửa

`src/godot/main.gd` — 1 dòng trong `_style_button` (bao phu tất cả
8 chỗ `Button.new()`, kể cả nút thêm sau này):
`b.focus_mode = Control.FOCUS_NONE` + comment giải thích. Dòng
riêng ở nút D-pad giữ nguyên (thừa nhưng vô hại, comment của nó
đã ghi lý do từ vòng 10).

### 34.3 Test mới `tests/g4_focus_none_test.gd` (13 kiểm)

- Tĩnh: nút Bắt đầu / Đổi khung / Việc làm / Điện thoại (P) /
  4 nút D-pad / 9 tab điện thoại / nút hành động / 2 nút lựa chọn
  hội thoại — tất cả `FOCUS_NONE`.
- Chức năng: `grab_focus()` lên nút HUD rồi kiểm
  `gui_get_focus_owner() == null` (FOCUS_NONE thì không lấy được
  focus). Trước sửa: 5/13 PASS, kiểm này FAIL đúng (focus owner =
  Button — probe xác nhận); sau sửa: **13/13 PASS**.
- Trung thực về giới hạn: headless KHÔNG tái hiện được việc GUI ăn
  phím mũi tên (event tiêm qua `Input.parse_input_event` vẫn tới
  `_unhandled_input` dù nút đang focus — probe `zz_focus_probe`
  đã xóa; bài học này khớp luật "headless không đáng tin cho di
  chuyển" trong AGENTS.md). Bước ArrowRight trong test chỉ là kiểm
  sanity "vẫn đi", không phải bằng chứng sửa — bằng chứng thật phải
  là kiểm live trên web sau deploy (bấm nút HUD bằng chuột thật rồi
  bấm mũi tên).
- `tools/godot/run_regression.sh`: thêm `g4_focus_none_test` →
  42 suite.

### 34.4 Verify vòng này

- `--check-only --script` cho `main.gd`,
  `g4_focus_none_test.gd`: exit 0. Scene 120 frame exit 0.
- Hồi quy đầy đủ: **42 OK, 0 FAIL** (41 cũ + 1 mới).
- Export web exit 0: pck **6.945.720 byte, SHA `d691d82e…`**,
  wasm không đổi `fc74679e…`. HTTP 200 đủ 6 file (cổng 8161).
- Push main — XONG, commit `33551e47` (5 file: `main.gd`,
  test mới + `.uid`, `run_regression.sh`, docs §34). Đối chiếu
  trước push: head `91a57d0b` khớp record; commit mới nhất chạm
  `main.gd` / `run_regression.sh` = `31f82a77` (đúng sync base),
  `godot-g4.md` = `91a57d0b` (đúng sync base), test mới chưa có
  trên remote — không divergence. Sync record 173 entries.
- Deploy gh-pages — **GIỮ LẠI (chưa deploy)**: lúc push, kiểm live
  bản `80da1a51` (§33.6 mục 1) vẫn đang chạy trên cloud browser
  (task `browser-task:145187af...`, bắt đầu ~14:39) — deploy pck
  mới giữa chừng sẽ làm checker thấy bản lai và kết quả kiểm mất
  giá trị. Deploy `d691d82e` ở run sau, ngay khi kết quả kiểm live
  về (dù pass hay fail đều deploy, vì fix này là đáp án cho triệu
  chứng "mũi tên chết sau khi bấm nút" nếu kiểm live tái hiện nó).

### 34.5 Việc tiếp theo

1. Deploy pck `d691d82e` lên gh-pages khi kiểm live `80da1a51`
   xong (đối chiếu `versions.json` + SHA pck như §33.5).
2. Kiểm live bản mới: bấm nút HUD ("Điện thoại (P)") bằng chuột
   thật rồi bấm mũi tên — phải đi được ngay, không cần bấm lại
   canvas; kiểm tương tự sau khi bấm nút "Việc làm" và sau khi
   đóng hội thoại NPC.
3. Map003+ vẫn dùng vẽ facade cũ chồng 50% (tạm) — sửa khi tới lượt.
4. Map002 vẫn dùng lại ảnh đất của Map001 — cần ảnh đất riêng cho
   chợ khi làm art Map002.

### 34.6 Deploy `d691d82e` lên gh-pages + kiểm nhanh (21/11 ~15:00–15:20 +07)

- Đối chiếu trước deploy: `versions.json` remote trên gh-pages pin
  đúng pck `80da1a51` tại head `6e7c4af7` (= deploy vòng 12); đường
  dẫn `pck/d691d82e/part-000.txt` chưa tồn tại remote — deploy là
  nối tiếp sạch, không divergence. (Lưu ý: sync record gh-pages
  `src/nadia/www.muse-github-snapshot-sync.json` đã stale từ vòng 8
  — các vòng 9–12 không ghi entry; đã ghi bù 5 entry của vòng này,
  18 → 23 entry. Các commit gh-pages vòng 9–12 vẫn thiếu trong
  record — không đoán paths để ghi bù.)
- Rebuild staging `tools/godot/build_gh_pages.py`: VERIFY OK, 52
  chunk pck, wasm `fc74679e` không đổi.
- Deploy 5 lô (mỗi lô ≤18 file): `44a032a6` (chunk 000–016),
  `2ffe8b76` (017–033), `40ca84b6` (034–051), `fa085d62`
  (`versions.json`), `8c1e7d3e` (`index.html` CUỐI — head gh-pages).
- Verify khớp byte từ live: ráp 52 chunk từ
  `raw.githubusercontent.com` = 6.945.720 byte, SHA `d691d82e` ✓;
  `versions.json` live pin `d691d82e` tại head `8c1e7d3e` ✓;
  `index.html` live SHA `73dfdad05180fe42` = staging ✓ (ngay lần
  fetch đầu, không dính CDN cache cũ).
- Kiểm nhanh Chromium local trên đúng bản deploy (staging, cổng
  8162, viewport 720×1280, probe
  `visual-check/artpass13/check_focus_deploy.py`): 0 console error,
  0 request fail.
  - Spawn Ô (4,5). D-pad ▶ → (5,5) ✓. **FOCUS TEST ĐẠT**:
    bấm ArrowRight ngay sau khi click nút D-pad → (6,5) ✓ (trước
    fix, mũi tên sẽ bị GUI ăn focus). ArrowUp → (6,4) ✓, ArrowDown
    → (6,5) ✓, ArrowLeft → (5,5) ✓. D-pad ▲ → (5,4) (= ô cửa,
    chuyển sang Chợ Đầu Mối — đúng luật) rồi ▼ → (5,5) ✓. Phím D
    → (6,5) ✓. P:1→3 đúng số lần bấm D-pad, không click lặp.
  - Tap: (600,1150) đăng ký `chạm (10,6)`, đi (4,5)→(10,6) ✓;
    (500,900) đăng ký `chạm (4,1)`, đi (4,5)→(4,1) ✓. Nhưng 2
    điểm chạm vùng trên (200,750) và (500,700) KHÔNG đăng ký gì
    (A vẫn (-1,-1)) — map ra ngoài hình thoi đất (chạm vào ảnh
    nền mặt tiền/trời, không có ô). Và tap (200,900) đăng ký đích
    (1,5) nhưng KHÔNG di chuyển, A xóa ngay trong 0,5s — đường đi
    qua (3,5) nơi Bạn Thân đang đứng: auto-walk bỏ cuộc khi bước
    tiếp bị NPC chặn thay vì đi vòng. Cả 2 đều là hành vi cũ (không
    phải hồi quy của fix focus), ghi lại làm việc cho vòng sau:
    (a) tap-to-move cần pathfind vòng NPC thay vì bỏ đích khi gặp
    chướng ngại; (b) chạm ngoài hình thoi đất nên có phản hồi
    (hoặc mở rộng vùng chạm) thay vì im lặng.
- Kết luận: fix focus đã live trên `d691d82e` và kiểm local đạt.
  Còn cần kiểm live bằng cloud browser trên URL thật (§34.5 mục 2:
  bấm nút HUD thật rồi bấm mũi tên) để chốt hẳn.

## 35. Vòng 14 — Tap BFS vòng NPC + chạm ngoài hình thoi + nhãn Map002 hết nổi cao (21/11 ~15:45–16:30 +07)

### 35.1 Việc làm (4 lỗi từ kiểm live 14:55 + §34.6)

1. **Tap-to-move bỏ cuộc khi NPC chặn đường** (vòng 13: tap (200,900) → đích (1,5) nhưng đường qua (3,5) có Bạn Thân → A xóa ngay, không đi).
   Gốc: `player.gd:_step_toward_auto()` chỉ thử 2 hướng tham lam theo |dx|/|dy|.
   Sửa (`player.gd`): BFS 4 hướng `_find_path(from, to)` trên lưới 12×9 qua `is_walkable` (tránh NPC/tường), lưu `_auto_path`; `_step_toward_auto()` đi theo đường, tính lại khi bước kế bị chặn; `_clear_auto()` xóa cả đích lẫn đường (phím/D-pad bấm tay hủy tap-walk); guard kề ô (`_tile_dist == 1`) chống đường lệch khi đặt đích giữa tween (không xảy ra vì `_try_step` đặt `tile` = đích ngay khi bắt đầu tween — guard chỉ là lưới an toàn).
2. **Chạm ngoài hình thoi đất thì im lặng** (vòng 13: (200,750)/(500,700) không đăng ký gì).
   Sửa (`main.gd` nhánh tap): `world_to_tile` ngoài biên → kẹp về ô trong biên gần nhất (`clampi` 0..11/0..8) rồi `_nearest_walkable` → đi tới ô đi được gần nhất (chạm vào mặt tiền thì đi tới trước cửa hàng đó); không có ô đi được nào thì toast "Chỗ đó không đi được." (thay vì im lặng). Cả nhánh trong biên mà `_nearest_walkable` trả (-1,-1) cũng toast.
3. **Nhãn debug che tiêu đề điện thoại** (live 14:55: nhãn (24,200) đè panel điện thoại y=216).
   Sửa (`main.gd`): `_process` + `set_debug_labels_visible` đặt `_dbg_label.visible = ... and not phone_open and not battle_open` (sửa ở `_process` vì nó đặt lại visible mỗi frame — sửa trong `_open_phone` sẽ bị ghi đè).
4. **Nhãn NPC Map002 nổi cao trên trời** (live 14:55: "Anh Hải"/"Chị Lệ" cách NPC ~70–200px).
   Gốc đo bằng probe headless (`/tmp/pxb_r14_label_probe*.gd`, đã xóa sau khi dùng):
   - `Anh Hải` drift **-100px** (want 706 → 606), khe trên đầu **197px**; `Chị Lệ` drift 0, khe 47px.
   - Chuỗi gây drift: (a) `NPC_PARITY_OFFSET = 40` (marker.gd) đẩy nhãn NPC ô lẻ lên thêm 50px màn hình (Anh Hải (6,3) lẻ, Chị Lệ (2,2) chẵn) — want_y hai nhãn chỉ cách nhau 50px; (b) `_nearest_free_y` tính vật cản khi chồng X chỉ **1px** (mép nhãn Anh Hải chạm mép vật cản sprite Chị Lệ đúng 1px) → cắt hết khoảng dọc gần neo, best_y rơi về 606.
   Sửa: **bỏ hẳn `NPC_PARITY_OFFSET`** (tách nhãn NPC kề nhau nay là việc của resolver, không cần lệch sẵn — cặp "Bạn Thân"/"Cô Tư" đều chẵn nên lệch này vốn không tách được chúng); **`_nearest_free_y` chỉ tính vật cản khi chồng X ≥ 10px** (cả obstacles lẫn placed — chồng < 10px thì bỏ qua).
   Sau sửa (probe lại): Anh Hải drift **0**, khe trên đầu **47px** = Chị Lệ; Map001 không đổi (Cô Tư/Bạn Thân drift 0, khe 47px). Còn drift cũ không sửa vòng này: "Góc Chế Tạo" Map001 -132px (main pass, kẹt giữa vật cản người chơi + nhãn Bạn Thân + icon — nhãn vẫn đọc được, không bay lên trời, để nguyên).

### 35.2 Không tái hiện: nền mờ sau điện thoại ở Chợ (live 14:55 mục d)

- Kiểm bằng ảnh thật (r14-05, xem §35.4): mở điện thoại ở Chợ, nền mờ sau panel là **cảnh Chợ hiện tại** (sạp + nhãn "Cửa đi Khu Công Nhân" dưới panel), không có "CA PHE" nào. Code cũng cho thấy `_phone_dim` chỉ là ColorRect đen 0.55 phủ lên map hiện tại; "CA PHE" chỉ tồn tại trong `bg_map001.png`/`title_bg.png` (Map001/title, đã ẩn khi chơi). Kết luận: mục (d) là đọc nhầm của checker (có thể là panel 2 bên desktop hiện tranh title) — không có lỗi để sửa, không bịa fix.

### 35.3 Test mới + hồi quy

- `tests/g4_r14_tap_test.gd`: **15/15 PASS** — spawn (4,5); chạm (200,750)/(500,700) đăng ký đích + ghi "chạm (x,y)" + đích đi được; BFS (4,5)→(1,5) đúng 5 bước, không qua (3,5)/(5,4), tới đích + xóa auto-target, không chuyển map giữa chừng; mở điện thoại → nhãn debug ẩn, đóng → hiện lại.
  - Bài học test: `tile` được đặt ngay khi bắt đầu tween nên kiểm "tới đích" ngay thì thiếu 1 bước `moved_to` + auto-target chưa xóa — phải chờ 3 frame sau khi hết tween mới assert.
- Hồi quy đầy đủ: **43 OK, 0 FAIL** (42 cũ + 1 mới; `run_regression.sh` thêm `g4_r14_tap_test`).
- `--check-only` exit 0 (main.gd, player.gd, marker.gd, test mới — chạy sau `--import` để tránh cache class cũ, bài học §8.3); scene Main 120 frame exit 0, 0 ERROR/warning.
- Export web exit 0: pck **6.950.036 byte, SHA `9d9896a9…`** (trước `d691d82e…`), wasm không đổi `fc74679e…`; HTTP 200 đủ 2 file (cổng 8166).

### 35.4 Browser-verify thật (Chromium 1255 + swiftshader, 720×1280, build 9d9896a9)

- Script mới `visual-check/artpass14/check_r14.py` (tái chạy được).
- **Lỗi verify lần 1:** click nút bắt đầu sai tọa độ — script dùng fallback (360,740) của bản staging có DOM overlay, nhưng build thô `src/godot-build` không có `web_shell.html` nên nút "Bắt đầu chơi" là Button trong canvas ở ~(360,1060); click (360,740) trúng panel trên nút, game mãi ở title, 6 ảnh byte-identical. Sửa script click (360,1060) rồi chạy lại. Bài học: **verify build thô ≠ verify staging — nút bắt đầu khác vị trí; ảnh byte-identical liên tiếp = game chưa vào, không phải kết quả.**
- **Lần 2 — PASS, đã xem ảnh thật, 0 console error, 0 pageerror, 0 request fail:**
  - Tap (200,750): nhãn debug `Ô (2,4) • chạm (1,1) / A:(1, 1)` — đăng ký đích ngay; 4s sau `Ô (1,1) • chạm (1,1) / A:(-1, -1)` — đã đi tới (1,1) và xóa đích. (r14-02/03)
  - Map002 lúc vào: "Chị Lệ" + "Anh Hải" nằm sát trên đầu NPC (khe ~47px), không còn chồng thành cột ở vùng trời như ảnh 60-m2-arrival. (r14-04)
  - Mở điện thoại ở Chợ: tiêu đề "Điện thoại — Danh bạ / Tin nhắn" đọc đủ, **không còn nhãn debug đè lên**; nền mờ là cảnh Chợ. Đóng điện thoại: nhãn debug hiện lại. (r14-05/06)
- Còn lại (không sửa vòng này): sạp chợ Map002 vẫn là khối hộp be nhỏ/thô (chờ hướng art Claude — xem §35.6); nhãn "Cửa đi Khu Công Nhân" ở sát đáy bị toast đè nhẹ (đã biết từ trước).

### 35.5 Việc tiếp theo

1. **Claude đã trả lời về đồ họa** (dòng Notion `41f4047a-8982-81ff-ac73-d293ef69307e`, xem §35.6) — Center ĐÃ NHẬN + ETA đã ghi trên dòng lúc 15:45 (trước vòng này). Việc nhanh (b) hạn trước 21:00 21/11: Default Texture Filter = Linear Mipmap + bật mipmaps khi import, thu nhỏ sẵn ảnh nhân vật về 208px, chuyển nhãn NPC sang Label trong thế giới; gửi ảnh trước/sau chụp trên điện thoại thật. Làm ở vòng sau ngay sau khi deploy vòng 14 xong.
2. Dựng lại Map001 (hạn 12:00 22/11), nhân vật 6 khung (20:00 22/11), ánh sáng + sự sống (23/11) — theo ETA đã ghi trên dòng.
3. Sạp chợ Map002 (khối be thô) — làm khi tới lượt art Map002, sau khi Map001 theo hướng Claude xong.

### 35.6 Claude trả lời — đã nhận (21/11 ~15:45, dòng 41f4047a-8982-81ff-ac73-d293ef69307e)

- Chủ (qua trợ lý Claude) đã chuyển trả lời cho câu hỏi đồ họa Center gửi sáng 21/11. Toàn văn đã đọc tươi (fetch 16:00): chẩn đoán 4 điểm gốc — (1) ảnh nền AI trộn với nhà vẽ bằng code trong `nadia_scene.gd` → hai phong cách đánh nhau; (2) nhân vật 512px thu còn 104px không mipmap → răng cưa, chỉ 1 khung; (3) map iso 12×9 chỉ phủ ~1/3 màn dọc, trời trống; (4) nhãn NPC trên CanvasLayer nên lơ lửng.
- 3 việc theo thứ tự (chi tiết + tên node trong trang chẩn đoán `41f4047a-8982-81fe-9924-e3926327667b`): (1) Dựng lại Map001: blockout Blender (camera ortho X=60°, Z=45°) → AI vẽ đè → 4 lớp Ground/YSort/Foreground/LightsLayer, phủ kín 9:16 bằng nhà ống cao + tiền cảnh, tắt hẳn vẽ nhà bằng code; (2) Nhân vật 6 khung (trước/sau-3/4 × 3 khung, lật ngang), ảnh 2× cỡ hiển thị, Linear Mipmap, nhãn là Label con của nhân vật, chỉ hiện khi ở gần; (3) Ánh sáng: nền đêm nướng sẵn + sprite phát sáng cộng dồn + CanvasModulate chiều + 3–5 chuyển động nhỏ (hơi nồi phở, biển đung đưa, lá rơi).
- Center ĐÃ NHẬN + ETA đã ghi trên dòng lúc 15:45 (do main agent ghi — vòng 14 này chạy sau đó): Center tự làm (không giao Muse Editor — bạn ấy giữ giám sát 30 phút + Bộ hiệu ứng hạn 18:00). ETA: (b) việc nhanh trước 21:00 21/11; (1) Map001 trước 12:00 22/11; (2) 6 khung trước 20:00 22/11; (3) ánh sáng 23/11. Làm trọn Map001 trước, không trải nhiều map; mỗi việc xong gửi ảnh điện thoại duyệt; xếp lịch không trễ slot 1Min/Ủa và vòng thử (PV-07).
- LƯU Ý cho vòng sau: việc (b) "chuyển nhãn NPC sang Label trong thế giới" CHỒNG với fix D vòng 14 (vòng 14 giữ CanvasLayer nhưng sửa drift) — (b) là đổi hẳn kiến trúc nhãn (Label con của Marker trong thế giới + chỉ hiện khi ở gần), phải làm riêng sau khi deploy vòng 14, không gộp chung để tránh phá bộ resolver/artpass tests đang PASS.

### 35.7 Deploy `9d9896a9` lên gh-pages — XONG (21/11 ~16:20–16:35 +07)

- Đối chiếu trước deploy: `versions.json` remote pin đúng pck `d691d82e` tại head `8c1e7d3e` (= deploy vòng 13); `pck/9d9896a9/` chưa tồn tại remote — nối tiếp sạch, không divergence.
- Rebuild staging `tools/godot/build_gh_pages.py`: VERIFY OK, 52 chunk pck, wasm `fc74679e` không đổi, img không đổi.
- Deploy 5 lô: `b4077061` (chunk 000–016), `6ca40d07` (017–033), `d87ca6b3` (034–051), `157cd0e6` (`versions.json`), `c42d44ab` (`index.html` CUỐI — head gh-pages).
- Verify khớp byte từ live: ráp 52 chunk từ `raw.githubusercontent.com` = 6.950.036 byte, SHA `9d9896a97b987031` ✓; `index.html` live SHA `de8c6d44ab176d02` = staging ✓; `versions.json` qua API tại head `c42d44ab` pin `9d9896a9` ✓.
- Lưu ý CDN (đã biết, §19.8): `versions.json` qua `tinnt120899.github.io` vẫn hiện `d691d82e` ngay sau deploy — Pages CDN cache, repo qua API đã đúng; tải lại sau vài phút sẽ khớp. Không kết luận deploy sai vì curl ngay sau push.
- Link live: https://tinnt120899.github.io/pho-xo-bo/ (Pages rebuild vài phút sau push).

## 36. Vòng 14b — Claude (b) phần nhanh: Linear Mipmap + thu nhỏ nhân vật 208px (21/11 ~16:35–17:00 +07)

### 36.1 Việc làm (2/3 mục nhanh (b) — hạn trước 21:00 21/11)

1. **Default Texture Filter = Linear Mipmap** (`project.godot` [rendering]): thêm `textures/canvas_textures/default_texture_filter=3` (0 Nearest, 1 Linear, 2 Nearest Mipmap, 3 Linear Mipmap). Trước đó không có setting này (mặc định Linear, không mipmap).
2. **Bật mipmaps khi import** cho 5 ảnh nhân vật: `art/char_*.png.import` `mipmaps/generate=false` → `true` (chỉ 5 file này; ảnh nền/sky hiển thị ~1:1 nên không cần).
3. **Thu nhỏ sẵn ảnh nhân vật 512px → 208px** (2× cỡ hiển thị 104px): PIL LANCZOS, giữ alpha. `char_player` 260×512→106×208, `char_cotu` 275→112, `char_banthan` 330→134, `char_chile` 233→95, `char_anhhai` 213→87 (đều cao 208). Gốc 512px lưu ở `visual-check/artpass14/orig-512/`.
   - An toàn vì `character_sprite.gd` tính scale theo `TEX_HEIGHT / texture.get_height()` (không hardcode 512) — hiển thị vẫn đúng 104px.
   - `.ctex` sau re-import: player 141.858→50.758 byte, banthan 167.334→57.836 byte; tên file `.ctex` không đổi (hash theo params, không theo nội dung ảnh).
4. **Chưa làm — nhãn NPC sang Label trong thế giới** (mục (b) thứ 3): là đổi hẳn kiến trúc nhãn (Label con của Marker + chỉ hiện khi ở gần), chồng với fix drift vòng 14 nhưng khác hẳn cách làm; làm riêng ở vòng sau, không gộp vào deploy này để khỏi phá bộ resolver/tests đang PASS. Ghi chú cho vòng sau: phải sửa `marker.gd` + `_resolve_label_overlaps` + các artpass test assert `label_screen_rect()`.

### 36.2 Lỗi export — bài học

- Export lần 1 dùng output `../godot-build/index.pck` → pck chỉ **18.146 byte, bắt đầu bằng `<!DOCTYPE html>`**: Godot 4.7.2 viết shell HTML vào đúng đường dẫn được đưa, không phải pck game. **LUẬT: luôn export bằng đường dẫn của preset (`../godot-build/index.html`), không bao giờ đưa đường dẫn `.pck`.**
- Export lại đúng cách: exit 0, pck **6.473.700 byte, SHA `cf88493c…`** (nhỏ hơn 6.950.036 của vòng 14 — đúng vì ảnh nhân vật đã thu nhỏ), wasm không đổi `fc74679e…`, HTTP 200 đủ 2 file.

### 36.3 Verify

- `--check-only` (character_sprite.gd, marker.gd) exit 0; hồi quy đầy đủ **43 OK, 0 FAIL**.
- Browser-verify script mới `visual-check/artpass14/check_r14b.py` (bản đổi tên output của check_r14.py): **0 console error, 0 pageerror, 0 request fail**; game vào được, tap/chạm/điện thoại vẫn chạy như vòng 14.
- Xem ảnh thật: Map001 (r14b-01) + Map002 (r14b-04) — sprite người chơi/Bạn Thân/Cô Tư/Anh Hải/Chị Lệ hiển thị đúng cỡ 104px, không méo/vỡ; nhãn "Anh Hải"/"Chị Lệ" vẫn sát trên đầu NPC (giữ được fix vòng 14). Còn tồn tại từ trước: nhãn "Sạp rau buổi sáng" hơi đè "Anh Hải", "Góc phế liệu chợ" bị cắt ở mép phải — thuộc layout nhãn, không phải do resize.
- **Giới hạn ảnh trước/sau:** ACK trên dòng đã hẹn "ảnh trước/sau chụp trên điện thoại thật" — VM không có điện thoại thật; ảnh trước/sau ở đây là screenshot Chromium 720×1280 (r14-*.png vs r14b-*.png). Chủ xem trên điện thoại của mình để duyệt cuối.

### 36.4 Lưu ý đồng bộ art

- 5 PNG đã resize chỉ sống ở **bản local + trong pck** (snapshot-push chỉ nhận file text) — giống mọi art PNG từ trước. File `.import` (text, đã push) thì tương thích cả 2 cỡ ảnh; nhưng **art trên repo main vẫn là bản 512px cũ** — clone mới về sẽ thấy ảnh 512px cho tới khi có cơ chế đẩy art nhị phân. Ghi rõ để vòng sau không tưởng repo đã có ảnh 208px.
- Ảnh title `char_player.png`/`char_banthan.png` trong `src/godot-build/` cũng đã copy bản 208px mới (45.086 / 53.272 byte) để deploy staging chunk lại với version mới.

### 36.5 Deploy `cf88493c` lên gh-pages — XONG (21/11 ~17:05–17:20 +07)

- Đối chiếu trước deploy: `versions.json` remote pin pck `9d9896a9` tại head `c42d44ab` (= deploy vòng 14); `pck/cf88493c/` chưa tồn tại remote — nối tiếp sạch.
- Rebuild staging `tools/godot/build_gh_pages.py`: VERIFY OK; pck 48 chunk; img char_player `9639c122`→`5dc7da77`, char_banthan `4750238d`→`a4c96723` (ảnh 208px mới), title_bg không đổi.
- Deploy 6 lô: `64752ee7` (chunk 000–016), `99340298` (017–033), `3d64de91` (034–047), `9b051eee` (img char 2 file), `061d9861` (`versions.json`), `3c7063e6` (`index.html` CUỐI — head gh-pages).
- Verify khớp byte từ live: ráp 48 chunk = 6.473.700 byte, SHA `cf88493c56f6edd6` ✓; img chunk char_player 45.086 byte + char_banthan 53.272 byte, đúng magic PNG ✓; `index.html` live SHA `069ae1886a2f5188` = staging ✓; `versions.json` qua API tại head `3c7063e6` pin `cf88493c` + img mới ✓.
- Link live: https://tinnt120899.github.io/pho-xo-bo/ (Pages rebuild vài phút sau push).


## 37. Vòng 15 — Nhãn NPC sang Label trong thế giới (21/11 ~16:50–17:30 +07)

Mục (b) thứ 3 của Claude (xem §35.6) — hạn trước 21:00 21/11. 2/3 mục
nhanh đã xong ở vòng 14b (Linear Mipmap + ảnh 208px); mục này làm riêng
sau khi deploy vòng 14b, không gộp chung (đúng lưu ý §35.6).

### 37.1 Việc làm

- **Nhãn NPC thành Label con của Marker** (`scripts/marker.gd`):
  `_make_world_label()` — Label con trực tiếp của Marker (Node2D),
  dùng rect neo thô `_anchor_rect()` (NPC: trên -170, cao 32 world),
  font 20 world, `z_index = 10` (trên ảnh nền/mặt tiền — cùng kỹ
  thuật SkyEffects/NightGlow dùng để thoát y-sort của IsoMap),
  `mouse_filter = IGNORE`. Nhãn hotspot/che tao/cua KHÔNG đổi —
  vẫn Label trên CanvasLayer layer 1 (resolver vẫn dịch được).
- **Chỉ hiện khi ở gần** (`main.gd` `_update_npc_labels()`, chạy
  mỗi frame trước resolver): Manhattan từ ô người chơi tới ô NPC
  ≤ `Marker.LABEL_NEAR_TILES = 5`. Ngưỡng 5 giữ cả 2 NPC hiện lúc
  spawn Map001 (Bạn Thân 1 ô, Cô Tư đúng 5 ô) + Map002 (Chị Lệ 5 ô,
  Anh Hải 2 ô) — ảnh spawn không đổi; xa hơn thì ẩn.
  Marker giữ `_label_near` (mặc định true để marker đứng lẻ không
  có Main vẫn hiện như cũ) + `_npc_label_should_show()` (gần +
  neo trong màn hình) dùng chung cho `_update_label()` và
  `label_screen_rect()` để 2 chỗ không lệch nhau 1 frame.
- **Resolver bỏ qua NPC** (`main.gd` `_resolve_label_overlaps()`):
  không đặt `label_override` cho NPC nữa (dịch là rời neo); rect
  màn hình của nhãn NPC ghi sẵn vào `placed` để nhãn hotspot/cửa/
  chế tạo tránh. Obstacle sprite NPC vẫn giữ nguyên.
- **`label_screen_rect()` cho NPC** nay là rect màn hình thật của
  Label con (canvas transform × vị trí local), rỗng khi nhãn ẩn.
  `_anchor_rect()` tách ra từ `label_rect()` (phần kep camera giữ
  nguyên cho nhãn CanvasLayer).
- **Test cũ cập nhật** (`g4_artpass4_test.gd`, `g4_artpass5_test.gd`):
  lấy rect hiển thị thật = override-nếu-có-không-thì-screen-rect
  (như polish test) để nhãn NPC vẫn được kiểm chồng/đè đầu.
  `artpass_test.gd` (state 3), `g4_artpass3_test.gd`,
  `g4_polish_test.gd` đã dùng screen-rect nên không cần sửa;
  `artpass12_test.gd` chỉ kiểm override (nhãn cửa) nên giữ nguyên.

### 37.2 Lỗi tìm ra khi làm: Label tự tăng lên minimum size

- Test mới rớt 8/63 lần đầu: tâm nhãn lệch +2 world khỏi chân NPC,
  `size` thành (chu+20, 32) thay vì (chu+16, 26) đã đặt. Nguyên nhân:
  Label có StyleBoxFlat (content margin 10+10 ngang, 4+4 dọc) nên
  minimum size = (chu+20, font-cao 24+8=32) — Control tự tăng lên
  minimum size khi vào tree, chỉ giữ nguyên `position`.
- Sửa: `_anchor_rect()` cho NPC trả đúng minimum size
  (`size.x + 20`, `font.get_height(20) + 8`, tâm x = `-w/2` thay vì
  `-w/2 - 8`). Khe trên đầu NPC còn ~42px màn hình (trước ~50px).
- Probe `/tmp/pxb_r15_probe.gd` (đã xóa sau khi dùng) đo thật:
  Cô Tư pos (-37,-170) size (78,32), anchor (74,26);
  Bạn Thân size (115,32), anchor (111,26); font_h=24.

### 37.3 Test mới + hồi quy

- `tests/g4_r15_label_world_test.gd`: **63/63 PASS** — nhãn NPC
  là con của Marker, không trên CanvasLayer, z 10, font 20, đúng
  rect neo, không override; spawn Map001/Map002 cả 2 NPC hiện,
  tâm X trùng chân NPC, khe trên đầu 40–60px; xa 11 ô / 8 ô thì
  nhãn ẩn + rect rỗng; nhãn hotspot/chế tạo/cửa vẫn CanvasLayer;
  nhãn các map không chồng nhau.
- Hồi quy đầy đủ: **44 OK, 0 FAIL** (43 cũ + 1 mới;
  `run_regression.sh` thêm `g4_r15_label_world_test`).
- `--check-only` exit 0 (marker.gd, main.gd sau `--import`);
  scene Main 120 frame exit 0, 0 ERROR/warning.
- Export web exit 0 (đúng đường dẫn preset `../godot-build/index.html`,
  bài học §36.2): pck **6.481.136 byte, SHA `b6913210…`**
  (trước `cf88493c…` 6.473.700 — tăng nhẹ do code mới),
  wasm không đổi `fc74679e…`, `GODOT_THREADS_ENABLED = false`;
  HTTP 200 đủ 4 file (cổng 8167).

### 37.4 Browser-verify thật (Chromium 1255 + swiftshader, 720×1280, build b6913210)

- Script mới `visual-check/artpass15/check_r15.py` (tái chạy được).
- **0 console error, 0 pageerror, 0 request fail.**
- Đã xem ảnh thật: Map001 spawn (r15-01) — "Bạn Thân" sát trên đầu
  2 nhân vật, "Cô Tư" sát trên đầu Cô Tư, không chồng nhãn khác;
  Map002 (r15-03) — "Chị Lệ"/"Anh Hải" sát trên đầu NPC, vị trí
  nhãn y hệt bản vòng 14 (r14-04) — không hồi quy.
- **"Sạp rau buổi sáng" hơi chạm đỉnh đầu người chơi lúc vào Chợ:**
  đã đối chiếu ảnh vòng 14 (r14-04) — Y HỆT, có từ trước (luật
  vòng 12: giữ y muốn thay vì bay xa khi khe gần nhất quá xa),
  không phải hồi quy của vòng này.
- **Flake harness (không phải lỗi game):** lần chạy check_r15.py
  đầu + probe1 click (500,850)/(200,750)/(480,879) đều không đăng
  ký (đứng yên ở (4,5), A:(-1,-1)) — nhưng chạy lại Y HỆT bằng
  script r14b (`check_r14b.py` đổi cổng 8167) thì tap (200,750)
  đăng ký ngay + đi tới (1,1); probe2/probe3 (cùng cấu trúc r14b)
  cũng đi được, KỂ CẢ click đúng giữa nhãn "Cô Tư" (480,879) →
  đăng ký (3,1) + tới (3,1). Headless probe cũng xác nhận logic
  tap đúng ((500,850) → auto-target (3,1)). Kết luận: 2 lần chạy
  đầu bị mất click do harness (lần đầu chạy trên build mới export,
  giống các flake swiftshader đã biết: phím nhấn nhanh bị miss),
  không phải nhãn nuốt click (`mouse_filter = IGNORE` có tác dụng).
  Bài học: click không đăng ký ở lần chạy đầu thì CHẠY LẠI y hệt
  trước khi kết luận game hỏng.

### 37.5 Việc tiếp theo

1. **Deploy gh-pages bản `b6913210`** (staging rebuild + push batch,
   kiểm tra head gh-pages trước mỗi lô — xem §37.6).
2. Dựng lại Map001 theo hướng Claude (hạn 12:00 22/11), nhân vật
   6 khung (20:00 22/11), ánh sáng + sự sống (23/11) — theo ETA
   §35.6. Việc (b) đã đủ 3/3 trước hạn 21:00 21/11.
3. Sạp chợ Map002 (khối be thô) — làm khi tới lượt art Map002.

### 37.6 Deploy `b6913210` lên gh-pages — XONG 21/11 ~17:40 +07

- Staging rebuild `build_gh_pages.py`: VERIFY OK; versions.json pin
  pck `b6913210`, wasm `fc74679e` không đổi, img không đổi.
- Kiểm tra tiền-push: remote gh-pages `versions.json` pin `cf88493c`
  ở head `3c7063e6` (đúng trạng thái vòng 14b) — NHƯNG sync record
  thiếu hẳn entry deploy gh-pages vòng 14 (9d9896a9) + 14b
  (cf88493c); entry gh-pages mới nhất trong record vẫn là vòng 13
  (80da1a51). Đối chiếu diff: index.html remote ↔ staging chỉ khác
  version pck + số chunk (48→49) + fileSizes pck (6473700→6481136)
  — không có writer khác chen vào. Lấy head đã verify `3c7063e6`
  làm base; các lô deploy vòng này ghi record đầy đủ trở lại.
- Push gh-pages 5 lô (mỗi lô ghi sync record ngay sau khi xong):
  chunk 1/3 `ee628999` (part-000..019), 2/3 `66614a85`
  (part-020..039), 3/3 `97ee0af1` (part-040..048),
  versions.json `4fcd9816`, index.html CUỐI `eeb3347c`.
  Spot-check 3 chunk (000/024/048) blob SHA remote = local.
- Verify live (curl): versions.json pin `b6913210`; index.html live
  trỏ pck/b6913210, fileSizes 6481136; tải đủ 49 chunk từ live,
  ráp lại = 6.481.136 byte, SHA256 `b6913210…` KHỚP TỪNG BYTE với
  pck local. Link live: https://tinnt120899.github.io/pho-xo-bo/
- **Hạn chế lần này:** smoke browser trên URL live KHÔNG chạy được
  từ VM này — Chromium báo `ERR_TUNNEL_CONNECTION_FAILED` (2 lần),
  trong khi curl cùng máy trả 200. Đây là lỗi đường mạng/proxy của
  Chromium trong sandbox, không phải lỗi site. Game đã browser-verify
  trên bản local CÙNG TỪNG BYTE pck + live đã khớp byte — nhưng theo
  luật "kiểm live bằng cloud browser" thì phần này còn thiếu; vòng
  sau thử lại live browser khi tunnel ổn.
- Lưu ý push: lần push main đầu bị service restart cắt giữa chừng
  (chưa lên, check head vẫn `7b21c4dd` rồi push lại mới xong);
  lần push versions.json cũng bị restart cắt (chưa lên, check lại
  rồi push lại). `/tmp` bị xóa sau mỗi restart — manifest phải tạo
  lại. Và: file `docs/godot-g4.md` 226.162 byte vẫn push qua
  snapshot-push được (giới hạn thật là 16 MiB tổng, không phải
  188.416 byte/file như MEMORY.md đang ghi — con số đó là cỡ chunk
  base64 của build_gh_pages, không phải giới hạn push).

## 38. Vòng 16 — Map001 dựng lại bước 1: ảnh nhà ống cao phủ kín 9:16 (22/11 ~00:30–01:00 +07)

Mục (1) của Claude (§35.6), hạn 12:00 22/11 — làm bước 1 (nền mới),
chưa phải blockout Blender đầy đủ (VM không có Blender).

### 38.1 Việc làm

- **Ảnh mới** (`src/godot/art/bg_map001_tall.png` 864×1536 + bản đêm
  `bg_map001_tall_night.png`): gen bằng media image generation
  (prompt: 3 nhà ống cao 4 tầng, tường vàng cũ, mái ngói, ban công
  cây, biển PHO BO / CA PHE / TAP HOA, đèn lồng đỏ, vỉa hè — đúng
  phong cách vẽ tay Nadia), xử lý bằng PIL
  (`tools/godot/make_map001_tall.py`, tái chạy được): gốc 1152×2048
  thu về 864×1536 (camera chỉ thấy ~576 đơn vị thế giới ngang nên
  vẫn >1,3× oversampling; tránh pck phồng thêm ~5MB), bản đêm suy
  ra từ bản ngày (tối + lạnh toàn cục, giữ 381.184 pixel ấm sáng
  cửa sổ/đèn lồng; mean ngày 91,5 → đêm 51,9). Bản gốc webp giữ ở
  `visual-check/artpass16/bg-map001-tall-source.webp`.
- **Code** (`scripts/iso_map.gd`): Map001 ưu tiên ảnh cao khi có
  (`has_tall_bg` mới); đáy ảnh neo ở offset.y+20 như ảnh cũ, đỉnh
  lên tới offset.y-1516 — phủ kín cả tầm nhìn khi đi lên hàng trên
  (camera thấy tới offset.y-777); **không vẽ dải trời sky_wide cho
  Map001 nữa** (sẽ đè lên tầng trên của ảnh cao); ảnh composite cũ
  giữ làm fallback khi thiếu ảnh cao. `set_frame` đổi ngày/đêm dùng
  chung `_bg_day_tex`/`_bg_night_tex` nên không cần sửa. Wash sáng
  mặt tiền `_draw_facade_light` giữ nguyên (nay phủ đúng dải mặt
  tiền tầng trệt của ảnh cao, alpha ≤0,14).
- **Test mới** `tests/g4_r16_map001_rebuild_test.gd`: **16/16 PASS**
  — ảnh tồn tại + đúng 864×1536, đêm tối hơn ngày (tỉ lệ 0,57),
  Map001 `has_tall_bg`, đáy neo offset.y+20, đỉnh vượt tầm nhìn
  hàng trên, không sky_wide, đổi khung Toi/Sáng đổi đúng ảnh,
  Map002 không đổi (sky_band + sky_wide).
- **Test cũ cập nhật** (tiền lệ §12.3 — test lỗi thời so với thay
  đổi có chủ ý, sửa test không sửa code): `g4_artpass3_test`
  (3 check tên ảnh nền ngày/đêm → ảnh cao) + `g4_polish_test`
  (Map001 bg composite + có sky_wide → bg ảnh cao + không sky_wide).

### 38.2 Verify vòng này

- Hồi quy đầy đủ: **45 OK, 0 FAIL** (44 cũ + 1 mới; lần chạy đầu
  43 OK + 2 FAIL đúng 2 test cũ trên — đã cập nhật, chạy lại đủ).
- Smoke `--headless --quit-after 120` exit 0, 0 ERROR.
- Export web exit 0: pck **10.028.440 byte, SHA `34bd6889…`**
  (trước 6.481.136 — tăng ~3,5MB do 2 ảnh cao; wasm không đổi
  `fc74679e…`); HTTP 200 đủ 4 file (cổng 8171).
- **Browser-verify thật** (Chromium 1255 + swiftshader, 720×1280,
  script `visual-check/artpass16/check_r16.py` +
  `check_r16_m2.py`, ảnh `r16-01…r16-05`): **0 console error,
  0 pageerror, 0 request fail.**
  - Spawn Map001: nhà ống cao 4 tầng phủ kín khung dọc, biển
    PHO BO / CA PHE / TAP HOA đọc được, không còn dải trời trống.
  - Đi lên 4 ô tới (4,1): mặt tiền vẫn kín khung, không hở trời.
  - F ×2 → Tối: ảnh đêm (tối xanh, trăng + sao, cửa sổ ấm còn
    sáng), nhãn "Hẻm trọ buổi tối" đổi đúng, toast "Ngày 1 •
    Khung Tối".
  - Vào Map002 bằng cửa (5,4): đúng Chợ Đầu Mối + toast "Đã sang
    Chợ Đầu Mối", sky_band + sky_wide như cũ — không hồi quy.
- **Nit còn lại (không chặn, ghi cho vòng sau):**
  1. Sao đêm NightGlow vẫn vẽ ở dải cũ (world y −92..−12) nên
     rơi lên mái hiên/biển hiệu thay vì trời — nhìn như bụi sáng,
     nhỏ; dời dải sao lên khi làm ánh sáng 23/11.
  2. Mặt trời Sáng (neo màn hình) đè lên biển PHO BO lúc spawn —
     dời mặt trời sang phải hoặc xuống thấp hơn.
  3. Đất iso (ground_wide.jpg, ảnh chụp) vẫn khác phong cách với
     mặt tiền vẽ tay — đường nối vỉa hè/đất còn thấy; cần art đất
     riêng cho Map001 ở bước tiếp theo.
  4. Sạp Chợ Map002 vẫn khối be thô (đã biết, chờ art Map002).
- **Lưu ý đồng bộ art:** 2 PNG cao chỉ sống ở local + trong pck
  (snapshot-push chỉ nhận file text) — giống mọi art PNG từ trước;
  file `.import` (text) đã push thì tương thích cả 2 cỡ ảnh.
  Clone mới về sẽ fallback về ảnh composite cũ cho tới khi có cơ
  chế đẩy art nhị phân.

### 38.3 Deploy — XONG (22/11 ~01:00 +07)

- Push main — XONG, commit `a1f549e3` (12 file: iso_map.gd, test
  r16 mới + `.uid`, 2 test cập nhật, run_regression.sh,
  make_map001_tall.py mới, 2 `.import` mới, 2 script visual-check
  artpass16, docs §38). Đối chiếu trước push: head `3230d76e`
  khớp record; commit mới nhất chạm 5 file sửa đều đúng sync base
  (iso_map/artpass3 `d0b5cbd1`, polish `bb47c522`,
  run_regression `42dafc2a`, docs `3230d76e`); 7 file mới xác nhận
  ABSENT trên remote trước khi push.
- Deploy gh-pages — XONG, 6 lô: `25e7ab71` (pck 000–022),
  `422d7708` (023–045), `4ee21f4a` (046–068), `5e1d0ca3`
  (069–074), `27133ed1` (versions.json), `a349ec32` (index.html
  CUỐI — head gh-pages). Staging rebuild `build_gh_pages.py`
  VERIFY OK; pck `34bd6889` (75 chunk), wasm `fc74679e` không đổi.
  Spot-check 3 chunk (000/037/074) blob SHA remote = local trước
  khi đẩy index.html.
- Verify khớp byte từ live: ráp 75 chunk từ
  `raw.githubusercontent.com` = 10.028.440 byte, SHA
  `34bd6889b567dad8` ✓; `versions.json` live pin `34bd6889`;
  `index.html` live SHA `102bf8dbff863da7` = staging ✓.
- Link live: https://tinnt120899.github.io/pho-xo-bo/ (Pages rebuild
  vài phút sau push).

### 38.4 Việc tiếp theo

1. Map001 bước 2: art đất riêng (khớp mặt tiền vẽ tay) + dời dải
   sao/mặt trời (nit 1–3 trên). — **XONG vong 17, xem §39.**
2. Nhân vật 6 khung (hạn 20:00 22/11, cần nguồn gen ảnh AI) +
   ánh sáng + sự sống (23/11) — theo ETA §35.6.
3. Sạp chợ Map002 (khối be thô) — làm khi tới lượt art Map002.

## 39. Vòng 17 — Map001 bước 2: sao/mặt trời neo camera + đất vẽ tay (22/11 ~01:00–01:45 +07)

Nit 1–3 của §38.2, làm xong cả 3 trong 1 vòng (2 luồng song song:
luồng này code + verify + deploy; luồng kia gen art đất).

### 39.1 Vấn đề gốc (đo bằng mắt trên ảnh r16)

- Ảnh nhà ống cao **không có vùng trời thật nào trong tầm nhìn**:
  camera (zoom 1.25, look-up −265) lúc spawn thấy tới world y −315,
  lúc lên hàng trên tới −379; ảnh cao kéo tới −1214 nhưng phần trên
  không bao giờ vào khung. Nửa trên màn hình lúc nào cũng là mặt tiền.
- Sao đêm cũ neo theo map (`sky_top.y+200..280` = world y −108..−28)
  rơi lên mái hiên/biển hiệu — nhìn như bụi sáng trên mái hiên
  (ảnh r16-03). Mặt trời Sáng neo màn hình (170,240) đè lên mái hiên
  trái + biển PHO BO lúc spawn (ảnh r16-01).
- Đất `ground_wide.jpg` là ảnh chụp thật — lệch phong cách với mặt
  tiền vẽ tay, đường nối vỉa hè/đất còn thấy (ảnh r16-01).

### 39.2 Việc làm

- **Sao đêm neo camera** (`scripts/night_glow.gd`): bỏ hẳn dải sao
  theo `sky_top`; sao vẽ ở dải màn hình cố định y **208..262**
  (dưới HUD ~200, trên mái hiên ~280), x 24..696 — cùng thủ thuật
  như trăng neo camera (400,240) của SkyEffects: "sao trên mái nhà"
  đọc được như trời đêm. Giữ nguyên số lượng (64 khi `sky_in_image`,
  36 khi không), cỡ, màu HDR. Thêm `_cam_anchor()` (như SkyEffects)
  + `_process()` vẽ lại khi camera đổi chỗ (chỉ khi `lit`); biến
  `star_screen_top/bottom` để test đọc. Trăng Map003+ vẫn vẽ theo
  map ở `sky_top+(560,250)` (trùng vị trí trăng neo camera lúc
  spawn nên chỉ thấy 1 trăng — không động vào). `set_sky` giữ lại
  cho trăng.
- **Mặt trời Sáng sang phải** (`scripts/sky_effects.gd`):
  (170,240) → **(560,240)**. Bên phải, trên biển TAP HOA (~y 390
  trở xuống), chỉ có tường tầng trên — mặt trời nằm "trên mái nhà"
  như trăng. Chiều (330,240) + trăng (400,240) không đổi.
- **Đất vẽ tay Map001** (`src/godot/art/ground_map001.png`,
  1440×900, ~2,4 MB — luồng song song gen bằng media image
  generation, prompt + xử lý PIL ghi ở
  `visual-check/artpass17/ground_map001-note.md`): watercolor/
  gouache, dải vỉa hè đá cũ ~18% trên cùng, dưới là đất hẻm nứt +
  lá vàng + rêu + vũng nước. Nối vào game (`main.gd`):
  `_ground_sprite` + `_update_ground(map_id)` gọi trong `load_map`
  — Map001 dùng `ground_map001.png`, map khác về `ground_wide.jpg`;
  cả 2 ảnh cùng 1440×900 nên scale giữ nguyên; thiếu file (clone
  mới chưa có art nhị phân) thì fallback ảnh cũ.
- **Test cập nhật theo tiền lệ §12.3** (test lỗi thời so với thay
  đổi có chủ ý): `v6_overlay_test` check mặt trời (170,240) →
  (560,240); `g4_artpass3_test` check ground sprite chấp nhận cả 2
  tên file.

### 39.3 Test mới + verify vòng này

- Test mới `tests/g4_r17_sky_test.gd`: **14/14 PASS** — mặt trời
  Sáng dưới HUD + sang phải (x>350, <550), Chiều giữ vị trí cũ,
  Tối sao đã vẽ + dải sao dưới HUD/trên mái hiên, trăng không đổi,
  Map001 đất vẽ tay, sang Map002 về đất cũ, về Map001 lại đất vẽ
  tay. (Lỗi test lần đầu: đọc `sun_pos` ngay sau `_advance_frame`
  trong cùng frame — `_draw` chưa chạy; đã sửa thành đọc ở frame
  sau, như artpass4.)
- Hồi quy đầy đủ: **46 OK, 0 FAIL** (45 cũ + 1 mới; lần chạy đầu
  45 OK + 1 FAIL đúng `v6_overlay_test` — test cũ đòi mặt trời
  (170,240), đã cập nhật, chạy lại đủ). Smoke `--headless
  --quit-after 120` exit 0, 0 ERROR.
- Export web exit 0: pck **11.692.520 byte, SHA `cddb9cd5…`**
  (trước `34bd6889…` — tăng ~1,66 MB do ảnh đất 2,4 MB);
  wasm không đổi `fc74679e…`; HTTP 200 đủ 4 file (cổng 8172).
- **Browser-verify thật** (Chromium 1255 + swiftshader, 720×1280,
  script `visual-check/artpass17/check_r17.py`, ảnh
  `r17-01…r17-03`): **0 console error, 0 pageerror,
  0 request fail.**
  - Spawn Sáng: mặt trời là đĩa vàng tròn + quầng mềm ở góc
    phải trên, không đè biển/mái hiên trái; biển PHO BO đọc đủ;
    đất vẽ tay (vỉa hè đá + đất nứt + lá vàng + vũng) khớp phong
    cách mặt tiền, đường nối vỉa hè/đất hết lộ.
  - F ×2 → Tối: sao nằm thành dải hẹp ngay dưới HUD/debug, không
    còn chấm trắng rải trên mái hiên/biển hiệu; trăng vẫn ở giữa
    trên; đất đêm tối đều, vẫn là tranh vẽ tay.
  - Về Sáng + sang Map002 bằng cửa (5,4): đúng Chợ Đầu Mối +
    toast "Đã sang Chợ Đầu Mối", đất về ảnh cũ (đúng thiết kế —
    chỉ Map001 có đất vẽ tay riêng); mặt trời trên trời thật của
    Map002. Không hồi quy.
- Nit còn lại (không chặn): dải sao hơi chạm hộp nhãn debug
  (nhãn debug tạm thời, mặc định hiện trong giai đoạn sửa di
  chuyển — hết debug là hết chạm); Map002 vẫn dùng đất ảnh chụp
  + sạp khối be (chờ art Map002).

### 39.4 Deploy — XONG (22/11 ~01:45 +07)

- Push main — XONG, commit `0654c7ac` (12 file: sky_effects,
  night_glow, main.gd, test r17 mới + `.uid`, 2 test cập nhật,
  run_regression.sh, 2 script/ghi chú artpass17, `.import` đất mới,
  docs §39). Đối chiếu trước push: head `39bf251f` khớp record;
  6 file sửa không divergence (remote-at-head vẫn nội dung cũ);
  5 file mới xác nhận ABSENT trên remote trước khi push.
- Deploy gh-pages — XONG, 6 lô: `8279590d` (pck 000–019),
  `1595cbd1` (020–039), `534920c4` (040–059), `e977b838`
  (060–079), `89a3f84a` (080–086 + versions.json), `5f641feb`
  (index.html CUỐI — head gh-pages). Staging rebuild
  `build_gh_pages.py` VERIFY OK; pck `cddb9cd5` (87 chunk),
  wasm `fc74679e` không đổi. Spot-check 3 chunk (000/043/086)
  blob SHA remote = local trước khi đẩy index.html.
- Verify khớp byte từ live: ráp 87 chunk từ
  `raw.githubusercontent.com` = 11.692.520 byte, SHA
  `cddb9cd543aea8e7` ✓; `versions.json` live pin `cddb9cd5`;
  `index.html` live SHA `4c31a5ab8eb8a35f` = staging ✓.
- Link live: https://tinnt120899.github.io/pho-xo-bo/ (Pages rebuild
  vài phút sau push).

### 39.5 Việc tiếp theo

1. Nhân vật 6 khung (hạn 20:00 22/11, cần nguồn gen ảnh AI) +
   ánh sáng + sự sống (23/11) — theo ETA §35.6.
2. Sạp chợ Map002 (khối be thô) + đất vẽ tay Map002 — làm khi tới
   lượt art Map002.
3. Kiểm live lại bằng cloud browser khi tunnel ổn (luật kiểm live).

## 40. Vòng 18 — Nhân vật 6 khung: walk cycle người chơi (22/11 ~01:45–02:30 +07)

Mục (2) của Claude (§35.6), hạn 20:00 22/11 — làm cho NGƯỜI CHƠI
trước (NPC chưa có sheet riêng, giữ ảnh đơn + nhún như cũ).

### 40.1 Việc làm

- **Art** (`src/godot/art/walk_player_f0..f5.png`, 119×208, luồng
  song song gen bằng media image generation): sheet 6 nhân vật 1
  hàng ngang, gen 1 lần đạt ngay — cùng mặt/tóc đen rối/áo xanh/
  quần tối/giày trắng với `char_player.png`, tư thế chân xen kẽ
  hợp lý. PIL tách theo khe trắng thật giữa các nhân vật (chia
  đều 6 lát đã cắt mất bàn tay f0/f5 + lọt tóc nhân vật kề vào
  f3/f4 — phát hiện nhờ ảnh kiểm nền magenta, đã sửa), trắng →
  trong suốt (flood-fill từ biên, ngưỡng ~235, feather 1.5),
  chuẩn hóa cùng canvas căn giữa ngang để không trượt khi chạy
  animation. Script `visual-check/artpass18/slice_walkcycle.py`,
  ghi chú `walkcycle-note.md`. Chỉ ~4 tư thế phân biệt rõ trong
  6 frame (f5≈f0, f2≈f4); chỉ có mặt trước — đi 4 hướng tạm dùng
  bộ này + flip ngang.
- **Code** (`scripts/character_sprite.gd`): cfg thêm `"frames"`
  (mảng đường dẫn); nạp được ≥2 frame thì chế độ frames — đổi
  khung mỗi 0.05s khi di chuyển (6 frame / 0.30s = 2 ô tile /
  chu trình, 3 frame / ô), dừng về frame 0; bob giảm còn 1.5
  (frame đã có chân động). Thiếu file → fallback ảnh đơn
  `texture` như cũ, không crash (clone mới chưa có art nhị phân
  vẫn chạy). `player.gd` nối 6 đường dẫn `walk_player_f*.png`.
- **Test mới** `tests/g4_r18_walkcycle_test.gd`: **16/16 PASS** —
  đủ 6 frame, đổi khung 0→1→2→3→5→0 đúng nhịp, dừng về frame 0,
  frames rác → fallback ảnh đơn, NPC không frames không đổi hành
  vi, Player trong Main nối frames. **Lỗi tìm ra khi test:** chia
  float `_frame_t / FRAME_TIME` sau 6 lần cộng 0.05 dừng ngay
  dưới 0.30 nên `int()` rớt xuống frame 5 thay vì 0 — sửa code
  thành tích lũy trừ dần (`while _frame_t >= FRAME_TIME`), không
  chia float; test chạy lại 16/16.
- **Lỗi export lần đầu (do lệnh sai, không phải game):**
  `--path src/godot` + đường dẫn tương đối `src/godot-build/...`
  khiến Godot tìm thư mục đích trong project (`Target folder
  does not exist`) — export bằng đường dẫn tuyệt đối thì xong.
  Bài học: export release luôn dùng đường dẫn tuyệt đối hoặc
  `cd src/godot` + `../godot-build/...` như G0.

### 40.2 Verify vòng này

- Hồi quy đầy đủ: **47 OK, 0 FAIL** (46 cũ + 1 mới); smoke
  `--headless --quit-after 120` exit 0, 0 ERROR.
- Export web exit 0: pck **11.898.092 byte, SHA `8f4a2e0a…`**
  (trước `cddb9cd5…` — tăng ~0,2 MB do 6 frame walk); wasm
  không đổi `fc74679e…`; HTTP 200 đủ 4 file (cổng 8173).
- **Browser-verify thật** (Chromium 1255 + swiftshader, 720×1280,
  script `visual-check/artpass18/check_r18.py`, ảnh
  `r18-01…r18-06`): **0 console error, 0 pageerror, 0 request
  fail.**
  - Giữ D: người chơi đi (4,5)→(7,5)→(10,5), tư thế chân KHÁC
    NHAU rõ giữa 2 ảnh giữa lúc bước (dạng rộng ↔ bắt chéo);
    thả phím: về tư thế đứng frame 0 tại (10,5).
  - **Lỗi script lần đầu (không phải game):** `check_r18.py`
    bấm cửa (5,4) sau khi đã đi tới (10,5) nên ảnh r18-06 vẫn ở
    Map001 (Ngày 2). Chạy bù `check_r18_m2.py` từ spawn: phải 1
    + lên 1 → đúng Chợ Đầu Mối + toast "Đã sang Chợ Đầu Mối",
    Chị Lệ/Anh Hải hiện đủ — không hồi quy.
- **Lưu ý đồng bộ art:** 6 PNG walk chỉ sống ở local + trong pck
  (snapshot-push chỉ nhận file text) — giống mọi art PNG từ trước;
  6 file `.import` (text) đã push thì tương thích. Clone mới về
  sẽ fallback về ảnh đơn `char_player.png` cho tới khi có cơ chế
  đẩy art nhị phân.

### 40.3 Deploy — CHẶN (22/11 ~02:30 +07, chưa xong)

- Push main + deploy gh-pages **CHƯA làm được trong vòng này**:
  `github push-files` bị gián đoạn 4 lần liên tiếp (cả bản đủ 16
  file lẫn bản nhỏ 4 file code) — lỗi "service restarted while it
  was running", head main vẫn `33d68d07` sau mỗi lần kiểm tra
  lại. Connector GitHub vẫn `connected`, read (`list_commits`)
  chạy bình thường; chỉ đường ghi `push_files` bị gián đoạn.
  ĐÃ DỪNG retry sau lần 4 (không lặp lại cùng 1 lệnh hỏng).
- **Retry 22/11 09:31 +07 (vòng sau): lại fail 3 lần nữa** — lần
  1 bản đủ 16 file, lần 2 bản đủ 16 file, lần 3 bản nhỏ 4 file
  (`pxb-push-r18a-paths`); cả 3 đều "service restarted", head
  main vẫn `33d68d07` sau mỗi lần kiểm tra lại, KHÔNG có commit
  nào áp dụng (đã đối chiếu lại trước mỗi lần retry: head khớp
  record, 4 file có base không divergence, 11 file mới xác nhận
  chưa tồn tại remote). Tổng cộng 7 lần push fail liên tiếp.
  Đường ghi `push_files` đang hỏng phía service — cần chờ hoặc
  tìm đường ghi khác, không retry vô hạn. DỪNG theo lệnh task.
- Mọi thứ khác của vòng này đã xong + verify (xem §40.2); code,
  test, export pck `8f4a2e0a…` đều ở working copy local.
- Manifest push đã chuẩn bị sẵn (bền, ngoài repo):
  `~/workspace/pxb-push-r18a-paths` (4 file code/test) +
  `~/workspace/pxb-push-r18-paths` (đủ 16 file) — vòng sau retry
  push main trước (đối chiếu lại head + divergence), rồi mới
  rebuild staging + deploy gh-pages pck `8f4a2e0a…` như §38.3/§39.4.
- Live site vẫn phục vụ bản vòng 17 (pck `cddb9cd5…`) — không hồi
  quy, chỉ chưa có walk cycle.

### 40.4 Việc tiếp theo

1. Ánh sáng + sự sống (23/11) — theo ETA §35.6: dải sao đã neo
   camera (vòng 17), còn nướng sáng đêm + sprite phát sáng cộng
   dồn + CanvasModulate + chuyển động nhỏ (lá rơi/khói/chim).
2. Walk cycle cho NPC (Cô Tư/Bạn Thân/Chị Lệ/Anh Hải) — cần sheet
   riêng từng người; mặt sau/mặt nghiêng cho người chơi (hiện chỉ
   mặt trước + flip).
3. Sạp chợ Map002 (khối be thô) + đất vẽ tay Map002 — làm khi tới
   lượt art Map002.
4. ~~G4 bước 7: nối PxbOnline sang server Godot mới (§17.2)~~ —
   **ĐÃ XONG từ commit `e01fa1542a`** (đính chính doc cũ §17.2/§20
   còn ghi là việc tiếp theo): `PxbOnline` đã có client WebSocket
   (`WebSocketMultiplayerPeer`, protocol v1) + chat trong điện thoại
   tab Tin nhắn, test `g4_online_ws_client_test` 49/49, browser-
   verify chat thật 0 lỗi. Việc online còn lại: auth player_id,
   giới hạn tốc độ chat, lưu lịch sử chat cho client mới vào
   (§17.5); server .NET giữ làm tham chiếu.


## 41. Vòng 19 — Ánh sáng + sự sống: glow ADD thật + lá rơi/đom đóm (22/11 ~09:45–10:15 +07)

Mục (3) của Claude (§35.6), ETA 23/11 — làm sớm trong lượt cron này
vì push main vòng 18 bị chặn (xem §41.4) nên chuyển sang việc tiếp
theo thay vì ngồi chờ.

### 41.1 Việc làm

- **GlowCanvas — ánh sáng cộng dồn THẬT** (`scripts/glow_canvas.gd`,
  mới): Node2D con của `_overlay_layer`, thêm SAU ColorRect MUL
  (nên vẽ TRÊN lớp nhân) nhưng TRƯỚC `_label_layer`/`_ui_layer`
  (cùng layer 1, thêm sau → vẫn dưới nhãn/HUD). Material
  `BLEND_MODE_ADD`: cộng ánh sáng thật vào ảnh cuối — đèn lồng/
  cửa sổ sáng hẳn lên rõ rệt mà không cần màu HDR >1.0 như
  NightGlow (vốn vẽ DƯỚI lớp MUL nên bị nhân tối, phải "xuyên"
  bằng HDR). Chỉ bật khung Tối; nguồn = `lamps + spots` của
  NightGlow (tọa độ thế giới → màn hình qua camera, vì CanvasLayer
  không theo viewport nên tọa độ vẽ là tọa độ màn hình). Vẽ halo
  mềm 10 vòng alpha giảm dần + tâm sáng, như kỹ thuật đĩa mềm của
  SkyEffects.
- **AmbientLife — sự sống nhỏ** (`scripts/ambient_life.gd`, mới):
  Node2D thế giới, z_index 10 (như SkyEffects/NightGlow), neo theo
  camera nên phủ kín khung nhìn: 14 lá vàng-xanh rơi chậm (24–42
  px/s) + lắc ngang, chạm đáy lặp lại từ trên; 10 đom đóm bay lang
  thang + nhấp nháy, CHỈ khung Tối. Seed RNG cố định 20261122 để
  test ổn định. `sim_step(delta)` là bước mô phỏng thật — `_process`
  gọi mỗi frame, test gọi trực tiếp để đo chính xác.
- **Nối dây** (`main.gd`): tạo 2 node trong `_build_ui()` (sau lớp
  overlay); `_update_daynight()` gọi `set_lit(frame==2)` +
  `set_sources(_glow_sources())` + `ambient.set_frame()` — nguồn
  đổi theo map mỗi lần đổi khung/đổi map. Helper `_glow_sources()`:
  Map001-002 = 1 đèn lồng (spots rỗng — cửa sổ đã sáng trong ảnh
  đêm), Map003+ thêm cửa sổ sáng.
- **Không đổi:** lớp MUL ngày/đêm, NightGlow, SkyEffects, sao/trăng
  giữ nguyên — vòng này chỉ THÊM 2 node mới, không sửa đường vẽ cũ
  (rủi ro hồi quy thấp; đã chứng minh bằng hồi quy 48/48 + browser).

### 41.2 Lỗi tìm ra khi làm (ghi để không tái phạm)

1. **GlowCanvas.visible mặc định true:** `set_lit(false)` lần đầu
   là no-op (lit đã false) nên node vẫn `visible=true` ở khung
   Sáng — `_draw` trả sớm nên không vẽ gì (vô hại về hình), nhưng
   test bắt đúng. Sửa: `set_lit` LUÔN gán `visible = on`, `_init`
   đặt `visible = false`.
2. **Test đo lá bằng trung bình y + baseline cũ:** lá chạm đáy lặp
   về y=-30 làm trung bình GIẢM dù lá vẫn rơi — FAIL giả. Sửa:
   đo 1 lá cụ thể xa đáy (y<1000) trước/sau `sim_step(1.0)`.
3. **Literal `[]` không kiếu bị từ chối ở tham số `Array[Vector2]`:**
   `set_sources([Vector2...])` lỗi type, `_state` không bao giờ
   sang 3 → test lặp state 2 vô hạn tới TIMEOUT (log 4465 dòng,
   371 lần lặp). Sửa: khai `var src: Array[Vector2] = [...]` rồi
   truyền. Bài học: lỗi type trong callback `_on_frame` không dừng
   test — state machine lặp mãi; test nào lặp state phải có guard
   đếm lần lặp (đã có TIMEOUT 400 frame, nhưng log phình vì mỗi
   lần lặp in 8 dòng PASS).
4. **Lá quá nhỏ/mờ trên ảnh thật:** lá 3–6px alpha 0.55 chìm hẳn
   vào lá vẽ sẵn trên đất. Tăng lên 4.5–8px, alpha 0.7 — vẫn tinh
   tế, nhìn kỹ thấy lá rơi giữa khung.

### 41.3 Test mới + verify vòng này

- Test mới `tests/g4_r19_lighting_test.gd`: **22/22 PASS** — Glow
  tồn tại + con của overlay + BLEND ADD, Sáng/Chiều tắt, Tối bật
  với đúng 1 nguồn/1 halo trong màn hình (Map001), đom đóm chỉ
  Tối, lá rơi xuống sau 1s mô phỏng, lá chạm đáy lặp từ trên,
  `set_sources` 2 điểm → 2 halo, về Sáng tắt lại, đủ 14 lá.
- Hồi quy đầy đủ: **48 OK, 0 FAIL** (47 cũ + 1 mới; chạy 2 lần —
  lần 2 sau khi tăng cỡ lá, vẫn 48/48).
- Smoke `--headless --quit-after 120` exit 0, 0 ERROR.
- Export web exit 0: pck **11.907.596 byte, SHA `96ef16a9…`**
  (trước `8f4a2e0a…` — tăng ~9,5KB do 2 script + test mới); wasm
  không đổi `fc74679e…`; HTTP 200 đủ 2 file (cổng 8174).
- **Browser-verify thật** (Chromium 1255 + swiftshader, 720×1280,
  script `visual-check/artpass19/check_r19.py`, ảnh
  `r19-01…r19-04`): **0 console error, 0 pageerror,
  0 request fail.**
  - Spawn Sáng: mặt trời + nhà ống + nhân vật như cũ; lá rơi
    nhỏ vàng-xanh lơ lửng giữa khung (nhìn kỹ mới thấy).
  - F ×2 → Tối Map001: đèn lồng góc trái dưới có quầng ấm rõ
    (ADD trên lớp MUL), sao + trăng như cũ, đom đóm lấm tấm.
  - Về Sáng + sang Map002: đúng Chợ Đầu Mối, không hồi quy.
  - Tối Map002: trời đêm + trăng + sao, quầng đèn lồng + cửa
    sổ sáng, NPC/sạp đủ.
- Staging gh-pages rebuild xong cho pck `96ef16a9` (89 chunk),
  VERIFY OK — sẵn sàng deploy khi push main hồi (xem §41.4).

### 41.4 Deploy — CHẶN (push-files gián đoạn, như vòng 18)

- Push main vòng 18 retry 2 lần trong lượt này (bản đủ 16 file +
  bản nhỏ 4 file `pxb-push-r18a-paths`): cả 2 đều "service
  restarted while it was running"; head main vẫn `33d68d07` sau
  mỗi lần kiểm tra lại. Cộng vòng 18 = **6 lần gián đoạn liên
  tiếp**. Connector GitHub `connected`, read (`list_commits`) bình
  thường; chỉ đường ghi `push_files` bị gián đoạn. **ĐÃ DỪNG
  retry** sau lần 2 của lượt này (không lặp cùng 1 lệnh hỏng).
- Hệ quả: live vẫn chạy pck vòng 17 `cddb9cd5` — walk cycle (vòng
  18) + ánh sáng/sự sống (vòng 19) CHƯA lên live, chỉ có local +
  export pck `96ef16a9` + staging gh-pages đã rebuild sẵn.
- Manifests chờ push (bền, ngoài repo): `~/workspace/pxb-push-r18-paths`
  (16 file vòng 18) + `~/workspace/pxb-push-r18a-paths` (4 file)
  + `~/workspace/pxb-push-r19-paths` (vòng 19, xem dưới). Lượt sau
  retry push main trước (đối chiếu lại head + divergence), rồi
  deploy gh-pages pck `96ef16a9` như §38.3/§39.4 (6 lô: pck
  89 chunk + versions.json + index.html CUỐI).
- Chủ CHƯA trả lời widget duyệt ảnh walk cycle vòng 18 (gửi
  ~12:52 22/11) tại thời điểm vòng này chạy — vòng 19 làm theo
  ETA Claude đã chốt (ánh sáng 23/11), không phụ thuộc duyệt đó.

### 41.5 Việc tiếp theo

1. Retry push main (vòng 18 + 19) + deploy gh-pages pck `96ef16a9`
   ngay khi `push_files` hồi — việc chặn duy nhất lúc này.
2. Walk cycle cho NPC (Cô Tư/Bạn Thân/Chị Lệ/Anh Hải) — cần sheet
   riêng từng người; mặt sau/mặt nghiêng cho người chơi (hiện chỉ
   mặt trước + flip).
3. Sạp chợ Map002 (khối be thô) + đất vẽ tay Map002 — làm khi tới
   lượt art Map002.
4. Kiểm live lại bằng cloud browser khi tunnel ổn (luật kiểm live).
5. Khói nồi phở / biển đung đưa (mục còn lại của Claude (3)) —
   cần sprite riêng cho biển/nồi (hiện là 1 phần của ảnh nền),
   để sau khi có art tách lớp.


## 42. Vòng 20 — Đất vẽ tay Map002 Chợ Đầu Mối (22/11 ~13:15–15:20 +07)

Mục 3 §41.5 (nửa đầu): sạp chợ Map002 + đất vẽ tay Map002 — làm
xong nửa đất; sạp (khối be thô) còn lại cho vòng sau (cần tách
sprite sạp riêng, hiện là 1 phần ảnh nền composite).

### 42.1 Việc làm

- Subagent gen `src/godot/art/ground_map002.png` 1440×900, PNG RGB
  2.369.876 byte, SHA `377ab722…`: sàn xi măng/đá chợ cũ loang lổ,
  vết nứt, vệt ẩm, 3 vũng nước phản chiếu, lá rau xanh rơi rải rác,
  vệt đất cát, dấu bánh xe mờ — watercolor, tông ấm, không chữ /
  không người / không công trình; vùng giữa thoáng. Hài hòa với
  `ground_map001.png` nhưng khác rõ (sàn chợ, không phải vỉa hè).
  Mép trên có 1 hàng đá kè thấp (rìa sàn) — chấp nhận, không gen lại.
- `main.gd` `_update_ground`: Map002 dùng `ground_map002.png` khi
  có file (fallback `ground_wide.jpg` nếu clone mới thiếu art nhị
  phân, như Map001); comment `_build_ui` cập nhật theo.
- Test mới `tests/g4_r20_map002_ground_test.gd`: Map001 giữ
  `ground_map001.png`, Map002 dùng `ground_map002.png` 1440×900,
  Map003 vẫn `ground_wide.jpg`, đi Map002→Map001 đổi đất đúng.
- Cập nhật test cũ theo tiền lệ §12.3: `g4_r17_sky_test.gd` kỳ vọng
  Map002 dùng `ground_map002.png` (không còn `ground_wide.jpg`).

### 42.2 Lỗi tìm ra khi làm (ghi để không tái phạm)

1. **PNG mới chưa `.import` thì `ResourceLoader.exists` = false:**
   test r20 chạy đầu 4/6 PASS — Map002 vẫn `ground_wide.jpg` dù file
   PNG đã có. Sửa: chạy `godot --headless --import` trước khi test
   (sinh `ground_map002.png.import`), rồi test 6/6 PASS. Bài học:
   thêm art nhị phân mới thì import trước, test sau.
2. **Test cũ tìm sprite đất bằng tên file:** `artpass12_test` tìm
   `"ground_wide" in texture.resource_path` để đo khe trời/đất —
   Map002 đổi texture nên `gtop` giữ 9999 → FAIL giả (hồi quy 48 OK,
   1 FAIL). Sửa: nhận cả 3 tên `ground_wide` / `ground_map001` /
   `ground_map002` (cùng 1 sprite 1440×900, chỉ đổi texture) →
   artpass12 14/14 PASS. Bài học: test nào match tên asset thì liệt
   kê đủ các biến thể khi thêm asset cùng loại.
3. **Cửa Map001→Map002 ở (5,4), KHÔNG phải (5,8):** check trình
   duyệt đi Phải + Xuống ×3 tới (5,8) rồi đứng im — (5,8) trên
   Map001 chỉ là ô thường (cửa (5,8) chỉ có ở Map002 trở đi, đi
   Map003). Nhãn "Cửa ra Chợ Đầu Mối" nổi trên màn hình không chỉ
   đúng vị trí ô (nhãn nổi cao ~190px) nên đừng bấm theo nhãn.
   Sửa: đi Phải + Lên từ spawn (4,5) → (5,4) là cửa thật, chuyển
   map ngay. Bài học: vị trí cửa lấy từ `maps.json`, không lấy từ
   vị trí nhãn trên ảnh.
4. **Nút Start DOM lúc có lúc không:** `get_by_text("BẮT ĐẦU CHƠI")`
   timeout 5s sau chờ 30s thì lúc được lúc không (lần tải đầu wasm
   39MB + pck 13MB chưa boot xong); fallback click canvas (360,1060)
   chạm thành tap di chuyển tới (6,7), làm vị trí spawn không ổn
   định giữa các lần chạy. Sửa: chờ 45s + retry DOM 3 lần (mỗi lần
   10s), chỉ fallback canvas khi hết retry; script chọn đường phím
   theo cách bấm được (`dom`: spawn (4,5) → Phải, Lên; `canvas`:
   (6,7) → Trái, Lên ×3). Cả 2 lần chạy sau đều bấm DOM được.

### 42.3 Test mới + verify vòng này

- Test mới `g4_r20_map002_ground_test`: **6/6 PASS**.
- Hồi quy đầy đủ sau khi sửa artpass12: **49 OK, 0 FAIL** (48 cũ +
  1 mới r20; lần chạy trước khi sửa: 48 OK, 1 FAIL chỉ artpass12,
  lỗi giả §42.2.2). artpass12 **14/14**, r17 **14/14**.
- Smoke `--headless --quit-after 120` exit 0, 0 ERROR.
- Export web exit 0: pck **13.514.456 byte, SHA `b501abd2…`**
  (trước `96ef16a9`, +1,6MB do `ground_map002.png`); wasm không đổi
  `fc74679e…`; `grep -a` thấy `ground_map002` ×2 trong pck; HTTP 200
  đủ 2 file (cổng 8175).
- **Browser-verify thật** (Chromium 1255 + swiftshader, 720×1280,
  script `visual-check/artpass20/check_r20.py`, ảnh
  `r20-01…r20-03`): **0 console error, 0 pageerror,
  0 request fail.**
  - Spawn Sáng Map001: đất vẽ tay ground_map001 như cũ, không hồi quy.
  - Sang Map002 (Phải + Lên qua cửa (5,4), toast "Đã sang Chợ Đầu
    Mối"): đất mới hiện rõ — sàn đá nứt + lá rau + vũng nước, thay
    ảnh chụp cũ; Chị Lệ/Anh Hải + sạp đủ. Sạp vẫn khối be thô + biển
    hiệu nổi (điểm chưa đẹp đã biết, để vòng sau).
  - Tải lại về Map001: spawn (4,5), đất ground_map001, không hồi quy.
- Staging gh-pages rebuild xong cho pck `b501abd2` (101 file),
  VERIFY OK, `versions.json` pin `b501abd2` — sẵn sàng deploy khi
  push hồi (xem §42.4).

### 42.4 Deploy — CHẶN (push-files gián đoạn lần 7 liên tiếp)

- Lượt này retry push main 1 lần (gộp r18+r19: 24 file, 423KB,
  manifest `~/workspace/pxb-push-r18r19-paths`): "service restarted
  while it was running"; kiểm tra lại head main vẫn `33d68d07`
  (chưa áp dụng). Đây là lần gián đoạn thứ 7 liên tiếp của
  `push_files` (6 lần vòng 18+19 + 1 lần lượt này). **ĐÃ DỪNG
  retry** trong lượt này theo luật vòng 18/19 — không lặp cùng 1
  lệnh hỏng.
- Hệ quả: live vẫn chạy pck vòng 17 `cddb9cd5` — walk cycle (vòng
  18) + ánh sáng/sự sống (vòng 19) + đất Map002 (vòng 20) CHƯA lên
  live, chỉ có local + export pck `b501abd2` + staging gh-pages đã
  rebuild sẵn.
- Manifest chờ push (bền, ngoài repo): `~/workspace/pxb-push-r18r19-paths`
  (24 file vòng 18+19) + `~/workspace/pxb-push-r18r19r20-paths`
  (vòng 18+19+20, xem dưới). Lượt sau retry push main trước (đối
  chiếu lại head + divergence), rồi deploy gh-pages pck `b501abd2`
  như §38.3/§39.4 (pck 101 file + versions.json + index.html CUỐI).
  Deploy gh-pages cũng dùng `push_files` nên cùng bị chặn — không
  thử trong lượt này.

### 42.5 Việc tiếp theo

1. Retry push main (vòng 18+19+20) + deploy gh-pages pck `b501abd2`
   ngay khi `push_files` hồi — việc chặn duy nhất lúc này.
2. Walk cycle cho NPC (Cô Tư/Bạn Thân/Chị Lệ/Anh Hải) — cần sheet
   riêng từng người; mặt sau/mặt nghiêng cho người chơi (hiện chỉ
   mặt trước + flip).
3. Sạp chợ Map002 (khối be thô + biển hiệu nổi) — cần sprite sạp
   tách riêng hoặc vẽ lại nền chợ; làm khi tới lượt art Map002.
4. Kiểm live lại bằng cloud browser khi tunnel ổn (luật kiểm live).
5. Khói nồi phở / biển đung đưa (mục còn lại của Claude (3)) — cần
   sprite riêng cho biển/nồi (hiện là 1 phần của ảnh nền), để sau
   khi có art tách lớp.

## 43. Vòng 21 — Push hồi + deploy b501abd2 lên live (22/11 ~15:20–16:10 +07)

### 43.1 Chặn push — HỒI sau 8 lần gián đoạn

- Lượt này retry push main gộp r18+r19+r20 (30 file, 450KB,
  manifest `~/workspace/pxb-push-r18r19r20-paths`): "service restarted
  while it was running" lần 8 liên tiếp; kiểm tra head main vẫn
  `33d68d07` (chưa áp dụng). **ĐÃ DỪNG retry lệnh này.**
- Chẩn đoán bằng lệnh khác: push 1 file `docs/godot-g4.md`
  (manifest `~/workspace/pxb-push-r21-diag-paths`) → **THÀNH CÔNG**,
  head `2befc7de`. Không phải do kích thước tuyệt đối (file này
  ~264KB) — dịch vụ push chập chờn, lúc được lúc không.
- Chia nhỏ + retry có chừng mực: lô A (6 file code, 120KB) fail 1
  lần rồi thành công ở retry (`95490677`); lô B (9 file test,
  36KB, `978e6cf2`) + lô C (14 file .import/visual-check, 31KB,
  `e5ad341d`) thành công ngay. **Kết luận: push_files không chết
  hẳn — fail là ngắt quãng, retry 1–2 lần mỗi lô là đủ; không retry
  vô hạn cùng 1 lệnh.** Sync record ghi đủ 4 commit (entries 203–206).
- Head main sau vòng này: `e5ad341d` — đủ 30 file vòng 18+19+20
  (walk cycle 6 khung, GlowCanvas + AmbientLife, đất Map002).

### 43.2 Deploy gh-pages pck b501abd2 — XONG, verify live khớp byte

- Staging đã rebuild từ vòng 20, `build_gh_pages.py --verify-only`
  exit 0: pck `b501abd2` 101 chunk / 13.514.456 byte khớp byte,
  wasm `fc74679e` 293 chunk không đổi, img khớp, loader đủ.
  Đối chiếu trước deploy: gh-pages head `5f641feb`,
  `versions.json` live pin `cddb9cd5` (vòng 17), không divergence.
- Deploy 7 lô (manifest `~/workspace/pxb-deploy-b501abd2-batch1..7`):
  part 000–019 `1f8fa637`, 020–039 `842b0bc1`, 040–059 `6533cb20`,
  060–079 `5cd568d3`, 080–099 `f4efbf19`, part 100 `55d0a1f5`,
  versions.json + index.html cuối `0fe30938`. Sync record ghi đủ
  7 commit (entries 207–213).
- Verify live bằng byte: lúc đầu `versions.json` live vẫn
  `cddb9cd5` + part-000 404 (Pages deploy lag ~3 phút) — sau đó
  pin `b501abd2`; tải + ráp 101 part từ live = **13.514.456 byte,
  SHA `b501abd2` — khớp đúng từng byte**; index.html live liệt kê
  đủ 101 part `b501abd2`.
- Smoke headless sau deploy: `--quit-after 120` exit 0, 0 ERROR
  (code không đổi từ vòng 20; hồi quy 49/49 + browser-verify r20
  0 lỗi đã có từ vòng 20, không chạy lại).
- **Live nay chạy vòng 18+19+20**: walk cycle nhân vật chính,
  đèn lồng/cửa sổ đêm sáng (GlowCanvas), lá rơi + đom đóm khung
  Tối, đất vẽ tay Map002. Link: https://tinnt120899.github.io/pho-xo-bo/

### 43.3 Việc tiếp theo

1. Walk cycle cho NPC (Cô Tư/Bạn Thân/Chị Lệ/Anh Hải) — §42.5 mục 2.
2. Sạp chợ Map002 — §42.5 mục 3.
3. Kiểm live lại bằng cloud browser khi tunnel ổn (luật kiểm live).
4. Khói nồi phở / biển đung đưa — §42.5 mục 5.
5. Chủ vẫn chưa trả lời widget duyệt ảnh walk cycle vòng 18 (gửi
   ~12:52 22/11) — vòng 18 đã lên live, nếu chủ chê thì làm lại
   theo ý chủ ở vòng sau.

## 44. Vòng 22 — Walk cycle 4 NPC + patrol đi lang thang (22/11 ~20:45–21:30 +07)

### 44.1 Art — 24 frame walk cycle NPC (đã có sẵn từ 13:48 22/11)

Art đã được chuẩn bị trước lượt này (artpass22, quy trình y hệt
vòng 18 — sheet 6 nhân vật/hàng → cắt theo khe trắng, flood fill
trắng→trong suốt, resize cao 208px): 4 sheet 2736×912 + 24 frame
`walk_cotu/banthan/chile/anhhai_f0..f5.png` (RGBA, cao 208px) trong
`src/godot/art/`, ghi chú `visual-check/artpass22/walkcycle-npc-note.md`
(kiểm bằng mắt: đúng 6 nhân vật/sheet, tư thế chân tiến triển,
f5 ≈ f0 như vòng 18). Lượt này có spawn subagent gen lại art —
đã đóng ngay khi thấy art đủ + đúng spec, tránh gen trùng.
PNG nhị phân chỉ sống local + trong pck (tiền lệ vòng 18); chỉ
`.import` mới push.

### 44.2 Code — frames NPC + patrol (Main quyết, Marker thực thi)

| File | Đổi |
|---|---|
| `scripts/marker.gd` | `NPC_STYLE` thêm `"frames"` 6 đường dẫn/NPC; patrol API: `home_tile`/`patrol_tile()` (ô logic, đổi khi tween xong), `patrol_walk_to(dest, world_pos)` (tween 0.30s/o = 1 chu trình walk cycle, `moving` bật frame, `facing` theo dx; từ chối khi đang bước/cùng ô), `patrol_moving()`, `has_walk_frames()`; tween tiến trong `_process`. |
| `main.gd` | `_update_npc_patrol(delta)` (gọi mỗi frame sau `_update_npc_labels`): quyết định mỗi 0.5s; NPC nghỉ ngẫu nhiên 4–9s rồi bước sang 1 ô đất trống kề nhà (`_npc_patrol_pick`: đi được + không event + không phải ô người chơi/NPC khác), ở ngoài 2–5s rồi về; **về nhà ngay khi người chơi lại gần (≤5 ô, cùng ngưỡng hiện nhãn) hoặc mở UI/hội thoại/title** — vì `event_at`/`is_walkable` dùng data tĩnh theo ô nhà, tương tác E chỉ đúng khi NPC đứng đúng ô nhà. Lần gặp đầu cũng nghỉ ngẫu nhiên (không cho cả 2 NPC cùng bước ra ngay tick đầu). |
| `tests/g4_r22_npc_walk_test.gd` (mới) | 41 mục: 4 NPC đủ 6 frame + đổi khung theo nhịp + về frame 0 khi đứng yên; thiếu frame → fallback ảnh đơn; Marker patrol (home, tween 0.30s, đổi ô logic, từ chối lệnh chen/cùng ô, về nhà); pick 20 lần đều ô kề hợp lệ + nhiều hơn 1 đích; Main: xa → bước ra, gần → về nhà, mở hội thoại khi ở ngoài → lệnh về nhà. |
| `tools/godot/run_regression.sh` | Thêm `g4_r22_npc_walk_test` vào danh sách (nay 46 suite + online). |

### 44.3 Lỗi tìm được khi làm

1. **Test fail giả do `title_open=true` lúc khởi động** — patrol
   bị chặn theo đúng thiết kế (đứng yên khi title mở) nên test
   "người chơi xa → NPC bước ra" timeout 30 frame. Sửa test
   (không sửa game): đặt `_main.title_open = false` như đã bấm
   Bắt đầu. Bài học: test nào cần game đang chạy phải tắt title
   trước — ghi nhớ cho test sau.
2. **Delta headless quá nhỏ làm tween patrol timeout giả** —
   frame headless chạy nhanh, delta ~1ms nên tween 0.30s cần
   hàng trăm frame mới xong (state 5 timeout 120 frame lần đầu).
   Sửa test: khi NPC đang bước thì gọi tay `_process(0.35)` để
   đẩy nhanh tween (tree cũng gọi `_process` nên chỉ nhanh hơn,
   không sai lệch). Tiền lệ: test sau có tween thì lái tay như vậy.
3. **`var t := home + d` không suy được kiểu** (d từ mảng literal
   không kiểu) — parse error ở `main.gd:1833`. Sửa: `var t:
   Vector2i = home + d`. Bài học: vòng lặp qua mảng literal
   Vector2i thì khai kiểu tường minh cho biến dùng `+`.

### 44.4 Verify thật vòng này

- `--check-only` main/marker/test: PASS.
- Test mới `g4_r22_npc_walk_test`: **41/41 PASS** (lần đầu 37/38
  do lỗi 1, lần hai 40/41 do lỗi 2 — sửa test, chạy lại PASS hết).
- Hồi quy đầy đủ `run_regression.sh`: **50 OK, 0 FAIL** (49 cũ +
  1 mới r22; gồm online server 37/37 + probe OK).
- Smoke `--headless --quit-after 120` exit 0, 0 ERROR.
- Export web exit 0: pck **14.396.484 byte, SHA `a5964dee…`**
  (trước `b501abd2`, +882KB do 24 frame NPC); wasm không đổi
  `fc74679e`; `grep -a` thấy `walk_cotu/banthan/chile/anhhai` ×24
  trong pck; HTTP 200 đủ 6 file (cổng 8176).
- **Browser-verify thật** (Chromium 1255 + swiftshader, 720×1280,
  script `visual-check/artpass22/check_r22.py`, ảnh `r22-01…03`):
  **0 console error, 0 pageerror, 0 request fail.**
  - Spawn Map001: Cô Tư + Bạn Thân đứng ở nhà, nhãn hiện.
  - Người chơi về (1,1), chờ 12s: cả 2 NPC đã bước ra khỏi ô
    nhà (Bạn Thân sang trái gần xe đẩy, Cô Tư xuống dưới gần
    cửa) — nhãn ẩn đúng luật xa >5 ô.
  - Người chơi về (4,6), chờ 3s: cả 2 NPC về đúng ô nhà, nhãn
    hiện lại như lúc spawn — patrol về nhà đã thấy bằng mắt.

### 44.5 Deploy — XONG, verify live khớp byte (22/11 ~21:30–22:25 +07)

- Push main 2 lô (không gián đoạn lần nào): lô A code
  `fa2ccea1` (main/marker/test/run_regression), lô B
  `84b721bf` (24 `.import` walk NPC + check_r22 + note +
  slice script). Head main `84b721bf` (trước `c4059abb`).
  Sync record 216 entries.
- Staging rebuild `build_gh_pages.py` VERIFY OK: pck
  `a5964dee` 107 chunk / 14.396.484 byte khớp byte, wasm
  `fc74679e` 293 chunk không đổi, img khớp, loader đủ.
- Deploy 7 lô gh-pages: part 000–019 `26f527f0`, 020–039
  `8a17fb1e`, 040–059 `78e666b0`, 060–079 `271bf7a7`,
  080–099 `09f2f03d`, 100–106 `6fc7b42e`, versions.json +
  index.html cuối `b0b97773`. Sync record 223 entries.
- Verify live bằng byte: `versions.json` live pin `a5964dee`
  (sau lag Pages ~3 phút); tải + giải base64 + ráp 107 part
  từ live = **14.396.484 byte, SHA `a5964dee` — khớp đúng
  từng byte**; index.html live liệt kê part `a5964dee`.
- **Live nay chạy vòng 22**: walk cycle 4 NPC + patrol đi
  lang thang. Link: https://tinnt120899.github.io/pho-xo-bo/
- Lưu ý verify: part `.txt` trên live là base64 — ráp trực
  tiếp ra 19.195.312 byte, SHA sai; phải `base64 -d` từng
  part rồi mới ráp (tỉ lệ 4/3 đúng bằng chứng).

### 44.6 Việc tiếp theo

1. Sạp chợ Map002 (khối be thô + biển hiệu nổi) — §42.5 mục 3.
2. Kiểm live lại bằng cloud browser (luật kiểm live) — bản mới
   có patrol, cần xem NPC đi lại trên live có mượt không.
3. Khói nồi phở / biển đung đưa — §42.5 mục 5.
4. NPC Map003–018 vẫn dùng ảnh đơn + nhún (chỉ 4 NPC Map001–002
   có walk cycle): khi nào art NPC các khu khác có sheet thì nối
   `frames` theo đúng mẫu `NPC_STYLE` này (không cần sửa code
   patrol — `CharacterSprite` tự fallback khi thiếu file).

### 44.7 Kiểm live vòng 22 (cloud browser, 22/11 21:29–21:38 +07)

- Game chạy, nút BẮT ĐẦU bấm được, HUD đủ; không thấy console
  error/pageerror/request fail trong suốt quá trình (checker
  không mở DevTools nên đây là kết luận quan sát, không phải
  log console thô).
- Di chuyển: phím D từ spawn (4,5) → (5,5), đúng 1 ô; W/A/S
  đều đổi tọa độ đúng từng ô; nhân vật đổi tư thế chân khi đi
  (walk cycle thấy được).
- Patrol: người chơi lên (1,1), chờ 12s → cả 2 NPC rời chỗ cũ
  (Bạn Thân xuống dưới-trái, Cô Tư xuống sát mép dưới); về
  (4,6), chờ 3s → cả 2 NPC về khu vực spawn, nhãn hiện lại.
- **Chưa khớp hẳn — ước lượng bằng mắt, chưa xác minh:** checker
  thấy Cô Tư về lệch ~1 ô sang phải và Bạn Thân chồng lên ô
  người chơi. Nhưng test headless 41/41 khẳng định
  `patrol_tile == home` sau khi về, và ảnh local r22-03 cho
  thấy NPC về đúng vị trí như lúc spawn — nhãn debug chỉ hiện
  ô NGƯỜI CHƠI nên checker chỉ ước lượng vị trí NPC qua ảnh
  iso (dễ lệch). Ghi nhận là quan sát chưa xác minh, không sửa
  code theo ước lượng này; nếu vòng sau thấy lại thì đo bằng
  số ô thật.
- Nhãn tên NPC ẩn khi người chơi xa (>5 ô) là **đúng thiết kế
  vòng 15** (LABEL_NEAR_TILES), không phải lỗi — checker chỉ
  ghi nhận hiện tượng.
- Lưu ý: cửa sổ checker là khổ ngang 1920×999, canvas game vẫn
  dọc 720×1280 ở giữa (không ép được đúng khổ 720×1280).

## 45. Vòng 23 — Sạp chợ Map002 vẽ lại (22/11 ~21:45–23:30 +07)

Mục 1 §44.6 (§42.5 mục 3): sạp chợ Map002 "khối be thô + biển
hiệu nổi" (anh r20-02: biển 58×13 chữ 10px trên tường be phang,
hàng trên quầy chỉ 3 giỏ trái cây theo hash, tường bên 2 cột là
hình chữ nhật be xếp bậc thang).

### 45.1 Vì sao không dùng sprite tách riêng (§42.5.3)

Đã đo trước khi chọn: ô hàng 0 cách nhau **32px màn hình**
(`tile_center_raw`: bước x 32px). Sprite sạp 64px sẽ bị tường
nhà lẻ 2 bên (34px, vẽ sau trong `_draw`) che 17px mỗi bên —
chỉ thấy ~30px giữa. Muốn dùng sprite phải đổi cấu trúc hàng
(ô lẻ để trống, sạp cách nhau) — việc 2 vòng (artpass sprite +
đổi hàng), không phải 1 vòng. Vòng này vẽ lại bằng code đúng
bước iso hiện có; sprite để vòng sau nếu đổi hàng.

### 45.2 Việc làm

| File | Đổi |
|---|---|
| `scripts/nadia_scene.gd` | `STALL_KIND_COLORS` (8 màu biển theo loại hàng) + `stall_goods_kind(sign)` (8 biển → rau/ca/thịt/trái-cây/bánh-mì/gia-vị/hoa-quả/đồ-khô) + `stall_sign_color(sign)` + `market_stall_tiles()` [0,2,4,6,8,10] + `side_stall_rows()` [2,4,6]; `_draw_market_row` vòng 2: biển **62×16 chữ 11px** (cũ 58×13 chữ 10), nền màu theo loại + viền kem + bóng + 2 đinh; vòng 1: tường thêm vân gỗ ngang + bóng cạnh; `_draw_shop_front(c,h,sign)` (thêm tham số biển): mái hiên thêm viền vỏ sò + 2 cột chống, quầy thêm vân gỗ + thẻ giá (sạp chẵn), hàng trên quầy theo loại qua `_draw_stall_goods(c,kind,counter_top)` mới (rau: lá xanh; cá: 2 con trên đá; thịt: miếng đỏ; trái cây: 4 quả đủ màu; bánh mì: ổ elip; gia vị: 3 lọ; đồ khô: 2 bao); `_draw_side_walls`: tường thêm vân gỗ + bóng cạnh, hàng chẵn (2,4,6) thành **sạp bên** (`_draw_side_stall`: biển nhỏ 52×12 chữ 10 + mái hiên kẻ 3 sọc + quầy + hàng theo loại), hàng lẻ giữ áp phích to hơn (24×30) / cây leo / vết loang; nhánh chết `if map_id == 2` trong `_draw_facades` đã bỏ (không bao giờ tới vì return sớm); helper `_draw_ellipse` mới. |
| `tests/g4_r23_stall_test.gd` (mới) | 10 mục: 8 biển ánh xạ đúng loại + biển lạ về "rau"; 8 màu biển khác nhau alpha 1; chữ biển vừa bảng (rộng nhất "THỊT HEO" 53.0px ≤ 58 ở cỡ 11; cỡ 10 ≤ 48 cho biển bên); nhịp sạp hàng 0 + hàng bên; scene thật Map002 có NadiaScene map_id 2, chạy 60 frame không lỗi, về Map001 map_id 1. |
| `tools/godot/run_regression.sh` | Thêm `g4_r23_stall_test` (nay 51 suite + online). |
| `visual-check/artpass23/check_r23.py` (mới, subagent) | Theo mẫu check_r20.py, cổng 8177 + ảnh zoom vùng sạp (clip y=640..1000). |

### 45.3 Verify thật vòng này

- `--check-only` nadia_scene.gd: PASS.
- Test mới `g4_r23_stall_test`: **10/10 PASS** (lần đầu).
- Hồi quy đầy đủ: **51 OK, 0 FAIL** (50 cũ + 1 mới r23).
- Smoke `--headless --quit-after 120` exit 0, 0 ERROR.
- Export web exit 0: pck **14.404.944 byte, SHA `e1e4ee94…`**
  (trước `a5964dee`, +8.460 byte = đúng code vẽ thêm, không art
  mới); wasm không đổi `fc74679e`; HTTP 200 đủ 6 file (cổng
  8177). Lưu ý export: lần đầu lỗi `Target folder does not
  exist: "src/godot-build"` vì đường dẫn export tương đối được
  hiểu theo `--path src/godot` (thành `src/godot/src/godot-build`)
  — sửa bằng đường dẫn tuyệt đối (tiền lệ G0 dùng `cd src/godot`
  + `../godot-build`). Lần import trước đó sinh
  `g4_r23_stall_test.gd.uid` đúng quy trình.
- **Browser-verify thật** (Chromium 1255 + swiftshader, 720×1280,
  script `visual-check/artpass23/check_r23.py`, ảnh
  `r23-01…r23-04`): **0 console error, 0 pageerror,
  0 request fail.**
  - Map002: biển đọc được, có màu riêng (RAU CỦ xanh lá,
    THỊT HEO đỏ, BÁNH MÌ nâu, HOA QUẢ hồng, CÁ TƯƠI xanh dương,
    ĐỒ KHÔ nâu vàng); mái hiên viền vỏ sò + cột chống; quầy có
    hàng đúng loại (trái cây đủ màu, ổ bánh mì); sạp bên 2 cột
    có biển + mái hiên + quầy (thấy rõ CÁ TƯƠI/ĐỒ KHÔ cột phải).
  - Map001 tải lại: không hồi quy (nền cao, NPC patrol như cũ).
  - Còn lại (không sửa vòng này): tường bên vẫn nền be sau sạp
    (đã có vân gỗ, vẫn phẳng); biển sạp bên cột phải (x=11) bị
    cắt một phần ở mép canvas 720 — tường cũ cũng bị cắt như vậy.

### 45.4 Deploy — XONG, verify live khớp byte (22/11 ~23:30–23:50 +07)

- Push main 1 lô (không gián đoạn): code + test + check_r23
  `2a214c4b` (trước `2167689e`). Sync record 226 entries.
- Staging rebuild `build_gh_pages.py --verify-only` exit 0: pck
  `e1e4ee94` 107 chunk / 14.404.944 byte khớp byte, wasm
  `fc74679e` 293 chunk không đổi, img khớp, loader đủ.
  Đối chiếu trước deploy: gh-pages head `b0b97773`,
  `versions.json` live pin `a5964dee` (vòng 22), không divergence
  (list_commits bỏ qua tham số branch nên chỉ dùng được cho main;
  head gh-pages lấy từ sync record).
- Deploy 7 lô gh-pages: part 000–019 `880e5b67`, 020–039
  `94b7b404`, 040–059 `00134b8e`, 060–079 `3f77c6e4`,
  080–099 `3c81c642`, 100–106 `daaf5950` (lô này chậm ~9 phút),
  versions.json + index.html cuối `85f190c8`. Sync record 233
  entries. Không gián đoạn lần nào (khác vòng 18–20).
- Verify live bằng byte: pin `e1e4ee94` sau lag Pages ~30 giây;
  tải + giải base64 + ráp 107 part từ live = **14.404.944 byte,
  SHA `e1e4ee94dae9` — khớp đúng từng byte**; index.html live
  liệt kê part `e1e4ee94`.
- **Live nay chạy vòng 23**: sạp chợ Map002 vẽ lại. Link:
  https://tinnt120899.github.io/pho-xo-bo/
- Kiểm live cloud browser lần 1 (22:44–22:52 +07): game chạy,
  nút Bắt đầu bấm được, không thấy lỗi hiển thị (checker không
  mở được DevTools nên là kết luận quan sát); di chuyển D/A/S/W
  đúng từng ô đo bằng nhãn debug (spawn (4,5); D→(5,5); A→(4,5);
  S→(4,6); W→(4,5)); sang Map002 qua cửa (5,4) được 2 chiều,
  toast "Đã sang Chợ Đầu Mối"; sạp hàng trên: biển đọc được +
  màu riêng theo loại, mái hiên kẻ sọc, quầy có hàng đúng loại
  (nhãn nổi che một phần quầy CÁ TƯƠI/GIA VỊ/ĐỒ KHÔ).
- Kiểm live bổ sung (22:54–23:05 +07): **sạp bên CÓ trên live**
  (đính chính kết luận lần 1 "chỉ thấy khối be phẳng" — checker
  đã bỏ sót vì biển bên nhỏ + bị D-pad/nhãn che): cột trái có
  biển BÁNH MÌ (nâu) + HOA QUẢ (cam) kèm mái hiên kẻ sọc +
  quầy; cột phải có BÁNH MÌ, HOA QUẢ, CÁ TƯƠI (xanh dương),
  ĐỒ KHÔ (ô-liu), GIA VỊ (tím) kèm mái hiên + quầy; khối be
  phẳng chỉ còn ở phần dưới cột trái (hàng lẻ, cố ý là tường
  trơn) + phần sau nút D-pad. Khớp ảnh local r23-02.
- Patrol live: 2 lần kiểm bằng ảnh tĩnh đều "không thấy đi"
  (đứng (1,7)/(1,8) 24s; đứng (1,1) chụp trước/sau 15s) —
  **KHÔNG phải lỗi patrol.** Probe headless vòng này
  (`/tmp/pxb-patrol-probe.gd`, không commit): chạy
  `Main._process(0.5)` thật 60 lần (= 30s game time), người
  chơi (1,1): t=10s Cô Tư (7,6) + Bạn Thân (3,6) (đã rời nhà),
  t=15s về nhà, t=20s lại ra (9,6)/(3,4), t=30s (8,7) —
  **PASS, patrol chạy đúng chu kỳ** (nhà 4–9s → ra ngoài 2–5s
  → về nhà). Bài học phương pháp: 2 ảnh tĩnh cách nhau 15s rất
  dễ cùng bắt lúc NPC ở nhà (~65% thời gian ở nhà) nên không
  kết luận được patrol hỏng — kiểm patrol phải quay video liên
  tục hoặc chụp mỗi 2s. Probe local vòng này cũng vậy: ảnh A/B
  ở (4,1) giống nhau ở vùng NPC, nhưng diff toàn ảnh 20.893 px
  (khói/lá/nắng động) và probe headless đã chứng minh NPC có đi.
  Lưu ý probe local: đi Trái trước từ spawn bị Bạn Thân ở (3,5)
  chặn (ô NPC không đi được) nên người chơi chỉ tới (4,1) —
  lần sau đi Lên trước rồi mới sang Trái (như check_r22.py).
- Lưu ý verify: lần export đầu lỗi `Target folder does not
  exist: "src/godot-build"` (xem §45.3) — pck cũ `a5964dee`
  vẫn nằm trên đĩa tới khi export lại bằng đường dẫn tuyệt đối
  thì mới ra `e1e4ee94`; đừng nhầm file cũ với bản mới khi đối
  chiếu SHA.

### 45.5 Việc tiếp theo

1. Khói nồi phở / biển đung đưa — §42.5 mục 5 (cần sprite riêng
   cho biển/nồi, hiện là 1 phần ảnh nền).
2. Sprite sạp tách riêng (§45.1): khi nào đổi hàng 0 thành sạp
   cách nhau (ô lẻ để trống) thì gen 3 sprite sạp (rau/trái cây/
   cá-thịt) thay code vẽ — vòng 24+.
3. NPC Map003–018 vẫn ảnh đơn + nhún (chỉ 4 NPC Map001–002 có
   walk cycle): nối `frames` khi có sheet (theo mẫu vòng 22).
4. Kiểm live lại bằng cloud browser — ĐÃ XONG vòng này (§45.4):
   sạp mới đã thấy trên live, patrol đã chứng minh bằng probe
   headless (PASS). Bài học phương pháp (ghi để vòng sau không
   tái phạm): kiểm patrol KHÔNG dùng 2 ảnh tĩnh — dùng video
   liên tục hoặc chụp mỗi 2s, hoặc probe headless qua
   `Main._process`; đi từ spawn phải Lên trước rồi mới sang
   Trái (ô (3,5) là nhà Bạn Thân, chặn đường).

## 46. Vòng 24 — Biển phở đung đưa + khói nồi phở rõ hơn (22/11 ~23:20–00:10 +07)

Mục 1 §45.5 (§42.5 mục 5 — mục còn lại của Claude (3) từ vòng 20):
khói nồi phở đã có từ trước trong code (`_draw_food_cart`, 3 cụm,
alpha ≤0.35) nhưng mờ, khó thấy; biển đung đưa chưa có — biển trên
mặt tiền Map001 nằm trong ảnh composite nên không lắc được.

### 46.1 Việc làm

| File | Đổi |
|---|---|
| `scripts/nadia_scene.gd` | Hằng + helper mới: `FOOD_CART_TILE (6,12)`, `SIGN_TEXT "PHỞ BÒ"`, `SIGN_BOARD (46,16)`, `SIGN_SWAY_AMP 0.07 rad (~4°)`, `SIGN_SWAY_SPEED 1.4`, `SMOKE_PUFFS 4`, `SMOKE_RISE 50`, `SMOKE_ALPHA_MAX 0.5`; `food_cart_sign_angle(t)` (sin con lắc, 0 ở t=0, cực đại ở t=PI/(2*SPEED)); `food_cart_smoke_puff(t, i)` (vị trí/bán kính/alpha — bay lên + mờ dần + lắc ngang). `_draw_food_cart`: khói 4 cụm alpha tới 0.5 (cũ 3 cụm 0.35); thêm **biển treo "PHỞ BÒ" đung đưa** dưới mái hiên xe đồ ăn — 2 dây treo + bảng gỗ 46×16 viền kem + chữ 10px, lắc quanh điểm treo ở mép mái hiên bằng `draw_set_transform(pivot, angle)`, vẽ sau cùng để nằm trước thân xe. Biển trên mặt tiền trong ảnh composite giữ nguyên — biển treo này là vật riêng, không đè lên biển trong ảnh. |
| `tests/g4_r24_smoke_sign_test.gd` (mới) | 15 mục: góc biển 0 ở t=0, +AMP ở t=PI/(2*SPEED), −AMP ở t=3*PI/(2*SPEED), đổi góc theo thời gian, biên độ 0.05–0.10 rad; khói 4 cụm, bay lên, mờ dần, lắc ngang đổi theo t, alpha ≤0.5, bán kính ≤9; chữ "PHỞ BÒ" cỡ 10 rộng 41.0px ≤ 42 (bảng 46); xe đồ ăn ở ô (6,12); scene Map001 chạy 60 frame, `_t` chạy thật. |
| `tools/godot/run_regression.sh` | Thêm `g4_r24_smoke_sign_test` (nay 52 suite + online). |
| `visual-check/artpass24/check_r24.py` (mới, subagent) | Theo mẫu check_r23.py, cổng 8178 + ảnh zoom vùng xe (clip y=640..1000) + pixel-diff 2 ảnh cách nhau 1.5s. |

### 46.2 Lỗi tìm ra khi làm (ghi để không tái phạm)

- **`rm -rf src/godot-build` xóa cả asset DOM shell:** export
  xong, browser-verify lần 1 báo **9 console error 404** —
  `title_bg.jpg`, `char_player.png`, `char_banthan.png` (mỗi file
  ×3 lần tải trang). Nguyên nhân: 3 file này không phải do export
  sinh ra mà do các vòng trước copy tay vào `src/godot-build/`
  cho `web_shell.html` fetch (`fetchBlobRetry`); `rm -rf` trước
  export đã xóa chúng. Sửa: khôi phục `title_bg.jpg` bằng cách
  giải base64 từ staging (`gh-pages-staging/img/title_bg.jpg/260962c1/`,
  119.190 byte, đúng bản live) + copy 2 PNG từ `src/godot/art/`;
  chạy lại check → **0 console error, 0 pageerror,
  0 requestfailed**. **LUẬT: không bao giờ `rm -rf` cả thư mục
  build — chỉ xóa file export sinh ra (`index.*`, `index.pck`,
  `index.wasm`), hoặc export đè lên; asset DOM shell
  (`title_bg.jpg`, `char_*.png`) phải giữ lại.**

### 46.3 Verify thật vòng này

- `--check-only` nadia_scene.gd: PASS.
- Test mới `g4_r24_smoke_sign_test`: **15/15 PASS** (lần đầu).
- Hồi quy đầy đủ: **52 OK, 0 FAIL** (51 cũ + 1 mới r24).
- Smoke `--headless --quit-after 120` exit 0, 0 ERROR/warning.
- Export web exit 0: pck **14.409.256 byte, SHA `db28f2c4…`**
  (trước `e1e4ee94`, +4.312 byte); wasm không đổi `fc74679e…`,
  `GODOT_THREADS_ENABLED = false`; HTTP 200 đủ 4 file (cổng 8178).
- **Browser-verify thật** (Chromium 1255 + swiftshader, 720×1280,
  script `visual-check/artpass24/check_r24.py`, ảnh
  `r24-01…r24-04` + crop xe): **0 console error, 0 pageerror,
  0 requestfailed.** Nhãn debug xác nhận đi xuống tới **Ô (4,8)**
  sau 3×S. Xem ảnh thật: biển gỗ **"PHỞ BÒ" đọc được** treo dưới
  mái hiên kẻ sọc đỏ/trắng của xe đồ ăn; **khói trắng thấy được**
  bay lên từ nồi phở xám trên xe; pixel-diff 2 ảnh zoom cách nhau
  1.5s = **14.955/460.800 pixel khác** (khói + biển + lá động).
  Crop phóng to 2 ảnh cách nhau 1.5s: cụm khói ở vị trí khác nhau,
  biển hơi nghiêng khác nhau.

### 46.4 Deploy — XONG, verify live khớp byte (22/11 ~23:55–00:05 +07)

- Push main 1 lô: code + test + check_r24 `b1267ef1` (trước
  `00596897`). Sync record 235 entries.
- Staging rebuild `build_gh_pages.py` exit 0 (VERIFY OK): pck
  `db28f2c4` 107 chunk / 14.409.256 byte khớp byte, wasm
  `fc74679e` 293 chunk không đổi, img khớp, loader đủ.
  Đối chiếu trước deploy: gh-pages head `85f190c8`,
  `versions.json` live pin `e1e4ee94` (vòng 23), không divergence.
- Deploy 7 lô gh-pages: part 000–019 `413a82dd`, 020–039
  `2246e1eb`, 040–059 `54dcfa75`, 060–079 `08834a25`, 080–099
  `7e87273d`, 100–106 `8322bfcf`, versions.json + index.html cuối
  `97bdeb66`. Sync record 242 entries. Không gián đoạn lần nào.
- Verify live bằng byte: pin `db28f2c4` sau lag Pages ~45 giây;
  tải + giải base64 + ráp 107 part từ live = **14.409.256 byte,
  SHA `db28f2c4b5f5` — khớp đúng từng byte**; index.html live
  liệt kê part `db28f2c4`.
- **Live nay chạy vòng 24**: biển phở đung đưa + khói nồi phở rõ
  hơn. Link: https://tinnt120899.github.io/pho-xo-bo/
- **Kiểm live cloud browser — XONG (23/11 00:05–00:12 +07,
  browser task 4b96032b, 6 phút):** game tải được, nút "BẮT ĐẦU
  CHƠI" enable sau ~10s rồi bấm được, vào Map001 "Xóm Trọ Cũ"
  đúng HUD. Di chuyển đọc nhãn debug: spawn (4,5); D→(5,5),
  A→(4,5), S→(4,6), W→(4,5) — **4 phím đổi đúng từng ô**.
  Xuống đáy map S×3 → (4,8): thấy xe đồ ăn (mái hiên kẻ sọc
  đỏ/trắng, 2 bánh, nồi trên nóc), biển gỗ **"PHỞ BÒ" treo dưới
  mái hiên nghiêng khác nhau qua 3 ảnh cách nhau ~2s** (ngang →
  nghiêng chiều kim đồng hồ → về ngang, biên độ vài độ, đọc bằng
  mắt vì xe chỉ ~55px trên màn hình) và **khói trắng bay từ nồi,
  cụm khói khác vị trí/hình mỗi ảnh**. Không thấy lỗi hiển thị;
  game chạy liên tục không gián đoạn. Hạn chế: checker không mở
  được DevTools nên không khẳng định "0 console error" từ live
  (bản local cùng SHA đã 0 lỗi ở §46.3); trang không hiện số vòng
  deploy nên "vòng 24" chỉ xác minh qua nội dung tính năng, không
  qua số phiên bản. Quan sát thêm chưa xác minh: checker thấy
  biển "PHO BO" quán phía trên + hơi nồi quầy "CÀ PHÊ" cũng đổi
  giữa 2 ảnh — biển mặt tiền nằm trong ảnh tĩnh nên đổi góc là
  khó hiểu, có thể checker đọc nhầm khói/overlay; không sửa code
  theo quan sát này, vòng sau xem lại nếu thấy lại.

### 46.5 Việc tiếp theo

1. Sprite sạp tách riêng (§45.1): khi nào đổi hàng 0 thành sạp
   cách nhau (ô lẻ để trống) thì gen 3 sprite sạp (rau/trái cây/
   cá-thịt) thay code vẽ — việc 2 vòng (artpass sprite + đổi hàng).
2. NPC Map003–018 vẫn ảnh đơn + nhún (chỉ 4 NPC Map001–002 có
   walk cycle): nối `frames` khi có sheet (theo mẫu vòng 22) —
   làm theo từng map (Map003: Anh Ba, Chị Sáu trước).
3. Kiểm live lại bằng cloud browser — ĐANG CHỜ vòng này (§46.4).

## 47. Vòng 25 — Walk cycle NPC Map003: Anh Ba + Chị Sáu (22/11 ~23:20–00:35 +07, cron 23:45)

Mục 2 §46.5: NPC Map003–018 vẫn ảnh đơn + nhún (chỉ 4 NPC Map001–002
có walk cycle). Vòng này làm Map003 trước: Anh Ba (4,6) + Chị Sáu
(8,3), Khu Công Nhân.

### 47.1 Art (subagent, theo đúng quy trình vòng 18/22)

- Ảnh đứng mới `src/godot/art/char_anhba.png` (90×208 RGBA) +
  `char_chisau.png` (95×208 RGBA): Anh Ba — đàn ông trung niên,
  công nhân xưởng, tóc đen ngắn, áo thun xanh dương đậm, quần tối,
  giày thể thao xám; Chị Sáu — phụ nữ trung niên, tóc đen búi thấp,
  áo bà ba xanh lá nhạt có hoa nhỏ, quần đen, dép quai. Cùng phong
  cách chibi watercolor/gouache với `char_cotu.png` (dùng làm tham
  chiếu phong cách). Xử lý trắng → trong suốt bằng flood fill từ
  biên (ngưỡng vòng 22) + feather r=1.5, cao 208px.
- Sheet `visual-check/artpass25/walkcycle-sheet-anhba.png` /
  `walkcycle-sheet-chisau.png` (2736×912, nền trắng trơn): đúng 6
  nhân vật 1 hàng ngang, cùng mặt/tóc/quần áo/giày, chân tiến triển
  hợp lý, tay đung đưa — kiểm tra bằng mắt ĐẠT cả 2, không cần gen
  lại. Hạn chế (chấp nhận như vòng 18/22): chỉ mặt trước; f5≈f0;
  họa tiết hoa áo bà ba Chị Sáu dao động nhẹ giữa các khung.
- Cắt frame bằng `visual-check/artpass25/slice_walkcycle_npc_map003.py`
  (bản sao script vòng 22, NPCS = anhba/chisau): 12 frame RGBA cao
  208px vào `src/godot/art/` — `walk_anhba_f0..f5` (120×208),
  `walk_chisau_f0..f5` (129×208). Dải kiểm tra nền magenta
  `walkcycle-check-magenta-{anhba,chisau}.png`: đủ 6 hình, toàn thân
  nguyên vẹn, không quầng trắng, không cắt tay/chân, chân xen kẽ
  chạm đất ↔ bắt chéo. Note: `visual-check/artpass25/walkcycle-npc-map003-note.md`.
- Lần gen song song đầu tiên cho 2 ảnh đứng bị gián đoạn do service
  restart, không file nào được tạo; gen lại lần lượt từng ảnh thì
  thành công ngay.

### 47.2 Code

| File | Đổi |
|---|---|
| `scripts/marker.gd` | `NPC_STYLE` thêm `"anh-ba"` (shirt xanh dương đậm (0.16,0.24,0.45), hair "ngan", texture `char_anhba.png`, frames `walk_anhba_f0..f5`) + `"chi-sau"` (shirt xanh lá nhạt (0.55,0.72,0.55), hair "bui", texture `char_chisau.png`, frames `walk_chisau_f0..f5`). Không sửa logic `CharacterSprite`/`Marker` — `setup(cfg)` đã ăn `texture` + `frames` từ vòng 18/22. |
| `tests/g4_r25_npc_walk_map003_test.gd` (mới) | 29 mục theo mẫu r22: sprite trực tiếp từng NPC (đủ 6 frame, bước 1 đổi frame 1, hết 0.30s về frame 0, đứng yên frame 0); marker đơn lẻ (home_tile đúng (4,6)/(8,3), có walk frames, walk_to 0.30s/o); Main load_map(3) (2 marker có walk frames + đúng nhà, pick patrol từ nhà Anh Ba hợp lệ). |
| `tools/godot/run_regression.sh` | Thêm `g4_r25_npc_walk_map003_test` (nay 53 suite + online). |
| `visual-check/artpass25/check_r25.py` (mới) | Theo mẫu check_r22.py, cổng 8179: Map001→Map002 (cửa (5,4))→Map003 (cửa (5,8)), đi xa lên (4,1), chờ patrol 12s, 2 ảnh cách nhau 2s để đo pixel-diff. |

### 47.3 Verify thật vòng này

- Test mới `g4_r25_npc_walk_map003_test`: **29/29 PASS** (lần đầu).
- Hồi quy đầy đủ: **53 OK, 0 FAIL** (52 cũ + 1 mới r25).
- Smoke `--headless --quit-after 120` exit 0, 0 ERROR/warning.
- Export web exit 0 (đường dẫn tuyệt đối, KHÔNG `rm -rf` build theo
  luật vòng 24 — asset DOM shell còn nguyên): pck **14.884.728 byte,
  SHA `af16fef1…`** (trước `db28f2c4`, +475.472 byte = 14 file art
  mới); wasm không đổi `fc74679e…`, `GODOT_THREADS_ENABLED = false`;
  HTTP 200 đủ 4 file (cổng 8179, gồm `title_bg.jpg`).
- **Browser-verify thật** (Chromium 1255 + swiftshader, 720×1280,
  script `visual-check/artpass25/check_r25.py`, ảnh `r25-01…r25-04`):
  **0 console error, 0 pageerror, 0 requestfailed.** Xem ảnh thật:
  Map003 "Khu Công Nhân" — Anh Ba (áo xanh dương đậm, mặt thật) +
  Chị Sáu (áo bà ba xanh lá, mặt thật) hiện rõ có nhãn tên, không
  còn vẽ code; người chơi đi (5,4)→(5,1) đúng ô theo nhãn debug;
  sau 12s xa nhà, **Chị Sáu đã patrol rời nhà (8,3) lên giữa map**,
  Anh Ba cũng rời nhà (khuất sau D-pad ở mép trái); pixel-diff 2
  ảnh Map003 cách nhau 2s = **9.003/921.600 pixel khác** (NPC
  bob/buộc + lá rơi động).

### 47.4 CHẶN — push main + deploy gh-pages CHƯA XONG (push_files hỏng)

- Push main lô A (4 file code+test) gián đoạn lần 1 ("service
  restarted while it was running"), head vẫn `333eba2f`; retry lần 2
  gián đoạn y hệt; push thăm dò 1 file (`marker.gd`) lần 3 cũng gián
  đoạn — **đường ghi push_files hỏng hẳn lúc này, đường đọc vẫn
  chạy** (list_commits OK). ĐÃ DỪNG retry trong lượt (theo bài học
  vòng 21: fail ngắt quãng thì retry 1–2 lần/lô là đủ; 3 lần liên
  tiếp kể cả file đơn = dịch vụ hỏng, không phải lô lớn).
- Manifest sẵn sàng: `~/workspace/pxb-push-r25-paths-a` (4 file
  code+test), `-b` (14 file `.import`), `-c` (4 file text
  visual-check), probe `pxb-push-r25-probe` (1 file). Sync record
  KHÔNG đổi (chưa có commit nào được xác nhận).
- Deploy gh-pages CHƯA làm (cùng đường push_files): staging chưa
  rebuild — vòng sau rebuild staging cho pck `af16fef1` rồi deploy
  1 lần sau khi push main hồi.
- Kiểm live cloud browser CHƯA làm (live vẫn chạy vòng 24
  `db28f2c4`; kiểm lúc này chỉ xác minh bản cũ, không phải vòng 25).
- Code + art an toàn ở local, không mất: 14 PNG mới chỉ sống local +
  trong pck `af16fef1` đã export (như mọi art trước — PNG không push
  được qua snapshot-push, chỉ `.import` text lên main).

### 47.5 Việc tiếp theo

1. **Retry push main (3 lô r25) → deploy gh-pages pck `af16fef1` →
   verify live khớp byte → kiểm live cloud browser** (Map003: Anh Ba
   + Chị Sáu đi patrol bằng art thật).
2. NPC Map004–018 walk cycle theo từng map (Map004: Bác Tài, Anh Bốc
   Vác — cần ảnh đứng + sheet mới, theo mẫu vòng này).
3. Sprite sạp tách riêng (§45.1): đổi hàng 0 thành sạp cách nhau (ô
   lẻ để trống) rồi gen 3 sprite sạp (rau/trái cây/cá-thịt).

### 47.6 Retry push lần 2 — VẪN CHẶN (cron 07:45, chạy ~08:00–08:20 23/11)

- Retry push main lô A 2 lần + push thăm dò 1 file (marker.gd) 1 lần:
  cả 3 đều gián đoạn y hệt ("service restarted while it was running"),
  head main vẫn `333eba2f`, sync record không đổi. Tổng cộng 7 lần
  gián đoạn liên tiếp cho vòng 25 (4 lần lúc 00:20–00:40 + 3 lần lượt
  này). Đường đọc vẫn chạy (list_commits OK), auth GitHub connected.
  **DỪNG retry push trong lượt này** (theo bài học §47.4 — 3 lần liên
  tiếp kể cả file đơn = dịch vụ hỏng, không phải lô lớn).
- Đã làm bù trong lượt (không cần push): rebuild staging gh-pages cho
  pck `af16fef1` (staging trước đó vẫn `db28f2c4` vòng 24) —
  `build_gh_pages.py` + `--verify-only` đều OK, `versions.json` nay
  pck `af16fef1`, wasm `fc74679e` không đổi; hồi quy baseline
  **53 OK, 0 FAIL** (cây hiện tại vẫn xanh trước vòng 26).
- Deploy gh-pages + kiểm live cloud vẫn CHƯA làm (cùng đường
  push_files hỏng). Khi dịch vụ hồi: push main 3 lô r25 (manifest
  `~/workspace/pxb-push-r25-paths-{a,b,c}`) → push docs → deploy
  staging `af16fef1` (đã rebuild sẵn, chỉ cần push chunk version
  mới + index.html cuối) → verify live khớp byte → kiểm live cloud.

## 48. Vòng 26 — Walk cycle NPC Map004: Bác Tài + Anh Bốc Vác (23/11 ~08:20 +07, cron 07:45)

Mục 2 §47.5: NPC Map004–018 walk cycle theo từng map. Vòng này làm
Map004 Bến Xe Miền Đông trước: Bác Tài (3,2) + Anh Bốc Vác (8,6).

### 48.1 Art (subagent, theo đúng quy trình vòng 18/22/25) — XONG

- Thư mục `visual-check/artpass26/`; ảnh đứng + sheet 6 khung cho
  Bác Tài (tài xế xe khách lớn tuổi, áo sơ mi xanh nhạt) + Anh Bốc
  Vác (thanh niên khỏe, áo thun trắng, khăn vắt vai); xử lý trắng →
  trong suốt + cắt frame theo mẫu Vòng 25.
- File đích: `src/godot/art/char_bactai.png` (97×208) +
  `char_anhbocvac.png` (90×208), `walk_bactai_f0..f5.png`
  (115×208) + `walk_anhbocvac_f0..f5.png` (123×208), RGBA.
- Kiểm tra bằng mắt: sheet Bác Tài gen lại 1 lần (lần 1 chân 6 pha
  gần như giống nhau); sheet Anh Bốc Vác đạt ngay lần 1; ảnh đứng
  Anh Bốc Vác gen lại 1 lần (lần 1 thừa vali). Dải magenta sạch,
  không quầng trắng. Hạn chế: chỉ mặt trước (thực tế 3/4); f5 Bác
  Tài gần như đứng yên; khăn vai dao động nhẹ giữa các khung. Bài
  học: prompt sheet Vòng 25 chưa đủ ép 6 pha khác nhau — đã bổ
  sung mô tả 6 pha rõ rệt vào prompt, dùng luôn cho các vòng sau.

### 48.2 Code + test — XONG

- `marker.gd` NPC_STYLE thêm `"bac-tai"` (áo xanh nhạt
  (0.55,0.75,0.90), tóc "ngan", texture + frames) +
  `"anh-boc-vac"` (áo trắng (0.95,0.95,0.95), tóc "ngan").
  Không sửa logic `CharacterSprite`/`Marker`.
- Test mới `tests/g4_r26_npc_walk_map004_test.gd`: **29/29 PASS**
  (theo mẫu r25: sprite trực tiếp từng NPC, marker home_tile
  (3,2)/(8,6), Main load_map(4) + pick patrol từ nhà Bác Tài).
- `tools/godot/run_regression.sh` thêm test mới (nay 54 suite).

### 48.3 Verify thật vòng này

- Hồi quy đầy đủ: **54 OK, 0 FAIL** (53 cũ + 1 mới r26).
- Smoke `--headless --quit-after 120` exit 0.
- Export web exit 0: pck **15.358.560 byte, SHA `d33bd266…`**
  (trước `af16fef1`, +473.832 byte = 14 file art mới); wasm không
  đổi `fc74679e…`, `GODOT_THREADS_ENABLED = false`; HTTP 200 đủ 5
  file (cổng 8180, gồm `title_bg.jpg`).
- **Browser-verify thật** (Chromium 1255 + swiftshader, 720×1280,
  script `visual-check/artpass26/check_r26.py`, ảnh `r26-01…r26-05`):
  **0 console error, 0 pageerror, 0 requestfailed.** Xem ảnh thật:
  Map004 "Bến Xe Miền Đông" — Bác Tài (áo sơ mi xanh nhạt, tóc
  điểm bạc) + Anh Bốc Vác (áo thun trắng, khăn vắt vai) hiện rõ
  có nhãn tên, không còn vẽ code; người chơi đi (5,4)→(10,1) đúng
  ô theo nhãn debug; sau 12s xa nhà, **cả 2 NPC đều patrol rời
  nhà** (Bác Tài ra mép trái map, Anh Bốc Vác khuất sau D-pad);
  pixel-diff 2 ảnh Map004 cách nhau 2s = **26.185**.
- Lỗi tìm ra khi xem ảnh: không có lỗi chặn — Anh Bốc Vác khuất
  sau D-pad ở mép trái là do patrol ra sát biên + camera theo
  người chơi (cosmetic, đã biết từ các vòng trước).

### 48.4 Deploy — CHƯA LÀM (push_files vẫn hỏng)

- Staging đã rebuild cho pck `d33bd266` (`--verify-only` OK).
- Push main + deploy gh-pages CHƯA làm: đường ghi push_files hỏng
  từ vòng 25 (7 lần gián đoạn liên tiếp; lượt này đã dừng retry
  sau 3 lần — xem §47.6). Manifest sẵn sàng cho vòng sau:
  `~/workspace/pxb-push-r26-paths-{a,b,c}` + `pxb-push-docs-r26`
  (docs/godot-g4.md + docs/roles-qc.md, gồm cả cập nhật vòng 25
  chưa push). Khi dịch vụ hồi: push r25 (3 lô) → push r26 (3 lô)
  → push docs → deploy staging `d33bd266` → verify live khớp byte
  → kiểm live cloud browser.

### 48.5 Việc tiếp theo

1. **Push main (r25 + r26) + deploy gh-pages pck `d33bd266` →
   verify live khớp byte → kiểm live cloud browser** (Map004:
   Bác Tài + Anh Bốc Vác đi patrol bằng art thật).
2. NPC Map005 walk cycle (Thầy Giáo + Sinh Viên Làm Thêm) theo
   từng map, mẫu vòng này (prompt sheet đã bổ sung 6 pha rõ rệt).
3. Sprite sạp tách riêng (§45.1): đổi hàng 0 thành sạp cách nhau
   (ô lẻ để trống) rồi gen 3 sprite sạp (rau/trái cây/cá-thịt).

## 49. Vòng 27 — Walk cycle NPC Map005: Thầy Giáo + Sinh Viên Làm Thêm (23/11 ~16:15 +07, cron 14:45)

Mục 2 §48.5: NPC Map005–018 walk cycle theo từng map. Vòng này làm
Map005 Làng Đại Học: Thầy Giáo (3,3) + Sinh Viên Làm Thêm (8,6).

### 49.1 Push/deploy — VẪN CHẶN (thử lại đầu lượt, lần thứ 8)

- Đầu lượt thử push main r25 lô A 1 lần: gián đoạn y hệt
  ("service restarted while it was running") — tổng 8 lần gián đoạn
  liên tiếp cho đường ghi push_files (4 lần vòng 25 + 3 lần vòng 26 +
  1 lần lượt này). Kiểm tra lại head main vẫn `333eba2f`, sync
  record không đổi — push không áp dụng một phần. **DỪNG retry push
  trong lượt này** (luật §47.4). Đường đọc vẫn chạy (list_commits OK).
- Deploy gh-pages + kiểm live cloud vẫn CHƯA làm (cùng đường ghi
  hỏng). Live vẫn chạy vòng 24 `db28f2c4`.

### 49.2 Art (subagent, theo đúng quy trình vòng 25/26) — XONG, 0 lần gen lại

- Thư mục `visual-check/artpass27/`; ảnh đứng + sheet 6 khung cho
  Thầy Giáo (giáo viên nam trung niên, đeo kính, áo sơ mi be dài
  tay, quần dài tối màu) + Sinh Viên Làm Thêm (nữ sinh viên trẻ,
  tóc đuôi ngựa, áo thun vàng nhạt, quần jeans, giày thể thao
  trắng); xử lý trắng → trong suốt + cắt frame theo mẫu vòng 26.
- File đích: `src/godot/art/char_thaygiao.png` (97×208) +
  `char_sinhvien.png` (92×208), `walk_thaygiao_f0..f5.png`
  (144×208) + `walk_sinhvienlamthem_f0..f5.png` (120×208, đúng tên
  theo id `sinh-vien-lam-them` bỏ dấu gạch nối), RGBA.
- Kiểm tra bằng mắt: 2 ảnh đứng + 2 sheet đều ĐẠT ngay lần đầu
  (đúng 6 nhân vật, nền trắng trơn, không chữ, không thừa đồ vật,
  6 pha chân khác nhau rõ); dải magenta sạch, không quầng trắng.
- Một sửa script so với vòng 26: sheet Sinh Viên có 2 đốm xám lẻ
  trong nền trắng khiến lần cắt đầu báo 8 run thay vì 6 — đã thêm
  bộ lọc bỏ run hẹp <20px vào `slice_walkcycle_npc_map005.py`
  (nhân vật thật rộng 360–460px); lần sửa đầu đặt bộ lọc sau câu
  raise nên vẫn lỗi — đã sửa lại đặt trước, cắt lại thành công.
- Hạn chế thấy bằng mắt: chỉ mặt trước (3/4); f5 cả hai gần như
  tư thế đứng; f1/f2/f3 Sinh Viên là 3 tư thế bắt chéo/khép khá gần
  nhau, ít sải hơn Thầy Giáo nhưng vẫn phân biệt được khi chạy;
  đuôi ngựa Sinh Viên hơi lệch sang một bên thay vì chính giữa.

### 49.3 Code + test — XONG

- `marker.gd` NPC_STYLE thêm `"thay-giao"` (áo be
  (0.85,0.78,0.62), tóc "ngan", texture + frames) +
  `"sinh-vien-lam-them"` (áo vàng nhạt (0.95,0.85,0.35), tóc
  "dai", texture + frames). Không sửa logic `CharacterSprite`/
  `Marker`.
- Test mới `tests/g4_r27_npc_walk_map005_test.gd`: **29/29 PASS**
  (theo mẫu r26: sprite trực tiếp từng NPC, marker home_tile
  (3,3)/(8,6), Main load_map(5) + pick patrol từ nhà Thầy Giáo).
- `tools/godot/run_regression.sh` thêm test mới (nay 55 suite).

### 49.4 Verify thật vòng này

- Hồi quy đầy đủ: **55 OK, 0 FAIL** (54 cũ + 1 mới r27).
- Smoke `--headless --quit-after 120` exit 0.
- Export web exit 0: pck **15.824.284 byte, SHA `986681e7`**
  (trước `d33bd266`, +465.724 byte = 14 file art mới); wasm không
  đổi `fc74679e…`, `GODOT_THREADS_ENABLED = false`; HTTP 200 đủ 5
  file (cổng 8181, gồm `title_bg.jpg`).
- **Browser-verify thật** (Chromium 1255 + swiftshader, 720×1280,
  script `visual-check/artpass27/check_r27.py`, ảnh `r27-01…r27-06`):
  **0 console error, 0 pageerror, 0 requestfailed.** Xem ảnh thật:
  Map005 "Làng Đại Học" — Thầy Giáo (đeo kính, áo sơ mi be) +
  Sinh Viên Làm Thêm (áo vàng nhạt, tóc đuôi ngựa) hiện rõ có nhãn
  tên, không còn vẽ code; người chơi đi (5,4)→(10,1) đúng ô theo
  nhãn debug; sau 12s xa nhà, **cả 2 NPC đều patrol rời nhà**
  (Thầy Giáo ra mép trái map, Sinh Viên khuất sau D-pad);
  pixel-diff 2 ảnh Map005 cách nhau 2s = **22.796**.
- Lỗi tìm ra khi xem ảnh: không có lỗi chặn — Sinh Viên khuất sau
  D-pad ở mép trái là do patrol ra sát biên + camera theo người
  chơi (cosmetic, đã biết từ các vòng trước); nhãn "Sinh Viên Làm
  Thêm" che một phần thân Thầy Giáo khi 2 NPC đứng gần nhau
  (cosmetic, đã biết).

### 49.5 Deploy — CHƯA LÀM (push_files vẫn hỏng)

- Staging đã rebuild cho pck `986681e7` (`--verify-only` OK).
- Push main + deploy gh-pages CHƯA làm: đường ghi push_files hỏng
  từ vòng 25 (8 lần gián đoạn liên tiếp; lượt này đã dừng retry
  sau 1 lần — xem §49.1). Manifest sẵn sàng cho vòng sau:
  `~/workspace/pxb-push-r27-paths-{a,b,c}` + `pxb-push-docs-r27`
  (docs/godot-g4.md + docs/roles-qc.md, gồm cả cập nhật vòng 25/26
  chưa push). Khi dịch vụ hồi: push r25 (3 lô) → push r26 (3 lô)
  → push r27 (3 lô) → push docs → deploy staging `986681e7` →
  verify live khớp byte → kiểm live cloud browser.

### 49.6 Việc tiếp theo

1. **Push main (r25 + r26 + r27) + deploy gh-pages pck `986681e7` →
   verify live khớp byte → kiểm live cloud browser** (Map005:
   Thầy Giáo + Sinh Viên Làm Thêm đi patrol bằng art thật).
2. NPC Map006 walk cycle (Cư Dân Chung Cư + Bác Quản Lý) theo
   từng map, mẫu vòng này.
3. Sprite sạp tách riêng (§45.1): đổi hàng 0 thành sạp cách nhau
   (ô lẻ để trống) rồi gen 3 sprite sạp (rau/trái cây/cá-thịt).

## 50. Vòng 28 — Walk cycle NPC Map006: Cư Dân Chung Cư + Bác Quản Lý (23/11 ~16:45–18:45 +07, cron 16:45)

Mục 2 §49.6: NPC Map006–018 walk cycle theo từng map. Vòng này làm
Map006 Chung Cư Cũ: Cư Dân Chung Cư (3,6) + Bác Quản Lý (8,3).

### 50.1 Push/deploy — VẪN CHẶN (thử lại đầu lượt, lần thứ 9)

- Đầu lượt thử push main r25 lô A 1 lần: gián đoạn y hệt
  ("service restarted while it was running") — tổng 9 lần gián đoạn
  liên tiếp cho đường ghi push_files (4 lần vòng 25 + 3 lần vòng 26 +
  1 lần vòng 27 + 1 lần lượt này). Kiểm tra lại head main vẫn
  `333eba2f`, sync record không đổi — push không áp dụng một phần.
  **DỪNG retry push trong lượt này** (luật §47.4). Đường đọc vẫn chạy
  (list_commits OK).
- Deploy gh-pages + kiểm live cloud vẫn CHƯA làm (cùng đường ghi
  hỏng). Live vẫn chạy vòng 24 `db28f2c4`.

### 50.2 Art (subagent, theo đúng quy trình vòng 25/26/27) — XONG, 0 lần gen lại

- Thư mục `visual-check/artpass28/`; ảnh đứng + sheet 6 khung cho
  Cư Dân Chung Cư (nam trung niên, áo thun xám, quần kaki tối,
  dép) + Bác Quản Lý (ông lớn tuổi, tóc bạc, áo sơ mi xanh nhạt
  ngắn tay, quần dài tối, giày đen); xử lý trắng → trong suốt +
  cắt frame theo mẫu vòng 27.
- File đích: `src/godot/art/char_cudanchungcu.png` (90×208) +
  `char_bacquanly.png` (92×208), `walk_cudanchungcu_f0..f5.png`
  (canvas chung 132×208) + `walk_bacquanly_f0..f5.png` (canvas
  chung 128×208), RGBA.
- Kiểm tra bằng mắt: 2 ảnh đứng + 2 sheet đều ĐẠT ngay lần đầu
  (đúng 6 nhân vật, nền trắng trơn, không chữ, không thừa đồ vật,
  6 pha chân khác nhau rõ); dải magenta sạch, không quầng trắng.
- **Bài học mới — cắt sheet bằng connected component:**
  cắt sheet Cư Dân lần đầu chỉ tìm được 5 run cột — tay trái giơ
  cao của hình f0 (nắm đấm x≈460–510) chồng lấn theo chiều ngang
  với tóc hình f1 (x≈480+), dù hai hình rời nhau trong 2D.
  `slice_walkcycle_npc_map006.py` đổi sang tách connected
  component (`scipy.ndimage.label`), mỗi hình mask riêng rồi mới
  crop — nắm đấm vẫn thuộc về hình f0, không bị cắt sang hình f1.
  Bộ lọc bỏ component hẹp <20px vẫn đặt TRƯỚC khi kiểm tra đủ 6
  hình (bài học vòng 27; sheet Cư Dân có 6 đốm 1px).
- Hạn chế thấy bằng mắt: chỉ mặt trước (3/4); f5 cả hai gần như
  tư thế đứng; f2/f3/f4 của Bác Quản Lý khá gần nhau (3 tư thế
  bắt chéo/khép), ít "sải" hơn Cư Dân; tay trái f0 của Cư Dân
  giơ cao ngang vai — đung đưa mạnh hơn các NPC vòng trước, vẫn
  trong nhịp đi bộ; áo Bác Quản Lý gen ra kiểu cổ trụ khuy bấm
  (gần áo dài cách tân) thay vì sơ mi cổ bẻ thường; mặt Cư Dân
  trông trẻ hơn "trung niên" (~30 tuổi) — cả hai đều chấp nhận
  được. Chi tiết: `visual-check/artpass28/walkcycle-npc-map006-note.md`.

### 50.3 Code + test — XONG

- `marker.gd` NPC_STYLE thêm `"cu-dan-chung-cu"` (áo xám
  (0.55,0.55,0.58), tóc "ngan", texture + frames) +
  `"bac-quan-ly"` (áo xanh nhạt (0.62,0.78,0.85), tóc "ngan",
  texture + frames). Không sửa logic `CharacterSprite`/
  `Marker`.
- Test mới `tests/g4_r28_npc_walk_map006_test.gd`: **29/29 PASS**
  (theo mẫu r27: sprite trực tiếp từng NPC, marker home_tile
  (3,6)/(8,3), Main load_map(6) + pick patrol từ nhà Cư Dân).
- `tools/godot/run_regression.sh` thêm test mới (nay 56 suite).
- **Lỗi gặp khi test lần đầu (15/29):** `ResourceLoader.exists`
  báo file art mới không tồn tại dù file đã có trên đĩa — do
  chưa chạy `--headless --import` nên chưa có file `.import`.
  Chạy `--import` (tự sinh 14 file `.import`) rồi test lại thì
  29/29. Đúng bài học §8.3: gặp lỗi lạ thì `--import` trước rồi
  mới kết luận code hỏng.

### 50.4 Verify thật vòng này

- Hồi quy đầy đủ: **56 OK, 0 FAIL** (55 cũ + 1 mới r28).
- Smoke `--headless --quit-after 120` exit 0.
- Export web exit 0: pck **16.291.172 byte, SHA `c6461bde`**
  (trước `986681e7`, +466.888 byte = 14 file art mới); wasm không
  đổi `fc74679e…`, `GODOT_THREADS_ENABLED = false`; HTTP 200 đủ 5
  file (cổng 8182, gồm `title_bg.jpg`).
- **Browser-verify thật** (Chromium 1255 + swiftshader, 720×1280,
  script `visual-check/artpass28/check_r28.py`, ảnh `r28-01…r28-07`):
  **0 console error, 0 pageerror, 0 requestfailed.** Xem ảnh thật:
  Map006 "Chung Cư Cũ" — Cư Dân Chung Cư (áo thun xám) + Bác Quản
  Lý (áo xanh nhạt, tóc bạc) hiện rõ mặt thật có nhãn tên, không
  còn vẽ code; người chơi đi (5,4)→(10,1) đúng ô theo nhãn debug;
  sau 12s xa nhà, **Bác Quản Lý patrol rời nhà ra mép trái map**;
  pixel-diff 2 ảnh Map006 cách nhau 2s = **4.557**.
- Lỗi tìm ra khi xem ảnh: không có lỗi chặn — D-pad đè lên cửa
  ở mép trái khi camera sang phải (cosmetic, đã biết từ các vòng
  trước); nhãn 2 cửa đáy map xếp chồng dọc, không đè nhau.
- Staging đã rebuild cho pck `c6461bde` (`build_gh_pages.py`
  verify OK: wasm 293 chunk + pck 121 chunk khớp byte).

### 50.5 Deploy — CHƯA LÀM (push_files vẫn hỏng)

- Push main + deploy gh-pages CHƯA làm: đường ghi push_files hỏng
  từ vòng 25 (9 lần gián đoạn liên tiếp; lượt này đã dừng retry
  sau 1 lần — xem §50.1). Manifest sẵn sàng cho vòng sau:
  `~/workspace/pxb-push-r28-paths-{a,b,c}` + `pxb-push-docs-r28`
  (docs/godot-g4.md + docs/roles-qc.md, gồm cả cập nhật vòng
  25/26/27/28 chưa push). Khi dịch vụ hồi: push r25 (3 lô) →
  push r26 (3 lô) → push r27 (3 lô) → push r28 (3 lô) → push
  docs → deploy staging `c6461bde` → verify live khớp byte →
  kiểm live cloud browser.

### 50.6 Việc tiếp theo

1. **Push main (r25 + r26 + r27 + r28) + deploy gh-pages pck `c6461bde` →
   verify live khớp byte → kiểm live cloud browser** (Map006:
   Cư Dân Chung Cư + Bác Quản Lý đi patrol bằng art thật).
2. NPC Map007 walk cycle (Phố Văn Phòng Nhỏ: 2 NPC của map 7) theo
   từng map, mẫu vòng này.
3. Sprite sạp tách riêng (§45.1): đổi hàng 0 thành sạp cách nhau
   (ô lẻ để trống) rồi gen 3 sprite sạp (rau/trái cây/cá-thịt).

## 51. Vòng 29 — Walk cycle NPC Map007: Nhân Viên Văn Phòng + Thực Tập Sinh (23/11 ~18:45–20:20 +07, cron 18:45)

Mục 2 §49.6: NPC Map006–018 walk cycle theo từng map. Vòng này làm
Map007 Phố Văn Phòng Nhỏ: Nhân Viên Văn Phòng (3,3) + Thực Tập Sinh (8,6).

### 51.1 Push/deploy — VẪN CHẶN (thử lại đầu lượt, lần thứ 10)

- Đầu lượt thử push main r25 lô A 1 lần: gián đoạn y hệt
  ("service restarted while it was running") — tổng 10 lần gián đoạn
  liên tiếp cho đường ghi push_files (4 lần vòng 25 + 3 lần vòng 26 +
  1 lần vòng 27 + 1 lần vòng 28 + 1 lần lượt này). Kiểm tra lại head
  main vẫn `333eba2f`, sync record không đổi — push không áp dụng
  một phần. **DỪNG retry push trong lượt này** (luật §47.4). Đường đọc
  vẫn chạy (list_commits OK).
- Deploy gh-pages + kiểm live cloud vẫn CHƯA làm (cùng đường ghi
  hỏng). Live vẫn chạy vòng 24 `db28f2c4`.

### 51.2 Art (subagent, theo đúng quy trình vòng 25/26/27/28) — XONG

- Thư mục `visual-check/artpass29/`; ảnh đứng + sheet 6 khung cho
  Nhân Viên Văn Phòng (nam thanh niên, áo sơ mi trắng dài tay, quần
  tây tối, giày đen) + Thực Tập Sinh (nữ trẻ, áo sơ mi xanh nhạt,
  quần dài tối, giày đen, tóc đuôi ngựa); xử lý trắng → trong suốt +
  cắt frame theo mẫu vòng 28 (connected component).
- File đích: `src/godot/art/char_nhanvienvanphong.png` (90×208) +
  `char_thuctapsinh.png` (92×208), `walk_nhanvienvanphong_f0..f5.png`
  (canvas chung 137×208) + `walk_thuctapsinh_f0..f5.png` (canvas
  chung 138×208), RGBA.
- Kiểm tra bằng mắt: 2 ảnh đứng ĐẠT ngay lần đầu (0 lần gen lại);
  sheet Thực Tập Sinh ĐẠT ngay lần đầu; **sheet Nhân Viên lần đầu
  lỗi** — hình f5 là nữ đi giày cao gót, sai hẳn nhân vật; sửa bằng
  resume snapshot chỉ vẽ lại hình 6 thành đúng nam nhân viên (áo
  trắng, quần tối, giày đen, chân khép) — **1 lần gen lại**, 5 hình
  còn lại giữ nguyên. Dải magenta cả 2 sạch, không quầng trắng.
- **Bài học mới — ngưỡng lọc đốm khi cắt sheet:** lần cắt đầu sheet
  Nhân Viên tìm được 8 component thay vì 6 — 2 đốm tối 24–26px lọt
  qua ngưỡng lọc cũ `MIN_FIG_W = 20`. `slice_walkcycle_npc_map007.py`
  nâng ngưỡng lên 100 (hình thật rộng 368–421px nên an toàn).
  Sheet Thực Tập Sinh không có đốm. Bộ lọc vẫn đặt TRƯỚC khi kiểm
  tra đủ 6 hình (bài học vòng 27/28).
- Hạn chế thấy bằng mắt: chỉ mặt trước (3/4); f5 cả hai gần như tư
  thế đứng; f2/f3/f4 khá gần nhau; áo Thực Tập Sinh gen ra kiểu cổ
  trụ khuy bấm (như Bác Quản Lý vòng 28) thay vì sơ mi cổ bẻ; tay
  trái f0 Nhân Viên giơ cao ngang vai; mặt Nhân Viên trông trẻ
  (~20 tuổi); Nhân Viên có khuyên tai vàng nhỏ không có trong mô tả
  — tất cả chấp nhận được. Chi tiết:
  `visual-check/artpass29/walkcycle-npc-map007-note.md`.

### 51.3 Code + test — XONG

- `marker.gd` NPC_STYLE thêm `"nhan-vien-van-phong"` (áo trắng
  (0.95,0.95,0.95), tóc "ngan", texture + frames) +
  `"thuc-tap-sinh"` (áo xanh nhạt (0.70,0.82,0.95), tóc "dai",
  texture + frames). Không sửa logic `CharacterSprite`/`Marker`.
- Test mới `tests/g4_r29_npc_walk_map007_test.gd`: **29/29 PASS**
  (theo mẫu r28: sprite trực tiếp từng NPC, marker home_tile
  (3,3)/(8,6), Main load_map(7) + pick patrol từ nhà Nhân Viên
  Văn Phòng).
- `tools/godot/run_regression.sh` thêm test mới (nay 57 suite).

### 51.4 Verify thật vòng này

- Hồi quy đầy đủ: **57 OK, 0 FAIL** (56 cũ + 1 mới r29).
- Smoke `--headless --quit-after 120` exit 0.
- **Lỗi export lần đầu:** lệnh export dùng đường dẫn
  `src/godot-build/index.html` (tương đối từ thư mục repo) nên
  Godot hiểu thành `src/godot/src/godot-build` không tồn tại —
  export fail, pck trên đĩa vẫn là bản cũ vòng 28 (`c6461bde`).
  Chạy lại đúng đường dẫn `../godot-build/index.html` (tương đối
  từ `src/godot`, theo `export_presets.cfg`) thì exit 0. Bài học:
  luôn kiểm tra SHA pck sau export, đừng tin exit code của lần
  chạy gộp khi lệnh sau che mất lỗi lệnh trước.
- Export web exit 0: pck **16.756.776 byte, SHA `e1919a27`**
  (trước `c6461bde`, +465.604 byte = 14 file art mới); wasm không
  đổi `fc74679e…`, `GODOT_THREADS_ENABLED = false`; HTTP 200 đủ 5
  file (cổng 8183, gồm `title_bg.jpg`).
- **Browser-verify thật** (Chromium 1255 + swiftshader, 720×1280,
  script `visual-check/artpass29/check_r29.py`, ảnh `r29-01…r29-08`):
  **0 console error, 0 pageerror, 0 requestfailed.** Xem ảnh thật:
  đi chuỗi Map001→Map007 qua đúng cửa (5,4)/(5,8) từng map; Map007
  "Phố Văn Phòng Nhỏ" — Nhân Viên Văn Phòng (áo trắng) + Thực Tập
  Sinh (áo xanh nhạt, tóc đuôi ngựa) hiện rõ mặt thật có nhãn tên,
  không còn vẽ code; người chơi đi tới (10,1) đúng ô theo nhãn
  debug; 2 ảnh xa nhà cách nhau 2s pixel-diff = **19.371** (lá rơi
  + mây + NPC bob, cảnh sống).
- Lỗi tìm ra khi xem ảnh (cosmetic, không chặn): nhãn "Thực Tập
  Sinh" đè lên người chơi lúc spawn (người chơi đứng sau nhãn);
  toast "Đã sang Phố Văn Phòng Nhỏ" đè lên nhãn "Cửa đi Khu Chung
  Cư Cao Cấp" ở đáy màn hình; D-pad đè lên cửa ở mép trái (đã biết
  từ các vòng trước).
- Staging đã rebuild cho pck `e1919a27` (`build_gh_pages.py`:
  wasm 293 chunk + pck 125 chunk khớp byte, ảnh khớp byte).

### 51.5 Deploy — ĐÃ LÀM MỘT PHẦN (lượt 24/11 00:45, cron 00:45)

- **Push main r25→r29 + docs XONG trong lượt này:** đường ghi
  push_files đã HỒI sau 10 lần gián đoạn liên tiếp — thử thăm dò
  1 lần đầu lượt thành công ngay (commit `7f008798` lô A r25).
  Tổng 16 commit, head main nay `4bfe5d46bf5c` (docs r25–29):
  r25 `7f008798`/`792e3f00`/`6c7b9400`, r26 `df29a7bf`/`27baaf4a`/
  `9f2512e7`, r27 `2eb3b431`/`4d8f59f2`/`cd8df953`, r28 `7fe17d10`/
  `9bf2eec8`/`ce450514`, r29 `779c4fe0`/`cd8cd4cd`/`30dcb5c9`,
  docs `4bfe5d46`. Chi tiết trong
  `~/workspace/pho-xo-bo.muse-github-snapshot-sync.json` (mục
  244–259). Lỗi duy nhất: 3 manifest vòng 27 viết bằng `\n` thay
  vì `\0` nên push-files từ chối — đã sửa sang NUL rồi đẩy lại
  thành công. Bài học: kiểm tra định dạng manifest bằng `od -c`
  trước khi đẩy (lô r27 là lô duy nhất sai trong 15 lô).
- **Deploy gh-pages pck `e1919a27` DỞ DANG:** staging verify OK
  (`build_gh_pages.py --verify-only` PASS, pck 125 chunk khớp
  byte); chỉ pck mới (wasm + img trùng version với live nên không
  đẩy lại). Đã đẩy 4/8 lô pck (chunk 000–063, commit `ecba525b`,
  `b69296ae`, `2e7c8029`, `8547176c`) — lô 5 (chunk 064–079) bị
  kẹt vì phê duyệt hết thời gian (userConfirmation timed out sau
  ~41 phút chạy chuỗi) → **DỪNG deploy theo hướng dẫn, KHÔNG thử
  lại trong lượt này**. Live KHÔNG ảnh hưởng: index.html +
  versions.json chưa đẩy nên live vẫn pck `db28f2c4` (vòng 24),
  đã verify bằng curl versions.json live sau khi dừng.
- Bài học mới — **giới hạn body MCP 413:** lô 32 chunk (5,76 MB)
  bị `HTTP 413: request body too large` — giới hạn thực tế nằm
  giữa 3,6 MB (20 chunk, từng đẩy được) và 5,76 MB; lô deploy an
  toàn là **16 chunk/lô (~2,88 MB)**. Manifest lô 16-chunk đã
  tạo: `/tmp/pxb-deploy-e1919a27-b1..b8` (b1–b4 đã đẩy, b5–b8 +
  final còn lại). Vòng sau: đẩy tiếp b5–b8 + final rồi chạy
  `build_gh_pages.py --check-live` + kiểm live cloud browser.
  (Manifest lô 32-chunk cũ `/tmp/pxb-deploy-e1919a27-batch1..4`
  bỏ, không dùng.)

### 51.6 Việc tiếp theo

1. **Push main (r25 + r26 + r27 + r28 + r29) + deploy gh-pages pck
   `e1919a27` → verify live khớp byte → kiểm live cloud browser**
   (Map007: Nhân Viên Văn Phòng + Thực Tập Sinh đi patrol bằng
   art thật).
2. NPC Map008 walk cycle (Khu Chung Cư Cao Cấp: 2 NPC của map 8)
   theo từng map, mẫu vòng này.
3. Sprite sạp tách riêng (§45.1): đổi hàng 0 thành sạp cách nhau
   (ô lẻ để trống) rồi gen 3 sprite sạp (rau/trái cây/cá-thịt).

## 52. Vòng 30 — Walk cycle NPC Map008: Cư Dân Cao Cấp + Bảo Vệ Chung Cư (24/11 ~01:30–03:00 +07, cron 00:45)

Mục 2 §51.6: NPC Map008 walk cycle theo từng map. Vòng này làm
Map008 Khu Chung Cư Cao Cấp: Cư Dân Cao Cấp (3,3) + Bảo Vệ Chung Cư (8,6).

### 52.1 Art (subagent, theo đúng quy trình vòng 29) — XONG

- Thư mục `visual-check/artpass30/`; ảnh đứng + sheet 6 khung cho
  Cư Dân Cao Cấp (nữ trung niên khá giả, blouse hồng nhạt, quần âu
  trắng, giày bệt đen, tóc búi cao, túi xách nhỏ) + Bảo Vệ Chung Cư
  (nam trung niên, sơ mi xanh đậm đồng phục có huy hiệu, quần tối,
  giày đen, mũ đồng phục); xử lý trắng → trong suốt + cắt frame
  theo mẫu vòng 29 (connected component, MIN_FIG_W=100).
- File đích: `src/godot/art/char_cudancaocap.png` (78×208) +
  `char_baovechungcu.png` (97×208), `walk_cudancaocap_f0..f5.png`
  (canvas chung 111×208) + `walk_baovechungcu_f0..f5.png` (canvas
  chung 139×208), RGBA.
- Kiểm tra bằng mắt: 2 ảnh đứng + 2 sheet ĐẠT ngay lần đầu (**0 lần
  gen lại**); sheet Bảo Vệ có f0/f1 chồng lấn trục x nhưng tách bằng
  connected component vẫn đúng (bài học vòng 28). Dải magenta cả 2
  sạch, không quầng trắng.
- Hạn chế thấy bằng mắt: chỉ mặt trước (3/4); f5 gần như tư thế
  đứng; f2/f3/f4 khá gần nhau; áo Cư Dân gen ra cổ trụ khuy bấm
  (kiểu áo dài cách tân) thay vì blouse cổ bẻ; mũ Bảo Vệ dạng kê-pi
  có huy hiệu thay vì mũ lưỡi trai; tay f0 Bảo Vệ giơ ngang vai —
  tất cả chấp nhận được. Chi tiết:
  `visual-check/artpass30/walkcycle-npc-map008-note.md`.

### 52.2 Code + test — XONG

- `marker.gd` NPC_STYLE thêm `"cu-dan-cao-cap"` (áo hồng nhạt
  (0.95,0.75,0.80), tóc "bui", texture + frames) +
  `"bao-ve-chung-cu"` (áo xanh đậm (0.15,0.30,0.55), tóc "ngan",
  texture + frames). Không sửa logic `CharacterSprite`/`Marker`.
- Test mới `tests/g4_r30_npc_walk_map008_test.gd`: **29/29 PASS**
  (theo mẫu r29: sprite trực tiếp từng NPC, marker home_tile
  (3,3)/(8,6), Main load_map(8) + pick patrol từ nhà Cư Dân Cao
  Cấp).
- `tools/godot/run_regression.sh` thêm test mới (nay 58 suite).

### 52.3 Verify thật vòng này

- Hồi quy đầy đủ: **58 OK, 0 FAIL** (57 cũ + 1 mới r30).
- Smoke `--headless --quit-after 120` exit 0.
- Export web exit 0: pck **17.193.156 byte, SHA `629ad8b8…`**
  (trước `e1919a27`, +436.380 byte = 14 file art mới); wasm không
  đổi `fc74679e…`, `GODOT_THREADS_ENABLED = false`; HTTP 200 đủ 5
  file (cổng 8184, gồm `title_bg.jpg`).
- **Browser-verify thật** (Chromium 1255 + swiftshader, 720×1280,
  script `visual-check/artpass30/check_r30.py`, ảnh `r30-01…r30-09`):
  **0 console error, 0 pageerror, 0 requestfailed.** Xem ảnh thật:
  đi chuỗi Map001→Map008 qua đúng cửa (5,4)/(5,8) từng map; Map008
  "Khu Chung Cư Cao Cấp" — Cư Dân Cao Cấp (áo hồng nhạt, búi cao,
  túi xách) + Bảo Vệ Chung Cư (đồng phục xanh đậm, mũ) hiện rõ mặt
  thật có nhãn tên, không còn vẽ code; người chơi đi tới (10,1)
  đúng ô theo nhãn debug; cả 2 NPC patrol rời nhà sau 12s xa; 2 ảnh
  xa nhà cách nhau 2s pixel-diff = **22.953** (lá rơi + mây + NPC
  bob, cảnh sống).
- Lỗi tìm ra khi xem ảnh (cosmetic, không chặn): nhãn "Bảo Vệ Chung
  Cư" đè lên thân Cư Dân lúc 2 NPC đứng gần nhau ở spawn; Bảo Vệ
  khuất một phần sau D-pad ở mép trái (đã biết từ các vòng trước).
- Staging CHƯA rebuild cho pck `629ad8b8` (vòng sau rebuild + deploy
  sau khi deploy `e1919a27` xong).

### 52.4 Push — CHƯA XONG (dịch vụ chập chờn trở lại)

- Thử đẩy main r30 lô A 1 lần cuối lượt: gián đoạn ngay ("service
  restarted while it was running") — lần gián đoạn đầu tiên kể từ
  khi dịch vụ hồi đầu lượt (16 commit main + 4 lô deploy đã đẩy
  thành công trước đó trong lượt). Kiểm tra lại: sync record không
  đổi (263 mục, chưa có commit r30 nào được xác nhận); lệnh kiểm
  tra head main cũng gián đoạn theo nên head chưa xác minh được —
  r30-a có thể đã lên GitHub nhưng chưa có SHA xác nhận nên KHÔNG
  ghi nhận. **DỪNG retry push trong lượt này** (luật §47.4).
  Manifest sẵn: `~/workspace/pxb-push-r30-paths-{a,b,c}` +
  `pxb-push-docs-r30` (docs gồm §51.5 cập nhật deploy + §52 vòng
  30). Vòng sau: kiểm tra head main trước rồi đẩy tiếp; nếu r30-a
  đã lên thì chỉ đẩy b/c + docs.
- Deploy gh-pages pck `e1919a27` vẫn dở dang như §51.5 (lô b5–b8 +
  final chưa đẩy); staging CHƯA rebuild cho pck `629ad8b8`.

### 52.6 Cập nhật 24/11 ~11:00 — DEPLOY `e1919a27` XONG, PUSH r30 XONG

- **Deploy gh-pages pck `e1919a27` ĐÃ XONG trong lượt này (cron
  10:45):** manifest lô b5–b8 + final tạo lại (file `/tmp` cũ đã
  mất sau restart VM — tạo mới tại `~/workspace/pxb-deploy-e1919a27-b5..b8`
  + `-final`, kiểm `od -c` NUL đúng); đẩy 5 lô liên tiếp, phê duyệt
  về ngay cả 5 lần (khác hẳn lần trước kẹt 41 phút ở b5): b5 chunk
  064–079 `93093b70`, b6 080–095 `c7c0f93e`, b7 096–111 `73fbfbff`,
  b8 112–124 `fda9430d`, final (versions.json + index.html)
  `829ed44c`. Sync record nay 268 mục. **Live đã chuyển sang pck
  `e1919a27` (vòng 29):** `--check-live` PASS sau khi chờ CDN lan
  (lần kiểm đầu FAIL do versions.json live còn cache `db28f2c4`,
  chunk part-124 404 nhất thời — API gh-pages đã có đủ file, chỉ
  là CDN chưa lan; kiểm lại sau vài phút thì khớp byte).
- **Push main r30 XONG trong lượt này:** lô a (marker.gd + test
  r30 + run_regression.sh) `8d107b0e` + lô b (14 file .import art
  Map008) `07920614` + lô c (visual-check artpass30) `e38e8544` +
  docs (godot-g4.md §52.6 + roles-qc.md hiện trạng mới) — head
  main sau lô docs xem sync record mục cuối.
- **Staging CHƯA rebuild cho pck `629ad8b8`** (vòng sau rebuild +
  deploy pck này → verify live → kiểm live cloud browser Map008).

### 52.7 Cập nhật 24/11 ~11:30 — DEPLOY `629ad8b8` DỞ DANG (4/8 LÔ), DỪNG THEO LUẬT §47.4

- **Staging rebuild cho pck `629ad8b8` XONG:** `build_gh_pages.py`
  chạy lại từ build hiện tại, VERIFY OK (pck 128 chunk khớp byte,
  wasm `fc74679e` + img không đổi, fileSizes khớp); staging
  versions.json nay pck `629ad8b8`.
- **Deploy gh-pages pck `629ad8b8` mới 4/8 lô:** b1 chunk 000–015
  `b19d85f7`, b2 016–031 `c152dfd0`, b3 032–047 `36baa220`, b4
  048–063 `af9be888` (sync record 276 mục). **Lô b5 (064–079) kẹt:
  dịch vụ restart 3 lần liên tiếp ngay trong lúc đẩy (lần 1 +
  retry lần 2 + retry lần 3 đều gián đoạn, head gh-pages vẫn
  `af9be888`, b5 chưa lên)** — DỪNG retry trong lượt này theo luật
  §47.4. Live AN TOÀN: versions.json + index.html chưa đẩy nên
  live vẫn pck `e1919a27` (vòng 29), đã `--check-live` PASS.
  Manifest b5–b8 + final sẵn tại
  `~/workspace/pxb-deploy-629ad8b8-b5..b8` + `-final` (NUL đúng).
  Vòng sau: đẩy tiếp b5–b8 + final → `--check-live` → kiểm live
  cloud browser Map008.
- **Vòng 31 ĐÃ BẮT ĐẦU song song:** art walk cycle NPC Map009
  (Chủ Cửa Hàng + Người Bán Hàng) giao subagent theo mẫu vòng
  29/30 — thư mục `visual-check/artpass31/`, chỉ art + note,
  không sửa code; kết quả về sẽ làm code + test + push sau.

### 52.5 Việc tiếp theo

1. **Đẩy tiếp deploy gh-pages pck `e1919a27` (lô b5–b8 + final) →
   `--check-live` → kiểm live cloud browser** (cần phê duyệt —
   lượt này kẹt ở lô b5 do phê duyệt hết thời gian).
2. Push main r30 (3 lô + docs) + rebuild staging + deploy pck
   `629ad8b8` → verify live.
3. NPC Map009 walk cycle (Phố Thương Mại: 2 NPC của map 9) theo
   từng map, mẫu vòng này.
4. Sprite sạp tách riêng (§45.1): đổi hàng 0 thành sạp cách nhau
   (ô lẻ để trống) rồi gen 3 sprite sạp (rau/trái cây/cá-thịt).

## 53. Vòng 31 — Walk cycle NPC Map009: Chủ Cửa Hàng + Người Bán Hàng (24/11 ~11:00–14:15 +07, cron 10:45 + handoff art)

Mục 3 §52.5: NPC Map009 walk cycle theo từng map. Vòng này làm
Map009 Phố Thương Mại: Chủ Cửa Hàng (3,3) + Người Bán Hàng (8,6).

### 53.1 Art (subagent, theo đúng quy trình vòng 29/30) — XONG

- Thư mục `visual-check/artpass31/`; ảnh đứng + sheet 6 khung cho
  Chủ Cửa Hàng (nam trung niên, áo xanh nhạt, quần tối, giày da,
  sổ tay nâu, tóc điểm bạc) + Người Bán Hàng (nữ trẻ, áo xanh lá
  nhạt, váy dài tối, giày bệt, đuôi ngựa, túi giấy); xử lý trắng →
  trong suốt + cắt frame theo mẫu vòng 29/30 (connected component,
  MIN_FIG_W=100).
- File đích: `src/godot/art/char_chucuahang.png` (99×208) +
  `char_nguoibanhang.png` (109×208), `walk_chucuahang_f0..f5.png`
  (canvas chung 140×208) + `walk_nguoibanhang_f0..f5.png` (canvas
  chung 135×208), RGBA.
- Kiểm tra bằng mắt: 2 ảnh đứng + 2 sheet ĐẠT ngay lần đầu (**0 lần
  gen lại**); sheet Chủ Cửa Hàng có f0/f1 chồng lấn trục x nhưng tách
  bằng connected component vẫn đúng (bài học vòng 28). Dải magenta
  cả 2 sạch, không quầng trắng.
- Hạn chế thấy bằng mắt: chỉ mặt trước (3/4); f5 gần như tư thế
  đứng; f2/f3/f4 khá gần nhau; áo cả 2 gen ra cổ trụ khuy bấm thay
  vì cổ bẻ; chân Người Bán Hàng chỉ lộ từ dưới váy nên nhịp chân
  ít rõ bằng NPC quần dài; cả 2 đều có khuyên tai vàng nhỏ không có
  trong mô tả — tất cả chấp nhận được. Chi tiết:
  `visual-check/artpass31/walkcycle-npc-map009-note.md`.
- Godot `--headless --import` exit 0 — đủ 14 file `.import` cho
  14 file art mới (lưu ý subagent: đường dẫn binary là
  `tools/godot/Godot_v4.7.2-stable_linux.x86_64`, không có file
  `tools/godot/godot`).

### 53.2 Code + test — XONG

- `marker.gd` NPC_STYLE thêm `"chu-cua-hang"` (áo xanh nhạt
  (0.70,0.85,0.90), tóc "ngan", texture + frames) +
  `"nguoi-ban-hang"` (áo xanh lá nhạt (0.75,0.90,0.75), tóc "dai",
  texture + frames). Không sửa logic `CharacterSprite`/`Marker`.
- Test mới `tests/g4_r31_npc_walk_map009_test.gd`: **29/29 PASS**
  (theo mẫu r30: sprite trực tiếp từng NPC, marker home_tile
  (3,3)/(8,6), Main load_map(9) + pick patrol từ nhà Chủ Cửa Hàng).
- `tools/godot/run_regression.sh` thêm test mới (nay 59 suite).

### 53.3 Verify thật vòng này

- Hồi quy đầy đủ: **59 OK, 0 FAIL** (58 cũ + 1 mới r31).
- Smoke `--headless --quit-after 120` exit 0.
- Export web exit 0: pck **17.682.168 byte, SHA `ea66c202`**
  (trước `629ad8b8`, +489.012 byte = 14 file art mới); wasm không
  đổi `fc74679e…`, `GODOT_THREADS_ENABLED = false`; HTTP 200 đủ 5
  file (cổng 8186).
- **Browser-verify thật** (Chromium 1255 + swiftshader, 720×1280,
  script `visual-check/artpass31/check_r31.py`, ảnh `r31-01…r31-10`):
  **0 console error, 0 pageerror, 0 requestfailed.** Xem ảnh thật:
  đi chuỗi Map001→Map009 qua đúng cửa (5,4)/(5,8) từng map; Map009
  "Phố Thương Mại" — Chủ Cửa Hàng (áo xanh nhạt, sổ tay) + Người
  Bán Hàng (áo xanh lá nhạt, váy dài, đuôi ngựa) hiện rõ mặt thật
  có nhãn tên, không còn vẽ code; người chơi đi tới (10,1) đúng ô
  theo nhãn debug; cả 2 NPC patrol rời nhà sau 12s; 2 ảnh xa nhà
  cách nhau 2s pixel-diff = **16.877** (lá rơi + mây + NPC bob,
  cảnh sống). Lưu ý: Playwright chỉ chạy khi
  `PYTHONPATH=/home/hatch/.local/lib/python3.12/site-packages`
  (python3 mặc định không thấy user site-packages).
- Lỗi tìm ra khi xem ảnh (cosmetic, không chặn): nhãn "Chủ Cửa
  Hàng" đè lên Người Bán Hàng lúc 2 NPC đứng gần nhau ở spawn
  (giống vòng 30); Người Bán Hàng khuất một phần sau D-pad ở mép
  trái (đã biết từ các vòng trước).

### 53.4 Push + Deploy — XONG (gộp, thay cho deploy `629ad8b8` dở)

- **Push main r31 XONG:** lô a (marker.gd + test r31 + .uid +
  run_regression.sh) `a437ba61` + lô b (14 file .import art
  Map009) `e8260bdb` + lô c (visual-check artpass31)
  `e441ff1a` + docs (godot-g4.md §53 + roles-qc.md hiện trạng
  mới) — head main sau lô docs xem sync record mục cuối.
- **QUYẾT ĐỊNH GỘP (Bậc 1, lượt này):** pck `629ad8b8` (vòng 30)
  mới deploy 4/8 lô thì kẹt b5 (§52.7); pck `ea66c202` (vòng 31)
  chứa toàn bộ nội dung `629ad8b8` + art Map009. Để tránh deploy 2
  lần liên tiếp trên đường ghi chập chờn, CHỈ deploy `ea66c202` lên
  live — `629ad8b8` không lên live riêng. Chunk `629ad8b8` b1–b4
  đã đẩy vẫn nằm trên gh-pages nhưng không được versions.json trỏ
  tới (mồ côi vô hại — chunk theo version, không ai tải; manifest
  `pxb-deploy-629ad8b8-b5..b8` + `-final` bỏ, không dùng).
- **Deploy gh-pages pck `ea66c202` XONG:** staging rebuild VERIFY
  OK (pck 131 chunk khớp byte, wasm + img không đổi); đẩy 10 lô
  liên tiếp, phê duyệt về ngay cả 10 lần: b1 chunk 000–015
  `f0fe2d26`, b2 016–031 `2747a7ae`, b3 032–047 `91f843b3`, b4
  048–063 `0dcf548b`, b5 064–079 `10b76597`, b6 080–095
  `38f103e2`, b7 096–111 `9213af8f`, b8 112–127 `a704a8ef`, b9
  128–130 `805a44c1`, final (versions.json + index.html)
  `f7114aa9`. Sync record nay 289 mục. **Live đã chuyển sang pck
  `ea66c202` (vòng 31):** `--check-live` PASS ngay lần đầu sau
  60s chờ CDN (versions.json live `ea66c202`, index.html khớp
  staging từng byte).

### 53.5 Việc tiếp theo

1. NPC Map010 walk cycle (Khu Công Nghệ: Lập Trình Viên +
   Kỹ Sư Phần Mềm) theo từng map, mẫu vòng này.
2. Sprite sạp tách riêng (§45.1): đổi hàng 0 thành sạp cách nhau
   (ô lẻ để trống) rồi gen 3 sprite sạp (rau/trái cây/cá-thịt).
3. Kiểm live cloud browser Map009 (live nay `ea66c202` — kiểm
   trực tiếp trên link Pages khi cần, không cần deploy lại).

## 54. Vòng 32 — Walk cycle NPC Map010: Lập Trình Viên + Kỹ Sư Phần Mềm (24/11 ~22:45–23:15 +07, cron 22:45)

Mục 1 §53.5: NPC Map010 walk cycle theo từng map. Vòng này làm
Map010 Khu Công Nghệ: Lập Trình Viên (3,3) + Kỹ Sư Phần Mềm (8,6).

### 54.1 Art (subagent, theo đúng quy trình vòng 29/30/31) — XONG

- Thư mục `visual-check/artpass32/`; ảnh đứng + sheet 6 khung cho
  Lập Trình Viên (nam trẻ, áo polo xanh navy, quần jeans tối, giày
  thể thao trắng, tóc đen ngắn, đeo kính, cầm laptop mỏng) + Kỹ Sư
  Phần Mềm (nữ trẻ, áo blouse trắng xám nhạt, quần âu tối, giày bệt
  đen, tóc đen dài ngang vai, cầm máy tính bảng); xử lý trắng →
  trong suốt + cắt frame theo mẫu vòng 31 (connected component,
  MIN_FIG_W=100).
- File đích: `src/godot/art/char_laptrinhvien.png` (85×208) +
  `char_kysuphanmem.png` (99×208), `walk_laptrinhvien_f0..f5.png`
  (canvas chung 153×208) + `walk_kysuphanmem_f0..f5.png` (canvas
  chung 181×208), RGBA.
- Kiểm tra bằng mắt: 2 ảnh đứng + 2 sheet ĐẠT ngay lần đầu (**0 lần
  gen lại**); sheet Lập Trình Viên có f0/f1 chồng lấn trục x nhưng
  tách bằng connected component vẫn đúng (bài học vòng 28). Dải
  magenta cả 2 sạch, không quầng trắng.
- Hạn chế thấy bằng mắt: chỉ mặt trước (3/4); f5 gần như tư thế
  đứng; f2/f3/f4 khá gần nhau; blouse Kỹ Sư Phần Mềm cổ trụ khuy
  bấm thay vì cổ bẻ; laptop/tablet đổi tay theo nhịp đi; khuyên tai
  vàng nhỏ cả 2 (như vòng 31); sheet Kỹ Sư Phần Mềm tỉ lệ
  3840×640, nền góc (254,254,254) — slice vẫn tách đúng 6 hình.
  Tất cả chấp nhận được. Chi tiết:
  `visual-check/artpass32/walkcycle-npc-map010-note.md`.

### 54.2 Code + test — XONG

- `marker.gd` NPC_STYLE thêm `"lap-trinh-vien"` (áo navy
  (0.15,0.25,0.45), tóc "ngan", texture + frames) +
  `"ky-su-phan-mem"` (áo trắng xám (0.85,0.85,0.88), tóc "dai",
  texture + frames). Không sửa logic `CharacterSprite`/`Marker`.
- Test mới `tests/g4_r32_npc_walk_map010_test.gd`: **29/29 PASS**
  (theo mẫu r31: sprite trực tiếp từng NPC, marker home_tile
  (3,3)/(8,6), Main load_map(10) + pick patrol từ nhà Lập Trình
  Viên).
- `tools/godot/run_regression.sh` thêm test mới (nay 60 suite).

### 54.3 Verify thật vòng này

- Hồi quy đầy đủ: **60 OK, 0 FAIL** (59 cũ + 1 mới r32).
- Smoke `--headless --quit-after 120` exit 0.
- Export web exit 0: pck **18.163.860 byte, SHA `0d2cf705`**
  (trước `ea66c202`, +481.692 byte = 14 file art mới); wasm không
  đổi `fc74679e…`, `GODOT_THREADS_ENABLED = false`; HTTP 200 đủ 6
  file (cổng 8187).
- **Browser-verify thật** (Chromium 1255 + swiftshader, 720×1280,
  script `visual-check/artpass32/check_r32.py`, ảnh `r32-01…r32-11`):
  **0 console error, 0 pageerror, 0 requestfailed.** Xem ảnh thật:
  đi chuỗi Map001→Map010 qua đúng cửa (5,4)/(5,8) từng map; Map010
  "Khu Công Nghệ" — Lập Trình Viên (polo navy, kính, laptop) + Kỹ
  Sư Phần Mềm (blouse trắng xám, máy tính bảng) hiện rõ mặt thật
  có nhãn tên, không còn vẽ code; người chơi đi tới (10,1) đúng ô
  theo nhãn debug; cả 2 NPC patrol rời nhà sau 12s; 2 ảnh xa nhà
  cách nhau 2s pixel-diff = **20.844** (lá rơi + mây + NPC bob,
  cảnh sống).
- Lỗi tìm ra khi xem ảnh (cosmetic, không chặn): nhãn "Kỹ Sư Phần
  Mềm" đè lên thân Lập Trình Viên lúc 2 NPC đứng gần nhau ở spawn
  (giống vòng 30/31); Kỹ Sư Phần Mềm khuất một phần sau D-pad ở
  mép trái (đã biết từ các vòng trước).

### 54.4 Push + Deploy — XONG

- **Push main r32 XONG:** lô a (marker.gd + test r32 + .uid +
  run_regression.sh) `133c0ed9` + lô b (14 file .import art
  Map010) `3c9fd236` + lô c (visual-check artpass32)
  `10783ed7` + docs (godot-g4.md §54 + roles-qc.md hiện trạng
  mới) — head main sau lô docs xem sync record mục cuối.
- **Deploy gh-pages pck `0d2cf705` XONG:** staging rebuild VERIFY
  OK (pck 135 chunk khớp byte, wasm + img không đổi); đẩy 10 lô
  liên tiếp, phê duyệt về ngay cả 10 lần: b1 chunk 000–015
  `5167b414`, b2 016–031 `7d15832f`, b3 032–047 `8a2257a8`, b4
  048–063 `5df86a60`, b5 064–079 `3542a4ea`, b6 080–095
  `ff377cd4`, b7 096–111 `ab0c0272`, b8 112–127 `f0ed5af3`, b9
  128–134 `472ee58a`, final (versions.json + index.html)
  `6bfca6ab`. Sync record nay 303 mục. **Live đã chuyển sang pck
  `0d2cf705` (vòng 32):** `--check-live` PASS ngay lần đầu sau
  60s chờ CDN (versions.json live `0d2cf705`, index.html khớp
  staging từng byte).

### 54.5 Việc tiếp theo

1. NPC Map011 walk cycle (Phố Tây: Nhân Viên Lễ Tân + Hướng Dẫn
   Viên) theo từng map, mẫu vòng này.
2. Sprite sạp tách riêng (§45.1): đổi hàng 0 thành sạp cách nhau
   (ô lẻ để trống) rồi gen 3 sprite sạp (rau/trái cây/cá-thịt).
3. Kiểm live cloud browser Map010 (live nay `0d2cf705` — kiểm
   trực tiếp trên link Pages khi cần, không cần deploy lại).

## 55. Vòng 33 — Walk cycle NPC Map011: Nhân Viên Lễ Tân + Hướng Dẫn Viên (24/11 ~23:45–00:30 +07, cron 23:45)

Mục 1 §54.5: NPC Map011 walk cycle theo từng map. Vòng này làm
Map011 Phố Tây: Nhân Viên Lễ Tân (3,3) + Hướng Dẫn Viên (8,6).

### 55.1 Art (subagent, theo đúng quy trình vòng 29/30/31/32) — XONG

- Thư mục `visual-check/artpass33/`; ảnh đứng + sheet 6 khung cho
  Nhân Viên Lễ Tân (nam trẻ, áo sơ mi trắng + áo gile tối màu,
  quần âu tối, giày da đen, tóc đen ngắn gọn gàng, cầm bảng đăng
  ký khách clipboard) + Hướng Dẫn Viên (nữ trẻ, áo polo xanh
  dương nhạt, quần âu tối, giày thể thao trắng, tóc đen dài ngang
  vai, cầm cờ tour đỏ nhỏ + bản đồ gấp); xử lý trắng → trong suốt
  + cắt frame theo mẫu vòng 32 (connected component,
  MIN_FIG_W=100).
- File đích: `src/godot/art/char_nhanvienletan.png` (82×208) +
  `char_huongdanvien.png` (120×208), `walk_nhanvienletan_f0..f5.png`
  (canvas chung 145×208) + `walk_huongdanvien_f0..f5.png`
  (canvas chung 149×208), RGBA.
- Kiểm tra bằng mắt: 2 ảnh đứng + 2 sheet ĐẠT ngay lần đầu (**0 lần
  gen lại**); sheet Nhân Viên Lễ Tân có f0/f1 chồng lấn trục x
  (clipboard f0 giơ ngang) nhưng tách bằng connected component vẫn
  đúng (bài học vòng 28); sheet Hướng Dẫn Viên f4/f5 chồng lấn
  trục x (cờ f4 giơ ngang) nhưng tách đúng ngay lần đầu. Dải
  magenta cả 2 sạch, không quầng trắng.
- Hạn chế thấy bằng mắt: chỉ mặt trước (3/4); f5 gần như tư thế
  đứng; f2/f3/f4 khá gần nhau; clipboard/cờ/bản đồ đổi tay theo
  nhịp đi; khuyên tai vàng nhỏ Hướng Dẫn Viên (như vòng 31/32);
  **cờ tour đỏ của Hướng Dẫn Viên không thấy trong f4** (tay phải
  nắm hờ, bản đồ vẫn ở tay trái) — chỉ mất 1/6 chu kỳ, ở kích
  thước sprite trong game cờ chỉ vài pixel nên không đáng kể.
  Tất cả chấp nhận được. Chi tiết:
  `visual-check/artpass33/walkcycle-npc-map011-note.md`.

### 55.2 Code + test — XONG

- `marker.gd` NPC_STYLE thêm `"nhan-vien-le-tan"` (áo trắng
  (0.92,0.92,0.95), tóc "ngan", texture + frames) +
  `"huong-dan-vien"` (áo xanh dương nhạt (0.55,0.75,0.95), tóc
  "dai", texture + frames). Không sửa logic `CharacterSprite`/
  `Marker`.
- Test mới `tests/g4_r33_npc_walk_map011_test.gd`: **29/29 PASS**
  (theo mẫu r32: sprite trực tiếp từng NPC, marker home_tile
  (3,3)/(8,6), Main load_map(11) + pick patrol từ nhà Nhân Viên
  Lễ Tân).
- `tools/godot/run_regression.sh` thêm test mới (nay 61 suite).

### 55.3 Verify thật vòng này

- Hồi quy đầy đủ: **61 OK, 0 FAIL** (60 cũ + 1 mới r33) — chạy
  lại 25/11 00:45 trên cùng cây code, vẫn 61/61.
- Smoke `--headless --quit-after 120` exit 0, không ERROR
  (chạy lại 25/11 00:45).
- Export web exit 0: pck **18.622.468 byte, SHA `99a445f9`**
  (trước `0d2cf705`, +458.608 byte = 14 file art mới); wasm không
  đổi `fc74679e…`, `GODOT_THREADS_ENABLED = false`; HTTP 200 đủ 6
  file (cổng 8188, kiểm lại 25/11 00:45).
- **Browser-verify thật** (Chromium 1255 + swiftshader, 720×1280,
  script `visual-check/artpass33/check_r33.py`, ảnh `r33-01…r33-12`):
  **0 console error, 0 pageerror, 0 requestfailed.** Xem ảnh thật:
  đi chuỗi Map001→Map011 qua đúng cửa (5,4)/(5,8) từng map; Map011
  "Phố Tây" — Nhân Viên Lễ Tân (sơ mi trắng + gile tối, clipboard)
  + Hướng Dẫn Viên (polo xanh nhạt, cờ đỏ + bản đồ) hiện rõ mặt
  thật có nhãn tên, không còn vẽ code; người chơi đi tới (10,1)
  đúng ô theo nhãn debug; cả 2 NPC patrol rời nhà sau 12s; 2 ảnh
  xa nhà cách nhau 2s pixel-diff = **25.931** (lá rơi + mây + NPC
  bob, cảnh sống).
- Lỗi tìm ra khi xem ảnh (cosmetic, không chặn): nhãn NPC đè nhau
  khi đứng gần ở spawn; NPC khuất một phần sau D-pad ở mép trái
  (đã biết từ các vòng trước).

### 55.4 Push + Deploy — XONG

- **Push main r33 XONG:** lô a (marker.gd + test r33 + .uid)
  `ec67055c` + lô b (14 file .import art Map011) `51366570` +
  lô c (visual-check artpass33) `9c1f2539` — head main sau lô c
  `9c1f2539`. **Docs §55 này là commit bổ sung sau** (vòng 33
  đẩy code/deploy xong nhưng chưa kịp viết §55 — vòng 25/11 00:45
  viết bù + đẩy riêng).
- **Deploy gh-pages pck `99a445f9` XONG:** staging rebuild VERIFY
  OK (pck 138 chunk khớp byte, wasm + img không đổi); đẩy 10 lô
  liên tiếp: b1 chunk 000–015 `cdb319a5`, b2 016–031 `2adbe949`,
  b3 032–047 `9f12edc9`, b4 048–063 `f6ecddc5`, b5 064–079
  `b7c7a7b3`, b6 080–095 `13dd5aef`, b7 096–111 `4b3bb961`, b8
  112–127 `12d01349`, b9 128–137 `ee20f514`, final
  (versions.json + index.html) `d4e8e210`. Sync record nay 317 mục.
  **Live đã chuyển sang pck `99a445f9` (vòng 33):**
  `--check-live` PASS (kiểm lại 25/11 00:45: versions.json live
  `99a445f9`, index.html khớp staging từng byte).

### 55.5 Đính chính — lần chạy lại check_r33.py 25/11 00:45 đi lố sang Map013

- Chạy lại `check_r33.py` trên đúng build `99a445f9` để xác nhận
  lại: start OK, **ERRORS: none**, pixel-diff 2.651 — nhưng ảnh
  `r33-10…r33-12` mới hiện **Map013 Quận Tài Chính** thay vì
  Map011: chuỗi đi 10 map bằng giữ phím 400ms/ô bị trôi ở FPS
  thấp (swiftshader ~5fps) — một lần giữ phím ăn 2 ô hoặc một
  lần bấm lọt giữa 2 frame, pha dịch chuyển dồn lại thành đi lố
  2 map. Đây là **lỗi của harness đo, không phải lỗi game**
  (đúng build đó đã đi đúng chuỗi ở lần chạy gốc, ảnh gốc chứng
  minh).
- Đã khôi phục đủ 12 ảnh gốc `r33-01…r33-12` từ backup
  (`/tmp/r33-shots-backup/`) — ảnh mới đi lố đã xóa, không dùng
  làm bằng chứng. Bài học: script đi chuỗi dài phải kiểm tra
  tiêu đề map trong TỪNG ảnh, không tin tên file; giữ phím ở FPS
  thấp cần xác nhận ô sau mỗi bước (đọc nhãn debug) thay vì bấm
  mù 4 lần liên tiếp.

### 55.6 Việc tiếp theo

1. NPC Map012 walk cycle (Khu Biệt Thự Ven Sông: Bảo Vệ Biệt Thự
   + Người Làm Vườn) theo từng map, mẫu vòng này — **art đã giao
   subagent ở lượt 25/11 00:45, đang làm**.
2. Sprite sạp tách riêng (§45.1): đổi hàng 0 thành sạp cách nhau
   (ô lẻ để trống) rồi gen 3 sprite sạp (rau/trái cây/cá-thịt).
3. Kiểm live cloud browser Map011 (live nay `99a445f9` — kiểm
   trực tiếp trên link Pages khi cần, không cần deploy lại).

## 56. Vòng 34 — Walk cycle NPC Map012: Bảo Vệ Biệt Thự + Người Làm Vườn (25/11 ~00:45–01:30 +07, cron 00:45)

Mục 1 §55.6: NPC Map012 walk cycle theo từng map. Vòng này làm
Map012 Khu Biệt Thự Ven Sông: Bảo Vệ Biệt Thự (3,3) + Người Làm
Vườn (8,6).

### 56.1 Art (subagent, theo đúng quy trình vòng 29/30/31/32/33) — XONG

- Thư mục `visual-check/artpass34/`; ảnh đứng + sheet 6 khung cho
  Bảo Vệ Biệt Thự (nam trung niên, mũ bảo vệ có huy hiệu vàng, sơ
  mi xanh đậm có cầu vai + huy hiệu ngực, quần âu tối, giày da
  đen, cầm đèn pin) + Người Làm Vườn (nam lớn tuổi tóc bạc + ria
  bạc, đội nón lá, áo be/kaki cổ trụ 3 cúc, quần tối, giày vải
  nâu, cầm kéo cắt cây + bình tưới xanh lá); xử lý trắng → trong
  suốt + cắt frame theo mẫu vòng 33 (connected component,
  MIN_FIG_W=100) + 2 sửa mới của vòng này (xem dưới).
- File đích: `src/godot/art/char_baovebietthu.png` (91×208) +
  `char_nguoilamvuon.png` (133×208), `walk_baovebietthu_f0..f5.png`
  (canvas chung 154×208) + `walk_nguoilamvuon_f0..f5.png`
  (canvas chung 145×208), RGBA.
- Kiểm tra bằng mắt: 2 ảnh đứng + 2 sheet ĐẠT ngay lần đầu (**0 lần
  gen lại**); dải magenta cả 2 sạch, không quầng trắng; zoom 4×
  kiểm tra thấu kính đèn pin + vòng dây đèn pin + tam giác giữa
  chân đều trong suốt đúng.
- **2 sửa script mới (ghi trong note, vòng sau copy từ vòng 34,
  không phải vòng 33):** (1) sheet Người Làm Vườn lần đầu chỉ
  tách được 5 hình — f2+f3 gộp thành 1 component rộng 913px do
  vành nón lá rộng + tay giơ ngang chạm nhau; thêm
  `split_wide_component` (tách component >600px tại cột mật độ
  thấp nhất) thì đúng 6 hình ngay lần đầu. (2) Vùng trắng kín
  (vòng dây đèn pin, tam giác giữa hai chân, khe tay–thân) bị
  flood fill giữ thành đục — thêm bước xóa vùng trắng kín
  ≥100 final px; bản đầu dùng ngưỡng pixel thô đã xóa nhầm thấu
  kính đèn pin (thấy lỗ magenta khi zoom), đã sửa lại theo
  final px; thấu kính (16–21px) và quai bình tưới (≤55px) được
  giữ nguyên. Lưu ý: ngưỡng xóa trắng kín chỉ đúng khi NPC
  không mặc đồ trắng.
- Hạn chế thấy bằng mắt: chỉ mặt trước (3/4); f5 gần như tư thế
  đứng; f2/f3/f4 khá gần nhau; đạo cụ đổi tay theo nhịp đi. Tất
  cả chấp nhận được. Chi tiết:
  `visual-check/artpass34/walkcycle-npc-map012-note.md`.

### 56.2 Code + test — XONG

- `marker.gd` NPC_STYLE thêm `"bao-ve-biet-thu"` (áo xanh đậm
  (0.12,0.25,0.45), tóc "ngan", texture + frames) +
  `"nguoi-lam-vuon"` (áo be/kaki (0.85,0.78,0.60), tóc "ngan",
  texture + frames). Không sửa logic `CharacterSprite`/`Marker`.
- Test mới `tests/g4_r34_npc_walk_map012_test.gd`: **29/29 PASS**
  (theo mẫu r33: sprite trực tiếp từng NPC, marker home_tile
  (3,3)/(8,6), Main load_map(12) + pick patrol từ nhà Bảo Vệ
  Biệt Thự).
- `tools/godot/run_regression.sh` thêm test mới (nay 62 suite).

### 56.3 Verify thật vòng này

- Hồi quy đầy đủ: **62 OK, 0 FAIL** (61 cũ + 1 mới r34).
- Smoke `--headless --quit-after 120` exit 0, không ERROR.
- Export web exit 0: pck **19.145.008 byte, SHA `aa5e4447`**
  (trước `99a445f9`, +522.540 byte = 14 file art mới); wasm không
  đổi `fc74679e…`, `GODOT_THREADS_ENABLED = false`; HTTP 200 đủ 6
  file (cổng 8189).
- **Browser-verify thật** (Chromium 1255 + swiftshader, 720×1280,
  script `visual-check/artpass34/check_r34.py`, ảnh `r34-01…r34-13`):
  **0 console error, 0 pageerror, 0 requestfailed.** Xem ảnh thật:
  đi chuỗi Map001→Map012 qua đúng cửa (5,4)/(5,8) từng map (đã
  kiểm tiêu đề từng ảnh theo bài học §55.5 — lần này chuỗi không
  trôi); Map012 "Khu Biệt Thự Ven Sông" — Bảo Vệ Biệt Thự (đồng
  phục xanh đậm, mũ có huy hiệu, đèn pin) + Người Làm Vườn (nón
  lá, áo be/kaki, kéo + bình tưới) hiện rõ mặt thật có nhãn tên,
  không còn vẽ code; người chơi đi xa, cả 2 NPC patrol rời nhà
  sau 12s (Bảo Vệ bước ra mép trái giữa chu kỳ, Người Làm Vườn
  gần D-pad); 2 ảnh xa nhà cách nhau 2s pixel-diff = **9.735**
  (lá rơi + mây + NPC bob, cảnh sống).
- Lỗi tìm ra khi xem ảnh (cosmetic, không chặn): nhãn "Người Làm
  Vườn" đè lên thân Bảo Vệ lúc 2 NPC đứng gần nhau ở spawn (giống
  vòng 30–33); Người Làm Vườn khuất một phần sau D-pad ở mép
  trái; người chơi spawn Map012 ở (5,5) thay vì (5,4) — 1 bước
  thừa do phím giữ lọt sang map mới (harness, không phải game);
  đi xa dừng ở (10,2) thay vì (10,1) — 1 lần bấm lên bị miss ở
  FPS thấp, vẫn đủ xa để patrol kích hoạt.

### 56.4 Push + Deploy — XONG

- **Push main r34 XONG:** lô a (marker.gd + test r34 + .uid +
  run_regression.sh) `c2a212be` + lô b (14 file .import art
  Map012) `833336e8` + lô c (visual-check artpass34)
  `f42bdef5` + docs (godot-g4.md §55–56 + roles-qc.md)
  `74dc0cb0` — head main sau lô docs `74dc0cb0`.
- **Deploy gh-pages pck `aa5e4447` XONG:** staging rebuild VERIFY
  OK (pck 142 chunk khớp byte, wasm + img không đổi); đẩy 10 lô
  liên tiếp: b1 chunk 000–015 `fb438e3d`, b2 016–031 `bbf7c663`,
  b3 032–047 `40a797f6`, b4 048–063 `151540b9`, b5 064–079
  `928f4e53`, b6 080–095 `1ff918e2`, b7 096–111 `ac56d5d5`, b8
  112–127 `a74e24be`, b9 128–141 `357c8e0b`, final
  (versions.json + index.html) `556f67d3`. Sync record nay 331 mục.
  **Live đã chuyển sang pck `aa5e4447` (vòng 34):**
  `--check-live` PASS (versions.json live `aa5e4447`, index.html
  khớp staging từng byte).
- Lưu ý: message commit deploy ghi "(§55)" do script deploy copy
  từ vòng 33 chưa đổi số mục — chỉ sai nhãn, nội dung đúng pck
  `aa5e4447` vòng 34. Lô final lên GitHub lúc 01:50:18Z nhưng
  script bị kill (tưởng approval kẹt) trước khi ghi sync record —
  đã ghi bù thủ công từ SHA commit trên GitHub
  (`556f67d3…`, đối chiếu message + thời gian), không push lại.
- Dọn dẹp: thẻ approval deploy lô 1 chờ ~6 phút mới về (lô 2–10
  về ngay sau đó) — lần sau đợi approval lâu hơn trước khi kết
  luận kẹt; kiểm tra sync record + head gh-pages trước khi kill
  script deploy đang chạy.

### 56.5 Việc tiếp theo

1. NPC Map013 walk cycle (Quận Tài Chính: Nhân Viên Ngân Hàng +
   Môi Giới Chứng Khoán) theo từng map, mẫu vòng này — nhớ copy
   script slice từ **vòng 34** (có `split_wide_component` + xóa
   trắng kín theo final px).
2. Sprite sạp tách riêng (§45.1): đổi hàng 0 thành sạp cách nhau
   (ô lẻ để trống) rồi gen 3 sprite sạp (rau/trái cây/cá-thịt).
3. Kiểm live cloud browser Map012 (live nay `99a445f9` cho tới
   khi deploy `aa5e4447` xong — kiểm trực tiếp trên link Pages
   khi cần).

## 57. Vòng 35 — Walk cycle NPC Map013: Nhân Viên Ngân Hàng + Môi Giới Chứng Khoán (25/11 ~08:45–09:45 +07, cron 08:45)

Mục 1 §56.5: NPC Map013 walk cycle theo từng map. Vòng này làm
Map013 Quận Tài Chính: Nhân Viên Ngân Hàng (3,3) + Môi Giới
Chứng Khoán (8,6).

### 57.1 Art (subagent, theo đúng quy trình vòng 29/30/31/32/33/34) — XONG

- Thư mục `visual-check/artpass35/`; ảnh đứng + sheet 6 khung cho
  Nhân Viên Ngân Hàng (nam trẻ, vest xanh navy + sơ mi xanh nhạt +
  cà vạt đỏ đậm, quần âu tối, giày da đen, cầm xấp giấy tờ ngân
  hàng / tablet) + Môi Giới Chứng Khoán (nam, vest xám than + sơ
  mi xanh bạc hà nhạt + cà vạt tối, đeo kính, giày da đen, cầm
  điện thoại hiện biểu đồ nến xanh/đỏ + tập hồ sơ); xử lý trắng →
  trong suốt + cắt frame theo mẫu vòng 34 (connected component,
  MIN_FIG_W=100, `split_wide_component` MAX_FIG_W=600 + xóa vùng
  trắng kín ≥100 final px).
- File đích: `src/godot/art/char_nhanviennganhang.png` (93×208) +
  `char_moigioichungkhoan.png` (103×208),
  `walk_nhanviennganhang_f0..f5.png` (canvas chung 153×208) +
  `walk_moigioichungkhoan_f0..f5.png` (canvas chung 131×208), RGBA.
- Kiểm tra bằng mắt: 2 ảnh đứng + 2 sheet; **1 lần gen lại** —
  ảnh đứng Nhân Viên Ngân Hàng lần đầu bị vẽ thành NỮ (tóc búi,
  bông tai vàng) vì ảnh tham chiếu `char_cotu.png` là nhân vật nữ;
  gen lại 1 lần với prompt siết giới tính ("MAN, masculine face,
  short black hair, no earrings, no bun") thì đạt ngay; bản hỏng
  giữ lại làm hồ sơ
  (`rejected-female-char-nhanviennganhang-af4428f2.webp`). Ảnh
  đứng Môi Giới + cả 2 sheet đều đạt ngay lần đầu (0 gen lại).
  Dải magenta cả 2 sạch, không quầng trắng; zoom 4× kiểm tra giấy
  tờ/tablet + điện thoại (nến xanh/đỏ + cột khối lượng) + kính
  gọng đen đều nguyên vẹn. Không có vùng trắng kín ≥100 final px
  nào bị xóa; vùng trắng kín còn lại chỉ là giấy trắng của xấp
  tài liệu (15–61 final px, giữ đúng thiết kế). Cả 2 sheet đúng
  6 hình, không cần tách component rộng.
- **Bài học mới (ghi trong note):** NPC nam tham chiếu
  `char_cotu.png` (nữ) phải siết giới tính ngay trong prompt; giấy
  trắng cầm tay có thể tạo vùng trắng kín thật — NPC nào cầm giấy
  trắng mà vùng giấy khép kín ≥100 final px thì bước xóa trắng kín
  sẽ thủng giấy, cần kiểm tra debug-white sau mỗi vòng.
- Hạn chế thấy bằng mắt: chỉ mặt trước (3/4); f5 gần như tư thế
  đứng; f2/f3/f4 khá gần nhau; đạo cụ đổi tay theo nhịp đi. Tất
  cả chấp nhận được. Chi tiết:
  `visual-check/artpass35/walkcycle-npc-map013-note.md`.

### 57.2 Code + test — XONG

- `marker.gd` NPC_STYLE thêm `"nhan-vien-ngan-hang"` (vest navy
  (0.12,0.20,0.42), tóc "ngan", texture + frames) +
  `"moi-gioi-chung-khoan"` (vest xám than (0.30,0.30,0.33), tóc
  "ngan", texture + frames). Không sửa logic `CharacterSprite`/
  `Marker`.
- Test mới `tests/g4_r35_npc_walk_map013_test.gd`: **29/29 PASS**
  (theo mẫu r34: sprite trực tiếp từng NPC, marker home_tile
  (3,3)/(8,6), Main load_map(13) + pick patrol từ nhà Nhân Viên
  Ngân Hàng).
- `tools/godot/run_regression.sh` thêm test mới (nay 63 suite).

### 57.3 Verify thật vòng này

- Hồi quy đầy đủ: **63 OK, 0 FAIL** (62 cũ + 1 mới r35).
- Smoke `--headless --quit-after 120` exit 0, không ERROR.
- Export web exit 0: pck **19.617.968 byte, SHA `2d9ae4e0`**
  (trước `aa5e4447`, +472.960 byte = 14 file art mới); wasm không
  đổi `fc74679e…`, `GODOT_THREADS_ENABLED = false`; HTTP 200 đủ 6
  file (cổng 8190).
- **Browser-verify thật** (Chromium 1255 + swiftshader, 720×1280,
  script `visual-check/artpass35/check_r35.py`, ảnh `r35-01…r35-14`):
  **0 console error, 0 pageerror, 0 requestfailed.** Xem ảnh thật:
  đi chuỗi Map001→Map013 qua đúng cửa (5,4)/(5,8) từng map; Map013
  "Quận Tài Chính" — Nhân Viên Ngân Hàng (vest navy, sơ mi xanh
  nhạt, cà vạt đỏ, cầm giấy tờ) + Môi Giới Chứng Khoán (vest xám
  than, kính, điện thoại) hiện rõ mặt thật có nhãn tên, không còn
  vẽ code; người chơi đi tới (10,4) đúng ô, cả 2 NPC patrol rời
  nhà sau 12s; 2 ảnh xa nhà cách nhau 2s pixel-diff = **6.244**
  (lá rơi + mây + NPC bob, cảnh sống).
- Lỗi tìm ra khi xem ảnh (cosmetic, không chặn): nhãn "Môi Giới
  Chứng Khoán" đè lên thân Nhân Viên Ngân Hàng — **đã xác minh
  KHÔNG phải nhãn sai:** nhãn NPC chỉ hiện khi người chơi trong
  Manhattan ≤5 ô (`LABEL_NEAR_TILES`=5; lúc chụp người chơi (5,7)
  cách Nhân Viên Ngân Hàng 6 ô nên nhãn bạn ấy ẩn, cách Môi Giới
  4 ô nên nhãn bạn ấy hiện); nhãn Môi Giới neo -170px trên đầu
  bạn ấy nên trong chiếu iso rơi đúng vào vị trí Nhân Viên Ngân
  Hàng đứng phía trên-trái. Cùng mẫu đã thấy ở Map012 vòng 34
  (nhãn "Người Làm Vườn" đè lên thân Bảo Vệ, ảnh r35-11 kiểm lại
  vẫn vậy). Texture/nhãn từng NPC đã đối chiếu đúng file art đứng
  (`char_nhanviennganhang.png` vest navy + cà vạt đỏ + giấy tờ;
  `char_moigioichungkhoan.png` vest xám + kính + điện thoại).
  Người chơi spawn Map013 ở (5,7) thay vì (5,4) — phím giữ lọt
  sang map mới 3 bước (harness, không phải game); đi xa tới
  (10,4) đúng ô (phải ×5 + lên ×3 từ (5,7)).

### 57.4 Push + Deploy — XONG

- **Push main r35 XONG:** lô a (marker.gd + test r35 + .uid +
  run_regression.sh) `50463816` + lô b (14 file .import art
  Map013) `c809bd70` + lô c (visual-check artpass35)
  `10c05901` — head main sau lô c `10c05901`.
- **Deploy gh-pages pck `2d9ae4e0` XONG:** staging rebuild VERIFY
  OK (pck 146 chunk khớp byte, wasm + img không đổi); đẩy 11 lô
  liên tiếp: b1 chunk 000–015 `22aec1f5`, b2 016–031 `2f6878be`,
  b3 032–047 `c107b27e`, b4 048–063 `43819c05`, b5 064–079
  `e990ba49`, b6 080–095 `fee7a39c`, b7 096–111 `04cff97b`, b8
  112–127 `c665c8ce`, b9 128–143 `a9ccf828`, b10 144–145
  `c9855819`, final (versions.json + index.html) `acb5ee1f`.
  Sync record nay 346 mục. **Live đã chuyển sang pck `2d9ae4e0`
  (vòng 35):** `--check-live` PASS (versions.json live
  `2d9ae4e0`, index.html khớp staging từng byte).

### 57.5 Việc tiếp theo

1. NPC Map014 walk cycle (Đảo Thượng Lưu: Quản Gia Đảo + Chủ
   Biệt Thự Đảo) theo từng map, mẫu vòng này — nhớ copy script
   slice từ **vòng 34** (có `split_wide_component` + xóa trắng kín
   theo final px); lưu ý siết giới tính trong prompt khi NPC nam
   tham chiếu `char_cotu.png` + kiểm tra debug-white nếu NPC cầm
   giấy trắng.
2. Sprite sạp tách riêng (§45.1): đổi hàng 0 thành sạp cách nhau
   (ô lẻ để trống) rồi gen 3 sprite sạp (rau/trái cây/cá-thịt).
3. Nhãn NPC chỉ hiện trong 5 ô + neo -170px nên nhãn NPC (8,6)
   dễ đè lên NPC (3,3) trong chiếu iso — cân nhắc cải thiện hiển
   thị nhãn (việc polish, không chặn).

## 58. Vòng 36 — Walk cycle NPC Map014: Quản Gia Đảo + Chủ Biệt Thự Đảo (25/11 ~09:45–10:15 +07, cron 09:45)

Mục 1 §57.5: NPC Map014 walk cycle theo từng map. Vòng này làm
Map014 Đảo Thượng Lưu: Quản Gia Đảo (3,3) + Chủ Biệt Thự Đảo (8,6).

### 58.1 Art (subagent, theo đúng quy trình vòng 35) — XONG

- Thư mục `visual-check/artpass36/`; ảnh đứng + sheet 6 khung cho
  Quản Gia Đảo (nam, áo đuôi tôm đen + sơ mi xám nhạt + nơ đen,
  găng tay tối màu, cầm khay bạc có ấm trà + tách) + Chủ Biệt Thự
  Đảo (nữ, váy dài hồng đào nhạt + mũ rộng vành, cầm quạt tay +
  túi xách nhỏ); xử lý trắng → trong suốt + cắt frame theo mẫu
  vòng 35 (connected component, MIN_FIG_W=100, `split_wide_component`
  MAX_FIG_W=600 + xóa vùng trắng kín ≥100 final px).
- File đích: `src/godot/art/char_quangiadao.png` (95×208) +
  `char_chubietthudao.png` (113×208),
  `walk_quangiadao_f0..f5.png` (canvas chung 138×208) +
  `walk_chubietthudao_f0..f5.png` (canvas chung 137×208), RGBA.
- Kiểm tra bằng mắt: 2 ảnh đứng + 2 sheet; **1 lần gen lại** —
  sheet Chủ Biệt Thự Đảo bản đầu thiếu quạt tay ở f5, gen lại có
  quạt đủ 6 hình nhưng thiếu túi xách ở f2 (chấp nhận: quạt là
  đạo cụ lớn, thiếu ở f5 lộ hơn túi nhỏ thiếu ở 1 frame giữa chu
  kỳ); bản hỏng giữ lại làm hồ sơ
  (`rejected-nofan-f5-walkcycle-sheet-chubietthudao-56867cd6.webp`).
  Ảnh đứng cả 2 đạt ngay lần đầu — prompt siết giới tính của
  Quản Gia Đảo ("MAN, masculine face, short black hair, no
  earrings, no bun, no long hair") phát huy tác dụng, không tái
  phạm lỗi vòng 35. Dải magenta cả 2 sạch, không quầng trắng;
  zoom 4× kiểm tra ấm trà (vòi + quai + núm nắp), quạt xếp, túi
  chần bông, mũ rộng vành đều nguyên vẹn. Vùng trắng kín còn lại
  lớn nhất chỉ 69px (nếp váy) / 35px (highlight ấm trà), đều
  <100 final px nên được giữ; các vùng ≥100 final px đã xóa đều
  là nền nhìn xuyên qua (tam giác giữa 2 chân bắt chéo, khe xẻ
  tà váy, quai ấm trà) — không có đạo cụ trắng khép kín nào bị
  xóa mù.
- **1 sửa script duy nhất:** sheet Quản Gia Đảo có bóng đổ mặt
  đất tách rời dưới chân f0 (rộng 195px, cao 21px) làm
  `find_figures` đếm 7 hình → thêm `MIN_FIG_H = 100` vào
  `slice_walkcycle_npc_map014.py` (bỏ component cao <100px; hình
  thật ~750px). Hệ quả nhỏ: f0 Quản Gia mất vệt bóng mờ dưới
  chân, các frame khác vẫn giữ bóng dính chân.
- **Bài học mới (ghi trong note):** khi gen lại vì thiếu 1 đạo
  cụ, siết cả 2 đạo cụ cùng lúc ("fan in ALL six figures AND
  handbag in ALL six figures").
- Chi tiết:
  `visual-check/artpass36/walkcycle-npc-map014-note.md`.

### 58.2 Code + test — XONG

- `marker.gd` NPC_STYLE thêm `"quan-gia-dao"` (đuôi tôm đen
  (0.08,0.08,0.10), tóc "ngan", texture + frames) +
  `"chu-biet-thu-dao"` (váy hồng đào (0.95,0.72,0.62), tóc "dai",
  texture + frames). Không sửa logic `CharacterSprite`/
  `Marker`.
- **Lỗi tìm ra khi nối code (2 lỗi, cùng 1 gốc — tên file art
  sai chính tả):** file art lúc gen dùng stem `quanggiadao`
  (thừa 1 chữ g — "Quản Gia" không dấu là `quan-gia`, khớp NPC
  id `quan-gia-dao`), trong khi test build tiền tố frame bằng
  `npc_id.replace("-", "")` = `quangiadao` → test rớt 4/29
  (frame file không tồn tại, frame_count 0). Sửa: đổi tên 7 file
  art Quản Gia Đảo thành `quangiadao` + cập nhật `marker.gd` +
  note (đính chính trong note artpass36); sau đó test còn rớt
  2/29 vì `NPC_TEX` trong test vẫn trỏ `char_quanggiadao.png`
  cũ — sửa nốt thì **29/29 PASS**. Bài học: quy tắc đặt tên
  file art = NPC id bỏ dấu gạch nối — kiểm tra khớp tên ngay
  khi art về, trước khi chạy test.
- Test mới `tests/g4_r36_npc_walk_map014_test.gd`: **29/29 PASS**
  (theo mẫu r35: sprite trực tiếp từng NPC, marker home_tile
  (3,3)/(8,6), Main load_map(14) + pick patrol từ nhà Quản Gia
  Đảo).
- `tools/godot/run_regression.sh` thêm test mới (nay 64 suite).

### 58.3 Verify thật vòng này

- Hồi quy đầy đủ: **64 OK, 0 FAIL** (63 cũ + 1 mới r36).
- Smoke `--headless --quit-after 120` exit 0, 0 ERROR.
- Export web exit 0: pck **20.102.808 byte, SHA `210e0a19`**
  (trước `2d9ae4e0`, +484.840 byte = 14 file art mới); wasm không
  đổi `fc74679e…`, `GODOT_THREADS_ENABLED = false`; HTTP 200 đủ
  2 file (cổng 8191).
- **Browser-verify thật** (Chromium 1255 + swiftshader, 720×1280,
  script `visual-check/artpass36/check_r36.py`, ảnh `r36-01…r36-15`;
  phải cài lại playwright bằng `pip install
  --break-system-packages playwright pillow` vì VM restart đã gỡ
  module — tiền lệ G4 §8.7): **0 console error, 0 pageerror, 0
  requestfailed.** Xem ảnh thật: đi chuỗi Map001→Map014 qua đúng
  cửa (5,4)/(5,8) từng map; Map014 "Đảo Thượng Lưu" — Quản Gia Đảo
  (đuôi tôm đen, cầm khay bạc ấm trà) + Chủ Biệt Thự Đảo (váy hồng
  đào, mũ rộng vành, quạt tay) hiện rõ mặt thật có nhãn tên, không
  còn vẽ code; người chơi đi tới (10,4) đúng ô, cả 2 NPC patrol
  rời nhà sau 12s (Quản Gia Đảo từ mép trên ảnh home sang mép trái
  ảnh away, cầm khay bạc thấy rõ ở ảnh away2); 2 ảnh xa nhà cách
  nhau 2s pixel-diff = **12.720** (lá rơi + mây + NPC bob, cảnh
  sống).
- Lỗi tìm ra khi xem ảnh (cosmetic, không chặn): nhãn "Chủ Biệt
  Thự Đảo" đè lên thân Quản Gia Đảo — **đã xác minh KHÔNG phải
  nhãn sai:** nhãn NPC chỉ hiện khi người chơi trong Manhattan
  ≤5 ô (lúc chụp người chơi (10,4) cách Chủ Biệt Thự 5 ô nên
  nhãn bạn ấy hiện, cách Quản Gia Đảo 9 ô nên nhãn bạn ấy ẩn);
  nhãn Chủ Biệt Thự neo -170px trên đầu bạn ấy nên trong chiếu
  iso rơi đúng vào vị trí Quản Gia Đảo đứng phía trên-trái. Cùng
  mẫu đã thấy ở Map012 vòng 34 / Map013 vòng 35. Người chơi
  spawn Map014 ở (5,7) thay vì (5,4) — phím giữ lọt sang map mới
  3 bước (harness, không phải game); đi xa tới (10,4) đúng ô
  (phải ×5 + lên ×3 từ (5,7)).

### 58.4 Push + Deploy — XONG

- **Push main r36 XONG:** lô a (marker.gd + test r36 + .uid +
  run_regression.sh) `1d8823f0` + lô b (14 file .import art Map014)
  `c0bbb853` + lô c (visual-check artpass36) `3de8252d` — head main sau lô c
  `3de8252d` (docs `b488f74a`).
- **Deploy gh-pages pck `210e0a19` XONG:** staging rebuild VERIFY
  OK (pck 149 chunk khớp byte, wasm + img không đổi); đẩy 11 lô
  liên tiếp: b1 chunk 000–015 `df653cca`, b2 016–031 `3b6dd61b`,
  b3 032–047 `0a5c0cb8`, b4 048–063 `a5849cf1`, b5 064–079
  `6859bd40`, b6 080–095 `6ce08fde`, b7 096–111 `23de3563`, b8
  112–127 `88ee8518`, b9 128–143 `ba7620a3`, b10 144–148
  `7cd67c1c`, final (versions.json + index.html) `929c84e8`.
  Sync record nay 363 mục. **Live đã chuyển sang pck `210e0a19`
  (vòng 36):** `--check-live` PASS (versions.json live `210e0a19`,
  index.html khớp staging từng byte — lần đầu check ngay sau deploy
  vẫn thấy bản cũ `2d9ae4e0` do CDN cache, check lại sau ~7 phút thì
  khớp).

### 58.5 Việc tiếp theo

1. NPC Map015 walk cycle (Khu Penthouse: Quản Lý Penthouse + Cư
   Dân Penthouse) theo từng map, mẫu vòng này — nhớ kiểm tra tên
   file art khớp NPC id bỏ dấu gạch nối ngay khi art về (§58.2).
2. Sprite sạp tách riêng (§45.1): đổi hàng 0 thành sạp cách nhau
   (ô lẻ để trống) rồi gen 3 sprite sạp (rau/trái cây/cá-thịt).
3. Nhãn NPC chỉ hiện trong 5 ô + neo -170px nên nhãn NPC (8,6)
   dễ đè lên NPC (3,3) trong chiếu iso — cân nhắc cải thiện hiển
   thị nhãn (việc polish, không chặn).

## 59. Vòng 37 — Walk cycle NPC Map015: Quản Lý Penthouse + Cư Dân Penthouse (25/11 ~10:45–11:15 +07, cron 10:45)

Mục 1 §58.5: NPC Map015 walk cycle theo từng map. Vòng này làm
Map015 Khu Penthouse: Quản Lý Penthouse (3,3) + Cư Dân
Penthouse (8,6).

### 59.1 Art (subagent, theo đúng quy trình vòng 36) — XONG

- Thư mục `visual-check/artpass37/`; ảnh đứng + sheet 6 khung cho
  Quản Lý Penthouse (nam, vest xám than + sơ mi xanh nhạt + cà vạt
  đỏ bordeaux, cầm clipboard + thẻ chìa khóa vàng) + Cư Dân
  Penthouse (nữ, váy dài xanh ngọc lục bảo, cầm túi mua sắm +
  điện thoại thông minh); xử lý trắng → trong suốt + cắt frame
  theo mẫu vòng 36 (connected component, MIN_FIG_W=100,
  MIN_FIG_H=100, `split_wide_component` MAX_FIG_W=600 + xóa vùng
  trắng kín ≥100 final px).
- File đích: `src/godot/art/char_quanlypenthouse.png` (102×208) +
  `char_cudanpenthouse.png` (106×208),
  `walk_quanlypenthouse_f0..f5.png` (canvas chung 122×208) +
  `walk_cudanpenthouse_f0..f5.png` (canvas chung 142×208), RGBA.
- Kiểm tra bằng mắt: 2 ảnh đứng + 2 sheet; **0 lần gen lại** —
  cả 2 ảnh đứng + cả 2 sheet đạt ngay lần đầu, đạo cụ đủ 6/6 hình
  cho cả 2 NPC (clipboard + thẻ vàng / túi mua sắm + điện thoại).
  Bài học vòng 36 phát huy: siết cả 2 đạo cụ cùng lúc NGAY TỪ
  LẦN GEN ĐẦU thì không tái phạm lỗi thiếu đạo cụ; prompt siết
  giới tính của Quản Lý Penthouse (nam, mặt nam tính, tóc đen
  ngắn, không khuyên tai, không búi, không tóc dài) cho nam rõ
  ràng ngay lần đầu. Slice vòng 36 chạy thẳng, đúng 6
  component/sheet, không cần `split_wide_component`.
- Hạn chế (chấp nhận, ghi trong note): Cư Dân f4 tay trái duỗi
  thẳng cầm điện thoại hơi cứng (1 frame giữa chu kỳ); chân dưới
  váy dài khó phân biệt pha; túi mua sắm có logo + chữ nhỏ mờ
  (không đọc được ở kích thước sprite); nhân vật đi dép quai thay
  vì giày (task không quy định). Tên file thô sheet Quản Lý bị
  pipeline cắt ngắn stem (`...-quanlypenthous-0-...webp`, thiếu
  chữ `e`) — đã chuẩn hóa khi chuyển sang `.png`.
- Chi tiết:
  `visual-check/artpass37/walkcycle-npc-map015-note.md`.

### 59.2 Code + test — XONG

- `marker.gd` NPC_STYLE thêm `"quan-ly-penthouse"` (vest xám than
  (0.22,0.24,0.28), tóc "ngan", texture + frames) +
  `"cu-dan-penthouse"` (váy xanh ngọc (0.05,0.45,0.38), tóc "dai",
  texture + frames). Không sửa logic `CharacterSprite`/
  `Marker`. Tên file art khớp NPC id bỏ dấu gạch nối ngay khi art
  về (`quanlypenthouse` / `cudanpenthouse`) — không tái phạm lỗi
  vòng 36.
- Test mới `tests/g4_r37_npc_walk_map015_test.gd`: **29/29 PASS**
  (theo mẫu r36: sprite trực tiếp từng NPC, marker home_tile
  (3,3)/(8,6), Main load_map(15) + pick patrol từ nhà Quản Lý
  Penthouse).
- `tools/godot/run_regression.sh` thêm test mới (nay 65 suite).

### 59.3 Verify thật vòng này

- Hồi quy đầy đủ: **65 OK, 0 FAIL** (64 cũ + 1 mới r37).
- Smoke `--headless --quit-after 120` exit 0, 0 ERROR.
- Export web exit 0: pck **20.590.412 byte, SHA `50e9c300`**
  (trước `210e0a19`, +487.604 byte = 14 file art mới); wasm không
  đổi `fc74679e…`, `GODOT_THREADS_ENABLED = false`; HTTP 200 đủ
  4 file (cổng 8192).
- **Browser-verify thật** (Chromium 1255 + swiftshader, 720×1280,
  script `visual-check/artpass37/check_r37.py`, ảnh `r37-01…r37-15`;
  playwright còn nguyên sau VM restart, không cần cài lại):
  **0 console error, 0 pageerror, 0 requestfailed.** Xem ảnh
  thật: đi chuỗi Map001→Map015 qua đúng cửa (5,4)/(5,8) từng
  map; Map015 "Khu Penthouse" — Quản Lý Penthouse (vest xám than,
  cầm clipboard) + Cư Dân Penthouse (váy xanh ngọc, cầm túi mua
  sắm) hiện rõ mặt thật có nhãn tên, không còn vẽ code; cả 2 NPC
  patrol rời nhà sau 12s (Quản Lý từ giữa map lên mép trên-trái,
  Cư Dân xuống mép dưới-trái ở ảnh away); 2 ảnh xa nhà cách nhau
  2s pixel-diff = **5.718** (lá rơi + mây + NPC bob, cảnh sống).
- Lỗi tìm ra khi xem ảnh (cosmetic, không chặn): người chơi spawn
  Map015 ở (5,6) thay vì (5,4) — phím giữ lọt sang map mới 2
  bước (harness, không phải game; cùng mẫu vòng 36); đi xa tới
  (7,3) (phải ×5 + lên ×3 từ (5,6) nhưng 2 phím phải bị miss —
  harness, không phải game). Nhãn "Cư Dân Penthouse" đè lên thân
  người chơi ở ảnh home — cùng mẫu nhãn neo -170px + hiện trong
  Manhattan ≤5 ô đã thấy ở Map012/013/014, không phải nhãn sai.

### 59.4 Push + Deploy — XONG

- **Push main r37 XONG:** lô a (marker.gd + test r37 + .uid +
  run_regression.sh) `fe16e095` + lô b (14 file .import art Map015)
  `fdfc0227` + lô c (visual-check artpass37) `2f87c273` — head main
  sau lô c `2f87c273` (docs `db1f1484` đẩy trước khi viết §59,
  xem dưới).
- **Deploy gh-pages pck `50e9c300` XONG:** staging rebuild VERIFY
  OK (pck 153 chunk khớp byte, wasm + img không đổi); đẩy 10 lô
  chunk + 1 lô final: b1 chunk 000–015 `9ba70ff7`, b2 016–031
  `dcd14119`, b3 032–047 `429b7f0c`, b4 048–063 `bb06acbb`, b5
  064–079 `0f15f04e`, b6 080–095 `fc26abf27`, b7 096–111
  `b4ef0737`, b8 112–127 `7d499aeb`, b9 128–143 `b5b4720f`, b10
  144–152 `ae1109bf` (9 file — staging chỉ có 153 chunk 000–152,
  không phải 154 như ghi ban đầu), final (versions.json +
  index.html) `448495c7`. Sync record nay 379 mục.
  **Live đã chuyển sang pck `50e9c300` (vòng 37):** `--check-live`
  PASS (versions.json live `50e9c300`, index.html 200).
- Lưu ý: lô docs `db1f1484` đẩy TRƯỚC khi §59 được viết (script
  push chạy hết 4 lô trong 1 lần, trong khi docs lúc đó chưa có
  §59) — đã đẩy bù lô docs2 `b183b0de` sau khi viết xong §59, head
  main sau docs2 `b183b0de`. Deploy cũng dở dang ở lô b8
  khi hết lượt 10:45 (live vẫn `210e0a19` dù §59.4 bản nháp ghi
  "check-live PASS" — ghi sai, đã đính chính ở đây): b9/b10/final
  đẩy bù trong lượt 11:45, live mới chuyển sang `50e9c300` lúc
  ~12:10. Bài học: không ghi "live đã lên" khi chưa curl lại
  versions.json live sau lô final. Ngoài ra có 1 commit chunk 6
  trùng `7f197799` (retry đẩy lại cùng nội dung, không ghi vào
  sync — sync chỉ giữ `fc26abf27` cho cùng 16 file).

### 59.5 Việc tiếp theo

1. NPC Map016 walk cycle (Khu Sân Golf & Resort: 2 NPC theo
   `maps.json` map id 16) theo từng map, mẫu vòng này.
2. Sprite sạp tách riêng (§45.1): đổi hàng 0 thành sạp cách nhau
   (ô lẻ để trống) rồi gen 3 sprite sạp (rau/trái cây/cá-thịt).
3. Nhãn NPC chỉ hiện trong 5 ô + neo -170px nên nhãn NPC (8,6)
   dễ đè lên NPC (3,3) trong chiếu iso — cân nhắc cải thiện hiển
   thị nhãn (việc polish, không chặn).

## 60. Vòng 38 — Walk cycle NPC Map016: Nhân Viên Sân Golf + Quản Lý Resort (25/11 ~11:45–13:35 +07, cron 11:45)

Mục 1 §59.5: NPC Map016 walk cycle theo từng map. Vòng này làm
Map016 Khu Sân Golf & Resort: Nhân Viên Sân Golf (3,3) + Quản Lý
Resort (8,6).

### 60.1 Art (subagent, theo đúng quy trình vòng 37) — XONG

- Thư mục `visual-check/artpass38/`; ảnh đứng + sheet 6 khung cho
  Nhân Viên Sân Golf (nam, áo polo xanh nhạt + quần kaki be + giày
  thể thao trắng + mũ lưỡi trai xanh navy, cầm gậy golf + đeo túi
  gậy golf mini) + Quản Lý Resort (nữ, blazer xanh mint nhạt + váy
  bút chì xanh navy + giày cao gót đen, cầm sổ đặt phòng bìa da nâu
  + thẻ phòng vàng); xử lý trắng → trong suốt + cắt frame theo mẫu
  vòng 37 (connected component, MIN_FIG_W=100, MIN_FIG_H=100,
  `split_wide_component` MAX_FIG_W=600 + xóa vùng trắng kín ≥100
  final px) + bước cleanup mảnh vụn rời mới vòng này
  (`cleanup_frames_r38.py`).
- File đích: `src/godot/art/char_nhanviensangolf.png` (97×208) +
  `char_quanlyresort.png` (89×208),
  `walk_nhanviensangolf_f0..f5.png` (canvas chung 105×208) +
  `walk_quanlyresort_f0..f5.png` (canvas chung 120×208), RGBA.
- Kiểm tra bằng mắt: 2 ảnh đứng + 2 sheet; **ảnh đứng 0 lần gen
  lại; sheet Resort 0 lần; sheet golf 1 lần (v1 → v2)** — v1 lỗi
  đạo cụ chéo hình: gậy golf chéo sang trái, đầu gậy hình sau nằm
  bên trái đường cắt nên bị gán nhầm sang hình trước + dải dây đen
  nối các hình (f1 có 2 đầu gậy, f2 gậy đứt, f3 gậy mất đầu);
  prompt v2 siết thêm "gậy dựng đứng sát thân, đầu gậy gần bàn
  chân, không chéo sang hình kế, không vật nào chạm sang hình kế"
  thì đạt ngay. Bài học mới: NPC cầm đạo cụ DÀI (gậy, ô, cần
  câu...) thì siết "dựng đứng sát thân" ngay từ lần gen đầu — lỗi
  chéo hình không sửa được bằng cắt cột; script cleanup mảnh vụn
  rời (`cleanup_frames_r38.py`: giữ component lớn nhất + ≥5% diện
  tích, xóa phần còn lại + quầng feather) nên chạy mặc định sau mỗi
  lần cắt frame. Slice vẫn cần `split_wide_component` (f1+f2 và
  f2+f3 dính nhau 2D qua túi/mũ — cắt đúng khe, đã kiểm tra bằng
  mắt từng frame). Đạo cụ đủ 6/6 hình cả 2 NPC.
- Hạn chế (chấp nhận, ghi trong note): thẻ phòng vàng có chữ nhỏ mờ
  (không đọc được ở kích thước sprite); váy bút chì ôm che chân
  (chỉ thấy bàn chân/giày đổi vị trí); f5 cả hai gần như tư thế
  đứng. Chi tiết:
  `visual-check/artpass38/walkcycle-npc-map016-note.md`.

### 60.2 Code + test — XONG

- `marker.gd` NPC_STYLE thêm `"nhan-vien-san-golf"` (polo xanh
  nhạt (0.55,0.75,0.90), tóc "ngan", texture + frames) +
  `"quan-ly-resort"` (blazer mint (0.55,0.85,0.75), tóc "dai",
  texture + frames). Không sửa logic `CharacterSprite`/
  `Marker`. Tên file art khớp NPC id bỏ dấu gạch nối ngay khi art
  về (`nhanviensangolf` / `quanlyresort`) — không tái phạm lỗi
  vòng 36.
- Test mới `tests/g4_r38_npc_walk_map016_test.gd`: **29/29 PASS**
  (theo mẫu r37: sprite trực tiếp từng NPC, marker home_tile
  (3,3)/(8,6), Main load_map(16) + pick patrol từ nhà Nhân Viên
  Sân Golf).
- Sửa kèm (lỗi copy-paste tìm ra khi viết test r38): test r37
  `NPC_TEX` trỏ nhầm sang ảnh đứng của vòng 36
  (`char_quangiadao.png` / `char_chubietthudao.png`) — test vẫn
  pass 29/29 vì chỉ kiểm tra tồn tại + đổi khung, không kiểm tra
  đúng ảnh đứng. Đã sửa về đúng 2 file Map015, chạy lại r37:
  **29/29 PASS** trở lại.
- `tools/godot/run_regression.sh` thêm test mới (nay 66 suite;
  sửa luôn chú thích cũ "45 suite").

### 60.3 Verify thật vòng này

- Hồi quy đầy đủ: **66 OK, 0 FAIL** (65 cũ + 1 mới r38).
- Smoke `--headless --quit-after 120` exit 0, 0 ERROR.
- Export web exit 0: pck **21.033.792 byte, SHA `b87c03bf`**
  (trước `50e9c300`, +443.380 byte = 14 file art mới); wasm không
  đổi `fc74679e…`, `GODOT_THREADS_ENABLED = false`; HTTP 200 đủ
  4 file (cổng 8193).
- **Browser-verify thật** (Chromium 1255 + swiftshader, 720×1280,
  script `visual-check/artpass38/check_r38.py`, ảnh `r38-01…r38-17`;
  playwright phải cài lại vì VM restart gỡ module — như vòng 36):
  **0 console error, 0 pageerror, 0 requestfailed.** Xem ảnh
  thật: đi chuỗi Map001→Map016 qua đúng cửa (5,4)/(5,8) từng
  map; Map016 "Khu Sân Golf & Resort" — Nhân Viên Sân Golf (mũ
  navy, polo xanh nhạt, cầm gậy) + Quản Lý Resort (blazer mint,
  váy navy, cầm sổ) hiện rõ mặt thật có nhãn tên, không còn vẽ
  code; cả 2 NPC patrol rời nhà sau 12s (golf ra mép trái, resort
  xuống gần cửa ở ảnh away); 2 ảnh xa nhà cách nhau 2s pixel-diff
  = **18.769** (lá rơi + mây + NPC bob, cảnh sống). Nhãn "Quản Lý
  Resort" đè lên thân Nhân Viên Sân Golf ở ảnh home — cùng mẫu
  nhãn neo -170px + hiện trong Manhattan ≤5 ô đã thấy ở
  Map012/013/014/015, không phải nhãn sai.

### 60.4 Push + Deploy — XONG TRỌN (main + deploy + docs)

- **Push main r38 XONG:** lô a (marker.gd + test r38 + .uid +
  sửa test r37 + run_regression.sh) `dc3567e3` + lô b (14 file
  .import art Map016) `83eeb29b` + lô c (visual-check artpass38:
  note + 4 script + check_r38.py) `3aecd20e` — head main sau lô c
  `3aecd20e`.
- **Deploy gh-pages pck `b87c03bf` XONG:** staging rebuild VERIFY
  OK (pck 156 chunk khớp byte, wasm + img không đổi); đẩy 10 lô
  chunk + 1 lô final: b1 000–015 `334b8a06`, b2 016–031
  `52681df6`, b3 032–047 `944aacb2`, b4 048–063 `817892c0`, b5
  064–079 `8792674b`, b6 080–095 `6b0e0518`, b7 096–111
  `dc6e1b3f`, b8 112–127 `1b5dd378`, b9 128–143 `a0de51fe`, b10
  144–155 `a825e000` (12 file), final (versions.json +
  index.html) `68cafb66`. Sync record nay 399 mục.
  **Live đã chuyển sang pck `b87c03bf` (vòng 38):** `--check-live`
  PASS (versions.json live `b87c03bf`, index.html 200) — sau ~3
  phút CDN lag (lúc đầu vẫn hiện `50e9c300`).
- Bài học deploy vòng này (3 điểm, ghi để không tái phạm):
  (1) Phê duyệt GitHub trong lượt detached này chậm theo đợt
  (mỗi lô chờ 2–13 phút); driver bị kill giữa chừng KHÔNG hủy
  write phía server — lô đang chờ vẫn hoàn tất sau khi phê
  duyệt tới (chunk-5/6/7 đều lên remote sau khi driver đã chết),
  nên sau mỗi lần kill phải kiểm tra remote bằng blob SHA rồi
  mới chạy tiếp, không đẩy lại mù. (2) URI SHA của
  `get_file_contents` là HEAD của branch lúc query, KHÔNG phải
  commit đã thêm file đó — đã ghi nhầm SHA chunk-6 (lấy
  `dc6e1b3f` là head lúc đó, đúng ra là `6b0e0518`); muốn biết
  commit thật thì đọc chuỗi `list_commits`, không dùng URI SHA
  làm sync base cho từng file. (3) Retry tạo commit trùng: b2 có
  thêm `5b38d91c`, b7 có thêm `8aa93bd7` (cùng nội dung); commit
  trùng làm head lệch khỏi sync → lô chunk-8 lỗi "not a fast
  forward" — sửa bằng cách ghi thêm entry cho commit trùng
  (`8aa93bd7`) rồi đẩy tiếp là thông.
- Lô docs (godot-g4 §60 + roles-qc) `b8d13cb2` (thẻ phê duyệt
  cũng chờ ~4 phút mới thông, như lô deploy); đính chính §60.4
  sau khi deploy xong: xem lô docs2 dưới.

### 60.5 Việc tiếp theo

1. NPC Map017 walk cycle (Công Viên An Bình: Cô Bán Bánh + Ông
   Lão Tập Thể Dục) theo từng map, mẫu vòng này — nhớ bài học
   vòng 38: đạo cụ dài siết "dựng đứng sát thân" ngay từ lần gen
   đầu; chạy cleanup mảnh vụn rời mặc định sau cắt frame.
2. NPC Map017 walk cycle (Công Viên An Bình: Cô Bán Bánh + Ông
   Lão Tập Thể Dục) theo từng map, mẫu vòng này — nhớ bài học
   vòng 38: đạo cụ dài siết "dựng đứng sát thân" ngay từ lần gen
   đầu; chạy cleanup mảnh vụn rời mặc định sau cắt frame.
3. Sprite sạp tách riêng (§45.1): đổi hàng 0 thành sạp cách nhau
   (ô lẻ để trống) rồi gen 3 sprite sạp (rau/trái cây/cá-thịt).

## 61. Vòng 39 — Walk cycle NPC Map017: Cô Bán Bánh + Ông Lão Tập Thể Dục (25/11 ~13:45–15:00 +07, cron 13:45)

Mục 1 §60.5: NPC Map017 walk cycle theo từng map. Vòng này làm
Map017 Công Viên An Bình: Cô Bán Bánh (3,3) + Ông Lão Tập Thể
Dục (8,6).

### 61.1 Art (subagent, theo đúng quy trình vòng 38) — XONG

- Thư mục `visual-check/artpass39/`; ảnh đứng + sheet 6 khung cho
  Cô Bán Bánh (nữ, áo bà ba hồng đào + tạp dề xanh lá + nón lá,
  cầm giỏ bánh + khay bánh) + Ông Lão Tập Thể Dục (nam, tóc bạc,
  áo thun thể thao xanh nhạt + quần thể thao xám + giày thể thao,
  khăn tập vàng cam vắt vai + bình nước xanh cầm tay); xử lý trắng
  → trong suốt + cắt frame theo mẫu vòng 38 (connected component,
  MIN_FIG_W=100, MIN_FIG_H=100, `split_wide_component` MAX_FIG_W=600
  + xóa vùng trắng kín ≥100 final px) + bước cleanup mảnh vụn rời
  mặc định (`cleanup_frames_r39.py`).
- File đích: `src/godot/art/char_cobanbanh.png` (122×208) +
  `char_onglaotaptheduc.png` (86×208),
  `walk_cobanbanh_f0..f5.png` (canvas chung 138×208) +
  `walk_onglaotaptheduc_f0..f5.png` (canvas chung 140×208), RGBA.
- Kiểm tra bằng mắt: 2 ảnh đứng + 2 sheet; **ảnh đứng 0 lần gen
  lại; sheet Ông Lão 0 lần; sheet Cô Bán Bánh 2 lần (v1 → v2 →
  v3)** — v1 thiếu khay ở f1/f3; v2 đủ khay nhưng thiếu giỏ ở f5;
  v3 siết mỗi đạo cụ bằng một câu riêng ("khay luôn ở tay phải /
  giỏ luôn ở tay trái trong mọi hình") thì đủ cả 2 đạo cụ ở cả 6
  hình. Bài học mới: NPC cầm 2 đạo cụ thì siết MỖI đạo cụ bằng
  MỘT CÂU RIÊNG gắn với tay cầm cố định ngay từ lần gen đầu — câu
  gộp "cả 2 đạo cụ phải rõ" làm generator bỏ 1 đạo cụ ở vài hình.
- Cắt sheet: cả 2 sheet tách đúng 6 component riêng, không cần
  `split_wide_component` (câu siết khoảng trắng giữa các hình đã
  phát huy). Cleanup: 12 frame không đổi (mỗi frame đúng 1
  component, không mảnh vụn mép); chỉ xóa 2px vết rời ở
  `char_onglaotaptheduc.png`. Debug-white: chỉ f3 Cô Bán Bánh xóa
  123 final px — đã đối chiếu zoom: đó là nền nhìn xuyên qua quai
  giỏ, không phải bánh; giỏ + khay còn nguyên. Vùng trắng kín còn
  lại lớn nhất 60–70px (<100, giữ đúng thiết kế: chóp bánh kem,
  bánh trong giỏ). Bình nước trong của Ông Lão được giữ nguyên,
  không bị thủng.
- Hạn chế (chấp nhận, ghi trong note): quần đen + áo bà ba dài che
  chân Cô Bán Bánh (chủ yếu thấy dép đổi vị trí); giỏ/khay + bình
  nước đổi bên/đổi tay theo nhịp đi giữa các frame (không phải lỗi,
  đạo cụ vẫn hiện liên tục cả 6 frame); f5 cả hai gần như tư thế
  đứng. Chi tiết:
  `visual-check/artpass39/walkcycle-npc-map017-note.md`.

### 61.2 Code + test — XONG

- `marker.gd` NPC_STYLE thêm `"co-ban-banh"` (áo hồng đào
  (0.93,0.60,0.55), tóc "dai", texture + frames) +
  `"ong-lao-tap-the-duc"` (áo xanh nhạt (0.55,0.75,0.85), tóc
  "ngan", texture + frames). Không sửa logic `CharacterSprite`/
  `Marker`. Tên file art khớp NPC id bỏ dấu gạch nối ngay khi art
  về (`cobanbanh` / `onglaotaptheduc`).
- Test mới `tests/g4_r39_npc_walk_map017_test.gd`: **29/29 PASS**
  (theo mẫu r38: sprite trực tiếp từng NPC, marker home_tile
  (3,3)/(8,6), Main load_map(17) + pick patrol từ nhà Cô Bán
  Bánh).
- `tools/godot/run_regression.sh` thêm test mới (nay 67 suite).

### 61.3 Verify thật vòng này

- Hồi quy đầy đủ: **67 OK, 0 FAIL** (66 cũ + 1 mới r39).
- Smoke `--headless --quit-after 120` exit 0, 0 ERROR.
- Export web exit 0: pck **21.532.816 byte, SHA `a6d7e36b`**
  (trước `b87c03bf`, +499.024 byte = 14 file art mới); wasm không
  đổi `fc74679e…`, `GODOT_THREADS_ENABLED = false`; HTTP 200 đủ
  4 file (cổng 8194).
- Playwright phải cài lại vì VM restart gỡ module (như vòng 36/38)
  — browser Chromium 1255 còn trong cache, chỉ cài lại package pip
  (`pip3 install --break-system-packages playwright`).
- **Browser-verify thật** (Chromium 1255 + swiftshader, 720×1280,
  script `visual-check/artpass39/check_r39.py`, ảnh `r39-01…r39-18`):
  **0 console error, 0 pageerror, 0 requestfailed.** Xem ảnh
  thật: đi chuỗi Map001→Map017 qua đúng cửa (5,4)/(5,8) từng
  map; Map017 "Công Viên An Bình" — Cô Bán Bánh (nón lá, áo hồng
  đào, giỏ + khay bánh) + Ông Lão Tập Thể Dục (tóc bạc, áo xanh
  nhạt, bình nước xanh) hiện rõ mặt thật có nhãn tên, không còn vẽ
  code; cả 2 NPC patrol rời nhà sau 12s (Cô Bán Bánh ra mép trái,
  Ông Lão sang gần cửa ở ảnh away); 2 ảnh xa nhà cách nhau 2s
  pixel-diff = **25.884** (lá rơi + mây + NPC bob, cảnh sống).
  Nhãn "Ông Lão Tập Thể Dục" đè lên thân Cô Bán Bánh ở ảnh home —
  cùng mẫu nhãn neo -170px + hiện trong Manhattan ≤5 ô đã thấy ở
  Map012/013/014/015/016, không phải nhãn sai.

### 61.4 Push + Deploy — XONG TRỌN (main + deploy + docs)

- **Push main r39 XONG:** lô a (marker.gd + test r39 + .uid +
  run_regression.sh) `51105053` + lô b (14 file .import art
  Map017) `1c508d89` + lô c (visual-check artpass39: note + 5
  script + check_r39.py) `dd4399b4` — head main sau lô c
  `dd4399b4`.
- **Deploy gh-pages pck `a6d7e36b` XONG:** staging rebuild VERIFY
  OK (pck 160 chunk khớp byte, wasm + img không đổi); đẩy 10 lô
  chunk + 1 lô final: b1 000–015 `46f26bf5`, b2 016–031
  `75de3782`, b3 032–047 `fd42f28c`, b4 048–063 `f9c81d8c`, b5
  064–079 `9d4a8d35`, b6 080–095 `194df6bb`, b7 096–111
  `75766d23`, b8 112–127 `f76cb2e5`, b9 128–143 `0e882325`, b10
  144–159 `6fe93e85` (16 file), final (versions.json +
  index.html) `46e4b410`. Sync record nay 414 mục.
  **Live đã chuyển sang pck `a6d7e36b` (vòng 39):** `--check-live`
  PASS (versions.json live `a6d7e36b`, index.html 200) — lúc đầu
  vẫn hiện `b87c03bf` do CDN lag ~3 phút (như vòng 38), kiểm lại
  sau thì PASS.
- Lô docs (godot-g4 §61 + roles-qc) `XEM DƯỚI`.

### 61.5 Việc tiếp theo

1. NPC Map018 walk cycle (Phố Đi Bộ – Chợ Đêm: Chủ Sạp Đêm +
   Người Bán Hàng Rong) theo từng map, mẫu vòng này — nhớ bài học
   vòng 39: 2 đạo cụ thì siết mỗi đạo cụ một câu riêng gắn tay cầm
   cố định.
2. Sprite sạp tách riêng (§45.1): đổi hàng 0 thành sạp cách nhau
   (ô lẻ để trống) rồi gen 3 sprite sạp (rau/trái cây/cá-thịt).
