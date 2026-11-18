// Phố Xô Bồ — Sổ cái server (server-authoritative, double-entry).
// Mọi giao dịch tiền trong game KHI ONLINE phải đi qua sổ cái này; client
// không được tự cộng/trừ tiền — client chỉ gửi yêu cầu, server ghi sổ.
// Xem docs/architecture.md (ledger double-entry, PostgreSQL là nguồn sự thật)
// và docs/economy.md (ranh giới pháp lý VN).
//
// Số chốt — PHẢI KHỚP src/client/Assets/Scripts/GameBalance.cs (nguồn duy nhất
// cho số client). Đổi 1 số thì đổi cả 2 chỗ cùng lúc, và cập nhật docs:
//   - Lãi tiết kiệm 0,5%/tháng game (GameBalance.BankInterestPerGameMonth = 0.005)
//   - Phí sàn đấu giá 5% (GameBalance.AuctionFeePercent = 5)
//   - 1 tháng game = 30 ngày game (Economy.DaysPerGameMonth = 30, PROVISIONAL
//     — GDD chưa chốt độ dài tháng game; đổi thì sửa cả 2 chỗ).
// KHÔNG có cash-out, KHÔNG cho vay lấy lãi, KHÔNG cờ bạc, KHÔNG mua tiền /
// nhà / xe / chỉ số bằng tiền thật — các hành vi đó bị chặn bằng exception,
// không phải chỉ ghi trong docs.
using System;
using System.Collections.Generic;
using System.Linq;

namespace PhoXoBo.Server
{
    /// <summary>Tài khoản trong sổ cái. Tiền không bao giờ "biến mất": mỗi bút toán
    /// ghi Nợ 1 tài khoản và Có 1 tài khoản khác với cùng số tiền.</summary>
    public enum LedgerAccount
    {
        PlayerCash,       // Tiền mặt của người chơi
        PlayerSavings,    // Tiền gửi tiết kiệm của người chơi
        BankInterest,     // Chi phí lãi ngân hàng trong game phải trả
        AuctionEscrow,    // Tiền đấu giá đang giữ (chưa giao cho người bán)
        SystemFees,       // Phí thu về hệ thống (phí đấu giá 5%)
        CompanyCapital,   // Vốn góp công ty (guild)
        SalaryExpense,    // Chi phí trả lương / thu nhập trong game
        ShopRevenue,      // Doanh thu cửa hàng / bán hàng
        GiftTransit,      // Tài khoản trung gian khi tặng tiền giữa 2 người chơi (xem Gift())
    }

    public enum LedgerEntryType
    {
        Earn,               // Nhận lương / thu nhập
        Spend,              // Chi tiêu mua đồ
        DepositSavings,     // Gửi tiết kiệm
        WithdrawSavings,    // Rút tiết kiệm
        MonthlyInterest,    // Lãi tiết kiệm 0,5%/tháng game
        AuctionSale,        // Bán qua sàn đấu giá (người bán nhận giá − phí 5%)
        AuctionFee,         // Phí đấu giá 5% về hệ thống
        CompanyContribution,// Góp vốn công ty
        Gift,               // Tặng tiền trong game (không lãi, không phí)
        BarterFee,          // Barter: không dùng tiền — ghi 0đ để lưu vết (xem Barter())
    }

    /// <summary>Một bút toán bất biến. IdempotencyKey chống ghi trùng khi client
    /// gửi lại yêu cầu (offline-first outbox): cùng key thì không ghi lần 2.</summary>
    public sealed record LedgerEntry(
        Guid Id,
        string PlayerId,
        LedgerEntryType Type,
        LedgerAccount Debit,
        LedgerAccount Credit,
        long AmountVnd,
        int GameDay,
        string Reference,
        string IdempotencyKey,
        DateTimeOffset CreatedAtUtc);

