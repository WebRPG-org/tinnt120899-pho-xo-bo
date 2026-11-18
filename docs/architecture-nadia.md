# Kiến trúc Phố Xô Bồ — theo đúng Treasure of Nadia (RPG Maker MV)

> **Quyết định đổi kiến trúc — chủ cho phép 18/11/2026 22:30:** đổi hẳn sang kiến trúc
> của Treasure of Nadia để giải quyết nút thắt VM không có dotnet/Unity, scene chỉ
> là khung file, test chưa chạy thật.
>
> File này **thay thế `docs/architecture.md` (Unity 2022 + .NET 8 modular monolith)**
> làm kiến trúc chính, và **đảo ngược quyết định §4 của `docs/tech-switch-nadia.md`**
> (ngày 18/11 18:10, lúc đó quyết giữ Unity). Lý do đổi: chủ ưu tiên có link chơi
> được ngay trên web + test được bằng trình duyệt, hơn là giữ engine Unity mà không
> có máy build/test.
>
> **Code Unity cũ KHÔNG xóa, KHÔNG sửa trong đợt này** — giữ nguyên trong
> `src/client/` + `src/server/` để đối chiếu / quay lại nếu cần. Kiến trúc mới sống
> ở `src/nadia/` (xem §8). `src/web/` (slice web tĩnh đã có) là tiền thân của kiến
> trúc này, không phải game thứ hai.
>
> Nguồn Nadia (tra cứu 18/11/2026): SteamDB app 1737100 — "Detected Technologies:
> RPGMaker Engine, Greenworks SDK, NWJS SDK, NodeJS SDK"; xogx.com — "Game Engine:
> RPG Maker (play in your browser)", v1.0117; trang https://xenvn.com/treasure-of-nadia/
> — chơi ngay trên trình duyệt, không cài đặt, Desktop/Android/iPhone. Các trang ghi
> "Ren'Py" là sai, đã đối chiếu và loại. **Không copy asset, nhạc, nhân vật, map,
> cốt truyện hay code của Nadia** — chỉ lấy kiến trúc + cơ chế. Game này sạch,
> không nội dung 18+/harem.

## 0. Tóm tắt 1 đoạn

Phố Xô Bồ chạy như Nadia: **game HTML5/JavaScript thuần, render bằng Pixi.js
(WebGL, fallback Canvas 2D), toàn bộ nội dung là file JSON + PNG + audio tĩnh**.
Mở `index.html` qua web server là chơi — không compile, không `.wasm`, không
cần Unity Editor, không cần dotnet, không cần license CI. Editor làm nội dung là
RPG Maker MV (Windows/Mac, thương mại); nhưng **mọi file game đều là text
(JSON/JS) nên viết và test được ngay trên VM Linux này** bằng trình duyệt +
`python3 -m http.server`, không cần editor. Logic riêng của Phố Xô Bồ (chỉ số
3 màu, nghề, kinh tế, xã hội, quest 5 chương) nằm trong **plugin JavaScript tự
viết** (`js/plugins/PXB_*.js`), dữ liệu nằm trong **`data/*.json`**, giống hệt
cách Nadia tổ chức. Online (công ty=guild, đấu giá, trade) làm ở phase 2 bằng
plugin gọi về server .NET 8 đã có (`src/server/`, sổ cái `EconomyLedger.cs` giữ
nguyên làm nguồn sự thật cho tiền) — MV gốc không có multiplayer, xem §7.

## 1. Nadia chạy như thế nào — kiến trúc gốc cần copy

### 1.1. Ba lớp

| Lớp | Thành phần | Vai trò |
|---|---|---|
| Render | Pixi.js v4 (`js/libs/pixi.js`, `pixi-tilemap.js`, `pixi-picture.js`) | Vẽ sprite/tilemap. WebGL khi có, tự fallback Canvas 2D khi không. ToneFilter (WebGL) / ToneSprite (Canvas) đổi tông màu ngày/đêm. |
| Engine | `js/rpg_core.js`, `rpg_managers.js`, `rpg_objects.js`, `rpg_scenes.js`, `rpg_sprites.js`, `rpg_windows.js` | Core scripts của RPG Maker MV (nguồn mở, MIT — repo `rpgtkoolmv/corescript`, v1.6.1). Vòng lặp game, load data, map/event, scene, cửa sổ UI, âm thanh, input/chạm. |
| Nội dung | `data/*.json` + `img/` + `audio/` + `js/plugins/` | Toàn bộ game: map, event, database, plugin tự viết. Không có code biên dịch. |

### 1.2. Thứ tự load — `www/index.html`

`index.html` load theo đúng thứ tự sau (đọc từ core MV, xem
reverseengineering.wiki — Library:RPG Maker):

1. `js/libs/pixi.js` (v4.5.4), `pixi-tilemap.js`, `pixi-picture.js`,
   `fpsmeter.js`, `lz-string.js`, `iphone-inline-video.browser.js`
2. `js/rpg_core.js` — lớp nền: `Bitmap`, `Graphics`, `Input`, `TouchInput`,
   `Tilemap`, `Sprite`, `AudioManager` nền
3. `js/rpg_managers.js` — `DataManager`, `SceneManager`, `AudioManager`,
   `BattleManager`, `PluginManager`, `StorageManager`, `ConfigManager`
4. `js/rpg_objects.js` — `Game_System`, `Game_Switches`, `Game_Variables`,
   `Game_Map`, `Game_Event`, `Game_Player`, `Game_Party`, `Game_Actor`,
   `Game_Interpreter`, `Game_Timer`
5. `js/rpg_scenes.js` — `Scene_Boot`, `Scene_Title`, `Scene_Map`,
   `Scene_Menu`, `Scene_Save`, `Scene_Load`, `Scene_Gameover`…
6. `js/rpg_sprites.js`, `js/rpg_windows.js` — sprite nhân vật/map, cửa sổ
   menu/dialogue
7. `js/plugins.js` — mảng `$plugins` (tên plugin, bật/tắt, tham số)
8. `js/main.js` — `PluginManager.setup($plugins)` rồi
   `SceneManager.run(Scene_Boot)`

