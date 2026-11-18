// Phố Xô Bồ — Hệ thời gian kiểu C (Mục 1 đã chốt)
// 1 ngày game = 30 phút thật. 3 khung: Sáng / Chiều / Tối.
// Miss khung KHÔNG bị phạt. Sự kiện chung: thứ 7, 20:00.
using System;

namespace PhoXoBo
{
    public enum TimeFrame { Sang, Chieu, Toi }

    public static class TimeSystem
    {
        public static readonly TimeSpan GameDayLength = TimeSpan.FromMinutes(30);
        public static readonly TimeSpan FrameLength = TimeSpan.FromMinutes(10); // 30 phút / 3 khung

        /// <summary>Khung hiện tại theo thời gian thật đã trôi từ đầu ngày game.</summary>
        public static TimeFrame CurrentFrame(TimeSpan elapsedInDay)
        {
            if (elapsedInDay < FrameLength) return TimeFrame.Sang;
            if (elapsedInDay < FrameLength * 2) return TimeFrame.Chieu;
            return TimeFrame.Toi;
        }

        /// <summary>Miss khung không phạt: chỉ trả về true nếu khung đã qua mà người chơi không vào.</summary>
        public static bool IsMissed(TimeFrame frame, TimeSpan elapsedInDay) =>
            frame switch
            {
                TimeFrame.Sang => elapsedInDay >= FrameLength,
                TimeFrame.Chieu => elapsedInDay >= FrameLength * 2,
                _ => elapsedInDay >= GameDayLength,
            };
        // Lưu ý thiết kế: IsMissed chỉ dùng để hiển thị, KHÔNG trừ điểm / phạt.
    }
}
