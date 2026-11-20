# Godot G3 — Đủ 18 khu (bước 1: Map003–005, 20/11/2026)

> **Kết luận: G3 bước 1 XONG (mức headless).** Map003 Khu Công Nhân +
> Map004 Bến Xe Miền Đông + Map005 Làng Đại Học đã port sang Godot từ
> dữ liệu MV, chuỗi 1→2→3→4→5 thông 2 chiều, NPC đối thoại được, cửa
> đi khu chưa port bị chặn có báo (không crash). G1 selftest **122/122
> PASS** (mới: đồ thị cửa, số event từng map, atlas PNG tồn tại),
> playtest mới **25/25 PASS**, G1 playtest **14/14 PASS**, toàn bộ test
> G2 cũ vẫn PASS (không regression), scene 120 frame exit 0, export web
> exit 0 (~8s, pck 1.177.624 byte chứa data 3 map mới), http.server 200
> đủ 6 file. **Chưa kiểm chứng bằng trình duyệt thật** — như G0/G1/G2,
> VM không có Chromium/Firefox. Còn lại G3: Map006–014 (đã có data MV)
> + Map015–018 (viết mới).

> **Cập nhật bước 4 (20/11 ~08:00): G3 bước 4 XONG (mức headless).**
> Map012 Khu Biệt Thự Ven Sông + Map013 Quận Tài Chính + Map014 Đảo
> Thượng Lưu đã port sang Godot từ dữ liệu MV — HẾT data MV (Map015–018
> viết mới ở bước sau). Chuỗi 1→2→…→14 thông 2 chiều, NPC đối thoại được,
> Map014 là map cuối MV (chỉ 1 cửa về, không có cửa đi tiếp). G1 selftest
> **327/327 PASS**, G3 playtest mở rộng **74/74 PASS**, toàn bộ test G2
> cũ vẫn PASS (không regression), scene 120 frame exit 0, export web
> exit 0 (~8s, pck 1.269.244 byte), http.server 200 đủ 6 file (cổng
> 8152). **Chưa kiểm chứng bằng trình duyệt thật.** Còn lại G3:
> Map015–018 (viết mới theo `docs/districts.md`).

> **Cập nhật bước 5 (20/11 ~08:45): G3 XONG — ĐỦ 18 KHU (mức headless).**
> Map015 Khu Penthouse + Map016 Khu Sân Golf & Resort + Map017 Công Viên
> An Bình + Map018 Phố Đi Bộ – Chợ Đêm đã VIẾT MỚI (hết data MV) theo
> `docs/districts.md` — chuỗi 1→2→…→18 thông 2 chiều, NPC đối thoại được,
> Map018 là map cuối chuỗi (chỉ 1 cửa về). G1 selftest **419/419 PASS**,
> G3 playtest mở rộng **95/95 PASS**, toàn bộ test G2 cũ vẫn PASS (không
> regression), scene 120 frame exit 0, export web exit 0 (~6s, pck
> 1.288.892 byte), http.server 200 đủ 6 file (cổng 8153). **Chưa kiểm
> chứng bằng trình duyệt thật.** Còn lại G3: KHÔNG — chuyển sang G4
> (online + release) hoặc scene trận MarketBattle (UI).

## 1. Port dữ liệu — `tools/godot/convert_maps.py` mở rộng

| Nguồn MV (không sửa) | Đích Godot |
|---|---|
| `Map003/004/005.json` (12×9, data 648, L0 108 ô + L1 28 ô) | `layers[0]` + `layers[1]` trong `maps.json` |
| `atlas-map003/004/005.json` (trường `atlasPng`) | `atlas_png`: Map003/Map005 **tái dùng** `atlas-map001.png`, Map004 tái dùng `atlas-map002.png` — converter nay lấy tên PNG từ `atlasPng`, không đoán theo số map |
| Event NPC (Show Text code 401) | `greet` **nguyên văn** MV (bỏ dấu cách đầu thừa) |
| Event cửa (TRANSFER code 201) | `to_map` đọc từ lệnh TRANSFER, không hardcode dict nữa |
| `districts.md` / GDD (ca kíp, bến xe, bậc học, khóa ngắn hạn) | `hint` NPC mới — **do port viết mới** (MV không có hint cho 6 NPC này) |

NPC mới (2/map, đúng vị trí + lời thoại MV):

| Map | NPC (ô) | Greet (nguyên văn MV) | Hint (port viết) |
|---|---|---|---|
| 003 Khu Công Nhân | Anh Ba (4,6), Chị Sáu (8,3) | Ca xưởng theo tổ / sáng đông, tan ca ra chợ | Đổi nghề qua bến xe; giữ sức, để lá chuối cho chị Lệ |
| 004 Bến Xe Miền Đông | Bác Tài (3,2), Anh Bốc Vác (8,6) | Vé theo chặng, shipper đông khách / bốc vác trả theo chuyến | Tuyến bến đông đơn; việc nhiều lúc xe về bến |
| 005 Làng Đại Học | Thầy Giáo (3,3), Sinh Viên Làm Thêm (8,6) | Ngưỡng Trí 5 bậc (20/40/60/75/90) + học phí / khóa ngắn 3–7 ngày, 2–10tr, +10 chỉ số phụ | Mở điện thoại mục Học tập đăng ký đúng bậc; khóa ngắn mở nghề phụ |

Map003–005 **không có** hotspot / Góc Chế Tạo trong MV nên không có
trong port (đúng nguồn, không bịa thêm).

