/*:
 * @plugindesc Phố Xô Bồ — Chế tạo kiểu Treasure of Nadia: công thức là cổng tiến trình, 4 công cụ nâng cấp đổi hành vi thật.
 * @author Muse Center
 *
 * @help
 * Port trung thực Crafting.cs (src/client/Assets/Scripts/Crafting.cs).
 *
 * - 3 công thức slice (PROVISIONAL, chưa chốt GDD): Xe Đẩy Hàng =
 *   Khung Sắt 1 + Bánh Xe 2 + Ván Gỗ 2 -> "tool:XeDay:1"; Đèn Soi =
 *   Sắt Vụn 2 + Chai Nhựa 2 -> "tool:DenSoi:1"; Quà Tặng Thủ Công =
 *   Lá Chuối 2 + Vải Vụn 1 -> "item:qua-tang". Số lấy từ Crafting.cs,
 *   KHÔNG lấy số web cũ (xem "Lệch đã phát hiện" dưới).
 * - 4 công cụ × 3 bậc, mỗi combo có mô tả hành vi riêng (không chỉ
 *   +số): Xe Đẩy / Đèn Soi / Sổ Tay / Xẻng — ToolBehaviour().
 * - CanCraft chỉ kiểm tra, không trừ đồ. Craft trừ trực tiếp trên túi
 *   truyền vào; nguyên liệu nào chế hết (về 0) thì XÓA key khỏi túi,
 *   không để lại entry 0 (hành vi đã sửa 18/11, xem test
 *   Craft_TruDungSoLuongVaTraResultId trong CraftingTests.cs).
 * - MissingIngredients trả số còn thiếu từng loại (để Sổ Tay bậc Tốt
 *   gợi ý — xem guideHintForRecipe()).
 * - Nguyên liệu dùng chung id với Exploration.cs / PXB_Hotspot.js
 *   ("khung-sat", "banh-xe", ...) và dùng chung túi
 *   $gameSystem.pxbMaterials (Hotspot nhặt vào, Crafting trừ ra).
 *
 * LƯU Ý — Công thức học qua chơi / NPC dạy (kiến trúc §6): C# chỉ ghi
 * UnlockNote bằng chữ, không có cơ chế "đã học". Plugin thêm
 * learnedRecipes — mặc định chưa học công thức nào; NPC/event gọi
 * learnRecipe(id) để dạy (vd Cô Tư dạy "che-xe-day" sau quest đầu).
 * craftCurrent() chặn khi chưa học (reason "chua-hoc-cong-thuc").
 * Event New Game / PXB_Story sau này quyết mở sẵn công thức nào.
 *
 * Lưu: state sống trong $gameSystem.pxbCrafting nên đi theo save của MV
 * ($gameSystem vốn đã nằm trong save contents của core). Khi core MV
 * chưa có (repo hiện tại), logic thuần vẫn chạy và test được qua
 * module.exports; hàm install() trả false và không giả vờ đã móc save.
 *
 * Dùng trong event (khi có core MV):
 *   PXB_Crafting.learnRecipe("che-xe-day")  // Cô Tư dạy xong quest đầu
 *   PXB_Crafting.hasLearned("che-xe-day")
 *   PXB_Crafting.canCraftCurrent("che-xe-day")
 *   PXB_Crafting.craftCurrent("che-xe-day") // {ok:true, resultId:"tool:XeDay:1", ...}
 *   PXB_Crafting.toolTier("XeDay")          // bậc Xe Đẩy đang có (0 = chưa có)
 *   PXB_Crafting.toolBehaviour("DenSoi", 2) // mô tả hành vi bậc Khá
 *   PXB_Crafting.guideHintForRecipe("che-xe-day") // Sổ Tay gợi ý đồ còn thiếu
 * Plugin command: PXB_Crafting Learn che-xe-day | Craft che-xe-day | Hint che-xe-day
 *
 * LỆCH ĐÃ PHÁT HIỆN (ghi nhận, không tự sửa số — chờ GDD chốt):
 * 1. GDD Mục 6/7 KHÔNG có số chế tạo nào: Mục 6 chỉ nói nghề/công ty,
 *    Mục 7 chỉ nói tài chính/nhà (xem docs/economy.md); chế tạo chỉ
 *    được nhắc là "cổng tiến trình" (GDD dòng 20, Mục 9) + side quest
 *    "chế quà tặng" (dòng 80). Toàn bộ số công thức ở đây lấy từ
 *    Crafting.cs, PROVISIONAL.
 * 2. Web cũ lệch khỏi C# (đã ghi trong src/nadia/README.md): System.js
 *    ghi xe-đẩy 1/1/1, đèn-soi 2/1, túi khởi đầu 1/1/1 không đủ chế;
 *    Crafting.cs ghi xe-đẩy 1/2/2, đèn-soi 2/2. Plugin theo C#.
 * 3. Chỉ có công thức bậc 1. ToolBehaviour có mô tả bậc 2 (Khá) và 3
 *    (Tốt) nhưng CHƯA có công thức nào chế ra tool bậc 2/3 — Crafting.cs
 *    cũng vậy. Công thức nâng cấp công cụ là việc của PXB_Tools.js /
 *    GDD chưa chốt (kiến trúc §6 ghi PXB_Crafting.js + PXB_Tools.js;
 *    file này chỉ port Crafting.cs, chưa có PXB_Tools.js).
 * 4. Crafting.cs gọi chế tạo là "cổng tiến trình" (không chế được thì
 *    không mở khu tiếp) nhưng không có code mở khu nào. Plugin này chỉ
 *    ghi nhận tool đã chế (state.tools); việc mở khu do PXB_Story /
 *    PXB_Hotspot giữ ($gameSystem.pxbUnlockedDistricts) — chưa nối.
 * 5. ResultId "item:qua-tang" chưa có Item tương ứng trong
 *    data/Items.json nên chưa cộng vào $gameParty; plugin chỉ đếm số
 *    quà đã chế trong state.craftedItems (PROVISIONAL — chờ Items.json
 *    có mục quà tặng thì nối $gameParty.gainItem).
 * 6. Hành vi xóa key 0: code/test ghi sửa 18/11; lệnh giao việc ghi
 *    "đợt 19:50" — hiểu là 19:50 ngày 18/11, cùng một hành vi, không
 *    lệch về logic.
 */
