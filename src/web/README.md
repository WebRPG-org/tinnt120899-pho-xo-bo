# Phố Xô Bồ — Game web chơi được thật (`src/web/`)

Game slice chơi được ngay trên trình duyệt, theo đúng kiến trúc web của
Treasure of Nadia trên xenvn.com: **file tĩnh HTML5/JS, mở link là chơi,
không cài đặt, chơi được trên Desktop / Android / iPhone bằng trình duyệt**.
Chủ đã cho phép 18/11/2026: đổi hẳn sang kiến trúc này cho bản web (code
Unity cũ vẫn giữ nguyên trong `src/client/`, không xóa — bản đầy đủ vẫn đi
Unity + server .NET khi có máy build).

## Kiến trúc kiểu RPG Maker MV (không dùng engine MV, tự viết lại bằng JS thuần)

Như Nadia bản web: dữ liệu data-driven, game đọc dữ liệu mà chạy.

| File MV | File Phố Xô Bồ | Nội dung |
|---|---|---|
| `data/MapInfos.json` | `data/MapInfos.js` | Danh sách 18 khu (đúng 18 khu đã chốt), khu nào khóa + điều kiện mở |
| `data/Map001.json` | `data/Maps.js` | Map tile 12×9: Xóm Trọ Cũ + Chợ Đầu Mối, hotspot, NPC, cổng chuyển khu |
| `data/Actors.json` | `data/Actors.js` | NPC: cô Tư, bạn thân Bin, chị Lệ, anh Hải — thoại + gợi ý |
| `data/Items.json` | `data/Items.js` | Nguyên liệu, đồ chế, đồ ăn/sách |
| `data/Skills.json` | `data/Skills.js` | 4 công cụ (Xe Đẩy, Đèn Soi, Sổ Tay, Xẻng), mỗi bậc đổi hành vi thật |
| `data/CommonEvents.json` | `data/CommonEvents.js` | 3 quest: chế Xe Đẩy, phụ sạp chị Lệ, chạy đơn buổi tối |
| `data/System.json` | `data/System.js` | Khung ngày, 3 nghề, công thức, 9 tab điện thoại, học vấn |
| Pixi WebGL renderer | `js/iso.js` + Canvas 2D | Chiếu tile sang 2.5D isometric (bước chuyển — xem dưới) |

## Chạy

```bash
cd src/web
python3 -m http.server 8000
# mở http://localhost:8000/
```

Mở trực tiếp file `index.html` cũng chạy (dữ liệu nằm trong file `.js`,
không dùng fetch, tránh lỗi CORS khi mở `file://`).

## Chơi thế nào

- **Đi:** WASD / phím mũi tên, hoặc chạm vào canvas (mobile). Đứng lên ô
  **CỔNG** là sang khu kia (kiểu transfer event của MV).
- **Nói chuyện:** lại gần NPC rồi nhấn `E`, hoặc chạm vào NPC. Cô Tư là NPC
  dẫn đường (thay Soul Crystal/Evie của Nadia) — bí thì hỏi cô ấy, gợi ý
  gắn mục tiêu hiện tại, không bao giờ biến mất giữa game.
- **Quest:** nhận ở NPC → làm theo yêu cầu → về trả quest cho NPC đó.
  Quest mở theo tiến trình, không khóa theo ngày/giờ cứng.
- **Nhặt:** hotspot vàng lấp lánh (cam = hiếm, cần Đèn Soi) — nhặt 1 lần /
  ngày game, đúng khung mới có đồ, sang ngày có đồ mới (sparkle của Nadia).
- **Chế:** phải đứng gần **Góc Chế Tạo** (ô CHẾ) mới chế được — như Native
  Shrine của Nadia, không chế từ menu ở đâu cũng được. Xe Đẩy Hàng = Khung
  Sắt + Bánh Xe + Ván Gỗ; Đèn Soi = Sắt Vụn ×2 + Chai Nhựa. Chế Xe Đẩy xong
  mở đường tới Công Viên An Bình.
- **Làm ca nghề:** 1 ca/khung, tốn 10 năng lượng. Lương theo chỉ số chính,
  khung tốt +25%, đúng khu +10%. Bán rong / shipper / nhân viên quán.
- **Điện thoại (P):** 9 tab như `PhoneHub.cs` — Danh bạ/Tin nhắn, Ngân
  hàng, Bản đồ (🟢 đi được / 🔴 khóa + điều kiện mở), Việc làm, Chợ (mua
  đồ ăn/sách, bán nguyên liệu), Học tập (đăng ký học thật: trả tiền, học
  đủ ngày thì Trí/EXP tăng), Sức khỏe, Xã hội, Cài đặt.
- **Ngày:** 1 ngày game = 30 phút thật, 3 khung Sáng/Chiều/Tối — hết 10
  phút thật tự sang khung (đồng hồ đếm ngược trên HUD), hoặc bấm "Sang
  khung sau". Miss khung không bị phạt. Sang ngày mới: hotspot reset +
  lãi tiết kiệm 0,5% (ở slice tính theo ngày cho thấy rõ).
- **Dùng đồ:** phím `U` hoặc nút "Dùng đồ ăn/sách" — cơm tấm/cà phê hồi
  năng lượng, sách cũ tăng Trí.
- **Lưu:** tự động vào localStorage + 3 ô save ở tab Cài đặt (kiểu xenvn
  lưu save theo tài khoản — ở slice này lưu local, tài khoản làm ở phase
  online).

## Góc nhìn 2.5D — bước chuyển, nói thẳng

- Mặc định game vẽ **isometric 2.5D thử nghiệm** (`js/iso.js`): cùng một
  lưới tile, chỉ đổi phép chiếu khi vẽ — logic đi lại, va chạm, hotspot,
  NPC không đổi. Bấm "Đổi góc nhìn" để về top-down như Nadia.
- Chưa phải 2.5D isometric thật: tile vẫn là hình thoi + khối hộp vẽ bằng
  Canvas, chưa có sprite/art thật, chưa có sort theo chiều sâu đầy đủ.
  Bước tiếp theo: thay Canvas bằng Pixi.js (đúng renderer Nadia dùng),
  vẽ sprite isometric thật theo `docs/art-assets.md`.

## Ranh giới (nói thẳng)

- Chỉ 2 khu slice (Xóm Trọ Cũ, Chợ Đầu Mối), 3 nghề, 2 công thức, 3 quest.
  Công Viên An Bình / Chợ Đêm mở điều kiện nhưng map chưa xây — hiện ghi
  "đang xây map, mở sau".
- Không có server, không multiplayer, không đấu giá online — các hệ đó ở
  bản Unity + server .NET.
- Vẽ Canvas 2D bằng hình khối/màu — **chưa có art thật**.
- Mọi hệ mới vẫn chốt ở GDD/Unity trước; web slice chỉ port lại phần đã
  chốt. Không phát triển `src/web/` thành game thứ hai.
