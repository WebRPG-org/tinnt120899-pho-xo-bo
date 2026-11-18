// Phố Xô Bồ — Test EditMode cho tiến trình người chơi (PlayerProgress.cs, Mục 9 + Mục 12).
// Chạy bằng Unity Test Runner (EditMode), KHÔNG chạy được trên VM này (không có Unity).
// API thật đang test: PlayerProgress.CanOpenChapter, PlayerProgress.SuggestEnding,
// PlayerProgress.RankAtRisk; enum Chapter (LenPho, LapNghiep, KhungHoang, VucDay,
// ThanhDat), enum Ending (GiamDoc, HocGia, GiaDinh, TuDo, SieuGiau, ChuaMo).
//
// Số lấy đúng code (PlayerProgress.cs ghi: CanOpenChapter dùng "số Danh vọng / Trí /
// tài sản đã chốt"; SuggestEnding / RankAtRisk không gắn nhãn riêng từng ngưỡng):
// mở chương — LapNghiep: tri ≥ 40 hoặc danhVong ≥ 200; VucDay: helpQuestsDone ≥ 3
// VÀ hasCloseRelationship; ThanhDat: tri ≥ 60 hoặc danhVong ≥ 500 hoặc taiSan ≥ 10 tỉ;
// kết thúc — SieuGiau ≥ 100 tỉ, GiamDoc ≥ 10 tỉ, HocGia tri ≥ 90 VÀ danhVong ≥ 1500,
// GiaDinh hasSpouse VÀ anYen ≥ 80, TuDo anYen ≥ 80; RankAtRisk danhVong < 100 hoặc
// anYen < 30. File nguồn KHÔNG đánh dấu số nào là PROVISIONAL riêng lẻ — nếu GDD
// đổi số thì test phải đổi theo. Không có số nào do test tự bịa thêm.
// Lưu ý thứ tự ưu tiên thật trong SuggestEnding (ghi nhận, chưa phải kiểm chứng
// kỳ vọng): SieuGiau > GiamDoc > HocGia > GiaDinh > TuDo > ChuaMo — người chơi
// đủ điều kiện nhiều kết thúc sẽ nhận kết thúc đứng trước trong thứ tự này.
using NUnit.Framework;

namespace PhoXoBo.Tests
{
    [TestFixture]
    public class PlayerProgressTests
    {
        // --- CanOpenChapter: chương 1 Lên Phố luôn mở ---

        [Test]
        public void CanOpenChapter_LenPho_LuonTrue()
        {
            // Chỉ số 0 hết mà chương 1 vẫn mở.
            Assert.IsTrue(PlayerProgress.CanOpenChapter(Chapter.LenPho, tri: 0, danhVong: 0,
                taiSan: 0, hasCloseRelationship: false, helpQuestsDone: 0));
        }

        // --- CanOpenChapter: chương 2 Lập Nghiệp — tri ≥ 40 hoặc danhVong ≥ 200 ---

        [Test]
        public void CanOpenChapter_LapNghiep_Tri40True()
        {
            Assert.IsTrue(PlayerProgress.CanOpenChapter(Chapter.LapNghiep, tri: 40, danhVong: 0,
                taiSan: 0, hasCloseRelationship: false, helpQuestsDone: 0),
                "Tri đúng 40 thì mở được chương 2");
        }

        [Test]
        public void CanOpenChapter_LapNghiep_DanhVong200True()
        {
            Assert.IsTrue(PlayerProgress.CanOpenChapter(Chapter.LapNghiep, tri: 0, danhVong: 200,
                taiSan: 0, hasCloseRelationship: false, helpQuestsDone: 0),
                "Danh vọng đúng 200 thì mở được chương 2 dù tri bằng 0");
        }

        [Test]
        public void CanOpenChapter_LapNghiep_DuoiCaHaiFalse()
        {
            Assert.IsFalse(PlayerProgress.CanOpenChapter(Chapter.LapNghiep, tri: 39, danhVong: 199,
                taiSan: 0, hasCloseRelationship: false, helpQuestsDone: 0),
                "Tri 39 < 40 và danh vọng 199 < 200 thì chưa mở được chương 2");
        }