### 1.3. Dữ liệu — `DataManager` + biến toàn cục `$data*`

`DataManager.loadDatabase()` load toàn bộ JSON vào biến toàn cục:

| File | Biến | Nội dung MV gốc |
|---|---|---|
| `data/System.json` | `$dataSystem` | Cấu hình game, màn hình, âm thanh, party khởi đầu, khóa mã hóa |
| `data/MapInfos.json` | `$dataMapInfos` | Danh sách map (id, tên, thứ tự) |
| `data/Map001.json`… | `$dataMap` (map đang chơi) | Tile, event, encounter của 1 map |
| `data/Actors.json` | `$dataActors` | Nhân vật chơi được |
| `data/Classes.json` | `$dataClasses` | Class / nghề gốc của actor |
| `data/Skills.json` | `$dataSkills` | Kỹ năng (ở đây: khóa học, kỹ năng nghề) |
| `data/Items.json` | `$dataItems` | Vật phẩm tiêu dùng |
| `data/Weapons.json` | `$dataWeapons` | Vũ khí (ở đây: công cụ — xem §4) |
| `data/Armors.json` | `$dataArmors` | Giáp (ở đây: quần áo, điện thoại, xe — xem §4) |
| `data/Enemies.json` / `Troops.json` | `$dataEnemies` | Đối thủ (ở đây: chỉ dùng cho Bụi Đời Chợ Cá, §4) |
| `data/States.json` | `$dataStates` | Trạng thái (mệt, ốm, cảm hứng…) |
| `data/CommonEvents.json` | `$dataCommonEvents` | Event dùng chung (sự kiện chung thứ 7, Tết…) |
| `data/Tilesets.json` | `$dataTilesets` | Tileset của map |
| `data/Animations.json` | `$dataAnimations` | Hiệu ứng |

### 1.4. Event — cách Nadia kể chuyện và mở khóa

- Mọi tương tác trong thế giới là **event trên map**: `Game_Event` + `Game_Interpreter`
  chạy chuỗi lệnh (code + parameters) trong JSON của map.
- Trigger: chạm vào (Action Button), chạm nhân vật (Player Touch), tự chạy
  (Autorun), chạy song song (Parallel), tự động theo điều kiện.
- Switch (`$gameSwitches`, on/off) + Variable (`$gameVariables`, số) là bộ nhớ
  của game: mở khu, xong quest, gặp NPC lần đầu đều ghi vào đây.
- `Game_CommonEvent` chạy event dùng chung mọi map (sự kiện chung, đồng hồ game).
- Nadia dùng đúng cơ chế này cho: hotspot (event lấp lánh, nhặt 1 lần/ngày),
  NPC dẫn đường (event thoại theo tiến trình), crafting shrine (event mở menu
  chế tạo), quest (event theo switch/variable).

### 1.5. Save — `StorageManager` + `DataManager.makeSaveContents`

- `DataManager.makeSaveContents()` gom: `$gameSystem`, `$gameScreen`,
  `$gameTimer`, `$gameSwitches`, `$gameVariables`, `$gameSelfSwitches`,
  `$gameActors`, `$gameParty`, `$gameMap`, `$gamePlayer` — **không** lưu
  `$gameTemp`, `$gameMessage`, `$gameTroop`.
- Nội dung save là JSON, nén `LZString.compressToBase64`.
- Desktop (NW.js): ghi file `save/fileN.rpgsave` (+ `config.rpgsave`,
  `global.rpgsave`). **Web: cùng dữ liệu đó ghi vào `localStorage`** của
  trình duyệt — đây là cách bản web Nadia lưu.
- XenVn thêm lớp riêng: tài khoản để sao lưu/đồng bộ save lên server của họ —
  không phải tính năng gốc MV. Phố Xô Bồ làm tương tự ở phase online (§7):
  tài khoản + server lưu save, web vẫn chơi được không cần đăng nhập.
- **Lưu ý:** dữ liệu plugin tự thêm phải móc vào `DataManager.createGameObjects`
  / `makeSaveContents` / `extractSaveContents`, hoặc lưu trong `$gameSystem`
  (quy ước của cộng đồng MV; plugin Yanfly cũng làm vậy). Không để state
  quan trọng chỉ nằm trong biến JS ngoài save — load lại là mất.

### 1.6. Desktop — NW.js

- Bản Steam/PC của Nadia là cùng thư mục `www/` đó, bọc bằng **NW.js**
  (Node.js + Chromium): `package.json` với `"main": "www/index.html"`.
- Greenworks SDK chỉ để nối Steam (achievement…), không phải phần của game.
- Hệ quả: **1 bộ file chạy được cả 3 dạng** — web (host tĩnh), desktop
  (NW.js), mobile (bọc Cordova/WebView, `assets/www/`). Phố Xô Bồ chỉ cần
  web + desktop trước; mobile app bọc sau.

### 1.7. Deploy web — đúng như xenvn

1. Editor MV: File → Deployment → platform **Web Browsers** → xuất thư mục
   `www/`.
2. Upload **nguyên thư mục `www/` lên web server tĩnh** (GitHub Pages,
   Netlify, bất kỳ host tĩnh nào). Mở URL tới `index.html` là chơi.
3. **Không mở `index.html` trực tiếp từ ổ đĩa (`file://`)** — trình duyệt
   chặn load data file, màn hình trắng. Phải qua web server thật
   (kể cả test local: `python3 -m http.server`).
4. Tên file **phân biệt hoa/thường** trên server Linux — Windows thì không,
   sai case là vỡ asset.
5. Audio MV ship cả `.ogg` + `.m4a` (desktop dùng `.ogg`, Safari/iOS cần
   `.m4a`). iOS cần 1 chạm màn hình để bật âm thanh.

## 2. Kiến trúc mới của Phố Xô Bồ — tổng thể

