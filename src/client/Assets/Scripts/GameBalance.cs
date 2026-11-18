// Phố Xô Bồ — Bảng số cân bằng: NGUỒN DUY NHẤT cho số liệu đã chốt.
// Quy tắc DEV: không hardcode số tiền / ngày / EXP ở file khác — dùng hằng ở đây.
// Mọi số trong file này phải khớp docs/gdd.md Mục 5 + docs/economy.md.
// Số ghi PROVISIONAL là số ví dụ chưa chốt — đổi thì sửa ở đây + docs cùng lúc.
using System.Collections.Generic;

namespace PhoXoBo
{
    /// <summary>Một bậc học vấn đã chốt (Mục 5).</summary>
    public sealed record Degree(string Name, long FeeVnd, int Days, int RequiredTri, int Exp, int Fame, bool NeedsMentor);

    public static class GameBalance
    {
        // Thời gian kiểu C (Mục 1, đã chốt): 1 ngày game = 30 phút thật, 3 khung.
        public const int GameDayMinutes = 30;
        public const int FramesPerDay = 3;

        // Học vấn (Mục 5, đã chốt).
        public static readonly IReadOnlyList<Degree> Degrees = new List<Degree>
        {
            new("THPT", 0, 30, 20, 0, 0, false),
            new("Cao đẳng", 20_000_000, 60, 40, 500, 0, false),
            new("Cử nhân", 80_000_000, 120, 60, 1_500, 200, false),
            new("Thạc sĩ", 200_000_000, 180, 75, 3_000, 500, false),
            new("Tiến sĩ / Học giả", 500_000_000, 240, 90, 6_000, 1_500, true),
        };

        // Khoá ngắn hạn (Mục 5, đã chốt): 3–7 ngày, 2–10 triệu, +10 một chỉ số phụ.
        public const int ShortCourseMinDays = 3;
        public const int ShortCourseMaxDays = 7;
        public const long ShortCourseMinFeeVnd = 2_000_000;
        public const long ShortCourseMaxFeeVnd = 10_000_000;
        public const int ShortCourseStatGain = 10;

        // Cung – cầu tuần (Mục 5/6, đã chốt).
        public const int ShortageSalaryBonusPercent = 30;   // nghề thiếu người: lương +30%
        public const int SaturatedSalaryCutPercent = 15;    // nghề bão hoà: lương −15%
        public const int SchoolSeatsPerCourseMin = 20;
        public const int SchoolSeatsPerCourseMax = 30;

        // Giấy phép + thi chứng chỉ (Mục 6, đã chốt).
        public const long FoodStallLicenseVnd = 50_000_000;  // sạp ăn
        public const long ClinicLicenseVnd = 200_000_000;    // phòng khám
        public const long ExamFeeMinVnd = 5_000_000;
        public const long ExamFeeMaxVnd = 20_000_000;

        // Công ty = guild (Mục 6, đã chốt).
        public const long CompanyCapitalVnd = 500_000_000;
        public const int CompanyInactiveWeeksToRemove = 2;

        // Xã hội (Mục 8, đã chốt).
        public const int NeglectDaysToDropCloseness = 7;      // bỏ bê 7 ngày game → thân thiết giảm
        public const int SupportedExpBonusPercent = 20;       // được hỗ trợ: +20% EXP
        public const int SoloSlowerPercentMin = 30;           // solo chậm hơn 30–50%
        public const int SoloSlowerPercentMax = 50;

        // Tài chính (Mục 7, đã chốt).
        public const double BankInterestPerGameMonth = 0.005; // lãi tiết kiệm 0,5%/tháng game
        public const int AuctionFeePercent = 5;               // phí sàn đấu giá
        public const int BigPurchaseFameBonus = 50;           // mua lớn: Danh vọng +50

        // Thang nhà (Mục 7, đã chốt) — tiền thuê tháng cho phòng trọ, giá mua cho các bậc còn lại.
        public const long RoomRentPerMonthVnd = 2_000_000;
        public const long MiniApartmentVnd = 800_000_000;
        public const long SmallTownhouseVnd = 3_000_000_000;
        public const long LargeTownhouseVnd = 8_000_000_000;
        public const long VillaVnd = 25_000_000_000;
        public const long PenthouseIslandVnd = 100_000_000_000;

        // Nhánh rank Chương 5 (Mục 9, đã chốt).
        public const long DirectorAssetsVnd = 10_000_000_000; // Giám đốc: tài sản 10 tỉ
        public const long SuperRichAssetsVnd = 100_000_000_000; // Siêu giàu: tài sản 100 tỉ
        public const int FamilyEndingAnYen = 80;              // Ending gia đình: An Yên 80
    }
}
