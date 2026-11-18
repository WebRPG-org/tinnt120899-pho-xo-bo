// Phố Xô Bồ — Test EditMode cho túi đồ (Inventory.cs, Mục 2 + Mục 7).
// Chạy bằng Unity Test Runner (EditMode), KHÔNG chạy được trên VM này (không có Unity).
// API thật đang test: ItemCatalog (Items, Get), Inventory (Add, Use, Count, BuffFor,
// EndFrame, ActiveBuffs), Buff (Stat, Amount, Frame), ItemDefinition (PriceVnd,
// Stackable, Effect, UnlockNote).
//
// Số PROVISIONAL (chưa chốt GDD, lấy đúng comment trong Inventory.cs — đổi code là test
// phải đổi theo): giá cơm tấm 35_000, cà phê 25_000, sách 80_000, áo mưa 120_000;
// buff +5 vào 1 chỉ số gốc trong 1 khung (cơm tấm Thể/Chiều, cà phê Trí/Sáng,
// sách Trí/Tối); áo mưa không buff, chỉ mở điều kiện "Làm được ca mưa, không bị ướt".
// Hành vi đã sửa (18/11, sửa 2 bug ghi trong docs/test-report.md đợt 18:50):
// - Add đồ không stackable: quantity > 1 thì trả false, không thêm gì — kể cả lúc
//   túi trống (trước đây Add("ao-mua", 2) lúc túi trống vẫn trả true và giữ 2 cái).
// - Use áp buff đúng khung ghi trong catalog: cơm tấm (catalog ghi khung Chiều) mà
//   dùng lúc Sáng thì buff vẫn vào khung Chiều, không bị ghi đè bằng khung lúc dùng
//   (xem test Use_BuffApDungKhungCatalog).
using NUnit.Framework;

namespace PhoXoBo.Tests
{
    [TestFixture]
    public class InventoryTests
    {
        // --- Add: id không có -> false, quantity <= 0 -> false ---

        [Test]
        public void Add_IdLa_TraFalseVaKhongThem()
        {
            var inv = new Inventory();
            Assert.IsFalse(inv.Add("khong-ton-tai"));
            Assert.AreEqual(0, inv.Count("khong-ton-tai"), "Id lạ thì túi không có món đó");
            Assert.AreEqual(0, inv.Count("com-tam"), "Add id lạ không làm thay đổi món khác");
        }

        [Test]
        public void Add_QuantityBang0HoacAm_TraFalse()
        {
            var inv = new Inventory();
            Assert.IsFalse(inv.Add("com-tam", 0), "quantity = 0 thì không mua được");
            Assert.IsFalse(inv.Add("com-tam", -2), "quantity âm thì không mua được");
            Assert.AreEqual(0, inv.Count("com-tam"), "Add thất bại thì số lượng vẫn 0");
        }

        // --- Add: đồ stackable cộng dồn; đồ không stackable chỉ giữ 1 ---

        [Test]
        public void Add_DoStackable_CongDonSoLuong()
        {
            var inv = new Inventory();
            Assert.IsTrue(inv.Add("com-tam", 2));
            Assert.AreEqual(2, inv.Count("com-tam"));
            Assert.IsTrue(inv.Add("com-tam", 3), "Đồ stackable mua thêm thì cộng dồn");
            Assert.AreEqual(5, inv.Count("com-tam")); // 2 + 3
        }

        [Test]
        public void Add_DoKhongStackable_ChiGiu1()
        {
            var inv = new Inventory();
            Assert.IsTrue(inv.Add("ao-mua")); // mặc định quantity = 1
            Assert.AreEqual(1, inv.Count("ao-mua"));
            Assert.IsFalse(inv.Add("ao-mua"), "Đã có áo mưa thì mua thêm trả false");
            Assert.AreEqual(1, inv.Count("ao-mua"), "Mua thêm thất bại thì số lượng vẫn 1");
        }

        [Test]
        public void Add_DoKhongStackable_Them2CungLuc_TraFalseVaKhongThem()
        {
            // ĐÃ SỬA 18/11 (bug test-report.md đợt 18:50): trước đây Add("ao-mua", 2)
            // lúc túi trống trả true và giữ 2 cái. Hành vi đúng: đồ không stackable
            // chỉ nhận đúng 1 cái mỗi lần, quantity > 1 thì trả false, không thêm gì
            // (nhất quán với việc mua thêm khi túi đã có món đó cũng trả false).
            var inv = new Inventory();
            Assert.IsFalse(inv.Add("ao-mua", 2), "Đồ không stackable mua 2 cái cùng lúc thì trả false");
            Assert.AreEqual(0, inv.Count("ao-mua"), "Mua thất bại thì túi vẫn trống");
        }

