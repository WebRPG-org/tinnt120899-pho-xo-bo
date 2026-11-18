// Phố Xô Bồ — Test EditMode cho khám phá hotspot (Exploration.cs, kiểu Treasure of Nadia).
// Chạy bằng Unity Test Runner (EditMode), KHÔNG chạy được trên VM này (không có Unity).
// API thật đang test: Exploration (Hotspots, Get, HotspotsInDistrict, CanFastTravel,
// Explore, NewGameDay, FastTravelUnlockedSlice), Hotspot (DistrictId, BestFrame,
// MaterialId, AmountPerVisit), MaterialIds, GuideHint.HintForDistrict,
// Districts.All (18 khu đã chốt).
//
// Số PROVISIONAL (chưa chốt GDD, lấy đúng comment trong Exploration.cs — đổi code là test
// phải đổi theo): 5 hotspot slice ở 4 khu 1 Xóm Trọ Cũ, 2 Chợ Đầu Mối, 17 Công Viên
// An Bình, 18 Phố Đi Bộ – Chợ Đêm — hs-cho-sang (khu 2, Sáng, lá chuối ×2),
// hs-cho-chieu (khu 2, Chiều, sắt vụn ×1), hs-tro-toi (khu 1, Tối, chai nhựa ×2),
// hs-cong-vien (khu 17, Chiều, ván gỗ ×1), hs-cho-dem (khu 18, Tối, vải vụn ×2);
// fast-travel slice mở 4 khu {1, 2, 17, 18}; mỗi hotspot chỉ khám phá 1 lần / 1 ngày game.
// Lưu ý hành vi thật (ghi nhận, chưa phải kiểm chứng kỳ vọng):
// - Explore NHẬN tham số gameDay nhưng KHÔNG DÙNG tới: đổi ngày mà không gọi
//   NewGameDay thì hotspot vẫn tính là đã khám phá (xem test
//   Explore_DoiGameDayNhungChuaNewGameDay_VanFalse). Ngày mới chỉ có hiệu lực khi
//   người gọi tự gọi NewGameDay để xóa visitedToday.
// - CanFastTravel kiểm tra khu có trong Districts.All (18 khu) TRƯỚC rồi mới kiểm
//   tra unlocked, nên khu không tồn tại trả false dù có trong danh sách unlocked.
using System.Collections.Generic;
using NUnit.Framework;

namespace PhoXoBo.Tests
{
    [TestFixture]
    public class ExplorationTests
    {
        // --- Hotspots: 5 điểm (đúng khu 1/2/17/18, đúng MaterialId + AmountPerVisit) ---

        [Test]
        public void Hotspots_Co5Diem_DungKhuVatVaSoLuong()
        {
            // Danh sách hotspot là PROVISIONAL (số cấu hình slice, chưa chốt GDD).
            Assert.AreEqual(5, Exploration.Hotspots.Count, "Slice đầu có đúng 5 hotspot");

            var choSang = Exploration.Get("hs-cho-sang");
            Assert.IsNotNull(choSang);
            Assert.AreEqual(2, choSang!.DistrictId, "Sạp rau buổi sáng ở khu 2 Chợ Đầu Mối");
            Assert.AreEqual(TimeFrame.Sang, choSang.BestFrame);
            Assert.AreEqual(MaterialIds.LaChuoi, choSang.MaterialId);
            Assert.AreEqual(2, choSang.AmountPerVisit);

            var choChieu = Exploration.Get("hs-cho-chieu");
            Assert.IsNotNull(choChieu);
            Assert.AreEqual(2, choChieu!.DistrictId, "Góc phế liệu chợ ở khu 2 Chợ Đầu Mối");
            Assert.AreEqual(TimeFrame.Chieu, choChieu.BestFrame);
            Assert.AreEqual(MaterialIds.SatVun, choChieu.MaterialId);
            Assert.AreEqual(1, choChieu.AmountPerVisit);

            var troToi = Exploration.Get("hs-tro-toi");
            Assert.IsNotNull(troToi);
            Assert.AreEqual(1, troToi!.DistrictId, "Hẻm trọ buổi tối ở khu 1 Xóm Trọ Cũ");
            Assert.AreEqual(TimeFrame.Toi, troToi.BestFrame);
            Assert.AreEqual(MaterialIds.ChaiNhua, troToi.MaterialId);
            Assert.AreEqual(2, troToi.AmountPerVisit);

            var congVien = Exploration.Get("hs-cong-vien");
            Assert.IsNotNull(congVien);
            Assert.AreEqual(17, congVien!.DistrictId, "Ghế đá công viên ở khu 17 Công Viên An Bình");
            Assert.AreEqual(TimeFrame.Chieu, congVien.BestFrame);
            Assert.AreEqual(MaterialIds.VanGo, congVien.MaterialId);
            Assert.AreEqual(1, congVien.AmountPerVisit);

            var choDem = Exploration.Get("hs-cho-dem");
            Assert.IsNotNull(choDem);
            Assert.AreEqual(18, choDem!.DistrictId, "Sạp đêm cuối phố ở khu 18 Phố Đi Bộ – Chợ Đêm");
            Assert.AreEqual(TimeFrame.Toi, choDem.BestFrame);
            Assert.AreEqual(MaterialIds.VaiVun, choDem.MaterialId);
            Assert.AreEqual(2, choDem.AmountPerVisit);
        }

