/*:
 * @plugindesc Phố Xô Bồ — 4 công cụ × 3 bậc kiểu Treasure of Nadia: nâng cấp đổi hành vi thật (Xe Đẩy đi được đường mưa, Đèn Soi thấy hotspot ẩn/hiếm, Sổ Tay gợi ý rõ, Xẻng nhặt nhanh + thêm đồ/hiếm).
 * @author Muse Center
 *
 * @help
 * Bạn đồng hành của PXB_Crafting.js (kiến trúc §6 #6:
 * PXB_Crafting.js + PXB_Tools.js). Crafting giữ công thức + chế tạo;
 * file này giữ BẬC CÔNG CỤ và HÀNH VI ĐỔI THEO BẬC.
 *
 * - 4 công cụ × 3 bậc (đúng enum GameTool / ToolTier trong
 *   Crafting.cs): Xe Đẩy / Đèn Soi / Sổ Tay / Xẻng (Thợ 1 / Khá 2 /
 *   Tốt 3). Mô tả hành vi từng combo lấy từng chữ từ
 *   Crafting.ToolBehaviour — xem toolBehaviour().
 * - Hành vi ĐỔI THẬT, không chỉ +số (kiểu Nadia):
 *   Xe Đẩy: sức chở tăng theo bậc (PROVISIONAL — xem dưới), bậc 3 đi
 *   được đường mưa, không ướt hàng — cartCanTravel().
 *   Đèn Soi: bậc 1 thấy hotspot thường; bậc 2 thêm hotspot ẨN GẦN;
 *   bậc 3 thấy MỌI hotspot, kể cả hotspot hiếm chỉ xuất hiện 1
 *   khung/ngày — seesHotspot().
 *   Sổ Tay: bậc 1 NPC gợi ý chung chung; bậc 2 gợi ý rõ mục tiêu +
 *   khu cần tới; bậc 3 thêm nguyên liệu còn thiếu — guideHint().
 *   Xẻng/Cuốc: bậc 1 nhặt thường; bậc 2 nhặt nhanh hơn, thỉnh
 *   thoảng +1 nguyên liệu; bậc 3 nhặt nhanh + có cơ hội nhặt được
 *   nguyên liệu hiếm — collectYield() / collect().
 * - NÂNG CẤP bậc 2/3: Crafting.cs KHÔNG có công thức nâng cấp nào
 *   (chỉ có 2 công thức bậc 1: che-xe-day, che-den-soi; Sổ Tay và
 *   Xẻng không có công thức bậc 1 nào). Toàn bộ chi phí nâng cấp
 *   trong file này là PROVISIONAL, suy từ công thức bậc 1 theo quy
 *   tắc: chi phí nâng lên bậc N = chi phí bậc 1 × N (bậc 2 = ×2,
 *   bậc 3 = ×3, cùng loại nguyên liệu) — xem UPGRADE_RECIPES.
 *   Khi GDD chốt bảng nâng cấp thì sửa đúng bảng đó, không sửa code.
 * - Sổ Tay / Xẻng bậc 1 cũng chưa có công thức trong Crafting.cs nên
 *   file này thêm công thức nhận bậc 1 PROVISIONAL cho 2 công cụ đó
 *   (ACQUIRE_RECIPES, suy theo kiểu Nadia: Xẻng = đầu sắt + cán gỗ
 *   như Basic Shovel; Sổ Tay = lá chuối làm trang + vải vụn làm bìa)
 *   qua acquire(). Xe Đẩy / Đèn Soi bậc 1 KHÔNG chế ở đây — phải chế
 *   qua PXB_Crafting (che-xe-day / che-den-soi, đã học qua NPC).
 * - LƯU TRỮ — 1 NGUỒN SỰ THẬT: bậc công cụ sống trong
 *   $gameSystem.pxbTools.tools (đi theo save MV, như pxbCrafting).
 *   PXB_Crafting vẫn giữ bản sao trong $gameSystem.pxbCrafting.tools
 *   (craftCurrent ghi vào đó). File này ĐỒNG BỘ 2 chiều: đọc bậc thì
 *   lấy max(pxbTools, pxbCrafting) qua syncFromCrafting(); nâng cấp /
 *   nhận công cụ ở đây thì ghi đè (mirror) sang pxbCrafting.tools để
 *   2 bên không lệch. Không bao giờ để 2 số bậc khác nhau tồn tại.
 * - Túi nguyên liệu dùng chung $gameSystem.pxbMaterials với
 *   PXB_Hotspot / PXB_Crafting (Hotspot nhặt vào, Crafting/Tools trừ
 *   ra; nguyên liệu nào trừ hết về 0 thì XÓA key khỏi túi, không để
 *   lại entry 0 — cùng quy ước Crafting.cs sửa 18/11).
 *
 * PROVISIONAL — số chưa chốt, đổi thì sửa ở đây + Crafting.cs +
 * docs/gdd.md Mục 6 cùng lúc (mọi số đều ghi rõ PROVISIONAL):
 *  1. Chi phí nâng cấp bậc 2/3 cả 4 công cụ (quy tắc ×N ở trên).
 *  2. Chi phí nhận bậc 1 Sổ Tay (lá chuối 2 + vải vụn 1) và Xẻng
 *     (sắt vụn 2 + ván gỗ 1) — Crafting.cs không có công thức nào.
 *  3. Sức chở Xe Đẩy: bậc 1 = 5, bậc 2 = 10, bậc 3 = 20 đơn vị hàng
 *     mỗi chuyến — Crafting.cs / Jobs.cs không có số sức chở nào.
 *  4. Xẻng: hệ số thời gian nhặt 1,0 / 0,75 / 0,5; bậc 2 thỉnh
 *     thoảng +1 với tỉ lệ 25%; bậc 3 cơ hội nhặt hiếm 10% — C# chỉ
 *     ghi chữ "nhanh hơn / thỉnh thoảng / có cơ hội", không có số.
 *  5. Nguyên liệu hiếm "da-quy" (id PROVISIONAL): Exploration.cs
 *     không có nguyên liệu hiếm / hotspot hiếm nào — id này chỉ là
 *     chỗ giữ, đổi khi GDD chốt bảng nguyên liệu hiếm.
 *  6. Đèn Soi bậc 2 "hotspot ẩn GẦN": "gần" = hotspot.near === true
 *     (hoặc cùng khu với người chơi khi event truyền districtId) —
 *     C# không định nghĩa khoảng cách gần/xa.
 *  7. Thời tiết mưa: chưa có hệ thời tiết nào — cartCanTravel nhận
 *     cờ isRaining do event / plugin thời tiết sau này truyền vào
 *     (đọc $gameSystem.pxbWeather.isRaining khi có, PROVISIONAL).
 *
 * MÓC VÀO PLUGIN KHÁC (chỉ gọi, KHÔNG sửa file khác):
 *  - PXB_Crafting: đọc toolTier / guideHintForRecipe / recipeList khi
 *    đã load (đồng bộ bậc, gợi ý Sổ Tay bậc 3); upgrade() trừ túi
 *    chung như Crafting.craft().
 *  - PXB_Hotspot: seesHotspot() quyết hotspot ẨN nào Đèn Soi thấy
 *    được (hotspot thường vẫn thấy bằng mắt thường, không cần Đèn
 *    Soi); collect() cộng thêm Xẻng vào lượng nhặt của hotspot.
 *  - PXB_Jobs: carryCheck() / cartCanTravel() để event làm ca kiểm
 *    tra Xe Đẩy chở nổi đơn hàng không và có đi được đường mưa không
 *    trước khi cho làm ca shipper / bán rong.
 *
 * Lưu: state sống trong $gameSystem.pxbTools nên đi theo save của MV
 * ($gameSystem vốn đã nằm trong save contents của core). Khi core MV
 * chưa có (repo hiện tại), logic thuần vẫn chạy và test được qua
 * module.exports; hàm install() trả false và không giả vờ đã móc save.
 *
 * Dùng trong event (khi có core MV):
 *   PXB_Tools.toolTier("XeDay")              // bậc Xe Đẩy đang có (0 = chưa có)
 *   PXB_Tools.toolBehaviour("DenSoi")        // mô tả bậc Đèn Soi đang có
 *   PXB_Tools.toolBehaviour("DenSoi", 3)     // mô tả bậc Tốt
 *   PXB_Tools.canUpgrade("XeDay")            // {ok, reason, cost, nextTier, missing}
 *   PXB_Tools.upgrade("XeDay")               // nâng 1 bậc, trừ nguyên liệu túi chung
 *   PXB_Tools.acquire("Xeng")                // nhận Xẻng bậc 1 (PROVISIONAL, xem trên)
 *   PXB_Tools.seesHotspot({hidden:true, near:true, rarity:"thuong"})
 *   PXB_Tools.cartCanTravel(true)            // trời mưa: chỉ Xe Đẩy bậc 3 đi được
 *   PXB_Tools.carryCheck(12)                 // chở nổi 12 đơn vị hàng không
 *   PXB_Tools.guideHint("làm xe đẩy", 2, "che-xe-day")
 *   PXB_Tools.collect("la-chuoi", 2)         // nhặt + bonus Xẻng, cộng vào túi
 * Plugin command: PXB_Tools Upgrade XeDay | Tier XeDay | Acquire Xeng |
 *   Hint che-xe-day | Collect la-chuoi 2 | Sync
 */
