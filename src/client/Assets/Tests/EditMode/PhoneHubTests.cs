// Phố Xô Bồ — Test EditMode cho điện thoại hub (PhoneHub.cs, Mục 2 đã chốt).
// Chạy bằng Unity Test Runner (EditMode), KHÔNG chạy được trên VM này (không có Unity).
// API thật đang test: PhoneHub.TabOrder, PhoneHub.Open, PhoneHub.Close,
// PhoneHub.Toggle, PhoneHub.SelectTab, PhoneHub.Notify, PhoneHub.UnreadCount,
// PhoneHub.TotalUnread, PhoneHub.IsOpen, PhoneHub.CurrentTab, sự kiện
// PhoneHub.TabChanged và PhoneHub.OpenChanged; enum PhoneTab (9 tab).
//
// Số / thứ tự lấy đúng code, Mục 2 đã chốt — không có số PROVISIONAL ở đây:
// 9 tab đúng thứ tự GDD: DanhBaTinNhan, NganHang, BanDo, ViecLam, Cho, HocTap,
// SucKhoe, XaHoi, CaiDat; tab mặc định khi mở là DanhBaTinNhan.
// Lưu ý hành vi thật (ghi nhận, chưa phải kiểm chứng kỳ vọng):
// - Open(tab) luôn gọi SelectTab nên luôn kích hoạt TabChanged (kể cả mở đúng tab
//   đang hiển thị) và luôn đánh dấu đã đọc tab đó (UnreadCount về 0).
// - SelectTab luôn kích hoạt TabChanged, kể cả chọn đúng tab hiện tại.
// - Notify đếm cả khi điện thoại đang đóng (không kiểm tra IsOpen).
// - Close không đổi CurrentTab, nên Toggle mở lại giữ đúng tab trước khi đóng.
using NUnit.Framework;

namespace PhoXoBo.Tests
{
    [TestFixture]
    public class PhoneHubTests
    {
        private static readonly PhoneTab[] TabChuan =
        {
            PhoneTab.DanhBaTinNhan,
            PhoneTab.NganHang,
            PhoneTab.BanDo,
            PhoneTab.ViecLam,
            PhoneTab.Cho,
            PhoneTab.HocTap,
            PhoneTab.SucKhoe,
            PhoneTab.XaHoi,
            PhoneTab.CaiDat,
        };

        // --- TabOrder: đúng 9 tab, đúng thứ tự GDD, không trùng ---

        [Test]
        public void TabOrder_Dung9TabDungThuTu()
        {
            Assert.AreEqual(9, PhoneHub.TabOrder.Count);
            for (var i = 0; i < TabChuan.Length; i++)
                Assert.AreEqual(TabChuan[i], PhoneHub.TabOrder[i],
                    $"Tab thứ {i + 1} phải là {TabChuan[i]}");
        }

        [Test]
        public void TabOrder_KhongTrung()
        {
            var tabs = new System.Collections.Generic.HashSet<PhoneTab>(PhoneHub.TabOrder);
            Assert.AreEqual(PhoneHub.TabOrder.Count, tabs.Count, "TabOrder không được trùng tab");
        }

        // --- Open: IsOpen true, tab mặc định DanhBaTinNhan, OpenChanged kích hoạt ---

        [Test]
        public void Open_MoVaTabMacDinhDanhBaTinNhan()
        {
            var hub = new PhoneHub();
            Assert.IsFalse(hub.IsOpen, "Ban đầu điện thoại đang đóng");
            Assert.AreEqual(PhoneTab.DanhBaTinNhan, hub.CurrentTab, "Tab mặc định ban đầu là DanhBaTinNhan");

            hub.Open();
            Assert.IsTrue(hub.IsOpen);
            Assert.AreEqual(PhoneTab.DanhBaTinNhan, hub.CurrentTab, "Open() không tham số thì ở tab DanhBaTinNhan");
        }

        [Test]
        public void Open_VoiTabChiDinh()
        {
            var hub = new PhoneHub();
            hub.Open(PhoneTab.BanDo);
            Assert.IsTrue(hub.IsOpen);
            Assert.AreEqual(PhoneTab.BanDo, hub.CurrentTab, "Open(BanDo) thì mở thẳng tab Bản đồ");
        }