        [Test]
        public void Get_IdLa_TraNull()
        {
            Assert.IsNull(Exploration.Get("khong-ton-tai"));
            Assert.IsNull(Exploration.Get(""));
        }

        // --- HotspotsInDistrict: khung tốt lên trước ---

        [Test]
        public void HotspotsInDistrict_KhungTotLenTruoc()
        {
            // Khu 2 có 2 hotspot: hs-cho-sang (khung tốt Sáng) + hs-cho-chieu (khung tốt Chiều).
            var sang = Exploration.HotspotsInDistrict(2, TimeFrame.Sang);
            Assert.AreEqual(2, sang.Count);
            Assert.AreEqual("hs-cho-sang", sang[0].Id, "Khung Sáng thì hotspot khung Sáng lên trước");
            Assert.AreEqual("hs-cho-chieu", sang[1].Id);

            var chieu = Exploration.HotspotsInDistrict(2, TimeFrame.Chieu);
            Assert.AreEqual(2, chieu.Count);
            Assert.AreEqual("hs-cho-chieu", chieu[0].Id, "Khung Chiều thì hotspot khung Chiều lên trước");
            Assert.AreEqual("hs-cho-sang", chieu[1].Id);

            // Khung Tối không phải khung tốt của hotspot nào ở khu 2 -> giữ nguyên thứ tự bảng.
            var toi = Exploration.HotspotsInDistrict(2, TimeFrame.Toi);
            Assert.AreEqual(2, toi.Count);
            Assert.AreEqual("hs-cho-sang", toi[0].Id);
            Assert.AreEqual("hs-cho-chieu", toi[1].Id);
        }

        [Test]
        public void HotspotsInDistrict_Khu1HotspotVaKhuKhongCoHotspot()
        {
            var khu1 = Exploration.HotspotsInDistrict(1, TimeFrame.Toi);
            Assert.AreEqual(1, khu1.Count);
            Assert.AreEqual("hs-tro-toi", khu1[0].Id, "Khu 1 chỉ có 1 hotspot, khung tốt Tối lên đầu");

            Assert.AreEqual(0, Exploration.HotspotsInDistrict(3, TimeFrame.Sang).Count,
                "Khu 3 Khu Công Nhân chưa có hotspot nào trong slice");
            Assert.AreEqual(0, Exploration.HotspotsInDistrict(99, TimeFrame.Sang).Count,
                "Khu không tồn tại thì trả danh sách rỗng");
        }

        // --- CanFastTravel: khu đã mở -> true, chưa mở -> false, không tồn tại -> false, null -> false ---

        [Test]
        public void CanFastTravel_KhuDaMo_TraTrue()
        {
            // FastTravelUnlockedSlice = {1, 2, 17, 18} (PROVISIONAL — slice đầu).
            Assert.AreEqual(4, Exploration.FastTravelUnlockedSlice.Count);
            foreach (var khu in Exploration.FastTravelUnlockedSlice)
                Assert.IsTrue(Exploration.CanFastTravel(khu, Exploration.FastTravelUnlockedSlice),
                    $"Khu {khu} đã mở fast-travel trong slice");
        }

