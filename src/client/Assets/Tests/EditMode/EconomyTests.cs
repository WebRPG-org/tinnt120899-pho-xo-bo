// Phố Xô Bồ — Test EditMode cho hệ kinh tế (Economy, ItemCatalog, Mục 7).
// Chạy bằng Unity Test Runner (EditMode), KHÔNG chạy được trên VM này (không có Unity).
// API thật đang test: Economy, ItemCatalog (src/client/Assets/Scripts/Economy.cs),
// GameBalance (BankInterestPerGameMonth, AuctionFeePercent, BigPurchaseFameBonus,
// thang nhà 6 bậc, tiền thuê trọ) — mọi số kỳ vọng tính đúng từ code thật, không bịa.
//
// LƯU Ý VỀ SỐ PROVISIONAL (ghi rõ trong từng test liên quan):
// - SetBonus (Fame +10, AnYen +5) là số PROVISIONAL trong Economy.cs (Economy.SetBonusFame /
//   SetBonusAnYen) — GDD chưa chốt; đổi hằng là test phải đổi theo.
// - Giá xe / điện thoại / quần áo trong ItemCatalog là PROVISIONAL theo docs/economy.md
//   (chưa có trong GameBalance); chỉ giá nhà là số đã chốt lấy từ GameBalance.
// - 1 tháng game = 30 ngày game (Economy.DaysPerGameMonth) cũng là PROVISIONAL.
using NUnit.Framework;

namespace PhoXoBo.Tests
{
    [TestFixture]
    public class EconomyTests
    {
        // --- Lãi tiết kiệm 0,5%/tháng game (GameBalance.BankInterestPerGameMonth) ---
        // Công thức Economy.ApplyMonthlyInterest: tháng = ngày / 30 (chia nguyên),
        // lãi = floor(tiết kiệm * 0,005 * tháng).

        [Test]
        public void LaiTietKiem_Gui10Trieu_30Ngay_Lai50k_LamTronXuong()
        {
            var eco = new Economy(20_000_000);
            Assert.IsTrue(eco.DepositSavings(10_000_000));
            var lai = eco.ApplyMonthlyInterest(30);
            Assert.AreEqual(50_000, lai); // 10_000_000 * 0,005 * 1
            Assert.AreEqual(10_050_000, eco.SavingsVnd);
            Assert.AreEqual(10_000_000, eco.MoneyVnd, "Lãi chỉ cộng vào tiết kiệm, tiền mặt không đổi");

            // Làm tròn xuống: 10_000_001 * 0,005 = 50_000,005 -> floor -> 50_000 (không phải 50_001).
            var ecoLe = new Economy(20_000_001);
            Assert.IsTrue(ecoLe.DepositSavings(10_000_001));
            Assert.AreEqual(50_000, ecoLe.ApplyMonthlyInterest(30));
            Assert.AreEqual(10_050_001, ecoLe.SavingsVnd);
        }

        [Test]
        public void LaiTietKiem_Gui10Trieu_60Ngay_Lai100k()
        {
            var eco = new Economy(20_000_000);
            Assert.IsTrue(eco.DepositSavings(10_000_000));
            var lai = eco.ApplyMonthlyInterest(60);
            Assert.AreEqual(100_000, lai); // 10_000_000 * 0,005 * 2 tháng
            Assert.AreEqual(10_100_000, eco.SavingsVnd);
        }

        [Test]
        public void LaiTietKiem_29NgayHoacKhongTietKiem_Tra0()
        {
            var eco = new Economy(20_000_000);
            Assert.IsTrue(eco.DepositSavings(10_000_000));
            Assert.AreEqual(0, eco.ApplyMonthlyInterest(29), "29 ngày = 0 tháng (29 / 30 chia nguyên)");
            Assert.AreEqual(10_000_000, eco.SavingsVnd, "Chưa đủ 1 tháng thì tiết kiệm không đổi");

            var ecoKhongTietKiem = new Economy(10_000_000);
            Assert.AreEqual(0, ecoKhongTietKiem.ApplyMonthlyInterest(30), "Không có tiết kiệm thì lãi 0");
            Assert.AreEqual(0, ecoKhongTietKiem.ApplyMonthlyInterest(90), "Không có tiết kiệm thì 3 tháng cũng lãi 0");
        }

        // --- Gửi / rút tiết kiệm ---