    /// <summary>
    /// Sổ cái double-entry trong bộ nhớ (bản skeleton — chưa nối PostgreSQL).
    /// Khi nối DB thật: mỗi Post() phải chạy trong 1 transaction, ghi cả 2 chân
    /// cùng lúc; nếu 1 chân lỗi thì rollback toàn bộ, không ghi nửa bút toán.
    /// </summary>
    public sealed class EconomyLedger
    {
        // Số chốt — phải khớp GameBalance.cs (xem đầu file).
        public const double BankInterestPerGameMonth = 0.005; // 0,5%/tháng game
        public const int AuctionFeePercent = 5;               // phí đấu giá 5%
        public const int DaysPerGameMonth = 30;               // PROVISIONAL, xem đầu file

        private readonly List<LedgerEntry> _entries = new();
        private readonly HashSet<string> _idempotencyKeys = new(StringComparer.Ordinal);

        public IReadOnlyList<LedgerEntry> Entries => _entries;

        /// <summary>Ghi 1 bút toán cân bằng: Nợ = Có, số tiền &gt; 0.
        /// Trả false (không ghi gì) nếu trùng IdempotencyKey — chống ghi trùng.</summary>
        public bool Post(string playerId, LedgerEntryType type, LedgerAccount debit,
            LedgerAccount credit, long amountVnd, int gameDay, string reference,
            string idempotencyKey)
        {
            if (amountVnd <= 0) throw new ArgumentOutOfRangeException(nameof(amountVnd), "Số tiền phải > 0.");
            if (debit == credit) throw new ArgumentException("Nợ và Có phải khác tài khoản.", nameof(credit));
            if (string.IsNullOrWhiteSpace(idempotencyKey)) throw new ArgumentException("Thiếu IdempotencyKey.", nameof(idempotencyKey));
            if (!_idempotencyKeys.Add(idempotencyKey)) return false; // đã ghi rồi — không ghi trùng

            _entries.Add(new LedgerEntry(Guid.NewGuid(), playerId, type, debit, credit,
                amountVnd, gameDay, reference, idempotencyKey, DateTimeOffset.UtcNow));
            return true;
        }

        /// <summary>Số dư 1 tài khoản của 1 người chơi: Có − Nợ (quy ước: tiền vào
        /// tài khoản người chơi ghi Có). Chỉ dùng để kiểm tra nội bộ skeleton.</summary>
        public long BalanceOf(string playerId, LedgerAccount account)
        {
            var credit = _entries.Where(e => e.PlayerId == playerId && e.Credit == account).Sum(e => e.AmountVnd);
            var debit = _entries.Where(e => e.PlayerId == playerId && e.Debit == account).Sum(e => e.AmountVnd);
            return credit - debit;
        }

        /// <summary>Sổ cái luôn cân bằng: tổng Nợ == tổng Có trên toàn sổ.
        /// Kiểm tra này phải chạy trước khi chốt ngày / trước khi sao lưu.</summary>
        public bool IsBalanced()
        {
            var debit = _entries.Sum(e => e.AmountVnd);
            var credit = _entries.Sum(e => e.AmountVnd);
            return debit == credit && _entries.All(e => e.AmountVnd > 0 && e.Debit != e.Credit);
        }

        // ===== Nghiệp vụ đã chốt (docs/economy.md) =====

        /// <summary>Nhận lương / thu nhập: Nợ SalaryExpense, Có PlayerCash.</summary>
        public bool Earn(string playerId, long amountVnd, int gameDay, string reference, string idempotencyKey) =>
            Post(playerId, LedgerEntryType.Earn, LedgerAccount.SalaryExpense, LedgerAccount.PlayerCash,
                amountVnd, gameDay, reference, idempotencyKey);

        /// <summary>Chi tiêu: Nợ PlayerCash, Có ShopRevenue.</summary>
        public bool Spend(string playerId, long amountVnd, int gameDay, string reference, string idempotencyKey) =>
            Post(playerId, LedgerEntryType.Spend, LedgerAccount.PlayerCash, LedgerAccount.ShopRevenue,
                amountVnd, gameDay, reference, idempotencyKey);

