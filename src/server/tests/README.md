# Tests — Phố Xô Bồ

> **Chưa có test chạy được.** VM này không có dotnet / Unity / csc nên không
> biên dịch được code C#, không chạy được server, không chơi được game.
> Thư mục này hiện chỉ có **kiểm tra tĩnh** — đọc file và đối chiếu số liệu.

## Chạy kiểm tra tĩnh

Từ thư mục gốc repo:

```bash
python3 src/server/tests/check_static.py
```

Thoát 0 = tất cả PASS, thoát 1 = có FAIL. Kết quả từng lần chạy ghi vào
`docs/test-report.md` (kèm ngày giờ + ghi rõ đây là kiểm tra tĩnh, chưa phải
build/test chạy được).

## Kiểm tra gì

1. Ngoặc `{}` `()` `[]` cân bằng ở mọi file `.cs` (không chứng minh đúng ngữ nghĩa).
2. Số chốt khớp giữa `GameBalance.cs` và docs: 18 khu, 5 bậc học, lãi 0,5%,
   phí đấu giá 5%, bỏ bê 7 ngày, +20% EXP, solo chậm 30–50%, thang nhà 6 bậc,
   rank Chương 5 (10 tỉ / 100 tỉ / An Yên 80).
3. `Social.cs` / `Economy.cs` dùng đúng hằng `GameBalance`, không hardcode số chốt.
4. Không có secret / token / key trong file `.cs`.
5. Ranh giới pháp lý: `CashOut` / `LendWithInterest` / `Gamble` /
   `BuyWithRealMoney` trong `Economy.cs` phải luôn trả `false`.
6. `assets/` trống (chưa có art nào, không asset lậu).

## Để có test chạy được thật (chưa làm được ở đây)

- Máy có .NET 8 SDK → `dotnet test` cho server (cần viết test xUnit, chưa có).
- Máy có Unity 2022 LTS → mở `src/client/`, chạy Play Mode với scene slice,
  test bằng Unity Test Framework (EditMode/PlayMode tests, chưa có).
- Xem checklist đầy đủ ở `docs/roles-qc.md` §6.
