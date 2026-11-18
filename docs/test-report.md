# Báo cáo kiểm tra — Phố Xô Bồ

> **Đây là kiểm tra TĨNH, chưa phải build / test chạy được.**
> VM này không có dotnet / Unity / csc nên không biên dịch được code C#,
> không chạy được server, không chơi được game. Báo cáo này chỉ chứng minh:
> ngoặc cân bằng, số chốt khớp nhau giữa code và docs, không có secret,
> ranh giới pháp lý bị chặn trong code. Muốn test chạy được thật phải có
> máy build (xem `docs/roles-qc.md` §6).

## Lần chạy mới nhất: 19/11/2026 ~03:55 (giờ VN)

- Lệnh: `python3 src/server/tests/check_static.py` (chạy từ gốc repo)
- Kết quả: **223/223 PASS, exit 0** — tăng từ 219/219: nhóm T19 mới (4 mục)
  khóa plugin mới; `node --check` nay 13/13 file JS nadia.
- **1 plugin slice mới (Giai đoạn 2):** `PXB_Social.js` (585 dòng, port
  `Social.cs` / GDD Mục 8: 7 loại quan hệ, 6 stage, bỏ bê 7 ngày giảm thân
  thiết, hỗ trợ +20% EXP, solo chậm 40%, ly hôn, hội bạn tan sau 7 ngày
  không họp, NPC bạn thân lấp chỗ `seedSlice`; quan hệ lưu object thuần
  trong `$gameSystem.pxbSocial` để vào save; plugin command Interact /
  Neglect / AdvanceStage / Divorce / SeedSlice; smoke 85/85 PASS) +
  `plugins.js` nay 11 plugin (…Economy → Social).
- **Kế hoạch tileset CC0 (luồng song song):** `docs/tileset-plan.md` mới
  (230 dòng): Kenney Isometric Tiles City/Landscape/Buildings/Roads
  (CC0, URL đã verify) là ưu tiên 1; Screaming Brain 1000+ Isometric
  Floor Tiles (OpenGameArt, CC0, 1.049 tile, 256×128 / 128×64) ưu tiên 2
  cho sàn; Unity Top-Down Starter Kit chỉ tham khảo (không phải tileset
  iso). Kết luận kỹ thuật: KHÔNG ép tile iso 64×32 vào layout tileset MV
  (ô vuông 48×48) — dùng atlas theo khu qua `PXB_Isometric.js`, tile
  downscale về 64×32, tường/vật cao vẽ dạng sprite neo đáy. PNG nhị phân
  KHÔNG push được qua snapshot push (chỉ nhận UTF-8) — đưa vào repo bằng
  git push từ máy có git hoặc upload web GitHub; chưa tải file nhị phân
  nào vào repo trong lần này.
- **Lệch / PROVISIONAL ghi nhận khi port (chưa sửa nguồn):** (1) Social:
  `applyNeglect` trả drop tính theo công thức (có thể lớn hơn phần trừ
  thực khi thân thiết kẹp về 0) + KHÔNG cập nhật `lastInteractionGameDay`
  (quirk C# — gọi 2 lần cùng ngày trừ 2 lần, event chỉ gọi 1 lần/ngày);
  `advanceStage` không kiểm tra Kind (để GDD/PM xem lại, như đã ghi từ
  18/11); `divorce` dùng `||` (bug đã sửa 18/11 — T19d khóa hồi quy, chỉ
  Spouse đang Cuoi mới ly hôn được); `seedSlice` thêm NPC "Bạn thân"
  (personId `ban-than`, tên TẠM — GDD Mục 11 chưa chốt tên, PXB_Story
  sau này thay bằng NPC thật); solo penalty 40% là điểm giữa khoảng
  30–50% đã chốt; ngưỡng stage 50/70/80 + thân thiết khởi đầu 20 +
  interact +5 + giảm bỏ bê 10/bước đều PROVISIONAL. (2) Tileset: kích
  thước tile Kenney + tên file thật + checksum SHA-256 CHƯA CÓ (ghi trong
  tileset-plan.md §6, đo sau khi tải).
- **Còn lại chưa xong (Giai đoạn 2):** tile data toàn 0 (chưa có tileset
  CC0 nên IsoTilemap chưa vẽ được gì thật), img/audio trống, plugin còn
  lại (PXB_Titles/Story…) chưa viết. Việc tiếp theo lớn nhất:
  PXB_Titles.js + PXB_Story.js, rồi tải tile Kenney/SBS + đóng atlas theo
  tileset-plan.md §4 (PNG đưa vào repo bằng git push, không qua snapshot).
- **Vẫn chưa chạy được:** xUnit (17 test) và EditMode test (219 test) chưa
  biên dịch/chạy lần nào (dotnet 8.0.428 có ở `~/.dotnet`, `dotnet test`
  vẫn kẹt RAM — chạy qua GitHub Actions; Unity chưa có).

## Lần chạy mới nhất: 19/11/2026 ~02:55 (giờ VN)

- Lệnh: `python3 src/server/tests/check_static.py` (chạy từ gốc repo)
- Kết quả: **219/219 PASS, exit 0** — tăng từ 215/215: nhóm T18 mới (4 mục)
  khóa 2 plugin mới; `node --check` nay 12/12 file JS nadia.
- **2 plugin slice mới (Giai đoạn 2):** `PXB_Education.js` (589 dòng, port
  GDD Mục 5 / `GameBalance.Degrees`: 5 bậc đúng học phí/ngày/Trí/EXP/Danh
  vọng/mentor; enroll chặn `chua-du-tri` / `can-mentor` (Tiến sĩ) /
  `khong-du-tien` / `da-co-bang` / `dang-hoc`; tiến độ theo ngày game,
  tốt nghiệp ghi `pendingExp`/`pendingFame` để event áp; khóa ngắn hạn
  3–7 ngày, 2–10 triệu, +10 một chỉ số phụ; học bổng xét Trí + tiền;
  ghế/khóa 20–30 + `registerOrder`; smoke 89/89 PASS) +
  `PXB_Economy.js` (577 dòng, port `Economy.cs`: catalog đủ 17 món
  6 nhà + 6 xe + 2 điện thoại + 3 quần áo đúng giá/chỉ số; ví riêng
  tiền mặt/tiết kiệm/`creditScore` 100; lãi 0,5%/tháng game 30 ngày;
  gửi/rút tiết kiệm; mua nhà/xe-sang +50 Danh vọng; đấu giá người bán
  nhận giá − phí 5%; barter; chia tài sản ly hôn; set bonus đủ 3 món;
  dress-code; 4 hàm cấm luôn false; smoke 78/78 PASS); `plugins.js`
  nay 10 plugin (Balance → … → PhoneHub → Education → Economy).
- **3 lỗi script trong lần chạy này (đã sửa, chạy lại PASS):** T14t/T16d/
  T17c lúc đầu FAIL giả — 3 check cũ bắt đúng 8 plugin (`== 8`), nay
  đã 10. Đã sửa thành `>= 8` (chỉ khóa 8 plugin gốc + thứ tự); T18c
  mới đếm đủ 10.
- **Lệch / PROVISIONAL ghi nhận khi port (chưa sửa nguồn):** (1)
  Education: học phí trả 1 lần lúc đăng ký (GDD chưa chốt trả trước
  hay góp); không học lại bằng đã có/bằng cao hơn (GDD chưa chốt học
  nhảy bậc); ngưỡng học bổng Trí ≥ 60 + tiền < 20tr (GDD chỉ nói
  "người nghèo mà Trí cao"); ghế 20–30 + thứ tự đăng ký, plugin không
  tự chặn hết ghế; tốt nghiệp chỉ ghi `pendingExp`/`pendingFame`/
  `pendingStatGain` để event áp (chưa có hệ EXP/Danh vọng chung, không
  tự gọi PXB_Stats); được học song song 1 bằng + 1 khóa ngắn hạn
  (GDD chưa chốt học chồng). (2) Economy: ví riêng trong
  `$gameSystem.pxbEconomy`, KHÔNG dùng `$gameParty.gold()` như Jobs —
  khi nối MV thật cần đồng bộ 1 chiều qua event; quirk
  `Buy("phong-tro")` giữ đúng C# (trừ 2tr thuê nhưng vẫn thêm vào
  Owned nên tổng tài sản không đổi); dress-code chỉ xét đồ loại
  Clothes nên xe sang set "Sang trọng" vẫn KHÔNG qua.
