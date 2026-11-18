# Phố Xô Bồ — kiến trúc Nadia (RPG Maker MV)

Kiến trúc chính từ 18/11/2026 22:30 (chủ cho phép đổi hẳn sang Nadia —
`docs/architecture-nadia.md` thay thế `docs/architecture.md` làm kiến trúc
chính). Game HTML5/JavaScript thuần, render Pixi.js (WebGL, fallback Canvas
2D), nội dung là file JSON + PNG + audio tĩnh. Code Unity cũ giữ nguyên trong
`src/client/` + `src/server/` làm phương án dự phòng / đối chiếu — không xóa,
không phát triển thêm trừ khi chủ quyết quay lại.

## Cây thư mục

```
src/nadia/
├── www/                        ← game (file tĩnh, deploy GitHub Pages)
│   ├── index.html              ← thứ tự load core MV (§1.2)
│   ├── js/
│   │   ├── libs/               ← pixi.js v4.5.4, pixi-tilemap, lz-string… (core MV, MIT — ĐÃ CÓ)
│   │   ├── rpg_core.js … rpg_windows.js  ← core MV v1.6.1, MIT (ĐÃ CÓ, tag community 1.3b)
│   │   ├── plugins.js          ← khai báo plugin ($plugins, 4 plugin bật)
│   │   ├── main.js             ← PluginManager.setup + SceneManager.run
│   │   └── plugins/
│   │       ├── PXB_Balance.js  ← hằng số duy nhất (port GameBalance.cs)
│   │       ├── PXB_Stats.js    ← 3 chỉ số gốc + 4 pha trộn + trần tổng (port Stats.cs)
│   │       ├── PXB_Time.js     ← 1 ngày 30 phút, 3 khung, sự kiện thứ 7 20:00 (port TimeSystem.cs)
│   │       └── PXB_Isometric.js← phép chiếu 2.5D (bản đầu: chưa móc Tilemap)
│   ├── data/
│   │   ├── System.json         ← gameTitle, tiền "đồng", map bắt đầu 1
│   │   ├── MapInfos.json       ← đủ 18 khu (tier + điều kiện mở là field mở rộng PXB)
│   │   ├── Map001.json         ← Xóm Trọ Cũ (12×9, event đủ theo Exploration.cs)
│   │   ├── Map002.json         ← Chợ Đầu Mối (12×9)
│   │   ├── Actors.json         ← 1 nhân vật chính ("Bạn" — tên PROVISIONAL)
│   │   ├── Classes.json        ← 1 class slice (params MV không dùng cho chỉ số gốc)
│   │   └── Items.json          ← 13 item (7 nguyên liệu + 2 công cụ + 3 đồ ăn/sách + quà tặng)
│   ├── img/                    ← CHƯA CÓ (tileset/character CC0)
│   └── audio/                  ← CHƯA CÓ (.ogg + .m4a, nhạc CC0, giọng Helio/Aria)
├── package.json                ← NW.js desktop (làm sau khi web ổn)
└── README.md                   ← file này
```

## Hiện trạng thật (19/11/2026 ~00:05)

- **Đã có (Giai đoạn 1, tiến thêm):** core MV v1.6.1 (MIT) ĐÃ CÓ — 12 file
  (6 `js/rpg_*.js` + 6 `js/libs/*`, tổng 2.341.224 byte, `node --check`
  12/12 PASS). Nguồn: `rpgtkoolmv/corescript` tag community 1.3b — repo
  không có tag v1.6.1; tag 1.3b chính là core v1.6.1 (header mỗi file ghi
  "v1.6.1 (community-1.3b)"); 6 file rpg build bằng đúng `concat.js` của
  repo; pixi.js v4.5.4 lấy từ bundle MV 1.6.1. Chỉ lấy code core + libs
  MIT — không lấy asset/nhạc/nhân vật/map/cốt truyện của Nadia hay RPG Maker.
  Plugin mới: `PXB_Stats.js` (261 dòng, port Stats.cs) + `PXB_Time.js`
  (268 dòng, port TimeSystem.cs), `node --check` PASS, smoke test logic
  thuần PASS; `plugins.js` nay khai báo 4 plugin (Balance → Stats → Time
  → Isometric). Kiểm tra tĩnh nhóm T15 mới (8 mục) khóa core + 2 plugin.
- **CHƯA CÓ — chưa mở trình duyệt chơi được:**
  1. `PXB_Isometric.js` chưa móc vào `Tilemap` — `install()` trả `false`
     khi chưa có core; nay core đã có, việc tiếp theo là móc Tilemap thật.
  2. Tile data trong Map001/002 toàn 0 (chưa có tileset CC0) — event đã đủ
     nhưng map chưa có hình.
  3. `img/` + `audio/` trống; plugin còn lại (`PXB_Hotspot`,
     `PXB_Crafting`, `PXB_Jobs`, `PXB_PhoneHub`…) chưa viết.
  4. Điểm PROVISIONAL mới (PXB_Time): ánh xạ "20:00 giờ game" trong ngày
     game 30 phút (20:00 = phút thật thứ 25), ngày game 1 = Thứ Hai,
     switch sự kiện thứ 7 = 1 — GDD chưa chốt, xem @help trong file.