        // --- CanOpenChapter: chương 3 Khủng Hoảng luôn mở (bài kiểm tra, mở khi qua chương 2) ---

        [Test]
        public void CanOpenChapter_KhungHoang_LuonTrue()
        {
            Assert.IsTrue(PlayerProgress.CanOpenChapter(Chapter.KhungHoang, tri: 0, danhVong: 0,
                taiSan: 0, hasCloseRelationship: false, helpQuestsDone: 0));
        }

        // --- CanOpenChapter: chương 4 Vực Dậy — helpQuestsDone ≥ 3 VÀ hasCloseRelationship ---

        [Test]
        public void CanOpenChapter_VucDay_DuCaHaiTrue()
        {
            Assert.IsTrue(PlayerProgress.CanOpenChapter(Chapter.VucDay, tri: 0, danhVong: 0,
                taiSan: 0, hasCloseRelationship: true, helpQuestsDone: 3),
                "Đúng 3 quest giúp đỡ và có quan hệ thân thiết thì mở được chương 4");
        }

        [Test]
        public void CanOpenChapter_VucDay_ThieuQuestFalse()
        {
            Assert.IsFalse(PlayerProgress.CanOpenChapter(Chapter.VucDay, tri: 0, danhVong: 0,
                taiSan: 0, hasCloseRelationship: true, helpQuestsDone: 2),
                "Chỉ 2 quest giúp đỡ (< 3) thì chưa mở được dù có quan hệ thân thiết");
        }

        [Test]
        public void CanOpenChapter_VucDay_ThieuQuanHeFalse()
        {
            Assert.IsFalse(PlayerProgress.CanOpenChapter(Chapter.VucDay, tri: 0, danhVong: 0,
                taiSan: 0, hasCloseRelationship: false, helpQuestsDone: 5),
                "Đủ 5 quest nhưng không có quan hệ thân thiết thì chưa mở được");
        }

        [Test]
        public void CanOpenChapter_VucDay_KhongQuestKhongQuanHeFalse()
        {
            Assert.IsFalse(PlayerProgress.CanOpenChapter(Chapter.VucDay, tri: 0, danhVong: 0,
                taiSan: 0, hasCloseRelationship: false, helpQuestsDone: 0));
        }

        // --- CanOpenChapter: chương 5 Thành Đạt — tri ≥ 60 hoặc danhVong ≥ 500 hoặc taiSan ≥ 10 tỉ ---

        [Test]
        public void CanOpenChapter_ThanhDat_Tri60True()
        {
            Assert.IsTrue(PlayerProgress.CanOpenChapter(Chapter.ThanhDat, tri: 60, danhVong: 0,
                taiSan: 0, hasCloseRelationship: false, helpQuestsDone: 0),
                "Tri đúng 60 thì mở được chương 5");
        }

        [Test]
        public void CanOpenChapter_ThanhDat_DanhVong500True()
        {
            Assert.IsTrue(PlayerProgress.CanOpenChapter(Chapter.ThanhDat, tri: 0, danhVong: 500,
                taiSan: 0, hasCloseRelationship: false, helpQuestsDone: 0),
                "Danh vọng đúng 500 thì mở được chương 5 dù tri bằng 0");
        }

        [Test]
        public void CanOpenChapter_ThanhDat_TaiSan10TiTrue()
        {
            Assert.IsTrue(PlayerProgress.CanOpenChapter(Chapter.ThanhDat, tri: 0, danhVong: 0,
                taiSan: 10_000_000_000L, hasCloseRelationship: false, helpQuestsDone: 0),
                "Tài sản đúng 10 tỉ thì mở được chương 5");
        }