        [Test]
        public void GuiTietKiem_DuTien_TruTienMatCongTietKiem()
        {
            var eco = new Economy(20_000_000);
            Assert.IsTrue(eco.DepositSavings(10_000_000));
            Assert.AreEqual(10_000_000, eco.MoneyVnd);
            Assert.AreEqual(10_000_000, eco.SavingsVnd);
            Assert.IsTrue(eco.DepositSavings(10_000_000), "Gửi đúng bằng số tiền mặt còn lại vẫn được");
            Assert.AreEqual(0, eco.MoneyVnd);
            Assert.AreEqual(20_000_000, eco.SavingsVnd);
        }

        [Test]
        public void GuiTietKiem_QuaTienMatHoacKhongDuong_TraFalseVaKhongDoi()
        {
            var eco = new Economy(10_000_000);
            Assert.IsFalse(eco.DepositSavings(10_000_001), "Gửi quá tiền mặt phải trả false");
            Assert.IsFalse(eco.DepositSavings(0), "Gửi 0 phải trả false");
            Assert.IsFalse(eco.DepositSavings(-5_000_000), "Gửi số âm phải trả false");
            Assert.AreEqual(10_000_000, eco.MoneyVnd, "Gửi thất bại thì tiền mặt không đổi");
            Assert.AreEqual(0, eco.SavingsVnd, "Gửi thất bại thì tiết kiệm không đổi");
        }

        [Test]
        public void RutTietKiem_DungSoVaQuaTietKiem()
        {
            var eco = new Economy(20_000_000);
            Assert.IsTrue(eco.DepositSavings(10_000_000));
            Assert.IsTrue(eco.WithdrawSavings(4_000_000));
            Assert.AreEqual(14_000_000, eco.MoneyVnd);
            Assert.AreEqual(6_000_000, eco.SavingsVnd);
            Assert.IsFalse(eco.WithdrawSavings(6_000_001), "Rút quá tiết kiệm phải trả false");
            Assert.IsFalse(eco.WithdrawSavings(0), "Rút 0 phải trả false");
            Assert.IsFalse(eco.WithdrawSavings(-1), "Rút số âm phải trả false");
            Assert.AreEqual(14_000_000, eco.MoneyVnd, "Rút thất bại thì tiền mặt không đổi");
            Assert.AreEqual(6_000_000, eco.SavingsVnd, "Rút thất bại thì tiết kiệm không đổi");
            Assert.IsTrue(eco.WithdrawSavings(6_000_000), "Rút đúng bằng tiết kiệm còn lại vẫn được");
            Assert.AreEqual(20_000_000, eco.MoneyVnd);
            Assert.AreEqual(0, eco.SavingsVnd);
        }

        // --- Mua đồ: trừ tiền, cộng fame khi mua lớn ---

        [Test]
        public void MuaChungCuMini_Tru800Tr_Fame50()
        {
            var eco = new Economy(1_000_000_000);
            Assert.IsTrue(eco.Buy("chung-cu-mini", out var fame));
            Assert.AreEqual(50, fame, "Nhà là mua lớn: +50 Danh vọng (GameBalance.BigPurchaseFameBonus)");
            Assert.AreEqual(200_000_000, eco.MoneyVnd); // 1_000_000_000 - 800_000_000 (GameBalance.MiniApartmentVnd)
            Assert.AreEqual(1, eco.Owned.Count);
            Assert.AreEqual("chung-cu-mini", eco.Owned[0].Id);
        }

        [Test]
        public void MuaXeSang_Fame50()
        {
            var eco = new Economy(6_000_000_000);
            Assert.IsTrue(eco.Buy("xe-sang", out var fame));
            Assert.AreEqual(50, fame, "Xe sang là mua lớn: +50 Danh vọng (GameBalance.BigPurchaseFameBonus)");
            Assert.AreEqual(1_000_000_000, eco.MoneyVnd); // 6_000_000_000 - 5_000_000_000 (giá PROVISIONAL)
        }

        [Test]
        public void MuaOToMoi_Fame0()
        {
            var eco = new Economy(2_000_000_000);
            Assert.IsTrue(eco.Buy("o-to-moi", out var fame));
            Assert.AreEqual(0, fame, "Ô tô mới không phải mua lớn (chỉ nhà và xe sang mới +fame)");
            Assert.AreEqual(800_000_000, eco.MoneyVnd); // 2_000_000_000 - 1_200_000_000 (giá PROVISIONAL)
        }

        [Test]
        public void MuaPhongTro_TruTienThue2Tr_KhongFame()
        {
            var eco = new Economy(10_000_000);
            Assert.IsTrue(eco.Buy("phong-tro", out var fame));
            Assert.AreEqual(0, fame, "Phòng trọ chỉ trả thuê tháng, không phải mua đứt nên không +fame");
            Assert.AreEqual(8_000_000, eco.MoneyVnd); // 10_000_000 - 2_000_000 (GameBalance.RoomRentPerMonthVnd)
            Assert.AreEqual(1, eco.Owned.Count);
        }

