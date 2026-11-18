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

12 file `*.cs` trong thư mục này là **logic thuần C#** (chỉ dùng
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

## Việc tiếp theo (chưa làm)

1. Viết lớp `MonoBehaviour` mỏng (ví dụ `GameManagerBehaviour`,
   `PhoneHubUI`, `DistrictView`) gọi vào các class logic trên — logic
   không được lẫn code Unity để còn test được ngoài Unity.
2. Dựng tilemap / sprite 2.5D cho Xóm Trọ Cũ (asset CC0, ghi rõ nguồn —
   không dùng asset có bản quyền, không copy asset của Treasure of Nadia).
3. Gắn Cinemachine Virtual Camera theo dõi nhân vật (package đã có trong
   `Packages/manifest.json`).

## Quy tắc

- Mọi số liệu gameplay phải khớp `GameBalance.cs` và `docs/gdd.md`.
- Không hardcode số tiền / ngày / EXP ở file khác.
- Số ghi `PROVISIONAL` là số ví dụ chưa chốt — đổi thì sửa ở
  `GameBalance.cs` + docs cùng lúc.