## 2. Lệch khỏi MV — 2 chỗ, đều có lý do ghi rõ

1. **Cửa thêm trên Map002 (5,8) "Cửa đi Khu Công Nhân" → Map003.**
   MV Map002 chỉ có 1 event cửa (về Map001); không có đường nào đi
   Map003, nên đồ thị MV chỉ nối 1 chiều (Map003 có cửa về Map002
   nhưng không có đường ngược lại). Port thêm cửa này để chuỗi
   1-2-3-4-5 thông 2 chiều (đúng yêu cầu G3 "đồ thị 18 map thông
   nhau"). Ô (5,8) trên Map002 trống (lớp 1 = 0, không event).
   Ghi trong converter: `ADDED_DOORS`.
2. **Cửa cuối Map005 (5,8) đi Map006 chưa port → bị chặn có báo.**
   `main.gd` `_transfer()` nay kiểm tra đích có trong `maps.json`
   không; chưa có thì toast "Khu này chưa mở trong bản Godot — đang
   làm (G3)." và người chơi đứng yên ở cửa (không crash, không load
   map rỗng). Nút đi nhanh (điện thoại → Bản đồ) đã chặn sẵn trường
   hợp này từ G2 (chỉ liệt kê map có trong `maps_data`).

## 3. Lỗi tìm được khi port — spawn lấy cửa CUỐI thay vì cửa ĐẦU

`_transfer()` và nút đi nhanh trong `main.gd` đều dùng vòng lặp
`for e in dest["events"]: if door: door_tile = ...` **không break**,
nên điểm spawn là cửa CUỐI trong danh sách, không phải cửa VỀ (5,4).
G1/G2 không lộ lỗi vì mỗi map chỉ có 1 cửa. Khi Map002 có thêm cửa
(5,8), playtest fail 6/25 mục "spawn o cua (5,4)" — người chơi spawn
ở (5,8) thay vì (5,4). Sửa: `break` sau cửa đầu tiên ở cả 2 chỗ
(xem `main.gd`). Sau sửa: G1 playtest 14/14, G3 playtest 25/25.
Bài học: vòng lặp tìm "cái đầu tiên" phải break — lỗi này từng có
dạng tương tự ở `PxbOnline.flush_outbox` (đã sửa ở G2 §2s).

## 4. File mới / đổi đợt này

| File | Nội dung |
|---|---|
| `tools/godot/convert_maps.py` (sửa) | `MAP_IDS = [1..5]`; `atlas_png` từ `atlas["atlasPng"]`; `to_map` từ lệnh TRANSFER code 201; `NPC_TEXT` thêm 6 NPC Map003–005; `ADDED_DOORS` (cửa Map002→Map003); `CRAFT` chỉ Map001–002 (Map003–005 không có event chế tạo) |
| `src/godot/data/maps.json` (tạo lại) | 5 map: Map001 5 event, Map002 7 event (thêm cửa), Map003–005 mỗi map 4 event (2 NPC + 2 cửa) |
| `src/godot/main.gd` (sửa) | `_transfer()`: chặn đích chưa có data (toast, không crash) + `break` lấy cửa đầu làm spawn; nút đi nhanh cũng `break` |
| `src/godot/tests/g1_selftest.gd` (sửa) | Kỳ vọng 5 map; bảng số event từng map; NPC nào cũng có greet+hint (>10 ký tự); atlas PNG tồn tại; đồ thị cửa BFS từ Map001 tới đủ 5 map; mỗi cửa có cửa ngược (trừ cửa cuối Map005→Map006 chưa port) |
| `src/godot/tests/g3_playtest.gd` (mới) | Chạy scene Main thật headless, đi chuỗi 1→2→3→4→5 qua cửa (5,8), nói chuyện Anh Ba / Bác Tài / Thầy Giáo, thử cửa Map005→Map006 bị chặn (vẫn ở Map005, vẫn ở ô (5,8)), đi ngược về Map001 qua các cửa (5,4) |

## 5. Verify thật đợt này (20/11 ~05:00)

| Kiểm tra | Kết quả |
|---|---|
| Converter chạy lại | Map001–005: L0=108, L1=28, event đúng số lượng từng map |
| `--check-only` main.gd + 2 test | PASS, exit 0 (1 lỗi sửa trước khi chạy: `var want := {...}[mid]` không suy được kiểu — đổi sang `var want: Dictionary`) |
| G1 selftest | **122/122 PASS** (từ 42/42: thêm ~80 mục cho 3 map mới + đồ thị) |
| G3 playtest mới | **25/25 PASS** (lần đầu 19/25: 6 mục spawn sai do lỗi cửa cuối §3 — sửa `main.gd`, chạy lại PASS hết) |
| G1 playtest | **14/14 PASS** (không regression) |
| G2 selftest cũ (Balance/Stats/Time) | **87/87 PASS** |
| G2 Jobs / Hotspot / Inventory+Crafting / Economy+Education / Social+Titles+Story / PhoneHub / Tools / Online / SaveCloud / UI wiring 1+2 | **56/56 + 37/37 + 78/78 + 92/92 + 102/102 + 66/66 + 155/155 + 91/91 + 69/69 + 37/37 + 71/71 PASS** (không regression) |
| Scene Main chạy 120 frame | exit 0, không ERROR/warning |
| Export web | exit 0, ~8s; `index.wasm` 39,5 MB, `index.pck` 1.177.624 byte (`grep -a` thấy "Khu Công Nhân" ×2, "Bến Xe Miền Đông" ×3, "Làng Đại Học" ×2, "Cửa đi Khu Công Nhân" ×1 trong pck) |
| HTTP 200 | `index.html/js/wasm/pck/audio.worklet.js/png` đủ 6 file (cổng 8149); `GODOT_THREADS_ENABLED = false` |

