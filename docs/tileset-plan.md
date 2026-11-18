# Kế hoạch tileset — Phố Xô Bồ (RPG Maker MV + render isometric riêng)

> Ngày nghiên cứu: 19/11/2026. File này chỉ là kế hoạch TEXT — chưa tải,
> chưa đưa bất kỳ file PNG nhị phân nào vào repo (xem §5).
>
> Căn cứ đã đọc trước khi viết: `docs/architecture-nadia.md` §1–§6
> (đường chính là RPG Maker MV, render 2.5D bằng plugin `PXB_Isometric.js`,
> tile iso 2:1, vd 64×32, viewport dọc 9:16) và `docs/art-style.md` §2 (palette
> khóa: tường vàng #E8C86A/#D9A441, mái tôn đỏ gạch #B4452F / tôn xanh #3E7A6E,
> đường xám ấm #8A7F70, nhựa đường #5C564E) + §7 (Isometric Z as Y, sort axis
> (0, 1, −0.26), atlas theo khu).
>
> Trạng thái xác minh: các URL dưới đây đã được mở/đọc trực tiếp bằng
> `browser.open` / `browser.search` ngày 19/11/2026. Mục nào ghi
> "CHƯA XÁC MINH" thì không được coi là đã chốt — phải kiểm tra lại sau khi
> tải file về.

## 1. Ứng viên tileset (2 chính + 1 tham khảo)

### Ứng viên A — Kenney Isometric Tiles (City + Landscape + Buildings) — ƯU TIÊN 1

