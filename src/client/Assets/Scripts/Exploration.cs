// Phố Xô Bồ — Khám phá hotspot kiểu Treasure of Nadia (docs/nadia-reference.md §1, hàng 2/5/6/7)
// Nadia: hotspot lấp lánh + quay lại địa điểm cũ có vật/sự kiện mới + fast-travel theo khu đã mở
// + NPC dẫn đường khi bí. Chuyển sang 2.5D isometric mobile:
// - Hotspot TO, lấp lánh, highlight rõ — KHÔNG rà từng pixel (Nadia PC point-and-click không lấy).
// - Chỉ fast travel tới khu đã mở; khu chưa mở ghi rõ điều kiện mở.
// - Số liệu: khu dùng District.cs (đúng 18 khu đã chốt); khung dùng TimeSystem (3 khung/ngày).
//   Danh sách hotspot + vật thu được là số cấu hình slice, PROVISIONAL, chưa chốt —
//   khi GDD chốt bảng hotspot thì sửa đúng bảng Hotspots, không sửa code khám phá.
using System;
using System.Collections.Generic;

namespace PhoXoBo
{
    /// <summary>Nguyên liệu thô nhặt ở hotspot. Id dùng chung với Crafting.cs (RecipeCatalog).</summary>
    public static class MaterialIds
    {
        public const string LaChuoi = "la-chuoi";
        public const string VanGo = "van-go";
        public const string KhungSat = "khung-sat";
        public const string BanhXe = "banh-xe";
        public const string VaiVun = "vai-vun";
        public const string ChaiNhua = "chai-nhua";
        public const string SatVun = "sat-vun";
    }

    /// <summary>Một điểm khám phá (hotspot) trên bản đồ isometric: to, lấp lánh, chạm được.</summary>
    public sealed record Hotspot(
        string Id,
        string Name,
        int DistrictId,          // Khu chứa hotspot — xem Districts.All (18 khu)
        TimeFrame BestFrame,     // Khung hotspot "đông" nhất (vật mới / sự kiện mới hay xuất hiện)
        string MaterialId,       // Nguyên liệu nhặt được
        int AmountPerVisit);     // Số lượng nhặt được mỗi lần khám phá

    public static class Exploration
    {
        // PROVISIONAL — danh sách hotspot slice, chưa chốt. Chỉ dùng khu slice đầu:
        // 1 Xóm Trọ Cũ, 2 Chợ Đầu Mối, 17 Công Viên An Bình, 18 Phố Đi Bộ – Chợ Đêm.
        public static readonly IReadOnlyList<Hotspot> Hotspots = new List<Hotspot>
        {
            new("hs-cho-sang", "Sạp rau buổi sáng", 2, TimeFrame.Sang, MaterialIds.LaChuoi, 2),
            new("hs-cho-chieu", "Góc phế liệu chợ", 2, TimeFrame.Chieu, MaterialIds.SatVun, 1),
            new("hs-tro-toi", "Hẻm trọ buổi tối", 1, TimeFrame.Toi, MaterialIds.ChaiNhua, 2),
            new("hs-cong-vien", "Ghế đá công viên", 17, TimeFrame.Chieu, MaterialIds.VanGo, 1),
            new("hs-cho-dem", "Sạp đêm cuối phố", 18, TimeFrame.Toi, MaterialIds.VaiVun, 2),
        };

        // Khu đã mở fast-travel trong slice: 4 khu trên. Khu khác mở dần bằng chế tạo / quest
        // (xem Crafting.cs + GDD Mục 9) — không hardcode khu chưa mở ở đây.
        public static readonly IReadOnlyList<int> FastTravelUnlockedSlice = new List<int> { 1, 2, 17, 18 };

        public static Hotspot? Get(string hotspotId)
        {
            foreach (var h in Hotspots)
                if (h.Id == hotspotId) return h;
            return null;
        }

