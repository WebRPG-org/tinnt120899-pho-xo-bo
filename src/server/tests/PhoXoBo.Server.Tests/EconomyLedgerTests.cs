// Phố Xô Bồ — Test xUnit cho EconomyLedger (server, C5).
//
// CHƯA CHẠY ĐƯỢC trên VM này: VM không có .NET 8 SDK / dotnet nên chưa biên
// dịch hay chạy được `dotnet test`. File này là code test thật (xUnit), đã
// viết đúng API hiện có trong EconomyLedger.cs — chạy trên máy có .NET 8 SDK
// bằng `dotnet test` từ thư mục gốc repo.
//
// Phạm vi: CHỈ test EconomyLedger.cs (sổ cái double-entry, docs/economy.md).
// Số chốt test ở đây: lãi 0,5%/tháng game, phí đấu giá 5%, 1 tháng game =
// 30 ngày (PROVISIONAL) — phải khớp GameBalance.cs (client).
// "Bỏ bê 7 ngày" (NeglectDaysToDropCloseness) và "+20% EXP"
// (SupportedExpBonusPercent) thuộc Social.cs (client), CHƯA có API server
// nên KHÔNG có test ở đây — không bịa API server cho 2 số đó.
// Ranh giới pháp lý: 4 hàm cấm phải ném InvalidOperationException.
using System;
using System.Linq;
using PhoXoBo.Server;
using Xunit;

namespace PhoXoBo.Server.Tests
{
    public sealed class EconomyLedgerTests
    {
        // ===== Số chốt khớp GameBalance.cs (client) =====

        [Fact]
        public void HangSo_Lai05Phi5Thang30Ngay_KhopGameBalance()
        {
            // GameBalance.cs: BankInterestPerGameMonth = 0.005, AuctionFeePercent = 5.
            // Economy.cs: DaysPerGameMonth = 30 (PROVISIONAL, GDD chưa chốt).
            Assert.Equal(0.005, EconomyLedger.BankInterestPerGameMonth);
            Assert.Equal(5, EconomyLedger.AuctionFeePercent);
            Assert.Equal(30, EconomyLedger.DaysPerGameMonth);
        }

        // ===== Lãi tiết kiệm 0,5%/tháng game =====

        [Fact]
        public void ApplyMonthlyInterest_10Trieu_1Thang_Tra50000()
        {
            var ledger = new EconomyLedger();
            // 10.000.000 * 0,5% * 1 tháng = 50.000, ghi Có vào PlayerSavings.
            var interest = ledger.ApplyMonthlyInterest("p1", 10_000_000, 30, 1, "lai-001");
            Assert.Equal(50_000, interest);
            Assert.Equal(50_000, ledger.BalanceOf("p1", LedgerAccount.PlayerSavings));
            Assert.Single(ledger.Entries);
            Assert.Equal(LedgerEntryType.MonthlyInterest, ledger.Entries[0].Type);
        }

        [Theory]
        // (tiết kiệm, số ngày game, lãi kỳ vọng) — tháng = ngày / 30, làm tròn xuống.
        [InlineData(10_000_000, 30, 50_000)]   // 1 tháng
        [InlineData(10_000_000, 60, 100_000)]  // 2 tháng
        [InlineData(1_000_000, 90, 15_000)]    // 3 tháng: 1tr * 0,5% * 3
        [InlineData(10_000_000, 29, 0)]        // chưa đủ 1 tháng -> 0, không ghi sổ
        [InlineData(10_000_000, 0, 0)]         // 0 ngày -> 0
        [InlineData(0, 30, 0)]                 // 0 tiết kiệm -> 0
        public void ApplyMonthlyInterest_CacTruongHop_TraDungLai(
            long savingsVnd, int gameDaysElapsed, long expectedInterest)
        {
            var ledger = new EconomyLedger();
            var interest = ledger.ApplyMonthlyInterest("p1", savingsVnd, gameDaysElapsed, 1, "lai-theory");
            Assert.Equal(expectedInterest, interest);
            if (expectedInterest == 0)
                Assert.Empty(ledger.Entries); // 0 lãi thì không ghi bút toán nào
            else
                Assert.Equal(expectedInterest, ledger.BalanceOf("p1", LedgerAccount.PlayerSavings));
        }

        // ===== Sàn đấu giá: phí 5%, người bán nhận giá − phí =====

