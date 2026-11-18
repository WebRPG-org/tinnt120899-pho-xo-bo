/*:
 * @plugindesc Phố Xô Bồ — danh hiệu: xung đột chặn lẫn nhau 2 chiều, phe Chính/Tà/Trung lập, quest đổi phe "Cải tà quy chính".
 * @author Muse Center
 *
 * @help
 * Port trung thực TitleConflict.cs
 * (src/client/Assets/Scripts/TitleConflict.cs, GDD Mục 3).
 *
 * - Danh hiệu không giới hạn số lượng sưu tầm; hiển thị 1 chính +
 *   2–3 phụ (GDD Mục 3). Mỗi danh hiệu có phe Chính / Tà / Trung
 *   lập, yêu cầu chỉ số, khoá nghề. Xung đột chặn lẫn nhau — ví dụ
 *   Tướng Cướp không làm được Cảnh sát. Đổi phe cần quest "Cải tà
 *   quy chính".
 * - Bảng chặn BlockedBy giữ đúng y C# (7 dòng, so sánh không phân
 *   biệt hoa/thường). isBlocked() chặn cả hai chiều: chiều xuôi
 *   (danh hiệu đang có chặn danh hiệu/nghề muốn nhận) + chiều ngược
 *   (tra BlockedBy[wanted] — không cần bảng ngược riêng).
 * - Danh hiệu lưu dạng object thuần (JSON-safe) trong
 *   $gameSystem.pxbTitles = {titles: [...], alignment: "TrungLap"}
 *   nên đi theo save của MV. Mọi hàm đều nhận object thuần — không
 *   dùng class / closure giữ method, vì method mất khi save/load.
 *
 * QUIRK GIỮ ĐÚNG C# (không tự sửa):
 *   - Kẻ Lừa Đảo CHỈ chặn "Luật Sư Chính Trực" — KHÔNG chặn
 *     "Luật Sư Bào Chữa". Đây là quirk cố ý trong TitleConflict.cs
 *     (có comment ghi rõ), giữ nguyên — đừng "sửa" cho đối xứng.
 *   - isBlocked() null-safe: wanted null → false, title null trong
 *     list đang có thì bỏ qua — đúng C# (C# kiểm tra
 *     `wantedTitleOrJob is null` và `title is null` trước khi so).
 *
 * PROVISIONAL — chưa chốt GDD, đổi thì sửa ở đây + TitleConflict.cs
 * + docs/gdd.md Mục 3 cùng lúc:
 *   - Danh sách phe Chính / Tà suy ra từ bảng chặn (GDD Mục 3 chỉ
 *     chốt "mỗi danh hiệu có phe", chưa liệt kê danh hiệu nào thuộc
 *     phe nào):
 *       Phe Tà: Tướng Cướp, Trùm Buôn Lậu, Tham Quan, Kẻ Lừa Đảo.
 *       Phe Chính: Thanh Liêm, Người Hùng, Luật Sư Chính Trực,
 *         Học Giả, Tiến sĩ, Tỷ Phú Từ Thiện.
 *     alignmentOf(): có danh hiệu phe Tà → "Ta"; có danh hiệu phe
 *     Chính → "Chinh"; cả hai phe hoặc không có gì → "TrungLap".
 *   - Quest "Cải tà quy chính": GDD Mục 3 / TitleConflict.cs chỉ
 *     nhắc tên, chưa chốt điều kiện chi tiết (cần làm gì, tốn bao
 *     nhiêu, có mất gì không). Tạm chốt: canRedeem() true khi
 *     alignment hiện tại là "Ta"; redeem() xóa mọi danh hiệu phe Tà.
 *   - Field alignment trong state chỉ là bản sao đã tính sẵn từ
 *     titles (để event đọc nhanh); nguồn sự thật là titles —
 *     addTitle()/removeTitle()/redeem() tự cập nhật lại field này.
 *
 * Lưu: state sống trong $gameSystem.pxbTitles nên đi theo save của
 * MV ($gameSystem vốn đã nằm trong save contents của core). Khi core
 * MV chưa có (repo hiện tại), logic thuần vẫn chạy và test được qua
 * module.exports; hàm install() trả false và không giả vờ đã móc save.
 *
 * Dùng trong event (khi có core MV):
 *   PXB_Titles.add("Tướng Cướp")              // false nếu đã có / bị chặn
 *   PXB_Titles.has("cảnh sát")                // so không phân biệt hoa/thường
 *   PXB_Titles.canTakeJobNow("Cảnh sát")      // false khi đang có Tướng Cướp
 *   PXB_Titles.alignmentNow()                 // "Chinh" / "Ta" / "TrungLap"
 *   PXB_Titles.canRedeemNow()                 // true khi đang phe Tà
 *   PXB_Titles.redeemNow()                    // xóa mọi danh hiệu phe Tà
 */
