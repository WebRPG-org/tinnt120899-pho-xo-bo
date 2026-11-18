// Phố Xô Bồ — Test EditMode cho tính lương theo ca (Jobs.PayPerShift, Mục 11).
// Chạy bằng Unity Test Runner (EditMode), KHÔNG chạy được trên VM này (không có Unity).
// API thật đang test: Jobs.PayPerShift(JobDefinition, Stats, TimeFrame, SupplyDemand),
// Jobs.Get(SliceJob), Jobs.WeeklyQuotaTracker, Stats(int, int, int).
//
// GIỚI HẠN ĐÃ BIẾT (không bịa test cho qua):
// - Stats chỉ khởi tạo được khi tổng 3 chỉ số = Stats.TotalCap (300) và mỗi chỉ số
//   <= Stats.StatMax (100) -> trên thực tế chỉ có (100, 100, 100) là hợp lệ.
//   Vì vậy hệ số chỉ số chỉ test được ở mốc 100 (hệ số 1.5); các mốc 50 (1.0)
//   và 0 (sàn 0.5) KHÔNG test được qua API công khai hiện tại — cần sửa Stats
//   (cho phép tổng khởi đầu khác 300, hoặc thêm factory cho test) rồi bổ sung test.
// - Stats.Train(...) từ trạng thái (100,100,100) luôn trả false vì chỉ số cần tăng
//   đã ở trần 100 — test dưới đây ghi nhận đúng hành vi này, không coi là pass
//   cho logic đánh đổi; logic Train cần test lại khi Stats sửa được như trên.
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
