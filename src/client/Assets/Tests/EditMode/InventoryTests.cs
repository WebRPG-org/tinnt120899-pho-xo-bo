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
// Lưu ý hành vi thật (ghi nhận, chưa phải kiểm chứng kỳ vọng):
// - Use GHI ĐÈ khung của buff trong catalog bằng khung hiện tại: cơm tấm (catalog
//   ghi khung Chiều) mà dùng lúc Sáng thì buff rơi vào khung Sáng, không phải Chiều
//   (xem test Use_KhungHienTaiGhiDeKhungCatalog).
// - Add đồ không stackable chỉ chặn khi túi ĐÃ CÓ món đó: Add("ao-mua", 2) lúc túi
//   trống vẫn trả true và giữ 2 cái (xem test Add_DoKhongStackable_Them2CungLuc).
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
        public void Add_DoKhongStackable_Them2CungLuc()
        {
            // HÀNH VI LẠ — ghi nhận, chưa sửa code: Add chỉ chặn khi Count(itemId) > 0,
            // nên Add("ao-mua", 2) lúc túi trống vẫn trả true và giữ 2 cái, dù áo mưa
            // là đồ không stackable (chỉ được giữ 1). Test này khóa hành vi hiện tại;
            // nếu code sửa chặn quantity > 1 thì test này phải đổi theo.
            var inv = new Inventory();
            Assert.IsTrue(inv.Add("ao-mua", 2));
            Assert.AreEqual(2, inv.Count("ao-mua"), "Lạ: túi trống + quantity 2 vẫn nhận 2 áo mưa");
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
        public void Use_KhungHienTaiGhiDeKhungCatalog()
        {
            // HÀNH VI LẠ — ghi nhận, chưa sửa code: Use thêm buff bằng
            // `def.Effect with { Frame = currentFrame }` nên khung ghi trong catalog
            // (cơm tấm = Chiều) bị ghi đè bằng khung lúc dùng. Cơm tấm dùng lúc Sáng
            // thì buff rơi vào Sáng, không phải Chiều như catalog ghi.
            var inv = new Inventory();
            Assert.IsTrue(inv.Add("com-tam"));
            Assert.IsTrue(inv.Use("com-tam", TimeFrame.Sang));
            Assert.AreEqual(5, inv.BuffFor(BaseStat.The, TimeFrame.Sang),
                "Lạ: dùng lúc Sáng thì buff vào Sáng");
            Assert.AreEqual(0, inv.BuffFor(BaseStat.The, TimeFrame.Chieu),
                "Lạ: khung Chiều trong catalog không nhận buff");
            Assert.AreEqual(TimeFrame.Sang, inv.ActiveBuffs[0].Frame);
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
