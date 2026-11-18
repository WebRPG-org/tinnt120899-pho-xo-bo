// Phố Xô Bồ — Chế tạo kiểu Treasure of Nadia (docs/nadia-reference.md §1, hàng 3/4/5)
// Nadia: Basic Shovel = Shovel Head + Shaft + Iron Ore; crafting là CỔNG TIẾN TRÌNH
// bắt buộc (không chế được thì không mở khu tiếp), công cụ nâng cấp ĐỔI HÀNH VI
// (không chỉ +5% số). Chuyển sang đồ chợ Việt, chế ở Góc Chế Tạo trong nhà / sạp chợ.
// - Nguyên liệu: lấy từ Exploration.cs (hotspot) — Id dùng chung MaterialIds.
// - Công thức học qua chơi / NPC dạy, KHÔNG mua bằng tiền thật.
// - Số liệu: công thức + bậc công cụ là số cấu hình slice, PROVISIONAL, chưa chốt —
//   khi GDD chốt bảng chế tạo thì sửa đúng RecipeCatalog / ToolTiers, không sửa code chế.
// - Không mâu thuẫn GameBalance: GameBalance không có số chế tạo; đồ chế bán ở Chợ
//   (phí đấu giá 5% đã chốt) nhưng không phải nguồn tiền duy nhất (GDD Mục 7).
using System;
using System.Collections.Generic;

namespace PhoXoBo
{
    /// <summary>Bậc công cụ: mỗi bậc ĐỔI HÀNH VI thật (kiểu Nadia), không chỉ +số.</summary>
    public enum ToolTier { Tho = 1, Kha = 2, Tot = 3 }

    /// <summary>4 công cụ Phố Xô Bồ, tương đương 4 công cụ Nadia (Boots / Metal Detector / Guide / Shovel).</summary>
    public enum GameTool { XeDay, DenSoi, SoTay, Xeng }

    /// <summary>Một công thức chế tạo: nguyên liệu -> sản phẩm (công cụ / quà / đồ bán).</summary>
    public sealed record Recipe(
        string Id,
        string Name,
        IReadOnlyDictionary<string, int> Ingredients, // MaterialId -> số lượng cần
        string ResultId,      // Id sản phẩm: "tool:XeDay:2" (công cụ bậc 2) hoặc "item:<id>"
        string ResultName,
        string UnlockNote);   // Điều kiện học công thức (NPC dạy / làm quest nào) — PROVISIONAL

    public static class Crafting
    {
        // Hành vi đổi theo bậc — mô tả, không phải số chốt; code gameplay dùng bậc này để rẽ nhánh.
        public static string ToolBehaviour(GameTool tool, ToolTier tier) => (tool, tier) switch
        {
            (GameTool.XeDay, ToolTier.Tho) => "Chở được ít hàng, không đi được đường mưa.",
            (GameTool.XeDay, ToolTier.Kha) => "Chở được nhiều hàng hơn.",
            (GameTool.XeDay, ToolTier.Tot) => "Chở nhiều + đi được đường mưa, không bị ướt hàng.",
            (GameTool.DenSoi, ToolTier.Tho) => "Thấy hotspot thường.",
            (GameTool.DenSoi, ToolTier.Kha) => "Thấy hotspot thường + hotspot ẩn gần.",
            (GameTool.DenSoi, ToolTier.Tot) => "Thấy mọi hotspot, kể cả hotspot hiếm chỉ xuất hiện 1 khung/ngày.",
            (GameTool.SoTay, ToolTier.Tho) => "NPC gợi ý chung chung.",
            (GameTool.SoTay, ToolTier.Kha) => "NPC gợi ý rõ mục tiêu + khu cần tới.",
            (GameTool.SoTay, ToolTier.Tot) => "NPC gợi ý rõ mục tiêu + khu + nguyên liệu còn thiếu.",
            (GameTool.Xeng, ToolTier.Tho) => "Nhặt được nguyên liệu thường.",
            (GameTool.Xeng, ToolTier.Kha) => "Nhặt nhanh hơn, thỉnh thoảng được thêm 1 nguyên liệu.",
            (GameTool.Xeng, ToolTier.Tot) => "Nhặt nhanh + có cơ hội nhặt được nguyên liệu hiếm.",
            _ => "Chưa rõ bậc công cụ.",
        };

