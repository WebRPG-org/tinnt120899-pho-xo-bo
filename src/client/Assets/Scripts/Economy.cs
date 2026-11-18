// Phố Xô Bồ — Hệ kinh tế (Mục 7 đã chốt, docs/economy.md)
// Tiền là hub nối mọi hệ: mua tốt hơn → làm / học tốt hơn → kiếm tốt hơn.
// Mỗi nhà / xe / điện thoại / quần áo có 3 dòng chỉ số:
//   (1) cộng chỉ số nhân vật, (2) mở nghề / danh hiệu, (3) set bonus.
// Số chốt dùng đúng GameBalance: lãi tiết kiệm 0,5%/tháng game, phí đấu giá 5%,
// mua lớn Danh vọng +50, thang nhà 6 bậc. Ranh giới pháp lý VN (docs/economy.md):
// KHÔNG cash-out, KHÔNG giao dịch tiền thật, KHÔNG cho vay lấy lãi giữa người
// chơi, KHÔNG cờ bạc, KHÔNG lootbox tiền thật, KHÔNG crypto/NFT — các hành vi
// đó bị chặn ngay trong code (trả false / ném lỗi), không chỉ ghi trong docs.
// Thang xe / điện thoại / quần áo lấy theo docs/economy.md (chưa có trong
// GameBalance nên ghi rõ PROVISIONAL ở bảng catalog khi GDD chốt thì sửa 1 chỗ).
using System;
using System.Collections.Generic;

namespace PhoXoBo
{
    /// <summary>3 dòng chỉ số của một món đồ / nhà / xe (Mục 7).</summary>
    public sealed record ItemStats(
        int The, int Tri, int Tam, int AnYen, int Fame,
        string? UnlocksJobOrTitle, // Nghề / danh hiệu món này mở ra (null = không mở gì)
        string? SetName);          // Tên set để tính set bonus (null = không thuộc set)

    public enum ItemKind { House, Car, Phone, Clothes }

    public sealed record OwnedItem(
        string Id,
        string Name,
        ItemKind Kind,
        long PriceVnd,      // Giá mua (nhà trọ: tiền thuê tháng, xem GameBalance.RoomRentPerMonthVnd)
        ItemStats Stats);

    public static class ItemCatalog
    {
        // Thang nhà 6 bậc — số đã chốt, lấy từ GameBalance (Mục 7).
        // Dòng chỉ số lấy theo ví dụ trong docs/economy.md (PROVISIONAL cho tới khi GDD chốt bảng).
        public static readonly IReadOnlyList<OwnedItem> Houses = new List<OwnedItem>
        {
            new("phong-tro", "Phòng trọ", ItemKind.House, GameBalance.RoomRentPerMonthVnd,
                new ItemStats(-5, 0, 0, 5, 0, null, "Nhà ấm")),
            new("chung-cu-mini", "Chung cư mini", ItemKind.House, GameBalance.MiniApartmentVnd,
                new ItemStats(0, 5, 0, 10, 0, "Quản lý cần có nhà riêng", "Nhà ấm")),
            new("nha-pho-nho", "Nhà phố nhỏ", ItemKind.House, GameBalance.SmallTownhouseVnd,
                new ItemStats(0, 10, 0, 15, 0, "Giám đốc cần nhà phố", "Nhà ấm")),
            new("nha-pho-lon", "Nhà phố lớn", ItemKind.House, GameBalance.LargeTownhouseVnd,
                new ItemStats(0, 10, 10, 20, 0, "Giám đốc cần nhà phố", "Nhà ấm")),
            new("biet-thu", "Biệt thự", ItemKind.House, GameBalance.VillaVnd,
                new ItemStats(0, 0, 20, 30, 50, "Chủ Nhà Trọ cần 2 nhà cho thuê", "Nhà ấm")),
            new("penthouse-dao", "Penthouse / Đảo", ItemKind.House, GameBalance.PenthouseIslandVnd,
                new ItemStats(0, 10, 20, 30, 50, null, "Nhà ấm")),
        };