## 6. Bước tiếp theo — G3 bước 5: Map015–018 viết mới (xem §9)

1. Browser-verify G3 bước 1–4 (mở build web, đi chuỗi 1→14, xem tile
   atlas tái dùng có vẽ đúng không — Map003/005/006/007/008/009/010/
   011/012/013/014 dùng tile nhà trọ làm xưởng/giảng đường/chung cư/văn
   phòng/cửa hàng/văn phòng công nghệ/phố dịch vụ/biệt thự/ngân hàng/đảo
   là PROVISIONAL, chờ art pass vẽ tile riêng).
2. Port Map015–018 (viết mới theo `docs/districts.md` — Phố Đi Bộ –
   Chợ Đêm, Công Viên An Bình, + 2 khu tầng 5): converter cần nhánh
   tạo map từ data viết tay (không có Map JSON MV), NPC/hint theo GDD,
   cửa Map014→Map015 là cửa MỚI (không có trong MV).
3. Sau Map015–018: G3 xong — đồ thị 18 map thông nhau; chuyển sang G4
   (online + release) hoặc scene trận MarketBattle (UI): vẽ lưới
   isometric qua iso_map.gd.
4. Export web: Godot giải đường dẫn export tương đối theo project dir
   (`src/godot`), không theo CWD — lần này export lần đầu fail vì thư
   mục `godot-build` chưa tồn tại; tạo thư mục + dùng đường dẫn tuyệt
   đối thì exit 0. Ghi nhớ cho lần sau.

## 7. G3 bước 2 — Map006–008 (20/11 ~06:00)

### 7.1 Port dữ liệu — `tools/godot/convert_maps.py` mở rộng

| Nguồn MV (không sửa) | Đích Godot |
|---|---|
| `Map006/007/008.json` (12×9, data 648, L0 108 ô + L1 28 ô) | `layers[0]` + `layers[1]` trong `maps.json` |
| `atlas-map006/007/008.json` (trường `atlasPng`) | `atlas_png`: cả 3 map **tái dùng** `atlas-map001.png` — không cần copy PNG mới (đã có trong `src/godot/tiles/`) |
| Event NPC (Show Text code 401, nhiều dòng nối bằng dấu cách) | `greet` **nguyên văn** MV |
| Event cửa (TRANSFER code 201) | `to_map` đọc từ lệnh TRANSFER; `transfer_target()` nay cho phép đích tới Map009 (`MAP_IDS + [9]`) |
| `districts.md` / GDD (nhà tầng 2/3, việc văn phòng, Chương 3 kiểm tra rank) | `hint` NPC mới — **do port viết mới** (MV không có hint cho 6 NPC này) |

NPC mới (2/map, đúng vị trí + lời thoại MV):

| Map | NPC (ô) | Greet (nguyên văn MV) | Hint (port viết) |
|---|---|---|---|
| 006 Chung Cư Cũ | Cư Dân Chung Cư (3,6), Bác Quản Lý (8,3) | Nhà tầng 2, chi phí vừa / giữ nhà cửa gọn gàng, hàng xóm quý nhau | Muốn lên tầng 3 thì qua Chương 3 kiểm tra rank |
| 007 Phố Văn Phòng Nhỏ | Nhân Viên Văn Phòng (3,3), Thực Tập Sinh (8,6) | Việc văn phòng cấp thấp, cần Trí 40 hoặc Cao đẳng, Danh vọng 200 / thực tập xong mới xin được việc | Đúng ngưỡng mở Chương 2; mở điện thoại mục Việc làm xem nghề đang tuyển |
| 008 Khu Chung Cư Cao Cấp | Cư Dân Cao Cấp (3,3), Bảo Vệ Chung Cư (8,6) | Nhà tầng 3, phải qua Chương 3 — bài kiểm tra rank / chỉ mở khi qua kiểm tra rank | Qua rồi thì đi nhanh bằng điện thoại mục Bản đồ; chưa qua thì học lên bậc, tích Danh vọng rồi quay lại |

Map006–008 **không có** hotspot / Góc Chế Tạo trong MV nên không có
trong port (đúng nguồn, không bịa thêm).

### 7.2 Khác bước 1 — đồ thị MV đã thông 2 chiều sẵn

Khác bước 1 (MV Map002 thiếu cửa đi Map003 nên phải thêm cửa
`ADDED_DOORS`): chuỗi 5→6→7→8 trong MV đã có đủ cửa về (5,4) + cửa
đi (5,8) ở mỗi map, nên bước 2 **không thêm cửa nào** — converter
chỉ mở rộng `MAP_IDS` sang 1–8 + thêm `NPC_TEXT` 6 NPC. Cửa cuối
Map008→Map009 chưa port thì bị chặn có báo bằng đúng cơ chế `_transfer()`
đã có từ bước 1 (toast "Khu này chưa mở trong bản Godot — đang làm (G3).").

### 7.3 File mới / đổi đợt này