```
Người chơi (PC / Android / iPhone, trình duyệt)
        │  mở https://tinnt120899.github.io/pho-xo-bo/  (GitHub Pages)
        ▼
┌─────────────────────────────────────────────────────────────┐
│  www/  — file tĩnh, không server-side (Phase 1)              │
│  index.html                                                  │
│  ├─ js/libs/      pixi.js v4, pixi-tilemap, lz-string        │
│  ├─ js/rpg_core.js / rpg_managers.js / rpg_objects.js /      │
│  │  rpg_scenes.js / rpg_sprites.js / rpg_windows.js          │
│  │  (core MV, MIT — KHÔNG sửa, chỉ dùng)                     │
│  ├─ js/plugins.js  (khai báo plugin + tham số)               │
│  ├─ js/plugins/PXB_*.js  ← TOÀN BỘ logic riêng Phố Xô Bồ     │
│  ├─ js/main.js                                               │
│  ├─ data/*.json    ← TOÀN BỘ nội dung 12 mục đã chốt          │
│  ├─ img/           tileset, character, face, picture (CC0)   │
│  └─ audio/         .ogg + .m4a (nhạc CC0, giọng Helio/Aria)   │
└─────────────────────────────────────────────────────────────┘
        │  Phase 2 (online) — plugin PXB_Online.js gọi HTTP/WS
        ▼
┌─────────────────────────────────────────────────────────────┐
│  Server .NET 8 (giữ nguyên src/server/)                      │
│  EconomyLedger (sổ cái double-entry, nguồn sự thật tiền) +   │
│  API tài khoản / save-sync / đấu giá / công ty=guild          │
│  PostgreSQL (dữ liệu) — Redis chỉ làm read-model             │
└─────────────────────────────────────────────────────────────┘
```

Nguyên tắc:

- **Không sửa core MV.** Mọi logic riêng là plugin — core hỏng thì thay core
  mới không mất game. Đây là cách cộng đồng MV làm (Yanfly…).
- **Data là nguồn sự thật cho nội dung; plugin là nguồn sự thật cho luật.**
  Số chốt (học phí, lương, lãi, phí) nằm trong data JSON **và** hằng plugin
  `PXB_Balance.js` — 2 chỗ phải khớp nhau, kiểm tra bằng test tĩnh (§9).
- **Mọi hệ mới vẫn đối chiếu `docs/nadia-reference.md`** trước khi viết
  (hotspot, crafting là cổng tiến trình, NPC dẫn đường, điện thoại làm hub).
- **Số chưa chốt ghi PROVISIONAL** trong cả JSON lẫn plugin, như quy ước cũ
  với `GameBalance.cs`.

## 3. Cái Nadia KHÔNG có — và cách xử lý (nói thẳng)

Đây là 3 điểm kiến trúc Nadia **đi ngược 3 mục đã chốt**, phải quyết cách
xử lý ngay từ đầu, không giấu:

| # | Mục đã chốt | Nadia / MV gốc | Cách xử lý trong kiến trúc này |
|---|---|---|---|
| 1 | **2.5D isometric** (Mục 10, GDD) — màn dọc 9:16, sort axis (0,1,−0.26) | MV là **top-down 2D tile** (tile 48×48, 4 hướng). Không có isometric sẵn. | **Giữ 2.5D bằng plugin render riêng `PXB_Isometric.js` (§5):** thay `Tilemap` mặc định bằng renderer isometric trên Pixi (chiếu 2:1, sắp xếp theo y), map vẫn là dữ liệu JSON kiểu MV. Tiền lệ: Kadajah ISO2.5D cho MZ (Three.js, thương mại) chứng minh isometric trên nền RPG Maker là làm được — không copy plugin đó, tự viết bản MV/Pixi gọn cho 18 khu. **Nếu plugin này thất bại, phương án dự phòng là chấp nhận top-down 2D — nhưng đó là bỏ mục chốt 2.5D, phải hỏi lại chủ trước khi làm.** |
| 2 | **Online nhiều người** (Mục 11: slice online, công ty=guild, đấu giá, trade) | MV **single-player offline**, không có multiplayer, không có server. | **Phase 1: chơi đơn như Nadia** (NPC đóng vai người chơi, sự kiện chung theo giờ game). **Phase 2: plugin `PXB_Online.js` + server .NET 8 đã có** (§7): mọi giao dịch tiền qua `EconomyLedger` server, client chỉ hiển thị. Không bao giờ để client tự quyết tiền của người khác. |
| 3 | **Build/test trên VM này** (lý do đổi kiến trúc) | Editor MV **chỉ Windows/Mac, thương mại (~$79.99)** — cũng **không chạy được trên VM Linux này**. | Đổi kiến trúc **không giải quyết "không có editor MV"** — nó giải quyết "không có máy build/test": vì game là **file text (JS/JSON)**, viết tay + test bằng trình duyệt ngay trên VM, không cần editor MV để có bản chơi được. Editor MV chỉ cần khi muốn dùng giao diện kéo-thả làm map/database; mọi map/data đều viết tay được bằng JSON (đã có sẵn `src/web/data/maps.js` làm mẫu). **Cần nói rõ với chủ: đây là đổi nút thắt, không phải xóa nút thắt.** |

Hệ quả khác cần biết:

- **Hiệu năng:** MV web load toàn bộ `data/` + `img/` theo map, nhẹ hơn Unity
  WebGL nhiều (không `.wasm` chục MB, không cần header COOP/COEP). Máy yếu
  vẫn chạy — đúng lý do Nadia web chơi được trên điện thoại cũ.
- **Bảo mật:** code + data là plaintext JS/JSON, ai cũng đọc được. Đừng để
  bí mật gì trong client. Tiền/đấu giá phải qua server (§7); luật cấm
  (cash-out, cờ bạc, cho vay lãi — GDD Mục 7) enforce cả 2 phía: plugin
  chặn ở client, ledger chặn ở server.
- **Tiếng Việt:** MV hỗ trợ Unicode; font tiếng Việt phải kèm trong
  `fonts/` (MV dùng font hệ thống + `GameFont`); test dấu tiếng Việt trên
  cả Chrome/Safari ngay từ slice đầu.

## 4. Data JSON — 12 mục đã chốt ánh xạ vào `data/` nào

### 4.1. Map — 18 khu (Mục 3, `docs/districts.md`)