        [Test]
        public void Open_KichHoatOpenChangedTrue()
        {
            var hub = new PhoneHub();
            var dem = 0;
            bool? giaTriCuoi = null;
            hub.OpenChanged += mo => { dem++; giaTriCuoi = mo; };

            hub.Open();
            Assert.AreEqual(1, dem, "Open kích hoạt OpenChanged đúng 1 lần");
            Assert.IsTrue(giaTriCuoi, "OpenChanged khi mở phải nhận true");
        }

        [Test]
        public void Open_DanhDauDaDocTabMo()
        {
            // Open gọi SelectTab nên tab được mở sẽ bị đánh dấu đã đọc (UnreadCount về 0).
            var hub = new PhoneHub();
            hub.Notify(PhoneTab.DanhBaTinNhan);
            hub.Notify(PhoneTab.DanhBaTinNhan);
            Assert.AreEqual(2, hub.UnreadCount(PhoneTab.DanhBaTinNhan));
            hub.Open(); // mở tab mặc định DanhBaTinNhan
            Assert.AreEqual(0, hub.UnreadCount(PhoneTab.DanhBaTinNhan),
                "Mở tab DanhBaTinNhan thì tin chưa đọc của tab đó về 0");
        }

        // --- Close: IsOpen false, OpenChanged kích hoạt, giữ nguyên tab hiện tại ---

        [Test]
        public void Close_DongVaKichHoatOpenChangedFalse()
        {
            var hub = new PhoneHub();
            var dem = 0;
            bool? giaTriCuoi = null;
            hub.OpenChanged += mo => { dem++; giaTriCuoi = mo; };

            hub.Open();
            hub.Close();
            Assert.IsFalse(hub.IsOpen);
            Assert.AreEqual(2, dem, "Open + Close kích hoạt OpenChanged 2 lần");
            Assert.IsFalse(giaTriCuoi, "OpenChanged khi đóng phải nhận false");
        }

        [Test]
        public void Close_GiuNguyenTabHienTai()
        {
            var hub = new PhoneHub();
            hub.Open(PhoneTab.Cho);
            hub.Close();
            Assert.AreEqual(PhoneTab.Cho, hub.CurrentTab,
                "Đóng điện thoại không đổi tab — mở lại vẫn ở tab Chợ");
        }

        // --- Toggle: đóng ↔ mở, mở lại giữ tab hiện tại ---

        [Test]
        public void Toggle_DongMoLuanPhien()
        {
            var hub = new PhoneHub();
            Assert.IsFalse(hub.IsOpen);
            hub.Toggle();
            Assert.IsTrue(hub.IsOpen, "Đang đóng thì Toggle mở ra");
            hub.Toggle();
            Assert.IsFalse(hub.IsOpen, "Đang mở thì Toggle đóng lại");
            hub.Toggle();
            Assert.IsTrue(hub.IsOpen, "Toggle lần 3 lại mở ra");
        }

        [Test]
        public void Toggle_MoLaiGiuTabHienTai()
        {
            var hub = new PhoneHub();
            hub.Open();
            hub.SelectTab(PhoneTab.SucKhoe);
            hub.Close();
            hub.Toggle(); // mở lại, Toggle dùng CurrentTab hiện tại
            Assert.IsTrue(hub.IsOpen);
            Assert.AreEqual(PhoneTab.SucKhoe, hub.CurrentTab,
                "Toggle mở lại phải giữ tab Sức khỏe trước khi đóng, không quay về tab mặc định");
        }

        // --- SelectTab: đổi tab, TabChanged kích hoạt, mở tab thì UnreadCount tab đó về 0 ---

        [Test]
        public void SelectTab_DoiTabVaKichHoatTabChanged()
        {
            var hub = new PhoneHub();
            PhoneTab? tabNhan = null;
            var dem = 0;
            hub.TabChanged += tab => { dem++; tabNhan = tab; };

            hub.Open();
            dem = 0; // bỏ qua lần TabChanged do Open() gọi SelectTab mặc định
            Assert.IsTrue(hub.SelectTab(PhoneTab.ViecLam), "Chọn tab có trong TabOrder trả true");
            Assert.AreEqual(PhoneTab.ViecLam, hub.CurrentTab);
            Assert.AreEqual(1, dem, "SelectTab kích hoạt TabChanged đúng 1 lần");
            Assert.AreEqual(PhoneTab.ViecLam, tabNhan);
        }

