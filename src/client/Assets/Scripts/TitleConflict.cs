// Phố Xô Bồ — Xung đột danh hiệu (Mục 3 đã chốt)
// Danh hiệu không giới hạn số lượng, nhưng phải logic: cặp xung đột chặn lẫn nhau.
// Ví dụ: Tướng Cướp không làm được Cảnh sát. Đổi phe cần quest "Cải tà quy chính".
using System;
using System.Collections.Generic;

namespace PhoXoBo
{
    public enum Alignment { Chinh, Ta, TrungLap }

    public static class TitleConflict
    {
        // Danh hiệu -> danh hiệu / nghề bị chặn.
        // So sánh không phân biệt hoa/thường (dùng StringComparer.OrdinalIgnoreCase).
        private static readonly Dictionary<string, string[]> BlockedBy = new(StringComparer.OrdinalIgnoreCase)
        {
            ["Tướng Cướp"] = new[] { "Cảnh sát", "Thẩm phán", "Hải quan", "Giáo viên" },
            ["Trùm Buôn Lậu"] = new[] { "Cảnh sát", "Thẩm phán", "Hải quan", "Giáo viên" },
            ["Tham Quan"] = new[] { "Thanh Liêm", "Người Hùng" },
            ["Kẻ Lừa Đảo"] = new[] { "Luật Sư Chính Trực" }, // Lưu ý: không chặn "Luật Sư Bào Chữa".
            ["Học Giả"] = new[] { "Kẻ Bỏ Học" },
            ["Tiến sĩ"] = new[] { "Kẻ Bỏ Học" },
            ["Tỷ Phú Từ Thiện"] = new[] { "Kẻ Keo Kiệt" },
        };

        /// <summary>
        /// True nếu danh hiệu đang có chặn danh hiệu/nghề muốn nhận — chặn cả hai chiều
        /// của mỗi cặp xung đột, không phân biệt hoa/thường.
        /// </summary>
        public static bool IsBlocked(IReadOnlyCollection<string> ownedTitles, string wantedTitleOrJob)
        {
            if (wantedTitleOrJob is null) return false;
            foreach (var title in ownedTitles)
            {
                if (title is null) continue;
                // Chiều xuôi: danh hiệu đang có chặn danh hiệu/nghề muốn nhận.
                if (BlockedBy.TryGetValue(title, out var blocked))
                    foreach (var b in blocked)
                        if (string.Equals(b, wantedTitleOrJob, StringComparison.OrdinalIgnoreCase))
                            return true;
                // Chiều ngược: danh hiệu/nghề muốn nhận chặn danh hiệu đang có
                // (ví dụ muốn nhận "Tướng Cướp" trong khi đang có "Cảnh sát").
                // Không cần bảng ngược riêng: tra thẳng BlockedBy[wanted] là đủ.
                if (BlockedBy.TryGetValue(wantedTitleOrJob, out var blockedByWanted))
                    foreach (var b in blockedByWanted)
                        if (string.Equals(b, title, StringComparison.OrdinalIgnoreCase))
                            return true;
            }
            return false;
        }
    }
}