| Map ID | Khu | Tầng | Ghi chú |
|---|---|---|---|
| Map001 | Xóm Trọ Cũ | 1 | Map bắt đầu. Slice Phase 1. |
| Map002 | Chợ Đầu Mối | 1 | Slice Phase 1 (buôn bán, Bụi Đời Chợ Cá). |
| Map003 | Khu Công Nhân | 1 | Việc tay chân, ca kíp. |
| Map004 | Bến Xe Miền Đông | 1 | Đi lại liên khu, shipper/bốc vác. |
| Map005 | Làng Đại Học | 2 | Học vấn, khóa ngắn, việc thêm. |
| Map006 | Chung Cư Cũ | 2 | Nhà tầng 2. |
| Map007 | Phố Văn Phòng Nhỏ | 2 | Văn phòng cấp thấp, thực tập. |
| Map008 | Khu Chung Cư Cao Cấp | 3 | Nhà tầng 3. |
| Map009 | Phố Thương Mại | 3 | Buôn bán vừa, cửa hàng. |
| Map010 | Khu Công Nghệ | 3 | Việc công nghệ, cần Trí cao. |
| Map011 | Phố Tây | 4 | Dịch vụ cao cấp. |
| Map012 | Khu Biệt Thự Ven Sông | 4 | Nhà tầng 4. |
| Map013 | Quận Tài Chính | 4 | Ngân hàng, chứng khoán mô phỏng, công ty lớn. |
| Map014 | Đảo Thượng Lưu | 5 | Chỉ mở khi tài sản ≥ ngưỡng siêu giàu. |
| Map015 | Khu Penthouse | 5 | Nhà tầng 5. |
| Map016 | Khu Sân Golf & Resort | 5 | Giải trí/quan hệ tầng 5. **Bến Du Thuyền nằm trong khu này, không phải khu riêng — đúng 18 khu.** |
| Map017 | Công Viên An Bình | Chung | Gặp gỡ, hẹn hò, sự kiện cộng đồng, chữa lành. |
| Map018 | Phố Đi Bộ – Chợ Đêm | Chung | Sự kiện chung thứ 7 20:00, buôn bán đêm, Bụi Đời Chợ Cá. |

- Mỗi map là 1 file `data/MapNNN.json`: tile + event (hotspot, NPC, sạp, cửa).
- `data/MapInfos.json` liệt kê đủ 18 map — test tĩnh đếm đúng 18 (§9).
- Mở khóa theo chương (Mục 9): Chương 1 → Tầng 1; Chương 2 → Tầng 2 (việc ổn
  định, Trí 40 hoặc Cao đẳng, Danh vọng 200); Chương 3 → bài kiểm tra rank
  (rank tụt nếu Danh vọng/An Yên thấp); Chương 4 → Tầng 3 (3 quest giúp
  người + ≥1 quan hệ thân thiết); Chương 5 → Tầng 4–5 theo nhánh.
- Fast travel chỉ tới map đã mở — switch `$gameSwitches[mapMở]` + event
  "cửa đỏ" kiểu Nadia (chưa mở = khóa, ghi rõ điều kiện).

### 4.2. Chỉ số — 3 màu + pha trộn (Mục 4, `docs/stats.md`)

MV gốc chỉ có 8 tham số actor (HP/MP/ATK/DEF/MAT/MDF/AGI/LUK) — **không đủ**.
Cách làm: không dùng param MV cho chỉ số gốc; lưu trong `$gameSystem` qua
plugin `PXB_Stats.js` (xem §6.1):

- 3 gốc: Đỏ **Thể**, Xanh **Trí**, Vàng **Tâm** (mỗi 0–100).
- Pha trộn (tính ra, không lưu riêng): Đỏ+Xanh = Tím **Kỷ**; Đỏ+Vàng = Cam
  **Dũng**; Xanh+Vàng = Lục **Sáng**; 3 màu cân bằng = Trắng **An Yên**.
- Có trần tổng (số trần là PROVISIONAL — GDD chỉ chốt "có trần", chưa chốt
  số; giữ 300 như ví dụ cũ cho tới khi chủ chốt số khác).
- Tiền, Danh vọng, EXP là **tài nguyên**, không phải chỉ số gốc — lưu riêng.
- Sức khỏe/Năng lượng là đồng hồ ngày (hồi khi ngủ/ăn/nghỉ).
- `$gameVariables` chỉ dùng cho cờ/đếm quest; **không** dùng variable MV
  làm chỉ số (dễ đụng plugin khác, khó test).

### 4.3. Học vấn (Mục 5 — số đã chốt)

`data/Skills.json` + `PXB_Education.js`. Bảng chốt (từ `GameBalance.cs`,
chuyển nguyên sang JSON):

| Bằng | Học phí | Thời gian | Yêu cầu Trí | EXP | Danh vọng | Mentor |
|---|---|---|---|---|---|---|
| THPT | 0 | 30 ngày | 20 | 0 | 0 | Không |
| Cao đẳng | 20.000.000 | 60 ngày | 40 | 500 | 0 | Không |
| Cử nhân | 80.000.000 | 120 ngày | 60 | 1.500 | 200 | Không |
| Thạc sĩ | 200.000.000 | 180 ngày | 75 | 3.000 | 500 | Không |
| Tiến sĩ/Học giả | 500.000.000 | 240 ngày | 90 | 6.000 | 1.500 | Có |

- Khóa ngắn hạn: 3–7 ngày, 2–10 triệu, +10 một chỉ số phụ, mở nghề phụ.
- Cung–cầu tuần: 1 nghề thiếu người (lương +30%), 1 nghề bão hòa (lương
  −15%). Trường nhận 20–30 học viên/khóa, ưu tiên thứ tự đăng ký + Trí +
  Danh vọng; học bổng cho người nghèo mà Trí cao.
- Học = event ở Làng Đại Học (Map005) + tab Học tập trên điện thoại (§6.4).

### 4.4. Nghề, công cụ, nhà/xe/điện thoại/quần áo (Mục 6–7)

