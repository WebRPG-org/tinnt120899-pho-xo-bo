# Scripts — Phố Xô Bồ (client Unity)

## Mở project

1. Cài **Unity Hub** + **Unity 2022.3.62f1** (LTS, xem `../ProjectSettings/ProjectVersion.txt`).
   Thêm module build theo nền tảng cần test: Android Build Support
   (SDK/NDK/OpenJDK đi kèm) và/hoặc iOS Build Support, WebGL Build Support.
2. Unity Hub → **Add** → chọn thư mục `src/client/` (đây là thư mục gốc
   project: chứa `Assets/`, `Packages/`, `ProjectSettings/`).
3. Mở scene **`Assets/Scenes/Main.unity`**:
   - `Main Camera` — camera orthographic, góc isometric (xoay 30° X / 45° Y),
     theo chuẩn 2.5D đã chốt (docs: Isometric Z as Y, sort axis).
   - `Directional Light` — ánh sáng mặt trời, màu ấm kiểu Sài Gòn buổi chiều.
   - `GameManager` — object trống, để gắn MonoBehaviour điều phối game
     (chưa gắn script — xem mục dưới).
   - `XomTroCu (Slice 1)` — root trống cho khu đầu tiên của slice
     (Xóm Trọ Cũ + Chợ Đầu Mối, Mục 11).

Lần mở đầu tiên Unity sẽ tự tạo `Library/`, `Temp/`, `Logs/` và file
`.meta` còn thiếu — các thư mục này KHÔNG commit lên Git (xem `.gitignore`).

## Trạng thái code hiện tại

13 file `*.cs` trong thư mục này là **logic thuần C#** (chỉ dùng
`System` / `System.Collections.Generic`, **chưa dùng `UnityEngine`**):

| File | Vai trò |
|---|---|
| `Stats.cs` | Hệ chỉ số 3 gốc + trộn (Mục 4) |
| `TimeSystem.cs` | 1 ngày game = 30 phút thật, 3 khung (Mục 1) |
| `District.cs` | Đúng 18 khu, 5 tầng (Mục 3) |
| `TitleConflict.cs` | Xung đột danh hiệu (Mục 3) |
| `GameBalance.cs` | Nguồn duy nhất cho số liệu đã chốt |
| `PhoneHub.cs` | Điện thoại là menu chính: 9 tab (Mục 2) |
| `Jobs.cs` | 3 nghề slice + quota tuần (Mục 11) |
| `Inventory.cs` | Túi đồ, buff tạm 1 khung (Mục 2 + 7) |
| `Exploration.cs` | Hotspot khám phá kiểu Nadia (Mục 2 + 11) |
| `Crafting.cs` | Chế tạo từ nguyên liệu (Mục 2) |
| `Social.cs` | Người yêu / bạn thân / gia đình (Mục 8) |
| `Economy.cs` | Tiền, nhà/xe, lãi, đấu giá (Mục 7) |
| `PlayerProgress.cs` | 5 chương + kết thúc (Mục 9 + 12) |

## Lớp MonoBehaviour mỏng (C2, đã có — gọi vào logic thuần, không chứa luật)

| File | Vai trò |
|---|---|
| `GameManagerBehaviour.cs` | Khởi tạo Stats, chạy vòng ngày 30 phút/3 khung, giữ túi/nguyên liệu/khu mở, khám phá + chế tạo + fast travel + gợi ý NPC |
| `PlayerController.cs` | Di chuyển isometric theo camera (WASD / chạm tay), tương tác hotspot gần nhất (phím E) |
| `HotspotView.cs` | Hotspot lấp lánh kiểu Nadia (to, chạm được, nhấp nháy; mờ đi khi đã nhặt hôm nay); visual hiện là hình khối/màu tạm do code tạo |
| `PhoneHubView.cs` | Bật/tắt overlay điện thoại 9 tab (phím P / Esc); Canvas UI chưa dựng — field để null thì logic vẫn chạy |
| `CameraFollowBehaviour.cs` | Camera lerp theo Player, giữ góc isometric — GIẢI PHÁP TẠM cho tới khi gắn Cinemachine (xem dưới) |

## Scene slice (C2)

- `Assets/Scenes/SliceXomTroCu.unity` — Xóm Trọ Cũ (khu 1): GameManager + Player + hotspot `hs-tro-toi` (cuối hẻm, khung Tối).
- `Assets/Scenes/SliceChoDauMoi.unity` — Chợ Đầu Mối (khu 2): GameManager + Player + hotspot `hs-cho-sang` (sạp chị Lệ, Sáng) + `hs-cho-chieu` (góc phế liệu, Chiều).
- 2 hotspot slice còn lại (`hs-cong-vien` khu 17, `hs-cho-dem` khu 18) thuộc scene khu riêng, chưa tạo.
- Mỗi script MonoBehaviour có file `.meta` với GUID cố định; scene trỏ vào GUID đó — đổi GUID phải sửa cả scene.

## Gắn Cinemachine trong Editor (làm sau, package đã có sẵn)

1. Mở scene slice → chọn Main Camera → Add Component → **CinemachineBrain**.
2. Tạo GameObject mới → Add Component → **CinemachineVirtualCamera** → Follow = Player, LookAt = Player, Lens: Orthographic, Orthographic Size 5, Body: Framing Transposer.
3. Tắt component `CameraFollowBehaviour` trên Main Camera (nó chỉ là giải pháp tạm).
4. Không tự bịa GUID script của package trong file `.unity` — GUID phải do Unity tạo khi import package, bịa sai sẽ thành Missing Script.

## Việc tiếp theo (chưa làm)

1. Dựng tilemap / sprite 2.5D cho Xóm Trọ Cũ + Chợ Đầu Mối (asset CC0, ghi rõ nguồn —
   không dùng asset có bản quyền, không copy asset của Treasure of Nadia).
2. Dựng Canvas điện thoại (9 tab) + nút tương tác, gắn vào `PhoneHubView`.
3. Mở project bằng Unity 2022.3.62f1 thật và Play scene slice (VM này không có Unity — chưa verify).

## Quy tắc

- Mọi số liệu gameplay phải khớp `GameBalance.cs` và `docs/gdd.md`.
- Không hardcode số tiền / ngày / EXP ở file khác.
- Số ghi `PROVISIONAL` là số ví dụ chưa chốt — đổi thì sửa ở
  `GameBalance.cs` + docs cùng lúc.