        // PROVISIONAL — công thức slice, chưa chốt. Ví dụ đầu tiên tương đương
        // Basic Shovel của Nadia (Shovel Head + Shaft + Iron Ore), đổi sang đồ chợ Việt:
        // Xe Đẩy Hàng = Khung Sắt + Bánh Xe + Ván Gỗ.
        public static readonly IReadOnlyList<Recipe> RecipeCatalog = new List<Recipe>
        {
            new(
                "che-xe-day",
                "Xe Đẩy Hàng (bậc 1)",
                new Dictionary<string, int>
                {
                    [MaterialIds.KhungSat] = 1,
                    [MaterialIds.BanhXe] = 2,
                    [MaterialIds.VanGo] = 2,
                },
                "tool:XeDay:1", "Xe Đẩy Hàng",
                "Cô Tư dạy sau khi làm xong quest đầu tiên ở Xóm Trọ Cũ."),
            new(
                "che-den-soi",
                "Đèn Soi (bậc 1)",
                new Dictionary<string, int>
                {
                    [MaterialIds.SatVun] = 2,
                    [MaterialIds.ChaiNhua] = 2,
                },
                "tool:DenSoi:1", "Đèn Soi",
                "Anh Hải dạy ở Phố Đi Bộ – Chợ Đêm."),
            new(
                "che-qua-tang",
                "Quà Tặng Thủ Công (tặng NPC)",
                new Dictionary<string, int>
                {
                    [MaterialIds.LaChuoi] = 2,
                    [MaterialIds.VaiVun] = 1,
                },
                "item:qua-tang", "Quà Tặng Thủ Công",
                "Học từ bạn thân NPC — tặng NPC để tăng thân thiết, mở quest (GDD Mục 8/9)."),
        };

        public static Recipe? Get(string recipeId)
        {
            foreach (var r in RecipeCatalog)
                if (r.Id == recipeId) return r;
            return null;
        }

        /// <summary>Đủ nguyên liệu để chế không? Không trừ đồ ở đây.</summary>
        public static bool CanCraft(Recipe recipe, IReadOnlyDictionary<string, int> materials)
        {
            foreach (var (materialId, needed) in recipe.Ingredients)
            {
                materials.TryGetValue(materialId, out var have);
                if (have < needed) return false;
            }
            return true;
        }

        /// <summary>
        /// Chế 1 món: trừ nguyên liệu, trả về ResultId. Trả null nếu công thức không có
        /// hoặc thiếu nguyên liệu. Server là nguồn sự thật khi online — client chỉ giữ
        /// bản đếm tạm để hiển thị (giống Jobs.WeeklyQuotaTracker).
        /// Nguyên liệu nào chế hết (số lượng về 0) thì XÓA key khỏi túi, không để lại
        /// entry 0 — túi chỉ giữ nguyên liệu còn thật (sửa 18/11, xem test
        /// Craft_TruDungSoLuongVaTraResultId).
        /// </summary>
        public static string? Craft(Recipe recipe, Dictionary<string, int> materials)
        {
            if (!CanCraft(recipe, materials)) return null;
            foreach (var (materialId, needed) in recipe.Ingredients)
            {
                var conLai = materials[materialId] - needed;
                // Chế hết loại này thì xóa key khỏi túi, không để lại entry 0.
                if (conLai <= 0) materials.Remove(materialId);
                else materials[materialId] = conLai;
            }
            return recipe.ResultId;
        }

        /// <summary>Nguyên liệu còn thiếu để chế 1 công thức (để Sổ Tay gợi ý, xem GuideHint).</summary>
        public static IReadOnlyDictionary<string, int> MissingIngredients(
            Recipe recipe, IReadOnlyDictionary<string, int> materials)
        {
            var missing = new Dictionary<string, int>();
            foreach (var (materialId, needed) in recipe.Ingredients)
            {
                materials.TryGetValue(materialId, out var have);
                if (have < needed) missing[materialId] = needed - have;
            }
            return missing;
        }
    }
}
