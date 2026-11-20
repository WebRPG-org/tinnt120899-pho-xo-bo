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
  `index.html` cuối): [ghi sau khi push xong]
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
  là nút thắt; loader cũ đo cùng setup là 24,8s).
- Verify từ site live (curl): [ghi sau khi deploy xong]
- Ảnh kiểm chứng: `visual-check/artpass9/` (`a9-01…a9-07`,
  `live-title.png` + script `check_live_load.py`,
  `check_artpass9_verify.py`).
- Caveat cho parent: **chưa kiểm live bằng cloud browser
  trên URL thật** (Chromium local không mở được github.io)
  — parent cần chạy kiểm live cuối trước khi báo user.
