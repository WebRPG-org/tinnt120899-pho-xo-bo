// Phố Xô Bồ — Test EditMode cho tính lương theo ca (Jobs.PayPerShift, Mục 11).
// Chạy bằng Unity Test Runner (EditMode), KHÔNG chạy được trên VM này (không có Unity).
// API thật đang test: Jobs.PayPerShift(JobDefinition, Stats, TimeFrame, SupplyDemand),
// Jobs.Get(SliceJob), Jobs.WeeklyQuotaTracker, Stats(int, int, int).
//
// GIỚI HẠN ĐÃ GỠ (18/11): Stats.WithValues(the, tri, tam) cho phép tạo Stats với
// giá trị tùy ý (chỉ dùng cho test), nên các mốc chỉ số 50 (hệ số 1.0) và 0 (sàn 0.5)
// nay test được qua API công khai. Ctor chính new Stats(...) vẫn yêu cầu tổng = 300.
// - Stats.Train(...) từ trạng thái (100,100,100) luôn trả false vì chỉ số cần tăng
//   đã ở trần 100 — nay test được logic đánh đổi thật qua WithValues (xem cuối file).
// - Lương ca cơ bản (BasePayVnd) + quota là số cấu hình slice, chưa chốt GDD:
//   test dùng đúng số trong Jobs.Definitions, đổi bảng là test phải đổi theo.
using System;
using NUnit.Framework;

namespace PhoXoBo.Tests
{
    [TestFixture]
    public class JobsPayTests
    {
        // Chỉ số duy nhất khởi tạo được qua Stats public ctor (xem ghi chú đầu file).
        private static Stats MaxStats() => new Stats(100, 100, 100);

        // --- Lương cơ bản: chỉ số chính 100 -> hệ số 1.5, khung thường, cung-cầu bình thường ---

        [Test]
        public void BanRong_ChiSo100_KhungThuong_Tra150kNhan1_5()
        {
            var pay = Jobs.PayPerShift(Jobs.Get(SliceJob.BanRong), MaxStats(), TimeFrame.Sang, SupplyDemand.BinhThuong);
            Assert.AreEqual(225_000, pay); // 150_000 * 1.5
        }

        [Test]
        public void Shipper_ChiSo100_KhungThuong_Tra180kNhan1_5()
        {
            var pay = Jobs.PayPerShift(Jobs.Get(SliceJob.Shipper), MaxStats(), TimeFrame.Sang, SupplyDemand.BinhThuong);
            Assert.AreEqual(270_000, pay); // 180_000 * 1.5
        }

        [Test]
        public void NhanVienQuan_ChiSoTam100_KhungThuong_DungChiSoTam()
        {
            // Nhân viên quán lấy Tâm làm chỉ số chính (khác 2 nghề kia lấy Thể).
            var pay = Jobs.PayPerShift(Jobs.Get(SliceJob.NhanVienQuan), MaxStats(), TimeFrame.Chieu, SupplyDemand.BinhThuong);
            Assert.AreEqual(225_000, pay); // 150_000 * 1.5 (Tam = 100)
        }

        // --- Khung giờ tốt: +25% (Jobs.GoodFrameBonusPercent) ---

        [Test]
        public void BanRong_KhungTotChieu_Cong25PhanTram()
        {
            var pay = Jobs.PayPerShift(Jobs.Get(SliceJob.BanRong), MaxStats(), TimeFrame.Chieu, SupplyDemand.BinhThuong);
            Assert.AreEqual(281_250, pay); // 225_000 * 1.25
        }

        [Test]
        public void Shipper_KhungTotToi_Cong25PhanTram()
        {
            var pay = Jobs.PayPerShift(Jobs.Get(SliceJob.Shipper), MaxStats(), TimeFrame.Toi, SupplyDemand.BinhThuong);
            Assert.AreEqual(337_500, pay); // 270_000 * 1.25
        }

        [Test]
        public void NhanVienQuan_KhungTotSang_Cong25PhanTram()
        {
            var pay = Jobs.PayPerShift(Jobs.Get(SliceJob.NhanVienQuan), MaxStats(), TimeFrame.Sang, SupplyDemand.BinhThuong);
            Assert.AreEqual(281_250, pay); // 225_000 * 1.25
        }

