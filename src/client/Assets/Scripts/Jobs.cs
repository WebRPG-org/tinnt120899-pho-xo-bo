// Phố Xô Bồ — 3 nghề slice đầu tiên (Mục 11 đã chốt)
// Bán rong, Shipper, Nhân viên quán — làm trong Xóm Trọ Cũ + Chợ Đầu Mối.
// Lương = lương ca cơ bản x hệ số chỉ số chính x hệ số khung giờ x hệ số cung – cầu.
// - Khung giờ tốt của nghề: +25% (theo yêu cầu slice; chưa phải số chốt GDD —
//   ghi rõ ở đây để khi chốt thì sửa 1 chỗ duy nhất là GoodFrameBonusPercent).
// - Cung – cầu tuần dùng đúng số chốt GameBalance: thiếu người +30%, bão hoà −15%.
// - Lương ca cơ bản (BasePayVnd) là số cấu hình của slice, KHÔNG phải số chốt:
//   chưa có trong GDD, chỉnh ở JobDefinitions, không hardcode ở nơi khác.
// - Quota tuần: mỗi nghề chỉ nhận tối đa WeeklyQuota ca/tuần (Mục 6: việc có quota tuần).
using System;
using System.Collections.Generic;

namespace PhoXoBo
{
    public enum SliceJob { BanRong, Shipper, NhanVienQuan }

    public enum SupplyDemand { BinhThuong, ThieuNguoi, BaoHoa }

    public sealed record JobDefinition(
        SliceJob Job,
        string Name,
        BaseStat MainStat,      // Chỉ số chính quyết định lương
        TimeFrame GoodFrame,    // Khung giờ tốt của nghề
        long BasePayVnd,        // Lương 1 ca khi chỉ số chính = 50, khung thường, cung – cầu bình thường
        int WeeklyQuota);       // Số ca tối đa được nhận trong 1 tuần game

    public static class Jobs
    {
        // PROVISIONAL — lương ca cơ bản + quota là số cấu hình slice, chưa chốt.
        // Khi GDD chốt bảng lương thì sửa đúng bảng này, không sửa code tính lương.
        public const int GoodFrameBonusPercent = 25; // Khung giờ tốt: +25%

        public static readonly IReadOnlyList<JobDefinition> Definitions = new List<JobDefinition>
        {
            // Bán rong: Thể khỏe thì gánh nhiều, bán được nhiều; khung tốt là Chiều (chợ đông).
            new(SliceJob.BanRong, "Bán rong", BaseStat.The, TimeFrame.Chieu, 150_000, 14),
            // Shipper: Thể khỏe thì chạy nhiều đơn; khung tốt là Tối (đơn ăn đêm).
            new(SliceJob.Shipper, "Shipper", BaseStat.The, TimeFrame.Toi, 180_000, 14),
            // Nhân viên quán: Tâm tốt thì phục vụ khéo, được tip; khung tốt là Sáng (khách cà phê).
            new(SliceJob.NhanVienQuan, "Nhân viên quán", BaseStat.Tam, TimeFrame.Sang, 150_000, 14),
        };

        public static JobDefinition Get(SliceJob job)
        {
            foreach (var def in Definitions)
                if (def.Job == job) return def;
            throw new ArgumentException($"Không có nghề slice: {job}");
        }

        /// <summary>
        /// Tính lương 1 ca (đồng trong game).
        /// Hệ số chỉ số chính: chỉ số 50 = hệ số 1.0; mỗi 10 điểm trên 50 cộng 10% lương,
        /// mỗi 10 điểm dưới 50 trừ 10% (làm tròn xuống, tối thiểu 50% lương ca).
        /// Khung tốt +25%; thiếu người +30% (GameBalance), bão hoà −15% (GameBalance).
        /// </summary>
        public static long PayPerShift(JobDefinition def, Stats stats, TimeFrame frame, SupplyDemand demand)
        {
            var mainValue = def.MainStat switch
            {
                BaseStat.The => stats.The,
                BaseStat.Tri => stats.Tri,
                _ => stats.Tam,
            };
            // Hệ số chỉ số: 50 -> 1.0, 100 -> 1.5, 0 -> 0.5 (giới hạn dưới 0.5).
            var statFactor = Math.Max(0.5, 1.0 + (mainValue - 50) * 0.01);
            var pay = def.BasePayVnd * statFactor;
            if (frame == def.GoodFrame) pay *= 1 + GoodFrameBonusPercent / 100.0;
            pay *= demand switch
            {
                SupplyDemand.ThieuNguoi => 1 + GameBalance.ShortageSalaryBonusPercent / 100.0,
                SupplyDemand.BaoHoa => 1 - GameBalance.SaturatedSalaryCutPercent / 100.0,
                _ => 1.0,
            };
            return (long)Math.Floor(pay);
        }

        /// <summary>
        /// Bộ đếm ca đã làm trong tuần — server là nguồn sự thật khi online;
        /// client chỉ giữ bản đếm tạm để hiển thị quota còn lại.
        /// </summary>
        public sealed class WeeklyQuotaTracker
        {
            private readonly Dictionary<SliceJob, int> _shiftsThisWeek = new();

            public int ShiftsDone(SliceJob job) =>
                _shiftsThisWeek.TryGetValue(job, out var count) ? count : 0;

            public int ShiftsLeft(SliceJob job) => Get(job).WeeklyQuota - ShiftsDone(job);

            public bool CanTakeShift(SliceJob job) => ShiftsLeft(job) > 0;

            /// <summary>Nhận 1 ca. Trả false nếu hết quota tuần.</summary>
            public bool TakeShift(SliceJob job)
            {
                if (!CanTakeShift(job)) return false;
                _shiftsThisWeek[job] = ShiftsDone(job) + 1;
                return true;
            }

            /// <summary>Reset khi sang tuần game mới.</summary>
            public void ResetWeek() => _shiftsThisWeek.Clear();
        }
    }
}
