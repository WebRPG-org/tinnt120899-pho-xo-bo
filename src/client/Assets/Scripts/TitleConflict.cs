// Phố Xô Bồ — Xung đột danh hiệu (Mục 3 đã chốt)
// Danh hiệu không giới hạn số lượng, nhưng phải logic: cặp xung đột chặn lẫn nhau.
// Ví dụ: Tướng Cướp không làm được Cảnh sát. Đổi phe cần quest "Cải tà quy chính".
using System.Collections.Generic;

namespace PhoXoBo
{
    public enum Alignment { Chinh, Ta, TrungLap }

    public static class TitleConflict
    {
        // Danh hiệu -> danh hiệu / nghề bị chặn.
        private static readonly Dictionary<string, string[]> BlockedBy = new()
        {
            ["Tướng Cướp"] = new[] { "Cảnh sát", "Thẩm phán", "Hải quan", "Giáo viên" },
            ["Trùm Buôn Lậu"] = new[] { "Cảnh sát", "Thẩm phán", "Hải quan", "Giáo viên" },
            ["Tham Quan"] = new[] { "Thanh Liêm", "Người Hùng" },
            ["Kẻ Lừa Đảo"] = new[] { "Luật Sư Chính Trực" }, // Lưu ý: không chặn "Luật Sư Bào Chữa".
            ["Học Giả"] = new[] { "Kẻ Bỏ Học" },
            ["Tiến sĩ"] = new[] { "Kẻ Bỏ Học" },
            ["Tỷ Phú Từ Thiện"] = new[] { "Kẻ Keo Kiệt" },
        };

        /// <summary>True nếu danh hiệu đang có chặn danh hiệu/nghề muốn nhận.</summary>
        public static bool IsBlocked(IReadOnlyCollection<string> ownedTitles, string wantedTitleOrJob)
        {
            foreach (var title in ownedTitles)
                if (BlockedBy.TryGetValue(title, out var blocked))
                    foreach (var b in blocked)
                        if (b == wantedTitleOrJob) return true;
            return false;
        }
    }
}
