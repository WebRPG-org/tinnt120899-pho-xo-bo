/*:
 * @plugindesc Phố Xô Bồ — Hotspot lấp lánh kiểu Nadia: to, chạm được, nhặt 1 lần/ngày game, chỉ có đồ đúng khung.
 * @author Muse Center
 *
 * @help
 * Port trung thực Exploration.cs + HotspotView.cs
 * (src/client/Assets/Scripts/Exploration.cs, HotspotView.cs).
 *
 * - 5 hotspot slice (PROVISIONAL — danh sách + vật + số lượng chưa chốt
 *   GDD; khi GDD chốt bảng hotspot thì sửa đúng bảng HOTSPOTS, không sửa
 *   code khám phá — như Exploration.cs đã ghi).
 * - Hotspot TO, lấp lánh, chạm được: vùng chạm tối thiểu 44×44 pt
 *   (architecture-nadia.md §6 dòng 5; HotspotView.cs).
 * - Nhặt 1 lần / 1 ngày game — quay lại ngày sau có vật mới (kiểu Nadia).
 *   Sang ngày game mới thì tự reset lượt khám phá trong ngày.
 * - CHỈ CHO ĐỒ ĐÚNG KHUNG: hotspot chỉ nhặt được khi khung hiện tại
 *   trùng BestFrame của nó. LƯU Ý LỆCH VỚI C#: Exploration.Explore()
 *   hiện KHÔNG kiểm tra khung (chỉ dùng BestFrame để sắp xếp + sáng
 *   hơn); architecture-nadia.md §6 dòng 5 ghi "chỉ có đồ đúng khung"
 *   nên plugin này chặn sai khung. Khi C# sửa theo thì hai bên khớp.
 * - Màu lấp lánh: vàng Vàng Tâm #E0A800 (thường) / cam (hiếm) — palette
 *   lock, HotspotView.cs. Cả 5 hotspot slice đều là "thường" (vàng);
 *   Exploration.cs KHÔNG có trường hiếm nên chưa hotspot nào là hiếm —
 *   mã màu cam dưới đây là PROVISIONAL, chỉ dùng khi GDD chốt hotspot hiếm.
 * - Độ sáng lấp lánh (HotspotView.cs): đã nhặt hôm nay 0.25, đúng khung
 *   tốt 1.5, còn lại 0.8; nhấp nháy to dần/nhỏ dần theo nhịp sin.
 * - NPC dẫn đường GuideHint (thay Soul Crystal / Evie của Nadia):
 *   Cô Tư (khu 1), Chị Lệ (khu 2), Ông Ba (khu 17), Anh Hải (khu 18),
 *   khu khác: Bạn thân. Gợi ý nhúng trong lời thoại, không spoil đáp án,
 *   nhạt dần theo tiến trình — không biến mất đột ngột giữa game.
 * - Fast travel chỉ tới khu đã mở (slice: 1, 2, 17, 18); khu chưa mở ghi
 *   rõ điều kiện mở (xem docs/districts.md — khu mở theo chương/tầng).
 *
 * NGÀY GAME LẤY TỪ ĐÂU? (cách chọn — đọc kỹ trước khi đổi)
 *   1. ƯU TIÊN PXB_Time nếu đã load: ngày game = $gameSystem.pxbDayNumber
 *      (PXB_Time.js đọc đúng biến này trong SaturdayEvent). Khi số ngày
 *      đổi, lượt khám phá trong ngày tự reset — như Exploration.Explore()
 *      tự gọi NewGameDay khi gameDay khác ngày đã lưu.
 *   2. Nếu PXB_Time chưa load (hoặc pxbDayNumber chưa có): plugin tự
 *      theo dõi ngày trong $gameSystem.pxbHotspot.day, tăng bằng plugin
 *      command `PXB_Hotspot NewDay` (event chuyển ngày gọi lệnh này).
 *   3. Không dùng $gameVariables cho ngày game: chưa có variable id nào
 *      chốt trong data/System.json; khi chốt thì đổi currentDayNumber().
 *
 * LƯU: state sống trong $gameSystem.pxbHotspot (+ nguyên liệu trong
 * $gameSystem.pxbMaterials) nên đi theo save của MV ($gameSystem vốn đã
 * nằm trong save contents của core — architecture-nadia.md §1.5). Khi
 * core MV chưa có (repo hiện tại), logic thuần vẫn chạy và test được qua
 * module.exports; hàm install() trả false và không giả vờ đã móc save.
 *
 * Dùng trong event (khi có core MV):
 *   PXB_Hotspot.collect("hs-cho-sang")   // true = nhặt được (đúng khung, chưa nhặt hôm nay)
 *   PXB_Hotspot.guideHint(2, "làm xe đẩy") // lời gợi ý của Chị Lệ
 *   PXB_Hotspot.hotspotsInDistrict(2)    // hotspot khu 2, khung tốt lên trước
 *   PXB_Hotspot.canFastTravel(17)        // khu 17 đã mở chưa
 * Plugin command: PXB_Hotspot Collect hs-cho-sang | Hint | NewDay
 */