- **Còn lại chưa xong (Giai đoạn 2):** tile data toàn 0 (chưa có tileset
  CC0 nên IsoTilemap chưa vẽ được gì thật), img/audio trống, plugin còn
  lại (PXB_Social/Titles/Story…) chưa viết. Việc tiếp theo lớn nhất:
  PXB_Social.js, rồi tileset CC0 + tile data thật cho Map001–002 để mở
  trình duyệt thấy map Xóm Trọ Cũ.
- **Vẫn chưa chạy được:** xUnit (17 test) và EditMode test (219 test) chưa
  biên dịch/chạy lần nào (dotnet 8.0.428 có ở `~/.dotnet`, `dotnet test`
  vẫn kẹt RAM — chạy qua GitHub Actions; Unity chưa có).

## Lần chạy mới nhất: 19/11/2026 ~01:50 (giờ VN)

- Lệnh: `python3 src/server/tests/check_static.py` (chạy từ gốc repo)
- Kết quả: **215/215 PASS, exit 0** — tăng từ 211/211: nhóm T17 mới (4 mục)
  khóa 2 plugin mới; `node --check` nay 10/10 file JS nadia.
- **2 plugin slice mới (Giai đoạn 2):** `PXB_Crafting.js` (537 dòng, port
  `Crafting.cs`: 3 công thức đúng số C# — xe-đẩy 1/2/2, đèn-soi 2/2, quà-tặng
  2/1; ToolBehaviour 4 tool × 3 bậc; CanCraft/Craft/MissingIngredients; Craft
  trừ đúng + xóa key về 0; học công thức qua NPC `learnRecipe`/`craftCurrent`
  chặn `chua-hoc-cong-thuc`; túi nguyên liệu chung `$gameSystem.pxbMaterials`
  với Hotspot; smoke 52/52 PASS) + `PXB_PhoneHub.js` (381 dòng, port
  `PhoneHub.cs`: 9 tab đúng thứ tự, Open/Close/Toggle/SelectTab,
  Notify/Unread/TotalUnread, callback `onTabChanged`/`onOpenChanged`, plugin
  command, phím P qua `Scene_Map.update`; smoke 56/56 PASS); `plugins.js`
  nay 8 plugin (Balance → Stats → Time → Isometric → Hotspot → Crafting →
  Jobs → PhoneHub).
- **Bug thật phát hiện khi smoke test PhoneHub (đã sửa bằng code):** gọi
  `install()` 2 lần wrap core 2 lần khiến plugin command/phím P kích hoạt
  2 lần — đã sửa bằng guard `_installed` (chỉ khóa khi lần trước đã móc
  được core), sau đó 56/56 mới đạt.
- **Lệch phát hiện khi port (ghi nhận, chưa sửa nguồn):** (1) Crafting: GDD
  Mục 6/7 không có số chế tạo nào (chỉ nhắc "cổng tiến trình" + side quest
  chế quà tặng) — toàn bộ số lấy từ `Crafting.cs`, PROVISIONAL; chỉ có công
  thức bậc 1 (C# cũng vậy — công thức nâng cấp tool bậc 2/3 thuộc
  `PXB_Tools.js` / GDD chưa chốt); `item:qua-tang` chưa có Item trong
  `data/Items.json` nên plugin chỉ đếm trong `craftedItems`, chưa cộng vào
  `$gameParty`; cơ chế "đã học" là thêm mới (C# chỉ ghi `UnlockNote` bằng
  chữ) — mặc định chưa học công thức nào, New Game / `PXB_Story` sau này
  phải gọi `learnRecipe`, nếu không slice chưa chế được gì; "cổng tiến
  trình" chưa nối mở khu (do `PXB_Story`/`PXB_Hotspot` giữ). (2) PhoneHub:
  Notify đếm cả khi đóng + Open/SelectTab luôn kích hoạt TabChanged kể cả
  đúng tab hiện tại — giữ đúng C#, để GDD/PM xem lại; chính tả "Sức khỏe"
  theo C# (GDD viết "Sức khoẻ"); phím P / nút điện thoại không có trong
  `PhoneHub.cs` — plugin thêm hook phím P, nút trên màn hình là việc của
  lớp UI, chưa làm.
- **Còn lại chưa xong (Giai đoạn 2):** tile data toàn 0 (chưa có tileset
  CC0 nên IsoTilemap chưa vẽ được gì thật), img/audio trống, plugin còn
  lại (PXB_Education/Economy/Social/Titles/Story…) chưa viết. Việc tiếp
  theo lớn nhất: PXB_Education.js + PXB_Economy.js, rồi tileset CC0 + tile
  data thật cho Map001–002 để mở trình duyệt thấy map Xóm Trọ Cũ.
- **Vẫn chưa chạy được:** xUnit (17 test) và EditMode test (219 test) chưa
  biên dịch/chạy lần nào (dotnet 8.0.428 có ở `~/.dotnet`, `dotnet test`
  vẫn kẹt RAM — chạy qua GitHub Actions; Unity chưa có).

## Lần chạy mới nhất: 19/11/2026 ~00:50 (giờ VN)

- Lệnh: `python3 src/server/tests/check_static.py` (chạy từ gốc repo)
- Kết quả: **211/211 PASS, exit 0** — tăng từ 206/206: nhóm T16 mới (5 mục)
  khóa Isometric v2 + 2 plugin mới; `node --check` nay 8/8 file JS nadia.
- **PXB_Isometric v2 — ĐÃ MÓC TILEMAP (việc tiếp theo lớn nhất, xong):**
  `PXB_IsoTilemap` kế thừa `Tilemap` (prototype chain nối trong `install()`),
  vẽ tile thường (B–E + A5) thành hình thoi 64×32 bằng sprite MV quay 45° +
  co (64/(48√2), 32/(48√2)); `Game_CharacterBase.screenX/screenY` chiếu
  isometric (giữ `screenZ` gốc — sắp xếp chiều sâu tự đúng vì nhân vật là
  con của Tilemap và `_sortChildren` xếp theo z rồi y iso);
  `Spriteset_Map.createTilemap` dựng IsoTilemap (fallback về cách dựng gốc
  nếu lỗi); cuộn map đổi `origin` MV thành độ dời iso của lớp tile.
  Smoke test stub core MV (`/tmp/pxb-iso-smoke.js`, không commit): **36/36
  PASS** (origin map 12×9 = {280, 472}, screenX/screenY (5,4) = (344, 648),
  vẽ đúng 2 tile thường + bỏ 1 autotile, sprite thoi đúng frame/quay/tỉ lệ/
  vị trí, pan origin (48,0) = (−32,−16), alias createTilemap);
  `install()` không có core trả false. Giới hạn v2: autotile A1–A4, bóng,
  mép bàn CHƯA vẽ (đếm vào `stats`); vẽ hết map không cắt viewport; cuộn
  vẫn theo luật MV gốc (tile 48px) nên tâm cuộn chỉ gần đúng.
- **2 plugin slice mới (Giai đoạn 2):** `PXB_Hotspot.js` (484 dòng, port
  `Exploration.cs`: 5 hotspot, nhặt 1 lần/ngày game, chặn sai khung
  `wrong-frame`, GuideHint 4 NPC + Bạn thân, lưu `$gameSystem.pxbHotspot`;
  smoke 26/26 PASS) + `PXB_Jobs.js` (548 dòng, port `Jobs.cs`: 3 nghề,
  lương mốc 50/0/100, khung tốt +25%, quota 14, cung–cầu xoay tuần
  PROVISIONAL, thi chứng chỉ theo GDD; smoke 40/40 PASS); `plugins.js`
  nay 6 plugin (Balance → Stats → Time → Isometric → Hotspot → Jobs).
- **Lệch phát hiện khi port (ghi nhận, chưa sửa nguồn):** (1) Hotspot:
  `Exploration.Explore()` KHÔNG kiểm tra khung (chỉ dùng `BestFrame` để
  sắp xếp + sáng hơn) nhưng architecture §6 dòng 5 ghi "chỉ có đồ đúng
  khung" — plugin chặn sai khung theo architecture, khi C# sửa theo thì
  khớp; `districts.md` không có dữ liệu hotspot nào; `Exploration.cs`
  không định nghĩa độ hiếm (cả 5 hotspot đều "thường"). (2) Jobs:
  `Jobs.cs` hoàn toàn không có logic thi chứng chỉ — hệ thi (phí 5–20tr,
  trượt mất phí, chờ tuần sau, nạp mua thêm 1 lượt/tuần) chỉ có trong GDD
  Mục 6 + architecture §4.4; plugin triển khai thi theo GDD. Không lệch
  số nào khác (lương/quota/khung/cung–cầu khớp Jobs.cs + GameBalance +
  PXB_Balance + GDD).