(function () {
  "use strict";

  // Lấy hằng từ PXB_Balance (plugin #1, load trước). Khi chạy node test
  // mà chưa load PXB_Balance, dùng fallback — cùng số với Crafting.cs /
  // PXB_Balance.js hiện tại, để logic vẫn test được.
  function balance() {
    if (typeof window !== "undefined" && window.PXB_Balance) {
      return window.PXB_Balance;
    }
    if (typeof global !== "undefined" && global.PXB_Balance) {
      return global.PXB_Balance;
    }
    return null;
  }

  // Công thức slice — đúng Crafting.cs (PROVISIONAL, chưa chốt GDD).
  // id, name, ingredients (MaterialId -> số lượng), resultId, resultName,
  // unlockNote (điều kiện học — chữ mô tả, chưa phải logic quest).
  var FALLBACK_RECIPES = [
    {
      id: "che-xe-day",
      name: "Xe Đẩy Hàng (bậc 1)",
      ingredients: { "khung-sat": 1, "banh-xe": 2, "van-go": 2 },
      resultId: "tool:XeDay:1",
      resultName: "Xe Đẩy Hàng",
      unlockNote: "Cô Tư dạy sau khi làm xong quest đầu tiên ở Xóm Trọ Cũ."
    },
    {
      id: "che-den-soi",
      name: "Đèn Soi (bậc 1)",
      ingredients: { "sat-vun": 2, "chai-nhua": 2 },
      resultId: "tool:DenSoi:1",
      resultName: "Đèn Soi",
      unlockNote: "Anh Hải dạy ở Phố Đi Bộ – Chợ Đêm."
    },
    {
      id: "che-qua-tang",
      name: "Quà Tặng Thủ Công (tặng NPC)",
      ingredients: { "la-chuoi": 2, "vai-vun": 1 },
      resultId: "item:qua-tang",
      resultName: "Quà Tặng Thủ Công",
      unlockNote: "Học từ bạn thân NPC — tặng NPC để tăng thân thiết, mở quest (GDD Mục 8/9)."
    }
  ];

  function fallbackById(id) {
    for (var i = 0; i < FALLBACK_RECIPES.length; i++) {
      if (FALLBACK_RECIPES[i].id === id) return FALLBACK_RECIPES[i];
    }
    return null;
  }

  // Danh mục công thức hiện tại. Số lấy từ PXB_Balance.recipes khi có
  // (hằng số duy nhất, kiến trúc §6.1); resultName/unlockNote lấy từ
  // fallback theo id vì Balance chỉ giữ needs/result/unlock. Chưa có
  // Balance thì dùng thẳng fallback (cùng số Crafting.cs).
  function recipeCatalog() {
    var b = balance();
    if (b && Array.isArray(b.recipes) && b.recipes.length > 0) {
      var list = [];
      var seen = {};
      for (var i = 0; i < b.recipes.length; i++) {
        var r = b.recipes[i];
        var fb = fallbackById(r.id);
        list.push({
          id: r.id,
          name: r.name,
          ingredients: r.needs || (fb && fb.ingredients) || {},
          resultId: r.result,
          resultName: (fb && fb.resultName) || r.name,
          unlockNote: r.unlock || (fb && fb.unlockNote) || ""
        });
        seen[r.id] = true;
      }
      // Công thức fallback nào Balance chưa có thì giữ lại (không mất
      // công thức khi Balance cập nhật chậm hơn Crafting.cs).
      for (var j = 0; j < FALLBACK_RECIPES.length; j++) {
        if (!seen[FALLBACK_RECIPES[j].id]) list.push(FALLBACK_RECIPES[j]);
      }
      return list;
    }
    return FALLBACK_RECIPES.slice();
  }

  function recipeList() {
    return recipeCatalog();
  }

  function getRecipe(recipeId) {
    var list = recipeCatalog();
    for (var i = 0; i < list.length; i++) {
      if (list[i].id === recipeId) return list[i];
    }
    return null;
  }

  // --- Công cụ: 4 tool × 3 tier (đúng enum GameTool / ToolTier C#) ---

  var TOOL_XE_DAY = "XeDay";
  var TOOL_DEN_SOI = "DenSoi";
  var TOOL_SO_TAY = "SoTay";
  var TOOL_XENG = "Xeng";

  var TOOL_IDS = [TOOL_XE_DAY, TOOL_DEN_SOI, TOOL_SO_TAY, TOOL_XENG];

  var TIER_THO = 1;
  var TIER_KHA = 2;
  var TIER_TOT = 3;

  var TIER_NAMES = { 1: "Tho", 2: "Kha", 3: "Tot" };

  function normalizeTier(tier) {
    if (typeof tier === "number") return tier;
    if (typeof tier === "string") {
      var t = tier.charAt(0).toUpperCase() + tier.slice(1).toLowerCase();
      if (t === "Tho") return TIER_THO;
      if (t === "Kha") return TIER_KHA;
      if (t === "Tot") return TIER_TOT;
      var n = parseInt(tier, 10);
      if (!isNaN(n)) return n;
    }
    return 0;
  }

  // Mô tả hành vi đổi theo bậc — đúng Crafting.ToolBehaviour, từng chữ.
  // Bậc/tool lạ thì trả chuỗi mặc định (đúng test ToolBehaviour_BacLa).
  function toolBehaviour(tool, tier) {
    var t = normalizeTier(tier);
    switch (tool + ":" + t) {
      case "XeDay:1":  return "Chở được ít hàng, không đi được đường mưa.";
      case "XeDay:2":  return "Chở được nhiều hàng hơn.";
      case "XeDay:3":  return "Chở nhiều + đi được đường mưa, không bị ướt hàng.";
      case "DenSoi:1": return "Thấy hotspot thường.";
      case "DenSoi:2": return "Thấy hotspot thường + hotspot ẩn gần.";
      case "DenSoi:3": return "Thấy mọi hotspot, kể cả hotspot hiếm chỉ xuất hiện 1 khung/ngày.";
      case "SoTay:1":  return "NPC gợi ý chung chung.";
      case "SoTay:2":  return "NPC gợi ý rõ mục tiêu + khu cần tới.";
      case "SoTay:3":  return "NPC gợi ý rõ mục tiêu + khu + nguyên liệu còn thiếu.";
      case "Xeng:1":   return "Nhặt được nguyên liệu thường.";
      case "Xeng:2":   return "Nhặt nhanh hơn, thỉnh thoảng được thêm 1 nguyên liệu.";
      case "Xeng:3":   return "Nhặt nhanh + có cơ hội nhặt được nguyên liệu hiếm.";
      default:          return "Chưa rõ bậc công cụ.";
    }
  }

  // --- Logic thuần (port trung thực Crafting.cs) ---

  // Nhận recipe object hoặc id ("che-xe-day"); id lạ -> null.
  function resolveRecipe(recipeOrId) {
    if (!recipeOrId) return null;
    if (typeof recipeOrId === "string") return getRecipe(recipeOrId);
    return recipeOrId;
  }

  // Đủ nguyên liệu để chế không? Không trừ đồ ở đây.
  function canCraft(recipeOrId, materials) {
    var recipe = resolveRecipe(recipeOrId);
    if (!recipe) return false;
    var bag = materials || {};
    for (var id in recipe.ingredients) {
      var have = bag[id] || 0;
      if (have < recipe.ingredients[id]) return false;
    }
    return true;
  }

  // Chế 1 món: trừ nguyên liệu TRỰC TIẾP trên túi truyền vào, trả về
  // ResultId. Trả null nếu công thức không có hoặc thiếu nguyên liệu
  // (khi đó không trừ gì). Nguyên liệu nào chế hết (về 0) thì XÓA key
  // khỏi túi, không để lại entry 0 — sửa 18/11 (đợt 19:50).
  function craft(recipeOrId, materials) {
    var recipe = resolveRecipe(recipeOrId);
    if (!recipe || !materials) return null;
    if (!canCraft(recipe, materials)) return null;
    for (var id in recipe.ingredients) {
      var conLai = (materials[id] || 0) - recipe.ingredients[id];
      // Chế hết loại này thì xóa key khỏi túi, không để lại entry 0.
      if (conLai <= 0) delete materials[id];
      else materials[id] = conLai;
    }
    return recipe.resultId;
  }

  // Nguyên liệu còn thiếu để chế 1 công thức (để Sổ Tay gợi ý).
  // Trả object { materialId: số còn thiếu }; đủ thì object rỗng.
  function missingIngredients(recipeOrId, materials) {
    var recipe = resolveRecipe(recipeOrId);
    var missing = {};
    if (!recipe) return missing;
    var bag = materials || {};
    for (var id in recipe.ingredients) {
      var have = bag[id] || 0;
      if (have < recipe.ingredients[id]) {
        missing[id] = recipe.ingredients[id] - have;
      }
    }
    return missing;
  }

  // --- State (sống trong $gameSystem.pxbCrafting để vào save) ---
  // Túi nguyên liệu KHÔNG ở đây — dùng chung $gameSystem.pxbMaterials
  // với PXB_Hotspot.js (Hotspot nhặt vào, Crafting trừ ra).

  function defaultState() {
    return {
      tools: {},         // bậc công cụ đang có, theo tên tool: {"XeDay": 1}
      learnedRecipes: {}, // công thức đã học, theo id -> true
      craftedItems: {},  // số vật phẩm đã chế, theo id: {"qua-tang": 2}
      lastCraft: null    // {recipeId, resultId} — lần chế gần nhất
    };
  }

  // Dữ liệu dự phòng khi chưa có core MV (logic thuần vẫn test được).
  var fallbackState = defaultState();

  function state() {
    if (typeof $gameSystem !== "undefined" && $gameSystem) {
      if (!$gameSystem.pxbCrafting) {
        $gameSystem.pxbCrafting = defaultState();
      }
      return $gameSystem.pxbCrafting;
    }
    return fallbackState;
  }

  // Túi nguyên liệu dùng chung với PXB_Hotspot ($gameSystem.pxbMaterials).
  var fallbackMaterials = {};

  function materialsBag() {
    if (typeof $gameSystem !== "undefined" && $gameSystem) {
      if (!$gameSystem.pxbMaterials) {
        $gameSystem.pxbMaterials = {};
      }
      return $gameSystem.pxbMaterials;
    }
    return fallbackMaterials;
  }

  // Khởi tạo pxbCrafting trong $gameSystem (gọi khi new game).
  // Trả false khi chưa có $gameSystem — không giả vờ đã lưu được.
  function initInGameSystem() {
    if (typeof $gameSystem === "undefined" || !$gameSystem) return false;
    if (!$gameSystem.pxbCrafting) {
      $gameSystem.pxbCrafting = defaultState();
    }
    return true;
  }

  // --- Học công thức (NPC dạy / làm quest) ---

  function learnRecipe(recipeId) {
    if (!getRecipe(recipeId)) return false;
    state().learnedRecipes[recipeId] = true;
    return true;
  }

  function hasLearned(recipeId) {
    return !!state().learnedRecipes[recipeId];
  }

  function knownRecipes() {
    var list = recipeCatalog();
    var known = [];
    for (var i = 0; i < list.length; i++) {
      if (hasLearned(list[i].id)) known.push(list[i]);
    }
    return known;
  }

  // --- Công cụ đang có ---

  // Bậc công cụ đang có (0 = chưa chế được tool này).
  function toolTier(tool) {
    return state().tools[tool] || 0;
  }

  function hasTool(tool) {
    return toolTier(tool) > 0;
  }

  // Mô tả hành vi của bậc công cụ đang có; chưa có tool thì trả chuỗi
  // mặc định (cùng ToolBehaviour với bậc lạ).
  function toolBehaviourCurrent(tool) {
    return toolBehaviour(tool, toolTier(tool));
  }

  // Ghi nhận kết quả chế: "tool:XeDay:1" -> tools.XeDay = 1 (chỉ tăng,
  // không giảm khi chế lại bậc thấp); "item:qua-tang" -> đếm quà đã chế.
  // Trả {kind:"tool"|"item", tool, tier, itemId} hoặc null khi parse lỗi.
  function applyResult(resultId) {
    if (typeof resultId !== "string") return null;
    var parts = resultId.split(":");
    if (parts[0] === "tool" && parts.length === 3) {
      var tool = parts[1];
      var tier = parseInt(parts[2], 10);
      if (TOOL_IDS.indexOf(tool) < 0 || isNaN(tier) ||
          tier < TIER_THO || tier > TIER_TOT) {
        return null;
      }
      var st = state();
      if ((st.tools[tool] || 0) < tier) st.tools[tool] = tier;
      return { kind: "tool", tool: tool, tier: tier, itemId: null };
    }
    if (parts[0] === "item" && parts.length === 2) {
      var itemId = parts[1];
      var s = state();
      s.craftedItems[itemId] = (s.craftedItems[itemId] || 0) + 1;
      // LƯU Ý (lệch #5 trong @help): chưa cộng vào $gameParty vì
      // data/Items.json chưa có mục quà tặng — chỉ đếm trong state.
      return { kind: "item", tool: null, tier: 0, itemId: itemId };
    }
    return null;
  }

  // --- Chế từ túi chung (đường dùng trong event) ---

  function canCraftCurrent(recipeId) {
    var recipe = getRecipe(recipeId);
    if (!recipe) return false;
    return canCraft(recipe, materialsBag());
  }

  // Chế 1 món từ túi nguyên liệu chung. Trả:
  //   {ok:true, recipeId, resultId, resultName, applied, missing:{}}
  //   {ok:false, reason:"khong-co-cong-thuc"}
  //   {ok:false, reason:"chua-hoc-cong-thuc", unlockNote}
  //   {ok:false, reason:"thieu-nguyen-lieu", missing:{...}}
  // applied: kết quả applyResult() (tool đã lên bậc / quà đã đếm).
  function craftCurrent(recipeId) {
    var recipe = getRecipe(recipeId);
    if (!recipe) return { ok: false, reason: "khong-co-cong-thuc" };
    if (!hasLearned(recipeId)) {
      return {
        ok: false, reason: "chua-hoc-cong-thuc",
        unlockNote: recipe.unlockNote
      };
    }
    var bag = materialsBag();
    if (!canCraft(recipe, bag)) {
      return {
        ok: false, reason: "thieu-nguyen-lieu",
        missing: missingIngredients(recipe, bag)
      };
    }
    var resultId = craft(recipe, bag);
    var applied = applyResult(resultId);
    state().lastCraft = { recipeId: recipeId, resultId: resultId };
    return {
      ok: true, recipeId: recipeId, resultId: resultId,
      resultName: recipe.resultName, applied: applied, missing: {}
    };
  }

  // Gợi ý Sổ Tay cho 1 công thức: liệt kê nguyên liệu còn thiếu.
  // Dùng khi Sổ Tay bậc Tốt (ToolBehaviour SoTay:3: gợi ý cả nguyên
  // liệu còn thiếu); bậc thấp hơn thì event tự rút gọn câu trả lời.
  // Trả chuỗi tiếng Việt; công thức lạ -> chuỗi mặc định.
  function guideHintForRecipe(recipeId) {
    var recipe = getRecipe(recipeId);
    if (!recipe) return "Chưa rõ bậc công cụ.";
    var missing = missingIngredients(recipe, materialsBag());
    var keys = Object.keys(missing);
    if (keys.length === 0) {
      return "Đủ đồ chế " + recipe.resultName + " rồi — ghé Góc Chế Tạo làm ngay đi.";
    }
    var parts = [];
    for (var i = 0; i < keys.length; i++) {
      parts.push(keys[i] + " còn thiếu " + missing[keys[i]]);
    }
    return "Để chế " + recipe.resultName + " còn thiếu: " + parts.join(", ") + ".";
  }

  // --- Móc vào core MV ---

  // Plugin command cho CommonEvent / event thường:
  //   PXB_Crafting Learn che-xe-day   — học công thức (NPC dạy)
  //   PXB_Crafting Craft che-xe-day   — chế từ túi chung (đã học + đủ đồ)
  //   PXB_Crafting Hint che-xe-day    — gợi ý Sổ Tay (trả về, event hiển thị)
  function install() {
    if (typeof DataManager !== "undefined") {
      if (typeof DataManager.createGameObjects === "function") {
        var _createGameObjects = DataManager.createGameObjects;
        DataManager.createGameObjects = function () {
          _createGameObjects.call(this);
          initInGameSystem();
        };
      }
      if (typeof DataManager.extractSaveContents === "function") {
        var _extractSaveContents = DataManager.extractSaveContents;
        DataManager.extractSaveContents = function (contents) {
          _extractSaveContents.call(this, contents);
          if (typeof $gameSystem !== "undefined" && $gameSystem &&
              $gameSystem.pxbCrafting) {
            // Điền lại field thiếu khi load save cũ / save sửa tay.
            var d = defaultState();
            var s = $gameSystem.pxbCrafting;
            for (var k in d) {
              if (typeof s[k] === "undefined") s[k] = d[k];
            }
          }
        };
      }
    }
    if (typeof Game_Interpreter !== "undefined" &&
        typeof Game_Interpreter.prototype.pluginCommand === "function") {
      var _pluginCommand = Game_Interpreter.prototype.pluginCommand;
      Game_Interpreter.prototype.pluginCommand = function (command, args) {
        _pluginCommand.call(this, command, args);
        if (command === "PXB_Crafting") {
          if (args[0] === "Learn") {
            learnRecipe(args[1]);
          } else if (args[0] === "Craft") {
            craftCurrent(args[1]);
          } else if (args[0] === "Hint") {
            guideHintForRecipe(args[1]);
          }
        }
      };
      return true;
    }
    return typeof DataManager !== "undefined";
  }

  // Áp dụng hook ngay khi file load (quy ước MV: code plugin chạy lúc
  // load). Không có core thì install() trả false và không làm gì.
  install();

  var PXB_Crafting = {
    TOOL_XE_DAY: TOOL_XE_DAY,
    TOOL_DEN_SOI: TOOL_DEN_SOI,
    TOOL_SO_TAY: TOOL_SO_TAY,
    TOOL_XENG: TOOL_XENG,
    TOOL_IDS: TOOL_IDS,
    TIER_THO: TIER_THO,
    TIER_KHA: TIER_KHA,
    TIER_TOT: TIER_TOT,
    TIER_NAMES: TIER_NAMES,
    recipeList: recipeList,
    getRecipe: getRecipe,
    toolBehaviour: toolBehaviour,
    canCraft: canCraft,
    craft: craft,
    missingIngredients: missingIngredients,
    learnRecipe: learnRecipe,
    hasLearned: hasLearned,
    knownRecipes: knownRecipes,
    toolTier: toolTier,
    hasTool: hasTool,
    toolBehaviourCurrent: toolBehaviourCurrent,
    applyResult: applyResult,
    materialsBag: materialsBag,
    canCraftCurrent: canCraftCurrent,
    craftCurrent: craftCurrent,
    guideHintForRecipe: guideHintForRecipe,
    initInGameSystem: initInGameSystem,
    install: install
  };

  if (typeof module !== "undefined" && module.exports) {
    module.exports = PXB_Crafting;
  } else if (typeof window !== "undefined") {
    window.PXB_Crafting = PXB_Crafting;
  }
})();