        /// <summary>Hotspot trong 1 khu, theo khung hiện tại (khung tốt lên trước).</summary>
        public static IReadOnlyList<Hotspot> HotspotsInDistrict(int districtId, TimeFrame frame)
        {
            var best = new List<Hotspot>();
            var rest = new List<Hotspot>();
            foreach (var h in Hotspots)
            {
                if (h.DistrictId != districtId) continue;
                if (h.BestFrame == frame) best.Add(h);
                else rest.Add(h);
            }
            best.AddRange(rest);
            return best;
        }

        /// <summary>Chỉ fast travel tới khu đã mở. Trả false nếu khu chưa mở / không có trong 18 khu.</summary>
        public static bool CanFastTravel(int districtId, IReadOnlyCollection<int> unlockedDistrictIds)
        {
            if (unlockedDistrictIds == null) return false;
            foreach (var d in Districts.All)
                if (d.Id == districtId) return unlockedDistrictIds.Contains(districtId);
            return false;
        }

        /// <summary>
        /// Khám phá 1 hotspot: nhặt nguyên liệu vào túi nguyên liệu.
        /// Mỗi hotspot chỉ khám phá 1 lần / 1 ngày game — quay lại ngày sau có vật mới
        /// (đúng kiểu Nadia: quay lại địa điểm cũ có vật/sự kiện mới).
        /// Trả false nếu hotspot không có, hoặc đã khám phá trong ngày game này.
        /// </summary>
        public static bool Explore(
            string hotspotId,
            int gameDay,
            HashSet<string> visitedToday,
            Dictionary<string, int> materials)
        {
            var hotspot = Get(hotspotId);
            if (hotspot == null) return false;
            if (visitedToday.Contains(hotspotId)) return false; // Đã nhặt hôm nay — mai quay lại có đồ mới.
            visitedToday.Add(hotspotId);
            materials.TryGetValue(hotspot.MaterialId, out var count);
            materials[hotspot.MaterialId] = count + hotspot.AmountPerVisit;
            return true;
        }

        /// <summary>Sang ngày game mới: reset lượt khám phá trong ngày.</summary>
        public static void NewGameDay(HashSet<string> visitedToday) => visitedToday.Clear();
    }

    /// <summary>
    /// NPC dẫn đường thay Soul Crystal / Evie của Nadia (docs/nadia-reference.md §1 hàng 7):
    /// gợi ý nhúng trong lời thoại, gắn với mục tiêu hiện tại, không spoil đáp án.
    /// Hint nhạt dần theo tiến trình — không biến mất đột ngột giữa game (lỗi Nadia đã mắc).
    /// </summary>
    public static class GuideHint
    {
        // NPC gợi ý theo khu người chơi đang đứng. Tên NPC là NPC Phố Xô Bồ, không phải Nadia.
        public static string HintForDistrict(int districtId, string currentGoal)
        {
            var goal = string.IsNullOrWhiteSpace(currentGoal) ? "chưa có mục tiêu rõ" : currentGoal;
            return districtId switch
            {
                1 => $"Cô Tư (chủ trọ): \"Ở hẻm này thì cứ ra chợ sớm mà nhặt đồ. Còn {goal} thì ghé sạp đầu hẻm hỏi thử.\"",
                2 => $"Chị Lệ (sạp rau): \"Chợ sáng nhiều đồ lắm, chiều thì qua góc phế liệu. {goal} thì cần đồ chế — coi lại túi nguyên liệu đi.\"",
                17 => $"Ông Ba (công viên): \"Ngồi ghế đá nghĩ cho kỹ đã. {goal} gấp thì không xong đâu, cứ từng bước.\"",
                18 => $"Anh Hải (chợ đêm): \"Đêm nay đông khách, vừa bán vừa nhặt được đồ. {goal} thì để mai sáng làm tiếp cũng được.\"",
                _ => $"Bạn thân: \"Không biết làm gì tiếp thì mở điện thoại coi Bản đồ với Việc làm đã. Mục tiêu hiện tại: {goal}.\"",
            };
        }
    }
}
