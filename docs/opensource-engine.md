# Engine open-source thay RPG Maker MV Editor — Phố Xô Bồ

> **Ngày:** 19/11/2026 — theo yêu cầu của chủ: tìm open-source tương tự để giải
> quyết vấn đề **RPG Maker MV Editor trả phí (~$79,99), chỉ Windows/Mac, không
> chạy được trên VM Linux này**.
>
> **Kết luận chốt: Godot 4 (MIT) — engine duy nhất trong các ứng viên giải quyết
> được đồng thời cả 3 nút thắt: (1) editor miễn phí chạy trên Linux,
> (2) 2.5D isometric có sẵn, (3) export web lên GitHub Pages + online có sẵn.**
>
> Trạng thái hiện tại (19/11, đã kiểm chứng trong repo): bản MV vẫn là bản đang
> chơi được — `src/nadia/www/` (core MV v1.6.1 MIT, 17 plugin PXB, Map001–009,
> MapInfos đủ 18 khu), đã đẩy lên branch `gh-pages`. **Không xóa, không thay
> bản MV cho tới khi bản Godot chơi được tương đương.** Godot là đường chuyển
> đổi song song, không phải đập đi làm lại trong 1 ngày.

## 0. Vấn đề cần giải — nói cho đúng

Cần phân biệt 3 phần của RPG Maker MV, vì chỉ 1 phần là vấn đề:

| Phần | Giấy phép | Vấn đề? |
|---|---|---|
| **Runtime engine** (`js/rpg_*.js`, Pixi.js) | **MIT, open-source** — đã tải đủ vào `src/nadia/www/js/` | Không. Chạy được trên mọi trình duyệt, không cần license. |
| **Game data** (`data/*.json`, map, plugin PXB) | Của team, tự viết | Không. File text, sửa bằng tay được. |
| **Editor** (phần mềm vẽ map / database / event bằng chuột) | **Đóng, trả phí ~$79,99, chỉ Windows/Mac** | **Có — đây là nút thắt duy nhất.** Trên VM Linux này không mở được editor, nên map phải viết bằng file JSON tay, không kéo-thả được. |

Nói cách khác: game đã chạy được bằng engine MV open-source, chỉ thiếu cái
editor miễn phí. Mọi ứng viên dưới đây được chấm đúng trên điểm này: có editor
miễn phí chạy Linux không, hay chỉ thay runtime?

## 1. Ứng viên đã tra cứu (19/11/2026)

Nguồn chính: `neta.art` (so sánh RPG Maker vs Godot vs Unity vs Phaser),
`soonlab.ai` (RPG Maker alternatives), `startupstash.com` (giá MZ $79,99,
EasyRPG 0.8.1.1), Godot docs chính thức, `ziva.sh` (Godot 4.7.2 web export,
chạy thật trên Linux 05/11/2026), EasyRPG community (06/2026), RPG Paper
Maker EULA 10/11/2026.

### 1.1 Godot 4 — MIT, editor miễn phí, Linux/Win/Mac/Web

- **License:** MIT, miễn phí hoàn toàn, không royalty, không phí theo ghế.
  Bản ổn định tra được: **4.7.2 (18/08/2026)**.
- **Editor trên Linux:** có, bản native Linux; chạy được cả trên VM này
  (headless CLI để build/test, không cần mở giao diện). Export templates
  ~1,2 GB tải 1 lần, đặt tại `~/.local/share/godot/export_templates/`.
- **2.5D isometric:** có sẵn, không cần plugin ngoài — `TileSet` đặt
  Tile Shape = **Isometric**, Tile Size 64×32 (tỉ lệ 2:1), `TileMapLayer`
  (Godot 4.3+, node `TileMap` cũ đã deprecated), Y-sort có sẵn
  (`y_sort_enabled` + `y_sort_origin` từng tile). Đây đúng là cái mà bản MV
  đang phải tự viết plugin `PXB_Isometric.js` để giả lập.
- **Web export:** có sẵn, preset **Web**, renderer **Compatibility**
  (WebGL 2.0). Từ Godot 4.3, export **single-threaded mặc định** — không
  cần header COOP/COEP mà GitHub Pages không gửi, nên chạy được trên Pages
  như file tĩnh. Lưu ý thật: file `index.wasm` ~39,5 MB (Godot 4.7.2),
  lớn hơn nhiều so với bản MV (toàn repo `src/nadia/www/` chỉ ~3,0 MB);
  lần tải đầu chậm hơn, cần màn hình loading rõ ràng. Test bằng
  `python3 -m http.server` như bản MV hiện tại.