        // Thang xe — giá theo docs/economy.md (PROVISIONAL, chưa có trong GameBalance).
        public static readonly IReadOnlyList<OwnedItem> Cars = new List<OwnedItem>
        {
            new("xe-dap", "Xe đạp", ItemKind.Car, 0,
                new ItemStats(5, 0, 0, 0, 0, null, null)),
            new("xe-may-cu", "Xe máy cũ", ItemKind.Car, 15_000_000,
                new ItemStats(0, 0, 0, 0, 0, "Shipper", null)),
            new("xe-may-moi", "Xe máy mới", ItemKind.Car, 60_000_000,
                new ItemStats(0, 0, 0, 5, 0, "Shipper", null)),
            new("o-to-cu", "Ô tô cũ", ItemKind.Car, 400_000_000,
                new ItemStats(0, 0, 0, 0, 10, "Việc tầng cao", null)),
            new("o-to-moi", "Ô tô mới", ItemKind.Car, 1_200_000_000,
                new ItemStats(0, 0, 5, 10, 20, "Giám đốc cần xe", "Sang trọng")),
            new("xe-sang", "Xe sang", ItemKind.Car, 5_000_000_000,
                new ItemStats(0, 0, 10, 10, 50, "Giám đốc cần xe", "Sang trọng")),
        };

        // Điện thoại / quần áo mẫu — giá + chỉ số theo docs/economy.md (PROVISIONAL).
        public static readonly IReadOnlyList<OwnedItem> Phones = new List<OwnedItem>
        {
            new("dien-thoai-cu", "Điện thoại cũ", ItemKind.Phone, 5_000_000,
                new ItemStats(0, 0, 0, 0, 0, null, null)),
            new("dien-thoai-flagship", "Điện thoại flagship", ItemKind.Phone, 30_000_000,
                new ItemStats(0, 10, 10, 0, 10, "Bác sĩ cần điện thoại tốt để trực", null)),
        };

        public static readonly IReadOnlyList<OwnedItem> Clothes = new List<OwnedItem>
        {
            new("ao-dai", "Áo dài", ItemKind.Clothes, 2_000_000,
                new ItemStats(0, 0, 15, 0, 10, null, "Truyền thống")),
            new("bo-cong-so", "Bộ công sở", ItemKind.Clothes, 5_000_000,
                new ItemStats(0, 0, 10, 0, 10, "Phỏng vấn quản lý", "Công sở")),
            new("vest-giam-doc", "Vest giám đốc", ItemKind.Clothes, 20_000_000,
                new ItemStats(0, 0, 10, 0, 20, "Giám đốc cần vest", "Công sở")),
        };

        public static OwnedItem? Get(string id)
        {
            foreach (var list in new[] { Houses, Cars, Phones, Clothes })
                foreach (var item in list)
                    if (item.Id == id) return item;
            return null;
        }
    }

    /// <summary>
    /// Ví tiền + tài sản của người chơi. Mọi giao dịch tiền trong game đi qua đây;
    /// server là nguồn sự thật khi online (ledger double-entry, xem docs/architecture.md).
    /// </summary>
    public sealed class Economy
    {
        // 1 tháng game = 30 ngày game — PROVISIONAL (GDD chưa chốt độ dài tháng game).
        public const int DaysPerGameMonth = 30;

        // Set bonus: đủ 3 món cùng set → cộng thêm. Số PROVISIONAL.
        public const int SetBonusFame = 10;
        public const int SetBonusAnYen = 5;

        // Đồ lệch chuẩn khi phỏng vấn: Giao tiếp −20 (docs/economy.md).
        // Giao tiếp lấy từ Tâm nên trừ vào Tam tạm thời trong phiên phỏng vấn — PROVISIONAL.
        public const int DressCodePenalty = 20;

        public long MoneyVnd { get; private set; }
        public long SavingsVnd { get; private set; }
        public int CreditScore { get; private set; } = 100; // PROVISIONAL — điểm tín dụng khởi đầu

        private readonly List<OwnedItem> _owned = new();

        public IReadOnlyList<OwnedItem> Owned => _owned;
        public long TotalAssetsVnd
        {
            get
            {
                var total = MoneyVnd + SavingsVnd;
                foreach (var item in _owned) total += item.PriceVnd;
                return total;
            }
        }

        public Economy(long startingMoneyVnd) => MoneyVnd = startingMoneyVnd;

        /// <summary>Lãi tiết kiệm: 0,5%/tháng game (GameBalance, đã chốt). Trả lãi đã cộng.</summary>
        public long ApplyMonthlyInterest(int gameDaysElapsed)
        {
            var months = gameDaysElapsed / DaysPerGameMonth;
            if (months <= 0 || SavingsVnd <= 0) return 0;
            var interest = (long)Math.Floor(SavingsVnd * GameBalance.BankInterestPerGameMonth * months);
            SavingsVnd += interest;
            return interest;
        }

        public bool DepositSavings(long amount)
        {
            if (amount <= 0 || amount > MoneyVnd) return false;
            MoneyVnd -= amount;
            SavingsVnd += amount;
            return true;
        }

        public bool WithdrawSavings(long amount)
        {
            if (amount <= 0 || amount > SavingsVnd) return false;
            SavingsVnd -= amount;
            MoneyVnd += amount;
            return true;
        }

