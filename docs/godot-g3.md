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

## 6. Bước tiếp theo — G3 bước 2

1. Browser-verify G3 bước 1 (mở build web, đi chuỗi 1→5, xem tile
   atlas tái dùng có vẽ đúng không — Map003/005 dùng tile nhà trọ làm
   xưởng/giảng đường là PROVISIONAL, chờ art pass vẽ tile riêng).
2. Port Map006–008 (Chung Cư Cũ, Phố Văn Phòng Nhỏ, Khu Chung Cư Cao
   Cấp — đã có data MV + atlas mapping, cùng mẫu bước 1): thêm vào
   `MAP_IDS`, chạy converter, mở rộng selftest/playtest theo chuỗi.
3. Sau Map006–014: Map015–018 viết mới (Phố Đi Bộ – Chợ Đêm, Công
   Viên An Bình, + 2 khu tầng 5) theo `docs/districts.md`.
4. MarketBattle vẫn chờ chủ duyệt luật (xem `docs/market-battle-design.md`)
   — không port cho tới khi duyệt.