        [Test]
        public void CanFastTravel_KhuChuaMo_TraFalse()
        {
            Assert.IsFalse(Exploration.CanFastTravel(3, Exploration.FastTravelUnlockedSlice),
                "Khu 3 có trong 18 khu nhưng chưa mở trong slice");
            Assert.IsFalse(Exploration.CanFastTravel(5, Exploration.FastTravelUnlockedSlice),
                "Khu 5 có trong 18 khu nhưng chưa mở trong slice");
            Assert.IsFalse(Exploration.CanFastTravel(1, new List<int>()),
                "Danh sách unlocked trống thì khu đã mở trong slice cũng không đi được");
        }

        [Test]
        public void CanFastTravel_KhuKhongTonTai_TraFalse()
        {
            Assert.IsFalse(Exploration.CanFastTravel(99, Exploration.FastTravelUnlockedSlice),
                "Khu 99 không có trong 18 khu");
            Assert.IsFalse(Exploration.CanFastTravel(0, Exploration.FastTravelUnlockedSlice),
                "Khu 0 không có trong 18 khu");
            // Khu không tồn tại trả false DÙ có trong danh sách unlocked (code kiểm tra
            // Districts.All trước rồi mới kiểm tra unlocked).
            Assert.IsFalse(Exploration.CanFastTravel(99, new List<int> { 99 }),
                "Khu 99 có trong unlocked nhưng không có trong 18 khu thì vẫn false");
        }

        [Test]
        public void CanFastTravel_Null_TraFalse()
        {
            Assert.IsFalse(Exploration.CanFastTravel(1, null!),
                "Danh sách unlocked null thì không fast-travel được");
        }

        // --- Explore: nhặt đúng số nguyên liệu, 1 lần/ngày, ngày mới khám phá lại được ---

        [Test]
        public void Explore_NhatDungSoNguyenLieu()
        {
            var visited = new HashSet<string>();
            var materials = new Dictionary<string, int>();
            Assert.IsTrue(Exploration.Explore("hs-cho-sang", 1, visited, materials));
            Assert.AreEqual(2, materials[MaterialIds.LaChuoi], "Sạp rau buổi sáng nhặt 2 lá chuối");
            Assert.IsTrue(visited.Contains("hs-cho-sang"), "Đã khám phá thì ghi vào visitedToday");

            Assert.IsTrue(Exploration.Explore("hs-cho-chieu", 1, visited, materials));
            Assert.AreEqual(1, materials[MaterialIds.SatVun], "Góc phế liệu chợ nhặt 1 sắt vụn");
            Assert.AreEqual(2, materials[MaterialIds.LaChuoi], "Khám phá hotspot khác không đổi số lá chuối");
        }

        [Test]
        public void Explore_Lan2CungNgay_TraFalseVaKhongCongThem()
        {
            var visited = new HashSet<string>();
            var materials = new Dictionary<string, int>();
            Assert.IsTrue(Exploration.Explore("hs-tro-toi", 1, visited, materials));
            Assert.AreEqual(2, materials[MaterialIds.ChaiNhua]);

            Assert.IsFalse(Exploration.Explore("hs-tro-toi", 1, visited, materials),
                "Khám phá lần 2 cùng ngày game thì trả false");
            Assert.AreEqual(2, materials[MaterialIds.ChaiNhua], "Lần 2 không cộng thêm chai nhựa");
        }

        [Test]
        public void Explore_NgayMoiSauNewGameDay_KhamPhaLaiDuoc()
        {
            var visited = new HashSet<string>();
            var materials = new Dictionary<string, int>();
            Assert.IsTrue(Exploration.Explore("hs-cong-vien", 1, visited, materials));
            Assert.AreEqual(1, materials[MaterialIds.VanGo]);

            Exploration.NewGameDay(visited);
            Assert.AreEqual(0, visited.Count, "Sang ngày mới thì NewGameDay xóa lượt khám phá trong ngày");
            Assert.IsTrue(Exploration.Explore("hs-cong-vien", 2, visited, materials),
                "Ngày mới thì khám phá lại được (kiểu Nadia: quay lại địa điểm cũ có đồ mới)");
            Assert.AreEqual(2, materials[MaterialIds.VanGo], "Ngày mới nhặt thêm 1 ván gỗ");
        }