        [Test]
        public void CanOpenChapter_ThanhDat_DuoiCaBaFalse()
        {
            Assert.IsFalse(PlayerProgress.CanOpenChapter(Chapter.ThanhDat, tri: 59, danhVong: 499,
                taiSan: 9_999_999_999L, hasCloseRelationship: false, helpQuestsDone: 0),
                "Tri 59, danh vọng 499, tài sản 1 đồng dưới 10 tỉ thì chưa mở được chương 5");
        }

        // --- CanOpenChapter: chapter lạ → false ---

        [Test]
        public void CanOpenChapter_ChapterLa_TraFalse()
        {
            Assert.IsFalse(PlayerProgress.CanOpenChapter((Chapter)99, tri: 100, danhVong: 9999,
                taiSan: 999_000_000_000L, hasCloseRelationship: true, helpQuestsDone: 99),
                "Chapter ngoài enum vẫn trả false dù mọi chỉ số đều cao");
            Assert.IsFalse(PlayerProgress.CanOpenChapter((Chapter)0, tri: 100, danhVong: 9999,
                taiSan: 999_000_000_000L, hasCloseRelationship: true, helpQuestsDone: 99));
            Assert.IsFalse(PlayerProgress.CanOpenChapter((Chapter)6, tri: 100, danhVong: 9999,
                taiSan: 999_000_000_000L, hasCloseRelationship: true, helpQuestsDone: 99));
        }

        // --- SuggestEnding: thứ tự ưu tiên SieuGiau (100 tỉ) trước GiamDoc (10 tỉ) ---

        [Test]
        public void SuggestEnding_SieuGiau_UuTienTruocGiamDoc()
        {
            // 100 tỉ cũng thỏa điều kiện GiamDoc (≥ 10 tỉ) nhưng kết thúc trả về là SieuGiau.
            Assert.AreEqual(Ending.SieuGiau,
                PlayerProgress.SuggestEnding(taiSan: 100_000_000_000L, tri: 0, danhVong: 0, anYen: 0, hasSpouse: false));
        }

        [Test]
        public void SuggestEnding_GiamDoc_Dung10Ti()
        {
            Assert.AreEqual(Ending.GiamDoc,
                PlayerProgress.SuggestEnding(taiSan: 10_000_000_000L, tri: 0, danhVong: 0, anYen: 0, hasSpouse: false));
        }

        [Test]
        public void SuggestEnding_Duoi10Ti_KhongGiamDoc()
        {
            Assert.AreEqual(Ending.ChuaMo,
                PlayerProgress.SuggestEnding(taiSan: 9_999_999_999L, tri: 0, danhVong: 0, anYen: 0, hasSpouse: false),
                "Tài sản 1 đồng dưới 10 tỉ, các chỉ số khác bằng 0 thì chưa mở kết thúc nào");
        }

        // --- SuggestEnding: HocGia cần tri ≥ 90 VÀ danhVong ≥ 1500 ---

        [Test]
        public void SuggestEnding_HocGia_DuCaHaiTrue()
        {
            Assert.AreEqual(Ending.HocGia,
                PlayerProgress.SuggestEnding(taiSan: 0, tri: 90, danhVong: 1500, anYen: 0, hasSpouse: false));
        }

        [Test]
        public void SuggestEnding_HocGia_ThieuDanhVongFalse()
        {
            Assert.AreEqual(Ending.ChuaMo,
                PlayerProgress.SuggestEnding(taiSan: 0, tri: 90, danhVong: 1499, anYen: 0, hasSpouse: false),
                "Tri 90 nhưng danh vọng 1499 (< 1500) thì chưa được kết thúc Học Giả");
        }

        [Test]
        public void SuggestEnding_HocGia_ThieuTriFalse()
        {
            Assert.AreEqual(Ending.ChuaMo,
                PlayerProgress.SuggestEnding(taiSan: 0, tri: 89, danhVong: 1500, anYen: 0, hasSpouse: false),
                "Danh vọng 1500 nhưng tri 89 (< 90) thì chưa được kết thúc Học Giả");
        }

