// Phố Xô Bồ — Khu vực (Mục 3 đã chốt): đúng 18 khu, 5 tầng lớp + 2 khu chung.
// Danh sách này là chuẩn. Đổi khu phải sửa cả docs/districts.md và docs/gdd.md.
using System.Collections.Generic;

namespace PhoXoBo
{
    public enum Tier { LaoDong = 1, CanTrungLuu = 2, TrungLuu = 3, ThuongLuu = 4, SieuGiau = 5, Chung = 0 }

    public sealed record District(int Id, string Name, Tier Tier);

    public static class Districts
    {
        public static readonly IReadOnlyList<District> All = new List<District>
        {
            new(1, "Xóm Trọ Cũ", Tier.LaoDong),
            new(2, "Chợ Đầu Mối", Tier.LaoDong),
            new(3, "Khu Công Nhân", Tier.LaoDong),
            new(4, "Bến Xe Miền Đông", Tier.LaoDong),
            new(5, "Làng Đại Học", Tier.CanTrungLuu),
            new(6, "Chung Cư Cũ", Tier.CanTrungLuu),
            new(7, "Phố Văn Phòng Nhỏ", Tier.CanTrungLuu),
            new(8, "Khu Chung Cư Cao Cấp", Tier.TrungLuu),
            new(9, "Phố Thương Mại", Tier.TrungLuu),
            new(10, "Khu Công Nghệ", Tier.TrungLuu),
            new(11, "Phố Tây", Tier.ThuongLuu),
            new(12, "Khu Biệt Thự Ven Sông", Tier.ThuongLuu),
            new(13, "Quận Tài Chính", Tier.ThuongLuu),
            new(14, "Đảo Thượng Lưu", Tier.SieuGiau),
            new(15, "Khu Penthouse", Tier.SieuGiau),
            new(16, "Khu Sân Golf & Resort", Tier.SieuGiau),
            new(17, "Công Viên An Bình", Tier.Chung),
            new(18, "Phố Đi Bộ – Chợ Đêm", Tier.Chung),
        };

        public const int ExpectedCount = 18;
        public static bool IsValidCount => All.Count == ExpectedCount;
    }
}