| Hệ | Ánh xạ MV | File |
|---|---|---|
| Nghề (3 nghề slice: bán rong, shipper, nhân viên quán; MVP 10 nhóm — danh sách 10 nhóm chưa chốt, để PROVISIONAL) | `data/Classes.json` (nhóm nghề) + event làm ca ở map + `PXB_Jobs.js` (lương theo chỉ số chính, khung tốt +25%, quota tuần, cung–cầu) | `data/Classes.json`, `PXB_Jobs.js` |
| Giấy phép | `data/Items.json` (giấy phép là item mua bằng tiền game) | Sạp ăn 50 triệu, phòng khám 200 triệu |
| Thi chứng chỉ | Event thi + `PXB_Jobs.js` | Phí 5–20 triệu tiền game, trượt mất phí, chờ tuần sau; nạp chỉ mua thêm 1 lượt thi/tuần, không mua đậu |
| Công ty = guild | `data/CommonEvents.json` + `PXB_Company.js` (Phase 2 online; Phase 1 là công ty NPC) | Lập cần 500 triệu + giấy phép + thuê văn phòng theo tầng; chia lợi nhuận theo điểm đóng góp; 0 đóng góp 2 tuần → loại |
| 4 công cụ (Xe Đẩy, Đèn Soi, Sổ Tay, Xẻng/Cuốc) | `data/Weapons.json` — mỗi bậc nâng cấp **đổi hành vi thật** (Xe Đẩy chở nhiều hơn + đi được đường mưa; Đèn Soi thấy hotspot ẩn…), không chỉ +5% số | `PXB_Crafting.js`, `PXB_Tools.js` |
| Nhà 6 bậc | `data/Armors.json` (nhóm "Nhà") + event mua/ở | Phòng trọ thuê 2 triệu/tháng → chung cư mini 800 triệu → nhà phố nhỏ 3 tỉ → nhà phố lớn 8 tỉ → biệt thự 25 tỉ → penthouse/đảo 100 tỉ |
| Xe, điện thoại, quần áo | `data/Armors.json` (nhóm "Xe"/"Điện thoại"/"Quần áo") | Mỗi món có 3 dòng chỉ số (cộng chỉ số / mở nghề-danh hiệu / set bonus) + phạt khi mặc sai dress-code (vd đồ chợ đi phỏng vấn giám đốc = Giao tiếp −20) |
| Tiền, lãi, đấu giá | `$gameParty.gold()` (tiền game) + `PXB_Economy.js` | Lãi tiết kiệm 0,5%/tháng game; phí sàn đấu giá 5%; mua lớn Danh vọng +50. **Cấm (enforce cả client + server):** cash-out, cho vay lấy lãi, cờ bạc, mua đồ bằng tiền thật |

### 4.5. Xã hội (Mục 8) — `PXB_Social.js`

- Quan hệ là event + dữ liệu plugin: người yêu/vợ-chồng, bạn thân (1 người),
  hội bạn (3–5), gia đình (cha mẹ, con), đối tác công ty.
- Thân thiết 0–100; bỏ bê 7 ngày game → giảm; được hỗ trợ → +20% EXP;
  chỉ duy trì được 2–3 quan hệ sâu trong 3 khung/ngày; solo chậm hơn
  30–50%, không có ending gia đình/cặp đôi.
- NPC có đời sống riêng (lịch theo khung, quest riêng) — event Parallel
  + switch theo ngày, kiểu NPC Nadia.

### 4.6. Quest 5 chương + danh hiệu (Mục 9, Mục 3)

- Quest chính: `data/CommonEvents.json` + event theo chương; mỗi chương gắn
  rank (§4.1). Side quest kiểu Nadia: tìm đồ thất lạc, chế quà, giúp NPC →
  mở khu/nghề.
- Danh hiệu: sưu tầm không giới hạn, hiển thị 1 chính + 2–3 phụ; mỗi danh
  hiệu có phe Chính/Tà/Trung lập + yêu cầu chỉ số + khóa nghề; xung đột
  chặn 2 chiều (Tướng Cướp ↔ Cảnh sát/Thẩm phán/Hải quan/Giáo viên…).
  Lưu trong `PXB_Titles.js`, kiểm tra bằng test tĩnh (§9).
- Bụi Đời Chợ Cá: mode chiến thuật vui 3v3/5v5 theo lượt trên lưới
  isometric (~3 phút, vũ khí hài, không máu me/không mất đồ vĩnh viễn).
  Trong MV: dùng `data/Troops.json` + `data/Enemies.json` làm khung đối
  thủ, nhưng **không dùng battle mặc định của MV** (đánh theo lượt kiểu
  RPG) — viết scene riêng `PXB_MarketBattle.js`. Chi tiết luật vẫn chưa
  chốt (chỉ có 1 dòng teaser nguồn Hàng Rong) — để PROVISIONAL.

### 4.7. Chữa lành (Mục 12 — đã chốt)

Không phải 1 hệ riêng mà là luật chạy xuyên suốt plugin: miss khung không
phạt; thất bại được NPC giúp; nghỉ ngơi được thưởng; An Yên là giá trị riêng
(không đo bằng tiền); nhiều ending đều được tôn trọng (Giám đốc / Học giả /
Gia đình / Tự do / Siêu giàu). Không FOMO, không quest khóa ngày cứng kiểu
Nadia (thứ Ba/Năm mới làm được) — quest mở theo tiến trình.

## 5. Render 2.5D trên Pixi — `PXB_Isometric.js` (plugin bắt buộc)

Vì MV gốc không có isometric, plugin này là **điều kiện để giữ mục chốt
2.5D**. Nếu không làm được plugin này, kiến trúc Nadia không đáp ứng được
game — xem bảng §3 dòng 1.

- **Chiếu:** world (x, y) → màn hình: `sx = (x − y) × tileW/2`,
  `sy = (x + y) × tileH/2`, tile 2:1 (vd 64×32). Góc camera X ~30°/Y 45°
  như chuẩn cũ (`docs/art-assets.md`).
- **Sắp xếp:** sort theo `x + y` (tương đương sort axis (0, 1, −0.26) của
  Unity); nhân vật/NPC/đồ vật là sprite có chân neo ở đáy tile.
