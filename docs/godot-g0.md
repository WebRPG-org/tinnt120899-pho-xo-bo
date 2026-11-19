# Godot G0 — Khung chạy được (19/11/2026)

> **Kết luận: G0 XONG.** Godot 4.7.2 đã cài và chạy được trên VM này, project
> `src/godot/` export web thật thành công, serve bằng `http.server` trả 200
> cho mọi file. **Chưa kiểm chứng bằng trình duyệt thật** — trên VM không có
> Chromium/Firefox hay Playwright/Puppeteer, cần parent agent chạy browser
> task (xem §5). Bản MV (`src/nadia/`) vẫn nguyên, không động vào.

## 1. Godot đã cài — bằng chứng

| Mục | Giá trị |
|---|---|
| Phiên bản | **4.7.2.stable.official.ed1daf0bf** (`godot --version`, chạy thật trên VM) |
| Link tải editor | https://github.com/godotengine/godot/releases/download/4.7.2-stable/Godot_v4.7.2-stable_linux.x86_64.zip (77.860.424 byte — khớp đúng kích thước release) |
| Link tải export templates | https://github.com/godotengine/godot/releases/download/4.7.2-stable/Godot_v4.7.2-stable_export_templates.tpz (1.281.349.702 byte — khớp đúng kích thước release) |
| SHA-256 (tính local, 19/11) | editor zip `cadd3204e728a35d3f13adb7fd0d7902636b79f6b95c40c265eb73b6c35329e4`; templates tpz `f298490b8d44d934be425a5a65a51bf15f422428b229a06a6e11d9ffea248011` |
| Vị trí editor | `tools/godot/Godot_v4.7.2-stable_linux.x86_64` (binary 146 MB, đã giải nén) |
| Vị trí templates | `~/.local/share/godot/export_templates/4.7.2.stable/` (2,0 GB, đã giải nén từ tpz; lưu ý tpz chứa thư mục `templates/` con — đã chuyển nội dung lên đúng cấp để Godot nhận) |

**Lưu ý checksum:** release 4.7.2 chỉ công bố file `.sha256` cho source tarball
(`godot-4.7.2-stable.tar.xz.sha256`), không có checksum chính thức cho 2 file
zip/tpz trên. 2 SHA-256 trên là tính local để đối chiếu khi tải lại, không phải
xác minh với nhà phát hành. Kích thước file khớp đúng từng byte với release.

**Cài lại từ đầu (nếu VM bị thay):**
```bash
mkdir -p ~/workspace/pho-xo-bo/tools/godot ~/.local/share/godot/export_templates/4.7.2.stable
cd ~/workspace/pho-xo-bo/tools/godot
curl -sL -o Godot_v4.7.2-stable_linux.x86_64.zip \
  https://github.com/godotengine/godot/releases/download/4.7.2-stable/Godot_v4.7.2-stable_linux.x86_64.zip
curl -sL -o Godot_v4.7.2-stable_export_templates.tpz \
  https://github.com/godotengine/godot/releases/download/4.7.2-stable/Godot_v4.7.2-stable_export_templates.tpz
unzip -o -q Godot_v4.7.2-stable_linux.x86_64.zip
unzip -o -q Godot_v4.7.2-stable_export_templates.tpz -d ~/.local/share/godot/export_templates/4.7.2.stable/
# Nếu trong 4.7.2.stable/ xuất hiện thư mục templates/ con thì: mv templates/* . && rmdir templates
~/workspace/pho-xo-bo/tools/godot/Godot_v4.7.2-stable_linux.x86_64 --version
# → 4.7.2.stable.official.ed1daf0bf
```

## 2. Project Godot — `src/godot/`

| File | Nội dung |
|---|---|
| `project.godot` | Tên "Phố Xô Bồ", main scene `Main.tscn`, features `4.7 + GL Compatibility`, viewport **720×1280 (9:16 dọc)**, stretch `canvas_items` + aspect `keep`, orientation Portrait, renderer `gl_compatibility`, `emulate_touch_from_mouse=true` |
| `Main.tscn` | Root Node2D + `main.gd`; Player (Node2D + `player.gd`); CanvasLayer UI: Title "Phố Xô Bồ" (64pt), Subtitle "G0 — Godot 4.7.2 • Khung chạy được", Hint "WASD / mũi tên / chạm-kéo để di chuyển" |
| `main.gd` | Vẽ nền vàng nhạt nắng trưa + vỉa hè; đặt player giữa màn hình lúc mở |
| `player.gd` | Di chuyển WASD/mũi tên (`ui_left/right/up/down` có sẵn) + chạm-kéo (touch target); tốc độ 260 px/s; kẹp trong viewport; vẽ bằng code: bóng, thân áo xanh lá (màu Trí), đầu, tóc — **placeholder, chưa có sprite thật** |
| `export_presets.cfg` | Preset **Web**, `variant/thread_support=false` (single-threaded), `export_path="../godot-build/index.html"` |
| `DejaVuSans.ttf` + `DejaVuSans-Bold.ttf` | Font hệ thống copy vào project — **đủ dấu tiếng Việt** cho chữ trên màn hình (luật dấu của game). License DejaVu tự do, được phép nhúng. |
| `.godot/`, `*.import`, `*.uid` | Sinh bởi `--headless --import` — đã thêm vào `.gitignore`, không push. |

