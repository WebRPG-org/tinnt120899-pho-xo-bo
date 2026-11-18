// Phố Xô Bồ — Túi đồ slice đầu tiên (Mục 2 + Mục 7)
// Mua / dùng vật phẩm trong Chợ. Vật phẩm tiêu hao chỉ cho BUFF TẠM trong 1 khung
// (xem Buff), KHÔNG đổi chỉ số vĩnh viễn — nên không phá trần tổng của Stats.cs
// và không mâu thuẫn GameBalance (GameBalance không có số vật phẩm tiêu hao).
// Giá + hiệu ứng dưới đây là số cấu hình slice, PROVISIONAL, chưa chốt:
// khi GDD chốt bảng vật phẩm thì sửa đúng bảng ItemCatalog, không sửa code túi đồ.
// Vật phẩm gắn chỉ số vĩnh viễn (nhà/xe/điện thoại/quần áo, 3 dòng chỉ số Mục 7)
// KHÔNG nằm ở đây — thuộc hệ trang bị, làm ở phase sau.
using System;
using System.Collections.Generic;

namespace PhoXoBo
{
    /// <summary>Buff tạm trong 1 khung game: +N vào 1 chỉ số gốc, hết khung thì mất.</summary>
    public sealed record Buff(BaseStat Stat, int Amount, TimeFrame Frame);

    public sealed record ItemDefinition(
        string Id,
        string Name,
        long PriceVnd,      // Giá mua 1 cái, tiền trong game (PROVISIONAL — số cấu hình slice)
        bool Stackable,
        Buff? Effect,       // null = vật phẩm không buff chỉ số (vd: áo mưa — chỉ mở điều kiện)
        string? UnlockNote);// Ghi chú điều kiện mở, vd: "Làm được ca mưa"

    public static class ItemCatalog
    {
        // PROVISIONAL — giá + buff là số ví dụ của slice, chưa chốt.
        public static readonly IReadOnlyList<ItemDefinition> Items = new List<ItemDefinition>
        {
            new("com-tam", "Cơm tấm", 35_000, true, new Buff(BaseStat.The, 5, TimeFrame.Chieu), null),
            new("ca-phe", "Cà phê", 25_000, true, new Buff(BaseStat.Tri, 5, TimeFrame.Sang), null),
            new("sach", "Sách", 80_000, true, new Buff(BaseStat.Tri, 5, TimeFrame.Toi), null),
            new("ao-mua", "Áo mưa", 120_000, false, null, "Làm được ca mưa, không bị ướt"),
        };

        public static ItemDefinition? Get(string id)
        {
            foreach (var item in Items)
                if (item.Id == id) return item;
            return null;
        }
    }

    /// <summary>Túi đồ của người chơi: số lượng theo Id. Tiền không nằm ở đây (thuộc ví/Economy).</summary>
    public sealed class Inventory
    {
        private readonly Dictionary<string, int> _items = new();
        private readonly List<Buff> _activeBuffs = new();

        public int Count(string itemId) =>
            _items.TryGetValue(itemId, out var count) ? count : 0;

        public IReadOnlyList<Buff> ActiveBuffs => _activeBuffs;

        /// <summary>Mua vật phẩm (đã trừ tiền ở ngoài). Trả false nếu Id không có trong catalog.</summary>
        public bool Add(string itemId, int quantity = 1)
        {
            var def = ItemCatalog.Get(itemId);
            if (def == null || quantity <= 0) return false;
            // Đồ không xếp chồng: chỉ giữ đúng 1 cái, và chỉ nhận đúng 1 cái mỗi lần.
            // Lựa chọn thiết kế: quantity > 1 thì trả false, không thêm gì — nhất quán
            // với hành vi hiện tại khi túi đã có món đó (cũng trả false, không thêm),
            // thay vì âm thầm bớt số lượng xuống 1. Người mua muốn 1 cái thì gọi lại
            // với quantity = 1. Trước đây chỉ chặn khi túi đã có món đó nên
            // Add("ao-mua", 2) lúc túi trống vẫn nhận 2 cái (bug, đã sửa).
            if (!def.Stackable && (quantity > 1 || Count(itemId) > 0)) return false;
            _items[itemId] = Count(itemId) + quantity;
            return true;
        }

        /// <summary>Dùng 1 vật phẩm: trừ khỏi túi, kích hoạt buff tạm (nếu có). Trả false nếu không có đồ.</summary>
        public bool Use(string itemId, TimeFrame currentFrame)
        {
            var def = ItemCatalog.Get(itemId);
            if (def == null || Count(itemId) <= 0) return false;
            _items[itemId] = Count(itemId) - 1;
            // Buff áp đúng khung ghi trong catalog (def.Effect.Frame), KHÔNG ghi đè
            // bằng khung hiện tại: khung trong catalog mới là khung buff có tác dụng.
            // Trước đây `def.Effect with { Frame = currentFrame }` ghi đè khung catalog
            // nên cơm tấm (catalog ghi Chiều) dùng lúc Sáng thì buff rơi vào Sáng (bug,
            // đã sửa). Tham số currentFrame giữ lại để không đổi API của người gọi;
            // nó không còn quyết định khung buff.
            if (def.Effect != null)
                _activeBuffs.Add(def.Effect);
            return true;
        }

        /// <summary>Buff đang có hiệu lực trong khung hiện tại.</summary>
        public int BuffFor(BaseStat stat, TimeFrame frame)
        {
            var total = 0;
            foreach (var buff in _activeBuffs)
                if (buff.Stat == stat && buff.Frame == frame) total += buff.Amount;
            return total;
        }

        /// <summary>Hết khung thì buff tạm hết hiệu lực (gọi khi chuyển khung).</summary>
        public void EndFrame(TimeFrame frame) => _activeBuffs.RemoveAll(b => b.Frame == frame);
    }
}