        // --- Cung - cầu tuần: thiếu người +30%, bão hoà -15% (GameBalance) ---

        [Test]
        public void BanRong_ThieuNguoi_Cong30PhanTram()
        {
            var pay = Jobs.PayPerShift(Jobs.Get(SliceJob.BanRong), MaxStats(), TimeFrame.Sang, SupplyDemand.ThieuNguoi);
            Assert.AreEqual(292_500, pay); // 225_000 * 1.30
        }

        [Test]
        public void BanRong_BaoHoa_Tru15PhanTram()
        {
            var pay = Jobs.PayPerShift(Jobs.Get(SliceJob.BanRong), MaxStats(), TimeFrame.Sang, SupplyDemand.BaoHoa);
            Assert.AreEqual(191_250, pay); // 225_000 * 0.85
        }

        // --- Kết hợp khung tốt + cung-cầu, và làm tròn xuống ---

        [Test]
        public void BanRong_KhungTotVaThieuNguoi_NhanChong()
        {
            var pay = Jobs.PayPerShift(Jobs.Get(SliceJob.BanRong), MaxStats(), TimeFrame.Chieu, SupplyDemand.ThieuNguoi);
            Assert.AreEqual(365_625, pay); // 225_000 * 1.25 * 1.30
        }

        [Test]
        public void BanRong_KhungTotVaBaoHoa_LamTronXuong()
        {
            // 225_000 * 1.25 * 0.85 = 239_062.5 -> làm tròn xuống 239_062.
            var pay = Jobs.PayPerShift(Jobs.Get(SliceJob.BanRong), MaxStats(), TimeFrame.Chieu, SupplyDemand.BaoHoa);
            Assert.AreEqual(239_062, pay);
        }

        // --- Hệ số lương ở mốc chỉ số chính 50 (hệ số 1.0) và 0 (sàn 0.5) ---
        // Công thức Jobs.PayPerShift: hệ số = max(0.5, 1.0 + (chỉ số - 50) * 0.01).
        // Tạo Stats qua Stats.WithValues (chỉ dùng cho test); ctor chính vẫn yêu cầu tổng = 300.

        [Test]
        public void BanRong_ChiSo50_KhungThuong_TraDungLuongCa()
        {
            var stats = Stats.WithValues(50, 100, 100); // Thể = 50 -> hệ số 1.0
            var pay = Jobs.PayPerShift(Jobs.Get(SliceJob.BanRong), stats, TimeFrame.Sang, SupplyDemand.BinhThuong);
            Assert.AreEqual(150_000, pay); // 150_000 * 1.0
        }

        [Test]
        public void Shipper_ChiSo50_KhungThuong_TraDungLuongCa()
        {
            var stats = Stats.WithValues(50, 100, 100); // Thể = 50 -> hệ số 1.0
            var pay = Jobs.PayPerShift(Jobs.Get(SliceJob.Shipper), stats, TimeFrame.Sang, SupplyDemand.BinhThuong);
            Assert.AreEqual(180_000, pay); // 180_000 * 1.0
        }

        [Test]
        public void NhanVienQuan_ChiSoTam50_KhungThuong_DungChiSoTam()
        {
            // Nhân viên quán lấy Tâm làm chỉ số chính: Tâm = 50 -> hệ số 1.0,
            // Thể/Tri = 100 không ảnh hưởng lương nghề này.
            var stats = Stats.WithValues(100, 100, 50);
            var pay = Jobs.PayPerShift(Jobs.Get(SliceJob.NhanVienQuan), stats, TimeFrame.Chieu, SupplyDemand.BinhThuong);
            Assert.AreEqual(150_000, pay); // 150_000 * 1.0
        }

        [Test]
        public void BanRong_ChiSo0_KhungThuong_TraSan50PhanTram()
        {
            var stats = Stats.WithValues(0, 100, 100); // Thể = 0 -> hệ số sàn 0.5
            var pay = Jobs.PayPerShift(Jobs.Get(SliceJob.BanRong), stats, TimeFrame.Sang, SupplyDemand.BinhThuong);
            Assert.AreEqual(75_000, pay); // 150_000 * 0.5
        }

