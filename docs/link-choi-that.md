# Link chơi thật — Phố Xô Bồ: nút thắt còn lại, đối chiếu Treasure of Nadia

> Cập nhật 19/11/2026 ~07:50 (giờ VN). Đối chiếu từng nút thắt với cách
> Treasure of Nadia / xenvn làm — vì chủ yêu cầu luồng này phải tham khảo
> Nadia: **RPG Maker MV web tĩnh, render Pixi.js WebGL, save localStorage,
> mở link là chơi, không cài đặt, không đăng nhập**.

## Link chơi sẽ là

```
https://tinnt120899.github.io/pho-xo-bo/src/nadia/www/
```

GitHub Pages (Deploy from a branch) phục vụ **toàn bộ repo** theo đường dẫn
thư mục — không cần dời `www/` ra root, không cần workflow, không cần
secret Unity. Đây đúng là mô hình xenvn: upload nguyên thư mục `www/` lên
host tĩnh, mở `index.html` là chơi.

## Nút thắt còn lại — theo thứ tự tới link

| # | Nút thắt | Nadia / xenvn làm thế nào | Phố Xô Bồ trước đợt này | Đã giải quyết trong đợt này | Còn lại |
|---|----------|---------------------------|-------------------------|------------------------------|---------|
| 1 | **Game kẹt ở màn hình loading** — `DataManager` load 14 file `data/*.json`, repo chỉ có 5 | Nadia xuất từ MV Editor ra đủ 14 file (`Actors, Classes, Skills, Items, Weapons, Armors, Enemies, Troops, States, Animations, Tilesets, CommonEvents, System, MapInfos`). Thiếu 1 file là `isDatabaseLoaded()` false mãi (404 không throw, chỉ kẹt im) | Thiếu 9 file: Skills, Weapons, Armors, Enemies, Troops, States, Animations, Tilesets, CommonEvents | ✅ **Đã tạo đủ 9 file** (`src/nadia/www/data/`): 8 file `[null]` đúng chuẩn MV + `Tilesets.json` id 1 với `flags` 2048 số 0 (Game_Map đọc `flags[tileId]` khi di chuyển — thiếu là crash; 0 = đi được, map slice mở). Đã kiểm: 14/14 file parse JSON được | Không còn — chờ mở trình duyệt kiểm chứng |
| 2 | **Atlas PNG nhị phân chưa lên GitHub** — map vẽ trắng nếu thiếu | Nadia host PNG tileset như file tĩnh bình thường trong `img/tilesets/` (xenvn upload nguyên thư mục `www/`) | PNG đã có local (`atlas-map001/002.png`, 17,5/17,1 KB) nhưng snapshot-push chỉ đẩy được text UTF-8 nên chưa bao giờ lên repo (grep sync = 0) | ✅ **Đã nhúng base64 thành text**: `tools/tiles/embed_assets.py` sinh `src/nadia/www/js/pxb-embedded.js` (~52 KB, 13 asset) + hook `ImageManager.loadBitmap` (có cache, đường nào không nhúng thì rơi về load file gốc). Kết quả chạy giống hệt Nadia (ảnh load được), chỉ khác cách đưa file lên (text thay vì binary). Chạy lại script khi đóng atlas mới | Không còn — chờ mở trình duyệt kiểm chứng |
| 3 | **Ảnh hệ thống MV thiếu** — `img/system/Window.png` (boot reserve), IconSet, Balloon, Shadow1/2, Damage, States, Weapons1-3, ButtonSet | Nadia ship đủ ảnh mặc định của MV trong `img/system/` | `img/` chỉ có 2 atlas PNG; các ảnh hệ thống đều thiếu. Không crash (`Bitmap._onError` chỉ đánh dấu lỗi) nhưng cửa sổ/menu vẽ trắng | ✅ **Đã nhúng placeholder** trong `pxb-embedded.js`: Window 192×192 (nền xanh đậm + viền sáng, đủ đọc menu) + 10 ảnh còn lại trong suốt. Chưa phải art thật — chỉ để boot + mở menu được | Art thật thay sau (không chặn link) |
| 4 | **GitHub Pages chưa bật** — chưa có host tĩnh nào phục vụ repo | xenvn: upload `www/` lên host tĩnh là có link. Không CI, không build | Chưa bật Pages; workflow Unity (cần quyền Workflows, đang kẹt 403) từng được coi là đường duy nhất | ✅ **Đã chuẩn bị xong phía repo**: `.nojekyll` ở root (tắt Jekyll, phục vụ file nguyên vẹn) + mọi file game đã là text, đẩy được qua snapshot-push | ⏳ **VIỆC DUY NHẤT CẦN CHỦ (1 việc)**: repo Settings → Pages → Build and deployment → Source: **Deploy from a branch** → Branch: **main**, Folder: **/ (root)** → Save. Xong là có link ở bảng trên. Không cần quyền Workflows, không cần secret Unity, không cần workflow nào |
| 5 | **Chưa mở trình duyệt chơi thật lần nào** | Nadia trên xenvn đã chơi được trên trình duyệt thật (PC + Android + iPhone) | Chỉ có kiểm tra tĩnh + smoke test stub; chưa ai bấm Play | ✅ **Đã kiểm chứng tới mức làm được không cần trình duyệt**: `node --check` toàn bộ JS nadia OK; `python3 src/server/tests/check_static.py` **248/248 PASS, 0 FAIL, exit 0**; `python3 -m http.server` trong `src/nadia/www/` + curl **28/28 file trả 200** (index + 6 core + 6 libs + pxb-embedded + plugins + main + 14 data JSON) | ⏳ **Cần parent chạy browser task**: mở link (sau khi chủ bật Pages) hoặc `http://localhost:8137/` local, bấm Play, xác nhận thấy map Xóm Trọ Cũ + đi được + mở điện thoại. Subagent không có trình duyệt thật nên không tự xác minh bước này được — nói thẳng, không bịa |