(function () {
  "use strict";

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

  // Tên hiển thị tiếng Việt của từng công cụ (chỉ để event / UI dùng).
  var TOOL_NAMES = {
    XeDay: "Xe Đẩy",
    DenSoi: "Đèn Soi",
    SoTay: "Sổ Tay",
    Xeng: "Xẻng/Cuốc"
  };

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

  function isValidTool(tool) {
    return TOOL_IDS.indexOf(tool) >= 0;
  }

  // Mô tả hành vi đổi theo bậc — đúng Crafting.ToolBehaviour, từng chữ.
  // Gọi 1 đối số toolBehaviour(tool) = mô tả bậc đang có; gọi 2 đối số
  // toolBehaviour(tool, tier) = mô tả bậc đó. Bậc/tool lạ thì trả chuỗi
  // mặc định (đúng test ToolBehaviour_BacLa trong CraftingTests.cs).
  function toolBehaviour(tool, tier) {
    var t = (typeof tier === "undefined" || tier === null)
      ? toolTier(tool) : normalizeTier(tier);
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

  // --- Chi phí nâng cấp / nhận bậc 1 (PROVISIONAL — xem @help) ---
  //
  // QUY TẮC SUY RA (PROVISIONAL, chưa chốt GDD): chi phí nâng lên bậc N
  // = chi phí bậc 1 × N (bậc 2 = ×2, bậc 3 = ×3, cùng loại nguyên liệu).
  // Cơ số bậc 1: Xe Đẩy / Đèn Soi lấy đúng công thức bậc 1 trong
  // Crafting.cs (che-xe-day / che-den-soi); Sổ Tay / Xẻng không có công
  // thức bậc 1 trong Crafting.cs nên cơ số cũng là PROVISIONAL (xem
  // ACQUIRE_RECIPES). Khi GDD chốt bảng nâng cấp thì sửa đúng 2 bảng
  // dưới đây, không sửa code nâng cấp.

  // id công thức nâng cấp (đặt tên để Sổ Tay gợi ý được): "nang-cap-<tool>-<tier>".
  // cost: { materialId: số lượng } — id nguyên liệu dùng chung
  // MaterialIds trong Exploration.cs (la-chuoi, van-go, khung-sat,
  // banh-xe, vai-vun, chai-nhua, sat-vun).
  var UPGRADE_RECIPES = [
    // Xe Đẩy: cơ số khung-sat 1 + banh-xe 2 + van-go 2 (che-xe-day, C#).
    { id: "nang-cap-xe-day-2", tool: TOOL_XE_DAY, toTier: TIER_KHA,
      cost: { "khung-sat": 2, "banh-xe": 4, "van-go": 4 } },
    { id: "nang-cap-xe-day-3", tool: TOOL_XE_DAY, toTier: TIER_TOT,
      cost: { "khung-sat": 3, "banh-xe": 6, "van-go": 6 } },
    // Đèn Soi: cơ số sat-vun 2 + chai-nhua 2 (che-den-soi, C#).
    { id: "nang-cap-den-soi-2", tool: TOOL_DEN_SOI, toTier: TIER_KHA,
      cost: { "sat-vun": 4, "chai-nhua": 4 } },
    { id: "nang-cap-den-soi-3", tool: TOOL_DEN_SOI, toTier: TIER_TOT,
      cost: { "sat-vun": 6, "chai-nhua": 6 } },
    // Sổ Tay: cơ số PROVISIONAL la-chuoi 2 + vai-vun 1 (xem ACQUIRE_RECIPES).
    { id: "nang-cap-so-tay-2", tool: TOOL_SO_TAY, toTier: TIER_KHA,
      cost: { "la-chuoi": 4, "vai-vun": 2 } },
    { id: "nang-cap-so-tay-3", tool: TOOL_SO_TAY, toTier: TIER_TOT,
      cost: { "la-chuoi": 6, "vai-vun": 3 } },
    // Xẻng: cơ số PROVISIONAL sat-vun 2 + van-go 1 (xem ACQUIRE_RECIPES).
    { id: "nang-cap-xeng-2", tool: TOOL_XENG, toTier: TIER_KHA,
      cost: { "sat-vun": 4, "van-go": 2 } },
    { id: "nang-cap-xeng-3", tool: TOOL_XENG, toTier: TIER_TOT,
      cost: { "sat-vun": 6, "van-go": 3 } }
  ];

  // Công thức nhận bậc 1 cho 2 công cụ KHÔNG có công thức bậc 1 trong
  // Crafting.cs — PROVISIONAL, suy theo kiểu Nadia:
  //  - Sổ Tay: lá chuối làm trang (la-chuoi 2) + vải vụn làm bìa (vai-vun 1).
  //  - Xẻng: đầu sắt (sat-vun 2) + cán gỗ (van-go 1), như Basic Shovel
  //    của Nadia (Shovel Head + Shaft + Iron Ore) đổi sang đồ chợ Việt.
  // Xe Đẩy / Đèn Soi KHÔNG có mục ở đây — bậc 1 của 2 công cụ đó phải
  // chế qua PXB_Crafting (che-xe-day / che-den-soi).
  var ACQUIRE_RECIPES = [
    { id: "che-so-tay", tool: TOOL_SO_TAY, toTier: TIER_THO,
      cost: { "la-chuoi": 2, "vai-vun": 1 } },
    { id: "che-xeng", tool: TOOL_XENG, toTier: TIER_THO,
      cost: { "sat-vun": 2, "van-go": 1 } }
  ];

  function upgradeRecipeFor(tool, toTier) {
    for (var i = 0; i < UPGRADE_RECIPES.length; i++) {
      if (UPGRADE_RECIPES[i].tool === tool &&
          UPGRADE_RECIPES[i].toTier === toTier) {
        return UPGRADE_RECIPES[i];
      }
    }
    return null;
  }

  function acquireRecipeFor(tool) {
    for (var i = 0; i < ACQUIRE_RECIPES.length; i++) {
      if (ACQUIRE_RECIPES[i].tool === tool) return ACQUIRE_RECIPES[i];
    }
    return null;
  }

  // Tìm công thức (nâng cấp hoặc nhận bậc 1) theo id — để Sổ Tay gợi ý.
  function recipeById(recipeId) {
    var i;
    for (i = 0; i < UPGRADE_RECIPES.length; i++) {
      if (UPGRADE_RECIPES[i].id === recipeId) return UPGRADE_RECIPES[i];
    }
    for (i = 0; i < ACQUIRE_RECIPES.length; i++) {
      if (ACQUIRE_RECIPES[i].id === recipeId) return ACQUIRE_RECIPES[i];
    }
    return null;
  }

  // --- Hằng hành vi (PROVISIONAL — xem @help mục 3/4/5/6/7) ---

  // Sức chở Xe Đẩy theo bậc: số đơn vị hàng chở được mỗi chuyến.
  // PROVISIONAL — Crafting.cs / Jobs.cs không có số sức chở nào.
  var CARRY_CAPACITY = { 1: 5, 2: 10, 3: 20 };

  // Xẻng: hệ số thời gian nhặt (1,0 = tốc độ thường; càng nhỏ càng nhanh).
  // PROVISIONAL — C# chỉ ghi "nhặt nhanh hơn", không có số.
  var COLLECT_TIME_FACTOR = { 1: 1.0, 2: 0.75, 3: 0.5 };

  // Xẻng bậc 2: tỉ lệ thỉnh thoảng được +1 nguyên liệu.
  // PROVISIONAL — C# chỉ ghi "thỉnh thoảng", không có số.
  var COLLECT_BONUS_CHANCE = 0.25;

  // Xẻng bậc 3: tỉ lệ nhặt được nguyên liệu hiếm (kèm +1 như bậc 2).
  // PROVISIONAL — C# chỉ ghi "có cơ hội", không có số.
  var RARE_FIND_CHANCE = 0.10;

  // Nguyên liệu hiếm Xẻng bậc 3 có thể nhặt được — id PROVISIONAL
  // (Exploration.cs không có nguyên liệu hiếm nào; đổi khi GDD chốt).
  var RARE_MATERIAL_ID = "da-quy";

  // --- State (sống trong $gameSystem.pxbTools để vào save) ---

  function defaultState() {
    return {
      tools: {},        // bậc công cụ đang có, theo tên tool: {"XeDay": 1}
      lastUpgrade: null // {tool, fromTier, toTier} — lần nâng cấp gần nhất
    };
  }

  // Dữ liệu dự phòng khi chưa có core MV (logic thuần vẫn test được).
  var fallbackState = defaultState();

  function state() {
    if (typeof $gameSystem !== "undefined" && $gameSystem) {
      if (!$gameSystem.pxbTools) {
        $gameSystem.pxbTools = defaultState();
      }
      return $gameSystem.pxbTools;
    }
    return fallbackState;
  }

  // Túi nguyên liệu dùng chung với PXB_Hotspot / PXB_Crafting
  // ($gameSystem.pxbMaterials).
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

  // Khởi tạo pxbTools trong $gameSystem (gọi khi new game).
  // Trả false khi chưa có $gameSystem — không giả vờ đã lưu được.
  function initInGameSystem() {
    if (typeof $gameSystem === "undefined" || !$gameSystem) return false;
    if (!$gameSystem.pxbTools) {
      $gameSystem.pxbTools = defaultState();
    }
    return true;
  }

  // Reset bậc công cụ hiện tại (event/test dùng để bắt đầu lại).
  function resetState() {
    var st = state();
    st.tools = {};
    st.lastUpgrade = null;
    return true;
  }

  // --- Đồng bộ với PXB_Crafting (1 nguồn sự thật — xem @help) ---

  // Đọc bậc 1 công cụ từ PXB_Crafting / $gameSystem.pxbCrafting.tools
  // (nơi craftCurrent ghi khi chế bậc 1). Trả 0 khi không có / chưa load.
  function craftingToolTier(tool) {
    if (typeof window !== "undefined" && window.PXB_Crafting &&
        typeof window.PXB_Crafting.toolTier === "function") {
      return window.PXB_Crafting.toolTier(tool) || 0;
    }
    if (typeof global !== "undefined" && global.PXB_Crafting &&
        typeof global.PXB_Crafting.toolTier === "function") {
      return global.PXB_Crafting.toolTier(tool) || 0;
    }
    if (typeof $gameSystem !== "undefined" && $gameSystem &&
        $gameSystem.pxbCrafting && $gameSystem.pxbCrafting.tools) {
      return $gameSystem.pxbCrafting.tools[tool] || 0;
    }
    return 0;
  }

  // Ghi đè (mirror) bậc công cụ sang $gameSystem.pxbCrafting.tools để
  // PXB_Crafting.toolTier() thấy cùng 1 số. Chỉ ghi khi pxbCrafting đã
  // có (không tự tạo state của plugin khác).
  function mirrorToCrafting(tool, tier) {
    if (typeof $gameSystem !== "undefined" && $gameSystem &&
        $gameSystem.pxbCrafting && $gameSystem.pxbCrafting.tools) {
      if (($gameSystem.pxbCrafting.tools[tool] || 0) < tier) {
        $gameSystem.pxbCrafting.tools[tool] = tier;
      }
      return true;
    }
    return false;
  }

  // Đồng bộ bậc từ PXB_Crafting sang pxbTools: lấy max 2 bên cho từng
  // công cụ (chế bậc 1 ở Crafting thì Tools cũng thấy). Trả true khi
  // có ít nhất 1 bậc được đồng bộ lên.
  function syncFromCrafting() {
    var st = state();
    var changed = false;
    for (var i = 0; i < TOOL_IDS.length; i++) {
      var tool = TOOL_IDS[i];
      var fromCrafting = craftingToolTier(tool);
      if (fromCrafting > (st.tools[tool] || 0)) {
        st.tools[tool] = fromCrafting;
        changed = true;
      }
    }
    return changed;
  }

  // --- Công cụ đang có ---

  // Bậc công cụ đang có (0 = chưa có công cụ này). Đồng bộ từ
  // PXB_Crafting trước khi đọc để không lệch với bản chế ở đó.
  function toolTier(tool) {
    if (!isValidTool(tool)) return 0;
    syncFromCrafting();
    return state().tools[tool] || 0;
  }

  function hasTool(tool) {
    return toolTier(tool) > 0;
  }

  function toolName(tool) {
    return TOOL_NAMES[tool] || tool;
  }

  // Mô tả hành vi của bậc công cụ đang có; chưa có tool thì trả chuỗi
  // mặc định (cùng ToolBehaviour với bậc lạ).
  function toolBehaviourCurrent(tool) {
    return toolBehaviour(tool, toolTier(tool));
  }

  // --- Trừ nguyên liệu (cùng quy ước Crafting.craft) ---

  // Đủ nguyên liệu cho 1 bảng cost không? Không trừ đồ ở đây.
  function hasMaterials(cost, materials) {
    var bag = materials || {};
    for (var id in cost) {
      if ((bag[id] || 0) < cost[id]) return false;
    }
    return true;
  }

  // Nguyên liệu còn thiếu cho 1 bảng cost: { materialId: số còn thiếu }.
  function missingForCost(cost, materials) {
    var missing = {};
    var bag = materials || {};
    for (var id in cost) {
      var have = bag[id] || 0;
      if (have < cost[id]) missing[id] = cost[id] - have;
    }
    return missing;
  }

  // Trừ nguyên liệu TRỰC TIẾP trên túi truyền vào. Nguyên liệu nào trừ
  // hết (về 0) thì XÓA key khỏi túi, không để lại entry 0 — cùng quy
  // ước Crafting.cs sửa 18/11. Chỉ gọi sau khi hasMaterials() đã true.
  function deductMaterials(cost, materials) {
    for (var id in cost) {
      var conLai = (materials[id] || 0) - cost[id];
      if (conLai <= 0) delete materials[id];
      else materials[id] = conLai;
    }
  }

  // --- Nâng cấp bậc 2/3 ---

  // Chi phí nâng công cụ lên bậc đích (2 hoặc 3). Trả object cost hoặc
  // null khi tool/bậc không hợp lệ (tool lạ, đích không phải 2/3).
  function upgradeCost(tool, toTier) {
    var t = normalizeTier(toTier);
    if (!isValidTool(tool) || (t !== TIER_KHA && t !== TIER_TOT)) return null;
    var recipe = upgradeRecipeFor(tool, t);
    return recipe ? recipe.cost : null;
  }

  // Nguyên liệu còn thiếu để nâng lên bậc tiếp theo (túi chung mặc định;
  // truyền materials để test với túi riêng). Công cụ lạ / đã max thì {}.
  function missingForUpgrade(tool, materials) {
    var cur = toolTier(tool);
    if (!isValidTool(tool) || cur <= 0 || cur >= TIER_TOT) return {};
    var cost = upgradeCost(tool, cur + 1);
    if (!cost) return {};
    return missingForCost(cost, materials || materialsBag());
  }

  // Có nâng được công cụ lên bậc tiếp theo không? (dùng túi chung mặc
  // định; truyền materials để test với túi riêng). Trả:
  //   {ok:true, tool, fromTier, toTier, cost, missing:{}}
  //   {ok:false, reason:"cong-cu-la"}
  //   {ok:false, reason:"chua-co-cong-cu", toTier:1} — chưa có bậc 1,
  //     phải chế/nhận bậc 1 trước (Xe Đẩy/Đèn Soi qua PXB_Crafting,
  //     Sổ Tay/Xẻng qua acquire())
  //   {ok:false, reason:"da-max", tier:3}
  //   {ok:false, reason:"thieu-nguyen-lieu", missing:{...}, cost}
  function canUpgrade(tool, materials) {
    if (!isValidTool(tool)) {
      return { ok: false, reason: "cong-cu-la" };
    }
    var cur = toolTier(tool);
    if (cur <= 0) {
      return { ok: false, reason: "chua-co-cong-cu", toTier: TIER_THO };
    }
    if (cur >= TIER_TOT) {
      return { ok: false, reason: "da-max", tier: cur };
    }
    var next = cur + 1;
    var cost = upgradeCost(tool, next);
    var bag = materials || materialsBag();
    if (!hasMaterials(cost, bag)) {
      return {
        ok: false, reason: "thieu-nguyen-lieu", toTier: next,
        cost: cost, missing: missingForCost(cost, bag)
      };
    }
    return { ok: true, tool: tool, fromTier: cur, toTier: next,
      cost: cost, missing: {} };
  }

  // Nâng công cụ lên 1 bậc: trừ nguyên liệu túi chung, tăng bậc, ghi
  // đè sang pxbCrafting, lưu lastUpgrade. Trả như canUpgrade(), thêm
  // ok:true khi xong. Thất bại thì KHÔNG trừ gì, KHÔNG đổi bậc.
  function upgrade(tool, materials) {
    var check = canUpgrade(tool, materials);
    if (!check.ok) return check;
    var bag = materials || materialsBag();
    deductMaterials(check.cost, bag);
    var st = state();
    st.tools[tool] = check.toTier;
    st.lastUpgrade = {
      tool: tool, fromTier: check.fromTier, toTier: check.toTier
    };
    mirrorToCrafting(tool, check.toTier);
    return {
      ok: true, tool: tool, fromTier: check.fromTier,
      toTier: check.toTier, cost: check.cost, missing: {}
    };
  }

  // --- Nhận bậc 1 Sổ Tay / Xẻng (PROVISIONAL — xem @help) ---

  // Có nhận được bậc 1 không? Xe Đẩy / Đèn Soi trả reason
  // "dung-che-tao" (bậc 1 của 2 công cụ đó chỉ chế qua PXB_Crafting).
  // Trả cùng dạng canUpgrade().
  function canAcquire(tool, materials) {
    if (!isValidTool(tool)) {
      return { ok: false, reason: "cong-cu-la" };
    }
    if (toolTier(tool) > 0) {
      return { ok: false, reason: "da-co-cong-cu", tier: toolTier(tool) };
    }
    var recipe = acquireRecipeFor(tool);
    if (!recipe) {
      return { ok: false, reason: "dung-che-tao",
        recipeId: tool === TOOL_XE_DAY ? "che-xe-day" : "che-den-soi" };
    }
    var bag = materials || materialsBag();
    if (!hasMaterials(recipe.cost, bag)) {
      return {
        ok: false, reason: "thieu-nguyen-lieu", toTier: TIER_THO,
        cost: recipe.cost, missing: missingForCost(recipe.cost, bag)
      };
    }
    return { ok: true, tool: tool, fromTier: 0, toTier: TIER_THO,
      cost: recipe.cost, missing: {} };
  }

  // Nhận bậc 1 Sổ Tay / Xẻng: trừ nguyên liệu túi chung, đặt bậc 1,
  // ghi đè sang pxbCrafting. Thất bại thì KHÔNG trừ gì.
  function acquire(tool, materials) {
    var check = canAcquire(tool, materials);
    if (!check.ok) return check;
    var bag = materials || materialsBag();
    deductMaterials(check.cost, bag);
    var st = state();
    st.tools[tool] = TIER_THO;
    st.lastUpgrade = { tool: tool, fromTier: 0, toTier: TIER_THO };
    mirrorToCrafting(tool, TIER_THO);
    return {
      ok: true, tool: tool, fromTier: 0,
      toTier: TIER_THO, cost: check.cost, missing: {}
    };
  }

  // --- Xe Đẩy: sức chở + đường mưa (móc PXB_Jobs) ---

  // Sức chở theo BẬC (số đơn vị hàng mỗi chuyến). Bậc lạ/0 -> 0.
  // PROVISIONAL — xem CARRY_CAPACITY.
  function carryCapacity(tier) {
    var t = normalizeTier(tier);
    return CARRY_CAPACITY[t] || 0;
  }

  // Sức chở của Xe Đẩy ĐANG CÓ (chưa có Xe Đẩy -> 0).
  function cartCapacityCurrent() {
    return carryCapacity(toolTier(TOOL_XE_DAY));
  }

  // Trời mưa: chỉ Xe Đẩy bậc 3 đi được, không ướt hàng.
  // isRaining: true/false do event truyền vào; không truyền thì đọc
  // $gameSystem.pxbWeather.isRaining khi có (PROVISIONAL), mặc định
  // coi như không mưa. Trả {canTravel, wetGoods, tier, reason}:
  //   không mưa -> đi được, hàng khô; mưa + bậc 3 -> đi được, hàng khô;
  //   mưa + bậc < 3 -> KHÔNG đi được (hàng ướt nếu cố đi).
  function cartCanTravel(isRaining) {
    var raining = isRaining;
    if (typeof raining === "undefined" || raining === null) {
      if (typeof $gameSystem !== "undefined" && $gameSystem &&
          $gameSystem.pxbWeather &&
          typeof $gameSystem.pxbWeather.isRaining === "boolean") {
        raining = $gameSystem.pxbWeather.isRaining;
      } else {
        raining = false;
      }
    }
    var tier = toolTier(TOOL_XE_DAY);
    if (!raining) {
      return { canTravel: true, wetGoods: false, tier: tier,
        reason: "khong-mua" };
    }
    if (tier >= TIER_TOT) {
      return { canTravel: true, wetGoods: false, tier: tier,
        reason: "xe-day-bac-3-di-duoc-duong-mua" };
    }
    return { canTravel: false, wetGoods: true, tier: tier,
      reason: "xe-day-chua-du-bac-di-duong-mua" };
  }

  // Xe Đẩy chở nổi chừng này đơn vị hàng không? (event làm ca shipper /
  // bán rong gọi trước khi nhận đơn). Trả {ok, units, capacity, tier}:
  //   ok=false khi chưa có Xe Đẩy hoặc đơn hàng vượt sức chở.
  function carryCheck(units) {
    var capacity = cartCapacityCurrent();
    var tier = toolTier(TOOL_XE_DAY);
    return {
      ok: capacity > 0 && units <= capacity,
      units: units, capacity: capacity, tier: tier
    };
  }

  // --- Đèn Soi: thấy hotspot ẩn / hiếm (móc PXB_Hotspot) ---

  // Đèn Soi có thấy hotspot này không?
  // hotspot: {hidden:boolean, rarity:"thuong"|"hiem", near:boolean,
  //   bestFrame:"Sáng"|"Chiều"|"Tối" (tùy chọn), districtId (tùy chọn)}.
  // frameName: khung hiện tại ("Sáng"/"Chiều"/"Tối", tùy chọn — event
  // truyền rõ khi PXB_Time chưa load; không truyền thì đọc PXB_Time
  // khi có, không có thì bỏ qua kiểm tra khung).
  //  - Hotspot thường (không ẩn, không hiếm): thấy bằng mắt thường,
  //    không cần Đèn Soi (PXB_Hotspot vốn nhặt được không cần công cụ).
  //  - Hotspot hiếm: chỉ Đèn Soi bậc 3 thấy, và chỉ đúng khung nó
  //    xuất hiện (1 khung/ngày — ToolBehaviour DenSoi:3).
  //  - Hotspot ẩn (không hiếm): bậc 1 không thấy; bậc 2 chỉ thấy khi
  //    GẦN (near === true); bậc 3 thấy mọi hotspot ẩn.
  //  - Hotspot có bestFrame mà sai khung hiện tại: chưa xuất hiện nên
  //    không thấy (kiểm tra này chỉ chạy khi biết rõ cả 2 khung).
  // PROVISIONAL: "gần" = hotspot.near (C# không định nghĩa gần/xa).
  function seesHotspot(hotspot, frameName) {
    if (!hotspot) return false;
    var frame = frameName || currentFrameName();
    if (hotspot.bestFrame && frame && hotspot.bestFrame !== frame) {
      return false;
    }
    var tier = toolTier(TOOL_DEN_SOI);
    if (hotspot.rarity === "hiem") {
      return tier >= TIER_TOT;
    }
    if (!hotspot.hidden) return true;
    if (tier >= TIER_TOT) return true;
    if (tier >= TIER_KHA) return hotspot.near === true;
    return false;
  }

  // Lọc danh sách hotspot thành những hotspot Đèn Soi thấy được ở khung
  // hiện tại (đường dùng khi PXB_Hotspot liệt kê hotspot trong khu).
  function visibleHotspots(list, frameName) {
    var out = [];
    if (!list) return out;
    for (var i = 0; i < list.length; i++) {
      if (seesHotspot(list[i], frameName)) out.push(list[i]);
    }
    return out;
  }

  // Khung hiện tại ("Sáng"/"Chiều"/"Tối") qua PXB_Time khi có.
  // Chưa có PXB_Time thì trả null — caller bỏ qua kiểm tra khung.
  function currentFrameName() {
    var t = null;
    if (typeof window !== "undefined" && window.PXB_Time) t = window.PXB_Time;
    else if (typeof global !== "undefined" && global.PXB_Time) t = global.PXB_Time;
    if (!t || typeof t.frameName !== "function" ||
        typeof t.elapsedMinutes !== "function") {
      return null;
    }
    return t.frameName(t.elapsedMinutes());
  }

  // --- Sổ Tay: gợi ý theo bậc (móc PXB_Crafting / PXB_Hotspot) ---

  // Mức chi tiết gợi ý của Sổ Tay đang có: 0 = chưa có Sổ Tay,
  // 1 = chung chung, 2 = mục tiêu + khu, 3 = + nguyên liệu thiếu
  // (đúng ToolBehaviour SoTay 1/2/3).
  function hintLevel() {
    return toolTier(TOOL_SO_TAY);
  }

  // Gợi ý Sổ Tay cho 1 công thức (chế tạo / nâng cấp / nhận công cụ):
  //  - Bậc 3: liệt kê nguyên liệu còn thiếu (ủy quyền cho
  //    PXB_Crafting.guideHintForRecipe khi đã load; công thức của
  //    riêng file này thì tự tính thiếu từ bảng cost).
  //  - Bậc 2: chỉ tên món + khu cần tới (không liệt kê thiếu từng món).
  //  - Bậc 1 trở xuống: câu chung chung, không spoil đáp án.
  // recipeId lạ (không phải công thức Crafting lẫn Tools) -> chuỗi mặc
  // định (cùng ToolBehaviour với bậc lạ).
  function guideHintForRecipe(recipeId) {
    var level = hintLevel();
    if (level <= 0) {
      return "Chưa có Sổ Tay — hỏi NPC trong khu xem cần làm gì trước đã.";
    }
    var local = recipeById(recipeId);
    if (local) {
      if (level >= TIER_TOT) {
        var missing = missingForCost(local.cost, materialsBag());
        var keys = Object.keys(missing);
        if (keys.length === 0) {
          return "Đủ đồ nâng " + toolName(local.tool) + " lên bậc " +
            TIER_NAMES[local.toTier] + " rồi — ghé Góc Chế Tạo làm ngay đi.";
        }
        var parts = [];
        for (var i = 0; i < keys.length; i++) {
          parts.push(keys[i] + " còn thiếu " + missing[keys[i]]);
        }
        return "Để nâng " + toolName(local.tool) + " lên bậc " +
          TIER_NAMES[local.toTier] + " còn thiếu: " + parts.join(", ") + ".";
      }
      if (level >= TIER_KHA) {
        return "Muốn nâng " + toolName(local.tool) + " lên bậc " +
          TIER_NAMES[local.toTier] + " thì ghé Góc Chế Tạo coi lại túi đồ.";
      }
      return "Cứ ghé Góc Chế Tạo hỏi thử — có món nâng được công cụ đó.";
    }
    // Công thức của PXB_Crafting (che-xe-day / che-den-soi / che-qua-tang):
    // ủy quyền cho Crafting khi đã load, để 1 chỗ tính thiếu.
    var c = craftingPlugin();
    if (c && typeof c.guideHintForRecipe === "function") {
      var hint = c.guideHintForRecipe(recipeId);
      if (level >= TIER_TOT) return hint;
      if (level >= TIER_KHA) {
        return "Muốn chế món đó thì ghé Góc Chế Tạo coi lại túi đồ.";
      }
      return "Cứ ghé Góc Chế Tạo hỏi thử — có món chế được đó.";
    }
    return "Chưa rõ bậc công cụ.";
  }

  // Lấy PXB_Crafting khi đã load (plugin #6, load trước plugin này).
  function craftingPlugin() {
    if (typeof window !== "undefined" && window.PXB_Crafting) {
      return window.PXB_Crafting;
    }
    if (typeof global !== "undefined" && global.PXB_Crafting) {
      return global.PXB_Crafting;
    }
    return null;
  }

  // Lấy PXB_Hotspot khi đã load (plugin #5, load trước plugin này).
  function hotspotPlugin() {
    if (typeof window !== "undefined" && window.PXB_Hotspot) {
      return window.PXB_Hotspot;
    }
    if (typeof global !== "undefined" && global.PXB_Hotspot) {
      return global.PXB_Hotspot;
    }
    return null;
  }

  // Gợi ý Sổ Tay cho mục tiêu hiện tại của người chơi:
  //  - Bậc 1: gợi ý chung chung (chỉ nhắc mục tiêu).
  //  - Bậc 2: thêm khu cần tới (districtId — số khu, không hardcode
  //    tên khu ở đây; tên khu xem docs/districts.md).
  //  - Bậc 3: thêm nguyên liệu còn thiếu của công thức recipeId (khi
  //    có recipeId); không có recipeId thì như bậc 2.
  //  - Chưa có Sổ Tay: câu chung chung nhất, khuyên hỏi NPC.
  // goal rỗng -> "chưa có mục tiêu rõ".
  function guideHint(goal, districtId, recipeId) {
    var level = hintLevel();
    var g = (!goal || !String(goal).replace(/\s/g, ""))
      ? "chưa có mục tiêu rõ" : goal;
    if (level <= 0) {
      return "Chưa có Sổ Tay — mục tiêu hiện tại: " + g +
        ". Hỏi NPC trong khu xem cần làm gì trước đã.";
    }
    if (level >= TIER_TOT && recipeId) {
      return "Mục tiêu: " + g + ". Cần tới khu " + districtId + ". " +
        guideHintForRecipe(recipeId);
    }
    if (level >= TIER_KHA) {
      return "Mục tiêu: " + g + ". Cần tới khu " + districtId +
        " — tới đó rồi hỏi NPC trong khu.";
    }
    return "Mục tiêu hiện tại: " + g +
      ". Cứ đi loanh quanh hỏi NPC trong khu xem sao.";
  }

  // Gợi ý NPC dẫn đường, chi tiết theo bậc Sổ Tay: ủy quyền câu gốc
  // cho PXB_Hotspot.guideHint(districtId, goal) khi đã load; bậc 2/3
  // thì nối thêm khu + nguyên liệu thiếu (khi có recipeId).
  // Chưa load PXB_Hotspot thì trả câu Sổ Tay thuần (guideHint).
  function npcHint(districtId, goal, recipeId) {
    var h = hotspotPlugin();
    if (!h || typeof h.guideHint !== "function") {
      return guideHint(goal, districtId, recipeId);
    }
    var base = h.guideHint(districtId, goal);
    var level = hintLevel();
    if (level >= TIER_TOT && recipeId) {
      return base + " " + guideHintForRecipe(recipeId);
    }
    if (level >= TIER_KHA) {
      return base + " (Sổ Tay: mục tiêu này cần tới khu " + districtId + ".)";
    }
    return base;
  }

  // --- Xẻng/Cuốc: nhặt nhanh + thêm đồ / hiếm (móc PXB_Hotspot) ---

  // Tính lượng nhặt được với Xẻng bậc tier (số, không cần state):
  // baseAmount = lượng hotspot cho mỗi lần nhặt (vd 2).
  // roll: số 0..1 do caller truyền (để test quyết định được) — không
  // truyền thì dùng Math.random(). Trả:
  //   {amount, bonus, rareFound, rareMaterialId, timeFactor}
  //   amount = baseAmount + bonus (bonus 0/1).
  //  - Bậc 1: amount = baseAmount, không bonus, không hiếm, chậm nhất.
  //  - Bậc 2: nhanh hơn (0,75); roll < 25% (PROVISIONAL) thì +1.
  //  - Bậc 3: nhanh nhất (0,5); roll < 25% thì +1; roll < 10%
  //    (PROVISIONAL) thì thêm nguyên liệu hiếm (rareFound, id "da-quy").
  // Bậc lạ/0: coi như bậc 1 (nhặt thường, không bonus).
  function collectYield(baseAmount, tier, roll) {
    var t = normalizeTier(tier);
    if (t < TIER_THO || t > TIER_TOT) t = TIER_THO;
    var r = (typeof roll === "number") ? roll : Math.random();
    var bonus = 0;
    var rareFound = false;
    if (t >= TIER_KHA && r < COLLECT_BONUS_CHANCE) bonus = 1;
    if (t >= TIER_TOT && r < RARE_FIND_CHANCE) rareFound = true;
    return {
      amount: (baseAmount | 0) + bonus,
      bonus: bonus,
      rareFound: rareFound,
      rareMaterialId: rareFound ? RARE_MATERIAL_ID : null,
      timeFactor: COLLECT_TIME_FACTOR[t]
    };
  }

  // Nhặt nguyên liệu với Xẻng ĐANG CÓ: cộng amount (+bonus) vào túi
  // chung, cộng 1 nguyên liệu hiếm khi rareFound. Trả kết quả
  // collectYield() kèm materialId. (Đường dùng sau khi PXB_Hotspot
  // cho nhặt hotspot — lượng cơ bản baseAmount lấy từ hotspot.)
  function collect(materialId, baseAmount, roll) {
    var y = collectYield(baseAmount, toolTier(TOOL_XENG), roll);
    var bag = materialsBag();
    bag[materialId] = (bag[materialId] || 0) + y.amount;
    if (y.rareFound) {
      bag[y.rareMaterialId] = (bag[y.rareMaterialId] || 0) + 1;
    }
    return {
      materialId: materialId, amount: y.amount, bonus: y.bonus,
      rareFound: y.rareFound, rareMaterialId: y.rareMaterialId,
      timeFactor: y.timeFactor
    };
  }

  // --- Móc vào core MV ---

  // Plugin command cho CommonEvent / event thường:
  //   PXB_Tools Upgrade XeDay   — nâng Xe Đẩy lên 1 bậc (trừ túi chung)
  //   PXB_Tools Acquire Xeng    — nhận Xẻng bậc 1 (PROVISIONAL)
  //   PXB_Tools Tier XeDay      — hiện bậc + hành vi qua $gameMessage
  //   PXB_Tools Hint che-xe-day — hiện gợi ý Sổ Tay qua $gameMessage
  //   PXB_Tools Collect la-chuoi 2 — nhặt 2 lá chuối + bonus Xẻng
  //   PXB_Tools Sync            — đồng bộ bậc từ PXB_Crafting
  // Upgrade/Acquire/Hint/Collect KHÔNG qua plugin command khi cần kết
  // quả trả về — event gọi trực tiếp PXB_Tools.upgrade(...) v.v.
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
              $gameSystem.pxbTools) {
            // Điền lại field thiếu khi load save cũ / save sửa tay;
            // kẹp bậc về 0–3, bỏ công cụ lạ.
            var d = defaultState();
            var s = $gameSystem.pxbTools;
            for (var k in d) {
              if (typeof s[k] === "undefined") s[k] = d[k];
            }
            if (!s.tools || typeof s.tools !== "object") s.tools = {};
            var kept = {};
            for (var i = 0; i < TOOL_IDS.length; i++) {
              var t = s.tools[TOOL_IDS[i]] | 0;
              if (t > 0) kept[TOOL_IDS[i]] = Math.min(t, TIER_TOT);
            }
            s.tools = kept;
          }
        };
      }
    }
    if (typeof Game_Interpreter !== "undefined" &&
        typeof Game_Interpreter.prototype.pluginCommand === "function") {
      var _pluginCommand = Game_Interpreter.prototype.pluginCommand;
      Game_Interpreter.prototype.pluginCommand = function (command, args) {
        _pluginCommand.call(this, command, args);
        if (command === "PXB_Tools") {
          if (args[0] === "Upgrade") {
            upgrade(args[1]);
          } else if (args[0] === "Acquire") {
            acquire(args[1]);
          } else if (args[0] === "Sync") {
            syncFromCrafting();
          } else if (args[0] === "Collect") {
            collect(args[1], parseInt(args[2], 10) || 0);
          } else if (args[0] === "Tier" &&
              typeof $gameMessage !== "undefined" && $gameMessage) {
            $gameMessage.add(toolName(args[1]) + " bậc " +
              toolTier(args[1]) + ": " + toolBehaviourCurrent(args[1]));
          } else if (args[0] === "Hint" &&
              typeof $gameMessage !== "undefined" && $gameMessage) {
            $gameMessage.add(guideHintForRecipe(args[1]));
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

  var PXB_Tools = {
    TOOL_XE_DAY: TOOL_XE_DAY,
    TOOL_DEN_SOI: TOOL_DEN_SOI,
    TOOL_SO_TAY: TOOL_SO_TAY,
    TOOL_XENG: TOOL_XENG,
    TOOL_IDS: TOOL_IDS,
    TIER_THO: TIER_THO,
    TIER_KHA: TIER_KHA,
    TIER_TOT: TIER_TOT,
    TIER_NAMES: TIER_NAMES,
    TOOL_NAMES: TOOL_NAMES,
    UPGRADE_RECIPES: UPGRADE_RECIPES,
    ACQUIRE_RECIPES: ACQUIRE_RECIPES,
    CARRY_CAPACITY: CARRY_CAPACITY,
    COLLECT_TIME_FACTOR: COLLECT_TIME_FACTOR,
    COLLECT_BONUS_CHANCE: COLLECT_BONUS_CHANCE,
    RARE_FIND_CHANCE: RARE_FIND_CHANCE,
    RARE_MATERIAL_ID: RARE_MATERIAL_ID,
    toolBehaviour: toolBehaviour,
    toolTier: toolTier,
    hasTool: hasTool,
    toolName: toolName,
    toolBehaviourCurrent: toolBehaviourCurrent,
    upgradeCost: upgradeCost,
    missingForUpgrade: missingForUpgrade,
    canUpgrade: canUpgrade,
    upgrade: upgrade,
    canAcquire: canAcquire,
    acquire: acquire,
    upgradeRecipeFor: upgradeRecipeFor,
    acquireRecipeFor: acquireRecipeFor,
    recipeById: recipeById,
    carryCapacity: carryCapacity,
    cartCapacityCurrent: cartCapacityCurrent,
    cartCanTravel: cartCanTravel,
    carryCheck: carryCheck,
    seesHotspot: seesHotspot,
    visibleHotspots: visibleHotspots,
    currentFrameName: currentFrameName,
    hintLevel: hintLevel,
    guideHint: guideHint,
    guideHintForRecipe: guideHintForRecipe,
    npcHint: npcHint,
    collectYield: collectYield,
    collect: collect,
    syncFromCrafting: syncFromCrafting,
    mirrorToCrafting: mirrorToCrafting,
    craftingToolTier: craftingToolTier,
    state: state,
    materialsBag: materialsBag,
    resetState: resetState,
    initInGameSystem: initInGameSystem,
    install: install
  };

  if (typeof module !== "undefined" && module.exports) {
    module.exports = PXB_Tools;
  } else if (typeof window !== "undefined") {
    window.PXB_Tools = PXB_Tools;
  }
})();