        [Test]
        public void Shipper_ChiSo0_KhungThuong_TraSan50PhanTram()
        {
            var stats = Stats.WithValues(0, 100, 100); // Thể = 0 -> hệ số sàn 0.5
            var pay = Jobs.PayPerShift(Jobs.Get(SliceJob.Shipper), stats, TimeFrame.Sang, SupplyDemand.BinhThuong);
            Assert.AreEqual(90_000, pay); // 180_000 * 0.5
        }

        [Test]
        public void NhanVienQuan_ChiSoTam0_KhungThuong_TraSan50PhanTram()
        {
            var stats = Stats.WithValues(100, 100, 0); // Tâm = 0 -> hệ số sàn 0.5
            var pay = Jobs.PayPerShift(Jobs.Get(SliceJob.NhanVienQuan), stats, TimeFrame.Chieu, SupplyDemand.BinhThuong);
            Assert.AreEqual(75_000, pay); // 150_000 * 0.5
        }

        [Test]
        public void BanRong_ChiSo50_KhungTotVaThieuNguoi_NhanChong()
        {
            // Mốc 50 + khung tốt +25% + thiếu người +30% (GameBalance):
            // 150_000 * 1.0 * 1.25 * 1.30 = 243_750.
            var stats = Stats.WithValues(50, 100, 100);
            var pay = Jobs.PayPerShift(Jobs.Get(SliceJob.BanRong), stats, TimeFrame.Chieu, SupplyDemand.ThieuNguoi);
            Assert.AreEqual(243_750, pay);
        }

        [Test]
        public void BanRong_ChiSo0_KhungTotVaBaoHoa_LamTronXuong()
        {
            // Mốc 0 + khung tốt +25% + bão hoà -15% (GameBalance):
            // 75_000 * 1.25 * 0.85 = 79_687.5 -> làm tròn xuống 79_687.
            var stats = Stats.WithValues(0, 100, 100);
            var pay = Jobs.PayPerShift(Jobs.Get(SliceJob.BanRong), stats, TimeFrame.Chieu, SupplyDemand.BaoHoa);
            Assert.AreEqual(79_687, pay);
        }

        [Test]
        public void BanRong_ChiSo60_KiemTraDoDocTuyenTinh()
        {
            // Mốc giữa: Thể = 60 -> hệ số 1.0 + 10 * 0.01 = 1.1.
            var stats = Stats.WithValues(60, 100, 100);
            var pay = Jobs.PayPerShift(Jobs.Get(SliceJob.BanRong), stats, TimeFrame.Sang, SupplyDemand.BinhThuong);
            Assert.AreEqual(165_000, pay); // 150_000 * 1.1
        }

        [Test]
        public void Stats_WithValues_ChoPhepTongKhac300_VaKepGiaTri()
        {
            // Factory chỉ dùng cho test: tổng khác 300 được chấp nhận,
            // nhưng từng chỉ số vẫn kẹp trong 0..StatMax (âm -> 0).
            var stats = Stats.WithValues(-10, 100, 100);
            Assert.AreEqual(0, stats.The);
            Assert.AreEqual(100, stats.Tri);
            Assert.AreEqual(100, stats.Tam);
            Assert.AreEqual(200, stats.Total, "Tổng 200 != TotalCap 300 nhưng WithValues vẫn tạo được");
            var pay = Jobs.PayPerShift(Jobs.Get(SliceJob.BanRong), stats, TimeFrame.Sang, SupplyDemand.BinhThuong);
            Assert.AreEqual(75_000, pay); // Thể kẹp về 0 -> hệ số sàn 0.5
        }

        // --- Logic đánh đổi của Stats.Train, nay test được thật qua WithValues ---

        [Test]
        public void Stats_TrainTuTrangThaiKhongMax_DoiChiSoDungLuong()
        {
            var stats = Stats.WithValues(50, 100, 100);
            Assert.IsTrue(stats.Train(BaseStat.The, BaseStat.Tri, 10), "Tăng Thể 10, giảm Trí 10 phải được");
            Assert.AreEqual(60, stats.The);
            Assert.AreEqual(90, stats.Tri);
            Assert.AreEqual(100, stats.Tam);
            Assert.AreEqual(250, stats.Total, "Train giữ nguyên tổng (đánh đổi, không tạo chỉ số mới)");
        }

