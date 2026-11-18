// Phố Xô Bồ — Test EditMode cho chế tạo (Crafting.cs, kiểu Treasure of Nadia).
// Chạy bằng Unity Test Runner (EditMode), KHÔNG chạy được trên VM này (không có Unity).
// API thật đang test: Crafting (ToolBehaviour, RecipeCatalog, Get, CanCraft, Craft,
// MissingIngredients), Recipe (Id, Ingredients, ResultId), GameTool, ToolTier,
// MaterialIds (dùng chung với Exploration.cs).
//
// Số PROVISIONAL (chưa chốt GDD, lấy đúng comment trong Crafting.cs — đổi code là test
// phải đổi theo): 3 công thức slice — che-xe-day (Khung Sắt 1 + Bánh Xe 2 + Ván Gỗ 2
// -> "tool:XeDay:1"), che-den-soi (Sắt Vụn 2 + Chai Nhựa 2 -> "tool:DenSoi:1"),
// che-qua-tang (Lá Chuối 2 + Vải Vụn 1 -> "item:qua-tang"); mô tả hành vi 12 combo
// công cụ × bậc (không phải số chốt, code gameplay dùng bậc để rẽ nhánh).
// Lưu ý hành vi thật (đã sửa 18/11, xem test Craft_TruDungSoLuongVaTraResultId):
// - Craft trừ nguyên liệu TRỰC TIẾP trên Dictionary truyền vào (đổi số lượng trong
//   túi gọi hàm), và nguyên liệu nào chế hết (về 0) thì XÓA key khỏi túi, không để
//   lại entry 0. Trước 18/11 key còn 0 vẫn nằm lại trong túi (hành vi lạ đợt 18:50).
using System;
using System.Collections.Generic;
using NUnit.Framework;

namespace PhoXoBo.Tests
{
    [TestFixture]
    public class CraftingTests
    {
        // --- ToolBehaviour: đủ 4 tool × 3 tier đều khác nhau, không trả mặc định ---

        [Test]
        public void ToolBehaviour_12Combo_DeuKhacNhauVaKhongPhaiMacDinh()
        {
            var moTa = new HashSet<string>();
            foreach (GameTool tool in Enum.GetValues(typeof(GameTool)))
            foreach (ToolTier tier in Enum.GetValues(typeof(ToolTier)))
            {
                var text = Crafting.ToolBehaviour(tool, tier);
                Assert.AreNotEqual("Chưa rõ bậc công cụ.", text,
                    $"Combo {tool}/{tier} phải có mô tả hành vi riêng, không được rơi về mặc định");
                Assert.IsFalse(string.IsNullOrWhiteSpace(text), $"Combo {tool}/{tier} phải có mô tả");
                Assert.IsTrue(moTa.Add(text),
                    $"Mô tả của {tool}/{tier} trùng với combo khác: \"{text}\"");
            }
            Assert.AreEqual(12, moTa.Count, "4 tool × 3 tier = 12 mô tả khác nhau");
        }

        [Test]
        public void ToolBehaviour_BacLa_TraChuoiMacDinh()
        {
            Assert.AreEqual("Chưa rõ bậc công cụ.",
                Crafting.ToolBehaviour(GameTool.XeDay, (ToolTier)99),
                "Bậc không nằm trong Tho/Kha/Tot thì rơi về chuỗi mặc định");
            Assert.AreEqual("Chưa rõ bậc công cụ.",
                Crafting.ToolBehaviour((GameTool)99, ToolTier.Tho),
                "Tool không nằm trong 4 tool thì rơi về chuỗi mặc định");
        }

        // --- RecipeCatalog: 3 công thức + Get (id lạ -> null) ---

        [Test]
        public void RecipeCatalog_Co3CongThuc()
        {
            Assert.AreEqual(3, Crafting.RecipeCatalog.Count, "Slice đầu có đúng 3 công thức");
            Assert.IsNotNull(Crafting.Get("che-xe-day"));
            Assert.IsNotNull(Crafting.Get("che-den-soi"));
            Assert.IsNotNull(Crafting.Get("che-qua-tang"));
        }

        [Test]
        public void RecipeCatalog_CheXeDay_NguyenLieuVaKetQua()
        {
            // Tương đương Basic Shovel của Nadia (Shovel Head + Shaft + Iron Ore),
            // đổi sang đồ chợ Việt: Xe Đẩy Hàng = Khung Sắt + Bánh Xe + Ván Gỗ (PROVISIONAL).
            var recipe = Crafting.Get("che-xe-day");
            Assert.IsNotNull(recipe);
            Assert.AreEqual("Xe Đẩy Hàng (bậc 1)", recipe!.Name);
            Assert.AreEqual(3, recipe.Ingredients.Count);
            Assert.AreEqual(1, recipe.Ingredients[MaterialIds.KhungSat]);
            Assert.AreEqual(2, recipe.Ingredients[MaterialIds.BanhXe]);
            Assert.AreEqual(2, recipe.Ingredients[MaterialIds.VanGo]);
            Assert.AreEqual("tool:XeDay:1", recipe.ResultId);
            Assert.AreEqual("Xe Đẩy Hàng", recipe.ResultName);
        }

