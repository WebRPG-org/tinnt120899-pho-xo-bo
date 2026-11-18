// Phố Xô Bồ — Tiến trình người chơi (Mục 9 đã chốt)
// 5 chương gắn với bậc: 1 Lên Phố (Lao động) -> 2 Lập Nghiệp (Cận trung lưu)
// -> 3 Khủng Hoảng (kiểm tra bậc, có thể tụt) -> 4 Vực Dậy (Trung lưu)
// -> 5 Thành Đạt / An Yên (nhiều kết thúc được tôn trọng).
// Số chốt dùng lại từ GameBalance / Stats; số chưa chốt ghi PROVISIONAL.
using System.Collections.Generic;

namespace PhoXoBo
{
    public enum Chapter { LenPho = 1, LapNghiep = 2, KhungHoang = 3, VucDay = 4, ThanhDat = 5 }

    public enum Ending { GiamDoc, HocGia, GiaDinh, TuDo, SieuGiau, ChuaMo }

    public static class PlayerProgress
    {
        // Điều kiện mở chương — theo GDD Mục 9 (số Danh vọng / Trí / tài sản đã chốt).
        public static bool CanOpenChapter(Chapter chapter, int tri, int danhVong, long taiSan, bool hasCloseRelationship, int helpQuestsDone)
        {
            return chapter switch
            {
                Chapter.LenPho => true,
                Chapter.LapNghiep => tri >= 40 || danhVong >= 200,
                Chapter.KhungHoang => true, // Chương 3 là bài kiểm tra, mở khi đã qua chương 2.
                Chapter.VucDay => helpQuestsDone >= 3 && hasCloseRelationship,
                Chapter.ThanhDat => tri >= 60 || danhVong >= 500 || taiSan >= 10_000_000_000L,
                _ => false,
            };
        }

        // Kết thúc chương 5 — nhiều kết thúc đều tính là thắng (Mục 12, chữa lành).
        public static Ending SuggestEnding(long taiSan, int tri, int danhVong, int anYen, bool hasSpouse)
        {
            if (taiSan >= 100_000_000_000L) return Ending.SieuGiau;
            if (taiSan >= 10_000_000_000L) return Ending.GiamDoc;
            if (tri >= 90 && danhVong >= 1500) return Ending.HocGia;
            if (hasSpouse && anYen >= 80) return Ending.GiaDinh;
            if (anYen >= 80) return Ending.TuDo;
            return Ending.ChuaMo;
        }

        // Bậc có thể tụt ở chương 3 nếu Danh vọng / An Yên thấp — không phạt nặng,
        // NPC giúp đỡ và người chơi được làm lại (Mục 12: thất bại không bị phạt).
        public static bool RankAtRisk(int danhVong, int anYen) => danhVong < 100 || anYen < 30;
    }
}