        [Test]
        public void MuaMonKhongTonTaiHoacKhongDuTien_TraFalseVaTienKhongDoi()
        {
            var eco = new Economy(1_000_000);
            Assert.IsFalse(eco.Buy("mon-khong-ton-tai", out var fameLa), "Món không có trong catalog phải trả false");
            Assert.AreEqual(0, fameLa);
            Assert.IsFalse(eco.Buy("chung-cu-mini", out var fameThieu), "Không đủ 800tr mua chung cư mini phải trả false");
            Assert.AreEqual(0, fameThieu);
            Assert.AreEqual(1_000_000, eco.MoneyVnd, "Mua thất bại thì tiền không đổi");
            Assert.AreEqual(0, eco.Owned.Count, "Mua thất bại thì không thêm đồ");
        }

        // --- Sàn đấu giá: người bán nhận giá trừ phí 5% (GameBalance.AuctionFeePercent) ---
        // Công thức Economy.AuctionSellerReceives: giá * (100 - 5) / 100, phép chia nguyên trên long
        // (nhân trước rồi chia, phần lẻ bị cắt — KHÔNG làm tròn lên).

        [Test]
        public void AuctionSellerReceives_Phi5PhanTram_LamTronXuong()
        {
            Assert.AreEqual(95_000_000, Economy.AuctionSellerReceives(100_000_000)); // 100tr * 95 / 100
            Assert.AreEqual(950_000, Economy.AuctionSellerReceives(1_000_000)); // 1tr * 95 / 100
            // Giá lẻ bắt làm tròn: 10_000_001 * 95 = 950_000_095; / 100 = 9_500_000 (cắt ,95, không phải 9_500_001).
            Assert.AreEqual(9_500_000, Economy.AuctionSellerReceives(10_000_001));
            // 999_999 * 95 = 94_999_905; / 100 = 949_999 (cắt ,05).
            Assert.AreEqual(949_999, Economy.AuctionSellerReceives(999_999));
            Assert.AreEqual(0, Economy.AuctionSellerReceives(0));
        }

        // --- Đồ đổi đồ (barter): không tiền, không phí ---

        [Test]
        public void Barter_HaiBenCoDo_DoiDoThanhCong()
        {
            var a = new Economy(100_000_000);
            var b = new Economy(100_000_000);
            Assert.IsTrue(a.Buy("xe-may-cu", out _)); // 15tr, giá PROVISIONAL
            Assert.IsTrue(b.Buy("dien-thoai-cu", out _)); // 5tr, giá PROVISIONAL
            Assert.IsTrue(a.Barter("xe-may-cu", "dien-thoai-cu", b));
            Assert.AreEqual(1, a.Owned.Count);
            Assert.AreEqual("dien-thoai-cu", a.Owned[0].Id, "A nhận điện thoại của B");
            Assert.AreEqual(1, b.Owned.Count);
            Assert.AreEqual("xe-may-cu", b.Owned[0].Id, "B nhận xe của A");
            Assert.AreEqual(85_000_000, a.MoneyVnd, "Barter không đụng tới tiền mặt của A");
            Assert.AreEqual(95_000_000, b.MoneyVnd, "Barter không đụng tới tiền mặt của B");
        }

        [Test]
        public void Barter_MotBenKhongCoDo_TraFalseVaDoKhongDoi()
        {
            var a = new Economy(100_000_000);
            var b = new Economy(100_000_000);
            Assert.IsTrue(a.Buy("xe-may-cu", out _));
            // B không có điện thoại cũ để đổi.
            Assert.IsFalse(a.Barter("xe-may-cu", "dien-thoai-cu", b));
            Assert.AreEqual("xe-may-cu", a.Owned[0].Id, "Đổi thất bại thì đồ của A không đổi");
            Assert.AreEqual(0, b.Owned.Count);
            // A không có ô tô mới để đưa.
            Assert.IsFalse(a.Barter("o-to-moi", "dien-thoai-cu", b));
            Assert.AreEqual("xe-may-cu", a.Owned[0].Id);
        }

        // --- Ly hôn chia tài sản: chia đôi tiền mặt + tiết kiệm (luật slice, PROVISIONAL) ---
        // Công thức Economy.SplitAssets: nửa tiền = tiền / 2 (chia nguyên), nửa tiết kiệm = tiết kiệm / 2;
        // Mine = phần còn lại của mình, Theirs = nửa tiền + nửa tiết kiệm.