| File | Nội dung |
|---|---|
| `tools/godot/convert_maps.py` (sửa) | `MAP_IDS = [1..8]`; `transfer_target` cho phép đích Map009; `NPC_TEXT` thêm 6 NPC Map006–008 |
| `src/godot/data/maps.json` (tạo lại) | 8 map: Map001 5 event, Map002 7 event, Map003–008 mỗi map 4 event (2 NPC + 2 cửa) |
| `src/godot/tests/g1_selftest.gd` (sửa) | Kỳ vọng 8 map; bảng số event từng map (6–8 như 3–5); đồ thị cửa BFS từ Map001 tới đủ 8 map; mỗi cửa có cửa ngược (trừ cửa cuối Map008→Map009 chưa port); cửa hợp lệ 1..9 |
| `src/godot/tests/g3_playtest.gd` (sửa) | Chuỗi mở rộng 1→2→…→8 qua cửa (5,8), nói chuyện Cư Dân Chung Cư / Nhân Viên Văn Phòng / Cư Dân Cao Cấp, thử cửa Map008→Map009 bị chặn (vẫn ở Map008, vẫn ở ô (5,8)), đi ngược về Map001 qua các cửa (5,4) |

### 7.4 Verify thật đợt này (20/11 ~06:00)

| Kiểm tra | Kết quả |
|---|---|
| Converter chạy lại | Map001–008: L0=108, L1=28, event đúng số lượng từng map |
| `--check-only` 2 test mới | PASS, exit 0 |
| G1 selftest | **191/191 PASS** (từ 122/122: thêm ~69 mục cho 3 map mới + đồ thị) |
| G3 playtest mở rộng | **41/41 PASS** (chạy đầu đã pass hết — không lộ lỗi spawn như bước 1, vì `break` lấy cửa đầu đã sửa ở bước 1) |
| G1 playtest | **14/14 PASS** (không regression) |
| G2 selftest cũ (Balance/Stats/Time) | **87/87 PASS** |
| G2 Jobs / Hotspot / Inventory+Crafting / Economy+Education / Social+Titles+Story / PhoneHub / Tools / Online / SaveCloud / UI wiring 1+2 | **56/56 + 37/37 + 78/78 + 92/92 + 102/102 + 66/66 + 155/155 + 91/91 + 69/69 + 37/37 + 71/71 PASS** (không regression) |
| Scene Main chạy 120 frame | exit 0, không ERROR/warning |
| Export web | exit 0, ~10s; `index.wasm` 39,5 MB, `index.pck` 1.193.464 byte (`grep -a` thấy "Khu Chung Cư Cao Cấp", "Phố Văn Phòng Nhỏ" trong pck) |
| HTTP 200 | `index.html/js/wasm/pck/audio.worklet.js/png` đủ 6 file (cổng 8150); `GODOT_THREADS_ENABLED = false` |

## 8. G3 bước 3 — Map009–011 (20/11 ~06:50)

### 8.1 Port dữ liệu — `tools/godot/convert_maps.py` mở rộng

| Nguồn MV (không sửa) | Đích Godot |
|---|---|
| `Map009/010/011.json` (12×9, data 648, L0 108 ô + L1 28 ô) | `layers[0]` + `layers[1]` trong `maps.json` |
| `atlas-map009/010/011.json` (trường `atlasPng`) | `atlas_png`: cả 3 map **tái dùng** `atlas-map001.png` — không cần copy PNG mới (đã có trong `src/godot/tiles/`) |
| Event NPC (Show Text code 401, nhiều dòng nối bằng dấu cách) | `greet` **nguyên văn** MV |
| Event cửa (TRANSFER code 201) | `to_map` đọc từ lệnh TRANSFER; `transfer_target()` nay cho phép đích tới Map012 (`MAP_IDS + [12]`) |
| `districts.md` / GDD (cửa hàng mở theo Chương 3 kiểm tra rank, việc công nghệ cần Trí cao, dịch vụ cao cấp cần Chương 4: 3 quest giúp người + 1 quan hệ thân thiết) | `hint` NPC mới — **do port viết mới** (MV không có hint cho 6 NPC này) |

NPC mới (2/map, đúng vị trí + lời thoại MV):

| Map | NPC (ô) | Greet (nguyên văn MV) | Hint (port viết) |
|---|---|---|---|
| 009 Phố Thương Mại | Chủ Cửa Hàng (3,3), Người Bán Hàng (8,6) | Buôn bán quy mô vừa, toàn cửa hàng / cửa hàng chỉ mở khi qua Chương 3 kiểm tra rank | Mở cửa hàng cần qua Chương 3; vốn ít thì bắt đầu từ sạp chợ, tích Danh vọng rồi quay lại |
| 010 Khu Công Nghệ | Lập Trình Viên (3,3), Kỹ Sư Phần Mềm (8,6) | Việc công nghệ yêu cầu Trí cao / chỉ mở khi qua Chương 3 kiểm tra rank | Việc công nghệ cần Trí cao — học lên bậc, qua Chương 3 kiểm tra rank rồi quay lại |
| 011 Phố Tây | Nhân Viên Lễ Tân (3,3), Hướng Dẫn Viên (8,6) | Dịch vụ cao cấp cần ngoại ngữ + giao tiếp / chỉ mở khi xong 3 quest giúp người ở Chương 4 | Xong 3 quest giúp người ở Chương 4 + 1 quan hệ thân thiết thì khu này mới mở |

Map009–011 **không có** hotspot / Góc Chế Tạo trong MV nên không có
trong port (đúng nguồn, không bịa thêm).

### 8.2 Khác bước 1 — đồ thị MV đã thông 2 chiều sẵn