        [Test]
        public void Add_DoKhongStackable_DaCo1RoiThem2_TraFalseVaGiu1()
        {
            // Hồi quy Bug 1: túi đã có 1 áo mưa, mua thêm 2 cùng lúc cũng phải chặn.
            var inv = new Inventory();
            Assert.IsTrue(inv.Add("ao-mua"));
            Assert.IsFalse(inv.Add("ao-mua", 2), "Đã có 1 thì mua thêm 2 cũng trả false");
            Assert.AreEqual(1, inv.Count("ao-mua"), "Số lượng vẫn giữ 1");
        }

        [Test]
        public void Add_DoKhongStackable_Them2ThatBai_RoiThem1ThanhCong()
        {
            // Hồi quy Bug 1: lần mua 2 thất bại không được thêm lẻ 1 cái nào vào túi —
            // gọi lại với quantity = 1 sau đó vẫn mua được bình thường.
            var inv = new Inventory();
            Assert.IsFalse(inv.Add("ao-mua", 2));
            Assert.AreEqual(0, inv.Count("ao-mua"));
            Assert.IsTrue(inv.Add("ao-mua", 1), "Mua đúng 1 cái thì vẫn được");
            Assert.AreEqual(1, inv.Count("ao-mua"));
        }

        // --- Use: không có đồ -> false; trừ 1; kích hoạt buff đúng khung ---

        [Test]
        public void Use_KhongCoDo_TraFalseVaKhongThemBuff()
        {
            var inv = new Inventory();
            Assert.IsFalse(inv.Use("ca-phe", TimeFrame.Sang), "Chưa có cà phê thì dùng trả false");
            Assert.IsFalse(inv.Use("khong-ton-tai", TimeFrame.Sang), "Id lạ thì dùng trả false");
            Assert.AreEqual(0, inv.ActiveBuffs.Count, "Dùng thất bại thì không có buff nào");
            Assert.AreEqual(0, inv.BuffFor(BaseStat.Tri, TimeFrame.Sang));
        }

        [Test]
        public void Use_Tru1VaKichHoatBuffDungKhung()
        {
            var inv = new Inventory();
            Assert.IsTrue(inv.Add("ca-phe", 2));
            Assert.IsTrue(inv.Use("ca-phe", TimeFrame.Sang));
            Assert.AreEqual(1, inv.Count("ca-phe"), "Dùng 1 thì trừ 1");
            Assert.AreEqual(5, inv.BuffFor(BaseStat.Tri, TimeFrame.Sang),
                "Cà phê +5 Trí trong khung Sáng (PROVISIONAL)");
            Assert.AreEqual(1, inv.ActiveBuffs.Count);
            Assert.AreEqual(TimeFrame.Sang, inv.ActiveBuffs[0].Frame);
        }

        [Test]
        public void Use_DoKhongCoBuff_Tru1KhongThemBuff()
        {
            var inv = new Inventory();
            Assert.IsTrue(inv.Add("ao-mua"));
            Assert.IsTrue(inv.Use("ao-mua", TimeFrame.Chieu), "Áo mưa dùng được dù không có buff");
            Assert.AreEqual(0, inv.Count("ao-mua"), "Dùng thì trừ 1");
            Assert.AreEqual(0, inv.ActiveBuffs.Count, "Áo mưa Effect = null nên không thêm buff");
            Assert.AreEqual(0, inv.BuffFor(BaseStat.The, TimeFrame.Chieu));
        }