        [Test]
        public void RecipeCatalog_CheDenSoi_NguyenLieuVaKetQua()
        {
            var recipe = Crafting.Get("che-den-soi");
            Assert.IsNotNull(recipe);
            Assert.AreEqual("Đèn Soi (bậc 1)", recipe!.Name);
            Assert.AreEqual(2, recipe.Ingredients.Count);
            Assert.AreEqual(2, recipe.Ingredients[MaterialIds.SatVun]);
            Assert.AreEqual(2, recipe.Ingredients[MaterialIds.ChaiNhua]);
            Assert.AreEqual("tool:DenSoi:1", recipe.ResultId);
            Assert.AreEqual("Đèn Soi", recipe.ResultName);
        }

        [Test]
        public void RecipeCatalog_CheQuaTang_NguyenLieuVaKetQua()
        {
            var recipe = Crafting.Get("che-qua-tang");
            Assert.IsNotNull(recipe);
            Assert.AreEqual("Quà Tặng Thủ Công (tặng NPC)", recipe!.Name);
            Assert.AreEqual(2, recipe.Ingredients.Count);
            Assert.AreEqual(2, recipe.Ingredients[MaterialIds.LaChuoi]);
            Assert.AreEqual(1, recipe.Ingredients[MaterialIds.VaiVun]);
            Assert.AreEqual("item:qua-tang", recipe.ResultId);
            Assert.AreEqual("Quà Tặng Thủ Công", recipe.ResultName);
        }

        [Test]
        public void Get_IdLa_TraNull()
        {
            Assert.IsNull(Crafting.Get("khong-ton-tai"));
            Assert.IsNull(Crafting.Get(""));
        }

        // --- CanCraft: đủ/thiếu từng nguyên liệu, thiếu 1 loại -> false ---

        [Test]
        public void CanCraft_DuNguyenLieu_TraTrue()
        {
            var recipe = Crafting.Get("che-xe-day")!;
            var duVua = new Dictionary<string, int>
            {
                [MaterialIds.KhungSat] = 1, [MaterialIds.BanhXe] = 2, [MaterialIds.VanGo] = 2,
            };
            Assert.IsTrue(Crafting.CanCraft(recipe, duVua), "Đủ đúng số lượng thì chế được");
            var duThua = new Dictionary<string, int>
            {
                [MaterialIds.KhungSat] = 5, [MaterialIds.BanhXe] = 9, [MaterialIds.VanGo] = 4,
                [MaterialIds.SatVun] = 3, // nguyên liệu thừa loại khác không ảnh hưởng
            };
            Assert.IsTrue(Crafting.CanCraft(recipe, duThua), "Thừa nguyên liệu vẫn chế được");
        }

        [Test]
        public void CanCraft_Thieu1Loai_TraFalse()
        {
            var recipe = Crafting.Get("che-xe-day")!;
            // Thiếu hẳn Ván Gỗ (key không có trong túi).
            var thieuVanGo = new Dictionary<string, int>
            {
                [MaterialIds.KhungSat] = 1, [MaterialIds.BanhXe] = 2,
            };
            Assert.IsFalse(Crafting.CanCraft(recipe, thieuVanGo), "Thiếu 1 loại thì không chế được");
            // Thiếu hẳn Khung Sắt.
            var thieuKhungSat = new Dictionary<string, int>
            {
                [MaterialIds.BanhXe] = 2, [MaterialIds.VanGo] = 2,
            };
            Assert.IsFalse(Crafting.CanCraft(recipe, thieuKhungSat));
            // Túi trống.
            Assert.IsFalse(Crafting.CanCraft(recipe, new Dictionary<string, int>()));
        }

        [Test]
        public void CanCraft_ThieuSoLuong1Loai_TraFalse()
        {
            var recipe = Crafting.Get("che-xe-day")!;
            // Có đủ Khung Sắt + Ván Gỗ nhưng Bánh Xe chỉ có 1/2.
            var thieuBanhXe = new Dictionary<string, int>
            {
                [MaterialIds.KhungSat] = 1, [MaterialIds.BanhXe] = 1, [MaterialIds.VanGo] = 2,
            };
            Assert.IsFalse(Crafting.CanCraft(recipe, thieuBanhXe), "Thiếu số lượng 1 loại thì không chế được");
            // Có 0 Bánh Xe (key có, giá trị 0).
            var banhXe0 = new Dictionary<string, int>
            {
                [MaterialIds.KhungSat] = 1, [MaterialIds.BanhXe] = 0, [MaterialIds.VanGo] = 2,
            };
            Assert.IsFalse(Crafting.CanCraft(recipe, banhXe0));
        }