- **Còn lại chưa xong (Giai đoạn 1–2):** tile data toàn 0 (chưa có tileset
  CC0 nên IsoTilemap chưa vẽ được gì thật), img/audio trống, plugin còn
  lại (PXB_PhoneHub/Crafting/Education/Economy/Social/Titles/Story…)
  chưa viết. Mở trình duyệt lúc này hết 404 ở core nhưng vẫn chưa chơi
  được — trạng thái thật, không giấu.
- **Vẫn chưa chạy được:** xUnit (17 test) và EditMode test (219 test) chưa
  biên dịch/chạy lần nào (dotnet 8.0.428 có ở `~/.dotnet`, `dotnet test`
  vẫn kẹt RAM — chạy qua GitHub Actions; Unity chưa có).

## Lần chạy mới nhất: 19/11/2026 ~00:05 (giờ VN)

- Lệnh: `python3 src/server/tests/check_static.py` (chạy từ gốc repo)
- Kết quả: **206/206 PASS, exit 0** — tăng từ 198/198: nhóm T15 mới (8 mục)
  khóa core MV + 2 plugin mới.
- **Core MV v1.6.1 ĐÃ VỀ (Giai đoạn 1):** 12/12 file trong `src/nadia/www/`
  (6 `js/rpg_*.js` + 6 `js/libs/*`, tổng 2.341.224 byte), `node --check`
  12/12 PASS. Nguồn: `rpgtkoolmv/corescript` tag community 1.3b — repo
  KHÔNG có tag v1.6.1; tag 1.3b chính là core v1.6.1 (header mỗi file ghi
  "v1.6.1 (community-1.3b)"); 6 file rpg build bằng đúng `concat.js` của
  repo; pixi.js v4.5.4 lấy từ bundle MV 1.6.1 (MIT). Chỉ lấy code core +
  libs MIT — không lấy asset/nhạc/nhân vật/map/cốt truyện của Nadia hay
  RPG Maker. 1 lỗi script trong lần chạy này (đã sửa, chạy lại PASS): T15g
  lúc đầu FAIL giả — check tìm "core MV v1.6.1" thường trong khi comment
  index.html ghi "Core MV v1.6.1" hoa C. 1 lỗi phát hiện khi viết T15 (đã
  sửa trong script, không phải code game): `secret_pat` quét trúng chuỗi
  "password=<redacted>" trong comment ví dụ của pixi.js — T14ab nay chỉ quét file
  do mình viết; code upstream MIT được khóa riêng ở T15a–c (header +
  node --check + UTF-8).
- **2 plugin slice mới (Giai đoạn 2, port từ C#):** `PXB_Stats.js` (261
  dòng: 3 gốc Thể/Trí/Tâm + 4 trộn Kỷ/Dũng/Sáng/An Yên + trần tổng 300
  PROVISIONAL + Train đánh đổi + lưu `$gameSystem.pxbStats` đi theo save)
  + `PXB_Time.js` (268 dòng: 1 ngày 30 phút, 3 khung 10 phút, miss không
  phạt, sự kiện thứ 7 20:00 giờ game); `node --check` PASS; smoke test
  logic thuần qua `module.exports` PASS (ctor tổng = 300, trộn, An Yên,
  Train, biên khung, sự kiện); `plugins.js` nay 4 plugin (Balance → Stats
  → Time → Isometric). Điểm PROVISIONAL mới: ánh xạ "20:00 giờ game" =
  phút thật thứ 25 của ngày; ngày game 1 = Thứ Hai; switch sự kiện = 1;
  phân bổ khởi đầu mặc định 100/100/100 — GDD chưa chốt.
- **Còn lại chưa xong (Giai đoạn 1):** `PXB_Isometric` chưa móc Tilemap
  (nay core đã có — việc tiếp theo lớn nhất); tile data toàn 0 (chưa có
  tileset CC0); img/audio trống; plugin còn lại (PXB_Hotspot/Crafting/
  Jobs/PhoneHub…) chưa viết. Mở trình duyệt lúc này hết 404 ở core nhưng
  vẫn chưa chơi được — trạng thái thật, không giấu.
- **Vẫn chưa chạy được:** xUnit (17 test) và EditMode test (219 test) chưa
  biên dịch/chạy lần nào (dotnet 8.0.428 có ở `~/.dotnet`, `dotnet test`
  vẫn kẹt RAM — chạy qua GitHub Actions; Unity chưa có).

## Lần chạy mới nhất: 18/11/2026 ~22:45 (giờ VN)

- Lệnh: `python3 src/server/tests/check_static.py` (chạy từ gốc repo)
- Kết quả: **198/198 PASS, exit 0** — tăng từ 167/167: nhóm T14 mới (31 mục)
  khóa khung Nadia Giai đoạn 1.
- **ĐỔI HƯỚNG SANG NADIA (chủ cho phép 18/11 22:30, `docs/architecture-nadia.md`):**
  `src/nadia/www/` khung file xong — `index.html` (thứ tự load §1.2) +
  `plugins.js` (PXB_Balance trước PXB_Isometric, cả 2 bật) + `main.js` +
  `PXB_Balance.js` (port đúng GameBalance.cs: 5 bậc học, lãi 0,5%, phí 5%,
  thang nhà, rank; Jobs.cs: 3 nghề Thể/Chiều/150k, Thể/Tối/180k,
  Tâm/Sáng/150k, quota 14, khung tốt +25%; Crafting.cs: xe-đẩy 1/2/2,
  đèn-soi 2/2, quà-tặng 2/1; Stats.cs PROVISIONAL: trần 300, StatMax 100,
  An Yên ±10) + `PXB_Isometric.js` bản đầu (chiếu (x−y)×tileW/2,
  (x+y)×tileH/2, tile 64×32, sort x+y, viewport 720×1280, `install()` trả
  false khi chưa có core — không giả vờ render được) + data tối thiểu:
  System.json (tiền "đồng", map bắt đầu 1), MapInfos.json đủ 18 khu
  (Bến Du Thuyền trong khu 16), Map001.json/Map002.json (lưới 12×9,
  data 648, event đúng Exploration.cs + Actors.js: hotspot hs-tro-toi /
  hs-cho-sang / hs-cho-chieu, NPC cô Tư/bạn thân/chị Lệ/anh Hải đúng tọa độ,
  transfer 2 chiều (5,4), Góc Chế Tạo (2,2)/(7,5)), Actors.json (1 nhân vật
  "Bạn" — tên PROVISIONAL), Classes.json, Items.json (13 món, giá khớp
  Items.js) + package.json NW.js + README. `node --check` 4/4 file JS OK
  (node v24 có sẵn trên VM).
- **Phát hiện khi port — slice web lệch khỏi code C# ở 3 chỗ (nadia lấy
  theo C#, chưa sửa web):** (1) nghề: web ghi bán rong Tâm/100k/Sáng, C#
  ghi Thể/150k/Chiều; shipper web 150k vs C# 180k; nhân viên quán web
  100k/Chiều vs C# 150k/Sáng; (2) công thức: web xe-đẩy 1/1/1, đèn-soi 2/1;
  C# xe-đẩy 1/2/2, đèn-soi 2/2 — bộ vật liệu khởi đầu 1/1/1 của web không đủ
  chế xe-đẩy theo C#; (3) hotspot: web đặt hs-cho-dem ở map 2 (sắt-vụn ×1,
  cần đèn-soi) + thêm hs-hem-sang ở map 1; C# đặt hs-cho-dem ở map 18
  (vải-vụn ×2) và không có hs-hem-sang. Chi tiết trong `src/nadia/README.md`
  — để GDD/PM xem lại.
- **Còn lại chưa xong (Giai đoạn 1):** core MV (`js/rpg_*.js` +
  `js/libs/pixi.js`…) chưa tải về (lấy từ rpgtkoolmv/corescript v1.6.1,
  MIT); `PXB_Isometric` chưa móc Tilemap; tile data toàn 0 (chưa có tileset
  CC0); img/audio trống; plugin còn lại (PXB_Stats/Time/Hotspot/Crafting/
  Jobs/PhoneHub…) chưa viết. Mở trình duyệt lúc này lỗi 404 ở core —
  trạng thái thật, không giấu.
- **Vẫn chưa chạy được:** xUnit (17 test) và EditMode test (219 test) chưa
  biên dịch/chạy lần nào. Ghi chú mới: dotnet 8.0.428 CÓ ở `~/.dotnet`
  (không trong PATH) — `dotnet test` vẫn kẹt RAM theo ghi nhận cũ, chạy qua
  GitHub Actions; Unity vẫn chưa có.

