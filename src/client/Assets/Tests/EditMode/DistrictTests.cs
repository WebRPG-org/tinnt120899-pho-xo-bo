// Phố Xô Bồ — Test EditMode cho khu vực + xung đột danh hiệu (District.cs, TitleConflict.cs,
// Mục 3 đã chốt).
// Chạy bằng Unity Test Runner (EditMode), KHÔNG chạy được trên VM này (không có Unity).
// API thật đang test: Districts.All, Districts.ExpectedCount, Districts.IsValidCount,
// District (record Id / Name / Tier), enum Tier (LaoDong, CanTrungLuu, TrungLuu,
// ThuongLuu, SieuGiau, Chung), TitleConflict.IsBlocked, enum Alignment (chỉ khai báo,
// không dùng trong test vì IsBlocked không nhận Alignment).
//
// Số / danh sách lấy đúng code, Mục 3 đã chốt — không có số PROVISIONAL ở đây:
// đúng 18 khu, Id 1–18 theo đúng thứ tự trong Districts.All; tầng lớp LaoDong 1–4,
// CanTrungLuu 5–7, TrungLuu 8–10, ThuongLuu 11–13, SieuGiau 14–16, Chung 17–18.
// Lưu ý hành vi thật (ghi nhận, chưa phải kiểm chứng kỳ vọng):
// - IsBlocked so sánh chuỗi bằng == (phân biệt hoa/thường, khớp đúng từng ký tự).
// - TitleConflict chỉ chặn một chiều theo bảng BlockedBy: danh hiệu trong bảng chặn
//   danh hiệu/nghề muốn nhận, chiều ngược lại không tự động chặn (ví dụ "Cảnh sát"
//   đang có không chặn việc nhận "Tướng Cướp" — xem test IsBlocked_KhongChanNguoc).
using System.Collections.Generic;
using System.Linq;
using NUnit.Framework;

namespace PhoXoBo.Tests
{
    [TestFixture]
    public class DistrictTests
    {
        // Danh sách chuẩn — sao đúng từng tên trong Districts.All (kể cả dấu gạch ngang
        // en dash "–" trong "Phố Đi Bộ – Chợ Đêm"). Đổi khu trong code thì phải sửa cả đây.
        private static readonly (int Id, string Ten, Tier Tang)[] KhuChuan =
        {
            (1, "Xóm Trọ Cũ", Tier.LaoDong),
            (2, "Chợ Đầu Mối", Tier.LaoDong),
            (3, "Khu Công Nhân", Tier.LaoDong),
            (4, "Bến Xe Miền Đông", Tier.LaoDong),
            (5, "Làng Đại Học", Tier.CanTrungLuu),
            (6, "Chung Cư Cũ", Tier.CanTrungLuu),
            (7, "Phố Văn Phòng Nhỏ", Tier.CanTrungLuu),
            (8, "Khu Chung Cư Cao Cấp", Tier.TrungLuu),
            (9, "Phố Thương Mại", Tier.TrungLuu),
            (10, "Khu Công Nghệ", Tier.TrungLuu),
            (11, "Phố Tây", Tier.ThuongLuu),
            (12, "Khu Biệt Thự Ven Sông", Tier.ThuongLuu),
            (13, "Quận Tài Chính", Tier.ThuongLuu),
            (14, "Đảo Thượng Lưu", Tier.SieuGiau),
            (15, "Khu Penthouse", Tier.SieuGiau),
            (16, "Khu Sân Golf & Resort", Tier.SieuGiau),
            (17, "Công Viên An Bình", Tier.Chung),
            (18, "Phố Đi Bộ – Chợ Đêm", Tier.Chung),
        };

        // --- Districts.All: đúng 18 khu, đúng thứ tự 1–18, đúng tên từng khu ---

        [Test]
        public void All_CoDung18Khu()
        {
            Assert.AreEqual(18, Districts.All.Count);
        }

        [Test]
        public void All_DungThuTuId1Den18()
        {
            for (var i = 0; i < KhuChuan.Length; i++)
                Assert.AreEqual(KhuChuan[i].Id, Districts.All[i].Id,
                    $"Khu thứ {i + 1} phải có Id {KhuChuan[i].Id}");
        }