        // --- Craft: trừ đúng số lượng nguyên liệu, trả ResultId; thiếu -> null, không trừ ---

        [Test]
        public void Craft_TruDungSoLuongVaTraResultId()
        {
            var recipe = Crafting.Get("che-xe-day")!;
            var materials = new Dictionary<string, int>
            {
                [MaterialIds.KhungSat] = 3, [MaterialIds.BanhXe] = 5, [MaterialIds.VanGo] = 2,
            };
            Assert.AreEqual("tool:XeDay:1", Crafting.Craft(recipe, materials));
            Assert.AreEqual(2, materials[MaterialIds.KhungSat], "Khung Sắt 3 - 1 = 2");
            Assert.AreEqual(3, materials[MaterialIds.BanhXe], "Bánh Xe 5 - 2 = 3");
            // ĐÃ SỬA 18/11: Ván Gỗ 2 - 2 = 0 thì key bị XÓA khỏi túi, không để lại
            // entry 0 (trước đây test này assert materials[Ván Gỗ] == 0).
            Assert.IsFalse(materials.ContainsKey(MaterialIds.VanGo),
                "Ván Gỗ chế hết thì key bị xóa khỏi túi, không để lại entry 0");
            Assert.AreEqual(2, materials.Count, "Túi chỉ còn Khung Sắt + Bánh Xe");
        }

        [Test]
        public void Craft_CheHet1Loai_XoaKey_NguyenLieuKhacConNguyen()
        {
            // Hồi quy Bug 1: chế hết đúng 1 loại thì chỉ xóa key loại đó, loại khác
            // còn nguyên số lượng (không xóa nhầm, không trừ nhầm).
            var recipe = Crafting.Get("che-xe-day")!;
            var materials = new Dictionary<string, int>
            {
                [MaterialIds.KhungSat] = 1, [MaterialIds.BanhXe] = 5, [MaterialIds.VanGo] = 2,
                [MaterialIds.SatVun] = 3, // nguyên liệu không dùng trong công thức
            };
            Assert.AreEqual("tool:XeDay:1", Crafting.Craft(recipe, materials));
            Assert.IsFalse(materials.ContainsKey(MaterialIds.KhungSat),
                "Khung Sắt 1 - 1 = 0 thì key bị xóa");
            Assert.IsFalse(materials.ContainsKey(MaterialIds.VanGo),
                "Ván Gỗ 2 - 2 = 0 thì key bị xóa");
            Assert.AreEqual(3, materials[MaterialIds.BanhXe], "Bánh Xe 5 - 2 = 3, key còn lại");
            Assert.AreEqual(3, materials[MaterialIds.SatVun],
                "Sắt Vụn không dùng trong công thức thì không đổi");
            Assert.AreEqual(2, materials.Count, "Túi chỉ còn Bánh Xe + Sắt Vụn");
        }

        [Test]
        public void Craft_Che2LanLienTiep_XoaKeyDanVaTraNullKhiHet()
        {
            // Hồi quy Bug 1: chế 2 lần liên tiếp — lần 2 trừ nốt số còn lại về 0 thì
            // xóa key; lần 3 hết nguyên liệu thì trả null, không trừ gì thêm.
            var recipe = Crafting.Get("che-xe-day")!;
            var materials = new Dictionary<string, int>
            {
                [MaterialIds.KhungSat] = 2, [MaterialIds.BanhXe] = 4, [MaterialIds.VanGo] = 4,
            };
            Assert.AreEqual("tool:XeDay:1", Crafting.Craft(recipe, materials));
            Assert.AreEqual(1, materials[MaterialIds.KhungSat]);
            Assert.AreEqual(2, materials[MaterialIds.BanhXe]);
            Assert.AreEqual(2, materials[MaterialIds.VanGo]);

            Assert.AreEqual("tool:XeDay:1", Crafting.Craft(recipe, materials));
            Assert.AreEqual(0, materials.Count,
                "Chế lần 2 trừ hết cả 3 loại về 0 thì túi trống, không còn key 0 nào");
            Assert.IsFalse(materials.ContainsKey(MaterialIds.KhungSat));
            Assert.IsFalse(materials.ContainsKey(MaterialIds.BanhXe));
            Assert.IsFalse(materials.ContainsKey(MaterialIds.VanGo));

            Assert.IsNull(Crafting.Craft(recipe, materials),
                "Hết nguyên liệu thì chế lần 3 trả null");
            Assert.AreEqual(0, materials.Count, "Chế thất bại thì túi vẫn trống");
            Assert.IsFalse(Crafting.CanCraft(recipe, materials),
                "Sau khi key bị xóa thì CanCraft trả false (không còn nguyên liệu)");
        }