## Không còn là nút thắt (đã gỡ nhờ đổi sang kiến trúc Nadia)

- **Quyền Workflows / Unity license / secret Unity**: chỉ cần cho CI Unity
  (đường cũ). Đường Nadia deploy bằng Pages branch, không cần workflow nào.
  Hai file `.github/workflows/` local vẫn kẹt 403 nhưng **không chặn link**.
- **VM không có dotnet/Unity**: game Nadia là file text JS/JSON, test bằng
  `node --check` + trình duyệt — không cần dotnet/Unity để có link.
  xUnit (17 test) + EditMode (219 test) vẫn chưa chạy thật — đó là việc của
  server Phase 2 / đường Unity dự phòng, không phải điều kiện để có link.
- **Audio trống**: `System.json` không tham chiếu file nhạc nào
  (title/battle BGM đều `""`) nên không chặn boot. Nhạc CC0 + giọng
  Helio/Aria thêm sau.
- **Nhân vật chưa có sprite** (`characterName: ""` ở actor + event): người
  chơi/NPC tàng hình nhưng game vẫn chạy, đi lại/tương tác vẫn được — chỉ
  xấu, không chặn link. Sprite CC0 là việc art tiếp theo.

## Những gì chưa phải Nadia — nói thẳng

- **2.5D isometric là phần tự viết, Nadia không có sẵn** (MV gốc top-down
  2D). `PXB_Isometric.js` v3 atlas mode + atlas theo khu là code riêng;
  nếu mở trình duyệt thấy map sai hình thì đó là lỗi plugin này, không
  phải lỗi kiến trúc MV.
- **Save**: Nadia web lưu `localStorage` qua `StorageManager` của MV —
  Phố Xô Bồ dùng đúng cơ chế đó (đã có trong core). Tài khoản đồng bộ save
  kiểu xenvn (`PXB_SaveCloud.js`) là lớp thêm ở Phase 2, server chưa có
  endpoint nên hiện trả `server-chua-co-endpoint` — chơi đơn không cần nó.
- **Online nhiều người**: MV không có sẵn (Nadia cũng chơi đơn). Phase 2
  mới có, qua `PXB_Online.js` + server .NET — không phải điều kiện link.

## Đã sửa thêm trong đợt này (ngoài bảng trên)

- `check_static.py` T14a FAIL giả: comment mới trong `index.html` chứa
  chuỗi `js/main.js` nên `find()` bắt nhầm vị trí trước `plugins.js`. Đã
  sửa câu chữ trong comment (không sửa code game), chạy lại **248/248 PASS**.
- File mới/sửa trong đợt này (local, chưa push — parent push):
  `src/nadia/www/data/{Skills,Weapons,Armors,Enemies,Troops,States,
  Animations,Tilesets,CommonEvents}.json` (mới),
  `tools/tiles/embed_assets.py` (mới), `src/nadia/www/js/pxb-embedded.js`
  (mới, sinh tự động), `src/nadia/www/index.html` (thêm 1 thẻ script),
  `.nojekyll` (mới), `docs/link-choi-that.md` (file này).