        // --- Lương không âm với mọi tổ hợp khung + cung-cầu ---

        [Test]
        public void PayPerShift_MoiToHop_LuongDuong()
        {
            foreach (SliceJob job in Enum.GetValues(typeof(SliceJob)))
            {
                foreach (TimeFrame frame in Enum.GetValues(typeof(TimeFrame)))
                {
                    foreach (SupplyDemand demand in Enum.GetValues(typeof(SupplyDemand)))
                    {
                        var pay = Jobs.PayPerShift(Jobs.Get(job), MaxStats(), frame, demand);
                        Assert.Greater(pay, 0, $"Lương phải > 0: {job} / {frame} / {demand}");
                    }
                }
            }
        }

        // --- Jobs.Get: nghề không tồn tại thì ném lỗi ---

        [Test]
        public void Get_NgheKhongTonTai_NemArgumentException()
        {
            Assert.Throws<ArgumentException>(() => Jobs.Get((SliceJob)999));
        }

        // --- Quota tuần: tối đa WeeklyQuota ca/tuần (Mục 6) ---

        [Test]
        public void WeeklyQuotaTracker_NhanDuQuota_ThiHetQuota()
        {
            var tracker = new Jobs.WeeklyQuotaTracker();
            var quota = Jobs.Get(SliceJob.BanRong).WeeklyQuota;
            Assert.AreEqual(14, quota); // số cấu hình slice hiện tại
            for (var i = 0; i < quota; i++)
                Assert.IsTrue(tracker.TakeShift(SliceJob.BanRong), $"Ca thứ {i + 1} phải nhận được");
            Assert.AreEqual(0, tracker.ShiftsLeft(SliceJob.BanRong));
            Assert.IsFalse(tracker.CanTakeShift(SliceJob.BanRong));
            Assert.IsFalse(tracker.TakeShift(SliceJob.BanRong), "Quá quota phải trả false");
            Assert.AreEqual(quota, tracker.ShiftsDone(SliceJob.BanRong));
        }

        [Test]
        public void WeeklyQuotaTracker_ResetWeek_TraLaiQuotaDay()
        {
            var tracker = new Jobs.WeeklyQuotaTracker();
            tracker.TakeShift(SliceJob.Shipper);
            tracker.TakeShift(SliceJob.Shipper);
            Assert.AreEqual(2, tracker.ShiftsDone(SliceJob.Shipper));
            tracker.ResetWeek();
            Assert.AreEqual(0, tracker.ShiftsDone(SliceJob.Shipper));
            Assert.AreEqual(Jobs.Get(SliceJob.Shipper).WeeklyQuota, tracker.ShiftsLeft(SliceJob.Shipper));
        }

        [Test]
        public void WeeklyQuotaTracker_QuotaRiengTheoNghe()
        {
            var tracker = new Jobs.WeeklyQuotaTracker();
            tracker.TakeShift(SliceJob.BanRong);
            Assert.AreEqual(1, tracker.ShiftsDone(SliceJob.BanRong));
            Assert.AreEqual(0, tracker.ShiftsDone(SliceJob.Shipper), "Ca của nghề này không tính sang nghề khác");
        }

        // --- Giới hạn của Stats (ghi nhận hành vi thật, xem ghi chú đầu file) ---

        [Test]
        public void Stats_TongKhongBang300_NemArgumentException()
        {
            // (50, 100, 100): tổng 250 != TotalCap 300 -> ctor ném lỗi.
            Assert.Throws<ArgumentException>(() => new Stats(50, 100, 100));
        }

        [Test]
        public void Stats_TrainTuTrangThaiMax_LuonTraFalse()
        {
            // Từ (100,100,100), chỉ số cần tăng đã ở trần 100 nên Train luôn false.
            // Đây là hệ quả của ctor hiện tại, chưa phải là kiểm chứng logic đánh đổi.
            var stats = MaxStats();
            Assert.IsFalse(stats.Train(BaseStat.The, BaseStat.Tri, 10));
            Assert.AreEqual(300, stats.Total, "Train thất bại thì tổng chỉ số không đổi");
        }
    }
}