## Lần chạy mới nhất: 18/11/2026 ~21:50 (giờ VN)

- Lệnh: `python3 src/server/tests/check_static.py` (chạy từ gốc repo)
- Kết quả: **167/167 PASS, exit 0** — tăng từ 156/156: nhóm T13 mới (11 mục)
  khóa spec art khu 17/18.
- **Follow-up C2 (roles-qc.md §6): spec art chi tiết khu 17/18 đã có trong
  `docs/art-assets.md` (§3 Công Viên An Bình, §4 Phố Đi Bộ – Chợ Đêm):**
  mô tả verbatim nguyên văn `art-style.md` §4; bố cục isometric + điểm neo;
  bảng prop; NPC dẫn đường khớp đúng `Exploration.cs` `GuideHint` (khu 17
  Ông Ba, khu 18 Anh Hải — cùng người với anh Hải ở khu 2, đã ghi rõ không
  vẽ thành 2 người); hotspot khớp đúng code (`hs-cong-vien` Ván gỗ ×1 khung
  Chiều, `hs-cho-dem` Vải vụn ×2 khung Tối); bảng Sáng/Chiều/Tối + mưa/nắng/
  Tết; shot list ≤ 8 shot mỗi khu (PROVISIONAL). Tiêu đề file đổi thành
  "4 khu slice đầu", các mục cũ đánh lại số (§3–§6 cũ thành §5–§8). Header
  2 scene mới nay trỏ thẳng tới đúng mục spec (§3/§4), không còn ghi "chưa
  có mục riêng". Không bịa số mới: mọi vật liệu / khung / NPC đều lấy từ
  `Exploration.cs` + `docs/districts.md` (khu chung luôn mở, khu 18 có sự
  kiện 20:00 thứ 7 + Bụi Đời Chợ Cá).
- **Còn lại chưa xong (C2):** 4/4 scene slice vẫn chỉ là khung file (chưa mở
  bằng Unity, chưa có art, chưa bấm Play được); C3–C9 vẫn chưa xong.
- **Vẫn chưa chạy được:** xUnit (17 test) và EditMode test (219 test) chưa biên
  dịch/chạy lần nào (VM không có dotnet/Unity). Server chưa chạy; client chưa
  có scene slice chơi được.

## Lần chạy mới nhất: 18/11/2026 ~20:50 (giờ VN)

- Lệnh: `python3 src/server/tests/check_static.py` (chạy từ gốc repo)
- Kết quả: **156/156 PASS, exit 0** — tăng từ 129/129: nhóm T12 mới (27 mục)
  khóa 4 scene slice.