Như bước 2 (không như bước 1 phải thêm cửa `ADDED_DOORS`): chuỗi
8→9→10→11 trong MV đã có đủ cửa về (5,4) + cửa đi (5,8) ở mỗi map,
nên bước 3 **không thêm cửa nào** — converter chỉ mở rộng `MAP_IDS`
sang 1–11 + thêm `NPC_TEXT` 6 NPC. Cửa cuối Map011→Map012 chưa port
thì bị chặn có báo bằng đúng cơ chế `_transfer()` đã có từ bước 1
(toast "Khu này chưa mở trong bản Godot — đang làm (G3).").

**Ghi chú kiểm chứng:** `opensource-engine.md` §G3 ghi "Map003–009 đã
có data MV, Map010–018 viết mới" là **sai** — thực tế MV có đủ
Map001–014 (`src/nadia/www/data/Map012.json` tồn tại). Bước 3 port
Map010–011 trực tiếp từ data MV, không viết mới. Cần sửa dòng đó ở
`opensource-engine.md` khi chạm tới file (bước 4).

### 8.3 File mới / đổi đợt này

| File | Nội dung |
|---|---|
| `tools/godot/convert_maps.py` (sửa) | `MAP_IDS = [1..11]`; `transfer_target` cho phép đích Map012; `NPC_TEXT` thêm 6 NPC Map009–011 |
| `src/godot/data/maps.json` (tạo lại) | 11 map: Map001 5 event, Map002 7 event, Map003–011 mỗi map 4 event (2 NPC + 2 cửa) |
| `src/godot/tests/g1_selftest.gd` (sửa) | Kỳ vọng 11 map; bảng số event từng map (9–11 như 3–8); đồ thị cửa BFS từ Map001 tới đủ 11 map; mỗi cửa có cửa ngược (trừ cửa cuối Map011→Map012 chưa port); cửa hợp lệ 1..12 |
| `src/godot/tests/g3_playtest.gd` (sửa) | Chuỗi mở rộng 1→2→…→11 qua cửa (5,8), nói chuyện Chủ Cửa Hàng / Lập Trình Viên / Nhân Viên Lễ Tân, thử cửa Map011→Map012 bị chặn (vẫn ở Map011, vẫn ở ô (5,8)), đi ngược về Map001 qua các cửa (5,4) |

### 8.4 Verify thật đợt này (20/11 ~06:50)

| Kiểm tra | Kết quả |
|---|---|
| Converter chạy lại | Map001–011: L0=108, L1=28, event đúng số lượng từng map |
| `--check-only` 2 test mới | PASS, exit 0 |
| G1 selftest | **260/260 PASS** (từ 191/191: thêm ~69 mục cho 3 map mới + đồ thị) |
| G3 playtest mở rộng | **57/57 PASS** (chạy đầu đã pass hết — không lộ lỗi spawn, vì `break` lấy cửa đầu đã sửa ở bước 1) |
| G1 playtest | **14/14 PASS** (không regression) |
| G2 selftest cũ (Balance/Stats/Time) | **87/87 PASS** |
| G2 Jobs / Hotspot / Inventory+Crafting / Economy+Education / Social+Titles+Story / PhoneHub / Tools / Online / SaveCloud / UI wiring 1+2 | **56/56 + 37/37 + 78/78 + 92/92 + 102/102 + 66/66 + 155/155 + 91/91 + 69/69 + 37/37 + 71/71 PASS** (không regression) |
| Scene Main chạy 120 frame | exit 0, không ERROR/warning |
| Export web | exit 0, ~10s; `index.wasm` 39,5 MB, `index.pck` 1.252.156 byte (`grep -a` thấy "Phố Thương Mại" ×3, "Khu Công Nghệ" ×3, "Phố Tây" ×2, "Chủ Cửa Hàng"/"Lập Trình Viên"/"Nhân Viên Lễ Tân" ×1 trong pck) |
| HTTP 200 | `index.html/js/wasm/pck/audio.worklet.js/png` đủ 6 file (cổng 8151); `GODOT_THREADS_ENABLED = false` |

## 9. G3 bước 4 — Map012–014 (20/11 ~08:00, HẾT data MV)

### 9.1 Port dữ liệu — `tools/godot/convert_maps.py` mở rộng

| Nguồn MV (không sửa) | Đích Godot |
|---|---|
| `Map012/013/014.json` (12×9, data 648, L0 108 ô + L1 28 ô) | `layers[0]` + `layers[1]` trong `maps.json` |
| MV **không có** `atlas-map012/013/014.json` (chỉ có 001/002) | `_atlas_for()` mới: fallback tái dùng `atlas-map001.json` (tiles) + `atlas-map001.png`; tên map lấy từ `MapInfos.json` (Khu Biệt Thự Ven Sông / Quận Tài Chính / Đảo Thượng Lưu) |
| Event NPC (Show Text code 401, nhiều dòng nối bằng dấu cách) | `greet` **nguyên văn** MV |
| Event cửa (TRANSFER code 201) | `to_map` đọc từ lệnh TRANSFER; `transfer_target()` nay cho phép đích tới Map015 (`MAP_IDS + [15]`) |
| `districts.md` / GDD (nhà tầng 4 mở theo Chương 4, Quận Tài Chính mở theo Chương 4, Đảo Thượng Lưu mở theo Chương 5 nhánh Siêu giàu: tài sản ≥ 100 tỉ) | `hint` NPC mới — **do port viết mới** (MV không có hint cho 6 NPC này) |

