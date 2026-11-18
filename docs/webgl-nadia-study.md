# WebGL kiểu Nadia (xenvn.com) — nghiên cứu và áp dụng cho Phố Xô Bồ

Ngày viết: 18/11/2026. Nguồn chính: trang
https://xenvn.com/treasure-of-nadia/ (đọc bằng browser.open ngày 18/11/2026),
cộng search xác minh engine. Trạng thái: file nghiên cứu local, chưa push.

> Kết luận trước: **Nadia trên xenvn KHÔNG phải Unity WebGL.**
> Nó là bản **RPG Maker MV export HTML5** — Pixi.js render qua WebGL
> (fallback Canvas) — host dưới dạng file tĩnh, chơi thẳng trên trình
> duyệt, không cài đặt. Phố Xô Bồ dùng **Unity WebGL** là đường khác,
> nặng hơn nhưng đúng engine đã chốt; link chơi cuối cùng vẫn giống nhau
> về trải nghiệm người dùng: mở 1 URL là chơi được trên PC + mobile.

## 1. Trang xenvn.com/treasure-of-nadia/ thực sự cho thấy gì

Những gì **đọc được trực tiếp từ trang** (browser.open, 18/11/2026):

- Tiêu đề: "Treasure of Nadia Online | Play Now On Web Browser",
  "No Installation Required! Compatible With Desktop, Android, iPhone
  Web Browser."
- Chơi được trên mọi trình duyệt PC, iOS, Android. **Đăng ký tài khoản
  là tùy chọn**, chỉ để "backup and sync your game data" — miễn phí.
  Tài khoản chơi game là tài khoản riêng, **không liên kết với tài
  khoản diễn đàn XenVn**.
- Điều khiển: desktop dùng chuột trái/phải; mobile chạm 1 ngón hoặc
  2 ngón cùng lúc; iOS cần chạm màn hình để bật âm thanh.
- Có bản Việt hóa trong game: Options → Vietnamese → On. Ngôn ngữ
  hỗ trợ: tiếng Anh + tiếng Việt.
- Có bộ lọc NSFW (18+) bật/tắt trong game qua Phone → Options →
  NSFW Filter. Đây là nội dung người lớn của Nadia — **Phố Xô Bồ
  KHÔNG lấy phần này** (game thuần Việt, sạch, xem §6).
- Rating 5 sao (69+ review), short URL `xenvn.com/ton`, cập nhật
  11/05/2026. Trang ghi "This version … is edited by XenVn.Com" —
  đây là **bản port/chỉnh sửa của XenVn, không phải bản chính thức
  của NLT Media**.

Những gì **KHÔNG xác minh được từ text fetch** (nói rõ để không bịa):

- Bản text của trang không lộ mã nhúng: không thấy thẻ `<iframe>`,
  không thấy đường dẫn file `.wasm` / `.data` / `.js` nào, không thấy
  host file game ở đâu (cùng domain xenvn hay CDN ngoài).
- Không xác minh được có cần đăng nhập mới chơi hay không (trang nói
  đăng ký là để sao lưu/đồng bộ, tức chơi được không cần tài khoản,
  nhưng chưa bấm chơi thử qua trình duyệt để kiểm chứng).
- Không xác minh được kích thước bản web, thời gian load lần đầu,
  hay save lưu ở localStorage hay server XenVn.

## 2. Engine của Nadia — kết luận: RPG Maker MV

Các nguồn mâu thuẫn nhau về engine, nên đối chiếu như sau:

| Nguồn | Nói engine gì | Độ tin cậy |
|---|---|---|
| SteamDB (app 1737100, depots) | **RPGMaker Engine**, Greenworks SDK, NWJS SDK, NodeJS SDK | Cao — đọc từ depot thật của bản Steam |
| IGDB / MobyGames / PlayTracker | **RPG Maker** | Cao — metadata chuẩn |
| xogx.com (trang game) | **RPG Maker (play in your browser)** | Trung bình — trang tổng hợp |
| haileytreasureadventureapk.com | "runs on RPG Maker MV" | Trung bình |
| treasureofnadiaapk.com (trang similar-games) | Viết "Treasure of Nadia and Lust Epidemic use the same Ren'Py engine" | **Thấp — sai**, mâu thuẫn SteamDB/IGDB; có thể nhầm với Lust Epidemic hoặc copy sai |
| adult-visual-novel.com | Gọi là "RPG Maker" trong nhóm "Beyond RPGM" | Trung bình |