        [Test]
        public void Explore_DoiGameDayNhungChuaNewGameDay_VanFalse()
        {
            // HÀNH VI LẠ — ghi nhận, chưa sửa code: Explore nhận tham số gameDay nhưng
            // KHÔNG DÙNG tới trong hàm; chỉ NewGameDay mới xóa visitedToday. Đổi số ngày
            // khi gọi Explore mà không gọi NewGameDay thì hotspot vẫn tính là đã khám
            // phá. Test này khóa hành vi hiện tại; nếu code dùng gameDay để tự reset
            // thì test này phải đổi theo.
            var visited = new HashSet<string>();
            var materials = new Dictionary<string, int>();
            Assert.IsTrue(Exploration.Explore("hs-cho-dem", 1, visited, materials));
            Assert.IsFalse(Exploration.Explore("hs-cho-dem", 2, visited, materials),
                "Lạ: sang ngày 2 nhưng chưa NewGameDay thì vẫn false");
            Assert.AreEqual(2, materials[MaterialIds.VaiVun], "Không cộng thêm vải vụn");
        }

        [Test]
        public void Explore_HotspotLa_TraFalse()
        {
            var visited = new HashSet<string>();
            var materials = new Dictionary<string, int>();
            Assert.IsFalse(Exploration.Explore("khong-ton-tai", 1, visited, materials));
            Assert.AreEqual(0, visited.Count, "Hotspot lạ thì không ghi vào visitedToday");
            Assert.AreEqual(0, materials.Count, "Hotspot lạ thì không nhặt được gì");
        }

        // --- GuideHint.HintForDistrict: mỗi khu nhắc đúng NPC, khu lạ -> gợi ý chung ---

        [Test]
        public void GuideHint_MoiKhuNhacDungNPC()
        {
            Assert.That(GuideHint.HintForDistrict(1, "chế xe đẩy"),
                Does.Contain("Cô Tư"), "Khu 1 Xóm Trọ Cũ do Cô Tư (chủ trọ) gợi ý");
            Assert.That(GuideHint.HintForDistrict(2, "chế đèn soi"),
                Does.Contain("Chị Lệ"), "Khu 2 Chợ Đầu Mối do Chị Lệ (sạp rau) gợi ý");
            Assert.That(GuideHint.HintForDistrict(17, "tìm ván gỗ"),
                Does.Contain("Ông Ba"), "Khu 17 Công Viên An Bình do Ông Ba gợi ý");
            Assert.That(GuideHint.HintForDistrict(18, "bán hàng đêm"),
                Does.Contain("Anh Hải"), "Khu 18 Phố Đi Bộ – Chợ Đêm do Anh Hải gợi ý");
        }

        [Test]
        public void GuideHint_GoiYNhacLaiMucTieuHienTai()
        {
            Assert.That(GuideHint.HintForDistrict(1, "chế xe đẩy"), Does.Contain("chế xe đẩy"),
                "Gợi ý khu 1 nhắc lại mục tiêu hiện tại");
            Assert.That(GuideHint.HintForDistrict(18, "bán hàng đêm"), Does.Contain("bán hàng đêm"),
                "Gợi ý khu 18 nhắc lại mục tiêu hiện tại");
            Assert.That(GuideHint.HintForDistrict(99, "tìm sách"), Does.Contain("tìm sách"),
                "Gợi ý chung cũng nhắc lại mục tiêu hiện tại");
        }

        [Test]
        public void GuideHint_KhuLa_GoiYChung()
        {
            Assert.That(GuideHint.HintForDistrict(99, "làm quest"),
                Does.Contain("Bạn thân"), "Khu lạ thì bạn thân gợi ý chung");
            Assert.That(GuideHint.HintForDistrict(3, "làm quest"),
                Does.Contain("Bạn thân"), "Khu 3 chưa có NPC gợi ý riêng nên dùng gợi ý chung");
            Assert.That(GuideHint.HintForDistrict(99, "làm quest"),
                Does.Contain("Bản đồ"), "Gợi ý chung nhắc mở điện thoại coi Bản đồ");
        }

        [Test]
        public void GuideHint_MucTieuRong_DungMacDinh()
        {
            Assert.That(GuideHint.HintForDistrict(1, ""),
                Does.Contain("chưa có mục tiêu rõ"), "Mục tiêu rỗng thì dùng chữ mặc định");
            Assert.That(GuideHint.HintForDistrict(1, "   "),
                Does.Contain("chưa có mục tiêu rõ"), "Mục tiêu chỉ có khoảng trắng thì dùng chữ mặc định");
            Assert.That(GuideHint.HintForDistrict(1, null!),
                Does.Contain("chưa có mục tiêu rõ"), "Mục tiêu null thì dùng chữ mặc định");
        }
    }
}