- **Map:** dữ liệu map vẫn viết theo lưới MV (tile + event có tọa độ lưới),
  plugin chỉ đổi cách vẽ — không đổi cách viết nội dung. Map editor MV vẫn
  dùng được để đặt event, hình vẽ do plugin chiếu lại.
- **Màn dọc 9:16:** viewport 720×1280 (tỉ lệ 9:16), camera theo player,
  zoom khi cần xem chi tiết (chuẩn Nadia: chi tiết thấy được khi zoom).
- **Asset:** atlas theo khu (1 atlas/khu, như chuẩn cũ); tile PNG CC0 hoặc
  tự vẽ; không dùng tileset Nadia.
- **Fallback:** nếu WebGL không có, Pixi fallback Canvas 2D — isometric vẫn
  vẽ được (chậm hơn), không vỡ game.

## 6. Plugin cần viết — `js/plugins/PXB_*.js`

Thứ tự load trong `js/plugins.js` (plugin sau được phép ghi đè/hook plugin
trước; plugin nào cũng khai báo `/*:` với `@plugindesc`, `@author`,
`@param` theo quy ước MV):

| # | Plugin | Việc | Dựa trên code cũ |
|---|---|---|---|
| 1 | `PXB_Balance.js` | **Hằng số duy nhất** cho số đã chốt (học phí, lương, lãi, phí, thang nhà…) — tương đương `GameBalance.cs`. Plugin khác không hardcode số. | `GameBalance.cs` |
| 2 | `PXB_Stats.js` | 3 chỉ số gốc + 4 chỉ số pha trộn + trần tổng + lưu vào `$gameSystem` (để vào save) | `Stats.cs` |
| 3 | `PXB_Time.js` | 1 ngày game = 30 phút thật, 3 khung Sáng/Chiều/Tối; miss khung không phạt; sự kiện chung thứ 7 20:00; đồng hồ chạy bằng `Game_Timer` + CommonEvent | `TimeSystem.cs` |
| 4 | `PXB_PhoneHub.js` | Điện thoại làm hub: 9 tab Danh bạ/Tin nhắn, Ngân hàng, Bản đồ, Việc làm, Chợ, Học tập, Sức khỏe, Xã hội, Cài đặt. Mở bằng phím P / nút điện thoại. Điện thoại không thay thế thế giới — vẫn phải đi lại. | `PhoneHub.cs`, `src/web/` |
| 5 | `PXB_Hotspot.js` | Hotspot lấp lánh kiểu Nadia: to ≥44×44 pt, chạm được, vàng (thường) / cam (hiếm), nhặt 1 lần/ngày game, reset khi sang ngày mới, chỉ có đồ đúng khung | `Exploration.cs` |
| 6 | `PXB_Crafting.js` + `PXB_Tools.js` | Chế tạo là **cổng tiến trình**: công thức học qua chơi/NPC dạy; Xe Đẩy Hàng = Khung Sắt + Bánh Xe + Ván Gỗ (tương đương Basic Shovel); 4 công cụ nâng cấp đổi hành vi thật | `Crafting.cs` |
| 7 | `PXB_Jobs.js` | 3 nghề slice + quota tuần + cung–cầu + thi chứng chỉ + lương theo chỉ số chính, khung tốt +25% | `Jobs.cs` |
| 8 | `PXB_Education.js` | 5 bậc học + khóa ngắn + học bổng + ghế 20–30/khóa | `GameBalance.cs` (Degrees) |
| 9 | `PXB_Economy.js` | Tiền, lãi 0,5%, đấu giá phí 5%, trade item-to-item, set bonus, dress-code; **4 hàm cấm luôn trả false / chặn**: `CashOut`, `LendWithInterest`, `Gamble`, `BuyWithRealMoney` | `Economy.cs`, `EconomyLedger.cs` (luật) |
| 10 | `PXB_Social.js` | Quan hệ, thân thiết, hỗ trợ +20% EXP, bỏ bê 7 ngày, ly hôn chia tài sản | `Social.cs` |
| 11 | `PXB_Titles.js` | Danh hiệu + xung đột 2 chiều + quest "Cải tà quy chính" | `TitleConflict.cs` |
| 12 | `PXB_Story.js` | 5 chương gắn rank + side quest kiểu Nadia + NPC dẫn đường (cô Tư…) thay Soul Crystal, gợi ý không biến mất giữa game | `PlayerProgress.cs` |
| 13 | `PXB_Isometric.js` | Render 2.5D (§5) — viết đầu tiên, vì mọi map đều phụ thuộc nó | `docs/art-assets.md` |
| 14 | `PXB_MarketBattle.js` | Bụi Đời Chợ Cá (Phase 2, luật chưa chốt) | GDD Mục 11 |
| 15 | `PXB_Online.js` | Phase 2: HTTP/WebSocket về server .NET (§7), save-sync kiểu xenvn | `src/server/` |
| 16 | `PXB_SaveCloud.js` | Phase 2: tài khoản + đồng bộ save nhiều thiết bị (xenvn model) | — |

Quy ước viết plugin (để test được trên VM, §9):

- Mỗi plugin là 1 file JS thuần, `"use strict"`, không dùng `require`
  (web không có Node), không dùng API chỉ có trên NW.js ở code chạy web.
- Không sửa file core MV; chỉ alias/hook function core (quy ước MV:
  `var _alias = Class.prototype.method; Class.prototype.method = function…`).
- Mọi số lấy từ `PXB_Balance.js`; số chưa chốt ghi `PROVISIONAL` trong
  comment + trong `docs/test-report.md`.

## 7. Online Phase 2 — server .NET 8 giữ nguyên, client đổi

MV không có multiplayer, nên online không nằm trong engine — nằm trong
plugin + server:

- **Server giữ nguyên `src/server/`:** .NET 8, `EconomyLedger.cs`
  (double-entry, nguồn sự thật cho tiền; 4 hàm cấm throw
  `InvalidOperationException`), PostgreSQL, Redis chỉ làm read-model.