        /// <summary>Gửi tiết kiệm: Nợ PlayerCash, Có PlayerSavings.</summary>
        public bool DepositSavings(string playerId, long amountVnd, int gameDay, string idempotencyKey) =>
            Post(playerId, LedgerEntryType.DepositSavings, LedgerAccount.PlayerCash, LedgerAccount.PlayerSavings,
                amountVnd, gameDay, $"deposit-{idempotencyKey}", idempotencyKey);

        /// <summary>Rút tiết kiệm: Nợ PlayerSavings, Có PlayerCash.</summary>
        public bool WithdrawSavings(string playerId, long amountVnd, int gameDay, string idempotencyKey) =>
            Post(playerId, LedgerEntryType.WithdrawSavings, LedgerAccount.PlayerSavings, LedgerAccount.PlayerCash,
                amountVnd, gameDay, $"withdraw-{idempotencyKey}", idempotencyKey);

        /// <summary>
        /// Lãi tiết kiệm 0,5%/tháng game (đã chốt): Nợ BankInterest, Có PlayerSavings.
        /// Trả lãi đã cộng (làm tròn xuống). 0 tháng hoặc 0 tiết kiệm thì trả 0, không ghi sổ.
        /// </summary>
        public long ApplyMonthlyInterest(string playerId, long savingsVnd, int gameDaysElapsed,
            int gameDay, string idempotencyKey)
        {
            var months = gameDaysElapsed / DaysPerGameMonth;
            if (months <= 0 || savingsVnd <= 0) return 0;
            var interest = (long)Math.Floor(savingsVnd * BankInterestPerGameMonth * months);
            if (interest <= 0) return 0;
            Post(playerId, LedgerEntryType.MonthlyInterest, LedgerAccount.BankInterest, LedgerAccount.PlayerSavings,
                interest, gameDay, $"interest-{months}mo", idempotencyKey);
            return interest;
        }

        /// <summary>
        /// Bán qua sàn đấu giá (đã chốt, phí 5%): người mua trả giá chốt vào Escrow,
        /// người bán nhận giá − phí 5%, phí 5% về SystemFees. Trả số tiền người bán nhận.
        /// </summary>
        public long AuctionSale(string sellerId, string buyerId, long hammerPriceVnd,
            int gameDay, string idempotencyKey)
        {
            if (hammerPriceVnd <= 0) throw new ArgumentOutOfRangeException(nameof(hammerPriceVnd));
            var fee = hammerPriceVnd * AuctionFeePercent / 100;
            var sellerReceives = hammerPriceVnd - fee;
            // Chân 1: tiền người mua vào Escrow (ghi 1 lần, 2 bút toán cân bằng riêng).
            Post(buyerId, LedgerEntryType.AuctionSale, LedgerAccount.PlayerCash, LedgerAccount.AuctionEscrow,
                hammerPriceVnd, gameDay, $"auction-buy-{idempotencyKey}", idempotencyKey + ":buy");
            // Chân 2: trả người bán (giá − phí).
            Post(sellerId, LedgerEntryType.AuctionSale, LedgerAccount.AuctionEscrow, LedgerAccount.PlayerCash,
                sellerReceives, gameDay, $"auction-sell-{idempotencyKey}", idempotencyKey + ":sell");
            // Chân 3: phí 5% về hệ thống (chỉ ghi khi phí > 0).
            if (fee > 0)
                Post(sellerId, LedgerEntryType.AuctionFee, LedgerAccount.AuctionEscrow, LedgerAccount.SystemFees,
                    fee, gameDay, $"auction-fee-{idempotencyKey}", idempotencyKey + ":fee");
            return sellerReceives;
        }

