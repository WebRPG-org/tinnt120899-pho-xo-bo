# Báo cáo kiểm tra — Phố Xô Bồ

> **Đây là kiểm tra TĨNH, chưa phải build / test chạy được.**
> VM này không có dotnet / Unity / csc nên không biên dịch được code C#,
> không chạy được server, không chơi được game. Báo cáo này chỉ chứng minh:
> ngoặc cân bằng, số chốt khớp nhau giữa code và docs, không có secret,
> ranh giới pháp lý bị chặn trong code. Muốn test chạy được thật phải có
> máy build (xem `docs/roles-qc.md` §6).

## Lần chạy mới nhất: 18/11/2026 ~14:44 (giờ VN)

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
  scene, prefab), asset CC0 nào, test xUnit / Unity Test Framework nào,
  server chạy được, bản chơi được thật.
- Đã có trong đợt này: `Social.cs` (quan hệ, bỏ bê 7 ngày, +20% EXP,
  solo chậm 40% trong khoảng 30–50% đã chốt), `Economy.cs` (ví, lãi 0,5%,
  đấu giá phí 5%, barter, chia tài sản ly hôn, 4 hàm cấm luôn trả false),
  `src/server/tests/check_static.py` + `README.md`, báo cáo này.
- Xem checklist để ra bản test được: `docs/roles-qc.md` §6.