- **Online:** có sẵn trong engine — `ENetMultiplayerPeer` (UDP, native),
  `WebSocketMultiplayerPeer` (bắt buộc cho web export, vì trình duyệt
  không mở được socket UDP thô), `WebRTCMultiplayerPeer`, cùng API
  `MultiplayerSpawner` / `MultiplayerSynchronizer` / `@rpc`. Server có
  thể là Godot headless dedicated server, hoặc giữ server .NET 8 đã có
  (`src/server/`, `EconomyLedger.cs`) và cho client Godot gọi qua
  WebSocket — không bắt buộc viết lại server.
- **Cộng đồng:** lớn nhất trong các ứng viên (hàng chục nghìn star,
  docs chính thức đầy đủ, forum/Discord sôi động, nhiều tutorial
  multiplayer + isometric). Không lo engine chết.
- **Điểm trừ duy nhất (nặng):** Godot **không có sẵn hệ RPG** như MV
  (database nhân vật/vật phẩm, event, quest, battle có sẵn). Toàn bộ 17
  plugin PXB + logic C# (`GameBalance.cs`, `Stats.cs`, `Jobs.cs`,
  `Economy.cs`, `Social.cs`…) phải viết lại bằng **GDScript**. Đây là
  chi phí chuyển đổi thật, không được giấu (xem §4). C# không dùng được
  cho web export (Godot ghi rõ C# chưa có trên web), nên bắt buộc
  GDScript cho bản web.

### 1.2 GDevelop — open-source (license hỗn hợp), no-code

- Editor miễn phí, chạy Windows/Mac/Linux **và cả trên trình duyệt**;
  logic bằng event-sheet trực quan, không cần code. Engine `GDJS`
  TypeScript, render PixiJS (2D) / Three.js (3D) trên WebGL; export
  HTML5/web 1 cú click, lên GitHub Pages dễ.
- **Loại vì:** không có tilemap isometric native — phải tự làm; 3D còn
  non; license repo là composite (GitHub báo NOASSERTION, không phải MIT
  sạch như Godot); một số dịch vụ tiện ích (iOS, cộng tác team) trả phí.
  Với game cần hệ kinh tế + công ty + xã hội phức tạp, event-sheet
  no-code sẽ rối nhanh hơn GDScript có cấu trúc. Cộng đồng nhỏ hơn Godot
  nhiều cho RPG sâu.

### 1.3 Phaser 3 — MIT, framework JS cho web

- Framework HTML5 nhanh, miễn phí, MIT; WebGL + fallback Canvas;
  hỗ trợ tilemap **orthogonal, isometric, hexagonal, staggered** từ
  Tiled (từ v3.50+); plugin `grid-engine` (Apache 2.0) cho di chuyển
  theo lưới + isometric; chạy ngon trên VM này bằng Node, deploy Pages
  như file tĩnh (đây là họ gần nhất với bản `src/web/` hiện tại).
- **Loại vì:** Phaser là **framework, không phải engine có editor** —
  không có editor vẽ map, không có database/event/quest sẵn. Map phải
  vẽ bằng **Tiled** (miễn phí, Linux, xem §5) rồi code tay toàn bộ hệ
  game. Tức là nó không giải quyết nút thắt "thiếu editor" — chỉ đổi
  từ "viết JSON MV tay" sang "viết JS Phaser tay". Không có multiplayer
  sẵn; phone hub/UI phải tự xây. Phù hợp làm slice web nhỏ, không phù
  hợp làm engine chính cho game 18 khu + online.

### 1.4 EasyRPG — GPLv3, nhưng KHÔNG hỗ trợ MV/MZ

- Player open-source chạy game RPG Maker 2000/2003 trên Windows, Linux,
  macOS, mobile, web (bản 0.8.1.1, 06/2025); Editor GPLv3 trên Qt 6
  nhưng **chưa có bản release ổn định, chỉ có daily CI build**.
- **Loại dứt khoát:** EasyRPG community xác nhận (06/2026) Player chỉ
  hỗ trợ 2000/2003, **không có kế hoạch hỗ trợ MV/MZ** vì engine MV/MZ
  là JavaScript web, khác hoàn toàn. Dùng EasyRPG nghĩa là quay về định
  dạng 2000/2003 từ 20 năm trước — mất toàn bộ code MV/JS hiện tại.
  Không phải đáp án.

### 1.5 RPG Paper Maker — source-available, KHÔNG phải open-source tự do

- Engine làm RPG 3D với sprite 2D, editor Windows/Mac/Linux; repo
  GitHub ~674 star, cập nhật 07/06/2026, bản 3.2.29 (12/11/2026).
- **Loại dứt khoát:** EULA 10/11/2026 ghi rõ bản miễn phí chỉ dùng
  **phi thương mại**; muốn bán/thương mại phải mua bản commercial.
  Giấy phép là "source available", không phải MIT/GPL — cộng đồng còn
  tranh cãi về việc EULA mâu thuẫn với GPL. Phong cách 3D-paper không
  phải 2.5D isometric đã chốt. Cộng đồng nhỏ (~674 star so với Godot
  hàng chục nghìn). Không giải quyết được gì mà Godot không làm tốt hơn.

### 1.6 Solarus / Open RPG Maker / OHRRPGCE / mkxp — loại

- **Solarus** (GPLv3, C++/Lua, có editor Linux): engine action-RPG kiểu
  Zelda top-down, không isometric, **không có web export** — muốn lên
  Pages phải port, cộng đồng nhỏ.
- **Open RPG Maker / OHRRPGCE / RPG Toolkit:** clone RPG Maker đời cũ,
  niche, không isometric, không web export, cộng đồng rất nhỏ, tài liệu
  thưa.
- **mkxp:** chỉ là runtime chạy game RPG Maker XP/VX, không có editor,
  không giải quyết nút thắt.

## 2. Bảng so sánh — chấm theo nhu cầu Phố Xô Bồ

Nhu cầu chốt: 12 mục GDD, đúng 18 khu, 2.5D isometric, online nhiều người,
phone làm hub chính, chạy được trên VM Linux này, deploy GitHub Pages
(`tinnt120899.github.io/pho-xo-bo/`), editor miễn phí.

| Tiêu chí | RPG Maker MV (hiện tại) | **Godot 4 ✓ CHỐT** | GDevelop | Phaser 3 + Tiled | EasyRPG | RPG Paper Maker |
|---|---|---|---|---|---|---|
| License | Editor trả phí ~$80; runtime MIT | **MIT, miễn phí** | Hỗn hợp, không sạch | MIT | GPLv3 | Source-available, free chỉ phi thương mại |
| Editor chạy Linux (VM này) | ✗ Không | **✓ Native + headless CLI** | ✓ (+ cả trên browser) | ✗ Không có editor | Editor chưa có release ổn định | ✓ |
| 2.5D isometric sẵn | ✗ Tự viết plugin | **✓ TileSet Isometric + Y-sort** | ✗ Tự làm | ✓ qua Tiled (nhưng code tay) | ✗ Top-down 2D | 3D-paper, không phải iso 2.5D |
| Export web → GitHub Pages | ✓ File tĩnh, nhẹ ~3 MB | **✓ Single-threaded, không cần COOP/COEP; wasm ~39,5 MB** | ✓ HTML5 dễ | ✓ File tĩnh, nhẹ | ✓ (chỉ game 2000/2003) | Không rõ |
| Online nhiều người | ✗ Tự viết plugin + server | **✓ ENet/WebSocket/WebRTC sẵn** | Qua extension | ✗ Tự viết | ✗ | ✗ |
| Hệ RPG sẵn (DB/event/quest) | ✓ Có sẵn | ✗ Phải viết lại bằng GDScript | Event-sheet no-code | ✗ Code tay hết | ✓ (nhưng đời 2000/2003) | ✓ (kiểu RPG Maker) |
| Phone hub / UI | Plugin tự viết | **✓ CanvasLayer + Control sẵn** | ✓ | Code tay | ✗ | Hạn chế |
| Cộng đồng / tuổi thọ | Lớn nhưng MV đã cũ (2020 MZ thay thế) | **Lớn nhất, đang phát triển** | Trung bình | Lớn (framework web) | Nhỏ | Rất nhỏ (~674★) |
| Chạy/test trên VM này | ✓ (node + http.server) | **✓ (headless export + test)** | ✓ | ✓ | ✓ | ✓ |
| Chi phí chuyển đổi | 0 (đang dùng) | **Cao: viết lại 17 plugin sang GDScript** | Trung bình-cao | Cao, lại không có editor | Rất cao + mất code MV | Cao + ràng buộc license |

**Đọc bảng:** chỉ Godot đạt đủ 3 điều kiện bắt buộc cùng lúc (editor Linux
miễn phí + isometric sẵn + online sẵn). Phaser thắng ở "nhẹ, dễ deploy"
nhưng thua ở "không có editor" — tức không giải quyết vấn đề chủ nêu.
EasyRPG và RPG Paper Maker thua ở license/phạm vi hỗ trợ, không phải vì
kém hay.

## 3. Đề xuất chốt: Godot 4.7.2 (MIT)

- **Engine:** Godot **4.7.2 stable** (bản mới nhất tra được 18/08/2026).
  Dùng GDScript (không dùng C#, vì C# chưa có trên web export).
- **Renderer web:** Compatibility (WebGL 2.0), export single-threaded.
- **Vị trí mới:** `src/godot/` trong repo — project Godot độc lập, song
  song với `src/nadia/` (MV) và `src/client/` + `src/server/` (Unity/.NET).
- **Nguyên tắc chuyển đổi:**
  1. **MV vẫn là bản chơi được chính** cho tới khi Godot đạt parity
     slice (2 khu + 3 nghề + phone hub + save). Không xóa `src/nadia/`,
     không dừng cron 24/24 trên MV.
  2. **Số liệu chốt là 1 nguồn duy nhất:** `src/client/Assets/Scripts/
     GameBalance.cs` (học vấn 5 bậc, lương, lãi 0,5%, phí đấu giá 5%,
     nhà 6 tầng…) + `docs/gdd.md` 12 mục — Godot port số từ đó, không
     tự bịa số mới. Mọi số PROVISIONAL trong code MV giữ nguyên nhãn
     PROVISIONAL khi port.
  3. **Art tái dùng:** atlas PNG Kenney CC0 + `docs/art-assets.md` +
     `docs/tileset-plan.md` — Godot TileSet ăn trực tiếp PNG atlas,
     không cần vẽ lại. Map 12×9 hiện tại port sang TileMapLayer.
  4. **Online Phase 2 giữ nguyên server .NET 8** (`EconomyLedger.cs`)
     hoặc Godot headless dedicated server — quyết sau khi slice Godot
     chạy, không quyết vội bây giờ.

## 4. Lộ trình chuyển từ MV sang Godot (5 giai đoạn)

| Giai đoạn | Việc | Xong khi |
|---|---|---|
| **G0 — Dựng khung (1 buổi)** | Cài Godot 4.7.2 Linux headless + export templates trên VM; tạo `src/godot/project.godot` (Compatibility renderer, viewport 9:16 720×1280, stretch canvas_items); `export_presets.cfg` preset Web single-threaded; scene `Main.tscn` trống chạy được + export `index.html` thử lên `gh-pages` nhánh test | `godot --headless --export-release Web` ra `index.html` + `index.wasm`, mở bằng `http.server` thấy màn hình Godot |
| **G1 — Slice parity (Map001–002)** | Port Map001 Xóm Trọ Cũ + Map002 Chợ Đầu Mối: TileSet isometric 64×32 từ atlas PNG hiện có, TileMapLayer 12×9 (port data từ `Map001.json`/`Map002.json` bằng script, không gõ tay); player di chuyển lưới WASD/chạm; NPC cô Tư/chị Lệ/anh Hải (dialogue); hotspot nhặt 1 lần/ngày đúng khung | Chơi được slice như bản MV hiện tại, kiểm tra bằng play-test trên trình duyệt |
| **G2 — Hệ lõi** | Port 17 plugin PXB → GDScript autoload theo thứ tự: `PXB_Balance` → `Stats` → `Time` (30 phút/ngày, 3 khung) → `Jobs` → `Inventory`/`Crafting` → `Economy` (lãi 0,5%, phí 5%, 4 hành vi cấm) → `Education` (5 bậc) → `Social` → `Titles`/`Story` (5 chương) → `PhoneHub` (CanvasLayer, 9 tab) → `MarketBattle` (luật chờ chủ duyệt) → `Online`/`SaveCloud` | Mỗi hệ có test GDScript chạy headless (`godot --headless --test` / Gut), số khớp `GameBalance.cs` |
| **G3 — Đủ 18 khu** | Port Map003–018 (Map003–009 đã có data MV, Map010–018 viết mới); đồ thị transfer nối như MV; NPC + hotspot + quest từng khu; Công Viên An Bình + Chợ Đêm mở theo điều kiện | Đồ thị 18 map thông nhau, kiểm tra tĩnh như `check_static.py` hiện tại |
| **G4 — Online + release** | WebSocket client ↔ server (giữ .NET 8 hoặc Godot dedicated server); save cloud; deploy `gh-pages` root = build Godot; tắt dần bản MV khi Godot parity 100% | Link `tinnt120899.github.io/pho-xo-bo/` chạy bản Godot, chơi được trên PC + mobile |

## 5. Phương án dự phòng — nếu không chuyển Godot

Nếu chủ không muốn trả chi phí viết lại (G2), phương án rẻ nhất mà vẫn
giải quyết "thiếu editor" một phần: **giữ MV runtime + dùng Tiled Map
Editor (miễn phí, BSD, Linux/Win/Mac) làm editor vẽ map thay cho MV
Editor** — Tiled hỗ trợ orthogonal/isometric/hexagonal, export TMX/JSON,
rồi viết script chuyển TMX → `MapNNN.json` của MV. Nhược điểm: Tiled chỉ
vẽ map, không có database/event/quest — các phần đó vẫn sửa JSON tay.
Đây là phương án "vá", không phải phương án "đổi engine"; chỉ dùng khi
chủ nói rõ không chuyển Godot.

## 6. Rủi ro khi chuyển Godot — nói thẳng

1. **Chi phí viết lại là thật:** 17 plugin PXB + logic C# phải viết lại
   GDScript; ước tính bằng nhiều đợt cron 24/24, không xong trong 1–2
   ngày. Trong thời gian đó MV vẫn phải chạy song song (gấp đôi việc).
2. **Wasm nặng:** bản web Godot ~39,5 MB + asset, tải lần đầu chậm hơn
   hẳn bản MV ~3 MB; người chơi mạng yếu sẽ thấy loading lâu — cần màn
   hình loading + nén + lazy-load theo khu.
3. **Isometric Y-sort có bẫy:** Godot forum ghi rõ Y-sort chỉ đúng khi
   bật ở cả parent lẫn TileMapLayer, và tile cao hơn 1 ô cần chỉnh
   `y_sort_origin` từng tile — phải test bằng pixel thật, không chỉ đọc
   docs.
4. **Không có sẵn hệ RPG:** quest/event/dialogue phải tự thiết kế
   (dùng Resource + JSON, port từ `CommonEvents.json` của MV).
5. **Godot 4.7 còn mới:** một số plugin cộng đồng chưa kịp cập nhật;
   chỉ dùng tính năng core, tránh plugin ngoài chưa kiểm chứng.

## 7. Nguồn tra cứu (19/11/2026)

- Godot Engine — MIT, bản 4.7.2 (18/08/2026), editor Linux/Win/Mac/Web,
  export Web: https://en.wikipedia.org/wiki/Godot_(game_engine)
- Godot docs — Using TileMaps / TileMapLayer (Y-sort, nhiều layer):
  https://docs.godotengine.org/en/stable/tutorials/2d/using_tilemaps.html
- Godot isometric setup (TileSet Isometric 64×32, Y-sort):
  https://spritefy.com/blog/isometric-pixel-art
- Godot 4 web export (single-threaded, Compatibility, wasm 39,5 MB,
  chạy thật trên Linux 05/11/2026): https://ziva.sh/blogs/godot-web-export
- Godot 4 multiplayer (ENet/WebSocket/WebRTC, `@rpc`, Spawner/
  Synchronizer): https://generalistprogrammer.com/tutorials/godot-4-multiplayer-tutorial
- RPG Maker alternatives (Godot/GDevelop/EasyRPG, giá MZ $79,99):
  https://www.soonlab.ai/blog/rpg-maker-alternatives/ —
  https://startupstash.com/alternatives/rpgmaker/
- EasyRPG: Player 0.8.1.1 chỉ hỗ trợ 2000/2003, không có kế hoạch MV/MZ:
  https://community.easyrpg.org/t/will-easyrpg-support-mz/1710
- RPG Paper Maker EULA 10/11/2026 (free chỉ phi thương mại):
  https://rpg-paper-maker.com/rpg-paper-maker-eula/
- Phaser 3 isometric tilemap + grid-engine (Apache 2.0):
  https://socket.dev/npm/package/grid-engine/overview/2.27.0
- Tiled Map Editor 1.11.2 (miễn phí, isometric, export Godot):
  https://copyprogramming.com/howto/tools-for-creating-2d-tile-based-maps

## 8. Quyết định cần chủ chốt

Chuyển sang Godot là quyết định kiến trúc lớn (đảo ngược quyết định đổi
sang MV ngày 18/11 22:30 của chủ). File này chỉ là đề xuất đã nghiên cứu
kỹ — **chưa chuyển code**. Cần chủ chốt 1 trong 2:

- **A. Chuyển Godot** — làm G0 ngay (dựng khung `src/godot/`), MV chạy
  song song tới khi Godot parity.
- **B. Giữ MV + Tiled vá editor** — không chuyển engine, chỉ thêm Tiled
  làm editor vẽ map (§5).