(function () {
  "use strict";

  // --- Enum Alignment (port enum TitleConflict.cs) ---

  var ALIGNMENT = {
    CHINH: "Chinh",       // phe Chính
    TA: "Ta",             // phe Tà
    TRUNG_LAP: "TrungLap" // trung lập / chưa rõ phe / cả hai phe
  };

  // --- Bảng chặn (port đúng y TitleConflict.cs — 7 dòng) ---

  // Danh hiệu -> danh hiệu / nghề bị chặn. So sánh không phân biệt
  // hoa/thường (C# dùng StringComparer.OrdinalIgnoreCase).
  var BLOCKED_BY = {
    "Tướng Cướp": ["Cảnh sát", "Thẩm phán", "Hải quan", "Giáo viên"],
    "Trùm Buôn Lậu": ["Cảnh sát", "Thẩm phán", "Hải quan", "Giáo viên"],
    "Tham Quan": ["Thanh Liêm", "Người Hùng"],
    // QUIRK — giữ đúng C#: chỉ chặn "Luật Sư Chính Trực", KHÔNG chặn
    // "Luật Sư Bào Chữa" (xem @help).
    "Kẻ Lừa Đảo": ["Luật Sư Chính Trực"],
    "Học Giả": ["Kẻ Bỏ Học"],
    "Tiến sĩ": ["Kẻ Bỏ Học"],
    "Tỷ Phú Từ Thiện": ["Kẻ Keo Kiệt"]
  };

  // --- Danh sách phe Chính / Tà (PROVISIONAL — xem @help) ---

  // Suy ra từ bảng chặn: danh hiệu nào chặn / bị chặn bởi phe đối
  // diện thì thuộc phe đó. GDD Mục 3 chưa chốt danh sách đầy đủ.
  var EVIL_TITLES = ["Tướng Cướp", "Trùm Buôn Lậu", "Tham Quan",
    "Kẻ Lừa Đảo"];
  var GOOD_TITLES = ["Thanh Liêm", "Người Hùng", "Luật Sư Chính Trực",
    "Học Giả", "Tiến sĩ", "Tỷ Phú Từ Thiện"];

  // --- So sánh không phân biệt hoa/thường ---

  function equalsIgnoreCase(a, b) {
    if (typeof a !== "string" || typeof b !== "string") return false;
    return a.toLowerCase() === b.toLowerCase();
  }

  // Tìm key trong BLOCKED_BY khớp không phân biệt hoa/thường.
  // Trả null nếu không có.
  function blockedByKey(title) {
    if (typeof title !== "string") return null;
    var lower = title.toLowerCase();
    for (var k in BLOCKED_BY) {
      if (k.toLowerCase() === lower) return k;
    }
    return null;
  }

  // --- Xung đột danh hiệu (port TitleConflict.IsBlocked) ---

  // True nếu danh hiệu đang có chặn danh hiệu/nghề muốn nhận — chặn
  // cả hai chiều của mỗi cặp xung đột, không phân biệt hoa/thường.
  // Null-safe: wanted null → false, title null trong list thì bỏ qua
  // (đúng C#).
  function isBlocked(ownedTitles, wantedTitleOrJob) {
    if (wantedTitleOrJob === null ||
        typeof wantedTitleOrJob === "undefined") {
      return false;
    }
    if (!ownedTitles || !Array.isArray(ownedTitles)) return false;
    for (var i = 0; i < ownedTitles.length; i++) {
      var title = ownedTitles[i];
      if (title === null || typeof title === "undefined") continue;
      // Chiều xuôi: danh hiệu đang có chặn danh hiệu/nghề muốn nhận.
      var key = blockedByKey(title);
      if (key) {
        var blocked = BLOCKED_BY[key];
        for (var j = 0; j < blocked.length; j++) {
          if (equalsIgnoreCase(blocked[j], wantedTitleOrJob)) {
            return true;
          }
        }
      }
      // Chiều ngược: danh hiệu/nghề muốn nhận chặn danh hiệu đang có
      // (ví dụ muốn nhận "Tướng Cướp" trong khi đang có "Cảnh sát").
      // Không cần bảng ngược riêng: tra thẳng BlockedBy[wanted].
      var wantedKey = blockedByKey(wantedTitleOrJob);
      if (wantedKey) {
        var blockedByWanted = BLOCKED_BY[wantedKey];
        for (var k = 0; k < blockedByWanted.length; k++) {
          if (equalsIgnoreCase(blockedByWanted[k], title)) {
            return true;
          }
        }
      }
    }
    return false;
  }

  // --- Danh hiệu người chơi (state thuần, JSON-safe) ---

  function defaultState() {
    return {
      titles: [],                 // string[] — danh hiệu đang có
      alignment: ALIGNMENT.TRUNG_LAP // bản sao đã tính từ titles
    };
  }

  // State thuần mới — tương đương `new` sổ danh hiệu trong C#.
  function createTitlesState() {
    return defaultState();
  }

  // Dữ liệu dự phòng khi chưa có core MV (logic thuần vẫn test được).
  var fallbackState = defaultState();

  function state() {
    if (typeof $gameSystem !== "undefined" && $gameSystem) {
      if (!$gameSystem.pxbTitles) {
        $gameSystem.pxbTitles = defaultState();
      }
      return $gameSystem.pxbTitles;
    }
    return fallbackState;
  }

  // Khởi tạo pxbTitles trong $gameSystem (gọi khi new game).
  // Trả false khi chưa có $gameSystem — không giả vờ đã lưu được.
  function initInGameSystem() {
    if (typeof $gameSystem === "undefined" || !$gameSystem) return false;
    if (!$gameSystem.pxbTitles) {
      $gameSystem.pxbTitles = defaultState();
    }
    return true;
  }

  // Reset sổ hiện tại (event/test dùng để bắt đầu lại).
  function resetState() {
    var st = state();
    st.titles = [];
    st.alignment = ALIGNMENT.TRUNG_LAP;
    return true;
  }

  // Danh sách danh hiệu trong 1 state thuần (bản sao — sửa bản sao
  // không ảnh hưởng state).
  function allTitles(st) {
    return (st && Array.isArray(st.titles)) ? st.titles.slice() : [];
  }

  // Có danh hiệu này không — không phân biệt hoa/thường.
  function hasTitle(st, title) {
    if (!st || !Array.isArray(st.titles) ||
        typeof title !== "string") {
      return false;
    }
    for (var i = 0; i < st.titles.length; i++) {
      if (equalsIgnoreCase(st.titles[i], title)) return true;
    }
    return false;
  }

  // Tính phe từ danh hiệu đang có (PROVISIONAL — xem @help):
  // có phe Tà → "Ta"; có phe Chính → "Chinh"; cả hai phe hoặc
  // không có gì → "TrungLap".
  function alignmentOf(st) {
    var titles = allTitles(st);
    var hasEvil = false;
    var hasGood = false;
    for (var i = 0; i < titles.length; i++) {
      var t = titles[i];
      if (typeof t !== "string") continue;
      for (var e = 0; e < EVIL_TITLES.length; e++) {
        if (equalsIgnoreCase(EVIL_TITLES[e], t)) hasEvil = true;
      }
      for (var g = 0; g < GOOD_TITLES.length; g++) {
        if (equalsIgnoreCase(GOOD_TITLES[g], t)) hasGood = true;
      }
    }
    if (hasEvil && hasGood) return ALIGNMENT.TRUNG_LAP;
    if (hasEvil) return ALIGNMENT.TA;
    if (hasGood) return ALIGNMENT.CHINH;
    return ALIGNMENT.TRUNG_LAP;
  }

  // Cập nhật lại field alignment đã tính sẵn trong state (nguồn sự
  // thật vẫn là titles — xem @help).
  function refreshAlignment(st) {
    if (!st) return;
    st.alignment = alignmentOf(st);
  }

  // Thêm danh hiệu. Trả false nếu đã có (không phân biệt hoa/thường)
  // hoặc bị chặn bởi danh hiệu đang có (dùng isBlocked — chặn cả hai
  // chiều). Title rỗng / không phải string cũng trả false.
  function addTitle(st, title) {
    if (!st || typeof title !== "string" || title === "") return false;
    if (!Array.isArray(st.titles)) st.titles = [];
    if (hasTitle(st, title)) return false;
    if (isBlocked(st.titles, title)) return false;
    st.titles.push(title);
    refreshAlignment(st);
    return true;
  }

  // Gỡ danh hiệu (không phân biệt hoa/thường). Trả false nếu không có.
  function removeTitle(st, title) {
    if (!st || !Array.isArray(st.titles) ||
        typeof title !== "string") {
      return false;
    }
    for (var i = 0; i < st.titles.length; i++) {
      if (equalsIgnoreCase(st.titles[i], title)) {
        st.titles.splice(i, 1);
        refreshAlignment(st);
        return true;
      }
    }
    return false;
  }

  // Có nhận được nghề này không — dùng isBlocked: danh hiệu đang có
  // chặn nghề thì không nhận được.
  function canTakeJob(st, jobName) {
    if (!st || !Array.isArray(st.titles)) return true;
    return !isBlocked(st.titles, jobName);
  }

  // --- Quest đổi phe "Cải tà quy chính" (PROVISIONAL — xem @help) ---

  // Được đổi phe khi alignment hiện tại là "Ta" (đang có danh hiệu
  // phe Tà).
  function canRedeem(st) {
    return alignmentOf(st) === ALIGNMENT.TA;
  }

  // Đổi phe: xóa mọi danh hiệu phe Tà. Trả true nếu đã đổi; false
  // nếu không phải phe Tà (không xóa gì).
  function redeem(st) {
    if (!canRedeem(st)) return false;
    if (!st || !Array.isArray(st.titles)) return false;
    var kept = [];
    for (var i = 0; i < st.titles.length; i++) {
      var t = st.titles[i];
      var isEvil = false;
      if (typeof t === "string") {
        for (var e = 0; e < EVIL_TITLES.length; e++) {
          if (equalsIgnoreCase(EVIL_TITLES[e], t)) isEvil = true;
        }
      }
      if (!isEvil) kept.push(t);
    }
    st.titles = kept;
    refreshAlignment(st);
    return true;
  }

  // --- Wrapper trên state hiện tại (event gọi trực tiếp) ---

  function add(title) { return addTitle(state(), title); }
  function remove(title) { return removeTitle(state(), title); }
  function has(title) { return hasTitle(state(), title); }
  function all() { return allTitles(state()); }
  function canTakeJobNow(jobName) { return canTakeJob(state(), jobName); }
  function alignmentNow() { return alignmentOf(state()); }
  function canRedeemNow() { return canRedeem(state()); }
  function redeemNow() { return redeem(state()); }

  // --- Móc vào core MV ---

  // Plugin command cho CommonEvent / event thường (tên danh hiệu có
  // thể gồm nhiều từ — nối các arg còn lại bằng khoảng trắng):
  //   PXB_Titles Add <title>     — nhận danh hiệu (false thì đã có / bị chặn)
  //   PXB_Titles Remove <title>  — gỡ danh hiệu
  //   PXB_Titles Redeem          — quest "Cải tà quy chính" (chỉ phe Tà)
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
              $gameSystem.pxbTitles) {
            // Điền lại field thiếu khi load save cũ / save sửa tay.
            var d = defaultState();
            var s = $gameSystem.pxbTitles;
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
        if (command === "PXB_Titles") {
          if (args[0] === "Add") {
            addTitle(state(), args.slice(1).join(" "));
          } else if (args[0] === "Remove") {
            removeTitle(state(), args.slice(1).join(" "));
          } else if (args[0] === "Redeem") {
            redeem(state());
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

  var PXB_Titles = {
    ALIGNMENT: ALIGNMENT,
    BLOCKED_BY: BLOCKED_BY,
    EVIL_TITLES: EVIL_TITLES,
    GOOD_TITLES: GOOD_TITLES,
    isBlocked: isBlocked,
    createTitlesState: createTitlesState,
    addTitle: addTitle,
    removeTitle: removeTitle,
    hasTitle: hasTitle,
    allTitles: allTitles,
    canTakeJob: canTakeJob,
    alignmentOf: alignmentOf,
    canRedeem: canRedeem,
    redeem: redeem,
    add: add,
    remove: remove,
    has: has,
    all: all,
    canTakeJobNow: canTakeJobNow,
    alignmentNow: alignmentNow,
    canRedeemNow: canRedeemNow,
    redeemNow: redeemNow,
    resetState: resetState,
    initInGameSystem: initInGameSystem,
    install: install
  };

  if (typeof module !== "undefined" && module.exports) {
    module.exports = PXB_Titles;
  } else if (typeof window !== "undefined") {
    window.PXB_Titles = PXB_Titles;
  }
})();