        [Fact]
        public void AuctionSale_Gia1Trieu_NguoiBanNhan950Nghin_Phi50Nghin()
        {
            var ledger = new EconomyLedger();
            var sellerReceives = ledger.AuctionSale("ban", "mua", 1_000_000, 1, "dau-gia-001");
            Assert.Equal(950_000, sellerReceives); // 1.000.000 − phí 5% (50.000)
            Assert.Equal(950_000, ledger.BalanceOf("ban", LedgerAccount.PlayerCash));
            Assert.Equal(50_000, ledger.BalanceOf("ban", LedgerAccount.SystemFees));
            Assert.Equal(-1_000_000, ledger.BalanceOf("mua", LedgerAccount.PlayerCash));
            Assert.Equal(3, ledger.Entries.Count); // mua vào Escrow, trả người bán, phí hệ thống
            Assert.True(ledger.IsBalanced());
        }

        [Fact]
        public void AuctionSale_Gia999_PhiLamTronXuong_NguoiBanNhan950()
        {
            var ledger = new EconomyLedger();
            // Phí = 999 * 5 / 100 = 49 (chia nguyên, làm tròn xuống), người bán nhận 950.
            var sellerReceives = ledger.AuctionSale("ban", "mua", 999, 1, "dau-gia-002");
            Assert.Equal(950, sellerReceives);
            Assert.Equal(49, ledger.BalanceOf("ban", LedgerAccount.SystemFees));
        }

        [Fact]
        public void AuctionSale_GiaKhongDuong_NemLoi()
        {
            var ledger = new EconomyLedger();
            Assert.Throws<ArgumentOutOfRangeException>(
                () => ledger.AuctionSale("ban", "mua", 0, 1, "dau-gia-003"));
        }

        // ===== Post(): chặn Nợ == Có, chặn số tiền <= 0, chặn trùng key =====

        [Fact]
        public void Post_NoBangCo_NemArgumentException()
        {
            var ledger = new EconomyLedger();
            Assert.Throws<ArgumentException>(() => ledger.Post(
                "p1", LedgerEntryType.Earn, LedgerAccount.PlayerCash, LedgerAccount.PlayerCash,
                1_000, 1, "ref", "key-001"));
        }

        [Theory]
        [InlineData(0)]
        [InlineData(-100)]
        public void Post_SoTienKhongDuong_NemArgumentOutOfRange(long amountVnd)
        {
            var ledger = new EconomyLedger();
            Assert.Throws<ArgumentOutOfRangeException>(() => ledger.Post(
                "p1", LedgerEntryType.Earn, LedgerAccount.SalaryExpense, LedgerAccount.PlayerCash,
                amountVnd, 1, "ref", "key-002"));
        }

        [Fact]
        public void Post_ThieuIdempotencyKey_NemArgumentException()
        {
            var ledger = new EconomyLedger();
            Assert.Throws<ArgumentException>(() => ledger.Post(
                "p1", LedgerEntryType.Earn, LedgerAccount.SalaryExpense, LedgerAccount.PlayerCash,
                1_000, 1, "ref", ""));
        }

        [Fact]
        public void Post_TrungIdempotencyKey_ChiGhi1Lan()
        {
            var ledger = new EconomyLedger();
            // Client gửi lại yêu cầu (offline-first outbox): cùng key thì không ghi lần 2.
            var first = ledger.Earn("p1", 1_000_000, 1, "luong", "luong-001");
            var second = ledger.Earn("p1", 1_000_000, 1, "luong", "luong-001");
            Assert.True(first);
            Assert.False(second);
            Assert.Single(ledger.Entries);
            Assert.Equal(1_000_000, ledger.BalanceOf("p1", LedgerAccount.PlayerCash));
        }

        // ===== Sổ cái luôn cân bằng: tổng Nợ == tổng Có =====

        [Fact]
        public void IsBalanced_SoTrong_CanBang()
        {
            Assert.True(new EconomyLedger().IsBalanced());
        }

        [Fact]
        public void IsBalanced_SauNhieuGiaoDich_VanCanBang()
        {
            var ledger = new EconomyLedger();
            ledger.Earn("p1", 5_000_000, 1, "luong", "cb-001");
            ledger.Spend("p1", 2_000_000, 1, "mua-do", "cb-002");
            ledger.DepositSavings("p1", 1_000_000, 1, "cb-003");
            ledger.WithdrawSavings("p1", 500_000, 1, "cb-004");
            ledger.ContributeToCompany("p1", 500_000, 1, "cty-1", "cb-005");
            ledger.ApplyMonthlyInterest("p1", 500_000, 30, 2, "cb-006");
            Assert.True(ledger.IsBalanced());
            Assert.All(ledger.Entries, e => Assert.True(e.AmountVnd > 0 && e.Debit != e.Credit));
        }