        [Test]
        public void All_DungTenTungKhu()
        {
            for (var i = 0; i < KhuChuan.Length; i++)
                Assert.AreEqual(KhuChuan[i].Ten, Districts.All[i].Name,
                    $"Khu Id {KhuChuan[i].Id} phải tên là '{KhuChuan[i].Ten}'");
        }

        [Test]
        public void All_DungTierTungKhu()
        {
            for (var i = 0; i < KhuChuan.Length; i++)
                Assert.AreEqual(KhuChuan[i].Tang, Districts.All[i].Tier,
                    $"Khu '{KhuChuan[i].Ten}' (Id {KhuChuan[i].Id}) phải thuộc tầng {KhuChuan[i].Tang}");
        }

        // --- Tier theo khoảng Id: LaoDong 1–4, CanTrungLuu 5–7, TrungLuu 8–10,
        // ThuongLuu 11–13, SieuGiau 14–16, Chung 17–18 ---

        [Test]
        public void Tier_LaoDong_1Den4()
        {
            foreach (var khu in Districts.All.Where(k => k.Id >= 1 && k.Id <= 4))
                Assert.AreEqual(Tier.LaoDong, khu.Tier, $"Khu Id {khu.Id} phải là LaoDong");
            Assert.AreEqual(4, Districts.All.Count(k => k.Tier == Tier.LaoDong));
        }

        [Test]
        public void Tier_CanTrungLuu_5Den7()
        {
            foreach (var khu in Districts.All.Where(k => k.Id >= 5 && k.Id <= 7))
                Assert.AreEqual(Tier.CanTrungLuu, khu.Tier, $"Khu Id {khu.Id} phải là CanTrungLuu");
            Assert.AreEqual(3, Districts.All.Count(k => k.Tier == Tier.CanTrungLuu));
        }

        [Test]
        public void Tier_TrungLuu_8Den10()
        {
            foreach (var khu in Districts.All.Where(k => k.Id >= 8 && k.Id <= 10))
                Assert.AreEqual(Tier.TrungLuu, khu.Tier, $"Khu Id {khu.Id} phải là TrungLuu");
            Assert.AreEqual(3, Districts.All.Count(k => k.Tier == Tier.TrungLuu));
        }

        [Test]
        public void Tier_ThuongLuu_11Den13()
        {
            foreach (var khu in Districts.All.Where(k => k.Id >= 11 && k.Id <= 13))
                Assert.AreEqual(Tier.ThuongLuu, khu.Tier, $"Khu Id {khu.Id} phải là ThuongLuu");
            Assert.AreEqual(3, Districts.All.Count(k => k.Tier == Tier.ThuongLuu));
        }

        [Test]
        public void Tier_SieuGiau_14Den16()
        {
            foreach (var khu in Districts.All.Where(k => k.Id >= 14 && k.Id <= 16))
                Assert.AreEqual(Tier.SieuGiau, khu.Tier, $"Khu Id {khu.Id} phải là SieuGiau");
            Assert.AreEqual(3, Districts.All.Count(k => k.Tier == Tier.SieuGiau));
        }

        [Test]
        public void Tier_Chung_17Den18()
        {
            foreach (var khu in Districts.All.Where(k => k.Id >= 17 && k.Id <= 18))
                Assert.AreEqual(Tier.Chung, khu.Tier, $"Khu Id {khu.Id} phải là Chung");
            Assert.AreEqual(2, Districts.All.Count(k => k.Tier == Tier.Chung));
        }

        // --- IsValidCount / ExpectedCount / không trùng Id, tên ---

        [Test]
        public void IsValidCount_True()
        {
            Assert.IsTrue(Districts.IsValidCount, "All có 18 khu thì IsValidCount phải true");
        }

        [Test]
        public void ExpectedCount_Bang18()
        {
            Assert.AreEqual(18, Districts.ExpectedCount);
            Assert.AreEqual(Districts.ExpectedCount, Districts.All.Count);
        }

        [Test]
        public void KhongTrungId()
        {
            var ids = Districts.All.Select(k => k.Id).ToList();
            Assert.AreEqual(ids.Count, ids.Distinct().Count(), "Không khu nào trùng Id");
        }