- **Đã có từ trước (khung file, Giai đoạn 1):** `index.html` + `plugins.js`
  + `main.js` + `PXB_Balance.js` + `PXB_Isometric.js` (bản đầu) + `data/`
  tối thiểu (System, MapInfos đủ 18 khu, Map001–002, Actors, Classes,
  Items). `node --check` 6/6 file JS nadia OK; JSON hợp lệ; kiểm tra tĩnh
  `check_static.py` nhóm T14+T15 khóa khung này (xem `docs/test-report.md`).

## Chạy / test

```sh
# Cú pháp JS (chạy được ngay trên VM — node v24 có sẵn):
node --check src/nadia/www/js/plugins/PXB_Balance.js
node --check src/nadia/www/js/plugins/PXB_Stats.js
node --check src/nadia/www/js/plugins/PXB_Time.js
node --check src/nadia/www/js/plugins/PXB_Isometric.js
# Kiểm tra tĩnh toàn repo (gồm nhóm T14+T15 khóa khung nadia):
python3 src/server/tests/check_static.py
# Chạy game thật (CHƯA ĐƯỢC — chờ móc Tilemap + tileset, xem mục trên):
cd src/nadia/www && python3 -m http.server 8000
# rồi mở http://localhost:8000/ — KHÔNG mở file:// trực tiếp.
```

## Quy ước

- Không sửa core MV; mọi logic riêng là plugin (`PXB_*.js`), số lấy từ
  `PXB_Balance.js`; số chưa chốt ghi `PROVISIONAL` trong cả JSON lẫn plugin.
- Nguồn port: `GameBalance.cs` (số chốt) + `Jobs.cs` / `Crafting.cs` /
  `Stats.cs` (số cấu hình slice, PROVISIONAL) + `Exploration.cs` (hotspot)
  + `Actors.js` (NPC, tọa độ, lời chào). `src/web/data/*.js` là slice web cũ
  — đã lệch khỏi code C# ở 3 chỗ (xem "Lệch đã phát hiện" dưới), nên nadia
  port từ C#, không port từ web.
- Tên nhân vật chính "Bạn" là PROVISIONAL — GDD chưa chốt tên.
- `MapInfos.json`: field `tier`/`unlock` là mở rộng của Phố Xô Bồ (MV gốc
  không có) — DataManager MV bỏ qua field thừa, không vỡ load.

## Lệch đã phát hiện khi port (ghi nhận, chưa sửa — để GDD/PM xem lại)

Slice web `src/web/data/*.js` lệch khỏi code C# (Unity) ở 3 chỗ — nadia
lấy theo C#:

1. **Nghề:** `System.js` ghi bán rong stat Tâm, lương 100.000, khung tốt
   Sáng; `Jobs.cs` ghi stat Thể, lương 150.000, khung tốt Chiều. Shipper:
   web 150.000/khung Tối/stat Thể — C# 180.000/khung Tối/stat Thể (chỉ lệch
   lương). Nhân viên quán: web 100.000/khung Chiều/stat Tâm — C# 150.000/
   khung Sáng/stat Tâm.
2. **Công thức:** `System.js` ghi xe-đẩy cần khung-sắt 1 + bánh-xe 1 +
   ván-gỗ 1, đèn-soi cần sắt-vụn 2 + chai-nhựa 1; `Crafting.cs` ghi xe-đẩy
   cần khung-sắt 1 + bánh-xe 2 + ván-gỗ 2, đèn-soi cần sắt-vụn 2 +
   chai-nhựa 2. Bộ vật liệu khởi đầu 1/1/1 trong `System.js` không đủ chế
   xe-đẩy theo công thức C#.
3. **Hotspot:** `Maps.js` đặt `hs-cho-dem` ở map 2 (Sạp đêm cuối chợ, Tối,
   sắt-vụn ×1, cần đèn-soi) và thêm `hs-hem-sang` ở map 1; `Exploration.cs`
   đặt `hs-cho-dem` ở map 18 (Phố Đi Bộ – Chợ Đêm, Tối, vải-vụn ×2) và
   không có `hs-hem-sang`. Nadia theo `Exploration.cs`: Map002 không có
   `hs-cho-dem`, Map001 không có `hs-hem-sang`.

## Lộ trình (docs/architecture-nadia.md §11)

1. **Khung (đợt này)** — core MV đã về; còn thiếu móc Tilemap + tileset
   thì mới mở trình duyệt thấy map được.
2. Slice chơi được — port `PXB_Hotspot`, `PXB_Crafting`, `PXB_Jobs`,
   `PXB_PhoneHub` (PXB_Stats + PXB_Time đã xong); 2 map slice, 3 nghề,
   2 công thức; chơi hết 1 ngày game, save/load được.
3. Đủ 18 khu + 5 chương.
4. Online (`PXB_Online.js` + server .NET).
5. Release.