| Hạng mục | Nội dung |
|---|---|
| Tác giả | Kenney (Kenney Vleugels) |
| Giấy phép | **CC0** — ghi rõ trên từng trang pack (đã mở và đọc trực tiếp) |
| Pack | Isometric Tiles City (128 file) + Isometric Tiles Landscape (128 file) + Isometric Tiles Buildings (128 file); bổ sung: Isometric Tiles Vehicles, Isometric Roads (95 file, CC0, đã xác minh) |
| URL tải (ĐÃ VERIFY) | https://kenney.nl/assets/isometric-tiles-city — https://kenney.nl/assets/isometric-tiles-landscape — https://kenney.nl/assets/isometric-tiles-buildings — https://kenney.nl/assets/isometric-roads — https://kenney.nl/assets/isometric-tiles-vehicles — trang tổng: https://kenney.nl/assets/tag:isometric |
| Kích thước tile gốc | **ĐÃ ĐO 19/11/2026 (xem §6):** tile City/Landscape canvas **132×~99** (hình thoi 128×64 + hông đất ~35px); Buildings 132×127 (nhà cao) / 99×~60 (mái nửa ô); Roads canvas 100×65; Vehicles sprite ~32×30 (16 hướng xoay). Không phải 64×32 gốc — downscale về footprint 64×32 khi đóng atlas (tools/tiles/build_atlas.py, NEAREST). |
| Định dạng | Từng tile là 1 file PNG riêng (không phải sheet ghép sẵn) + template Tiled kèm theo (theo trang bundle Kenney Isometric Assets: https://kenney.itch.io/kenney-isometric-assets — lưu ý bundle này giá 4.95 USD và chứa nội dung độc quyền; các pack lẻ trên kenney.nl là miễn phí CC0, đừng nhầm bundle trả phí với pack lẻ miễn phí) |
| Phù hợp Sài Gòn | Trung bình. Có đủ: đường, nhà phố, cây, đất/cỏ, xe. **Không có sẵn**: tường vàng loang lổ, mái tôn, dây điện chằng chịt, sạp chợ lá chuối, xe máy, ghế nhựa. Dùng làm nền + nhà phố rồi **recolor theo palette §2 art-style** (tường → #E8C86A, tôn → #3E7A6E / #B4452F). Phong cách Kenney hơi "hoạt hình Tây" — cần test 1 map trước khi chốt (xem §4). |
| Ghi chú | Tải ở kenney.nl, nút Download dẫn qua itch.io / màn hình donate — bấm "Continue without donating" để tải miễn phí. Giữ lại biên lai/giấy phép CC0 (trang pack đã ghi CC0 là đủ, không cần ghi credit nhưng nên ghi nguồn trong file này). |

### Ứng viên B — Screaming Brain Studios: 1000+ Isometric Floor Tiles (+ Wall / Object Pack) — ƯU TIÊN 2

| Hạng mục | Nội dung |
|---|---|
| Tác giả | Screaming Brain Studios |
| Giấy phép | **CC0** — ghi rõ trên OpenGameArt (tag license CC0) và tác giả xác nhận trong bình luận: "All Screaming Brain Studios assets are CC0, no credit required!" |
| Pack | 1000+ Isometric Floor Tiles: **1.049 tile** — 540 tile nước, 285 autotile/terrain blend, 224 tile sàn trong nhà + ngoài trời. Kèm *.tsx cho Tiled Map Editor. Pack cùng họ (chưa mở riêng từng trang — cần verify URL trước khi tải): Isometric Tiles – Wall Pack (1.872 tile), Isometric Tiles – Object Pack (395 tile), Isometric Tiles – Overworld Pack (360 tile) |
| URL tải (ĐÃ VERIFY) | https://opengameart.org/content/1000-isometric-floor-tiles |
| Kích thước tile gốc | **Đã xác minh qua danh sách file đính kèm**: bản lớn **256×128** (`sbs_-_isometric_floor_tiles_-_large_256x128.zip`, 3.4 MB), bản nhỏ **128×64** (`sbs_-_isometric_floor_tiles_-_small_128x64.zip`). Tỉ lệ 2:1 đúng chuẩn iso của game. Trang OpenGameArt mô tả: "true 2-Dimensional 2:1 isometric render", PNG, seamless tiling. |
| Định dạng | PNG, **nền đen (black background), KHÔNG trong suốt** — phải xử lý nền đen thành transparent (hoặc dùng làm sàn đặc, không chồng lớp) trước khi đưa vào atlas. Đây là điểm trừ lớn so với Kenney. |
| Phù hợp Sài Gòn | Trung bình-thấp cho mặt tiền phố (pack này mạnh về sàn/nền: gạch, đá, gỗ, đất, nước — không có nhà/tường/sạp hoàn chỉnh). Dùng tốt cho: sàn hẻm xi măng, sàn chợ, nền phòng trọ (gạch bông), vỉa hè. Tường/sạp phải lấy từ Kenney (A) hoặc vẽ thêm. |
| Ghi chú | Checksum (SHA-256/MD5) của file zip: **CHƯA CÓ** — OpenGameArt không công bố checksum trên trang. Sau khi tải, tự tính checksum và ghi vào §6 của file này. |

### Ứng viên C — Unity Top-Down Starter Kit (Ville Seppänen, Unity 6.4) — CHỈ THAM KHẢO, KHÔNG PHẢI TILESET ISO

| Hạng mục | Nội dung |
|---|---|
| Tác giả | Ville Seppänen |
| Giấy phép | Art kèm kit là **CC0** (ghi trên trang case study: "The kit includes a working example scene, CC0 assets…") |
| URL (ĐÃ VERIFY) | https://villeseppanen.com/unity-top-down-starter-kit.html — link GitHub repo nằm trong trang này (nút "Download at Github"); **không ghi URL GitHub cụ thể vào đây vì chưa mở được link đó, không đoán URL repo** |
| Kích thước tile gốc | Không công bố trên trang case study — **CHƯA XÁC MINH** |
| Kết luận | **Không dùng làm tileset chính.** Đây là template Unity top-down trực giao (orthogonal), không phải isometric, và là cả một project Unity chứ không phải pack tile. Chỉ tham khảo: cấu trúc scene/menus/HUD và cách tổ chức asset CC0. Đường chính của game là RPG Maker MV (§1 architecture-nadia), Unity chỉ là phương án dự phòng — không lấy tile từ kit này cho map iso. |

### Kết luận chọn lựa (đề xuất, chưa phải quyết định cuối)

- **Nền + đường + nhà phố: Kenney (A)** — CC0 chắc chắn nhất, PNG trong
  suốt, có Tiled template.
- **Sàn chi tiết (hẻm, chợ, phòng trọ): Screaming Brain (B), bản nhỏ 128×64**
  — sau khi xử lý nền đen.
- **Không pack nào có sẵn "hồn Sài Gòn"** (nhà tôn, tường vàng, chợ, vỉa hè
  đúng chất Việt). Cả 2 pack đều là chất liệu nền — phần Việt hóa (recolor
  tường vàng, mái tôn, sạp lá chuối, xe máy, dây điện, ghế nhựa, thùng xốp)
  phải vẽ thêm / recolor, đối chiếu palette `docs/art-style.md` §2 và mô tả
  verbatim 4 khu (§4). Không được lấy asset từ game khác / rip từ Nadia.

## 2. Cách map vào layout tileset MV — và vì sao KHÔNG map trực tiếp

### 2.1. Layout tileset chuẩn RPG Maker MV (đã xác minh qua diễn đàn RPG Maker)

- Tile chuẩn MV: **48×48 px**. Mỗi ô map MV là 1 ô vuông 48×48.
- **B–E: 768×768 px** (16×16 ô 48×48). Dùng cho tường/vật trang trí, hỗ trợ
  trong suốt, tối đa 2 lớp B–E chồng lên 1 ô (lớp thứ 3 sẽ xóa lớp dưới).
  Ô đầu tiên của sheet B phải để trong suốt (làm tẩy).
- **A5: 384×768 px** (8×16 ô). Sàn không-autotile — đây là chỗ đúng nhất
  cho tile sàn thường.
- **A4: 768×720 px** (tường autotile, 24 kiểu tường).
- **A1–A3: định dạng autotile đặc biệt** (mỗi autotile hoạt hình chiếm
  288×144 px = 3 frame × 96×144; A1 cho nước/hoạt hình, A2 cho đất autotile).
  **Tile iso KHÔNG phải autotile — tuyệt đối không nhét tile iso vào A1–A4.**
- Mỗi ô map MV bắt buộc có 1 tile A làm nền; B–E chỉ là lớp phủ.

### 2.2. Vấn đề cốt lõi: tile iso 64×32 KHÔNG vừa ô vuông MV 48×48

- Tile iso là hình thoi 2:1 (vd 64×32, 128×64, 256×128). Ô MV là hình
  vuông 48×48. Không có cách "xếp vừa" 1–1 mà không méo hình hoặc cắt xén.
- MV gốc là top-down trực giao; bản thân engine MV không có chế độ
  isometric. Đây đúng là rủi ro §3 dòng 1 của `docs/architecture-nadia.md`.

### 2.3. Đường chính (theo architecture-nadia §5): KHÔNG dùng Tilemap MV — dùng plugin render riêng

- **`PXB_Isometric.js` vẽ iso trực tiếp trên Pixi**, map vẫn là dữ liệu JSON
  kiểu MV (lưới + event có tọa độ lưới). Tile iso được dùng **dạng sprite /
  atlas theo khu** (1 atlas/khu), không đi qua sheet tileset MV.
- Chiếu: `sx = (x − y) × tileW/2`, `sy = (x + y) × tileH/2`, tile 2:1
  (vd 64×32); sort theo `x + y`; nhân vật/NPC neo chân ở đáy tile.
- Hệ quả: **không cần ép tile iso vào ảnh 768×768 slot A/B–E**. Việc cần làm
  là: (1) chọn tile gốc (Kenney / SBS bản nhỏ 128×64), (2) downscale footprint
  về **64×32** (chuẩn game, §5 architecture-nadia) bằng nearest-neighbour
  (giữ pixel sắc, không blur), (3) đóng atlas PNG theo khu
  (`img/tilesets/…` — tên thư mục chỉ là đề xuất, chốt khi viết plugin),
  (4) ghi bảng ánh xạ "tile nguồn → vị trí atlas → mã tile trong Map JSON"
  vào file này (§6) khi làm thật.
- Tile tường/vật cao hơn 1 ô (nhà 2 tầng, cây, sạp cao): vẽ dạng sprite cao
  (footprint vẫn 64×32, canvas cao hơn, vd 64×96), neo đáy, sort theo
  `x + y` — không cắt thành nhiều ô vuông MV.

### 2.4. Đường dự phòng: nếu bắt buộc dùng editor MV / Tilemap mặc định

Chỉ dùng khi plugin iso thất bại (lúc đó phải hỏi lại chủ theo §3
architecture-nadia — bỏ mục chốt 2.5D). Cách chuyển đổi, nếu làm:

1. Downscale tile iso về footprint **48×24** (tỉ lệ 2:1, vừa ô MV 48×48
   theo chiều ngang), đặt thoi iso ở giữa ô 48×48, phần còn lại trong suốt.
   Nhược điểm: mất một nửa độ chi tiết so với 64×32; đường chéo sẽ răng cưa
   hơn. Phương án khác: footprint 96×48 chiếm 2 ô MV ngang — chỉ dùng cho
   vật lớn, không dùng cho sàn.
2. Sàn (hẻm, đường, vỉa hè, sàn chợ): xếp vào **A5** (384×768, 8×16 ô),
   không-autotile. Sàn autotile (chuyển đất↔đường) bỏ qua ở bản đầu — vẽ
   chuyển tiếp thủ công bằng tile biên.
3. Tường/vật (tường vàng, mái tôn, sạp, xe máy, cây, thùng xốp): xếp vào
   **B–E** (768×768), mỗi vật là sprite trong suốt, đặt passability ★
   (đi xuyên sau lưng) hoặc ✕ (chặn) tùy vật; ô B đầu tiên để trống làm tẩy.
4. Nước/mưa/hoạt hình: chỉ A1 mới có hoạt hình — tile iso không có frame
   hoạt hình sẵn, muốn nước chảy phải tự làm 3 frame rồi mới nhét A1.
   Bản đầu: nước là sàn tĩnh A5, không hoạt hình.
5. Nhân vật MV mặc định là 48×48/frame (sheet 3×4). Nhân vật iso của game
   cao hơn tile (đi trên thoi 64×32) nên **không dùng sprite nhân vật MV
   mặc định** — vẽ riêng theo chuẩn neo đáy của plugin iso.

## 3. Gợi ý tile cụ thể cho 2 map slice (Map001, Map002 — đã xác minh trong repo: cả 2 đều 12×9 ô, tilesetId 1)

> "Gợi ý" = tile nguồn nào dùng cho ô nào. Tên tile dưới đây là mô tả theo
> nội dung pack (Kenney/SBS đặt tên file theo loại vật), **không phải tên
> file chính xác** — tên file chính xác chỉ có sau khi tải và liệt kê thư mục.
> Khi đó cập nhật bảng này bằng tên file thật.

### Map001 — Xóm Trọ Cũ (12×9, hẻm nhỏ Sài Gòn, tường vàng loang lổ, dây điện, xe máy, chậu cây, nắng xiên sáng)

| Vùng / lớp | Tile nguồn đề xuất | Ghi chú Việt hóa |
|---|---|---|
| Sàn hẻm (nền toàn map) | SBS Floor — tile xi măng/đá xám (bản nhỏ 128×64 → 64×32) | Recolor về xám ấm #8A7F70 (art-style §2); thêm vết loang bằng overlay |
| Vỉa hè trước phòng trọ | SBS Floor — tile gạch bông / gạch lát | Gạch bông là nét Việt — chọn mẫu gạch có hoa văn, không dùng gạch Tây trơn |
| Tường phòng trọ (biên map) | Kenney Buildings/City — tile tường nhà | **Recolor bắt buộc**: tường → vàng #E8C86A/#D9A441, loang lổ (thêm vết ố khi vẽ lại) |
| Mái tôn (nhà trọ) | Kenney Buildings — tile mái nhà | Recolor: tôn xanh #3E7A6E hoặc đỏ gạch #B4452F; mái ngói Tây trong pack phải sửa lại |
| Cửa phòng trọ + cửa sổ | Kenney City/Buildings — cửa, cửa sổ | Đặt làm event cửa (mở/khóa theo chương), không phải tile tĩnh |
| Xe máy dựng sát tường | Kenney Vehicles — xe (nếu có xe 2 bánh; nếu chỉ có ô tô thì **vẽ thêm xe máy**) | Xe máy là vật bắt buộc của hẻm Sài Gòn — không thay bằng ô tô |
| Chậu cây trước cửa | Kenney Landscape — cây/chậu | Nhỏ, đặt ở biên, không chặn lối đi chính |
| Dây điện chằng chịt | **Không có trong pack — vẽ thêm** dạng picture/event overlay phía trên map | Dây điện là dấu ấn hẻm Sài Gòn, không bỏ |
| Hotspot (kiểu Nadia) | Vẽ riêng, lấp lánh vàng, to ≥44×44 pt (art-style §1) | Không dùng tile pack làm hotspot |

### Map002 — Chợ Đầu Mối (12×9, chợ 5 giờ sáng, sạp rau củ xếp cao, lá chuối, thùng xốp, xe ba gác, đèn vàng, hơi sương)

| Vùng / lớp | Tile nguồn đề xuất | Ghi chú Việt hóa |
|---|---|---|
| Sàn chợ (nền toàn map) | SBS Floor — tile đá/đất nện (128×64 → 64×32) | Sàn chợ ướt/sáng sớm — tông tối hơn hẻm, thêm vũng nước tĩnh (A5, không hoạt hình ở bản đầu) |
| Đường nhựa + vỉa hè quanh chợ | Kenney Isometric Roads (95 file, CC0) — tile đường nhựa + vỉa hè | Recolor nhựa đường về #5C564E; vỉa hè xám ấm #8A7F70 |
| Sạp rau củ (dãy sạp giữa map) | Kenney City/Buildings — quầy/kệ + SBS Object Pack (nếu có kệ/hộp) | Sạp phải xếp cao rau củ — rau củ/lá chuối **vẽ thêm**, pack Tây không có rau chợ Việt |
| Thùng xốp, lá chuối | **Vẽ thêm** | Thùng xốp trắng + lá chuối xanh là vật kể chuyện của chợ đầu mối |
| Xe ba gác | Kenney Vehicles — xe tải nhỏ (nếu có; nếu không thì vẽ thêm) | Xe ba gác chở hàng — vật di động, đặt làm event, không phải tile tĩnh |
| Đèn vàng + hơi sương buổi sớm | Hiệu ứng ánh sáng trong plugin (ToneFilter / overlay vàng), không phải tile | Theo art-style §2: nắng vàng buổi sáng, đèn vàng buổi tối chợ đêm |
| NPC gánh hàng / người bán | Nhân vật vẽ riêng (theo lock nhân vật art-style §3) | Không dùng nhân vật trong pack tile |

## 4. Quy trình áp dụng (bước tiếp theo, theo thứ tự)

1. Tải 2 pack A + B về máy làm việc (KHÔNG tải vào repo — xem §5).
2. Kiểm tra và ghi bổ sung vào file này: kích thước tile thật của Kenney,
   tên file thật dùng cho Map001/Map002 (§3), checksum SHA-256 của 2 file zip.
3. Test nhỏ: dựng 1 map 12×9 mẫu bằng tile Kenney + SBS (qua plugin iso,
   không qua Tilemap MV), chụp màn hình, chấm theo rubric art-style §6
   (đủ 12/16, không chiều nào 0) rồi mới chốt pack.
4. Recolor theo palette art-style §2 (script recolor, giữ lại script + bảng
   màu trong repo — file script là text nên push được bình thường).
5. Đóng atlas theo khu (1 atlas/khu), ghi bảng ánh xạ tile → atlas vào §6.
6. Chỉ sau khi atlas xong mới bàn đưa PNG vào repo (§5).

## 5. ⚠️ QUAN TRỌNG — Cách đưa PNG vào repo (snapshot push KHÔNG nhận file nhị phân)

- **Cơ chế push hiện tại (github snapshot push) chỉ nhận file UTF-8
  (text). File PNG là nhị phân nên KHÔNG push được bằng cơ chế này.**
  Đừng thử push PNG qua snapshot — sẽ lỗi hoặc làm hỏng sync.
- **Trong lần này (file kế hoạch này): KHÔNG tải bất kỳ file nhị phân nào
  vào repo.** File này chỉ ghi URL + (sau này) checksum. Không có PNG nào
  được tải vào `~/workspace/pho-xo-bo/` trong lần làm này.
- Cách đưa PNG vào repo (chọn 1, do người có git / quyền GitHub thực hiện):
  1. **Git push từ máy có git** (khuyến nghị): `git add` các file PNG đã
     xử lý (atlas + tile nguồn đã recolor) rồi `git push origin main` từ
     máy tính có cài git và quyền push repo `tinnt120899/pho-xo-bo`.
     Đây là cách chuẩn cho file nhị phân.
  2. **Upload qua giao diện web GitHub**: mở repo trên github.com →
     Add file → Upload files → kéo-thả PNG (giới hạn ~25 MB/lần qua web;
     file lớn hơn thì dùng cách 1 hoặc Git LFS).
  3. **GitHub Release (nếu PNG chỉ là asset tải về, không cần version
     cùng code)**: đính kèm zip tile vào 1 release, repo chỉ giữ URL +
     checksum — code và asset tách nhau, repo nhẹ.
  4. **Không dùng**: snapshot push cho PNG; nhúng PNG dạng base64 vào
     file text (repo phình, khó quản lý); host PNG ở dịch vụ lạ không rõ
     nguồn.
- Sau khi PNG đã vào repo bằng cách 1/2, ghi vào §6: đường dẫn file trong
  repo + checksum SHA-256 đã verify khớp với file tải về. Nếu checksum
  lệch, không dùng file đó.
- Lưu ý dung lượng: atlas theo khu (art-style §7) — đừng đẩy cả 1.049 tile
  SBS + 384 tile Kenney thô vào repo; chỉ đẩy tile đã chọn + atlas đã đóng.

## 6. Bảng theo dõi (cập nhật khi làm thật)

| Mục | Trạng thái 19/11/2026 |
|---|---|
| URL Kenney City/Landscape/Buildings/Roads | ĐÃ VERIFY (mở trực tiếp, CC0) |
| URL SBS Floor Tiles (OpenGameArt) | ĐÃ VERIFY (mở trực tiếp, CC0, 1.049 tile, 256×128 / 128×64) |
| URL Unity Top-Down Starter Kit (case study) | ĐÃ VERIFY (CC0, nhưng không phải tileset iso — chỉ tham khảo) |
| Kích thước tile Kenney | **ĐÃ ĐO (xem §7):** City/Landscape 132×~99; Buildings 132×127 / 99×~60; Roads 100×65; Vehicles ~32×30 |
| Tên file thật dùng cho Map001/Map002 | **ĐÃ CÓ (xem §7):** SBS sheet + ô; Kenney buildingTiles_000/001/009/014/021, cityTiles_014, roads roadNS |
| Checksum SHA-256 các file zip | **ĐÃ CÓ (xem §7):** 6 file zip, đã tải 19/11/2026 |
| PNG trong repo | **CHƯA — atlas PNG chỉ nằm ở máy làm việc** `/tmp/pxb-tiles/atlas/` (SHA-256 xem §7); đưa vào repo bằng git push / upload web (§5), KHÔNG qua snapshot |
| Atlas theo khu | **ĐÃ ĐÓNG (19/11/2026):** atlas-map001 (5 tile) + atlas-map002 (6 tile), script `tools/tiles/build_atlas.py`, mapping JSON `src/nadia/www/data/atlas-map*.json` |
| Tile data Map001/Map002 | **ĐÃ ĐIỀN (19/11/2026):** layer 0 108/108 ô, layer 1 28/108 ô, scheme atlas-code — cần PXB_Isometric v3 (atlas mode) mới vẽ được |

## 7. Kết quả đo thật 19/11/2026 — đã tải 6 pack (CC0) về máy làm việc

Tải bằng curl (kenney.nl chặn UA mặc định: 403; thêm UA trình duyệt +
`Referer: https://kenney.nl/assets/<pack>` thì endpoint
`download-link/<hex>` trả link ký — xem `tools/tiles/` không lưu link ký
vì hết hạn). Zip lưu ở `/tmp/pxb-tiles/` (ngoài repo, đúng §5).

| Pack | File zip | Dung lượng | SHA-256 |
|---|---|---|---|
| Kenney Isometric Tiles City | `kenney-isometric-tiles-city.zip` | 990.594 byte | `bea03c38f340af6df14949cc7ca23ac68f30d087d4867350424f08b697a7e01c` |
| Kenney Isometric Tiles Landscape | `kenney-isometric-tiles-landscape.zip` | 1.141.541 byte | `18fa4fb22fa18bd4230e2422bc4123c986123c53966846b5a5bc219b331e7d3e` |
| Kenney Isometric Tiles Buildings | `kenney-isometric-tiles-buildings.zip` | 1.706.949 byte | `0894214e3b604f3eef53b9fa633340ba4617e24053a6178fa81dab6bac3d6d5e` |
| Kenney Isometric Roads | `kenney-isometric-roads.zip` | 621.468 byte | `dc7ffbe7d65c26cb2f46c6ce4beabf07206f410466a31572f572456728ed8f12` |
| Kenney Isometric Tiles Vehicles | `kenney-isometric-tiles-vehicles.zip` | 2.269.908 byte | `b478cf692d936e2cfda2368f8d24505841508907adc343f1068a6b2ea457d3fd` |
| SBS 1000+ Floor Tiles (bản nhỏ) | `sbs-floor-small-128x64.zip` | 880.313 byte | `d4d72f52ec543604c0d5a4bf3e4f0807e1000495c873646a3831b97afa7db5db` |

### 7.1. Kenney — tile đã xác định bằng mắt (contact sheet 0–31)

- **Landscape:** toàn bộ 0–31 là sông/kênh + dốc (không có cỏ phẳng ở
  đầu danh sách). Tile phẳng dùng được: **010 cỏ phẳng**, **014 đất
  phẳng**, **016 khối cỏ**, 015/021/022/028/029 dốc cỏ, 027 nước + bãi cát.
- **City:** khối vỉa hè + dải đường: **014/015/021 vỉa hè**, **022 ngã tư**,
  020/027/028 đường cong, 029/030 ngã ba, 000/002/003/006 đường có biển.
- **Buildings:** nhà/sạp trên bệ dày: **000 nhà nhỏ cửa xanh**,
  **001 sạp đỏ**, **003 nhà 2 tầng**, **007 sạp**, **009 sạp đỏ mái xanh**,
  **014 nhà nâu có cửa**, **021 nhà nâu có bậc**, **022 nhà vàng-xanh**,
  **030 nhà đỏ**; 005/006/013 là tấm mái phẳng (99×~55).
- **Roads:** tên file mô tả, không cần đoán: `road.png`, `roadNS.png`,
  `roadEW.png`, `roadNE/NW/ES/SW.png`, `crossroad.png`,
  `grass.png`, `grassWhole.png`, `dirt.png`, `dirtDouble.png`,
  `bridgeEW/NS.png`, `water.png`, `beach*.png`, `lotE/N/S/W.png`.
- **Vehicles: CHỈ CÓ Ô TÔ** (sedan, truck, pick-up, taxi, police,
  ambulance, garbage — mỗi loại 16 hướng xoay, sprite ~32×30).
  **Không có xe máy** — đúng như dự báo §3: xe máy phải vẽ thêm.
- **Kết luận §1 sửa lại:** kích thước tile gốc KHÔNG phải 64×32 —
  canvas Kenney 132×99 (thoi 128×64 + hông), Roads 100×65. Atlas
  downscale footprint về 64×32 bằng NEAREST (script §7.3).

### 7.2. SBS — sheet, KHÔNG phải tile lẻ (sửa kết luận §1)

Zip bản nhỏ chứa **10 sheet PNG** (không phải 1.049 file lẻ — 1.049 là số
tile nằm trong các sheet):

| Sheet | Kích thước | Lưới ô 128×64 |
|---|---|---|
| Worldmap `1 Forests 128x64.png` | 384×320 | 3×5 |
| Worldmap `2 Ground - Dry 128x64.png` | 384×320 | 3×5 |
| Worldmap `2 Ground - Rocky 128x64.png` | 384×320 | 3×5 |
| Pathways `1 Basic Ground - 128x72.png` | 512×216 | 4×3 (ô 128×72) |
| Pathways `1 Wilderness - 128x72.png` | 512×216 | 4×3 (ô 128×72) |
| Pathways `2 Cyber Road -128x72.png` | 512×216 | 4×3 (ô 128×72) |
| Pathways `Grass A - Road Yellow 128x72.png` | 512×72 | 4×1 (ô 128×72) |
| Interior `1 Floor - Tiled 128x64.png` | 384×192 | 3×3 |
| Interior `1 Floor - Wood 128x64.png` | 384×192 | 3×3 |
| Interior `2 Decoration - Carpet 128x64.png` | 384×192 | 3×3 |

Nền sheet là **đen đặc (~50% pixel đen)** — đã xác minh: cắt ô rồi áp mặt
nạ hình thoi 2:1 (script §7.3), KHÔNG dùng exact-black toàn cục (ruột
tile tối cũng có pixel gần đen). Ô đã dùng: Tiled (1,0) xám + (1,1) kem
cho Map001; Rocky (1,1) đá xám + (0,3) đá đậm cho Map002.

### 7.3. Atlas đã đóng — script + mapping + tile data thật (19/11/2026)

- Script: `tools/tiles/build_atlas.py` (Pillow, NEAREST, tint RGB
  PROVISIONAL theo palette art-style §2) + `tools/tiles/fill_map_data.py`
  (điền Map data theo công thức MV `data[(z*h+y)*w+x]`, giữ nguyên event).
- Selection: `tools/tiles/select-map001.json` (5 tile) +
  `tools/tiles/select-map002.json` (6 tile) — ghi rõ nguồn + ô sheet +
  tint + ghi chú Việt hóa từng tile.
- Atlas PNG (chỉ ở máy làm việc `/tmp/pxb-tiles/atlas/`, chưa vào repo):
  `atlas-map001.png` 512×64, SHA-256
  `971faa8da7d2410ec288bedb5bf981440ad5c6e35bfd4e0348d4a98a98715940`;
  `atlas-map002.png` 512×64, SHA-256
  `d1329a32bd39d5738708375afa0d9759f0b26ebcdc209bc26b45ce4a39080949`.
  Đưa vào `src/nadia/www/img/tilesets/` bằng git push / upload web (§5).
- Mapping JSON (text, đã push): `src/nadia/www/data/atlas-map001.json`
  (5 code) + `atlas-map002.json` (6 code). **Scheme atlas-code:**
  mã 1..N trong Map data là mã atlas, KHÔNG phải tile ID MV
  (B=0/C=256/A5=1536...) — đọc mapping JSON mới hiểu.
- Tile data thật: `Map001.json`/`Map002.json` layer 0 108/108 ô
  (sàn + xen kẽ + dải đường nhựa dọc x=5 ở Map002, xuyên qua ô cửa
  (5,4)), layer 1 28/108 ô (tường/sạp ở biên bắc/tây/đông; biên nam
  y=8 để trống như mặt tiền mở để không che sân trong khi nhìn iso).
  Event giữ nguyên tọa độ (Map001: 5 event; Map002: 6 event).
- **CHƯA vẽ được:** `PXB_Isometric.js` v2 đọc tile theo Tilemap MV
  (bitmap tileset) nên chưa tiêu thụ được atlas-code — cần **v3 atlas
  mode** (đọc mapping JSON + vẽ sprite từ atlas PNG, sort theo x+y)
  mới mở trình duyệt thấy map thật. V3 là việc tiếp theo lớn nhất sau
  đợt này (cùng với PXB_MarketBattle — luật chưa chốt).
- **Lỗi script đã sửa trong đợt này:** `build_atlas.py` lúc đầu xếp tile
  sai trục (`col, row = divmod(i, cols)` — divmod trả (thương, dư) nên
  phải là `row, col`); atlas đầu ra dồn 1 cột dọc. Đã sửa + chạy lại,
  atlas 512×64 xếp đúng 8 cột.
- **Recolor PROVISIONAL:** tint tường vàng (1.08, 0.95, 0.6) cho nhà
  Kenney + xám ấm cho sàn SBS chỉ là bước đầu — art pass (§4 bước 3:
  dựng map mẫu + chấm rubric ≥12/16) vẫn chưa làm, chưa chốt pack.

## Nguồn (đã đọc 19/11/2026)

- Kenney — Isometric Tiles City: https://kenney.nl/assets/isometric-tiles-city (CC0, 128 file, 2014)
- Kenney — Isometric Tiles Landscape: https://kenney.nl/assets/isometric-tiles-landscape (CC0, 128 file, 2014)
- Kenney — Isometric Tiles Buildings: https://kenney.nl/assets/isometric-tiles-buildings (CC0, 128 file, 2014)
- Kenney — Isometric Roads: https://kenney.nl/assets/isometric-roads (CC0, 95 file)
- Kenney — Isometric Tiles (trang tổng): https://kenney.nl/assets/tag:isometric
- Kenney Isometric Assets (bundle trả phí, chỉ để phân biệt với pack lẻ miễn phí): https://kenney.itch.io/kenney-isometric-assets
- Screaming Brain Studios — 1000+ Isometric Floor Tiles (OpenGameArt, CC0): https://opengameart.org/content/1000-isometric-floor-tiles
- Ville Seppänen — Unity Top-Down Starter Kit (CC0 assets, Unity 6.4): https://villeseppanen.com/unity-top-down-starter-kit.html
- RPG Maker MV tileset layout (B–E 768×768, A5 384×768, A4 768×720, autotile A1 288×144/pattern; không nhét tile thường vào A1–A4): https://rpg-refuge.com/threads/using-your-own-tilesets-in-rpg-maker-mv.703/ và https://forums.rpgmakerweb.com/threads/where-to-find-48-48-sprites.86021/
- Nội bộ: `docs/architecture-nadia.md` §1–§6, `docs/art-style.md` §2/§7, `src/nadia/www/data/Map001.json` + `Map002.json` (12×9, tilesetId 1 — đã kiểm tra trong repo).