        // ===== Gửi / rút tiết kiệm =====

        [Fact]
        public void DepositRutTietKiem_SoDuDung()
        {
            var ledger = new EconomyLedger();
            ledger.Earn("p1", 1_000_000, 1, "luong", "tk-001");
            ledger.DepositSavings("p1", 400_000, 1, "tk-002");
            Assert.Equal(600_000, ledger.BalanceOf("p1", LedgerAccount.PlayerCash));
            Assert.Equal(400_000, ledger.BalanceOf("p1", LedgerAccount.PlayerSavings));
            ledger.WithdrawSavings("p1", 100_000, 1, "tk-003");
            Assert.Equal(700_000, ledger.BalanceOf("p1", LedgerAccount.PlayerCash));
            Assert.Equal(300_000, ledger.BalanceOf("p1", LedgerAccount.PlayerSavings));
        }

        [Fact]
        public void ContributeToCompany_VonVaoCongTy()
        {
            var ledger = new EconomyLedger();
            ledger.Earn("p1", 1_000_000, 1, "luong", "cty-001");
            Assert.True(ledger.ContributeToCompany("p1", 200_000, 1, "cty-1", "cty-002"));
            Assert.Equal(800_000, ledger.BalanceOf("p1", LedgerAccount.PlayerCash));
            Assert.Equal(200_000, ledger.BalanceOf("p1", LedgerAccount.CompanyCapital));
        }

        // ===== Tặng tiền qua tài khoản trung gian GiftTransit =====

        [Fact]
        public void Gift_QuaTaiKhoanTrungGian_TienChuyenDungNguoi()
        {
            var ledger = new EconomyLedger();
            var ok = ledger.Gift("a", "b", 100_000, 1, "tang-001");
            Assert.True(ok);
            Assert.Equal(2, ledger.Entries.Count); // a -> Transit, Transit -> b
            Assert.All(ledger.Entries, e => Assert.Equal(LedgerEntryType.Gift, e.Type));
            // Người tặng mất 100k tiền mặt, người nhận được 100k tiền mặt.
            Assert.Equal(-100_000, ledger.BalanceOf("a", LedgerAccount.PlayerCash));
            Assert.Equal(100_000, ledger.BalanceOf("b", LedgerAccount.PlayerCash));
            // Transit về 0 khi cộng cả 2 người chơi (xem ghi chú trong Gift()).
            var transitTotal = ledger.BalanceOf("a", LedgerAccount.GiftTransit)
                + ledger.BalanceOf("b", LedgerAccount.GiftTransit);
            Assert.Equal(0, transitTotal);
            Assert.True(ledger.IsBalanced());
        }

        [Fact]
        public void Gift_TrungIdempotencyKey_KhongTangLan2()
        {
            var ledger = new EconomyLedger();
            Assert.True(ledger.Gift("a", "b", 100_000, 1, "tang-002"));
            Assert.False(ledger.Gift("a", "b", 100_000, 1, "tang-002"));
            Assert.Equal(2, ledger.Entries.Count);
            Assert.Equal(100_000, ledger.BalanceOf("b", LedgerAccount.PlayerCash));
        }

        // ===== Ranh giới pháp lý — 4 hành vi CẤM phải ném lỗi =====

        [Fact]
        public void CashOut_BiCam_NemInvalidOperationException()
        {
            var ledger = new EconomyLedger();
            Assert.Throws<InvalidOperationException>(() => ledger.CashOut("p1", 1_000_000));
        }

        [Fact]
        public void LendWithInterest_BiCam_NemInvalidOperationException()
        {
            var ledger = new EconomyLedger();
            Assert.Throws<InvalidOperationException>(
                () => ledger.LendWithInterest("a", "b", 1_000_000, 0.1));
        }

        [Fact]
        public void Gamble_BiCam_NemInvalidOperationException()
        {
            var ledger = new EconomyLedger();
            Assert.Throws<InvalidOperationException>(() => ledger.Gamble("p1", 100_000));
        }

        [Fact]
        public void BuyWithRealMoney_BiCam_NemInvalidOperationException()
        {
            var ledger = new EconomyLedger();
            Assert.Throws<InvalidOperationException>(
                () => ledger.BuyWithRealMoney("p1", "biet-thu", 100m));
        }
    }
}