(function () {
  "use strict";

  // Lấy hằng từ PXB_Balance (plugin #1, load trước). Khi chạy node test
  // mà chưa load PXB_Balance, dùng fallback — cùng số đã chốt trong
  // Exploration.cs / TimeSystem.cs, để logic vẫn test được.
  function balance() {
    if (typeof window !== "undefined" && window.PXB_Balance) {
      return window.PXB_Balance;
    }
    if (typeof global !== "undefined" && global.PXB_Balance) {
      return global.PXB_Balance;
    }
    return null;
  }

  // Khung đã chốt: Sáng / Chiều / Tối (PXB_Balance.frames).
  var FALLBACK_FRAMES = ["Sáng", "Chiều", "Tối"];

  function frameNames() {
    var b = balance();
    if (b && b.frames) return b.frames;
    return FALLBACK_FRAMES;
  }

  // Lấy PXB_Time nếu đã load (plugin #3, load trước plugin này).
  function timePlugin() {
    if (typeof window !== "undefined" && window.PXB_Time) {
      return window.PXB_Time;
    }
    if (typeof global !== "undefined" && global.PXB_Time) {
      return global.PXB_Time;
    }
    return null;
  }

  // --- Bảng hotspot slice — PORT TRỰC TIẾP Exploration.Hotspots ---
  // PROVISIONAL — danh sách hotspot + vật + số lượng là số cấu hình slice,
  // chưa chốt GDD (Exploration.cs). Chỉ dùng 4 khu slice: 1 Xóm Trọ Cũ,
  // 2 Chợ Đầu Mối, 17 Công Viên An Bình, 18 Phố Đi Bộ – Chợ Đêm.
  // docs/districts.md KHÔNG liệt kê hotspot/vật/khung nào — mọi dữ liệu
  // dưới đây chỉ lấy từ Exploration.cs, không bịa thêm.
  // id, name, districtId, bestFrame ("Sáng"/"Chiều"/"Tối"), materialId,
  // amountPerVisit, rarity ("thuong" — cả 5 đều thường; Exploration.cs
  // không có trường hiếm).
  var HOTSPOTS = [
    { id: "hs-cho-sang",  name: "Sạp rau buổi sáng",  districtId: 2,  bestFrame: "Sáng",  materialId: "la-chuoi",  amount: 2, rarity: "thuong" },
    { id: "hs-cho-chieu", name: "Góc phế liệu chợ",   districtId: 2,  bestFrame: "Chiều", materialId: "sat-vun",   amount: 1, rarity: "thuong" },
    { id: "hs-tro-toi",   name: "Hẻm trọ buổi tối",   districtId: 1,  bestFrame: "Tối",   materialId: "chai-nhua", amount: 2, rarity: "thuong" },
    { id: "hs-cong-vien", name: "Ghế đá công viên",   districtId: 17, bestFrame: "Chiều", materialId: "van-go",    amount: 1, rarity: "thuong" },
    { id: "hs-cho-dem",   name: "Sạp đêm cuối phố",   districtId: 18, bestFrame: "Tối",   materialId: "vai-vun",   amount: 2, rarity: "thuong" }
  ];

  // Khu đã mở fast-travel trong slice (Exploration.FastTravelUnlockedSlice).
  // Khu khác mở dần bằng chế tạo / quest (GDD Mục 9) — không hardcode ở đây.
  var FAST_TRAVEL_UNLOCKED_SLICE = [1, 2, 17, 18];

  // Tổng số khu đã chốt: 18 (docs/districts.md). Dùng để kiểm tra khu
  // có thật khi fast travel — tên khu xem districts.md, không hardcode
  // tên khu vào plugin này.
  var DISTRICT_COUNT = 18;

  // --- Hằng hiển thị (không phải số game — lấy từ HotspotView.cs) ---
  // Vùng chạm tối thiểu 44×44 pt trên mobile (architecture-nadia §6.5).
  var MIN_TOUCH_PT = 44;
  // Màu Vàng Tâm #E0A800 — palette lock (HotspotView.cs, docs/art-assets.md §0).
  var SPARKLE_COLOR_COMMON = "#E0A800"; // vàng — thường
  // PROVISIONAL — mã màu cam cho hotspot hiếm: GDD chưa chốt hotspot hiếm
  // nào (Exploration.cs không có trường hiếm) nên màu này chưa dùng trong
  // slice; đổi khi chốt palette hiếm.
  var SPARKLE_COLOR_RARE = "#E07800"; // cam — hiếm (PROVISIONAL)
  // Độ sáng lấp lánh (HotspotView.cs): đã nhặt 0.25 / đúng khung 1.5 / còn lại 0.8.
  var BRIGHTNESS_COLLECTED = 0.25;
  var BRIGHTNESS_BEST_FRAME = 1.5;
  var BRIGHTNESS_NORMAL = 0.8;
  // Nhấp nháy kiểu Nadia: to dần / nhỏ dần theo nhịp sin (HotspotView.cs).
  var SPARKLE_PULSE_BASE = 0.85;
  var SPARKLE_PULSE_AMP = 0.15;
  var SPARKLE_PULSE_SPEED = 3;

  // --- Tra cứu bảng ---

  function get(hotspotId) {
    for (var i = 0; i < HOTSPOTS.length; i++) {
      if (HOTSPOTS[i].id === hotspotId) return HOTSPOTS[i];
    }
    return null;
  }

  // Hotspot trong 1 khu, theo khung hiện tại (khung tốt lên trước).
  // Port trung thực Exploration.HotspotsInDistrict.
  function hotspotsInDistrict(districtId, frameName) {
    var best = [];
    var rest = [];
    for (var i = 0; i < HOTSPOTS.length; i++) {
      var h = HOTSPOTS[i];
      if (h.districtId !== districtId) continue;
      if (h.bestFrame === frameName) best.push(h);
      else rest.push(h);
    }
    return best.concat(rest);
  }

  // Chỉ fast travel tới khu đã mở. Trả false nếu khu chưa mở / không có
  // trong 18 khu. Port trung thực Exploration.CanFastTravel.
  function canFastTravel(districtId, unlockedDistrictIds) {
    if (!unlockedDistrictIds) return false;
    if (districtId < 1 || districtId > DISTRICT_COUNT) return false;
    for (var i = 0; i < unlockedDistrictIds.length; i++) {
      if (unlockedDistrictIds[i] === districtId) return true;
    }
    return false;
  }

  // --- State thuần (test được, không dính $gameSystem) ---
  // state = { day: số ngày game đã ghi nhận, visited: { hotspotId: true } }
  // materials = { materialId: số lượng } — túi nguyên liệu, id dùng chung
  // với Crafting.cs / PXB_Balance.recipes (la-chuoi, van-go, khung-sat,
  // banh-xe, vai-vun, chai-nhua, sat-vun).

  function createState(day) {
    return { day: day || 1, visited: {} };
  }

  // Sang ngày game mới: reset lượt khám phá trong ngày.
  // Port trung thực Exploration.NewGameDay.
  function newGameDay(state) {
    state.visited = {};
    return state;
  }

  // Khám phá 1 hotspot (logic thuần, port Exploration.Explore + chặn sai khung).
  // Trả { ok, reason, materialId, amount }:
  //   ok=true  — nhặt được; reason "ok".
  //   ok=false — reason "unknown" (hotspot không có), "wrong-frame"
  //   (sai khung — chỉ cho đồ đúng khung, xem @help), "already"
  //   (đã nhặt trong ngày game này — mai quay lại có đồ mới).
  // Sang ngày mới thì TỰ reset lượt khám phá trong ngày (như C# đã sửa
  // 18/11: Explore tự reset khi gameDay khác ngày đã lưu).
  function explore(state, hotspotId, gameDay, frameName, materials) {
    var hotspot = get(hotspotId);
    if (!hotspot) {
      return { ok: false, reason: "unknown", materialId: null, amount: 0 };
    }
    if (typeof gameDay === "number" && gameDay !== state.day) {
      newGameDay(state);
      state.day = gameDay;
    }
    // Chỉ cho đồ đúng khung (architecture-nadia §6 dòng 5). Lệch với
    // Exploration.Explore() hiện tại — xem ghi chú ở @help.
    if (frameName && hotspot.bestFrame !== frameName) {
      return { ok: false, reason: "wrong-frame", materialId: hotspot.materialId, amount: 0 };
    }
    if (state.visited[hotspotId]) {
      return { ok: false, reason: "already", materialId: hotspot.materialId, amount: 0 };
    }
    state.visited[hotspotId] = true;
    if (materials) {
      materials[hotspot.materialId] = (materials[hotspot.materialId] || 0) + hotspot.amount;
    }
    return { ok: true, reason: "ok", materialId: hotspot.materialId, amount: hotspot.amount };
  }

  function hasVisitedToday(state, hotspotId) {
    return !!state.visited[hotspotId];
  }

  // --- Màu + độ sáng lấp lánh (HotspotView.cs) ---

  function sparkleColor(hotspot) {
    if (hotspot && hotspot.rarity === "hiem") return SPARKLE_COLOR_RARE;
    return SPARKLE_COLOR_COMMON;
  }

  // Tỉ lệ nhấp nháy theo thời gian (giây): 0.85 + 0.15 * sin(t * 3).
  function sparkleScale(elapsedSeconds) {
    return SPARKLE_PULSE_BASE + SPARKLE_PULSE_AMP * Math.sin(elapsedSeconds * SPARKLE_PULSE_SPEED);
  }

  // Độ sáng: đã nhặt hôm nay 0.25, đúng khung tốt 1.5, còn lại 0.8.
  function sparkleBrightness(hotspot, frameName, collectedToday) {
    if (collectedToday) return BRIGHTNESS_COLLECTED;
    if (hotspot && frameName && hotspot.bestFrame === frameName) return BRIGHTNESS_BEST_FRAME;
    return BRIGHTNESS_NORMAL;
  }

  // Kích thước chạm tối thiểu (pt) — event hotspot phải to ít nhất chừng này.
  function minTouchPt() {
    return MIN_TOUCH_PT;
  }

  // --- NPC dẫn đường GuideHint — PORT TRỰC TIẾP Exploration.GuideHint ---
  // Tên NPC là NPC Phố Xô Bồ, không phải Nadia. Gợi ý gắn với mục tiêu
  // hiện tại, không spoil đáp án.

  function guideHint(districtId, currentGoal) {
    var goal = (!currentGoal || !String(currentGoal).replace(/\s/g, ""))
      ? "chưa có mục tiêu rõ" : currentGoal;
    switch (districtId) {
      case 1:
        return "Cô Tư (chủ trọ): \"Ở hẻm này thì cứ ra chợ sớm mà nhặt đồ. Còn " + goal + " thì ghé sạp đầu hẻm hỏi thử.\"";
      case 2:
        return "Chị Lệ (sạp rau): \"Chợ sáng nhiều đồ lắm, chiều thì qua góc phế liệu. " + goal + " thì cần đồ chế — coi lại túi nguyên liệu đi.\"";
      case 17:
        return "Ông Ba (công viên): \"Ngồi ghế đá nghĩ cho kỹ đã. " + goal + " gấp thì không xong đâu, cứ từng bước.\"";
      case 18:
        return "Anh Hải (chợ đêm): \"Đêm nay đông khách, vừa bán vừa nhặt được đồ. " + goal + " thì để mai sáng làm tiếp cũng được.\"";
      default:
        return "Bạn thân: \"Không biết làm gì tiếp thì mở điện thoại coi Bản đồ với Việc làm đã. Mục tiêu hiện tại: " + goal + ".\"";
    }
  }

  // --- Gắn vào $gameSystem (đi theo save) ---

  // Dữ liệu dự phòng khi chưa có core MV (logic thuần vẫn test được).
  var fallbackState = createState(1);
  var fallbackMaterials = {};

  // Số ngày game hiện tại. ƯU TIÊN PXB_Time ($gameSystem.pxbDayNumber);
  // nếu không có thì dùng ngày plugin tự theo dõi trong state.
  // Xem cách chọn ở @help.
  function currentDayNumber(state) {
    var tp = timePlugin();
    if (tp && typeof $gameSystem !== "undefined" && $gameSystem &&
        typeof $gameSystem.pxbDayNumber === "number") {
      return $gameSystem.pxbDayNumber;
    }
    return state.day;
  }

  // Khung hiện tại ("Sáng"/"Chiều"/"Tối"). Cần PXB_Time; chưa có thì
  // trả null — event phải truyền khung rõ, không đoán khung.
  function currentFrameName() {
    var tp = timePlugin();
    if (tp && typeof tp.frameName === "function" &&
        typeof tp.elapsedMinutes === "function") {
      return tp.frameName(tp.elapsedMinutes());
    }
    return null;
  }

  // State hotspot hiện tại. Ưu tiên $gameSystem.pxbHotspot (đi theo save);
  // chưa có core MV thì dùng dữ liệu dự phòng.
  function state() {
    if (typeof $gameSystem !== "undefined" && $gameSystem) {
      if (!$gameSystem.pxbHotspot) {
        $gameSystem.pxbHotspot = createState(currentDayNumber({ day: 1 }));
      }
      return $gameSystem.pxbHotspot;
    }
    return fallbackState;
  }

  // Túi nguyên liệu hiện tại ($gameSystem.pxbMaterials — dùng chung id
  // với Crafting.cs / PXB_Crafting.js sau này).
  function materials() {
    if (typeof $gameSystem !== "undefined" && $gameSystem) {
      if (!$gameSystem.pxbMaterials) {
        $gameSystem.pxbMaterials = {};
      }
      return $gameSystem.pxbMaterials;
    }
    return fallbackMaterials;
  }

  // Khởi tạo pxbHotspot + pxbMaterials trong $gameSystem (gọi khi new game).
  // Trả false khi chưa có $gameSystem — không giả vờ đã lưu được.
  function initInGameSystem() {
    if (typeof $gameSystem === "undefined" || !$gameSystem) return false;
    if (!$gameSystem.pxbHotspot) {
      $gameSystem.pxbHotspot = createState(1);
    }
    if (!$gameSystem.pxbMaterials) {
      $gameSystem.pxbMaterials = {};
    }
    return true;
  }

  // Nhặt hotspot ở khung + ngày hiện tại (đường dùng trong event).
  // Trả cùng dạng explore(): { ok, reason, materialId, amount }.
  function collect(hotspotId) {
    var st = state();
    var day = currentDayNumber(st);
    var frame = currentFrameName();
    return explore(st, hotspotId, day, frame, materials());
  }

  // Nhặt hotspot với khung truyền rõ (dùng khi PXB_Time chưa load hoặc
  // event muốn ép khung — vd test). dayNumber null = dùng ngày hiện tại.
  function collectAt(hotspotId, frameName, dayNumber) {
    var st = state();
    var day = (typeof dayNumber === "number") ? dayNumber : currentDayNumber(st);
    return explore(st, hotspotId, day, frameName, materials());
  }

  // Sang ngày game mới (plugin tự theo dõi ngày): reset lượt khám phá.
  // Khi PXB_Time đã móc pxbDayNumber thì không cần gọi — ngày đổi là
  // explore() tự reset. Gọi lệnh này chỉ cho đường fallback (xem @help).
  function advanceDay() {
    var st = state();
    newGameDay(st);
    st.day = st.day + 1;
    return st.day;
  }

  // Danh sách khu đã mở fast-travel hiện tại (slice). Sau này PXB_Story /
  // quest mở thêm khu thì ghi vào $gameSystem.pxbUnlockedDistricts.
  function unlockedDistricts() {
    if (typeof $gameSystem !== "undefined" && $gameSystem &&
        $gameSystem.pxbUnlockedDistricts) {
      return $gameSystem.pxbUnlockedDistricts;
    }
    return FAST_TRAVEL_UNLOCKED_SLICE.slice();
  }

  // Móc vào core MV (chỉ chạy khi core đã có; chưa có thì trả false).
  // - createGameObjects: new game -> khởi tạo pxbHotspot + pxbMaterials.
  // - extractSaveContents: load save -> bỏ lượt đã nhặt của hotspot lạ
  //   (save sửa tay / bảng hotspot đổi sau này), kẹp ngày về >= 1.
  // - makeSaveContents: KHÔNG cần alias — $gameSystem vốn đã nằm trong
  //   save contents của core MV nên pxbHotspot + pxbMaterials đi theo
  //   save tự động (architecture-nadia.md §1.5).
  // Plugin command cho event:
  //   PXB_Hotspot Collect <hotspotId>  — nhặt ở khung + ngày hiện tại
  //   PXB_Hotspot Hint                 — hiện gợi ý GuideHint theo khu
  //                                      hiện tại ($gameMap.mapId() = id khu)
  //   PXB_Hotspot NewDay               — sang ngày mới (đường fallback)
  function install() {
    if (typeof DataManager === "undefined") return false;
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
            $gameSystem.pxbHotspot) {
          var st = $gameSystem.pxbHotspot;
          if (typeof st.day !== "number" || st.day < 1) st.day = 1;
          if (!st.visited || typeof st.visited !== "object") st.visited = {};
          // Bỏ lượt đã nhặt của hotspot không còn trong bảng.
          var kept = {};
          for (var id in st.visited) {
            if (st.visited.hasOwnProperty(id) && get(id)) kept[id] = true;
          }
          st.visited = kept;
        }
      };
    }
    if (typeof Game_Interpreter !== "undefined" &&
        typeof Game_Interpreter.prototype.pluginCommand === "function") {
      var _pluginCommand = Game_Interpreter.prototype.pluginCommand;
      Game_Interpreter.prototype.pluginCommand = function (command, args) {
        _pluginCommand.call(this, command, args);
        if (command === "PXB_Hotspot") {
          if (args[0] === "Collect" && args[1]) {
            collect(args[1]);
          } else if (args[0] === "NewDay") {
            advanceDay();
          } else if (args[0] === "Hint") {
            if (typeof $gameMap !== "undefined" && $gameMap &&
                typeof $gameMap.mapId === "function" &&
                typeof $gameMessage !== "undefined" && $gameMessage) {
              var goal = "";
              if (typeof $gameSystem !== "undefined" && $gameSystem &&
                  typeof $gameSystem.pxbCurrentGoal === "string") {
                goal = $gameSystem.pxbCurrentGoal;
              }
              $gameMessage.add(guideHint($gameMap.mapId(), goal));
            }
          }
        }
      };
    }
    return true;
  }

  // Áp dụng hook ngay khi file load (quy ước MV). Không có core thì
  // install() trả false và không làm gì.
  install();

  var PXB_Hotspot = {
    HOTSPOTS: HOTSPOTS,
    FAST_TRAVEL_UNLOCKED_SLICE: FAST_TRAVEL_UNLOCKED_SLICE,
    DISTRICT_COUNT: DISTRICT_COUNT,
    MIN_TOUCH_PT: MIN_TOUCH_PT,
    SPARKLE_COLOR_COMMON: SPARKLE_COLOR_COMMON,
    SPARKLE_COLOR_RARE: SPARKLE_COLOR_RARE,
    BRIGHTNESS_COLLECTED: BRIGHTNESS_COLLECTED,
    BRIGHTNESS_BEST_FRAME: BRIGHTNESS_BEST_FRAME,
    BRIGHTNESS_NORMAL: BRIGHTNESS_NORMAL,
    get: get,
    hotspotsInDistrict: hotspotsInDistrict,
    canFastTravel: canFastTravel,
    createState: createState,
    newGameDay: newGameDay,
    explore: explore,
    hasVisitedToday: hasVisitedToday,
    sparkleColor: sparkleColor,
    sparkleScale: sparkleScale,
    sparkleBrightness: sparkleBrightness,
    minTouchPt: minTouchPt,
    guideHint: guideHint,
    frameNames: frameNames,
    currentDayNumber: currentDayNumber,
    currentFrameName: currentFrameName,
    state: state,
    materials: materials,
    initInGameSystem: initInGameSystem,
    collect: collect,
    collectAt: collectAt,
    advanceDay: advanceDay,
    unlockedDistricts: unlockedDistricts,
    install: install
  };

  if (typeof module !== "undefined" && module.exports) {
    module.exports = PXB_Hotspot;
  } else if (typeof window !== "undefined") {
    window.PXB_Hotspot = PXB_Hotspot;
  }
})();