**Kết luận: Nadia = RPG Maker MV** (bản Steam dùng NW.js; bản web
dùng export HTML5 của chính RPG Maker MV). Các trang ghi "Ren'Py"
là sai hoặc nhầm với game khác cùng thể loại. File
`docs/references.md` của repo trước đây cũng đã ghi "sources conflict
on engine, so only design (not architecture) was taken" — kết luận
này giữ nguyên, chỉ bổ sung bằng chứng SteamDB.

## 3. Nadia làm web chơi được như thế nào (RPG Maker MV HTML5)

RPG Maker MV export web **không cần build engine riêng**:

1. Trong editor: File → Deployment → chọn platform **Web Browsers**.
2. Engine xuất ra thư mục `www/` chứa:
   - `index.html` — entry point, load các script rồi boot game.
   - `js/` — `pixi.js` (thư viện render), `rpg_core.js`,
     `rpg_managers.js`, `rpg_objects.js`, `rpg_scenes.js`,
     `rpg_sprites.js`, `rpg_windows.js`, `plugins.js` (+ plugin).
   - `data/` — JSON: `System.json`, `Map001.json`… (map, event, database).
   - `img/` — tileset, character, face, picture… (PNG).
   - `audio/` — nhạc/hiệu ứng, MV ship cả `.ogg` + `.m4a` (desktop
     dùng `.ogg`, mobile/Safari cần `.m4a`).
3. Upload **nguyên thư mục `www/` lên web server tĩnh**, người chơi
   mở URL tới `index.html` là chơi. Không cần server-side, không cần
   cài đặt, không cần đăng nhập để chơi.
4. Render: **Pixi.js v4** — dùng **WebGL khi trình duyệt hỗ trợ**
   (ToneFilter), tự **fallback sang Canvas 2D** khi không có WebGL.
   Đây chính là "WebGL" mà chủ thấy trên xenvn: WebGL là **renderer
   của Pixi.js**, không phải Unity WebGL, không có file `.wasm`.
5. Tương tác: click chuột / chạm — đúng như hướng dẫn trên trang
   xenvn (chuột trái/phải, chạm 1–2 ngón).
6. Save: RPG Maker MV web lưu bằng `localStorage` của trình duyệt
   (mặc định), XenVn **thêm lớp tài khoản riêng** để sao lưu/đồng bộ
   save lên server của họ — đó là tính năng XenVn tự làm thêm, không
   phải tính năng gốc của RPG Maker MV.
