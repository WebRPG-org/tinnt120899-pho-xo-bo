// Phố Xô Bồ — Test EditMode cho hệ thời gian kiểu C (TimeSystem, Mục 1 đã chốt).
// Chạy bằng Unity Test Runner (EditMode), KHÔNG chạy được trên VM này (không có Unity).
// API thật đang test: TimeSystem.GameDayLength, TimeSystem.FrameLength,
// TimeSystem.CurrentFrame(TimeSpan), TimeSystem.IsMissed(TimeFrame, TimeSpan),
// GameBalance.GameDayMinutes, GameBalance.FramesPerDay.
//
// GIỚI HẠN ĐÃ BIẾT (không bịa test cho qua):
// - CurrentFrame KHÔNG wrap khi elapsed vượt quá 1 ngày game (vd 35 phút vẫn trả Toi),
//   và không có API "sang ngày mới / ngày game thứ mấy" — test dưới đây ghi nhận
//   đúng hành vi này; nếu GDD chốt wrap thì bổ sung test + sửa code cùng lúc.
// - IsMissed chỉ dùng để hiển thị, KHÔNG phạt (theo chú thích trong TimeSystem.cs).
using System;
using NUnit.Framework;

namespace PhoXoBo.Tests
{
    [TestFixture]
    public class TimeSystemTests
    {
        // --- Hằng thời gian đã chốt: 1 ngày game = 30 phút thật, 3 khung, mỗi khung 10 phút ---

        [Test]
        public void GameDayLength_La30Phut()
        {
            Assert.AreEqual(TimeSpan.FromMinutes(30), TimeSystem.GameDayLength);
            Assert.AreEqual(30, GameBalance.GameDayMinutes);
        }

        [Test]
        public void FrameLength_La10Phut_Bang1Phan3NgayGame()
        {
            Assert.AreEqual(TimeSpan.FromMinutes(10), TimeSystem.FrameLength);
            Assert.AreEqual(TimeSystem.GameDayLength, TimeSystem.FrameLength * 3);
            Assert.AreEqual(3, GameBalance.FramesPerDay);
        }

        // --- CurrentFrame: ranh giới khung (Sáng 0-10', Chiều 10-20', Tối 20-30') ---

        [Test]
        public void CurrentFrame_DauNgay_LaSang()
        {
            Assert.AreEqual(TimeFrame.Sang, TimeSystem.CurrentFrame(TimeSpan.Zero));
            Assert.AreEqual(TimeFrame.Sang, TimeSystem.CurrentFrame(TimeSpan.FromMinutes(9) + TimeSpan.FromSeconds(59)));
        }

        [Test]
        public void CurrentFrame_TuPhut10_LaChieu()
        {
            Assert.AreEqual(TimeFrame.Chieu, TimeSystem.CurrentFrame(TimeSpan.FromMinutes(10)));
            Assert.AreEqual(TimeFrame.Chieu, TimeSystem.CurrentFrame(TimeSpan.FromMinutes(19) + TimeSpan.FromSeconds(59)));
        }

        [Test]
        public void CurrentFrame_TuPhut20_LaToi()
        {
            Assert.AreEqual(TimeFrame.Toi, TimeSystem.CurrentFrame(TimeSpan.FromMinutes(20)));
            Assert.AreEqual(TimeFrame.Toi, TimeSystem.CurrentFrame(TimeSpan.FromMinutes(29) + TimeSpan.FromSeconds(59)));
        }

        [Test]
        public void CurrentFrame_VuotQuaNgayGame_VanLaToi_KhongWrap()
        {
            // Hành vi thật hiện tại: elapsed > 30 phút vẫn trả Toi (không wrap sang ngày mới).
            Assert.AreEqual(TimeFrame.Toi, TimeSystem.CurrentFrame(TimeSpan.FromMinutes(30)));
            Assert.AreEqual(TimeFrame.Toi, TimeSystem.CurrentFrame(TimeSpan.FromMinutes(35)));
        }

        // --- IsMissed: khung đã qua mà chưa vào -> true; chưa qua -> false; KHÔNG phạt ---

        [Test]
        public void IsMissed_Sang_ChuaQuaPhut10_ThiFalse_QuaThiTrue()
        {
            Assert.IsFalse(TimeSystem.IsMissed(TimeFrame.Sang, TimeSpan.FromMinutes(9) + TimeSpan.FromSeconds(59)));
            Assert.IsTrue(TimeSystem.IsMissed(TimeFrame.Sang, TimeSpan.FromMinutes(10)));
        }

        [Test]
        public void IsMissed_Chieu_ChuaQuaPhut20_ThiFalse_QuaThiTrue()
        {
            Assert.IsFalse(TimeSystem.IsMissed(TimeFrame.Chieu, TimeSpan.FromMinutes(19) + TimeSpan.FromSeconds(59)));
            Assert.IsTrue(TimeSystem.IsMissed(TimeFrame.Chieu, TimeSpan.FromMinutes(20)));
        }

        [Test]
        public void IsMissed_Toi_ChuaHetNgay_ThiFalse_HetNgayThiTrue()
        {
            Assert.IsFalse(TimeSystem.IsMissed(TimeFrame.Toi, TimeSpan.FromMinutes(29) + TimeSpan.FromSeconds(59)));
            Assert.IsTrue(TimeSystem.IsMissed(TimeFrame.Toi, TimeSpan.FromMinutes(30)));
        }

        [Test]
        public void IsMissed_DauNgay_ChuaKhungNaoMiss()
        {
            Assert.IsFalse(TimeSystem.IsMissed(TimeFrame.Sang, TimeSpan.Zero));
            Assert.IsFalse(TimeSystem.IsMissed(TimeFrame.Chieu, TimeSpan.Zero));
            Assert.IsFalse(TimeSystem.IsMissed(TimeFrame.Toi, TimeSpan.Zero));
        }
    }
}