NPC mới (2/map, đúng vị trí + lời thoại MV):

| Map | NPC (ô) | Greet (nguyên văn MV) | Hint (port viết) |
|---|---|---|---|
| 012 Khu Biệt Thự Ven Sông | Bảo Vệ Biệt Thự (3,3), Người Làm Vườn (8,6) | Nhà tầng 4, chỉ mở khi xong Chương 4: 3 quest giúp người + 1 quan hệ thân thiết / biệt thự ven sông yên tĩnh, nhà tầng 4 | Nhà tầng 4 chỉ mở khi xong Chương 4; xong rồi đi nhanh bằng điện thoại mục Bản đồ |
| 013 Quận Tài Chính | Nhân Viên Ngân Hàng (3,3), Môi Giới Chứng Khoán (8,6) | Ngân hàng, chứng khoán mô phỏng, công ty lớn — chỉ mở khi xong Chương 4 | Việc ở đây cần xong Chương 4; mở điện thoại mục Việc làm xem nghề đang tuyển |
| 014 Đảo Thượng Lưu | Quản Gia Đảo (3,3), Chủ Biệt Thự Đảo (8,6) | Chỉ mở khi tài sản ≥ ngưỡng siêu giàu — Chương 5 nhánh Siêu giàu: tài sản ≥ 100 tỉ | Chưa đủ 100 tỉ thì tích lũy, mở cửa hàng, đầu tư rồi quay lại |

Map012–014 **không có** hotspot / Góc Chế Tạo trong MV nên không có
trong port (đúng nguồn, không bịa thêm).

### 9.2 Khác bước 1–3 — hết data MV, hết cửa bị chặn