        [Test]
        public void KhongTrungTen()
        {
            var ten = Districts.All.Select(k => k.Name).ToList();
            Assert.AreEqual(ten.Count, ten.Distinct().Count(), "Không khu nào trùng tên");
        }

        [Test]
        public void Ten_KhongRong()
        {
            foreach (var khu in Districts.All)
                Assert.IsFalse(string.IsNullOrWhiteSpace(khu.Name), $"Khu Id {khu.Id} phải có tên");
        }

        // --- TitleConflict.IsBlocked: Tướng Cướp chặn Cảnh sát/Thẩm phán/Hải quan/Giáo viên ---

        [Test]
        public void TuongCuop_Chan4Nghe()
        {
            var dangCo = new[] { "Tướng Cướp" };
            Assert.IsTrue(TitleConflict.IsBlocked(dangCo, "Cảnh sát"));
            Assert.IsTrue(TitleConflict.IsBlocked(dangCo, "Thẩm phán"));
            Assert.IsTrue(TitleConflict.IsBlocked(dangCo, "Hải quan"));
            Assert.IsTrue(TitleConflict.IsBlocked(dangCo, "Giáo viên"));
        }

        [Test]
        public void TuongCuop_KhongChanNgheKhac()
        {
            var dangCo = new[] { "Tướng Cướp" };
            Assert.IsFalse(TitleConflict.IsBlocked(dangCo, "Bác sĩ"));
            Assert.IsFalse(TitleConflict.IsBlocked(dangCo, "Kỹ sư"));
            Assert.IsFalse(TitleConflict.IsBlocked(dangCo, "Đầu bếp"));
        }

        [Test]
        public void TrumBuonLau_Chan4NgheNhuTuongCuop()
        {
            // Trùm Buôn Lậu chặn cùng 4 nghề với Tướng Cướp (lấy đúng bảng trong code).
            var dangCo = new[] { "Trùm Buôn Lậu" };
            Assert.IsTrue(TitleConflict.IsBlocked(dangCo, "Cảnh sát"));
            Assert.IsTrue(TitleConflict.IsBlocked(dangCo, "Thẩm phán"));
            Assert.IsTrue(TitleConflict.IsBlocked(dangCo, "Hải quan"));
            Assert.IsTrue(TitleConflict.IsBlocked(dangCo, "Giáo viên"));
        }

        // --- Tham Quan chặn Thanh Liêm + Người Hùng ---

        [Test]
        public void ThamQuan_ChanThanhLiemVaNguoiHung()
        {
            var dangCo = new[] { "Tham Quan" };
            Assert.IsTrue(TitleConflict.IsBlocked(dangCo, "Thanh Liêm"));
            Assert.IsTrue(TitleConflict.IsBlocked(dangCo, "Người Hùng"));
        }

        [Test]
        public void ThamQuan_KhongChanKhac()
        {
            var dangCo = new[] { "Tham Quan" };
            Assert.IsFalse(TitleConflict.IsBlocked(dangCo, "Cảnh sát"));
            Assert.IsFalse(TitleConflict.IsBlocked(dangCo, "Giáo viên"));
        }

        // --- Kẻ Lừa Đảo chặn Luật Sư Chính Trực nhưng KHÔNG chặn Luật Sư Bào Chữa ---

        [Test]
        public void KeLuaDao_ChanLuatSuChinhTruc_KhongChanLuatSuBaoChua()
        {
            var dangCo = new[] { "Kẻ Lừa Đảo" };
            Assert.IsTrue(TitleConflict.IsBlocked(dangCo, "Luật Sư Chính Trực"));
            Assert.IsFalse(TitleConflict.IsBlocked(dangCo, "Luật Sư Bào Chữa"),
                "Code ghi rõ: không chặn 'Luật Sư Bào Chữa' — hai danh hiệu luật sư khác nhau");
        }

        // --- Học Giả / Tiến sĩ chặn Kẻ Bỏ Học ---

