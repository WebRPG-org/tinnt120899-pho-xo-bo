# Báo cáo kiểm tra — Phố Xô Bồ

> **Đây là kiểm tra TĨNH, chưa phải build / test chạy được.**
> VM này không có dotnet / Unity / csc nên không biên dịch được code C#,
> không chạy được server, không chơi được game. Báo cáo này chỉ chứng minh:
> ngoặc cân bằng, số chốt khớp nhau giữa code và docs, không có secret,
> ranh giới pháp lý bị chặn trong code. Muốn test chạy được thật phải có
> máy build (xem `docs/roles-qc.md` §6).

## Lần chạy mới nhất: 18/11/2026 ~17:00 (giờ VN)

- Lệnh: `python3 src/server/tests/check_static.py` (chạy từ gốc repo)
- Kết quả: **66/66 PASS, exit 0** — không vỡ kiểm tra cũ.
- **Luồng A — sửa phát hiện `Stats` (đã ghi ở lần ~15:55, nay đã sửa bằng code):**
  `Stats.cs` thêm factory `Stats.WithValues(the, tri, tam)` — tạo `Stats` với
  giá trị tùy ý, không yêu cầu tổng = 300 (PROVISIONAL); từng chỉ số vẫn kẹp
  0..100; ctor chính giữ nguyên (tổng phải = 300). `JobsPayTests.cs` từ 16
  lên **28 test method** (+12): hệ số lương mốc 50 (1.0) và mốc 0 (sàn 0.5)
  cho cả 3 nghề slice, nhân khung tốt + thiếu người, làm tròn xuống, kiểm tra
  độ dốc tuyến tính mốc 60, `WithValues` kẹp giá trị, và `Stats.Train` đánh
  đổi thật qua `WithValues`. Mốc 50/0 khớp đúng công thức `Jobs.cs`
  (`max(0.5, 1.0 + (chỉ số − 50) × 0.01)`), không bịa số mới.