        [Test]
        public void Use_BuffApDungKhungCatalog_DungLucSang_VanVaoChieu()
        {
            // ĐÃ SỬA 18/11 (bug test-report.md đợt 18:50): trước đây Use ghi đè khung
            // buff bằng khung lúc dùng nên cơm tấm (catalog ghi Chiều) dùng lúc Sáng
            // thì buff rơi vào Sáng. Hành vi đúng: buff áp đúng khung ghi trong catalog.
            var inv = new Inventory();
            Assert.IsTrue(inv.Add("com-tam"));
            Assert.IsTrue(inv.Use("com-tam", TimeFrame.Sang));
            Assert.AreEqual(0, inv.BuffFor(BaseStat.The, TimeFrame.Sang),
                "Dùng lúc Sáng nhưng buff catalog là Chiều nên Sáng không nhận buff");
            Assert.AreEqual(5, inv.BuffFor(BaseStat.The, TimeFrame.Chieu),
                "Cơm tấm +5 Thể trong khung Chiều như catalog ghi (PROVISIONAL)");
            Assert.AreEqual(TimeFrame.Chieu, inv.ActiveBuffs[0].Frame);
        }

        [Test]
        public void Use_BuffCatalogKhungChieu_DungLucToi_VanVaoChieu()
        {
            // Hồi quy Bug 2 với khung khác: cơm tấm dùng lúc Tối vẫn buff vào Chiều.
            var inv = new Inventory();
            Assert.IsTrue(inv.Add("com-tam"));
            Assert.IsTrue(inv.Use("com-tam", TimeFrame.Toi));
            Assert.AreEqual(0, inv.BuffFor(BaseStat.The, TimeFrame.Toi));
            Assert.AreEqual(5, inv.BuffFor(BaseStat.The, TimeFrame.Chieu));
            Assert.AreEqual(TimeFrame.Chieu, inv.ActiveBuffs[0].Frame);
        }

        [Test]
        public void Use_BuffCatalogKhungSang_DungLucChieu_EndFrameTheoKhungCatalog()
        {
            // Hồi quy Bug 2: cà phê (catalog ghi Sáng) dùng lúc Chiều thì buff vào
            // Sáng — nên hết khung Chiều buff vẫn còn, hết khung Sáng buff mới mất.
            var inv = new Inventory();
            Assert.IsTrue(inv.Add("ca-phe"));
            Assert.IsTrue(inv.Use("ca-phe", TimeFrame.Chieu));
            Assert.AreEqual(5, inv.BuffFor(BaseStat.Tri, TimeFrame.Sang));
            Assert.AreEqual(0, inv.BuffFor(BaseStat.Tri, TimeFrame.Chieu));

            inv.EndFrame(TimeFrame.Chieu);
            Assert.AreEqual(5, inv.BuffFor(BaseStat.Tri, TimeFrame.Sang),
                "Hết khung Chiều không xóa buff khung Sáng");
            inv.EndFrame(TimeFrame.Sang);
            Assert.AreEqual(0, inv.BuffFor(BaseStat.Tri, TimeFrame.Sang),
                "Hết khung Sáng thì buff khung Sáng mất");
            Assert.AreEqual(0, inv.ActiveBuffs.Count);
        }

        // --- BuffFor: cộng dồn cùng stat + khung, khác khung/stat không tính ---

        [Test]
        public void BuffFor_CongDonCungStatVaKhung()
        {
            var inv = new Inventory();
            Assert.IsTrue(inv.Add("com-tam", 2));
            Assert.IsTrue(inv.Use("com-tam", TimeFrame.Chieu));
            Assert.IsTrue(inv.Use("com-tam", TimeFrame.Chieu));
            Assert.AreEqual(10, inv.BuffFor(BaseStat.The, TimeFrame.Chieu),
                "2 lần cơm tấm cùng khung Chiều: 5 + 5 = 10");
        }

        [Test]
        public void BuffFor_KhacKhungVaKhacStat_KhongTinh()
        {
            var inv = new Inventory();
            Assert.IsTrue(inv.Add("ca-phe"));
            Assert.IsTrue(inv.Use("ca-phe", TimeFrame.Sang)); // +5 Trí, khung Sáng
            Assert.AreEqual(0, inv.BuffFor(BaseStat.Tri, TimeFrame.Chieu), "Khác khung thì không tính");
            Assert.AreEqual(0, inv.BuffFor(BaseStat.Tri, TimeFrame.Toi), "Khác khung thì không tính");
            Assert.AreEqual(0, inv.BuffFor(BaseStat.The, TimeFrame.Sang), "Khác chỉ số thì không tính");
            Assert.AreEqual(0, inv.BuffFor(BaseStat.Tam, TimeFrame.Sang), "Khác chỉ số thì không tính");
        }