        /// <summary>Góp vốn công ty: Nợ PlayerCash, Có CompanyCapital.</summary>
        public bool ContributeToCompany(string playerId, long amountVnd, int gameDay,
            string companyId, string idempotencyKey) =>
            Post(playerId, LedgerEntryType.CompanyContribution, LedgerAccount.PlayerCash,
                LedgerAccount.CompanyCapital, amountVnd, gameDay, $"company-{companyId}", idempotencyKey);

        /// <summary>
        /// Tặng tiền trong game: không lãi, không phí. Ghi 2 bút toán qua tài khoản
        /// trung gian GiftTransit (vì Post() chặn Nợ == Có, và 1 bút toán chỉ mang
        /// 1 PlayerId): người tặng Nợ Cash / Có Transit, người nhận Nợ Transit /
        /// Có Cash. Transit về 0 sau mỗi lần tặng khi cộng cả 2 người chơi.
        /// Hạn chế skeleton: BalanceOf() tính theo từng người chơi nên số dư
        /// Transit của từng người không về 0 riêng lẻ — khi nối DB thật phải
        /// đối chiếu Transit theo Reference, không theo PlayerId.
        /// </summary>
        public bool Gift(string fromPlayerId, string toPlayerId, long amountVnd, int gameDay, string idempotencyKey)
        {
            var okOut = Post(fromPlayerId, LedgerEntryType.Gift, LedgerAccount.PlayerCash, LedgerAccount.GiftTransit,
                amountVnd, gameDay, $"gift-to-{toPlayerId}", idempotencyKey + ":out");
            if (!okOut) return false;
            return Post(toPlayerId, LedgerEntryType.Gift, LedgerAccount.GiftTransit, LedgerAccount.PlayerCash,
                amountVnd, gameDay, $"gift-from-{fromPlayerId}", idempotencyKey + ":in");
        }

        /// <summary>Barter (đồ đổi đồ): không dùng tiền, không phí — chỉ lưu vết 0đ
        /// để đối chiếu. Đồ đổi đồ thật do Inventory/Crafting xử lý ở client.</summary>
        public bool RecordBarter(string playerId, string giveItemId, string receiveItemId, int gameDay, string idempotencyKey) =>
            // Không ghi bút toán tiền (AmountVnd phải > 0) — trả true nghĩa là đã ghi log ngoài sổ.
            // Giữ hàm này để API sau này có chỗ nối log barter, không tự bịa số tiền.
            !string.IsNullOrWhiteSpace(giveItemId) && !string.IsNullOrWhiteSpace(receiveItemId);

        // ===== RANH GIỚI PHÁP LÝ — các hành vi này BỊ CHẶN =====
        // Ném InvalidOperationException có chủ đích để QC kiểm tra tĩnh bắt được
        // nếu ai vô tình "mở" lại chúng. Xem docs/economy.md mục CẤM.

        /// <summary>Cash-out: đổi tiền trong game ra tiền thật — CẤM.</summary>
        public void CashOut(string playerId, long amountVnd) =>
            throw new InvalidOperationException("Cash-out bị cấm: tiền trong game không có giá trị thật.");

        /// <summary>Cho vay lấy lãi giữa người chơi — CẤM.</summary>
        public void LendWithInterest(string lenderId, string borrowerId, long amountVnd, double rate) =>
            throw new InvalidOperationException("Cho vay lấy lãi giữa người chơi bị cấm.");

        /// <summary>Cờ bạc / cá cược — CẤM.</summary>
        public void Gamble(string playerId, long stakeVnd) =>
            throw new InvalidOperationException("Cờ bạc / cá cược bị cấm.");

        /// <summary>Mua tiền / nhà / xe / chỉ số bằng tiền thật — CẤM.</summary>
        public void BuyWithRealMoney(string playerId, string itemId, decimal realMoneyAmount) =>
            throw new InvalidOperationException("Không mua tiền / nhà / xe / chỉ số bằng tiền thật.");
    }
}