- **Plugin `PXB_Online.js`** gọi API server bằng `fetch` (web) /
  WebSocket (chat, đấu giá trực tiếp, sự kiện chung). Client **không bao
  giờ** tự quyết số tiền/đồ của người khác — mọi giao dịch phải có
  `IdempotencyKey`, server kiểm tra rồi mới ghi ledger.
- **Save-sync kiểu xenvn:** tài khoản (đăng ký tùy chọn, chơi được không
  cần đăng nhập) → save JSON (LZString base64 như MV) đẩy lên server →
  đồng bộ nhiều thiết bị. Local `localStorage` vẫn là save mặc định khi
  offline.
- **Chống cold-start (GDD Mục 11):** NPC đóng vai người chơi, 1 server
  chung, sự kiện chung thứ 7 20:00 khu 18, quest cần 2 người — logic này
  ở server + `PXB_Online.js`, không ở core MV.

## 8. Cây thư mục mới — `src/nadia/`

```
src/nadia/                      ← kiến trúc mới (bản này là chuẩn từ nay)
├── www/
│   ├── index.html
│   ├── js/
│   │   ├── libs/               pixi.js v4, pixi-tilemap.js, lz-string.js …
│   │   ├── rpg_core.js         core MV (MIT, không sửa)
│   │   ├── rpg_managers.js     core MV (MIT, không sửa)
│   │   ├── rpg_objects.js      core MV (MIT, không sửa)
│   │   ├── rpg_scenes.js       core MV (MIT, không sửa)
│   │   ├── rpg_sprites.js      core MV (MIT, không sửa)
│   │   ├── rpg_windows.js      core MV (MIT, không sửa)
│   │   ├── plugins.js          khai báo plugin + tham số
│   │   ├── main.js
│   │   └── plugins/
│   │       ├── PXB_Balance.js
│   │       ├── PXB_Stats.js
│   │       ├── PXB_Time.js
│   │       ├── PXB_PhoneHub.js
│   │       ├── PXB_Hotspot.js
│   │       ├── PXB_Crafting.js
│   │       ├── PXB_Jobs.js
│   │       ├── PXB_Education.js
│   │       ├── PXB_Economy.js
│   │       ├── PXB_Social.js
│   │       ├── PXB_Titles.js
│   │       ├── PXB_Story.js
│   │       ├── PXB_Isometric.js
│   │       └── PXB_Online.js   (Phase 2)
│   ├── data/
│   │   ├── System.json  MapInfos.json  Actors.json  Classes.json
│   │   ├── Skills.json  Items.json  Weapons.json  Armors.json
│   │   ├── Enemies.json  Troops.json  States.json  Animations.json
│   │   ├── Tilesets.json  CommonEvents.json
│   │   └── Map001.json … Map018.json   (đúng 18 khu, §4.1)
│   ├── img/                    tileset / character / face / picture (CC0)
│   ├── audio/                  .ogg + .m4a (CC0, giọng Helio/Aria)
│   └── fonts/                  font tiếng Việt
├── package.json                NW.js desktop: { "main": "www/index.html" }
└── README.md                   cách chạy/test/deploy (§9–§10)
```

- `src/client/` (Unity) + `src/server/` (.NET) **giữ nguyên, không xóa** —
  server dùng lại ở Phase 2; Unity là phương án dự phòng nếu plugin
  isometric thất bại.
- `src/web/` (slice web tĩnh) là bản thử nghiệm trước của mô hình này —
  giữ lại làm tham chiếu, không phát triển thành game thứ hai; logic đã
  chốt trong `src/web/js/game.js` port sang plugin ở bảng §6.

## 9. Test — chạy thật được trên VM này (đây là điểm đổi kiến trúc giải quyết)

Không cần dotnet, không cần Unity, không cần license CI:

| Loại test | Cách chạy trên VM | Lệnh |
|---|---|---|
| Cú pháp JS | `node --check` từng plugin | `node --check src/nadia/www/js/plugins/PXB_*.js` |
| JSON hợp lệ + đủ 18 map | script tĩnh Python (mở rộng `check_static.py`) | `python3 src/server/tests/check_static.py` — thêm nhóm kiểm tra `data/`: đủ 18 `MapNNN.json`, `MapInfos.json` khớp, số trong JSON khớp `PXB_Balance.js`, danh hiệu xung đột 2 chiều, công thức chế tạo đủ nguyên liệu |
| Chạy game thật | web server tĩnh + trình duyệt | `cd src/nadia/www && python3 -m http.server 8000` → mở `http://localhost:8000/` — đi phố, nhặt hotspot, chế Xe Đẩy, làm ca nghề, mở điện thoại, sang khung/ngày, save/load |
| Test tự động trên trình duyệt | headless (khi có) — kiểm tra load không lỗi, `Scene_Boot` chạy, save/load localStorage | Ghi lại kết quả, không bịa — chưa chạy headless được thì ghi rõ "chưa chạy" |
| Test online (Phase 2) | `dotnet build` server đã chạy được trên VM (SDK 8.0.428 ở `~/.dotnet`); `dotnet test` vẫn kẹt RAM — chạy trên GitHub Actions | `dotnet test` qua CI, không phải trên VM |

**Quy tắc test (giữ từ trước):** không bịa kết quả build/test. Chưa mở
trình duyệt chạy thì ghi "chưa chạy thật". Test tĩnh PASS không có nghĩa
là game chạy được — chỉ có mở trình duyệt chơi slice mới tính.

## 10. Build / deploy — không cần CI Unity nữa

| Bước | Cách làm |
|---|---|
| Viết nội dung | Viết tay JSON/JS trong `src/nadia/www/` (không cần editor MV), hoặc dùng editor MV trên máy Windows/Mac rồi copy thư mục `www/` về |
| Test local | `python3 -m http.server 8000` trong `src/nadia/www/` → mở trình duyệt |
| Deploy web | Push `src/nadia/www/` lên GitHub → GitHub Pages (Source: Deploy from a branch, thư mục `www`) → link `https://tinnt120899.github.io/pho-xo-bo/` — **không cần quyền Workflows, không cần secret Unity, không cần workflow `.github/workflows/`** (đó chính là nút thắt cũ được gỡ) |
| Desktop | Thêm `package.json` NW.js → đóng gói NW.js (Windows/Mac/Linux) — làm sau, khi web ổn |
| Mobile app | Bọc `www/` bằng Cordova/WebView — làm sau, khi web ổn |
| Online | Deploy server .NET 8 (giữ CI dotnet-test đã có) + plugin `PXB_Online.js` |

