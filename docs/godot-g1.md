# Godot G1 — Slice parity Map001–002 (19/11/2026)

> **Kết luận: G1 XONG (mức headless).** Map001 Xóm Trọ Cũ + Map002 Chợ Đầu Mối
> đã port sang Godot từ dữ liệu MV, chơi được: di chuyển theo ô, NPC đối
> thoại lựa chọn, hotspot đúng khung, chuyển map 2 chiều, hệ thời gian kiểu C.
> Selftest **42/42 PASS**, playtest mô phỏng chơi thật **14/14 PASS**,
> scene chạy 120 frame exit 0, export web exit 0 (~7s), http.server 200 đủ
> 6 file. **Chưa kiểm chứng bằng trình duyệt thật** — VM không có Chromium/
> Firefox (như G0), cần parent agent chạy browser task. Bản MV (`src/nadia/`)
> vẫn nguyên, không động vào.

## 1. Port dữ liệu — `tools/godot/convert_maps.py` → `src/godot/data/maps.json`

| Nguồn MV (không sửa) | Đích Godot |
|---|---|
| `Map001.json` / `Map002.json` (12×9, data 648 = 6 lớp × 108) | `layers[0]` nền (108 ô) + `layers[1]` vật (28 ô) |
| `atlas-map001/002.json` (vị trí tile trong atlas PNG) | `atlas_tiles` (id → x,y,w,h,layer) |
| `System.json` (startMapId 1, startX 4, startY 5) | `start` |
| `Actors.js` (greet/hint 4 NPC) | NPC `greet` + `hint` |
| `PXB_Hotspot.js` (bảng hotspot slice) | hotspot `best_frame`/`material`/`amount` |
| Event "Góc Chế Tạo" | craft: Map001 Xe Đẩy Hàng, Map002 Đèn Soi |
| Event "Cửa ra/về" | door: Map001 ↔ Map002, cùng ô (5,4) |

Kiểm tra converter: Map001 5 event (2 NPC + 1 hotspot + 1 craft + 1 door),
Map002 6 event (2 NPC + 2 hotspot + 1 craft + 1 door). Lớp vật tạo thành
vòng biên quanh map nên đồng thời là tường chắn.

## 2. Code Godot mới

| File | Nội dung |
|---|---|
| `scripts/iso_map.gd` (IsoMap) | Dựng TileSet isometric 64×32 lúc chạy từ atlas PNG + `maps.json`; 2 TileMapLayer (nền/vật) bật y-sort; chiếu tile↔world; `is_walkable` (trong biên + lớp 1 trống + không NPC) |
| `scripts/marker.gd` (Marker) | Điểm tương tác vẽ bằng code: NPC (người + dấu "!" + tên), hotspot (sao vàng nhấp nháy kiểu Nadia), craft, door |
| `player.gd` (viết lại) | Di chuyển theo ô 0,18s/ô, WASD/mũi tên, chạm vào ô để tự bước tới; signal `moved_to` |
| `main.gd` (viết lại) | Controller: load map, HUD (tên khu, Ngày/Khung, Túi), thời gian kiểu C, đối thoại lựa chọn, nhặt hotspot, chuyển map |
| `Main.tscn` (viết lại) | Chỉ còn root Node2D + `main.gd`; toàn bộ UI dựng bằng code trong `main.gd` |
| `data/maps.json` | Dữ liệu 2 map đã port (tạo bởi converter) |
| `tiles/atlas-map001.png`, `atlas-map002.png` | Atlas PNG copy từ MV (binary — xem §5) |
| `tests/g1_selftest.gd`, `tests/g1_playtest.gd` | Kiểm tra headless (xem §3) |

## 3. Verify thật trên VM — kết quả

```bash
godot --headless --check-only --script <moi script>   # 6/6 script khong loi
godot --headless --path . -s res://tests/g1_selftest.gd
godot --headless --path . -s res://tests/g1_playtest.gd
godot --headless --quit-after 120                      # chay scene that
godot --headless --export-release Web ../godot-build/index.html
python3 -m http.server 8140 --bind 127.0.0.1           # curl tung file
```