        [Test]
        public void HocGiaVaTienSi_ChanKeBoHoc()
        {
            Assert.IsTrue(TitleConflict.IsBlocked(new[] { "Học Giả" }, "Kẻ Bỏ Học"));
            Assert.IsTrue(TitleConflict.IsBlocked(new[] { "Tiến sĩ" }, "Kẻ Bỏ Học"));
        }

        [Test]
        public void HocGia_KhongChanKhac()
        {
            Assert.IsFalse(TitleConflict.IsBlocked(new[] { "Học Giả" }, "Cảnh sát"));
            Assert.IsFalse(TitleConflict.IsBlocked(new[] { "Tiến sĩ" }, "Thanh Liêm"));
        }

        [Test]
        public void TyPhuTuThien_ChanKeKeoKiet()
        {
            // Lấy đúng bảng trong code (không nằm trong yêu cầu gốc nhưng là cặp xung đột thật).
            Assert.IsTrue(TitleConflict.IsBlocked(new[] { "Tỷ Phú Từ Thiện" }, "Kẻ Keo Kiệt"));
            Assert.IsFalse(TitleConflict.IsBlocked(new[] { "Tỷ Phú Từ Thiện" }, "Người Hùng"));
        }

        // --- Danh hiệu không trong bảng → không chặn gì; nhiều danh hiệu, 1 cái chặn là đủ ---

        [Test]
        public void DanhHieuLa_KhongChanGi()
        {
            var dangCo = new[] { "Danh hiệu lạ chưa có trong bảng" };
            Assert.IsFalse(TitleConflict.IsBlocked(dangCo, "Cảnh sát"));
            Assert.IsFalse(TitleConflict.IsBlocked(dangCo, "Kẻ Bỏ Học"));
            Assert.IsFalse(TitleConflict.IsBlocked(dangCo, "Thanh Liêm"));
        }

        [Test]
        public void KhongCoDanhHieu_KhongChanGi()
        {
            Assert.IsFalse(TitleConflict.IsBlocked(new string[0], "Cảnh sát"));
            Assert.IsFalse(TitleConflict.IsBlocked(new List<string>(), "Kẻ Bỏ Học"));
        }

        [Test]
        public void NhieuDanhHieu_MotCaiChanLaDu()
        {
            // "Học Giả" không chặn "Cảnh sát", nhưng "Tướng Cướp" chặn — chỉ cần 1 cái chặn là đủ.
            var dangCo = new[] { "Học Giả", "Tướng Cướp" };
            Assert.IsTrue(TitleConflict.IsBlocked(dangCo, "Cảnh sát"));
            // Cả hai đều không chặn "Bác sĩ" thì kết quả vẫn là không chặn.
            Assert.IsFalse(TitleConflict.IsBlocked(dangCo, "Bác sĩ"));
        }

        [Test]
        public void IsBlocked_KhongChanNguoc()
        {
            // Chặn chỉ một chiều theo bảng: đang có "Cảnh sát" (nghề bị chặn) thì
            // việc nhận "Tướng Cướp" KHÔNG bị chặn — bảng không có dòng ngược lại.
            // Ghi nhận hành vi thật của code; muốn đổi phe cần quest "Cải tà quy chính"
            // theo comment trong TitleConflict.cs.
            Assert.IsFalse(TitleConflict.IsBlocked(new[] { "Cảnh sát" }, "Tướng Cướp"));
            Assert.IsFalse(TitleConflict.IsBlocked(new[] { "Kẻ Bỏ Học" }, "Học Giả"));
        }

        [Test]
        public void IsBlocked_PhanBietHoaThuong()
        {
            // So sánh bằng == nên "cảnh sát" viết thường không khớp "Cảnh sát" trong bảng.
            // Ghi nhận hành vi thật của code (không phải kỳ vọng GDD).
            Assert.IsFalse(TitleConflict.IsBlocked(new[] { "Tướng Cướp" }, "cảnh sát"),
                "Chuỗi phải khớp đúng từng ký tự, kể cả hoa/thường");
            Assert.IsFalse(TitleConflict.IsBlocked(new[] { "tướng cướp" }, "Cảnh sát"),
                "Danh hiệu đang có viết sai hoa/thường thì bảng cũng không tra được");
        }
    }
}
