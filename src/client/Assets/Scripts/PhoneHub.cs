// Phố Xô Bồ — Điện thoại là menu chính (Mục 2 đã chốt)
// Overlay hub, KHÔNG thay thế thế giới 2.5D: vẫn phải đi lại trong phố.
// 9 tab đúng GDD: Danh bạ/Tin nhắn, Ngân hàng, Bản đồ, Việc làm, Chợ,
// Học tập, Sức khỏe, Xã hội, Cài đặt.
// File này chỉ giữ trạng thái + điều hướng tab (logic thuần C#).
// Lớp UI Unity (Canvas / Button) bind vào các hàm Open/Close/SelectTab.
using System;
using System.Collections.Generic;

namespace PhoXoBo
{
    public enum PhoneTab
    {
        DanhBaTinNhan, // Danh bạ / Tin nhắn
        NganHang,       // Ngân hàng
        BanDo,          // Bản đồ — 18 khu, xem docs/districts.md
        ViecLam,        // Việc làm — xem Jobs.cs
        Cho,            // Chợ — mua/bán, đấu giá
        HocTap,         // Học tập — xem GameBalance.Degrees
        SucKhoe,        // Sức khỏe — đồng hồ năng lượng theo ngày
        XaHoi,          // Xã hội — bạn bè, cặp đôi, gia đình, công ty
        CaiDat,         // Cài đặt
    }

    public sealed class PhoneHub
    {
        // Thứ tự tab hiển thị trên điện thoại, khớp GDD Mục 2.
        public static readonly IReadOnlyList<PhoneTab> TabOrder = new List<PhoneTab>
        {
            PhoneTab.DanhBaTinNhan,
            PhoneTab.NganHang,
            PhoneTab.BanDo,
            PhoneTab.ViecLam,
            PhoneTab.Cho,
            PhoneTab.HocTap,
            PhoneTab.SucKhoe,
            PhoneTab.XaHoi,
            PhoneTab.CaiDat,
        };

        public bool IsOpen { get; private set; }
        public PhoneTab CurrentTab { get; private set; } = PhoneTab.DanhBaTinNhan;

        // Số tin nhắn / thông báo chưa đọc theo tab (UI hiển thị chấm đỏ).
        private readonly Dictionary<PhoneTab, int> _unread = new();

        public event Action<PhoneTab>? TabChanged;
        public event Action<bool>? OpenChanged;

        public void Open(PhoneTab tab = PhoneTab.DanhBaTinNhan)
        {
            IsOpen = true;
            SelectTab(tab);
            OpenChanged?.Invoke(true);
        }

        public void Close()
        {
            IsOpen = false;
            OpenChanged?.Invoke(false);
        }

        public void Toggle()
        {
            if (IsOpen) Close();
            else Open(CurrentTab);
        }

        /// <summary>Chọn tab. Trả false nếu tab không có trong TabOrder (không bao giờ xảy ra với enum hiện tại).</summary>
        public bool SelectTab(PhoneTab tab)
        {
            if (!TabOrder.Contains(tab)) return false;
            CurrentTab = tab;
            _unread[tab] = 0; // Mở tab thì đánh dấu đã đọc.
            TabChanged?.Invoke(tab);
            return true;
        }

        public void Notify(PhoneTab tab)
        {
            _unread.TryGetValue(tab, out var count);
            _unread[tab] = count + 1;
        }

        public int UnreadCount(PhoneTab tab) =>
            _unread.TryGetValue(tab, out var count) ? count : 0;

        public int TotalUnread
        {
            get
            {
                var total = 0;
                foreach (var count in _unread.Values) total += count;
                return total;
            }
        }
    }
}