        [Test]
        public void Craft_ThieuNguyenLieu_TraNullVaKhongTru()
        {
            var recipe = Crafting.Get("che-den-soi")!; // cần Sắt Vụn 2 + Chai Nhựa 2
            var materials = new Dictionary<string, int>
            {
                [MaterialIds.SatVun] = 2, [MaterialIds.ChaiNhua] = 1, // thiếu 1 Chai Nhựa
            };
            Assert.IsNull(Crafting.Craft(recipe, materials), "Thiếu nguyên liệu thì chế trả null");
            Assert.AreEqual(2, materials[MaterialIds.SatVun], "Chế thất bại thì không trừ Sắt Vụn");
            Assert.AreEqual(1, materials[MaterialIds.ChaiNhua], "Chế thất bại thì không trừ Chai Nhựa");
        }

        [Test]
        public void Craft_CheQuaTang_TraItemId()
        {
            var recipe = Crafting.Get("che-qua-tang")!;
            var materials = new Dictionary<string, int>
            {
                [MaterialIds.LaChuoi] = 2, [MaterialIds.VaiVun] = 1,
            };
            Assert.AreEqual("item:qua-tang", Crafting.Craft(recipe, materials));
            // ĐÃ SỬA 18/11: chế hết cả 2 loại thì cả 2 key đều bị xóa, túi trống
            // (trước đây test này assert materials[...] == 0 cho cả 2 loại).
            Assert.IsFalse(materials.ContainsKey(MaterialIds.LaChuoi),
                "Lá Chuối chế hết thì key bị xóa khỏi túi");
            Assert.IsFalse(materials.ContainsKey(MaterialIds.VaiVun),
                "Vải Vụn chế hết thì key bị xóa khỏi túi");
            Assert.AreEqual(0, materials.Count, "Chế hết cả 2 loại thì túi trống");
        }

        // --- MissingIngredients: trả đúng số còn thiếu từng loại, đủ thì rỗng ---

        [Test]
        public void MissingIngredients_TraDungSoThieuTungLoai()
        {
            var recipe = Crafting.Get("che-xe-day")!; // cần Khung Sắt 1, Bánh Xe 2, Ván Gỗ 2
            var materials = new Dictionary<string, int>
            {
                [MaterialIds.BanhXe] = 1, // có 1/2 Bánh Xe; Khung Sắt + Ván Gỗ không có
            };
            var missing = Crafting.MissingIngredients(recipe, materials);
            Assert.AreEqual(3, missing.Count, "Thiếu cả 3 loại");
            Assert.AreEqual(1, missing[MaterialIds.KhungSat], "Khung Sắt thiếu 1 - 0 = 1");
            Assert.AreEqual(1, missing[MaterialIds.BanhXe], "Bánh Xe thiếu 2 - 1 = 1");
            Assert.AreEqual(2, missing[MaterialIds.VanGo], "Ván Gỗ thiếu 2 - 0 = 2");
        }

        [Test]
        public void MissingIngredients_DuNguyenLieu_TraRong()
        {
            var recipe = Crafting.Get("che-qua-tang")!; // cần Lá Chuối 2 + Vải Vụn 1
            var duVua = new Dictionary<string, int>
            {
                [MaterialIds.LaChuoi] = 2, [MaterialIds.VaiVun] = 1,
            };
            Assert.AreEqual(0, Crafting.MissingIngredients(recipe, duVua).Count, "Đủ thì không thiếu gì");
            var duThua = new Dictionary<string, int>
            {
                [MaterialIds.LaChuoi] = 9, [MaterialIds.VaiVun] = 4,
            };
            Assert.AreEqual(0, Crafting.MissingIngredients(recipe, duThua).Count, "Thừa thì cũng không thiếu gì");
        }

        [Test]
        public void MissingIngredients_Thieu1Loai_ChiTraLoaiDo()
        {
            var recipe = Crafting.Get("che-den-soi")!; // cần Sắt Vụn 2 + Chai Nhựa 2
            var materials = new Dictionary<string, int>
            {
                [MaterialIds.SatVun] = 2, [MaterialIds.ChaiNhua] = 0,
            };
            var missing = Crafting.MissingIngredients(recipe, materials);
            Assert.AreEqual(1, missing.Count, "Chỉ thiếu Chai Nhựa");
            Assert.AreEqual(2, missing[MaterialIds.ChaiNhua], "Chai Nhựa thiếu 2 - 0 = 2");
            Assert.IsFalse(missing.ContainsKey(MaterialIds.SatVun), "Sắt Vụn đủ thì không có trong danh sách thiếu");
        }
    }
}