**Không push:** `tools/godot/` (binary 1,5 GB), `src/godot-build/` (39 MB),
`src/godot/.godot/` đã được thêm vào `.gitignore` (19/11).

## 3. Export web — lệnh + kết quả thật

```bash
cd ~/workspace/pho-xo-bo/src/godot
~/workspace/pho-xo-bo/tools/godot/Godot_v4.7.2-stable_linux.x86_64 \
  --headless --export-release Web ../godot-build/index.html
# exit 0, ~7 giây. Lỗi duy nhất gặp: thư mục đích chưa tồn tại → mkdir trước là xong.
```

| File xuất ra (`src/godot-build/`) | Kích thước |
|---|---|
| `index.wasm` | **38 MB** (dự báo trong docs/opensource-engine.md là ~39,5 MB — khớp) |
| `index.pck` | 814 KB (chứa scene + font + script) |
| `index.js` | 274 KB |
| `index.html` | 5,4 KB (`<canvas id="canvas">`, tên "Phố Xô Bồ") |
| `index.audio.worklet.js`, `index.audio.position.worklet.js`, `index.png`, icon | còn lại |

Tổng build web: **~39 MB** — gấp ~13 lần bản MV (~3 MB). Đúng như đã cảnh
báo: lần tải đầu chậm, cần màn hình loading + lazy-load theo khu ở các
giai đoạn sau.

**Kiểm tra trước export (đều PASS):**
- `godot --headless --import` → exit 0, font import OK.
- `godot --headless --check-only --script main.gd` / `player.gd` → không lỗi.
- `godot --headless --quit-after 120` (chạy scene thật 120 frame) → exit 0,
  không error/warning nào trong log.

## 4. Verify bằng HTTP server — kết quả thật

```bash
cd ~/workspace/pho-xo-bo/src/godot-build
python3 -m http.server 8139 --bind 127.0.0.1
```

| File | HTTP |
|---|---|
| `index.html` | 200 |
| `index.js` | 200 |
| `index.wasm` | 200 |
| `index.pck` | 200 |
| `index.audio.worklet.js` | 200 |
| `index.png` | 200 |

Xác minh thêm trong `index.html`: **`GODOT_THREADS_ENABLED = false`** — đúng
export single-threaded, không cần header COOP/COEP, chạy được trên GitHub
Pages như file tĩnh (đúng như docs/opensource-engine.md §1.1 đã tra).

## 5. Giới hạn — nói thẳng

1. **CHƯA chạy thử trong trình duyệt thật.** Trên VM không có Chromium,
   Firefox, Playwright hay Puppeteer (`which` + `fc-list` đều trống).
   Việc còn lại cho parent agent: chạy browser task mở
   **http://127.0.0.1:8139/** (server đang chạy sẵn trên VM lúc viết file
   này — nếu tắt thì chạy lại lệnh ở §4), bấm Start, xem có hiện chữ
   "Phố Xô Bồ" + nhân vật xanh lá di chuyển được bằng WASD không, chụp
   màn hình làm bằng chứng. Nếu browser task cũng không mở được localhost
   (từng lỗi `invalid_request` với bản MV ngày 19/11), thì phải deploy
   `src/godot-build/` lên `gh-pages` rồi test bằng link Pages.
2. **Chưa có sprite/art thật:** player vẽ bằng hình tròn/chữ nhật trong
   code; nền chỉ là màu trơn + vạch vỉa hè. Art thật (atlas PNG, TileSet
   isometric) là việc G1.
3. **Chưa có game logic nào:** chỉ di chuyển + hiển thị. 17 plugin PXB
   port sang GDScript là việc G2.
4. **RAM VM chỉ còn ~518 MB trống** lúc export — export G0 (7 giây) vẫn
   qua, nhưng project lớn dần có thể cần theo dõi RAM.
5. **Bản MV không bị động vào:** `src/nadia/` + cron 24/24 trên MV vẫn chạy
   song song cho tới khi Godot đạt parity (theo quyết định của chủ).

## 6. Bước tiếp theo — G1 (Slice parity Map001–002)

1. Browser-verify G0 (mục §5.1) — xong mới coi G0 là hoàn tất thật.
2. Tạo TileSet isometric 64×32 từ atlas PNG hiện có (`tools/tiles/`,
   `src/nadia/www/data/atlas-map001.json`).
3. Port Map001 Xóm Trọ Cũ + Map002 Chợ Đầu Mối (12×9) sang TileMapLayer
   bằng script (không gõ tay), NPC cô Tư/chị Lệ/anh Hải + dialogue,
   hotspot nhặt 1 lần/ngày đúng khung.
4. Chơi được slice như bản MV hiện tại, play-test trên trình duyệt.