- **Luồng B — khung Unity C1 (file-level, chưa verify mở bằng Unity):**
  `src/client/ProjectSettings/` thêm 10 file `.asset` tối thiểu
  (ProjectSettings, EditorSettings, GraphicsSettings — đã khóa hằng isometric
  `TransparencySortAxis (0, 1, −0.26)`, QualitySettings 6 mức, TagManager,
  TimeManager, Physics2DSettings, DynamicsManager, AudioManager,
  NavMeshAreas) + scene `Assets/Scenes/SliceXomTroCu.unity` (camera ortho,
  nền vàng nắng #F9EDCE, GO `SliceRoot`, chưa có art). Đã có sẵn từ trước:
  `ProjectVersion.txt` 2022.3.62f1, `Packages/manifest.json` (test-framework
  1.1.33), `Assets/Scenes/Main.unity`, `.gitignore` đủ Library/Temp/Logs.
  **Chưa verify:** Unity lần đầu mở còn phải sinh `Library/`, `*.csproj`
  (C3), `.meta` thư mục, `InputManager.asset` / `EditorBuildSettings.asset`
  và chuẩn hóa lại các `.asset` tối thiểu — cần máy có Unity 2022.3.62f1.
- **Vẫn chưa chạy được:** 28 test EditMode + 17 test xUnit vẫn chưa biên dịch/
  chạy lần nào (VM không có dotnet/Unity). `TimeSystem` không wrap quá 30
  phút vẫn chưa có chốt GDD — giữ nguyên, không coi là bug.

## Lần chạy mới nhất: 18/11/2026 ~15:55 (giờ VN)

- Lệnh: `python3 src/server/tests/check_static.py` (chạy từ gốc repo)
- Kết quả: **66/66 PASS, exit 0** — tăng từ 53/53: nhóm T8 mới quét file
  server (13 mục: ngoặc Program.cs + EconomyLedger.cs, số chốt khớp
  GameBalance, 4 hàm cấm ném exception, secret, UTF-8) + 2 mục T8h/T8i
  (Program.cs đăng ký EconomyLedger singleton, giữ endpoint /health).

### Chuẩn bị C5/C6 trong đợt này (code test thật, CHƯA chạy được)

- **C5 — test xUnit server:** `src/server/tests/PhoXoBo.Server.Tests/`
  (`PhoXoBo.Server.Tests.csproj` net8.0, xUnit 2.9.2; `EconomyLedgerTests.cs`
  256 dòng, 17 test: lãi 0,5%, phí đấu giá 5%, chặn Nợ == Có / trùng
  IdempotencyKey / số tiền ≤ 0, IsBalanced, Gift qua GiftTransit, 4 hàm cấm
  ném InvalidOperationException). Không có test bỏ bê 7 ngày / +20% EXP vì
  2 số đó thuộc `Social.cs` (client), chưa có API server — không bịa API.
  `Program.cs` (26 → 66 dòng): đăng ký `EconomyLedger` singleton + endpoint
  `GET /ledger/balance/{playerId}` và `POST /ledger/gift` (200/409/400);
  `/health` giữ nguyên; ledger vẫn in-memory, endpoint gift chưa có auth.
- **C6 — test EditMode Unity:** `src/client/Assets/Tests/EditMode/`
  (`JobsPayTests.cs` 190 dòng, 16 test; `TimeSystemTests.cs` 99 dòng,
  10 test) + `PhoXoBo.asmdef` mới cho Scripts (trước đây chưa có asmdef nên
  test không tham chiếu được) + `EditMode.asmdef`. `manifest.json` đã có sẵn
  `com.unity.test-framework 1.1.33` (bản đi kèm Unity 2022 LTS), không sửa.
- **Phát hiện khi viết test (đã ghi, chưa sửa code):** `Stats` chỉ khởi tạo
  được (100,100,100) nên hệ số lương ở mốc 50/0 chưa test được qua API công
  khai; `Stats.Train` từ trạng thái max luôn trả false; `TimeSystem.CurrentFrame`
  không wrap khi elapsed vượt 30 phút (chưa có chốt GDD về wrap, không coi là bug).
- **Chưa chạy được:** VM không có dotnet/Unity nên xUnit và EditMode test
  chưa biên dịch/chạy lần nào — phải chạy `dotnet test` và Unity Test Runner
  trên máy có .NET 8 SDK + Unity 2022.3.62f1 trước khi coi C5/C6 là xong.

## Lần chạy trước: 18/11/2026 ~14:44 (giờ VN)

- Lệnh: `python3 src/server/tests/check_static.py` (chạy từ gốc repo)
- Kết quả: **53/53 PASS, exit 0**
- File kiểm tra: 13 file `.cs` trong `src/client/Assets/Scripts/`
  (gồm `PlayerProgress.cs` — file này do một luồng làm song song thêm vào
  và đã push riêng commit `13761c8f` lúc 14:42, không thuộc đợt này).

### Chi tiết 53 mục

| Nhóm | Mục | Kết quả |
|------|-----|---------|
| T1 — Ngoặc cân bằng (13 file .cs) | Crafting, District, Economy, Exploration, GameBalance, Inventory, Jobs, PhoneHub, PlayerProgress, Social, Stats, TimeSystem, TitleConflict | 13/13 PASS |
| T2 — Số chốt khớp GameBalance ↔ docs | 18 khu (District.cs 18 entry + docs), 5 bậc học, học phí 20/80/200/500tr, lãi 0,5%, phí 5%, bỏ bê 7 ngày, +20% EXP, solo 30–50%, mua lớn +50 Danh vọng, thang nhà 6 bậc, rank Chương 5 (10 tỉ / 100 tỉ / An Yên 80), GDD nhắc đủ lãi/phí/bỏ bê/+20% EXP | 28/28 PASS |
| T3 — Social/Economy dùng đúng hằng | Dùng `NeglectDaysToDropCloseness`, `SupportedExpBonusPercent`, `BankInterestPerGameMonth`, `AuctionFeePercent`, `BigPurchaseFameBonus`; không hardcode số chốt | 7/7 PASS |
| T4 — Secret | Không có password / api-key / secret / token / private key trong file .cs | PASS |
| T5 — Ranh giới pháp lý | `CashOut`, `LendWithInterest`, `Gamble`, `BuyWithRealMoney` trong `Economy.cs` luôn trả `false` | 4/4 PASS |
| T6 — Assets | `assets/` trống — chưa đưa asset nào vào, không asset lậu | PASS |
| T7 — Encoding | Mọi file .cs đều UTF-8 | PASS |

### 2 lỗi gặp trong lần chạy đầu (đã sửa, chạy lại PASS)

1. **T2a FAIL lúc đầu — lỗi ở script kiểm tra, không phải ở code:**
   `District.cs` dùng target-typed `new(1, "Xóm Trọ Cũ", ...)` nên regex
   `new District(` đếm được 0 entry. Đã sửa regex đếm `new(số, "tên", Tier)`.
2. **T2o FAIL lúc đầu — lỗi thật ở docs:** GDD Mục 7 chỉ ghi "Xem
   `docs/economy.md`" mà không nhắc lãi 0,5%/tháng. Đã bổ sung 1 dòng vào
   GDD Mục 7 ghi rõ lãi 0,5%, phí 5%, mua lớn +50 Danh vọng (số đã chốt
   sẵn trong `GameBalance.cs` / `economy.md`, không phải số mới).

### Lần chạy đầu cũng phát hiện 1 lỗi script khác (đã sửa)

- `check_static.py` tính sai thư mục gốc (`parents[2]` ra `src/` thay vì
  repo) → `FileNotFoundError`. Đã sửa thành `parents[3]`.

## Lần chạy bổ sung — EconomyLedger (server), 18/11/2026 ~14:45 (giờ VN)

> Luồng song song 3 (server + test). File mới: `src/server/src/EconomyLedger.cs`
> (228 dòng) — sổ cái double-entry server-authoritative: mỗi bút toán Nợ 1 tài
> khoản / Có 1 tài khoản khác, cùng số tiền; `Post()` chặn Nợ == Có và chặn
> ghi trùng bằng IdempotencyKey; `IsBalanced()` kiểm tra tổng Nợ == tổng Có.

- Lệnh: `python3 src/server/tests/check_static.py` (chạy lại từ gốc repo)
- Kết quả: **53/53 PASS, exit 0** — không vỡ kiểm tra cũ.
- Kiểm tra riêng file server mới (script kiểm tra trong `/tmp`, không commit
  vào repo vì `check_static.py` hiện chỉ quét file `.cs` client):
  **18/18 PASS**, gồm:
  - L1 — Ngoặc cân bằng `EconomyLedger.cs`: `{}` 10/10, `()` 67/67, `[]` 0/0.
  - L2 — Số chốt khớp `GameBalance.cs`: lãi 0,5% (`0.005`), phí đấu giá 5%,
    1 tháng game = 30 ngày (PROVISIONAL, khớp `Economy.cs`).
  - L3 — `Post()` chặn Nợ == Có; chặn trùng IdempotencyKey; `IsBalanced()`;
    `AuctionSale` tính phí `hammer * 5 / 100`, người bán nhận `hammer − phí`;
    `Gift()` đi qua tài khoản trung gian `GiftTransit`, không Post cùng tài
    khoản; `ApplyMonthlyInterest` dùng đúng `BankInterestPerGameMonth`.
  - L4 — Ranh giới pháp lý: `CashOut`, `LendWithInterest`, `Gamble`,
    `BuyWithRealMoney` đều bị chặn bằng `throw InvalidOperationException`.
  - L5/L6 — Không có secret; file UTF-8.
- **1 lỗi thật phát hiện khi viết code, đã sửa trước khi kiểm tra:** bản nháp
  `Gift()` gọi `Post(..., PlayerCash, PlayerCash, ...)` — `Post()` chặn Nợ ==
  Có nên sẽ ném lỗi. Đã sửa bằng tài khoản trung gian `GiftTransit` (người
  tặng Nợ Cash / Có Transit, người nhận Nợ Transit / Có Cash). Hạn chế
  skeleton đã ghi trong comment: `BalanceOf()` tính theo từng người chơi nên
  số dư Transit của từng người không về 0 riêng lẻ — khi nối DB thật phải đối
  chiếu Transit theo Reference, không theo PlayerId.
- Chưa làm trong đợt này: `EconomyLedger` chưa được `Program.cs` gọi (server
  vẫn chỉ có `GET /health`), chưa nối PostgreSQL, chưa có test xUnit chạy
  được — vẫn là kiểm tra tĩnh, chưa phải build/test chạy được.

## Hiện trạng thật (18/11/2026, lúc viết báo cáo này)

- Code: 13 file `.cs` client + server `.NET 8` skeleton (`Program.cs`,
  `GET /health`, ghi rõ `database: not-connected`). **Chưa biên dịch lần nào.**
- Chưa có: Unity project đầy đủ (`.csproj` client, `ProjectSettings/`,
  scene, prefab), asset CC0 nào, test xUnit / Unity Test Framework nào
  **chạy được**, server chạy được, bản chơi được thật.
- Đã có trong đợt này: `Social.cs` (quan hệ, bỏ bê 7 ngày, +20% EXP,
  solo chậm 40% trong khoảng 30–50% đã chốt), `Economy.cs` (ví, lãi 0,5%,
  đấu giá phí 5%, barter, chia tài sản ly hôn, 4 hàm cấm luôn trả false),
  `src/server/tests/check_static.py` + `README.md`, báo cáo này.
- Xem checklist để ra bản test được: `docs/roles-qc.md` §6.

## Hiện trạng thật (18/11/2026 ~15:55, lúc viết báo cáo này)

- Kiểm tra tĩnh: **66/66 PASS** (`check_static.py`, gồm nhóm T8 mới quét
  file server + T8h/T8i nối ledger vào `Program.cs`).
- Chuẩn bị C5: test xUnit server `EconomyLedgerTests.cs` (17 test) +
  `Program.cs` đã nối `EconomyLedger` singleton với 2 endpoint
  `/ledger/balance` + `/ledger/gift`; `/health` giữ nguyên.
- Chuẩn bị C6: test EditMode `JobsPayTests.cs` (16 test) +
  `TimeSystemTests.cs` (10 test) + `PhoXoBo.asmdef` + `EditMode.asmdef`;
  `manifest.json` đã có sẵn test-framework 1.1.33.
- Vẫn chưa chạy được: không có dotnet/Unity trên VM — xUnit và EditMode test
  chưa biên dịch/chạy lần nào; server chưa chạy; client chưa có scene slice
  chơi được. Cần máy có Unity 2022 LTS + .NET 8 SDK để chạy `dotnet test` và
  Unity Test Runner trước khi coi C5/C6 là xong.

## Hiện trạng thật (18/11/2026 ~17:00, lúc viết báo cáo này)

- Kiểm tra tĩnh: **66/66 PASS** (`check_static.py`).
- `Stats.WithValues` đã sửa xong phát hiện "chỉ khởi tạo được (100,100,100)";
  `JobsPayTests.cs` nay 28 test (mốc lương 50/0 đã test được qua API công khai).
- Khung Unity C1 đã có ở mức file (`ProjectSettings/` 10 file `.asset` +
  scene `SliceXomTroCu.unity`); **chưa verify mở bằng Unity** — cần máy có
  Unity 2022.3.62f1 sinh `Library/` + `.csproj` và kiểm tra Play lần đầu.
- Vẫn chưa chạy được: không có dotnet/Unity trên VM — xUnit (17 test) và
  EditMode test (28 + 10 test) chưa biên dịch/chạy lần nào; server chưa chạy;
  client chưa có scene slice chơi được.