        [Test]
        public void SplitAssets_SoLe_ChiaNguyen_MineTheirsDungCongThuc()
        {
            var eco = new Economy(15_000_002);
            Assert.IsTrue(eco.DepositSavings(5_000_001)); // Tiền mặt 10_000_001, tiết kiệm 5_000_001
            var (mine, theirs) = eco.SplitAssets();
            // Nửa tiền = 10_000_001 / 2 = 5_000_000 (chia nguyên, bỏ 1 đồng lẻ);
            // nửa tiết kiệm = 5_000_001 / 2 = 2_500_000 (bỏ 1 đồng lẻ).
            Assert.AreEqual(7_500_000, theirs); // 5_000_000 + 2_500_000
            Assert.AreEqual(7_500_002, mine); // (10_000_001 - 5_000_000) + (5_000_001 - 2_500_000)
            Assert.AreEqual(5_000_001, eco.MoneyVnd);
            Assert.AreEqual(2_500_001, eco.SavingsVnd);
            Assert.AreEqual(15_000_002, mine + theirs, "Chia tài sản không làm mất đồng nào");
        }

        // --- Set bonus: đủ 3 món cùng set → cộng thêm (số PROVISIONAL trong Economy.cs) ---

        [Test]
        public void SetBonus_Du3MonNhaAm_Fame10AnYen5_PROVISIONAL()
        {
            // PROVISIONAL: SetBonusFame = 10, SetBonusAnYen = 5 (Economy.cs) — GDD chưa chốt.
            var eco = new Economy(10_000_000_000);
            Assert.IsTrue(eco.Buy("phong-tro", out _)); // set "Nhà ấm"
            Assert.IsTrue(eco.Buy("chung-cu-mini", out _)); // set "Nhà ấm"
            Assert.IsTrue(eco.Buy("nha-pho-nho", out _)); // set "Nhà ấm"
            var (fame, anYen) = eco.SetBonus();
            Assert.AreEqual(10, fame);
            Assert.AreEqual(5, anYen);
        }

        [Test]
        public void SetBonus_ChuaDu3Mon_Tra0()
        {
            var eco = new Economy(10_000_000_000);
            Assert.IsTrue(eco.Buy("phong-tro", out _)); // set "Nhà ấm" (1 món)
            Assert.IsTrue(eco.Buy("chung-cu-mini", out _)); // set "Nhà ấm" (2 món)
            var (fame, anYen) = eco.SetBonus();
            Assert.AreEqual(0, fame, "Mới 2 món cùng set thì chưa có bonus");
            Assert.AreEqual(0, anYen);
            // 2 món set "Công sở" cũng chưa đủ 3.
            Assert.IsTrue(eco.Buy("bo-cong-so", out _));
            Assert.IsTrue(eco.Buy("vest-giam-doc", out _));
            (fame, anYen) = eco.SetBonus();
            Assert.AreEqual(0, fame);
            Assert.AreEqual(0, anYen);
        }

        // --- Dress-code phỏng vấn giám đốc: cần đồ set "Công sở" hoặc "Sang trọng" ---

        [Test]
        public void PassesDirectorDressCode_MuaBoCongSo_MoiTrue()
        {
            var eco = new Economy(100_000_000);
            Assert.IsFalse(eco.PassesDirectorDressCode(), "Lúc đầu chưa có đồ công sở thì không đạt dress-code");
            Assert.IsTrue(eco.Buy("ao-dai", out _)); // set "Truyền thống" — không tính
            Assert.IsFalse(eco.PassesDirectorDressCode(), "Áo dài không phải đồ công sở nên vẫn không đạt");
            Assert.IsTrue(eco.Buy("bo-cong-so", out _)); // set "Công sở"
            Assert.IsTrue(eco.PassesDirectorDressCode());

            var ecoVest = new Economy(100_000_000);
            Assert.IsTrue(ecoVest.Buy("vest-giam-doc", out _)); // set "Công sở"
            Assert.IsTrue(ecoVest.PassesDirectorDressCode(), "Vest giám đốc cũng đạt dress-code");
        }

        // --- Ranh giới pháp lý VN (docs/economy.md): các hành vi này BỊ CHẶN, luôn trả false ---

