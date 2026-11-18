// Phố Xô Bồ — Điện thoại trên màn hình (MonoBehaviour mỏng, C2)
// Bám sát Treasure of Nadia (docs/nadia-reference.md §1 hàng 8): điện thoại
// là hub gom mọi menu — 1 thiết bị trong thế giới gom hệ thống. Chuyển sang
// Phố Xô Bồ: 9 tab đúng GDD (PhoneHub.TabOrder). Mọi luật tab / chưa đọc nằm
// ở PhoneHub.cs (logic thuần); file này chỉ bật/tắt Canvas + hiển thị tab.
// Canvas UI chưa dựng trong lượt này (chưa có art/UI) — các field Canvas/Text
// để null thì logic điện thoại vẫn chạy (mở/đóng/chọn tab), chỉ chưa hiện hình.
// CHƯA MỞ/BUILD ĐƯỢC trên VM này (không có Unity).
using UnityEngine;
using UnityEngine.UI;

namespace PhoXoBo
{
    /// <summary>Overlay điện thoại. Gắn Canvas trong Editor khi dựng UI; nút bấm trên UI gọi OpenTab(...).</summary>
    public class PhoneHubView : MonoBehaviour
    {
        [SerializeField] private Canvas phoneCanvas; // Canvas điện thoại (chưa dựng — để trống cũng chạy được logic).
        [SerializeField] private Text tabLabel;      // Nhãn tên tab hiện tại (tuỳ chọn).

        private PhoneHub Phone => GameManagerBehaviour.Instance != null
            ? GameManagerBehaviour.Instance.Phone
            : null;

        private void Update()
        {
            // Phím P: mở/đóng điện thoại. Esc: đóng.
            if (Input.GetKeyDown(KeyCode.P)) TogglePhone();
            else if (Input.GetKeyDown(KeyCode.Escape) && Phone != null && Phone.IsOpen) ClosePhone();
        }

        public void TogglePhone()
        {
            if (Phone == null) return;
            Phone.Toggle();
            ApplyVisibility();
        }

        public void OpenPhone(PhoneTab tab = PhoneTab.DanhBaTinNhan)
        {
            if (Phone == null) return;
            Phone.Open(tab);
            ApplyVisibility();
        }

        public void ClosePhone()
        {
            if (Phone == null) return;
            Phone.Close();
            ApplyVisibility();
        }

        /// <summary>Chọn tab (nút tab trên UI gọi hàm này). Mở tab thì đánh dấu đã đọc tab đó (PhoneHub).</summary>
        public void OpenTab(PhoneTab tab)
        {
            if (Phone == null) return;
            Phone.Open(tab);
            ApplyVisibility();
        }

        private void ApplyVisibility()
        {
            if (Phone == null) return;
            if (phoneCanvas != null) phoneCanvas.enabled = Phone.IsOpen;
            if (tabLabel != null) tabLabel.text = Phone.CurrentTab.ToString();
        }
    }
}