7. Lưu ý kỹ thuật khi host kiểu này: **không mở `index.html` trực
   tiếp từ ổ đĩa** (file://) — trình duyệt chặn load data file; phải
   chạy qua web server thật. Tên file phân biệt hoa/thường trên
   server Linux (Windows thì không), sai case là vỡ asset.

So với Unity WebGL, đường RPG Maker MV nhẹ hơn rất nhiều: không
compile, không `.wasm` hàng chục MB, không cần header COOP/COEP,
chạy được cả trên trình duyệt yếu. Cái giá: chỉ làm được game 2D
tile-based kiểu RPG Maker, không làm được 2.5D isometric tùy biến
như Phố Xô Bồ đã chốt.

## 4. Unity WebGL của Phố Xô Bồ — khác Nadia ở đâu

| Hạng mục | Nadia trên xenvn (RPG Maker MV HTML5) | Phố Xô Bồ (Unity WebGL) |
|---|---|---|
| Engine | RPG Maker MV | Unity 2022.3.62f1 |
| Render web | Pixi.js v4 → WebGL (fallback Canvas) | Unity WebGL → WebAssembly + WebGL |
| File build | `index.html` + `js/` + `data/` + `img/` + `audio/` (JS + JSON + PNG, đọc được) | `index.html` + `Build/*.wasm` + `Build/*.data` + `Build/*.framework.js` + `Build/*.loader.js` (binary, nén Brotli/gzip) |
| Cần compile | Không | Có — Unity Editor build WebGL |
| Kích thước | Nhẹ (asset PNG/JSON) | Nặng — build WebGL Unity thường vài chục MB trước nén |
| Header đặc biệt | Không | Build có threads cần COOP/COEP (cross-origin isolation); build mặc định của Unity 2022 không threads thì GitHub Pages host được bình thường |
| Cần server-side | Không (trừ save-sync của XenVn) | Không cho bản chơi đơn; server .NET 8 chỉ cần khi làm online/multiplayer |
| Save | localStorage (+ tài khoản XenVn để sync) | PlayerPrefs / localStorage qua Unity; sync server sau |
| Mobile | Chạy tốt (chuột → chạm) | Chạy được nhưng nặng, cần tối ưu (đã ghi trong art-style: atlas theo khu, modular asset) |
| Bản quyền | Bản xenvn là bản edit không chính thức | Code + asset tự làm, CC0, không copy asset Nadia |

**Điểm chung quan trọng (cái chủ thực sự cần):** cả hai đều cho ra
**1 link web mở là chơi, không cài đặt, chơi được PC + mobile**.
Nadia chứng minh mô hình này chạy được thật với game nặng 9 GB bản
PC (GOG: 9 GB storage) mà bản web vẫn chơi được — vì web chỉ load
dần asset theo map. Phố Xô Bồ làm tương tự bằng Unity WebGL trên
GitHub Pages.

## 5. Áp dụng cho Phố Xô Bồ — đường đi đã có sẵn trong repo

Repo đã có sẵn, không cần làm lại từ đầu:

- **Unity project:** `src/client/` — Unity 2022.3.62f1
  (`ProjectSettings/ProjectVersion.txt`), scene slice
  `Assets/Scenes/SliceXomTroCu.unity` + `SliceChoDauMoi.unity`,
  script MonoBehaviour (`GameManagerBehaviour`,
  `PlayerController`, `HotspotView`, `PhoneHubView`…).
- **Workflow CI:** `.github/workflows/build-test.yml` — 4 job:
  `dotnet-test` → `unity-test` (EditMode) → `build-webgl`
  (game-ci/unity-builder@v4, target WebGL, chỉ push main) →
  `deploy-pages` (GitHub Pages). Build lần đầu 60+ phút,
  30–50 phút khi đã cache Library.
- **Link chơi sẽ là:** `https://tinnt120899.github.io/pho-xo-bo/`
  (đã ghi trong `docs/ci-build-test.md` §2 và trong workflow).
- **Học từ Nadia để áp cho Phố Xô Bồ:**
  1. **Mở link là chơi, không bắt đăng nhập** — như xenvn (tài khoản
     chỉ để sync save, là tính năng sau, không chặn chơi).
  2. **Điều khiển chạm trước cho mobile** — Nadia chơi được bằng
     chạm 1–2 ngón; Phố Xô Bồ đã có `PlayerController` chạm để đi
     + hotspot chạm được, cần giữ ưu tiên này khi làm UI.
  3. **Load dần theo khu, không load hết 18 khu lúc mở game** —
     Nadia load theo map; Phố Xô Bồ làm theo: scene slice Xóm Trọ
     Cũ + Chợ Đầu Mối trước, các khu khác load sau (đã có
     `FastTravel` chỉ tới khu đã mở trong `Exploration.cs`).
  4. **Tiếng Việt trong game** — Nadia có toggle Vietnamese trong
     Options; Phố Xô Bồ là game thuần Việt từ đầu nên mặc định
     tiếng Việt, không cần toggle.
  5. **Save nhiều slot, khôi phục dễ khi crash** — mẹo trên trang
     xenvn ("Save multiple segments"); áp cho Phố Xô Bồ: nhiều
     slot save + autosave sau mỗi khung.

## 6. Những gì KHÔNG lấy từ Nadia / xenvn

- **Không lấy nội dung 18+/harem** — Phố Xô Bồ là game xã hội
  Việt sạch, đã chốt từ đầu. Bộ lọc NSFW của Nadia không liên quan.
- **Không lấy asset, nhạc, nhân vật, map, cốt truyện Nadia** —
  chỉ lấy cơ chế (hotspot, crafting, quest, điện thoại, guidance)
  như `docs/nadia-reference.md` đã lock.
- **Không copy bản port của XenVn** — đó là bản edit không chính
  thức của game có bản quyền; Phố Xô Bồ tự build bằng Unity, asset
  CC0.
- **Không đổi engine sang RPG Maker MV** — dù đường web của nó nhẹ
  hơn, nó không làm được 2.5D isometric, hệ chỉ số 3 màu, công ty
  = guild, đấu giá… như GDD 12 mục đã chốt. Unity WebGL là đường
  đã chốt trong `docs/architecture.md`.

## 7. Bước còn thiếu để có link chơi Phố Xô Bồ

Theo thứ tự, trạng thái ngày 18/11/2026:

1. **Push 2 file workflow lên main — ĐANG KẸT.** API GitHub đã
   liên kết push file thường được, nhưng push `.github/workflows/`
   bị **403 "Resource not accessible by integration"** (đã thử 2
   cách ngày 18/11). Nguyên nhân: Muse GitHub App chưa có quyền
   **Workflows**. Cách xử lý (đã báo chủ): chủ mở
   https://github.com/apps/meta-muse-ai/installations/new,
   bật thêm quyền Workflows cho app (All repositories), báo lại để
   push workflow. Không có bước này thì CI không chạy, không có
   build WebGL tự động.
2. **Chủ tạo 3 secret Unity** (xem `docs/ci-build-test.md` §3):
   `UNITY_LICENSE` (nội dung file `.ulf` lấy qua workflow
   `activation.yml` → `.alf` → license.unity3d.com),
   `UNITY_EMAIL`, `UNITY_PASSWORD`. Rủi ro: Unity Personal có thể
   bị từ chối kích hoạt offline (2 nguồn mâu thuẫn, xem file CI);
   phương án dự phòng: Unity Pro/Plus (`UNITY_SERIAL`) hoặc
   self-hosted runner đã kích hoạt bằng Unity Hub.
3. **Bật GitHub Pages:** repo Settings → Pages → Source:
   GitHub Actions.
4. **Push 1 commit lên main** → workflow chạy: `dotnet-test`
   (vài phút, không cần secret) → `unity-test` → `build-webgl`
   (60+ phút lần đầu) → `deploy-pages`.
5. **Link chơi:** `https://tinnt120899.github.io/pho-xo-bo/` —
   mở là chơi, PC + mobile, không cài đặt, giống trải nghiệm
   xenvn của Nadia (nhưng bằng Unity WebGL, không phải RPG Maker).
6. **Sau khi có link:** đo thời gian load lần đầu, test trên
   mobile thật (Safari/Chrome), rồi mới tối ưu (nén, atlas theo
   khu, giảm dung lượng build).

## Nguồn

- https://xenvn.com/treasure-of-nadia/ — trang chơi online của
  XenVn (đọc 18/11/2026).
- https://steamdb.info/app/1737100/depots/ — Treasure of Nadia
  depots, Detected Technologies: RPGMaker Engine, NWJS SDK.
- https://www.igdb.com/games/treasure-of-nadia — Game Engine:
  RPG Maker.
- https://xogx.com/treasure-of-nadia — Game Engine: RPG Maker
  (play in your browser), v1.0117.
- https://naughty.games/guides/rpg-maker-web-export và
  https://deepwiki.com/miaowm5/RMMV-F1/3.2-desktop-and-web-deployment
  — cách RPG Maker MV export Web Browser (`www/`, Pixi.js,
  WebGL/Canvas fallback).
- Repo: `docs/nadia-reference.md`, `docs/nadia-scene-study.md`,
  `docs/ci-build-test.md`, `.github/workflows/build-test.yml`.