- **Luồng song song — 2 scene slice còn lại (C2):**
  `SliceCongVienAnBinh.unity` (khu 17, hotspot `hs-cong-vien` “Ghế đá công
  viên”, khung Chiều, Ván gỗ ×1) + `SlicePhoDiBoChoDem.unity` (khu 18,
  hotspot `hs-cho-dem` “Sạp đêm cuối phố”, khung Tối, Vải vụn ×2) — mỗi scene
  có GameManager + Player + CameraFollowBehaviour + camera ortho + mô tả
  verbatim `docs/art-style.md` §4; `.meta` guid mới, duy nhất; không bịa
  hotspot / prop / màu mới. **Sửa lỗi header cũ:** `SliceChoDauMoi.unity`
  từng ghi nhầm “Xom Tro Cu (khu 1/18” — đã sửa thành khu 2; 2 scene cũ đã
  cập nhật dòng “doi scene khu rieng (chua tao)” → trỏ tới 2 scene mới.
  1 lỗi script trong lần chạy này (đã sửa, chạy lại PASS): T12f lúc đầu FAIL
  giả — chuỗi kiểm tra không dấu trong khi header scene mới ghi đúng mô tả
  verbatim có dấu của `art-style.md` §4.
- **Còn lại chưa xong (C2):** spec art chi tiết khu 17/18 chưa có trong
  `docs/art-assets.md` (hiện chỉ có khu 1–2) — việc follow-up; xử lý sáng
  chiều / tối là việc của art pass sau, khung scene giữ nguyên màu nền đã
  khóa #F9EDCE.
- **Vẫn chưa chạy được:** xUnit (17 test) và EditMode test (219 test) chưa biên
  dịch/chạy lần nào (VM không có dotnet/Unity). Server chưa chạy; client chưa
  có scene slice chơi được (4/4 scene slice mới chỉ là khung file).

## Lần chạy mới nhất: 18/11/2026 ~19:50 (giờ VN)

- Lệnh: `python3 src/server/tests/check_static.py` (chạy từ gốc repo)
- Kết quả: **129/129 PASS, exit 0** — tăng từ 119/119: nhóm T11 mới (10 mục)
  khóa 4 bug đã sửa trong đợt này + tổng EditMode 219 test.
- **Luồng song song — sửa 4 bug đã ghi nhận ở đợt 18:50 (code thật + test hồi quy):**
  1. `Inventory.Add` đồ không stackable: `Add("ao-mua", 2)` lúc túi trống nay
     trả false, không thêm gì (all-or-nothing — nhất quán với hành vi khi túi
     đã có món đó; muốn 1 cái thì gọi lại quantity = 1).
  2. `Inventory.Use`: bỏ `def.Effect with { Frame = currentFrame }` — buff áp
     đúng khung ghi trong catalog (cơm tấm dùng lúc Tối vẫn buff vào Chiều).
  3. `Crafting.Craft`: nguyên liệu về 0 thì `materials.Remove(materialId)` —
     không để lại key = 0 trong Dictionary.
  4. `Exploration.Explore`: tự gọi `NewGameDay(visitedToday)` khi `gameDay`
     khác ngày đã lưu (`_currentDay`, null = chưa khám phá lần nào trong phiên
     thì chỉ ghi nhận ngày, không reset — tránh xóa lượt đã lưu trong save).
  5. `TitleConflict.IsBlocked`: chặn cả hai chiều (tra thẳng
     `BlockedBy[wanted]`, không cần bảng ngược riêng) + so sánh
     `OrdinalIgnoreCase` (dictionary + `string.Equals`); thêm guard null.
  - Test hồi quy mới: Inventory +4 (19), Crafting +2 (18), Exploration +3
    (19), District +4 (33) = **+12 test, tổng EditMode nay 219 test**
    (Jobs 28 + TimeSystem 10 + Social 22 + Economy 22 + Inventory 19 +
    Crafting 18 + Exploration 19 + PlayerProgress 30 + District 33 +
    PhoneHub 18) — vẫn **chưa chạy được** (VM không có Unity; cần Unity
    2022.3.62f1 + Unity Test Runner). 1 lỗi script trong lần chạy này (đã sửa,
    chạy lại PASS): T11b lúc đầu FAIL giả — chuỗi `with { Frame = currentFrame }`
    vẫn còn trong comment nhắc bug cũ; đã sửa chỉ xét code sau khi strip comment.
- **Hành vi lạ còn lại (chưa sửa — để GDD/PM xem lại, là quyết định thiết kế
  chứ không phải bug rõ):** `PhoneHub.Notify` đếm cả khi điện thoại đóng
  (thông báo đến khi đóng máy là hành vi bình thường của điện thoại);
  `PlayerProgress.SuggestEnding` thứ tự ưu tiên cứng SieuGiau > GiamDoc >
  HocGia > GiaDinh > TuDo; `Buy("phong-tro")` tính tiền thuê vào
  `TotalAssetsVnd`; `AdvanceStage` không kiểm tra Kind.
- **Vẫn chưa chạy được:** xUnit (17 test) và EditMode test (219 test) chưa biên
  dịch/chạy lần nào (VM không có dotnet/Unity). Server chưa chạy; client chưa
  có scene slice chơi được.

## Lần chạy mới nhất: 18/11/2026 ~18:50 (giờ VN)

- Lệnh: `python3 src/server/tests/check_static.py` (chạy từ gốc repo)
- Kết quả: **119/119 PASS, exit 0** — tăng từ 83/83: nhóm T10 mới quét 6 file
  test EditMode đợt 2 (36 mục: đủ 6 file, số test khớp 15/16/17/30/29/18,
  ngoặc cân bằng, NUnit + namespace, không dùng UnityEngine, nhắc đúng API
  thật). 1 lỗi script trong lần chạy này (đã sửa, chạy lại PASS): T9a cũ bắt
  đúng 4 file test, nay đã có 10 file — đã sửa thành kiểm tra tập con.
- **Luồng song song — test EditMode cho 6 module logic thuần còn lại (chuẩn bị C6):**
  `InventoryTests.cs` 15 test (Add/Use/BuffFor/EndFrame, catalog 4 item slice),
  `CraftingTests.cs` 16 test (ToolBehaviour 12 combo 4 tool × 3 tier, 3 công thức,
  CanCraft/Craft/MissingIngredients), `ExplorationTests.cs` 17 test (5 hotspot,
  HotspotsInDistrict, CanFastTravel, Explore 1 lần/ngày, GuideHint 4 NPC),
  `PlayerProgressTests.cs` 30 test (CanOpenChapter 5 chương, SuggestEnding 6 kết
  thúc, RankAtRisk biên 100/30), `DistrictTests.cs` 29 test (18 khu đúng thứ tự/
  tên/Tier + TitleConflict.IsBlocked 7 danh hiệu), `PhoneHubTests.cs` 18 test
  (9 tab đúng thứ tự, Open/Close/Toggle/SelectTab, Notify/Unread/TotalUnread,
  sự kiện TabChanged/OpenChanged). Tổng EditMode nay **207 test** (82 cũ + 125
  mới) — vẫn **chưa chạy được** (VM không có Unity; cần Unity 2022.3.62f1 +
  Unity Test Runner). Toàn bộ module logic thuần client nay đã có test:
  Jobs, TimeSystem, Social, Economy, Inventory, Crafting, Exploration,
  PlayerProgress, District/TitleConflict, PhoneHub. Chỉ còn các file
  MonoBehaviour (PlayerController, CameraFollowBehaviour, GameManagerBehaviour,
  HotspotView, PhoneHubView) chưa có test — cần Unity để test PlayMode.
- **Hành vi lạ phát hiện khi viết test (ghi nhận, chưa sửa code — để GDD/PM xem lại):**
  1. `Inventory.Use` ghi đè khung buff trong catalog (`def.Effect with { Frame =
     currentFrame }`): cơm tấm catalog ghi khung Chiều nhưng dùng lúc Sáng thì
     buff rơi vào Sáng — khung ghi trong catalog thực tế không có tác dụng lúc dùng.
  2. `Inventory.Add` đồ không stackable chỉ chặn khi túi đã có món đó:
     `Add("ao-mua", 2)` lúc túi trống vẫn trả true và giữ 2 áo mưa.
  3. `Exploration.Explore` nhận tham số `gameDay` nhưng không dùng: ngày mới chỉ
     có hiệu lực khi người gọi tự gọi `NewGameDay` — đổi số ngày lúc gọi Explore
     không tự reset lượt khám phá.
  4. `Crafting.Craft` để lại key nguyên liệu = 0 trong Dictionary sau khi chế hết.
  5. `TitleConflict.IsBlocked` chỉ chặn một chiều: đang có "Cảnh sát" thì nhận
     "Tướng Cướp" vẫn được; so sánh `==` nên phân biệt hoa/thường.
  6. `PhoneHub.SelectTab` luôn kích hoạt `TabChanged` kể cả chọn đúng tab hiện
     tại; `Notify` vẫn đếm khi điện thoại đang đóng (không kiểm tra `IsOpen`).
  7. `PlayerProgress.SuggestEnding` có thứ tự ưu tiên cứng
     SieuGiau > GiamDoc > HocGia > GiaDinh > TuDo.
  8. (ghi nhận từ đợt 17:50, nhắc lại) `Buy("phong-tro")` tính tiền thuê vào
     `TotalAssetsVnd`; `AdvanceStage` không kiểm tra Kind.
- **Vẫn chưa chạy được:** xUnit (17 test) và EditMode test (207 test) chưa biên
  dịch/chạy lần nào (VM không có dotnet/Unity). Server chưa chạy; client chưa
  có scene slice chơi được.

## Lần chạy trước: 18/11/2026 ~17:50 (giờ VN)

- Lệnh: `python3 src/server/tests/check_static.py` (chạy từ gốc repo)
- Kết quả: **83/83 PASS, exit 0** — tăng từ 66/66: nhóm T9 mới quét file test
  EditMode (17 mục: đủ 4 file, số test khớp 28/10/22/22, ngoặc cân bằng,
  NUnit + namespace, hồi quy bug Divorce, UTF-8, không secret).
- **Luồng song song — test EditMode cho Social + Economy (chuẩn bị C6):**
  `SocialTests.cs` 22 test (bỏ bê 7/14/21 ngày, Interact +5, AdvanceStage
  ngưỡng 50/70/80, giới hạn 3 quan hệ sâu, 1 BestFriend, supporter +20% EXP,
  solo penalty 40% PROVISIONAL trong khoảng 30–50% chốt, nhóm tan 7 ngày,
  Divorce, BreakUp) + `EconomyTests.cs` 22 test (lãi 0,5% + làm tròn xuống,
  gửi/rút tiết kiệm, mua đồ + fame 50, đấu giá phí 5% + chia nguyên, barter,
  chia tài sản ly hôn, set bonus, dress-code, 4 hàm cấm, TotalAssetsVnd,
  catalog thang nhà 6 bậc). Tổng EditMode nay **82 test** (28 Jobs + 10
  TimeSystem + 22 Social + 22 Economy) — vẫn **chưa chạy được** (VM không có
  Unity; cần Unity 2022.3.62f1 + Unity Test Runner).
- **BUG THẬT PHÁT HIỆN KHI VIẾT TEST — ĐÃ SỬA BẰNG CODE (18/11):**
  `Social.Divorce` dùng `(Kind != Spouse && Stage != Cuoi)` nên Spouse chưa
  cưới vẫn ly hôn được (chỉ cần 1 trong 2 điều kiện là đủ). Đã sửa thành `||`
  — phải vừa là Spouse vừa đang ở Stage Cuoi mới ly hôn được; thêm 2 test
  (Spouse chưa cưới → false, Lover ở Stage Cuoi → false) + kiểm tra hồi quy
  T9e trong `check_static.py` (dòng điều kiện if, không tính comment nhắc bug cũ).
  Ghi nhận thêm (không phải bug, để GDD xem lại sau): `Buy("phong-tro")`
  thêm phòng trọ vào `Owned` nên `TotalAssetsVnd` tính cả 2tr tiền thuê tháng
  như tài sản; `AdvanceStage` không kiểm tra Kind (Spouse cũng đi được
  HenHo → DinhHon → Cuoi).
- **1 lỗi script trong lần chạy này (đã sửa, chạy lại PASS):** T9e lúc đầu FAIL
  giả — regex lấy cả khối Divorce gồm comment nhắc ký tự `&&` của bug cũ.
  Đã sửa chỉ xét dòng điều kiện `if (...)` thay vì cả khối.

## Lần chạy trước: 18/11/2026 ~17:00 (giờ VN)

- Lệnh: `python3 src/server/tests/check_static.py` (chạy từ gốc repo)
- Kết quả: **66/66 PASS, exit 0** — không vỡ kiểm tra cũ.
- **Luồng A — sửa phát hiện `Stats` (đã ghi ở lần ~15:55, nay đã sửa bằng code):**
  `Stats.cs` thêm factory `Stats.WithValues(the, tri, tam)` — tạo `Stats` với
  giá trị tùy ý, không yêu cầu tổng = 300 (PROVISIONAL); từng chỉ số vẫn kẹp
  0..100; ctor chính giữ nguyên (tổng phải = 300). `JobsPayTests.cs` từ 16
  lên **28 test method** (+12): hệ số lương mốc 50 (1.0) và mốc 0 (sàn 0.5)
  cho cả 3 nghề slice, nhân khung tốt + thiếu người, làm tròn xuống, kiểm tra
  độ dốc tuyến tính mốc 60, `WithValues` kẹp giá trị, và `Stats.Train` đánh
  đổi thật qua `WithValues`. Mốc 50/0 khớp đúng công thức `Jobs.cs`
  (`max(0.5, 1.0 + (chỉ số − 50) × 0.01)`), không bịa số mới.
- **Luồng B — khung Unity C1 (file-level, chưa verify mở bằng Unity):**
  `src/client/ProjectSettings/` thêm 10 file `.asset` tối thiểu
  (ProjectSettings, EditorSettings, GraphicsSettings — đã khóa hằng isometric
  `TransparencySortAxis (0, 1, −0.26)`, QualitySettings 6 mức, TagManager,
  TimeManager, Physics2DSettings, DynamicsManager, AudioManager,
  NavMeshAreas) + scene `Assets/Scenes/SliceXomTroCu.unity` (camera ortho,
  nền vàng nắng #F9EDCE, GO `SliceRoot`, chưa có art). Đã có sẵn từ trước:
  `ProjectVersion.txt` 2022.3.62f1, `Packages/manifest.json` (test-framework
  1.1.33), `Assets/Scenes/Main.unity`, `.gitignore` đủ Library/Temp/Logs.
  **Chưa verify:** Unity lần đầu mở còn phải sinh `Library/`, `*.csproj`
  (C3), `.meta` thư mục, `InputManager.asset` / `EditorBuildSettings.asset`
  và chuẩn hóa lại các `.asset` tối thiểu — cần máy có Unity 2022.3.62f1.
- **Vẫn chưa chạy được:** 28 test EditMode + 17 test xUnit vẫn chưa biên dịch/
  chạy lần nào (VM không có dotnet/Unity). `TimeSystem` không wrap quá 30
  phút vẫn chưa có chốt GDD — giữ nguyên, không coi là bug.

## Lần chạy mới nhất: 18/11/2026 ~15:55 (giờ VN)

- Lệnh: `python3 src/server/tests/check_static.py` (chạy từ gốc repo)
- Kết quả: **66/66 PASS, exit 0** — tăng từ 53/53: nhóm T8 mới quét file
  server (13 mục: ngoặc Program.cs + EconomyLedger.cs, số chốt khớp
  GameBalance, 4 hàm cấm ném exception, secret, UTF-8) + 2 mục T8h/T8i
  (Program.cs đăng ký EconomyLedger singleton, giữ endpoint /health).

### Chuẩn bị C5/C6 trong đợt này (code test thật, CHƯA chạy được)

- **C5 — test xUnit server:** `src/server/tests/PhoXoBo.Server.Tests/`
  (`PhoXoBo.Server.Tests.csproj` net8.0, xUnit 2.9.2; `EconomyLedgerTests.cs`
  256 dòng, 17 test: lãi 0,5%, phí đấu giá 5%, chặn Nợ == Có / trùng
  IdempotencyKey / số tiền ≤ 0, IsBalanced, Gift qua GiftTransit, 4 hàm cấm
  ném InvalidOperationException). Không có test bỏ bê 7 ngày / +20% EXP vì
  2 số đó thuộc `Social.cs` (client), chưa có API server — không bịa API.
  `Program.cs` (26 → 66 dòng): đăng ký `EconomyLedger` singleton + endpoint
  `GET /ledger/balance/{playerId}` và `POST /ledger/gift` (200/409/400);
  `/health` giữ nguyên; ledger vẫn in-memory, endpoint gift chưa có auth.
- **C6 — test EditMode Unity:** `src/client/Assets/Tests/EditMode/`
  (`JobsPayTests.cs` 190 dòng, 16 test; `TimeSystemTests.cs` 99 dòng,
  10 test) + `PhoXoBo.asmdef` mới cho Scripts (trước đây chưa có asmdef nên
  test không tham chiếu được) + `EditMode.asmdef`. `manifest.json` đã có sẵn
  `com.unity.test-framework 1.1.33` (bản đi kèm Unity 2022 LTS), không sửa.
- **Phát hiện khi viết test (đã ghi, chưa sửa code):** `Stats` chỉ khởi tạo
  được (100,100,100) nên hệ số lương ở mốc 50/0 chưa test được qua API công
  khai; `Stats.Train` từ trạng thái max luôn trả false; `TimeSystem.CurrentFrame`
  không wrap khi elapsed vượt 30 phút (chưa có chốt GDD về wrap, không coi là bug).
- **Chưa chạy được:** VM không có dotnet/Unity nên xUnit và EditMode test
  chưa biên dịch/chạy lần nào — phải chạy `dotnet test` và Unity Test Runner
  trên máy có .NET 8 SDK + Unity 2022.3.62f1 trước khi coi C5/C6 là xong.

## Lần chạy trước: 18/11/2026 ~14:44 (giờ VN)

- Lệnh: `python3 src/server/tests/check_static.py` (chạy từ gốc repo)
- Kết quả: **53/53 PASS, exit 0**
- File kiểm tra: 13 file `.cs` trong `src/client/Assets/Scripts/`
  (gồm `PlayerProgress.cs` — file này do một luồng làm song song thêm vào
  và đã push riêng commit `13761c8f` lúc 14:42, không thuộc đợt này).

### Chi tiết 53 mục

| Nhóm | Mục | Kết quả |
|------|-----|---------|
| T1 — Ngoặc cân bằng (13 file .cs) | Crafting, District, Economy, Exploration, GameBalance, Inventory, Jobs, PhoneHub, PlayerProgress, Social, Stats, TimeSystem, TitleConflict | 13/13 PASS |
| T2 — Số chốt khớp GameBalance ↔ docs | 18 khu (District.cs 18 entry + docs), 5 bậc học, học phí 20/80/200/500tr, lãi 0,5%, phí 5%, bỏ bê 7 ngày, +20% EXP, solo 30–50%, mua lớn +50 Danh vọng, thang nhà 6 bậc, rank Chương 5 (10 tỉ / 100 tỉ / An Yên 80), GDD nhắc đủ lãi/phí/bỏ bê/+20% EXP | 28/28 PASS |
| T3 — Social/Economy dùng đúng hằng | Dùng `NeglectDaysToDropCloseness`, `SupportedExpBonusPercent`, `BankInterestPerGameMonth`, `AuctionFeePercent`, `BigPurchaseFameBonus`; không hardcode số chốt | 7/7 PASS |
| T4 — Secret | Không có password / api-key / secret / token / private key trong file .cs | PASS |
| T5 — Ranh giới pháp lý | `CashOut`, `LendWithInterest`, `Gamble`, `BuyWithRealMoney` trong `Economy.cs` luôn trả `false` | 4/4 PASS |
| T6 — Assets | `assets/` trống — chưa đưa asset nào vào, không asset lậu | PASS |
| T7 — Encoding | Mọi file .cs đều UTF-8 | PASS |

### 2 lỗi gặp trong lần chạy đầu (đã sửa, chạy lại PASS)

1. **T2a FAIL lúc đầu — lỗi ở script kiểm tra, không phải ở code:**
   `District.cs` dùng target-typed `new(1, "Xóm Trọ Cũ", ...)` nên regex
   `new District(` đếm được 0 entry. Đã sửa regex đếm `new(số, "tên", Tier)`.
2. **T2o FAIL lúc đầu — lỗi thật ở docs:** GDD Mục 7 chỉ ghi "Xem
   `docs/economy.md`" mà không nhắc lãi 0,5%/tháng. Đã bổ sung 1 dòng vào
   GDD Mục 7 ghi rõ lãi 0,5%, phí 5%, mua lớn +50 Danh vọng (số đã chốt
   sẵn trong `GameBalance.cs` / `economy.md`, không phải số mới).

### Lần chạy đầu cũng phát hiện 1 lỗi script khác (đã sửa)

- `check_static.py` tính sai thư mục gốc (`parents[2]` ra `src/` thay vì
  repo) → `FileNotFoundError`. Đã sửa thành `parents[3]`.

## Lần chạy bổ sung — EconomyLedger (server), 18/11/2026 ~14:45 (giờ VN)

> Luồng song song 3 (server + test). File mới: `src/server/src/EconomyLedger.cs`
> (228 dòng) — sổ cái double-entry server-authoritative: mỗi bút toán Nợ 1 tài
> khoản / Có 1 tài khoản khác, cùng số tiền; `Post()` chặn Nợ == Có và chặn
> ghi trùng bằng IdempotencyKey; `IsBalanced()` kiểm tra tổng Nợ == tổng Có.

- Lệnh: `python3 src/server/tests/check_static.py` (chạy lại từ gốc repo)
- Kết quả: **53/53 PASS, exit 0** — không vỡ kiểm tra cũ.
- Kiểm tra riêng file server mới (script kiểm tra trong `/tmp`, không commit
  vào repo vì `check_static.py` hiện chỉ quét file `.cs` client):
  **18/18 PASS**, gồm:
  - L1 — Ngoặc cân bằng `EconomyLedger.cs`: `{}` 10/10, `()` 67/67, `[]` 0/0.
  - L2 — Số chốt khớp `GameBalance.cs`: lãi 0,5% (`0.005`), phí đấu giá 5%,
    1 tháng game = 30 ngày (PROVISIONAL, khớp `Economy.cs`).
  - L3 — `Post()` chặn Nợ == Có; chặn trùng IdempotencyKey; `IsBalanced()`;
    `AuctionSale` tính phí `hammer * 5 / 100`, người bán nhận `hammer − phí`;
    `Gift()` đi qua tài khoản trung gian `GiftTransit`, không Post cùng tài
    khoản; `ApplyMonthlyInterest` dùng đúng `BankInterestPerGameMonth`.
  - L4 — Ranh giới pháp lý: `CashOut`, `LendWithInterest`, `Gamble`,
    `BuyWithRealMoney` đều bị chặn bằng `throw InvalidOperationException`.
  - L5/L6 — Không có secret; file UTF-8.
- **1 lỗi thật phát hiện khi viết code, đã sửa trước khi kiểm tra:** bản nháp
  `Gift()` gọi `Post(..., PlayerCash, PlayerCash, ...)` — `Post()` chặn Nợ ==
  Có nên sẽ ném lỗi. Đã sửa bằng tài khoản trung gian `GiftTransit` (người
  tặng Nợ Cash / Có Transit, người nhận Nợ Transit / Có Cash). Hạn chế
  skeleton đã ghi trong comment: `BalanceOf()` tính theo từng người chơi nên
  số dư Transit của từng người không về 0 riêng lẻ — khi nối DB thật phải đối
  chiếu Transit theo Reference, không theo PlayerId.
- Chưa làm trong đợt này: `EconomyLedger` chưa được `Program.cs` gọi (server
  vẫn chỉ có `GET /health`), chưa nối PostgreSQL, chưa có test xUnit chạy
  được — vẫn là kiểm tra tĩnh, chưa phải build/test chạy được.

## Hiện trạng thật (18/11/2026, lúc viết báo cáo này)

- Code: 13 file `.cs` client + server `.NET 8` skeleton (`Program.cs`,
  `GET /health`, ghi rõ `database: not-connected`). **Chưa biên dịch lần nào.**
- Chưa có: Unity project đầy đủ (`.csproj` client, `ProjectSettings/`,
  scene, prefab), asset CC0 nào, test xUnit / Unity Test Framework nào
  **chạy được**, server chạy được, bản chơi được thật.
- Đã có trong đợt này: `Social.cs` (quan hệ, bỏ bê 7 ngày, +20% EXP,
  solo chậm 40% trong khoảng 30–50% đã chốt), `Economy.cs` (ví, lãi 0,5%,
  đấu giá phí 5%, barter, chia tài sản ly hôn, 4 hàm cấm luôn trả false),
  `src/server/tests/check_static.py` + `README.md`, báo cáo này.
- Xem checklist để ra bản test được: `docs/roles-qc.md` §6.

## Hiện trạng thật (18/11/2026 ~15:55, lúc viết báo cáo này)

- Kiểm tra tĩnh: **66/66 PASS** (`check_static.py`, gồm nhóm T8 mới quét
  file server + T8h/T8i nối ledger vào `Program.cs`).
- Chuẩn bị C5: test xUnit server `EconomyLedgerTests.cs` (17 test) +
  `Program.cs` đã nối `EconomyLedger` singleton với 2 endpoint
  `/ledger/balance` + `/ledger/gift`; `/health` giữ nguyên.
- Chuẩn bị C6: test EditMode `JobsPayTests.cs` (16 test) +
  `TimeSystemTests.cs` (10 test) + `PhoXoBo.asmdef` + `EditMode.asmdef`;
  `manifest.json` đã có sẵn test-framework 1.1.33.
- Vẫn chưa chạy được: không có dotnet/Unity trên VM — xUnit và EditMode test
  chưa biên dịch/chạy lần nào; server chưa chạy; client chưa có scene slice
  chơi được. Cần máy có Unity 2022 LTS + .NET 8 SDK để chạy `dotnet test` và
  Unity Test Runner trước khi coi C5/C6 là xong.

## Hiện trạng thật (18/11/2026 ~18:50, lúc viết báo cáo này)

- Kiểm tra tĩnh: **119/119 PASS** (`check_static.py`, gồm nhóm T10 mới quét
  6 file test EditMode đợt 2).
- Test EditMode Unity nay **207 test** (Jobs 28 + TimeSystem 10 + Social 22 +
  Economy 22 + Inventory 15 + Crafting 16 + Exploration 17 + PlayerProgress 30 +
  District 29 + PhoneHub 18) — vẫn chưa chạy được lần nào (VM không có
  dotnet/Unity). Toàn bộ module logic thuần client đã có test; chỉ còn các file
  MonoBehaviour chưa có test (cần Unity PlayMode).
- Hành vi lạ ghi nhận khi viết test (chưa sửa, để GDD/PM xem lại):
  `Inventory.Use` ghi đè khung buff, `Add` áo mưa số lượng 2 vẫn qua,
  `Explore` không dùng tham số `gameDay`, `Craft` để lại key = 0,
  `TitleConflict` chỉ chặn một chiều + phân biệt hoa/thường,
  `PhoneHub.Notify` đếm cả khi đóng, `SuggestEnding` ưu tiên cứng.
- Vẫn chưa chạy được: không có dotnet/Unity trên VM — xUnit (17 test) và
  EditMode test (207 test) chưa biên dịch/chạy lần nào; server chưa chạy;
  client chưa có scene slice chơi được.

## Hiện trạng thật (18/11/2026 ~17:50, lúc viết báo cáo này)

- Kiểm tra tĩnh: **83/83 PASS** (`check_static.py`, gồm nhóm T9 mới quét
  file test EditMode).
- Test EditMode Unity nay **82 test** (Jobs 28 + TimeSystem 10 + Social 22 +
  Economy 22) — vẫn chưa chạy được lần nào (VM không có dotnet/Unity).
  Bug `Social.Divorce` (điều kiện `&&` sai) đã sửa thành `||` + 2 test hồi quy.
- Khung Unity C1 đã có ở mức file (`ProjectSettings/` 10 file `.asset` +
  scene `SliceXomTroCu.unity`); **chưa verify mở bằng Unity** — cần máy có
  Unity 2022.3.62f1 sinh `Library/` + `.csproj` và kiểm tra Play lần đầu.
- Vẫn chưa chạy được: không có dotnet/Unity trên VM — xUnit (17 test) và
  EditMode test (82 test) chưa biên dịch/chạy lần nào; server chưa chạy;
  client chưa có scene slice chơi được.

## Hiện trạng thật (18/11/2026 ~17:00, lúc viết báo cáo này)

- Kiểm tra tĩnh: **66/66 PASS** (`check_static.py`).
- `Stats.WithValues` đã sửa xong phát hiện "chỉ khởi tạo được (100,100,100)";
  `JobsPayTests.cs` nay 28 test (mốc lương 50/0 đã test được qua API công khai).
- Khung Unity C1 đã có ở mức file (`ProjectSettings/` 10 file `.asset` +
  scene `SliceXomTroCu.unity`); **chưa verify mở bằng Unity** — cần máy có
  Unity 2022.3.62f1 sinh `Library/` + `.csproj` và kiểm tra Play lần đầu.
- Vẫn chưa chạy được: không có dotnet/Unity trên VM — xUnit (17 test) và
  EditMode test (28 + 10 test) chưa biên dịch/chạy lần nào; server chưa chạy;
  client chưa có scene slice chơi được.

## Hiện trạng thật (18/11/2026 ~19:50, lúc viết báo cáo này)

- Kiểm tra tĩnh: **129/129 PASS** (`check_static.py`, gồm nhóm T11 mới khóa
  4 bug đã sửa + tổng EditMode 219 test).
- 4 bug ghi nhận ở đợt 18:50 nay đã sửa bằng code + 12 test hồi quy:
  Inventory.Add đồ không stackable (all-or-nothing), Inventory.Use áp đúng
  khung catalog, Crafting.Craft xóa key nguyên liệu về 0, Exploration.Explore
  tự reset khi đổi ngày, TitleConflict.IsBlocked chặn 2 chiều + không phân
  biệt hoa/thường.
- Hành vi lạ còn lại (chưa sửa, để GDD/PM xem lại): `PhoneHub.Notify` đếm cả
  khi đóng, `SuggestEnding` ưu tiên cứng, `Buy("phong-tro")` tính tiền thuê
  vào tài sản, `AdvanceStage` không kiểm tra Kind.
- Vẫn chưa chạy được: không có dotnet/Unity trên VM — xUnit (17 test) và
  EditMode test (219 test) chưa biên dịch/chạy lần nào; server chưa chạy;
  client chưa có scene slice chơi được.

## Hiện trạng thật (18/11/2026 ~20:50, lúc viết báo cáo này)

- Kiểm tra tĩnh: **156/156 PASS** (`check_static.py`, gồm nhóm T12 mới khóa
  4 scene slice).
- C2 tiến thêm 1 bước: 4/4 scene slice đầu nay đã có khung file
  (`SliceXomTroCu`, `SliceChoDauMoi`, `SliceCongVienAnBinh` khu 17,
  `SlicePhoDiBoChoDem` khu 18 — mỗi scene GameManager + Player +
  CameraFollowBehaviour + camera ortho + đúng hotspot trong
  `Exploration.cs`); đã sửa header `SliceChoDauMoi.unity` ghi nhầm khu 1.
- Hành vi lạ còn lại (chưa sửa, để GDD/PM xem lại): `PhoneHub.Notify` đếm cả
  khi đóng, `SuggestEnding` ưu tiên cứng, `Buy("phong-tro")` tính tiền thuê
  vào tài sản, `AdvanceStage` không kiểm tra Kind. Việc follow-up C2: spec art
  chi tiết khu 17/18 chưa có trong `docs/art-assets.md` (chỉ có khu 1–2).
- Vẫn chưa chạy được: không có dotnet/Unity trên VM — xUnit (17 test) và
  EditMode test (219 test) chưa biên dịch/chạy lần nào; server chưa chạy;
  client chưa có scene slice chơi được (4/4 scene mới chỉ là khung file).

## Hiện trạng thật (18/11/2026 ~22:45, lúc viết báo cáo này)

- Kiểm tra tĩnh: **198/198 PASS** (`check_static.py`, gồm nhóm T14 mới khóa
  khung Nadia Giai đoạn 1).
- Khung Nadia Giai đoạn 1 đã có ở mức file (`src/nadia/www/`): index.html,
  plugins.js, main.js, PXB_Balance.js, PXB_Isometric.js (bản đầu), data tối
  thiểu (System, MapInfos đủ 18 khu, Map001–002, Actors, Classes, Items),
  package.json NW.js, README. `node --check` 4/4 file JS OK.
- Chưa chơi được: core MV chưa tải về, PXB_Isometric chưa móc Tilemap, tile
  data toàn 0, img/audio trống. Việc tiếp theo: tải core MV v1.6.1 (MIT) về
  js/ + móc Tilemap isometric — rồi mới mở trình duyệt thấy map Xóm Trọ Cũ.
- Phát hiện khi port: slice web lệch khỏi code C# ở 3 chỗ (nghề, công thức,
  hotspot hs-cho-dem/hs-hem-sang) — nadia lấy theo C#; web chưa sửa, để
  GDD/PM xem lại (chi tiết trong `src/nadia/README.md`).
- Hành vi lạ còn lại (chưa sửa — để GDD/PM xem lại): `PhoneHub.Notify` đếm cả
  khi đóng, `SuggestEnding` ưu tiên cứng, `Buy("phong-tro")` tính tiền thuê
  vào tài sản, `AdvanceStage` không kiểm tra Kind.
- Vẫn chưa chạy được: xUnit (17 test) và EditMode test (219 test) chưa biên
  dịch/chạy lần nào (dotnet 8.0.428 có ở `~/.dotnet`, `dotnet test` vẫn kẹt
  RAM — chạy qua GitHub Actions; Unity chưa có).

## Hiện trạng thật (19/11/2026 ~00:05, lúc viết báo cáo này)

- Kiểm tra tĩnh: **206/206 PASS** (`check_static.py`, gồm nhóm T15 mới khóa
  core MV + 2 plugin mới).
- Core MV v1.6.1 ĐÃ CÓ trong repo (12 file, 2.341.224 byte, MIT, tag
  community 1.3b); plugin `PXB_Stats.js` + `PXB_Time.js` đã viết (port
  Stats.cs/TimeSystem.cs), `node --check` PASS, smoke test logic thuần PASS.
- Chưa chơi được: `PXB_Isometric` chưa móc Tilemap (việc tiếp theo lớn
  nhất, nay core đã có), tile data toàn 0, img/audio trống, plugin
  Hotspot/Crafting/Jobs/PhoneHub chưa viết.
- Điểm PROVISIONAL mới (PXB_Time): ánh xạ 20:00 giờ game = phút thật thứ
  25 của ngày, ngày game 1 = Thứ Hai, switch sự kiện thứ 7 = 1 — GDD chưa chốt.
- Hành vi lạ còn lại (chưa sửa — để GDD/PM xem lại): `PhoneHub.Notify` đếm cả
  khi đóng, `SuggestEnding` ưu tiên cứng, `Buy("phong-tro")` tính tiền thuê
  vào tài sản, `AdvanceStage` không kiểm tra Kind.
- Vẫn chưa chạy được: xUnit (17 test) và EditMode test (219 test) chưa biên
  dịch/chạy lần nào (dotnet 8.0.428 có ở `~/.dotnet`, `dotnet test` vẫn kẹt
  RAM — chạy qua GitHub Actions; Unity chưa có).

## Hiện trạng thật (19/11/2026 ~04:50, lúc viết báo cáo này)

- Kiểm tra tĩnh: **228/228 PASS** (`check_static.py`, gồm nhóm T20 mới,
  5 mục; 2 check cũ T18c/T19b nới `== 11` thành `>= 11` theo đúng mẫu
  các đợt trước — T20b đếm đủ 13).
- 2 plugin slice mới, làm song song 2 luồng: `PXB_Titles.js` (415 dòng,
  port TitleConflict.cs / GDD Mục 3: bảng chặn 7 dòng, chặn 2 chiều,
  không phân biệt hoa/thường, phe Chính/Tà/Trung lập, quest đổi phe
  "Cải tà quy chính"; smoke 68/68 PASS) + `PXB_Story.js` (454 dòng,
  port PlayerProgress.cs / GDD Mục 9: 5 chương, 6 kết thúc, tụt bậc
  chương 3; smoke 109/109 PASS); `plugins.js` nay 13 plugin
  (Social → Titles → Story); `node --check` 15/15 file JS nadia.
- Lệch mới phát hiện (đã ghi trong @help của 2 plugin, plugin giữ đúng
  C#): GDD Mục 3 không nhắc tên quest "Cải tà quy chính" (chỉ có trong
  comment C#) và không liệt kê phe của từng danh hiệu (plugin suy ra từ
  bảng chặn, PROVISIONAL); GDD nói danh hiệu có "yêu cầu chỉ số" và
  hiển thị "1 chính + 2–3 phụ" nhưng C# không có logic đó; chương 2
  GDD ghi "Trí 40 hoặc Cao đẳng" nhưng C# chỉ kiểm Trí/Danh vọng
  (Cao đẳng cho Trí 40 nên trùng); chương 5 Học giả GDD ghi cần bằng
  Tiến sĩ nhưng C# chỉ kiểm Trí/Danh vọng; chương 5 Gia đình GDD ghi
  cần rank Trung lưu nhưng C# chỉ kiểm vợ/chồng + An Yên 80.
- Check T20e bắt sai tên chương 1 lần (đòi `LenPho` kiểu PascalCase
  trong khi plugin dùng `CHAPTERS.LEN_PHO` số 1–5, đúng enum C#) — đã
  sửa danh sách token của check, không sửa plugin.
- CHƯA chơi được: tile data toàn 0, chưa có tileset CC0. Plugin Phase 1
  nay ĐÃ ĐỦ 13/13 theo `docs/architecture-nadia.md` §6 (#1–13, Titles
  #11 + Story #12 là 2 cái cuối); còn lại là Phase 2: `PXB_MarketBattle`
  (luật Bụi Đời Chợ Cá chưa chốt), `PXB_Online.js`, `PXB_SaveCloud.js`.
  Checklist C1–C9 (§6) vẫn giữ cho đường Unity (phương án dự phòng);
  đường chính nay là Giai đoạn 1–5 của `docs/architecture-nadia.md`.
  Việc tiếp theo lớn nhất: tải tile Kenney/SBS + đóng atlas theo
  `docs/tileset-plan.md` §4, rồi tile data thật cho Map001–002 để mở
  trình duyệt thấy map Xóm Trọ Cũ.
- Hành vi lạ còn lại (chưa sửa — để GDD/PM xem lại): `PhoneHub.Notify`
  đếm cả khi đóng, `SuggestEnding` ưu tiên cứng, `Buy("phong-tro")`
  tính tiền thuê vào tài sản, `AdvanceStage` không kiểm tra Kind.
- Vẫn chưa chạy được: xUnit (17 test) và EditMode test (219 test) chưa
  biên dịch/chạy lần nào (dotnet 8.0.428 có ở `~/.dotnet`, `dotnet test`
  vẫn kẹt RAM — chạy qua GitHub Actions; Unity chưa có).
