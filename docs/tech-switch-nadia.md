# Chuyển công nghệ sang y chang Treasure of Nadia (xenvn) — Quyết định

> Chủ cho phép 18/11/2026 18:10: chuyển công nghệ sang y chang Nadia trên
> https://xenvn.com/treasure-of-nadia/ (WebGL chơi được trên web).
> Nghiên cứu ngày 18/11/2026. Kết luận ở §4 — đọc trước khi làm theo.

## 1. Công nghệ thật của xenvn.com/treasure-of-nadia

**Treasure of Nadia chạy trên RPG Maker MV.** Bằng chứng (không phải đoán):

- xogx.com: "Game Engine: RPG Maker (play in your browser)", version 1.0117.
- haileytreasureadventureapk.com: "Although it runs on RPG Maker MV… Engine: RPG Maker MV".
- SteamDB (app 1737100): "Detected Technologies: RPGMaker Engine, Greenworks SDK,
  NWJS SDK, NodeJS SDK" — NW.js + Node.js chính là runtime desktop của RPG Maker MV.
- Trang xenvn tự mô tả: chơi ngay trên trình duyệt, không cài đặt, tương thích
  Desktop / Android / iPhone; đăng ký tài khoản miễn phí để sao lưu + đồng bộ
  dữ liệu giữa thiết bị (tài khoản chơi game tách riêng với tài khoản XenVn).

**"WebGL" ở đây nghĩa là gì — nói cho chính xác:**

- RPG Maker MV là engine **HTML5/JavaScript**, render bằng **Pixi.js** (WebGL
  renderer, fallback Canvas). Bản web của MV không phải file `.wasm` / `.data`
  như Unity WebGL.
- Cấu trúc bản web MV: `index.html` + `js/rpg_core.js`, `rpg_managers.js`,
  `rpg_sprites.js`, `rpg_scenes.js`, `plugins.js` + `data/*.json`
  (Map, System, Items, Actors…) + `img/` + `audio/`. Toàn bộ là **file tĩnh** —
  host ở đâu cũng chạy, không cần server riêng cho game single-player.
- Phần "đăng ký tài khoản để sao lưu/đồng bộ" là **server riêng của xenvn** thêm
  vào trên bản MV (lưu save lên tài khoản), không phải tính năng gốc của MV.
- Mobile chơi được vì MV web chạy bằng chạm (tap 1 ngón / 2 ngón), đúng như
  hướng dẫn trên trang xenvn. iOS cần chạm màn hình để bật âm thanh.

Tóm lại: Nadia trên xenvn = **RPG Maker MV, xuất bản web HTML5 (Pixi/WebGL),
host tĩnh + server lưu save của xenvn**. Không phải Unity WebGL, không phải
Godot, không phải server game.

## 2. Đối chiếu với Phố Xô Bồ hiện tại

| Hạng mục | Phố Xô Bồ hiện tại (đã chốt) | RPG Maker MV (Nadia) |
|---|---|---|
| Engine | Unity 2022 LTS + .NET 8 server | RPG Maker MV (HTML5/JS, Pixi) |
| Đồ họa | 2.5D isometric, mobile dọc 9:16 | Top-down 2D tile, màn hình ngang |
| Online | Có: công ty=guild, đấu giá, buôn bán, sổ cái server | Không có sẵn: single-player offline; online phải tự viết plugin + server |
| Code đã có | ~20 script C# (Stats, Jobs, Economy, Social, Exploration, Crafting, PhoneHub…), scene slice, test xUnit/EditMode, CI workflow | Viết lại toàn bộ bằng JS/plugin MV, data JSON |
| Build/deploy | Unity WebGL → GitHub Pages (đang kẹt license + quyền Workflows) | Xuất web MV → host tĩnh là chạy ngay, không cần license CI |
| Chi phí engine | Unity Personal miễn phí (vướng license CI) | RPG Maker MV/MZ thương mại (~$79.99), editor chỉ Windows/Mac |
| Build trên VM này | Không (không Unity/.NET đủ RAM) | Cũng không build editor được trên Linux VM; chỉ chạy được bản web đã xuất |

## 3. Giữ lại gì / Đổi gì nếu chuyển

**Giữ nguyên (không phụ thuộc engine):** GDD 12 mục, đúng 18 khu / 5 tầng lớp,
hệ chỉ số 3 màu + pha trộn, học vấn 5 bậc, nghề + công ty=guild, kinh tế
(lãi 0,5%, phí đấu giá 5%, cấm cash-out/cờ bạc), xã hội (vợ/chồng, bạn thân,
gia đình), 5 chương gắn rank, chữa lành, điện thoại làm hub, chuẩn Nadia
(`docs/nadia-reference.md`, `docs/nadia-scene-study.md`).

**Phải đổi nếu chuyển sang MV:**
- Engine Unity → RPG Maker MV: toàn bộ code C# bỏ, viết lại bằng event +
  plugin JS; scene `.unity` bỏ, làm lại map tile MV.
- 2.5D isometric → top-down 2D: **mất điểm chốt "chỉ 2.5D"** của game.
- Server .NET (ledger, auction, guild) → phải tự viết server + plugin MV
  giao tiếp qua HTTP/WebSocket; MV không có sẵn multiplayer.