Như bước 2–3 (không như bước 1 phải thêm cửa `ADDED_DOORS`): chuỗi
11→12→13→14 trong MV đã có đủ cửa về (5,4) + cửa đi (5,8) ở mỗi map,
nên bước 4 **không thêm cửa nào** — converter chỉ mở rộng `MAP_IDS`
sang 1–14 + thêm `NPC_TEXT` 6 NPC + `_atlas_for()` fallback.
Map014 là map cuối MV: chỉ có 1 cửa (về Map013), **không có cửa đi
tiếp** nên không còn trường hợp cửa bị chặn ở cuối chuỗi — cơ chế
`_transfer()` chặn đích chưa có data vẫn giữ nguyên cho Map015+
(bước sau). Sửa luôn dòng sai trong `opensource-engine.md` §4
("Map003–009 đã có data MV, Map010–018 viết mới" → "Map003–014 đã
có data MV, Map015–018 viết mới") — đã ghi chú từ §8.2.

### 9.3 Lỗi tìm được khi port — kỳ vọng test sai, không phải game sai

Playtest lần đầu 73/74: mục "player van o (5,7)" FAIL — bước xuống
(5,8) ở Map014 không bị chặn. Nguyên nhân: `is_walkable()` = trong
biên + lớp 1 trống + không NPC; ô (5,8) ở Map014 (cũng như mọi map)
có L1 = 0 (hàng y=8 của L1 chỉ có vật ở 2 góc), nên là ô đi được
bình thường — chỉ khác là không có event cửa nên không chuyển map.
Sửa test (không sửa game): bước xuống (5,8) thì player ở (5,8) và
vẫn ở Map014. Chạy lại: G3 playtest **74/74 PASS**.

### 9.4 File mới / đổi đợt này

| File | Nội dung |
|---|---|
| `tools/godot/convert_maps.py` (sửa) | `MAP_IDS = [1..14]`; `transfer_target` cho phép đích Map015; `_atlas_for()` fallback atlas-map001 + tên từ MapInfos.json; `NPC_TEXT` thêm 6 NPC Map012–014 |
| `src/godot/data/maps.json` (tạo lại) | 14 map: Map001 5 event, Map002 7 event, Map003–013 mỗi map 4 event (2 NPC + 2 cửa), Map014 3 event (2 NPC + 1 cửa) |
| `src/godot/tests/g1_selftest.gd` (sửa) | Kỳ vọng 14 map; bảng số event từng map (12–13 như 3–11, 14: door=1); đồ thị cửa BFS từ Map001 tới đủ 14 map; mỗi cửa có cửa ngược (không còn ngoại lệ cửa cuối); cửa hợp lệ 1..14 |
| `src/godot/tests/g3_playtest.gd` (sửa) | Chuỗi mở rộng 1→2→…→14 qua cửa (5,8), nói chuyện Bảo Vệ Biệt Thự / Nhân Viên Ngân Hàng / Quản Gia Đảo, kiểm tra Map014 không có cửa đi tiếp (o (5,8) không event, bước xuống vẫn ở Map014), đi ngược về Map001 qua các cửa (5,4) |
| `docs/opensource-engine.md` (sửa) | §4: "Map003–014 đã có data MV, Map015–018 viết mới" (sửa dòng sai đã ghi chú từ §8.2) |
| `.gitignore` (sửa) | Thêm `godot-build/` (build web local, binary, không push) |

### 9.5 Verify thật đợt này (20/11 ~08:00)

| Kiểm tra | Kết quả |
|---|---|
| Converter chạy lại | Map001–014: L0=108, L1=28, event đúng số lượng từng map |
| `--check-only` 2 test mới | PASS, exit 0 |
| G1 selftest | **327/327 PASS** (từ 260/260: thêm ~67 mục cho 3 map mới + đồ thị) |
| G3 playtest mở rộng | **74/74 PASS** (lần đầu 73/74: 1 mục kỳ vọng sai về ô (5,8) Map014 — sửa test §9.3, chạy lại PASS hết) |
| G1 playtest | **14/14 PASS** (không regression) |
| G2 selftest cũ (Balance/Stats/Time) | **87/87 PASS** |
| G2 Jobs / Hotspot / Inventory+Crafting / Economy+Education / Social+Titles+Story / PhoneHub / Tools / Online / SaveCloud / UI wiring 1+2 / MarketBattle | **56/56 + 37/37 + 78/78 + 92/92 + 102/102 + 66/66 + 155/155 + 91/91 + 69/69 + 37/37 + 71/71 + 123/123 PASS** (không regression) |
| Scene Main chạy 120 frame | exit 0, không ERROR/warning |
| Export web | Lần đầu FAIL ("Target folder does not exist": `godot-build` chưa có; Godot giải path export tương đối theo project dir, không theo CWD) — tạo thư mục + dùng đường dẫn tuyệt đối thì exit 0, ~8s; `index.wasm` 39,5 MB, `index.pck` 1.269.244 byte (`grep -a` thấy "Khu Biệt Thự Ven Sông" ×3, "Quận Tài Chính" ×6, "Đảo Thượng Lưu" ×4, "Bảo Vệ Biệt Thự"/"Nhân Viên Ngân Hàng"/"Quản Gia Đảo" ×1 trong pck) |
| HTTP 200 | `index.html/js/wasm/pck/audio.worklet.js/png` đủ 6 file (cổng 8152); `GODOT_THREADS_ENABLED = false` (trong `index.html:115`) |

## 10. G3 bước 5 — Map015–018 viết mới (20/11 ~08:45, G3 XONG — ĐỦ 18 KHU)

### 10.1 Viết mới dữ liệu — `tools/godot/convert_maps.py` thêm `handwritten()`

| Nguồn (viết mới, không có trong MV) | Đích Godot |
|---|---|
| `docs/districts.md` (tên + tầng + mở khóa: 15/16 tầng 5, 17/18 khu chung luôn mở) + GDD Chương 5 (nhánh Giám đốc / Học giả / Gia đình / Siêu giàu), sự kiện Chợ Đêm 20:00 thứ 7, Bụi Đời Chợ Cá | `maps.json` Map015–018 (12×9, L0 108 ô + L1 28 ô) |
| Lớp tile mẫu Map014 (nền 1/2 + vật 3/4/5 vòng biên, atlas-map001) | `layers[0]` + `layers[1]` — L0 biến đổi nhẹ theo map (đổi 1↔2 ở ô `(x + 2*y + map_id) % 7 == 0`); L1 giữ nguyên mẫu |
| NPC 2/map ở (3,3) + (8,6) như các map 3–14 | `greet` + `hint` **do port viết mới** theo districts.md/GDD (MV không có) |
| Cửa về (5,4) + cửa đi (5,8); Map018 chỉ cửa về | `to_map` viết tay trong `HANDWRITTEN` (không qua TRANSFER MV) |

NPC mới (2/map, đúng vị trí):

| Map | NPC (ô) | Greet (port viết) | Hint (port viết) |
|---|---|---|---|
| 015 Khu Penthouse | Quản Lý Penthouse (3,3), Cư Dân Penthouse (8,6) | Nhà tầng 5, xong Chương 5 theo nhánh Giám đốc / Học giả / Gia đình / Siêu giàu / ở penthouse nhìn xuống cả phố | Nhà tầng 5 chỉ mở khi xong Chương 5 theo nhánh; đi nhanh bằng điện thoại mục Bản đồ |
| 016 Khu Sân Golf & Resort | Nhân Viên Sân Golf (3,3), Quản Lý Resort (8,6) | Sân golf là chỗ giải trí tầng 5 — đánh golf, gặp gỡ, làm quen / resort phục vụ khách tầng 5 | Muốn quen người tầng 5 thì ra sân golf; làm dịch vụ cao cấp cần ngoại ngữ + giao tiếp + kinh nghiệm |
| 017 Công Viên An Bình | Cô Bán Bánh (3,3), Ông Lão Tập Thể Dục (8,6) | Công viên ai cũng vào được — gặp gỡ, hẹn hò, đi dạo / tập thể dục, giữ An Yên mới đi xa | Công viên luôn mở — mệt thì ra đây đi dạo, gặp gỡ, ăn bánh cho khuây khỏa |
| 018 Phố Đi Bộ – Chợ Đêm | Chủ Sạp Đêm (3,3), Người Bán Hàng Rong (8,6) | Chợ đêm mở từ tối, đông nhất 20:00 thứ 7 / bán rong phải biết Bụi Đời Chợ Cá | Chợ đêm đông nhất 20:00 thứ 7 — mở sạp bán đêm; Bụi Đời Chợ Cá = đua doanh thu + phục vụ khách theo mùa |

Map015–018 **không có** hotspot / Góc Chế Tạo (như Map003–014 — đúng
quy ước port, không bịa thêm).

### 10.2 Khác bước 1–4 — hết data MV, cửa thêm trên Map014

Như bước 1 (không như bước 2–4 đồ thị MV đã thông sẵn): Map014 là map
cuối MV, chỉ có 1 cửa về Map013, nên phải thêm cửa (5,8) "Cửa đi Khu
Penthouse" → Map015 (`ADDED_DOORS`, như Map002→Map003 ở bước 1) để chuỗi
1→…→18 thông 2 chiều. Ô (5,8) trên Map014 trống (lớp 1 = 0, không
event). Map018 là map cuối chuỗi: chỉ 1 cửa về Map017, không có cửa đi
tiếp — cơ chế `_transfer()` chặn đích chưa có data vẫn giữ nguyên cho
tương lai (không còn đích nào chưa port trong 18 khu). Converter có
assert nội bộ cho map viết tay: L0 đủ 108 ô (chỉ 1/2), L1 đủ 28 ô, ô
cửa (5,4)/(5,8) + ô NPC (3,3)/(8,6) có L1 = 0.

### 10.3 File mới / đổi đợt này

| File | Nội dung |
|---|---|
| `tools/godot/convert_maps.py` (sửa) | `NPC_TEXT` thêm 8 NPC Map015–018; `ADDED_DOORS` thêm Map014→Map015; `HANDWRITTEN` (tên + NPC + tên cửa + đích); `handwritten()` mới (lớp tile mẫu Map014 + biến đổi L0 + assert); `main()` gộp 14 map MV + 4 map viết tay |
| `src/godot/data/maps.json` (tạo lại) | 18 map: Map001 5 event, Map002 7 event, Map003–017 mỗi map 4 event (2 NPC + 2 cửa), Map018 3 event (2 NPC + 1 cửa) |
| `src/godot/tests/g1_selftest.gd` (sửa) | Kỳ vọng 18 map; bảng số event từng map (14: door=2, 15–17: door=2, 18: door=1); đồ thị cửa BFS từ Map001 tới đủ 18 map; mỗi cửa có cửa ngược (không còn ngoại lệ cửa cuối); cửa hợp lệ 1..18 |
| `src/godot/tests/g3_playtest.gd` (sửa) | Chuỗi mở rộng 1→2→…→18 qua cửa (5,8), nói chuyện Quản Lý Penthouse / Nhân Viên Sân Golf / Cô Bán Bánh / Chủ Sạp Đêm, kiểm tra Map018 không có cửa đi tiếp (ô (5,8) không event, bước xuống vẫn ở Map018), đi ngược về Map001 qua các cửa (5,4) |
| `docs/godot-g3.md` (sửa) | §10 này + khối cập nhật bước 5 ở đầu file |

### 10.4 Verify thật đợt này (20/11 ~08:45)

| Kiểm tra | Kết quả |
|---|---|
| Converter chạy lại | Map001–018: L0=108, L1=28, event đúng số lượng từng map |
| `--check-only` 2 test mới | PASS, exit 0 |
| G1 selftest | **419/419 PASS** (từ 327/327: thêm ~92 mục cho 4 map mới + đồ thị) |
| G3 playtest mở rộng | **95/95 PASS** (chạy đầu đã pass hết — không lộ lỗi spawn, vì `break` lấy cửa đầu đã sửa ở bước 1) |
| G1 playtest | **14/14 PASS** (không regression) |
| G2 selftest cũ (Balance/Stats/Time) | **87/87 PASS** |
| G2 Jobs / Hotspot / Inventory+Crafting / Economy+Education / Social+Titles+Story / PhoneHub / Tools / Online / SaveCloud / UI wiring 1+2 / MarketBattle | **56/56 + 37/37 + 78/78 + 92/92 + 102/102 + 66/66 + 155/155 + 91/91 + 69/69 + 37/37 + 71/71 + 123/123 PASS** (không regression) |
| Scene Main chạy 120 frame | exit 0, không ERROR/warning |
| Export web | exit 0, ~6s; `index.wasm` 39,5 MB, `index.pck` 1.288.892 byte (`grep -a` thấy "Khu Penthouse" ×2, "Khu Sân Golf & Resort" ×3, "Công Viên An Bình" ×3, "Phố Đi Bộ – Chợ Đêm" ×2, "Quản Lý Penthouse"/"Chủ Sạp Đêm"/"Cửa đi Khu Penthouse" ×1 trong pck) |
| HTTP 200 | `index.html/js/wasm/pck/audio.worklet.js/png` đủ 6 file (cổng 8153); `GODOT_THREADS_ENABLED = false` |

### 10.5 Bước tiếp theo — G3 XONG, chuyển G4 (online + release)

1. Browser-verify G3 (mở build web, đi chuỗi 1→18, xem tile atlas tái
   dùng có vẽ đúng không — Map003–018 dùng tile nhà trọ làm
   xưởng/giảng đường/chung cư/văn phòng/cửa hàng/văn phòng công nghệ/
   phố dịch vụ/biệt thự/ngân hàng/đảo/penthouse/sân golf/công viên/chợ
   đêm là PROVISIONAL, chờ art pass vẽ tile riêng).
2. G4: online thật (server .NET đã có trong `src/server/`, PxbOnline
   hiện chỉ health/balance/gift qua endpoint thật, trade/đấu giá/công
   ty vẫn server-chưa-có-endpoint) + release (build web mới ở
   `src/godot-build/`, đã đồng bộ sang `godot-build/` ở root repo làm
   bản chơi local; `gh-pages-staging/` chứa bản split cũ — kiểm tra lại
   trước khi deploy gh-pages).
3. Scene trận MarketBattle (UI): vẽ lưới isometric qua `iso_map.gd`
   (luật ĐÃ CHỐT 20/11, xem `docs/market-battle-design.md`).
