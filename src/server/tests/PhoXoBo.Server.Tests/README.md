# Test server — Phố Xô Bồ (xUnit, .NET 8)

Test chạy được cho `EconomyLedger` (sổ cái double-entry, C5).
Xem checklist đầy đủ ở `docs/roles-qc.md` §6.

## Chạy

Từ thư mục gốc repo:

```bash
dotnet test src/server/tests/PhoXoBo.Server.Tests/PhoXoBo.Server.Tests.csproj
```

Hoặc vào thư mục test rồi chạy `dotnet test`.

## Giới hạn — CHƯA CHẠY ĐƯỢC trên VM này

VM này không có .NET 8 SDK / `dotnet` nên chưa biên dịch hay chạy được
`dotnet test`. Các test trong `EconomyLedgerTests.cs` là code test thật
(xUnit `[Fact]` / `[Theory]`), đã viết đúng API hiện có trong
`EconomyLedger.cs` — nhưng chưa có bằng chứng chạy PASS cho tới khi có
máy cài .NET 8 SDK. Không bịa kết quả test.

## Test gì

`EconomyLedgerTests.cs` — chỉ test `EconomyLedger.cs`, không test client:

- Lãi tiết kiệm 0,5%/tháng game (`ApplyMonthlyInterest`): 10tr/1 tháng
  = 50.000; các trường hợp 0 ngày / 0 tiết kiệm / chưa đủ tháng = 0, không ghi sổ.
- Sàn đấu giá phí 5% (`AuctionSale`): giá 1tr → người bán nhận 950k,
  phí 50k về hệ thống; phí làm tròn xuống (giá 999 → phí 49).
- `Post()`: chặn Nợ == Có, chặn số tiền <= 0, chặn thiếu
  IdempotencyKey, trùng IdempotencyKey chỉ ghi 1 lần.
- `IsBalanced()`: sổ trống cân bằng, sau nhiều giao dịch vẫn cân bằng.
- Gửi/rút tiết kiệm, góp vốn công ty, tặng tiền qua tài khoản trung gian
  `GiftTransit` (Transit về 0 khi cộng cả 2 người chơi).
- Ranh giới pháp lý: `CashOut` / `LendWithInterest` / `Gamble` /
  `BuyWithRealMoney` phải ném `InvalidOperationException`.
- Hằng số khớp `GameBalance.cs`: lãi 0,005, phí 5, 1 tháng game = 30 ngày
  (PROVISIONAL, GDD chưa chốt).

Không có test cho "bỏ bê 7 ngày" / "+20% EXP": 2 số đó thuộc `Social.cs`
(client), chưa có API server nên không bịa API để test.

## Kiểm tra tĩnh (chạy được ngay trên VM này)

```bash
python3 src/server/tests/check_static.py
```

Script tĩnh quét cả `src/server/src/*.cs` (ngoặc, số chốt, ranh giới pháp lý,
secret) — nhưng không biên dịch test xUnit. Kết quả ghi vào
`docs/test-report.md`.