- Mobile app (APK/IPA) → chỉ còn bản web; muốn app phải bọc NW.js/Cordova.
- CI: workflow Unity bỏ, thay bằng xuất web MV bằng tay trên máy Windows/Mac
  có editor (không tự động hóa được trên GitHub Actions).

## 4. Quyết định — KHÔNG chuyển engine hoàn toàn

**Giữ Unity 2022 LTS + .NET 8 làm engine game đầy đủ. Lý do:**

1. Chuyển sang MV là **đi lùi so với 2 mục chốt lớn nhất**: 2.5D isometric và
   online nhiều người chơi. MV không làm được 2 thứ đó mà không viết lại
   gần như một engine mới trên lưng MV.
2. Code C# + test + scene slice đã có sẽ mất trắng; MV cũng không chạy được
   trên VM này (editor Windows/Mac, thương mại), nên nút thắt "không có máy
   build" không được giải quyết — chỉ đổi từ "thiếu Unity license CI" sang
   "thiếu máy Windows có RPG Maker MV".
3. Cái chủ thật sự cần từ Nadia không phải engine MV, mà là **cách đưa link**:
   chơi ngay trên web, không cài đặt, được trên mobile. Unity WebGL cho ra
   đúng link đó (`https://tinnt120899.github.io/pho-xo-bo/`), chỉ đang kẹt ở
   license + quyền Workflows (xem `docs/ci-build-test.md`).

**Cái lấy y chang từ Nadia (đã làm):**

- **Mô hình đưa link:** bản web tĩnh, mở link là chơi, không cài đặt,
  chạm được trên mobile — áp dụng cho cả Unity WebGL (game đầy đủ) và
  `src/web/` (slice web nhẹ, xem §5).
- **Lưu save theo tài khoản:** xenvn cho đăng ký để sao lưu/đồng bộ — Phố Xô Bồ
  làm tương tự ở phase online: tài khoản + server .NET lưu tiến trình, không
  chỉ lưu local.
- **Thiết kế hệ thống:** vẫn bám `docs/nadia-reference.md` như cũ (hotspot,
  crafting là cổng tiến trình, NPC dẫn đường, điện thoại làm hub).

## 5. Skeleton web mới — `src/web/` (đã viết, cùng đợt này)

Để có link chơi được **ngay** trong lúc chờ Unity WebGL, repo có thêm slice web
tĩnh theo đúng mô hình MV web (file tĩnh, không cần build, không cần server):

- `src/web/index.html` — trang chơi, canvas + giao diện điện thoại 9 tab.
- `src/web/js/game.js` — vòng lặp game: đi phố (WASD/chạm), hotspot lấp lánh,
  nhặt nguyên liệu, chế Xe Đẩy Hàng, làm ca nghề, điện thoại làm hub, ngày
  game 30 phút / 3 khung Sáng-Chiều-Tối, lưu localStorage.
- `src/web/data/maps.json` — dữ liệu khu Xóm Trọ Cũ + Chợ Đầu Mối, hotspot,
  NPC (cô Tư, chị Lệ, anh Hải), công thức chế tạo — cùng số với `GameBalance.cs`.
- `src/web/README.md` — cách chạy + ranh giới.

Ranh giới nói thẳng: đây là **slice web nhẹ** (Canvas 2D, vẽ bằng hình khối/màu,
chưa có art thật), không phải bản MV đầy đủ và không thay thế Unity. Code Unity
cũ **không xóa, không sửa** trong đợt này. Khi Unity WebGL build được, link
chính vẫn là GitHub Pages từ bản Unity; `src/web/` chỉ là đường chơi thử nhanh.

## 6. Lộ trình tới link chơi được

1. **Ngay:** `src/web/` — host tĩnh là có link chơi slice (cần host: GitHub Pages
   thư mục `src/web`, hoặc bất kỳ host tĩnh nào). Không cần Unity license.
2. **Sau khi có quyền Workflows + secret Unity:** push `.github/workflows/`,
   chạy CI → Unity WebGL → `https://tinnt120899.github.io/pho-xo-bo/`
   (link chính, game đầy đủ, 2.5D).
3. **Phase online:** server .NET + tài khoản lưu save kiểu xenvn (đồng bộ
   nhiều thiết bị).

## 7. Rủi ro

- Nhầm lẫn "WebGL" = Unity WebGL: Nadia dùng Pixi/WebGL qua RPG Maker MV,
  không phải `.wasm`. Đừng đi tìm file `.wasm` của Nadia — không có.
- Không copy asset/nhạc/nhân vật/cốt truyện của Nadia; chỉ lấy cơ chế và mô
  hình đưa link. Game này sạch, không có nội dung 18+.
- `src/web/` là 2 code base song song (JS + C#): chỉ giữ slice web ở mức tối
  thiểu, không phát triển nó thành game thứ hai; mọi hệ mới vẫn viết ở Unity
  trước, web slice chỉ port lại phần đã chốt.

## Nguồn

- https://xenvn.com/treasure-of-nadia/ (truy cập 18/11/2026: chơi trên web,
  không cài đặt, Desktop/Android/iPhone, đăng ký sao lưu/đồng bộ).
- https://xogx.com/treasure-of-nadia (Engine: RPG Maker, play in browser).
- https://steamdb.info/app/1737100/depots/ (Detected Technologies: RPGMaker
  Engine, Greenworks SDK, NWJS SDK, NodeJS SDK).
- haileytreasureadventureapk.com (Engine: RPG Maker MV).