        [Test]
        public void SelectTab_MoTabThiUnreadVe0()
        {
            var hub = new PhoneHub();
            hub.Open();
            hub.Notify(PhoneTab.NganHang);
            hub.Notify(PhoneTab.NganHang);
            hub.Notify(PhoneTab.BanDo);
            Assert.AreEqual(2, hub.UnreadCount(PhoneTab.NganHang));
            Assert.AreEqual(1, hub.UnreadCount(PhoneTab.BanDo));

            hub.SelectTab(PhoneTab.NganHang);
            Assert.AreEqual(0, hub.UnreadCount(PhoneTab.NganHang),
                "Mở tab Ngân hàng thì tin chưa đọc của tab đó về 0");
            Assert.AreEqual(1, hub.UnreadCount(PhoneTab.BanDo),
                "Tab Bản đồ chưa mở thì số chưa đọc giữ nguyên");
        }

        [Test]
        public void SelectTab_TabHienTaiVanKichHoatSuKien()
        {
            // Ghi nhận hành vi thật: SelectTab luôn kích hoạt TabChanged, kể cả khi
            // chọn đúng tab đang hiển thị (code không kiểm tra tab có đổi hay không).
            var hub = new PhoneHub();
            var dem = 0;
            hub.TabChanged += _ => dem++;
            hub.Open(); // 1 lần TabChanged do Open
            Assert.AreEqual(1, dem);
            hub.SelectTab(PhoneTab.DanhBaTinNhan); // đúng tab hiện tại
            Assert.AreEqual(2, dem, "Chọn lại đúng tab hiện tại vẫn kích hoạt TabChanged");
        }

        // --- Notify / UnreadCount / TotalUnread ---

        [Test]
        public void Notify_TangDungTab()
        {
            var hub = new PhoneHub();
            hub.Notify(PhoneTab.DanhBaTinNhan);
            Assert.AreEqual(1, hub.UnreadCount(PhoneTab.DanhBaTinNhan));
            hub.Notify(PhoneTab.DanhBaTinNhan);
            Assert.AreEqual(2, hub.UnreadCount(PhoneTab.DanhBaTinNhan));
            Assert.AreEqual(0, hub.UnreadCount(PhoneTab.NganHang),
                "Notify tab Danh bạ không làm tăng tab Ngân hàng");
        }

        [Test]
        public void Notify_NhieuTab_TotalUnreadCongDon()
        {
            var hub = new PhoneHub();
            Assert.AreEqual(0, hub.TotalUnread, "Ban đầu chưa có tin chưa đọc nào");
            hub.Notify(PhoneTab.DanhBaTinNhan);
            hub.Notify(PhoneTab.DanhBaTinNhan);
            hub.Notify(PhoneTab.NganHang);
            hub.Notify(PhoneTab.Cho);
            hub.Notify(PhoneTab.Cho);
            hub.Notify(PhoneTab.Cho);
            Assert.AreEqual(6, hub.TotalUnread, "Tổng = 2 Danh bạ + 1 Ngân hàng + 3 Chợ");
        }

        [Test]
        public void UnreadCount_TabChuaNotify_Bang0()
        {
            var hub = new PhoneHub();
            foreach (var tab in TabChuan)
                Assert.AreEqual(0, hub.UnreadCount(tab), $"Tab {tab} chưa notify thì UnreadCount bằng 0");
        }

        [Test]
        public void Notify_KhiDongVanDem()
        {
            // Ghi nhận hành vi thật: Notify không kiểm tra IsOpen nên tin đến lúc
            // điện thoại đang đóng vẫn được đếm, mở ra sẽ thấy chấm đỏ.
            var hub = new PhoneHub();
            Assert.IsFalse(hub.IsOpen);
            hub.Notify(PhoneTab.DanhBaTinNhan);
            Assert.AreEqual(1, hub.UnreadCount(PhoneTab.DanhBaTinNhan));
            Assert.AreEqual(1, hub.TotalUnread);
        }

        [Test]
        public void TotalUnread_GiamKhiMoTab()
        {
            var hub = new PhoneHub();
            hub.Notify(PhoneTab.DanhBaTinNhan);
            hub.Notify(PhoneTab.DanhBaTinNhan);
            hub.Notify(PhoneTab.NganHang);
            Assert.AreEqual(3, hub.TotalUnread);
            hub.Open(PhoneTab.DanhBaTinNhan); // mở tab Danh bạ -> đánh dấu đã đọc
            Assert.AreEqual(1, hub.TotalUnread, "Tổng chỉ còn 1 tin của tab Ngân hàng");
            Assert.AreEqual(0, hub.UnreadCount(PhoneTab.DanhBaTinNhan));
        }
    }
}