## 11. Lộ trình chuyển đổi (từ Unity sang Nadia)

| Giai đoạn | Việc | Xong khi |
|---|---|---|
| 1 — Khung (ngay) | Dựng `src/nadia/www/` trống đúng cấu trúc §8: `index.html` + core MV + `plugins.js` + `main.js` + `data/` tối thiểu (System, MapInfos, Map001–002) + `PXB_Balance.js` + `PXB_Isometric.js` bản đầu | Mở trình duyệt thấy map Xóm Trọ Cũ vẽ isometric, đi được |
| 2 — Slice chơi được | Port slice đã có (`src/web/` + logic C# slice) sang plugin: `PXB_Stats`, `PXB_Time`, `PXB_Hotspot`, `PXB_Crafting`, `PXB_Jobs`, `PXB_PhoneHub`; 2 map slice (Map001–002), 3 nghề, 2 công thức | Chơi hết 1 ngày game (3 khung) trên trình duyệt, save/load được |
| 3 — Đủ 18 khu + 5 chương | Thêm Map003–018, `PXB_Education`, `PXB_Economy`, `PXB_Social`, `PXB_Titles`, `PXB_Story`; art CC0 theo `docs/art-assets.md` | Chơi được Chương 1–2, mở được Tầng 2 |
| 4 — Online | `PXB_Online.js` + `PXB_SaveCloud.js` + server .NET (ledger, đấu giá, công ty=guild) | 2 người chơi cùng thấy nhau / trade được qua server |
| 5 — Release | Bụi Đời Chợ Cá, hệ phụ (câu cá, trồng cây), desktop NW.js, mobile bọc | Bản release đầy đủ theo GDD |

**Không làm song song 2 game:** mọi hệ mới viết ở `src/nadia/` trước;
Unity chỉ là phương án dự phòng, không phát triển thêm trừ khi chủ quyết
quay lại.

## 12. Rủi ro còn lại (nói thẳng)

1. **Plugin isometric là rủi ro lớn nhất.** Chưa có code nào chứng minh
   isometric chạy ổn trên MV/Pixi v4 với 18 khu + NPC + hotspot. Nếu
   plugin này chậm/vỡ, phải hỏi lại chủ: chấp nhận top-down 2D hay quay
   lại Unity. Đừng cố giấu bằng cách vẽ "giả isometric".
2. **Editor MV thương mại + chỉ Windows/Mac.** Ai làm map bằng editor thì
   cần mua MV (~$79.99) + máy Windows/Mac. Viết tay JSON thì không cần,
   nhưng chậm hơn và dễ sai tay — test tĩnh §9 là bắt buộc.
3. **MV là engine 2015, Pixi v4 cũ.** Không có update chính thức; nâng
   Pixi lên v5 (cộng đồng đã làm) thì phải test lại toàn bộ render.
   Đừng nâng Pixi giữa chừng khi chưa có test trình duyệt chạy được.
4. **Plaintext JS/JSON:** không chống copy/cheat ở client. Mọi thứ có
   giá trị (tiền, đấu giá, rank) phải qua server Phase 2.
5. **Số chưa chốt vẫn chưa chốt:** trần chỉ số tổng, ngưỡng An Yên, danh
   sách 10 nhóm nghề MVP, luật chi tiết Bụi Đời Chợ Cá — giữ PROVISIONAL,
   không tự chốt số trong plugin/data.
6. **Đảo ngược quyết định cũ:** file này đảo ngược `docs/tech-switch-nadia.md`
   §4. Đọc 2 file cùng nhau khi cần biết lịch sử: 18/11 18:10 quyết giữ
   Unity → 18/11 22:30 chủ cho phép đổi hẳn sang Nadia → file này là
   kiến trúc mới.

## Nguồn

- SteamDB app 1737100 — Treasure of Nadia, Detected Technologies: RPGMaker
  Engine, Greenworks SDK, NWJS SDK, NodeJS SDK.
  https://steamdb.info/app/1737100/depots/
- xogx.com — Treasure of Nadia, Game Engine: RPG Maker (play in your
  browser), v1.0117.
- https://xenvn.com/treasure-of-nadia/ — chơi trên web, không cài đặt,
  Desktop/Android/iPhone, đăng ký sao lưu/đồng bộ (đọc 18/11/2026).
- RPG Maker MV core scripts (MIT): `rpgtkoolmv/corescript` v1.6.1 —
  cấu trúc `js/`, thứ tự load `index.html`, `DataManager`, `StorageManager`
  (localStorage web / file `.rpgsave` NW.js).
- DeepWiki `miaowm5/RMMV-F1` — tổng quan kiến trúc MV, deployment desktop/web,
  plugin system, event system.
- reverseengineering.wiki — Library:RPG Maker (MV/MZ layout, save LZString).
- naughty.games — RPG Maker MV/MZ web deployment guide (`www/`, Pixi WebGL/
  Canvas fallback, không mở `file://`, case-sensitive).
- Repo: `docs/gdd.md` (12 mục), `docs/districts.md` (18 khu),
  `docs/stats.md`, `docs/economy.md`, `docs/nadia-reference.md`,
  `docs/nadia-scene-study.md`, `docs/webgl-nadia-study.md`,
  `docs/tech-switch-nadia.md` (§4 — quyết định cũ, đã bị file này đảo ngược),
  `docs/ci-build-test.md` (CI Unity cũ — không còn là đường chính),
  `src/client/Assets/Scripts/GameBalance.cs` (số chốt, nguồn port sang
  `PXB_Balance.js`), `src/server/src/EconomyLedger.cs` (server Phase 2),
  `src/web/` (slice web, mẫu port sang plugin).