        /// <summary>
        /// Mua món đồ. Trả false nếu không đủ tiền hoặc món không có.
        /// Mua lớn (nhà / xe sang) cộng Danh vọng GameBalance.BigPurchaseFameBonus (+50, đã chốt).
        /// </summary>
        public bool Buy(string itemId, out int fameGained)
        {
            fameGained = 0;
            var item = ItemCatalog.Get(itemId);
            if (item == null) return false;
            if (item.Kind == ItemKind.House && item.Id == "phong-tro")
            {
                // Phòng trọ trả thuê tháng, không mua đứt.
                if (MoneyVnd < item.PriceVnd) return false;
                MoneyVnd -= item.PriceVnd;
                _owned.Add(item);
                return true;
            }
            if (MoneyVnd < item.PriceVnd) return false;
            MoneyVnd -= item.PriceVnd;
            _owned.Add(item);
            if (item.Kind == ItemKind.House || item.Id == "xe-sang")
                fameGained = GameBalance.BigPurchaseFameBonus;
            return true;
        }

        /// <summary>Sàn đấu giá: người bán nhận giá trừ phí 5% (GameBalance, đã chốt).</summary>
        public static long AuctionSellerReceives(long hammerPriceVnd) =>
            hammerPriceVnd * (100 - GameBalance.AuctionFeePercent) / 100;

        /// <summary>Đồ đổi đồ (barter): không dùng tiền, không phí. Chỉ kiểm tra 2 bên có đồ.</summary>
        public bool Barter(string giveItemId, string receiveItemId, Economy other)
        {
            var give = _owned.Find(i => i.Id == giveItemId);
            var receive = other._owned.Find(i => i.Id == receiveItemId);
            if (give == null || receive == null) return false;
            _owned.Remove(give);
            other._owned.Remove(receive);
            _owned.Add(receive);
            other._owned.Add(give);
            return true;
        }

        /// <summary>Ly hôn chia tài sản: chia đôi tiền mặt + tiền tiết kiệm (luật slice, PROVISIONAL).</summary>
        public (long Mine, long Theirs) SplitAssets()
        {
            var halfMoney = MoneyVnd / 2;
            var halfSavings = SavingsVnd / 2;
            MoneyVnd -= halfMoney;
            SavingsVnd -= halfSavings;
            return (MoneyVnd + SavingsVnd, halfMoney + halfSavings);
        }

        /// <summary>Set bonus: đủ 3 món cùng set → cộng thêm Danh vọng + An Yên (số PROVISIONAL).</summary>
        public (int Fame, int AnYen) SetBonus()
        {
            var counts = new Dictionary<string, int>();
            foreach (var item in _owned)
            {
                if (item.Stats.SetName == null) continue;
                counts.TryGetValue(item.Stats.SetName, out var n);
                counts[item.Stats.SetName] = n + 1;
            }
            var fame = 0;
            var anYen = 0;
            foreach (var n in counts.Values)
                if (n >= 3) { fame += SetBonusFame; anYen += SetBonusAnYen; }
            return (fame, anYen);
        }

        /// <summary>Kiểm tra dress-code: mặc đồ chợ (không có món Công sở / Sang trọng) đi phỏng vấn giám đốc.</summary>
        public bool PassesDirectorDressCode()
        {
            foreach (var item in _owned)
                if (item.Kind == ItemKind.Clothes &&
                    (item.Stats.SetName == "Công sở" || item.Stats.SetName == "Sang trọng"))
                    return true;
            return false;
        }

        // ===== RANH GIỚI PHÁP LÝ — các hành vi này BỊ CHẶN, không phải tính năng =====
        // Mỗi hàm trả false / ném lỗi có chủ đích để QC kiểm tra tĩnh bắt được nếu ai
        // vô tình "mở" lại chúng. Xem docs/economy.md mục CẤM.

        /// <summary>Cash-out: đổi tiền trong game ra tiền thật — CẤM. Luôn trả false.</summary>
        public bool CashOut(long amountVnd) => false;

        /// <summary>Cho vay lấy lãi giữa người chơi — CẤM. Luôn trả false.</summary>
        public bool LendWithInterest(Economy borrower, long amountVnd, double interestRate) => false;

        /// <summary>Cờ bạc / cá cược bằng tiền trong game — CẤM. Luôn trả false.</summary>
        public bool Gamble(long stakeVnd) => false;

        /// <summary>Mua nhà / xe / chỉ số bằng tiền thật — CẤM. Nạp chỉ mua gói tháng, mỹ phẩm, lượt thi.</summary>
        public bool BuyWithRealMoney(string itemId, decimal realMoneyAmount) => false;
    }
}
