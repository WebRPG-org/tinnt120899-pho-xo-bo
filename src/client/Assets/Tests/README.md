# Tests — Phố Xô Bồ (client Unity)

Test NUnit cho logic thuần C# của client, thuộc checklist C6
(docs/roles-qc.md §6). Chỉ test logic không dùng `UnityEngine` nên chạy
được ở chế độ EditMode, không cần PlayMode.

## Cách chạy (cần Unity 2022.3.62f1 LTS)

1. Mở project `src/client/` bằng Unity Hub.
2. Unity → **Window → General → Test Runner** → tab **EditMode** → **Run All**.
3. Kết quả kỳ vọng: toàn bộ test trong `Assets/Tests/EditMode/` pass.
   Nếu test fail sau khi đổi bảng số, kiểm tra `GameBalance.cs` /
   `Jobs.Definitions` trước — test dùng đúng số trong code, không hardcode
   số khác.

## Giới hạn — CHƯA chạy được trên VM này

VM hiện tại **không có Unity / dotnet** nên các test trong thư mục này
**chưa từng được chạy** — code test được viết theo đúng API thật trong
`Assets/Scripts/` (đã đối chiếu tên hàm, tham số, hằng số) nhưng phải
chạy lại bằng Unity Test Runner trước khi coi C6 là xong.

## Cấu trúc

| File | Test cho |
|---|---|
| `EditMode/EditMode.asmdef` | Assembly test EditMode, tham chiếu `PhoXoBo` + `UnityEngine.TestRunner` |
| `EditMode/JobsPayTests.cs` | `Jobs.PayPerShift` (lương ca), `Jobs.Get`, `WeeklyQuotaTracker` |
| `EditMode/TimeSystemTests.cs` | `TimeSystem` (1 ngày game = 30 phút, 3 khung × 10 phút) |
| `../Scripts/PhoXoBo.asmdef` | Assembly `PhoXoBo` cho toàn bộ script logic (xem dưới) |

## Vì sao có `Scripts/PhoXoBo.asmdef`

Thư mục `Assets/Scripts/` trước đây chưa có `.asmdef` nên code nằm trong
assembly mặc định `Assembly-CSharp`, mà assembly test **không tham chiếu
được**. Đã tạo `PhoXoBo.asmdef` để gom 13 file logic thuần C# thành
assembly có tên `PhoXoBo`, và `EditMode.asmdef` tham chiếu nó.

An toàn khi thêm: đã kiểm tra trước khi tạo — không file `.cs` nào dùng
`UnityEngine`, và `Assets/Scenes/Main.unity` chưa gắn script nào
(0 tham chiếu `MonoBehaviour`), nên việc chuyển assembly không làm vỡ
scene. Lần mở Unity đầu tiên sau khi thêm file này, Unity sẽ biên dịch
lại assembly `PhoXoBo` — nếu có lỗi, xóa `PhoXoBo.asmdef` sẽ trả code
về `Assembly-CSharp` như cũ (khi đó test EditMode không chạy được cho
tới khi tạo lại asmdef).

## Package test-framework

`Packages/manifest.json` **đã có sẵn** `com.unity.test-framework`
phiên bản `1.1.33` (bản đi kèm Unity 2022 LTS) — không cần thêm gì.