        [Test]
        public void SuggestEnding_HocGia_UuTienTruocGiaDinh()
        {
            // Đủ cả Học Giả lẫn Gia Đình (có vợ/chồng, an yên 80) thì kết thúc là Học Giả.
            Assert.AreEqual(Ending.HocGia,
                PlayerProgress.SuggestEnding(taiSan: 0, tri: 90, danhVong: 1500, anYen: 80, hasSpouse: true));
        }

        // --- SuggestEnding: GiaDinh cần hasSpouse VÀ anYen ≥ 80; TuDo khi anYen ≥ 80 không có spouse ---

        [Test]
        public void SuggestEnding_GiaDinh_CoSpouseVaAnYen80()
        {
            Assert.AreEqual(Ending.GiaDinh,
                PlayerProgress.SuggestEnding(taiSan: 0, tri: 0, danhVong: 0, anYen: 80, hasSpouse: true));
        }

        [Test]
        public void SuggestEnding_TuDo_AnYen80KhongSpouse()
        {
            Assert.AreEqual(Ending.TuDo,
                PlayerProgress.SuggestEnding(taiSan: 0, tri: 0, danhVong: 0, anYen: 80, hasSpouse: false));
        }

        [Test]
        public void SuggestEnding_CoSpouseNhungAnYenDuoi80_ThanhChuaMo()
        {
            // Có vợ/chồng nhưng an yên 79 (< 80): GiaDinh cần an yên ≥ 80, TuDo cũng
            // cần an yên ≥ 80 nên cả hai đều không thỏa — kết thúc là Chưa Mở.
            Assert.AreEqual(Ending.ChuaMo,
                PlayerProgress.SuggestEnding(taiSan: 0, tri: 0, danhVong: 0, anYen: 79, hasSpouse: true));
        }

        [Test]
        public void SuggestEnding_DuoiHet_ThanhChuaMo()
        {
            Assert.AreEqual(Ending.ChuaMo,
                PlayerProgress.SuggestEnding(taiSan: 0, tri: 0, danhVong: 0, anYen: 0, hasSpouse: false));
        }

        // --- RankAtRisk: danhVong < 100 hoặc anYen < 30 → true; đủ cả hai → false; biên 100/30 ---

        [Test]
        public void RankAtRisk_DanhVongDuoi100True()
        {
            Assert.IsTrue(PlayerProgress.RankAtRisk(danhVong: 99, anYen: 100),
                "Danh vọng 99 < 100 thì bậc có nguy cơ tụt dù an yên cao");
        }

        [Test]
        public void RankAtRisk_AnYenDuoi30True()
        {
            Assert.IsTrue(PlayerProgress.RankAtRisk(danhVong: 500, anYen: 29),
                "An yên 29 < 30 thì bậc có nguy cơ tụt dù danh vọng cao");
        }

        [Test]
        public void RankAtRisk_CaHaiThapTrue()
        {
            Assert.IsTrue(PlayerProgress.RankAtRisk(danhVong: 0, anYen: 0));
        }

        [Test]
        public void RankAtRisk_DuCaHaiFalse()
        {
            Assert.IsFalse(PlayerProgress.RankAtRisk(danhVong: 100, anYen: 30),
                "Đúng biên 100 danh vọng và 30 an yên thì bậc không còn nguy cơ");
        }

        [Test]
        public void RankAtRisk_Bien100_30()
        {
            Assert.IsFalse(PlayerProgress.RankAtRisk(100, 30), "Biên trên: 100/30 thì an toàn");
            Assert.IsTrue(PlayerProgress.RankAtRisk(100, 29), "An yên 29 thì nguy cơ dù danh vọng đúng 100");
            Assert.IsTrue(PlayerProgress.RankAtRisk(99, 30), "Danh vọng 99 thì nguy cơ dù an yên đúng 30");
            Assert.IsFalse(PlayerProgress.RankAtRisk(101, 31), "Trên biên cả hai thì an toàn");
        }
    }
}