        [Test]
        public void RanhGioiPhapLy_BonHanhViCam_LuonTraFalse()
        {
            var eco = new Economy(1_000_000_000);
            var other = new Economy(0);
            Assert.IsFalse(eco.CashOut(100_000_000), "Cash-out đổi tiền game ra tiền thật — CẤM");
            Assert.IsFalse(eco.CashOut(2_000_000_000), "Cash-out quá số tiền có cũng vẫn false");
            Assert.IsFalse(eco.LendWithInterest(other, 100_000_000, 0.1), "Cho vay lấy lãi giữa người chơi — CẤM");
            Assert.IsFalse(eco.Gamble(100_000_000), "Cờ bạc / cá cược bằng tiền trong game — CẤM");
            Assert.IsFalse(eco.BuyWithRealMoney("chung-cu-mini", 100m), "Mua đồ bằng tiền thật — CẤM");
            Assert.AreEqual(1_000_000_000, eco.MoneyVnd, "Hành vi bị chặn không được đụng tới tiền");
            Assert.AreEqual(0, other.MoneyVnd, "Hành vi bị chặn không được chuyển tiền cho bên kia");
            Assert.AreEqual(0, eco.Owned.Count, "Mua bằng tiền thật bị chặn thì không được nhận đồ");
        }

        // --- Tổng tài sản = tiền mặt + tiết kiệm + giá đồ đã mua ---

        [Test]
        public void TotalAssetsVnd_TienMatCongTietKiemCongGiaDo()
        {
            var eco = new Economy(100_000_000);
            Assert.AreEqual(100_000_000, eco.TotalAssetsVnd, "Chưa làm gì thì tổng tài sản = tiền mặt ban đầu");
            Assert.IsTrue(eco.DepositSavings(10_000_000));
            Assert.AreEqual(100_000_000, eco.TotalAssetsVnd, "Gửi tiết kiệm chỉ chuyển tiền, tổng không đổi");
            Assert.IsTrue(eco.Buy("xe-may-cu", out _)); // 15tr, giá PROVISIONAL
            Assert.AreEqual(75_000_000, eco.MoneyVnd);
            Assert.AreEqual(10_000_000, eco.SavingsVnd);
            Assert.AreEqual(100_000_000, eco.TotalAssetsVnd, "Mua đồ chỉ chuyển tiền thành tài sản, tổng không đổi");
        }

        // --- ItemCatalog.Get + thang nhà 6 bậc (GameBalance, đã chốt) ---

        [Test]
        public void ItemCatalog_Get_TimDungMon_IdLaTraNull()
        {
            var mini = ItemCatalog.Get("chung-cu-mini");
            Assert.IsNotNull(mini);
            Assert.AreEqual("Chung cư mini", mini!.Name);
            Assert.AreEqual(ItemKind.House, mini.Kind);
            Assert.AreEqual(800_000_000, mini.PriceVnd); // GameBalance.MiniApartmentVnd
            var xeSang = ItemCatalog.Get("xe-sang");
            Assert.IsNotNull(xeSang);
            Assert.AreEqual(5_000_000_000, xeSang!.PriceVnd, "Giá xe sang là PROVISIONAL theo docs/economy.md");
            Assert.IsNull(ItemCatalog.Get("mon-khong-ton-tai"), "Id lạ trả null");
            Assert.IsNull(ItemCatalog.Get(""), "Id rỗng trả null");
        }

        [Test]
        public void ItemCatalog_ThangNha6Bac_DungGiaGameBalance()
        {
            Assert.AreEqual(6, ItemCatalog.Houses.Count, "Thang nhà đúng 6 bậc");
            var expected = new (string Id, long Price)[]
            {
                ("phong-tro", GameBalance.RoomRentPerMonthVnd), // 2_000_000 — tiền thuê tháng
                ("chung-cu-mini", GameBalance.MiniApartmentVnd), // 800_000_000
                ("nha-pho-nho", GameBalance.SmallTownhouseVnd), // 3_000_000_000
                ("nha-pho-lon", GameBalance.LargeTownhouseVnd), // 8_000_000_000
                ("biet-thu", GameBalance.VillaVnd), // 25_000_000_000
                ("penthouse-dao", GameBalance.PenthouseIslandVnd), // 100_000_000_000
            };
            for (var i = 0; i < expected.Length; i++)
            {
                Assert.AreEqual(expected[i].Id, ItemCatalog.Houses[i].Id);
                Assert.AreEqual(expected[i].Price, ItemCatalog.Houses[i].PriceVnd, $"Giá {expected[i].Id} phải đúng GameBalance");
                if (i > 0)
                    Assert.Greater(ItemCatalog.Houses[i].PriceVnd, ItemCatalog.Houses[i - 1].PriceVnd,
                        "Thang nhà tăng dần theo bậc");
            }
        }
    }
}