        // --- EndFrame: xóa buff đúng khung, giữ buff khung khác ---

        [Test]
        public void EndFrame_XoaBuffDungKhungGiuBuffKhungKhac()
        {
            var inv = new Inventory();
            Assert.IsTrue(inv.Add("ca-phe"));
            Assert.IsTrue(inv.Add("com-tam"));
            Assert.IsTrue(inv.Use("ca-phe", TimeFrame.Sang));  // +5 Trí, Sáng
            Assert.IsTrue(inv.Use("com-tam", TimeFrame.Chieu)); // +5 Thể, Chiều
            Assert.AreEqual(2, inv.ActiveBuffs.Count);

            inv.EndFrame(TimeFrame.Sang);
            Assert.AreEqual(0, inv.BuffFor(BaseStat.Tri, TimeFrame.Sang), "Hết khung Sáng thì buff Sáng mất");
            Assert.AreEqual(5, inv.BuffFor(BaseStat.The, TimeFrame.Chieu), "Buff khung Chiều vẫn còn");
            Assert.AreEqual(1, inv.ActiveBuffs.Count);

            inv.EndFrame(TimeFrame.Chieu);
            Assert.AreEqual(0, inv.BuffFor(BaseStat.The, TimeFrame.Chieu), "Hết khung Chiều thì buff Chiều mất");
            Assert.AreEqual(0, inv.ActiveBuffs.Count);
        }

        [Test]
        public void EndFrame_KhungKhongCoBuff_KhongAnhHuong()
        {
            var inv = new Inventory();
            Assert.IsTrue(inv.Add("ca-phe"));
            Assert.IsTrue(inv.Use("ca-phe", TimeFrame.Sang));
            inv.EndFrame(TimeFrame.Toi); // khung Tối không có buff nào
            Assert.AreEqual(5, inv.BuffFor(BaseStat.Tri, TimeFrame.Sang), "Buff khung Sáng vẫn còn");
            Assert.AreEqual(1, inv.ActiveBuffs.Count);
        }

        // --- ItemCatalog.Get: id lạ -> null; 4 item slice ---

        [Test]
        public void ItemCatalog_Get_IdLa_TraNull()
        {
            Assert.IsNull(ItemCatalog.Get("khong-ton-tai"));
            Assert.IsNull(ItemCatalog.Get(""));
        }

        [Test]
        public void ItemCatalog_4ItemSlice_GiaVaTinhChat()
        {
            // Giá + buff là PROVISIONAL (số cấu hình slice, chưa chốt GDD).
            Assert.AreEqual(4, ItemCatalog.Items.Count, "Slice đầu có đúng 4 vật phẩm");

            var comTam = ItemCatalog.Get("com-tam");
            Assert.IsNotNull(comTam);
            Assert.AreEqual(35_000, comTam!.PriceVnd);
            Assert.IsTrue(comTam.Stackable);
            Assert.AreEqual(new Buff(BaseStat.The, 5, TimeFrame.Chieu), comTam.Effect);
            Assert.IsNull(comTam.UnlockNote);

            var caPhe = ItemCatalog.Get("ca-phe");
            Assert.IsNotNull(caPhe);
            Assert.AreEqual(25_000, caPhe!.PriceVnd);
            Assert.IsTrue(caPhe.Stackable);
            Assert.AreEqual(new Buff(BaseStat.Tri, 5, TimeFrame.Sang), caPhe.Effect);
            Assert.IsNull(caPhe.UnlockNote);

            var sach = ItemCatalog.Get("sach");
            Assert.IsNotNull(sach);
            Assert.AreEqual(80_000, sach!.PriceVnd);
            Assert.IsTrue(sach.Stackable);
            Assert.AreEqual(new Buff(BaseStat.Tri, 5, TimeFrame.Toi), sach.Effect);
            Assert.IsNull(sach.UnlockNote);

            var aoMua = ItemCatalog.Get("ao-mua");
            Assert.IsNotNull(aoMua);
            Assert.AreEqual(120_000, aoMua!.PriceVnd);
            Assert.IsFalse(aoMua.Stackable, "Áo mưa là đồ không stackable duy nhất trong slice");
            Assert.IsNull(aoMua.Effect, "Áo mưa không buff chỉ số");
            Assert.AreEqual("Làm được ca mưa, không bị ướt", aoMua.UnlockNote);
        }
    }
}