| Kiểm tra | Kết quả |
|---|---|
| `--check-only` 6 script (main, player, iso_map, marker, 2 test) | PASS, không lỗi |
| Selftest (data, TileSet iso, chiếu 108/108 ô/map, đi được/chặn, event, hotspot) | **42/42 PASS** |
| Playtest (đi 1 ô, qua cửa → Map002, nhặt hs-cho-sang ×2, nhặt lại bị chặn, đổi khung → Chiều nhặt hs-cho-chieu ×1, mở/đóng đối thoại Chị Lệ, về Map001 khung Tối nhặt hs-tro-toi ×2) | **14/14 PASS** |
| Scene Main chạy 120 frame | exit 0, không ERROR |
| Export web | exit 0, ~7s; `index.wasm` 39,5 MB, `index.pck` 890 KB (đã chứa `data/maps.json` + 2 atlas PNG + script — kiểm bằng `strings index.pck`) |
| HTTP 200 | `index.html/js/wasm/pck/audio.worklet.js/png` đủ 6 file; `GODOT_THREADS_ENABLED = false` (single-threaded, chạy Pages như file tĩnh) |

## 4. Giả định chưa kiểm chứng được (cần browser task)

1. **Căn texture iso:** atlas cell 64×64, tile nền là hình thoi 64×32 ở nửa
   dưới cell. Code đặt `texture_region_size = (64,64)` và
   `texture_origin = (0,-32)` để đáy hình thoi/chân vật rơi đúng đáy ô.
   Đây là suy luận từ API Godot (`TileData.texture_origin`), **chưa thấy
   bằng mắt** — nếu hình thoi lệch 32px so với ô thì sửa `texture_origin`
   (hoặc `y_sort_origin`, hiện là int 32). Browser task cần chụp màn
   hình Map001 và đối chiếu: nền hẻm liền mạch, nhà trọ đứng ở hàng biên.
2. **Y-sort trước/sau vật:** cả 2 TileMapLayer + IsoMap đều bật y-sort,
   `y_sort_origin = 32` (đáy ô). Chưa thấy bằng mắt: đi sau nhà trọ thì
   nhân vật phải bị che, đi trước thì không.
3. **Chữ tiếng Việt + UI:** font DejaVu đã nhúng (G0); hộp thoại + HUD
   chưa thấy render thật — cần xem có tràn/vỡ layout ở 720×1280 không.
4. **Âm thanh:** chưa có (G2 trở đi mới tính).

## 5. Giới hạn — nói thẳng

1. **Chưa chạy thử trong trình duyệt thật** (VM không có Chromium/Firefox/
   Playwright). Server http://127.0.0.1:8140/ đã tắt sau khi curl xong;
   parent chạy lại `python3 -m http.server 8140` trong `src/godot-build/`
   rồi mở bằng browser task, bấm Start, đi bằng WASD, bấm E gần NPC,
   kiểm tra §4.
2. **Chưa có sprite/art thật:** tile là atlas CC0 có sẵn (đúng đồ họa MV),
   nhưng người/NPC/hotspot vẫn vẽ bằng code. Sprite thật là việc sau G2.
3. **Chưa có logic game sâu:** chỉ di chuyển + đối thoại + hotspot + đổi
   khung + chuyển map. Việc làm (Jobs), chế tạo thật, học vấn, kinh tế,
   xã hội, cốt truyện — port 17 plugin PXB sang GDScript — là **G2**.
4. **Atlas PNG là binary, không push được qua snapshot-push** (giống vấn
   đề PNG của bản MV): `src/godot/tiles/*.png` chỉ có local. Khi push G1
   lên GitHub, parent cần embed base64 như `pxb-embedded.js` của MV hoặc
   để PNG ngoài repo; nếu không, bản export trên Pages sẽ thiếu tile.
5. **Wasm 39,5 MB** (gấp ~13 lần bản MV ~3 MB) — lần tải đầu chậm, cần
   màn hình loading + lazy-load theo khu ở các giai đoạn sau (đã cảnh báo
   từ G0).
6. **Khung thời gian:** 1 khung = 10 phút thật (đúng chốt kiểu C), nhưng
   để test có phím F / nút "Đổi khung" đổi khung ngay — đây là công cụ
   test, không phải luật chơi; khi release thì bỏ hoặc giấu sau menu dev.

## 6. Bước tiếp theo — G2

1. Browser-verify G1 (§4) — xong mới coi G1 là hoàn tất thật.
2. Port 17 plugin PXB → GDScript autoload theo `docs/opensource-engine.md`
   §4: Balance → Stats → Time → Jobs → Inventory/Crafting → Economy →
   Education → Social → Titles/Story → PhoneHub → MarketBattle →
   Online/SaveCloud, số khớp `GameBalance.cs`.
3. G3: đủ 18 khu (Map003–014 đã có data MV, Map015–018 mới).
4. G4: online + deploy `gh-pages` root = build Godot.
